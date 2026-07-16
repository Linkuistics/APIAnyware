//! Top-level TypeScript framework emission — the `TargetEmitter` orchestrator.
//!
//! Consumes the pure [`crate::class_graph`] (parent resolution, load order, the
//! class→module resolver) to turn the two render-**one**-class functions
//! ([`render_class`] → `.ts`, [`render_dts`] → `.d.ts`) into a complete per-framework
//! binding tree: one paired `<class>.ts` + `<class>.d.ts` per class written in
//! superclass-before-subclass load order, plus the **barrel** `index.ts` re-exporting
//! them all in that order. This is the TS analogue of sbcl's `emit_framework` (ADR-0034
//! load-order precedent), in TS idiom — a barrel of per-class modules, not a CL package
//! facade.
//!
//! ## On-disk layout (ADR-0055 §2)
//!
//! Under `generated_subdir = "generated"`, one **per-framework directory** (the
//! `@apianyware/<fw>` module) of per-class files plus a barrel:
//!
//! ```text
//! generated/
//!   foundation/
//!     index.ts         ← barrel: re-exports every class in load order, then ./enums, ./protocols
//!     nsobject.ts      ← (NSObject itself is runtime-owned, never emitted)
//!     nsstring.ts      ← one file per class: the ES6 class body + call sites
//!     nsstring.d.ts    ← the co-generated type surface
//!     nsmutablestring.ts
//!     …
//!     enums.ts         ← the framework's NS_ENUM/NS_OPTIONS as real TS enums (ADR-0055 §6)
//!     enums.d.ts       ← the co-generated (identical-bodied) enum type surface
//!     protocols.ts     ← the framework's @protocols as real TS interfaces (ADR-0055 §4)
//!     protocols.d.ts   ← the co-generated (identical-bodied) interface type surface
//! ```
//!
//! ## The barrel's re-export order is load-bearing (not cosmetic)
//!
//! A same-framework subclass imports its superclass from the **package barrel**
//! (`@apianyware/foundation`, via [`crate::class_graph::ClassModuleResolver`]), not a
//! relative path — an intra-package import cycle. Under ESM evaluation the subclass's
//! `extends Super` binding is live only if `Super`'s module evaluated first, so the
//! barrel must `export * from './<super>'` **before** `export * from './<sub>'`. That is
//! exactly the superclass-before-subclass order [`ordered_classes`] yields; synthesized
//! bare nodes (referenced superclasses not themselves collected) are
//! re-exported **ahead of** all collected classes for the same reason.

use std::collections::{BTreeMap, BTreeSet};
use std::io;
use std::path::Path;
use std::sync::Arc;

use apianyware_emit::code_writer::{CodeWriter, FileEmitter};
use apianyware_emit::enrichment::{class_error_selectors, class_retaining_params};
use apianyware_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};
use apianyware_emit::write_line;
use apianyware_types::ir::Framework;

use crate::class_graph::{
    build_class_graph, ordered_classes, ClassModuleResolver, ClassRegistry, RUNTIME_MODULE,
    RUNTIME_ROOT,
};
use crate::class_surface::{bound_methods, has_emitted_error_method};
use crate::delegate_spec::{render_delegates_dts, render_delegates_module, DELEGATES_STEM};
use crate::emit_class::render_class;
use crate::emit_constants::{
    emitted_constant_count, render_constants_dts, render_constants_module,
};
use crate::emit_dts::render_dts;
use crate::emit_enums::{
    emitted_enum_count, is_emittable_enum, render_enums_dts, render_enums_module,
};
use crate::emit_functions::{
    emitted_function_count, render_functions_dts, render_functions_module,
};
use crate::emit_protocol::{
    emitted_protocol_count, render_protocols_dts, render_protocols_module,
    transitively_emittable_protocols,
};
use crate::enum_graph::{EnumModuleResolver, EnumRegistry};
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::naming::{module_specifier, ClassFileStems};
use crate::override_widening::override_param_widenings;
use crate::protocol_graph::{ProtocolModuleResolver, ProtocolRegistry};

/// Metadata for the `typescript` target (ADR-0055; the Node TypeScript target).
/// `generated_subdir = "generated"` — TS imposes no on-disk path constraint on the
/// module name (unlike chez), so it takes the common default; the `@apianyware/<fw>`
/// import specifier is a `package.json`/tsconfig-paths concern, not a directory one.
pub const TS_TARGET_INFO: TargetInfo = TargetInfo {
    id: "typescript",
    display_name: "TypeScript",
    generated_subdir: "generated",
};

/// A [`FileEmitter`] that **refuses to write the same filename twice** — the write-side dual
/// of the import-honesty invariant (k66): the emitted artifact set must *contain* a file for
/// every class the IR declares, exactly as it may only *import* a class the IR declares.
///
/// Before this guard the orchestrator counted `files_written` by arithmetic and reported
/// `classes_emitted` from `fw.classes.len()`, so nothing compared what was written against
/// what was declared. A non-injective file stem ([`ClassFileStems`], which this exists to
/// backstop) therefore lost 17 Matter classes in silence: two writes, one file, last one wins,
/// and 34 sibling modules went on importing a name that existed nowhere.
///
/// So the count is now **measured, not asserted** — `files_written` is the number of distinct
/// filenames actually written — and a second write to one name is a hard error naming the
/// file. A future stem rule cannot silently lose a class; it can only fail loudly.
struct WriteOnceEmitter {
    inner: FileEmitter,
    written: BTreeSet<String>,
}

impl WriteOnceEmitter {
    fn new(output_dir: &Path, framework_name: &str) -> io::Result<Self> {
        Ok(Self {
            inner: FileEmitter::new(output_dir, framework_name)?,
            written: BTreeSet::new(),
        })
    }

    fn write_file(&mut self, filename: &str, content: &str) -> io::Result<()> {
        if !self.written.insert(filename.to_string()) {
            return Err(io::Error::new(
                io::ErrorKind::AlreadyExists,
                format!(
                    "emit-typescript: '{filename}' would be written twice — two declared \
                     constructs share one on-disk file, and the second would silently clobber \
                     the first. The class→stem map must be injective (naming::ClassFileStems)."
                ),
            ));
        }
        self.inner.write_file(filename, content)
    }

    /// The number of **distinct** files written — measured, so it cannot disagree with the disk.
    fn files_written(&self) -> usize {
        self.written.len()
    }
}

/// The `typescript` target emitter — pure codegen over the analysed `Framework` IR, no
/// native linkage (the hermetic ADR-0011 seam; the addon is Steps 3–4).
///
/// Carries three cross-framework ownership registries — the [`ClassRegistry`] (a referenced
/// class owned by another framework → its `@apianyware/<fw>` module), the parallel
/// [`EnumRegistry`] (a referenced enum owned by another framework → its module, plus the
/// recognition set that lets the type mapper upgrade an enum alias off `number`,
/// ADR-0055 §6), and the [`ProtocolRegistry`] (a conformed / inherited protocol owned by
/// another framework → its module, ADR-0055 §4 — the class `implements` clause and
/// cross-framework protocol `extends`). All empty in [`TsEmitter::new`] — same-framework refs
/// still resolve from the framework's own class/enum/protocol sets, and unresolvable
/// cross-framework refs degrade to the current framework — so an unconfigured emitter still
/// produces a self-consistent tree. The Step-5 generate CLI pre-pass builds the global
/// registries over every loaded framework and swaps in a configured emitter via
/// [`TsEmitter::with_registries`] (the sbcl whole-program shape).
#[derive(Default)]
pub struct TsEmitter {
    class_registry: ClassRegistry,
    enum_registry: EnumRegistry,
    protocol_registry: ProtocolRegistry,
    /// Whole-program set of classes that must not receive the synthetic plain `init(): this`
    /// ([`crate::class_graph::synthetic_init_blocklist`], `nsobject-plain-init-surface-gap-k122`)
    /// — empty by default, exactly like the other three registries, so an unconfigured emitter
    /// still produces a self-consistent (if potentially over-eager) result.
    synthetic_init_blocklist: BTreeSet<String>,
}

impl TsEmitter {
    pub fn new() -> Self {
        Self::default()
    }

    /// An emitter backed by the whole-program cross-framework **class** ownership registry
    /// (the CLI pre-pass shape); the enum and protocol registries are empty, so
    /// cross-framework enums/protocols fall back to same-framework resolution (same-framework
    /// ones still upgrade / conform and import).
    pub fn with_registry(class_registry: ClassRegistry) -> Self {
        Self {
            class_registry,
            ..Self::default()
        }
    }

    /// An emitter backed by all three whole-program cross-framework ownership registries — the
    /// full CLI pre-pass shape (class, enum *and* protocol ownership) — plus the whole-program
    /// synthetic-init blocklist (struct doc).
    pub fn with_registries(
        class_registry: ClassRegistry,
        enum_registry: EnumRegistry,
        protocol_registry: ProtocolRegistry,
        synthetic_init_blocklist: BTreeSet<String>,
    ) -> Self {
        Self {
            class_registry,
            enum_registry,
            protocol_registry,
            synthetic_init_blocklist,
        }
    }
}

impl TargetEmitter for TsEmitter {
    fn target_info(&self) -> &TargetInfo {
        &TS_TARGET_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        emit_framework(
            framework,
            output_dir,
            &self.class_registry,
            &self.enum_registry,
            &self.protocol_registry,
            &self.synthetic_init_blocklist,
        )
    }
}

/// Emit one framework's complete binding tree into `output_dir/<fw_low>/`: the paired
/// per-class `.ts` + `.d.ts` files in superclass-before-subclass load order (synthesized
/// bare nodes ahead of collected classes) and the barrel `index.ts` re-exporting them
/// in that order. Pure codegen; the class resolver (from `registry`) routes cross-class
/// imports, the enum resolver (from `enum_registry` + this framework's own enums) upgrades
/// enum aliases and routes their type-only imports, and the protocol resolver (from
/// `protocol_registry` + this framework's own emittable protocols) drives the class
/// `implements` clause and cross-framework protocol `extends`, routing each interface's
/// type-only import to its owning module.
pub fn emit_framework(
    fw: &Framework,
    output_dir: &Path,
    registry: &ClassRegistry,
    enum_registry: &EnumRegistry,
    protocol_registry: &ProtocolRegistry,
    synthetic_init_blocklist: &BTreeSet<String>,
) -> io::Result<EmitResult> {
    // The resolved class graph (parents + synthesized bare nodes) and the class→module
    // resolver both derive from the same registry — the pure reasoning of the sibling
    // `class-graph-k21` leaf, consumed here.
    let graph = build_class_graph(fw, registry);
    // The **declared-class recognition set** every `Class{name}` reference resolves against
    // (`class_binding`, k66): the cross-framework registry's classes plus this framework's own —
    // the same same-framework seeding the enums and protocols get below, so a single-framework
    // emitter still recognises its own classes. It settles the `TypeRefKind::Class` overload: a
    // name in it is a real ObjC class the emitter emits (bind); a name outside it is either a
    // real ObjC class this target does not emit (degrade to the root) or a `.swiftinterface`
    // nominal type with no ObjC identity (defer the member). Under the generate CLI the registry
    // spans every framework, so this reduces to the set the table collectors build from
    // `ordered_frameworks` ([`declared_classes`]) — which is exactly what keeps the emitted call
    // sites and the generated tables walking one frontier.
    let known_classes: Arc<BTreeSet<String>> = Arc::new(
        registry
            .names()
            .into_iter()
            .chain(fw.classes.iter().map(|c| c.name.clone()))
            .collect(),
    );
    let resolver = ClassModuleResolver::new(&fw.name, registry, Arc::clone(&known_classes));
    // The enum→module resolver + the mapper's recognition set: the cross-framework
    // registry's owned enums plus this framework's own emittable enums (so an unconfigured,
    // single-framework emitter still recognises and upgrades its own enums — the
    // same-framework seeding classes get from the collected class set). ADR-0055 §6.
    let known_enums: Arc<BTreeSet<String>> = Arc::new(
        enum_registry
            .names()
            .into_iter()
            .chain(
                fw.enums
                    .iter()
                    .filter(|en| is_emittable_enum(en))
                    .map(|en| en.name.clone()),
            )
            .collect(),
    );
    let enum_resolver = EnumModuleResolver::new(&fw.name, enum_registry, known_enums);
    // The protocol→module resolver + its recognition set: the cross-framework registry's
    // owned protocols plus this framework's own emittable protocols (so an unconfigured,
    // single-framework emitter still emits its own `implements` conformances — the
    // same-framework seeding, exactly as enums get from `fw.enums`). ADR-0055 §4.
    //
    // Built with a **class-only** mapper, and it has to be: emittability *computes* the protocol
    // recognition set, so it cannot already hold it. Sound because
    // [`transitively_emittable_protocols`] runs the method frontier, and the frontier reads only
    // class membership and the ABI shape — never enums, never protocols.
    // (`emittability_is_recognition_blind` in `emit_protocol` pins that for the own-surface base
    // case; if it ever stopped holding, this would be a bootstrap paradox, not a mere gap.)
    //
    // Same-framework transitive fallback (ADR-0055 §4b, k106): an unconfigured, single-framework
    // emitter still recognises its own protocol's *inherited* surface, not just its own — the
    // whole-program `protocol_registry` above already carries the fully cross-framework-transitive
    // set for a configured, multi-framework run.
    let known_protocols: Arc<BTreeSet<String>> = {
        let frontier = TsFfiTypeMapper::with_known_classes(Arc::clone(&known_classes));
        Arc::new(
            protocol_registry
                .names()
                .into_iter()
                .chain(transitively_emittable_protocols(
                    fw.protocols.iter(),
                    &frontier,
                ))
                .collect(),
        )
    };
    let protocol_resolver =
        ProtocolModuleResolver::new(&fw.name, protocol_registry, known_protocols);
    // The framework-level mapper — all three recognition sets, exactly as each per-artifact emitter
    // builds its own. Used for the framework-wide *counts* (fallible probe, protocols,
    // constants, functions), which must be computed with the same knowledge the render passes
    // use or the barrel would re-export a module the renderer wrote nothing into.
    let mapper = TsFfiTypeMapper::with_known(
        enum_resolver.known_enums(),
        Arc::clone(&known_classes),
        protocol_resolver.known_protocols(),
    );
    let ordered = ordered_classes(fw, &graph);
    // The framework's classes by ObjC name — the override-widening ancestor walk's world
    // (`crate::override_widening`; same-framework by construction, the module doc's scope limit).
    let class_index: BTreeMap<&str, &apianyware_types::ir::Class> =
        fw.classes.iter().map(|c| (c.name.as_str(), c)).collect();

    let mut emitter = WriteOnceEmitter::new(output_dir, &fw.name)?;

    // The **injective** class→stem decision for this directory, built once over every class
    // the directory will hold — the synthesized bare nodes and the collected classes share
    // it — and read by both the file writer below and the barrel. Lowercasing alone is not
    // injective (Matter's 17 ALL-CAPS/alias pairs), and a case-insensitive filesystem cannot
    // keep two stems apart that differ only in case; `ClassFileStems` carries the whole
    // argument.
    let stems = ClassFileStems::new(
        graph
            .synthesized
            .iter()
            .map(String::as_str)
            .chain(ordered.iter().map(|c| c.name.as_str())),
    );

    // The barrel re-export order == the ESM-safe load order: synthesized bare nodes
    // (each a superclass of some collected class) first, then the collected classes
    // superclass-before-subclass. Stems, not class names — the barrel re-exports files.
    let mut load_order: Vec<&str> = Vec::with_capacity(graph.synthesized.len() + ordered.len());

    for name in &graph.synthesized {
        let stem = stems.stem(name);
        emitter.write_file(&format!("{stem}.ts"), &render_bare_node_ts(name, &fw.name))?;
        emitter.write_file(
            &format!("{stem}.d.ts"),
            &render_bare_node_dts(name, &fw.name),
        )?;
        load_order.push(stem);
    }
    let mut framework_has_fallible = false;
    for cls in &ordered {
        let stem = stems.stem(&cls.name);
        // The class's NSError out-param selector set — the enrichment relation every target
        // keys error-out routing off (ADR-0058), empty without enrichment. Drives which of
        // the class's methods emit a `Result<T>` surface.
        let error_selectors = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
        // The class's declared-retaining `(selector, param_index)` slots — k82's resolved three-state
        // ownership, which decides the ADR-0059 §6 associate-or-skip arm for every bound `id<P>` slot
        // this class bridges (`emitted-delegate-spec-k84`). A `.d.ts` needs none: a bridged slot's
        // *type* is unchanged; only its body differs.
        let retaining = class_retaining_params(&fw.class_annotations, &cls.name);
        framework_has_fallible = framework_has_fallible
            || has_emitted_error_method(cls, &mapper, &error_selectors, protocol_registry);
        // The params the SDK redeclares incompatibly with an ancestor's declaration — computed
        // once over the same bound frontier both artifacts render, handed to both, so the `.ts`
        // and `.d.ts` widen (and import) identically (ADR-0055 §4b,
        // `sdk-override-incompatibility-policy-k105`).
        let widenings = {
            let (statics, instances) =
                bound_methods(cls, &mapper, &error_selectors, protocol_registry);
            override_param_widenings(
                cls,
                &statics,
                &instances,
                &class_index,
                &mapper,
                protocol_registry,
            )
        };
        emitter.write_file(
            &format!("{stem}.ts"),
            &render_class(
                cls,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
                &error_selectors,
                &retaining,
                &widenings,
                synthetic_init_blocklist,
            ),
        )?;
        emitter.write_file(
            &format!("{stem}.d.ts"),
            &render_dts(
                cls,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
                &error_selectors,
                &widenings,
                synthetic_init_blocklist,
            ),
        )?;
        load_order.push(stem);
    }

    // Enums (ADR-0055 §6): one per-framework `enums.ts` + its co-generated `enums.d.ts`,
    // written only when the framework declares at least one *emittable* enum (a valid
    // TS-identifier name — anonymous synthetic-named enums are skipped, `emit_enums`). A real
    // TS enum carries both a runtime object and a type, so both files are emitted; the barrel
    // re-exports `./enums`. Enums carry no inter-dependency, so they need no load ordering
    // (unlike the class chain).
    let enum_count = emitted_enum_count(&fw.enums);
    let has_enums = enum_count > 0;
    if has_enums {
        emitter.write_file("enums.ts", &render_enums_module(&fw.enums, &fw.name))?;
        emitter.write_file("enums.d.ts", &render_enums_dts(&fw.enums, &fw.name))?;
    }

    // Protocols (ADR-0055 §4): one per-framework `protocols.ts` + its co-generated
    // `protocols.d.ts`, written only when the framework declares at least one *emittable*
    // protocol (a valid TS-identifier name with a bindable surface — empty markers and
    // non-identifier names are skipped, `emit_protocol`). An interface is type-only, so the
    // `.ts` is (essentially) empty at runtime; it is emitted anyway so the barrel's
    // `export * from './protocols'` resolves at run time. Interfaces carry no cross-module
    // load order (same-framework `extends` is in-file), so they need none.
    let protocol_count = emitted_protocol_count(&fw.protocols, &mapper);
    let has_protocols = protocol_count > 0;
    if has_protocols {
        emitter.write_file(
            "protocols.ts",
            &render_protocols_module(
                &fw.protocols,
                &fw.name,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
            ),
        )?;
        emitter.write_file(
            "protocols.d.ts",
            &render_protocols_dts(
                &fw.protocols,
                &fw.name,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
            ),
        )?;
    }

    // Delegate specs (ADR-0059 §3/§8): one per-framework `delegates.ts` + its co-generated
    // `delegates.d.ts`, carrying one `DelegateSpec` per protocol this framework emits an interface
    // for — what turns a plain JS object literal reaching a bound `id<P>` slot into a real ObjC
    // forwarder (`emitted-delegate-spec-k84`). Written on exactly the [`emitted_protocol_count`]
    // condition, because the spec set **is** the interface set (`delegate_spec::spec_protocols`): a
    // bound qualifier must always find its `SPEC_<P>` exported, in any framework.
    //
    // It re-exports **before** the classes, though it need not: a spec's only import is
    // `@apianyware/runtime`, so it has no edge back into a class module and cannot be part of a
    // barrel cycle at all — the property that made a separate module (rather than a `const` inside
    // `protocols.ts`) the right home. Ordering it first simply makes that visible.
    if has_protocols {
        emitter.write_file(
            &format!("{DELEGATES_STEM}.ts"),
            &render_delegates_module(&fw.protocols, &fw.name, &mapper),
        )?;
        emitter.write_file(
            &format!("{DELEGATES_STEM}.d.ts"),
            &render_delegates_dts(&fw.protocols, &fw.name, &mapper),
        )?;
    }

    // Constants (ADR-0055 §6): one per-framework `constants.ts` + its co-generated
    // `constants.d.ts`, written only when the framework declares at least one *emittable*
    // constant (a CFSTR macro, a pointer-valued object global, or a scalar/enum global — a
    // Swift-native / struct / non-routable constant defers, `emit_constants`). Each object
    // constant's module-load initializer references its wrap class as a runtime *value*, so
    // `./constants` re-exports **after** the classes (the same superclass-before-subclass
    // ESM-cycle discipline). Class refs route through the class resolver, enum refs through
    // the enum resolver (type-only).
    let constant_count = emitted_constant_count(&fw.constants, &mapper);
    let has_constants = constant_count > 0;
    if has_constants {
        emitter.write_file(
            "constants.ts",
            &render_constants_module(
                &fw.constants,
                &fw.name,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
            ),
        )?;
        emitter.write_file(
            "constants.d.ts",
            &render_constants_dts(
                &fw.constants,
                &fw.name,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
            ),
        )?;
    }

    // Functions (ADR-0054): one per-framework `functions.ts` + its co-generated
    // `functions.d.ts`, written only when the framework declares at least one *bindable*
    // `objc_exposed` free function (a Swift-native / variadic / inline / raw-pointer function
    // defers, `emit_functions`). A function body references classes only at *call* time (not
    // module load), so `./functions` needs no load ordering; it re-exports after the classes
    // for consistency. Same resolver routing as the constants.
    let function_count = emitted_function_count(&fw.functions, &fw.name, &mapper);
    let has_functions = function_count > 0;
    if has_functions {
        emitter.write_file(
            "functions.ts",
            &render_functions_module(
                &fw.functions,
                &fw.name,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
            ),
        )?;
        emitter.write_file(
            "functions.d.ts",
            &render_functions_dts(
                &fw.functions,
                &fw.name,
                &resolver,
                &enum_resolver,
                &protocol_resolver,
            ),
        )?;
    }

    emitter.write_file(
        "index.ts",
        &render_barrel(
            fw,
            &load_order,
            has_enums,
            has_protocols,
            has_constants,
            has_functions,
            framework_has_fallible,
        ),
    )?;

    Ok(EmitResult {
        // Measured, not computed: the distinct filenames the write-once guard actually
        // accepted. With one pair written per declared class and no name written twice,
        // this *is* the proof that no class was clobbered.
        files_written: emitter.files_written(),
        classes_emitted: fw.classes.len(),
        protocols_emitted: protocol_count,
        enums_emitted: enum_count,
        constants_emitted: constant_count,
        functions_emitted: function_count,
    })
}

/// The per-framework barrel `index.ts`: one `export * from './<stem>'` per emitted class
/// in load order — `load_order` carries the **stems** the file writer used
/// ([`ClassFileStems`]), not the class names, so the barrel cannot re-derive a stem the
/// writer disagrees with (the k57 "one decision, N readers" rule; re-deriving it is exactly
/// how the barrel came to re-export one file twice for Matter's colliding pairs). The class
/// exports are followed by `./enums`,
/// `./protocols`, `./constants`, and `./functions` when the framework declares them. Enums
/// and protocols carry no inter-dependency with the classes (a protocol's `export *`
/// re-exports interface **types** with no runtime footprint); the **constants** module's
/// object initializers reference their wrap class as a runtime value at module load, so it
/// re-exports **after** the classes (the same ESM-cycle discipline the class chain uses); the
/// **functions** module references classes only at call time, so it needs no ordering.
/// An empty framework — nothing declared — gets a bare `export {}` so the file is still a
/// valid ES module.
///
/// When the framework emits any fallible `…error:` method (`has_fallible`, ADR-0058), the
/// barrel also re-exports the runtime error surface — `Result` (type-only) and the
/// `unwrap` / `ObjCError` / `NSExceptionError` / `NSErrorError` value hierarchy — from
/// `@apianyware/runtime`, so a consumer of this framework can name the fallible methods'
/// return types and handlers from the same package (the per-class `import type { Result }`
/// is a local import the class re-export does not propagate). Runtime-provided (Step 3),
/// re-exported not defined.
#[allow(clippy::too_many_arguments)]
fn render_barrel(
    framework: &Framework,
    load_order: &[&str],
    has_enums: bool,
    has_protocols: bool,
    has_constants: bool,
    has_functions: bool,
    has_fallible: bool,
) -> String {
    let mut w = CodeWriter::new();
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(
        w,
        "// Framework: {} (module {})",
        framework.name,
        module_specifier(&framework.name)
    );
    w.line("//");
    w.line("// Per-framework barrel: re-exports every bound class in superclass-before-subclass");
    w.line(
        "// load order (ADR-0055 §2) — the ESM-cycle-safe order that lets a subclass import its",
    );
    w.line(
        "// superclass through this barrel — then the enums, protocols, constants, and functions.",
    );
    w.blank_line();
    if load_order.is_empty()
        && !has_enums
        && !has_protocols
        && !has_constants
        && !has_functions
        && !has_fallible
    {
        // A bare `export {}` marks an empty framework's file as an ES module.
        w.line("export {};");
    } else {
        // The delegate specs first: they import nothing but the runtime, so they can neither close a
        // cycle nor sit in a TDZ when a class body reads one (`emitted-delegate-spec-k84`).
        if has_protocols {
            write_line!(w, "export * from './{DELEGATES_STEM}';");
        }
        for stem in load_order {
            write_line!(w, "export * from './{stem}';");
        }
        if has_enums {
            w.line("export * from './enums';");
        }
        if has_protocols {
            w.line("export * from './protocols';");
        }
        if has_constants {
            w.line("export * from './constants';");
        }
        if has_functions {
            w.line("export * from './functions';");
        }
        if has_fallible {
            // The NSError** → Result<T> error surface (ADR-0058), re-exported from the
            // runtime so this framework's fallible methods are consumable by name.
            w.line("export type { Result } from '@apianyware/runtime';");
            w.line(
                "export { NSErrorError, NSExceptionError, ObjCError, unwrap } from '@apianyware/runtime';",
            );
        }
    }
    w.finish()
}

/// A synthesized bare intermediate node's `.ts` — a class referenced as a superclass but
/// not itself collected, emitted as a minimal root-derived class so the `extends` chain
/// does not dangle ([`build_class_graph`](crate::class_graph::build_class_graph)'s
/// same-framework-gap rule). Essentially never produced in real SDK data.
fn render_bare_node_ts(name: &str, framework: &str) -> String {
    let mut w = CodeWriter::new();
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(
        w,
        "// Class: {name} ({framework}) — synthesized bare class-graph node"
    );
    w.line("//");
    w.line("// Referenced as a superclass but not collected; a minimal root-derived class so the");
    w.line("// extends chain does not dangle (ADR-0055 §2). It still registers: a bare node is a");
    w.line("// real ObjC class, so a Class handle crossing out must resolve to THIS constructor");
    w.line("// rather than degrade to an unbound stand-in (`__classCtor`, classes.ts).");
    w.blank_line();
    emit_runtime_root_import(&mut w, &["__registerClass"]);
    write_line!(w, "export class {name} extends {RUNTIME_ROOT} {{");
    w.indent();
    write_line!(w, "static {{ __registerClass('{name}', {name}); }}");
    w.dedent();
    w.line("}");
    w.finish()
}

/// The synthesized bare node's paired `.d.ts` — the declaration-only surface of the same
/// minimal root-derived class. The registration is a runtime concern (a static block, absent
/// from the declaration surface), so this stays a bare `extends` — no seam symbols leak into
/// the `.d.ts` (ADR-0055 §2).
fn render_bare_node_dts(name: &str, framework: &str) -> String {
    let mut w = CodeWriter::new();
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(
        w,
        "// Type surface: {name} ({framework}) — synthesized bare class-graph node"
    );
    w.blank_line();
    emit_runtime_root_import(&mut w, &[]);
    write_line!(w, "export class {name} extends {RUNTIME_ROOT} {{}}");
    w.finish()
}

/// The runtime import a bare node needs: the root (`NSObject`) it extends, plus any `.ts`-only
/// seam symbols (`seam`, empty for the `.d.ts`). Names render sorted, matching
/// [`crate::imports::render_import_blocks`]'s ordering, so the two emitters agree.
fn emit_runtime_root_import(w: &mut CodeWriter, seam: &[&str]) {
    let mut names: Vec<&str> = std::iter::once(RUNTIME_ROOT)
        .chain(seam.iter().copied())
        .collect();
    names.sort_unstable();
    w.line("import {");
    for name in names {
        write_line!(w, "  {name},");
    }
    write_line!(w, "}} from '{RUNTIME_MODULE}';");
    w.blank_line();
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Class, Method, Param, Protocol};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn framework(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes,
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    fn class(name: &str, superclass: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.into(),
            superclass: superclass.into(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn object_return_method(selector: &str, class_name: &str) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: false,
            params: vec![Param {
                name: "x".into(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Id {
                        protocols: Vec::new(),
                    },
                },
            }],
            return_type: TypeRef {
                nullable: true,
                kind: TypeRefKind::Class {
                    name: class_name.into(),
                    framework: None,
                    params: vec![],
                },
            },
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn void_method(selector: &str) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: false,
            params: vec![],
            return_type: TypeRef::void(),
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn protocol(name: &str, required: Vec<Method>) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: vec![],
            required_methods: required,
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    fn emit(fw: &Framework, registry: &ClassRegistry) -> (tempfile::TempDir, EmitResult) {
        let tmp = tempfile::tempdir().unwrap();
        // The enum and protocol registries are empty here — same-framework enums/protocols
        // still recognise and route (seeded from `fw.enums` / `fw.protocols`);
        // cross-framework routing is exercised in unit tests.
        let res = emit_framework(
            fw,
            tmp.path(),
            registry,
            &EnumRegistry::new(),
            &ProtocolRegistry::new(),
            &BTreeSet::new(),
        )
        .unwrap();
        (tmp, res)
    }

    #[test]
    fn target_info_is_typescript() {
        let e = TsEmitter::new();
        assert_eq!(e.target_info().id, "typescript");
        assert_eq!(e.target_info().display_name, "TypeScript");
        assert_eq!(e.target_info().generated_subdir, "generated");
    }

    #[test]
    fn empty_framework_writes_just_the_barrel() {
        let e = TsEmitter::new();
        let tmp = tempfile::tempdir().unwrap();
        let result = e
            .emit_framework(&framework("Foundation", vec![]), tmp.path())
            .unwrap();
        assert_eq!(result.files_written, 1);
        assert_eq!(result.classes_emitted, 0);

        let index = tmp.path().join("foundation").join("index.ts");
        assert!(index.exists(), "expected {index:?} to be written");
        let content = std::fs::read_to_string(&index).unwrap();
        assert!(content.contains("emit-typescript"));
        assert!(content.contains("Framework: Foundation (module @apianyware/foundation)"));
        // An empty framework's barrel is still a valid ES module.
        assert!(content.contains("export {};"));
    }

    #[test]
    fn writes_paired_files_and_barrel_in_load_order() {
        // IR order deliberately reversed (subclass first) — the orchestrator must write
        // the barrel superclass-before-subclass (the ESM-cycle-safe order).
        let fw = framework(
            "AppKit",
            vec![
                class("NSControl", "NSView", vec![]),
                class("NSView", "NSResponder", vec![]),
                class("NSResponder", "NSObject", vec![]),
            ],
        );
        let (tmp, res) = emit(&fw, &ClassRegistry::new());
        // 3 classes × 2 files + barrel.
        assert_eq!(res.files_written, 7);
        assert_eq!(res.classes_emitted, 3);

        let dir = tmp.path().join("appkit");
        for stem in ["nsresponder", "nsview", "nscontrol"] {
            assert!(dir.join(format!("{stem}.ts")).exists(), "missing {stem}.ts");
            assert!(
                dir.join(format!("{stem}.d.ts")).exists(),
                "missing {stem}.d.ts"
            );
        }
        // The subclass's .ts really extends its superclass, imported from the package
        // barrel (the intra-package cycle the load order makes safe).
        let view = std::fs::read_to_string(dir.join("nsview.ts")).unwrap();
        assert!(
            view.contains("export class NSView extends NSResponder {"),
            "{view}"
        );
        assert!(
            view.contains("} from '@apianyware/appkit';"),
            "NSView imports its superclass from the package barrel:\n{view}"
        );

        // The barrel re-exports every class superclass-before-subclass.
        let barrel = std::fs::read_to_string(dir.join("index.ts")).unwrap();
        let order: Vec<&str> = ["nsresponder", "nsview", "nscontrol"].to_vec();
        let positions: Vec<usize> = order
            .iter()
            .map(|s| {
                barrel
                    .find(&format!("export * from './{s}';"))
                    .unwrap_or_else(|| panic!("barrel missing {s}:\n{barrel}"))
            })
            .collect();
        assert!(
            positions.windows(2).all(|w| w[0] < w[1]),
            "barrel must re-export superclass-before-subclass:\n{barrel}"
        );
    }

    #[test]
    fn synthesized_bare_node_is_written_ahead_and_re_exported_first() {
        // Leaf extends Mid, where Mid is referenced but not collected: Mid is synthesized
        // as a bare node, emitted (paired files) ahead of Leaf, and re-exported first.
        let fw = framework("Widgets", vec![class("Leaf", "Mid", vec![])]);
        let (tmp, res) = emit(&fw, &ClassRegistry::new());
        // Leaf (2) + Mid bare node (2) + barrel.
        assert_eq!(res.files_written, 5);
        // classes_emitted counts collected classes only (Mid is synthesized).
        assert_eq!(res.classes_emitted, 1);

        let dir = tmp.path().join("widgets");
        let mid = std::fs::read_to_string(dir.join("mid.ts")).unwrap();
        assert!(
            mid.contains("synthesized bare class-graph node"),
            "bare node banner:\n{mid}"
        );
        // The `.ts` body carries only the registration (a bare node is a real ObjC class, so a
        // Class handle crossing out must resolve to it, not to an unbound stand-in).
        assert!(
            mid.contains("export class Mid extends NSObject {")
                && mid.contains("static { __registerClass('Mid', Mid); }")
                && mid.contains("  __registerClass,\n"),
            "{mid}"
        );
        // The paired `.d.ts` stays a bare declaration — the static block is a runtime concern and
        // no seam symbol may leak into the type surface (ADR-0055 §2).
        let mid_dts = std::fs::read_to_string(dir.join("mid.d.ts")).unwrap();
        assert!(
            mid_dts.contains("export class Mid extends NSObject {}")
                && !mid_dts.contains("__registerClass"),
            "{mid_dts}"
        );

        let barrel = std::fs::read_to_string(dir.join("index.ts")).unwrap();
        let mid_pos = barrel
            .find("export * from './mid';")
            .expect("mid re-exported");
        let leaf_pos = barrel
            .find("export * from './leaf';")
            .expect("leaf re-exported");
        assert!(mid_pos < leaf_pos, "bare node re-exported first:\n{barrel}");
    }

    #[test]
    fn case_only_class_collision_emits_two_files_neither_clobbering_the_other() {
        // The real Matter pair (`class-file-stem-collision-k76`): an ALL-CAPS acronym class
        // and its Swift-friendly alias, which is declared as its *subclass*. Lowercasing the
        // name to form the stem mapped both onto `mtrbaseclusterwakeonlan.ts`, so the alias's
        // write clobbered the superclass's file — the superclass then existed nowhere, while
        // 17 sibling modules went on importing it by name (34 dangling imports corpus-wide,
        // the entire residual after k66).
        let fw = framework(
            "Matter",
            vec![
                class(
                    "MTRBaseClusterWakeOnLan",
                    "MTRBaseClusterWakeOnLAN",
                    vec![void_method("readAttributeMACAddress")],
                ),
                class("MTRBaseClusterWakeOnLAN", "NSObject", vec![]),
            ],
        );
        let (tmp, res) = emit(&fw, &ClassRegistry::new());
        // Both classes get their own pair; nothing is lost. 2 classes × 2 files + barrel.
        assert_eq!(
            res.files_written, 5,
            "a file pair per class, plus the barrel"
        );
        assert_eq!(res.classes_emitted, 2);

        let dir = tmp.path().join("matter");
        let barrel = std::fs::read_to_string(dir.join("index.ts")).unwrap();
        let exports: Vec<&str> = barrel
            .lines()
            .filter(|l| l.starts_with("export * from './"))
            .collect();
        assert_eq!(
            exports.len(),
            2,
            "one re-export per class — the collision used to emit the same line twice:\n{barrel}"
        );
        assert_ne!(
            exports[0], exports[1],
            "the two classes must re-export distinct files:\n{barrel}"
        );

        // Each re-exported file exists on disk and declares its own class — the superclass's
        // file is no longer overwritten by the subclass's.
        let mut declared: Vec<String> = Vec::new();
        for export in &exports {
            let stem = export
                .trim_start_matches("export * from './")
                .trim_end_matches("';");
            let ts = dir.join(format!("{stem}.ts"));
            assert!(
                ts.exists(),
                "barrel re-exports a file that does not exist: {ts:?}"
            );
            assert!(
                dir.join(format!("{stem}.d.ts")).exists(),
                "missing paired .d.ts for {stem}"
            );
            let body = std::fs::read_to_string(&ts).unwrap();
            declared.push(
                body.lines()
                    .find(|l| l.starts_with("export class "))
                    .unwrap_or_else(|| panic!("no class in {ts:?}"))
                    .to_string(),
            );
        }
        assert!(
            declared
                .iter()
                .any(|d| d.starts_with("export class MTRBaseClusterWakeOnLAN ")),
            "the ALL-CAPS class survives:\n{declared:#?}"
        );
        assert!(
            declared
                .iter()
                .any(|d| d.starts_with("export class MTRBaseClusterWakeOnLan ")),
            "the alias survives:\n{declared:#?}"
        );

        // And the two stems differ in more than case — APFS is case-insensitive, so stems
        // that differed only in case would still be one file on the developer's disk.
        let stems: Vec<String> = exports
            .iter()
            .map(|e| {
                e.trim_start_matches("export * from './")
                    .trim_end_matches("';")
                    .to_ascii_lowercase()
            })
            .collect();
        assert_ne!(stems[0], stems[1], "stems collide case-insensitively");
    }

    #[test]
    fn protocols_are_emitted_paired_and_re_exported_after_the_classes() {
        // A framework with one class and two protocols writes the paired protocols.ts +
        // protocols.d.ts, counts them, and re-exports './protocols' from the barrel after
        // the class (no ordering constraint — interfaces carry no inter-dependency).
        let mut fw = framework("TestKit", vec![class("TKObject", "NSObject", vec![])]);
        fw.protocols = vec![
            protocol("TKRefreshing", vec![void_method("refresh")]),
            protocol("TKDelegate", vec![void_method("didFire")]),
        ];
        let (tmp, res) = emit(&fw, &ClassRegistry::new());
        // 1 class × 2 files + 2 protocol files + 2 delegate-spec files + barrel.
        assert_eq!(res.files_written, 7);
        assert_eq!(res.protocols_emitted, 2);

        let dir = tmp.path().join("testkit");
        assert!(dir.join("protocols.ts").exists(), "protocols.ts written");
        assert!(
            dir.join("protocols.d.ts").exists(),
            "protocols.d.ts written"
        );
        // The spec set IS the interface set (`delegate_spec::spec_protocols`), so the two modules are
        // written on one condition: a bound `id<P>` qualifier can never fail to find its `SPEC_<P>`.
        assert!(dir.join("delegates.ts").exists(), "delegates.ts written");
        assert!(
            dir.join("delegates.d.ts").exists(),
            "delegates.d.ts written"
        );
        let specs = std::fs::read_to_string(dir.join("delegates.ts")).unwrap();
        assert!(
            specs.contains("export const SPEC_TKRefreshing: DelegateSpec = {"),
            "{specs}"
        );
        let protocols = std::fs::read_to_string(dir.join("protocols.ts")).unwrap();
        assert!(
            protocols.contains("export interface TKRefreshing {"),
            "{protocols}"
        );
        assert!(
            protocols.contains("export interface TKDelegate {"),
            "{protocols}"
        );

        let barrel = std::fs::read_to_string(dir.join("index.ts")).unwrap();
        let class_pos = barrel
            .find("export * from './tkobject';")
            .expect("class re-export");
        let proto_pos = barrel
            .find("export * from './protocols';")
            .expect("protocols re-export");
        let spec_pos = barrel
            .find("export * from './delegates';")
            .expect("delegate-spec re-export");
        assert!(
            class_pos < proto_pos,
            "protocols re-exported after the classes:\n{barrel}"
        );
        // The specs lead. They import nothing but the runtime, so they have no edge back into a class
        // module and cannot be part of a cycle — putting them first says so.
        assert!(
            spec_pos < class_pos,
            "delegate specs re-exported before the classes:\n{barrel}"
        );
    }

    #[test]
    fn a_class_and_a_protocol_sharing_a_name_never_export_the_same_barrel_symbol() {
        // THE NEGATIVE CONTROL (`protocol-class-name-collapse-k90`). ObjC has two namespaces —
        // a class `Foo` and a protocol `Foo` can coexist — TypeScript has one, and the framework
        // barrel `export * from`s both `./foo` and `./protocols`. Left alone, both would export a
        // top-level `Foo`, and `export * from` of two modules sharing a name is ambiguous (TS2308).
        // Nothing here runs `tsc` (that is `corpus-typecheck-gate-k75`'s job) — the checkable proxy
        // at this layer is that the two modules' own top-level identifiers provably differ.
        let mut fw = framework("TestKit", vec![class("Foo", "NSObject", vec![])]);
        fw.protocols = vec![protocol("Foo", vec![void_method("go")])];
        let (tmp, res) = emit(&fw, &ClassRegistry::new());
        assert_eq!(res.protocols_emitted, 1);

        let dir = tmp.path().join("testkit");
        let class_ts = std::fs::read_to_string(dir.join("foo.ts")).unwrap();
        assert!(
            class_ts.contains("export class Foo extends NSObject {"),
            "the class keeps its own name:\n{class_ts}"
        );

        let protocols_ts = std::fs::read_to_string(dir.join("protocols.ts")).unwrap();
        assert!(
            protocols_ts.contains("export interface FooProtocol {"),
            "the colliding protocol re-encodes with the Protocol suffix:\n{protocols_ts}"
        );
        assert!(
            !protocols_ts.contains("export interface Foo {"),
            "the protocol must NEVER declare under the bare name the class file already exports:\n{protocols_ts}"
        );
    }

    #[test]
    fn empty_protocols_write_no_protocol_files_or_barrel_entry() {
        // A framework with no emittable protocols writes neither file and no barrel entry.
        let mut fw = framework("TestKit", vec![class("TKObject", "NSObject", vec![])]);
        // A pure marker protocol has no bindable surface → skipped.
        fw.protocols = vec![protocol("TKMarker", vec![])];
        let (tmp, res) = emit(&fw, &ClassRegistry::new());
        assert_eq!(res.protocols_emitted, 0);
        let dir = tmp.path().join("testkit");
        assert!(
            !dir.join("protocols.ts").exists(),
            "no protocols.ts for a marker-only fw"
        );
        let barrel = std::fs::read_to_string(dir.join("index.ts")).unwrap();
        assert!(
            !barrel.contains("./protocols"),
            "no barrel entry:\n{barrel}"
        );
    }

    #[test]
    fn fallible_framework_barrel_reexports_the_error_surface() {
        // A framework whose class emits a fallible `…error:` method (flagged by the
        // enrichment relation) re-exports the runtime error surface from its barrel
        // (ADR-0058), so `Result` / `unwrap` / the `ObjCError` hierarchy are consumable by
        // name from the framework package. A framework with no fallible method does not.
        use apianyware_types::enrichment::{ClassSelectorEntry, EnrichmentData};

        let fallible = Method {
            selector: "writeToFile:error:".into(),
            class_method: false,
            init_method: false,
            params: vec![
                Param {
                    name: "path".into(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Id {
                            protocols: Vec::new(),
                        },
                    },
                },
                Param {
                    name: "error".into(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Pointer,
                    },
                },
            ],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "bool".into(),
                },
            },
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        };
        let mut fw = framework(
            "Foundation",
            vec![class("NSData", "NSObject", vec![fallible])],
        );
        fw.enrichment = Some(EnrichmentData {
            convenience_error_methods: vec![ClassSelectorEntry {
                class: "NSData".into(),
                selector: "writeToFile:error:".into(),
            }],
            ..Default::default()
        });
        let (tmp, _) = emit(&fw, &ClassRegistry::new());
        let barrel = std::fs::read_to_string(tmp.path().join("foundation/index.ts")).unwrap();
        assert!(
            barrel.contains("export type { Result } from '@apianyware/runtime';"),
            "Result re-exported type-only:\n{barrel}"
        );
        assert!(
            barrel.contains(
                "export { NSErrorError, NSExceptionError, ObjCError, unwrap } from '@apianyware/runtime';"
            ),
            "the value error hierarchy re-exported:\n{barrel}"
        );
        // The class itself emits the Result method.
        let nsdata = std::fs::read_to_string(tmp.path().join("foundation/nsdata.ts")).unwrap();
        assert!(
            nsdata.contains("writeToFile_error_(path: NSObject): Result<boolean> {"),
            "the fallible method emits Result<boolean>:\n{nsdata}"
        );

        // A framework with the same class but NO enrichment emits neither the Result method
        // nor the barrel re-export (the method defers as a raw pointer).
        let plain = framework(
            "Foundation",
            vec![class(
                "NSData",
                "NSObject",
                vec![object_return_method("data", "NSData")],
            )],
        );
        let (tmp2, _) = emit(&plain, &ClassRegistry::new());
        let barrel2 = std::fs::read_to_string(tmp2.path().join("foundation/index.ts")).unwrap();
        assert!(
            !barrel2.contains("@apianyware/runtime"),
            "no error re-export without fallible methods:\n{barrel2}"
        );
    }

    #[test]
    fn cross_framework_reference_routes_through_the_registry() {
        // Emitting AppKit with a populated registry: a class returning a Foundation-owned
        // NSString imports it from @apianyware/foundation, not the local package.
        let fw = framework(
            "AppKit",
            vec![class(
                "NSView",
                "NSObject",
                vec![object_return_method("stringValue", "NSString")],
            )],
        );
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let (tmp, _) = emit(&fw, &reg);
        let view = std::fs::read_to_string(tmp.path().join("appkit/nsview.ts")).unwrap();
        assert!(
            view.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "cross-framework return imports from the owning module:\n{view}"
        );
        // And its .d.ts groups the same way.
        let dts = std::fs::read_to_string(tmp.path().join("appkit/nsview.d.ts")).unwrap();
        assert!(
            dts.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "the .d.ts routes cross-framework identically:\n{dts}"
        );
    }
}
