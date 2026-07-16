//! Constant emission — each `Constant` → an exported module member (ADR-0055 §6).
//!
//! A constant's *value* is almost never in the IR: the `Constant` struct carries only its
//! `name`, `constant_type`, and — for `CFSTR`-style macros — the embedded string
//! (`macro_value`). Everything else is a **link-time fact** (ADR-0025): a runtime address
//! cannot be a TS literal. So constants split four ways, and only the first is a literal:
//!
//! 1. **CFSTR macro** (`macro_value` present) — a compile-time `NSString` the C macro
//!    expands to, with **no exported symbol**. Built + retained (+1) at module load from the
//!    literal string and wrapped owned:
//!    `export const NAME: NSString = __wrapOwned(NSString, __cfstr('…'))!;` (the sbcl
//!    `aw-make-nsstring` analogue in TS idiom — a `dlsym` would dangle, there is no symbol).
//! 2. **Pointer-valued object global** (`NSString * const NSFontAttributeName`, type
//!    `Class`/`Id`/`Instancetype`) — the framework owns the global for the process lifetime,
//!    so its pointer value is read through the addon and wrapped **borrowed** (+0):
//!    `export const NAME: NSString = __wrapRetained(NSString, __dispatch.aw_ts_const_P('NAME'))!;`
//!    (the sbcl "wrap borrowed" flavour — [`crate::native_dispatch::constant_entry_name`]).
//! 3. **Array-typed global** (`Constant::array_element` present — `extern const unsigned char
//!    X[]`) — the symbol's own address IS the array, not a stored pointer to load through
//!    (`array-constant-symbol-value-k109`). A **byte/char element** (the measured *VersionString
//!    banner-string population) reads as a `string`, straight off the symbol's own address, no
//!    load-through: `export const NAME: string = __dispatch.aw_ts_const_N_a('NAME');`. Any other
//!    element (a `CGFloat[6]` geometry matrix, say) has no first-pass surface — a fixed-size
//!    numeric array needs runtime marshalling this leaf does not build — and defers, same as
//!    arm 4 below.
//! 4. **Scalar / enum / C-string / opaque-pointer global** (`extern const double`, an
//!    enum-typed global, `extern const void * const`) — the value is a runtime-read C global
//!    too (no IR literal), read through the addon by its result ABI shape:
//!    `export const NAME: number = __dispatch.aw_ts_const_d('NAME');`. A proven enum casts the
//!    read (`… as TKAlignment`), since a numeric enum is not structurally `number` (the
//!    [`crate::emit_class`] return-cast rule). A **pointer-shaped but non-object** global (a
//!    raw C pointer, a block singleton — never `Class`/`Id`/`Instancetype`) reads as an opaque
//!    `bigint` through the **non-retaining** `aw_ts_const_P_n` entry, distinct from arm 2's
//!    object-retaining `aw_ts_const_P` (`pointer-constant-ownership-k92`; ADR-0057 §4's
//!    wrap-boundary rule — the fold gates on `is_object_type`, never on the ABI shape alone —
//!    applied to constants). Retaining a non-object dereferences a nonexistent `isa`: measured
//!    crash, `CoreSpotlightVersionString` — arm 3 above is exactly that global, now honest.
//!
//! Everything else defers: a **Swift-native** (`objc_exposed == false`) non-macro constant has
//! no C symbol (its symbol is a Swift-ABI one — a trampoline, Step 4, the sbcl
//! `collect_const_residual` analogue); a **struct / non-routable** constant has no first-pass
//! surface; a non-byte-element **array-typed** global has no first-pass surface either (arm 3).
//! Deferred constants are simply not emitted (not counted) — the honest no-silent-narrowing
//! posture the method filter keeps.
//!
//! ## The runtime seam this module *defines* (Step 3 / the addon provide it)
//!
//! Pure codegen (ADR-0011): the emitted `.ts` references primitives the runtime library
//! (Step 3) and the addon (Step 4) will provide, imported from `@apianyware/runtime`. Beside
//! the object-wrap seam [`crate::emit_class`] fixes (`__wrapRetained`/`__wrapOwned`/`NSObject`):
//!
//! - `__cfstr(s)` → a +1 retained `NSString` handle built from a JS string (the CFSTR
//!   constructor; `id` handle wrapped owned);
//! - `__dispatch.aw_ts_const_<code>(name)` → the addon's per-shape constant-read entry: an
//!   object-pointer global's raw handle (`P`, wrapped borrowed), an opaque-pointer global's raw
//!   handle (`P_n`, never wrapped, never retained — `pointer-constant-ownership-k92`), a
//!   byte/char array global's banner string read off its own address (`N_a`, no load-through —
//!   `array-constant-symbol-value-k109`), or a scalar/C-string global's JS primitive.
//!
//! ## `.ts` / `.d.ts` co-generation (ADR-0055 §2)
//!
//! Both artifacts derive from one [`classify`] pass, so the declared type of every constant
//! is identical; the `.ts` appends the module-load initializer, the `.d.ts` a bare `;`
//! (`export const NAME: T;`, ambient — no `declare`, the enum/protocol house style). Class
//! types import as **values** in both (the `.ts` passes the class to a wrap primitive; both
//! reference it), enum types **type-only**; the `.ts` additionally merges its seam helpers
//! into the runtime block — the same asymmetry [`crate::emit_class`] / [`crate::emit_dts`] keep.

use std::collections::BTreeSet;

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::Constant;
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_binding::{deferred_class, surface_class_name};
use crate::class_graph::{ClassModuleResolver, RUNTIME_MODULE};
use crate::class_surface::object_class_name;
use crate::emit_class::wrap_call;
use crate::enum_graph::EnumModuleResolver;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::imports::{
    class_type_imports, enum_type_imports, merge_type_imports, protocol_type_imports,
    render_import_blocks, render_type_import_blocks,
};
use crate::naming::{is_valid_ts_identifier, module_specifier};
use crate::native_dispatch::{constant_entry_name, ARRAY_STRING_CONST_ENTRY};
use crate::protocol_binding::{id_surface_type, referenced_protocol_types};
use crate::protocol_graph::ProtocolModuleResolver;

/// Render a framework's constants as the **`constants.ts`** module — the banner, the import
/// preamble (class-type value imports + the merged runtime-seam block; enum type-only
/// imports), and one `export const NAME: T = <module-load initializer>;` per emittable
/// constant ([`classify`]). Class types route through the `resolver`; enum types + the
/// enum-aware mapper come from the `enum_resolver` (ADR-0055 §6).
pub fn render_constants_module(
    constants: &[Constant],
    framework: &str,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> String {
    // All three recognition sets (`emit_class`): an enum alias upgrades off `number`; an unbound
    // `Class{…}` degrades to the root, and a `.swiftinterface` nominal type defers the constant
    // (`class_binding`, k66); a bound `id<P>` qualifier types the global by its interface
    // (`protocol_binding`, k89 — the corpus population is zero today; the arm is here so a
    // constant's declared type is the same string every other emitter would render for it).
    let mapper = TsFfiTypeMapper::with_known(
        enum_resolver.known_enums(),
        resolver.known_classes(),
        protocol_resolver.known_protocols(),
    );
    let items = classify(constants, &mapper);

    let mut w = CodeWriter::new();
    emit_banner(&mut w, framework, true);
    emit_imports(
        &mut w,
        &items,
        resolver,
        enum_resolver,
        protocol_resolver,
        &mapper,
        true,
    );
    for item in &items {
        write_line!(
            w,
            "export const {}: {} = {};",
            item.name,
            item.ts_type,
            item.init()
        );
    }
    w.finish()
}

/// Render the co-generated **`constants.d.ts`** — the declaration-only surface: the same
/// banner + imports (minus the `.ts`-only seam block) and `export const NAME: T;` per
/// constant, from the same [`classify`] pass so the declared types cannot drift from
/// `constants.ts`.
pub fn render_constants_dts(
    constants: &[Constant],
    framework: &str,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> String {
    // The identical three-set mapper `render_constants_module` builds (ADR-0055 §2).
    let mapper = TsFfiTypeMapper::with_known(
        enum_resolver.known_enums(),
        resolver.known_classes(),
        protocol_resolver.known_protocols(),
    );
    let items = classify(constants, &mapper);

    let mut w = CodeWriter::new();
    emit_banner(&mut w, framework, false);
    emit_imports(
        &mut w,
        &items,
        resolver,
        enum_resolver,
        protocol_resolver,
        &mapper,
        false,
    );
    for item in &items {
        write_line!(w, "export const {}: {};", item.name, item.ts_type);
    }
    w.finish()
}

/// The number of constants this framework actually emits — those [`classify`] admits (a
/// valid TS-identifier name whose shape has a first-pass surface). Drives the orchestrator's
/// write decision, its `EmitResult::constants_emitted` count, and the barrel re-export, so
/// all three agree with the two render functions.
pub fn emitted_constant_count(constants: &[Constant], mapper: &TsFfiTypeMapper) -> usize {
    classify(constants, mapper).len()
}

// --- classification --------------------------------------------------------------------

/// One emittable constant, projected once so `constants.ts` and `constants.d.ts` share its
/// declared type (ADR-0055 §2).
struct ConstItem {
    /// The TS `const` name — the ObjC constant name verbatim (a C identifier).
    name: String,
    /// The declared TS type (`mapper.map_type`), identical in both artifacts.
    ts_type: String,
    /// The class type the **declared type** names, if any — its value import in both artifacts.
    ///
    /// Read off the declared type ([`object_class_name`]), **not** off the wrap class: since k88 the
    /// two differ, because a bare or qualified `id` takes the class-less wrap arm (no class named at
    /// the call) while its *type* still spells `NSObject`. Collecting the import from the wrap would
    /// leave `export const K: NSObject | null = __wrapRetained(…)` naming a symbol it never imported
    /// — import honesty (k66) says the import set follows the **rendered token**, always.
    class_ref: Option<String>,
    /// The protocol interfaces the declared type names through a bound `id<P>` qualifier — an
    /// `import type` in both artifacts (`protocol_binding`, ADR-0055 §4b).
    protocol_refs: BTreeSet<String>,
    /// How the `.ts` initializes it (the `.d.ts` carries none).
    init: ConstInit,
}

/// How a constant's value is produced at module load — the three-way split (module doc).
enum ConstInit {
    /// CFSTR macro: build a +1 `NSString` from the literal, wrap owned.
    Cfstr {
        /// The declared class, or `None` for the class-less (dynamically resolved) wrap arm.
        wrap_class: Option<String>,
        /// The bound-protocol type argument the class-less arm carries — what makes the wrap
        /// satisfy a declared `P & NSObject` ([`crate::emit_class::wrap_call`]).
        type_arg: Option<String>,
        value: String,
        bang: &'static str,
    },
    /// Pointer-valued object global: read the pointer through the addon, wrap borrowed (+0).
    ObjectGlobal {
        /// The declared class, or `None` for the class-less (dynamically resolved) wrap arm.
        wrap_class: Option<String>,
        /// The bound-protocol type argument the class-less arm carries — what makes the wrap
        /// satisfy a declared `P & NSObject` ([`crate::emit_class::wrap_call`]).
        type_arg: Option<String>,
        entry: String,
        bang: &'static str,
    },
    /// Scalar / enum / C-string / opaque-pointer global: read the value through the addon; a
    /// proven enum casts the numeric read to the enum type. An opaque-pointer global (`entry`
    /// the non-retaining `aw_ts_const_P_n`) carries no cast — it reads as a bare `bigint`.
    Scalar { entry: String, cast: Option<String> },
}

impl ConstItem {
    /// The `.ts` initializer expression (the right of `= `).
    fn init(&self) -> String {
        match &self.init {
            ConstInit::Cfstr {
                wrap_class,
                type_arg,
                value,
                bang,
            } => format!(
                "{}{bang}",
                wrap_call(
                    "__wrapOwned",
                    wrap_class.clone(),
                    type_arg.clone(),
                    &format!("__cfstr('{}')", escape(value))
                )
            ),
            ConstInit::ObjectGlobal {
                wrap_class,
                type_arg,
                entry,
                bang,
            } => format!(
                "{}{bang}",
                wrap_call(
                    "__wrapRetained",
                    wrap_class.clone(),
                    type_arg.clone(),
                    &format!("__dispatch.{entry}('{}')", self.name)
                )
            ),
            ConstInit::Scalar { entry, cast } => {
                let read = format!("__dispatch.{entry}('{}')", self.name);
                match cast {
                    Some(enum_name) => format!("{read} as {enum_name}"),
                    None => read,
                }
            }
        }
    }
}

/// Project a framework's constants to the emittable [`ConstItem`]s, skipping the deferrals
/// (module doc). A single pass both render functions consume, so their declared types agree.
fn classify(constants: &[Constant], mapper: &TsFfiTypeMapper) -> Vec<ConstItem> {
    constants
        .iter()
        .filter(|c| is_valid_ts_identifier(&c.name))
        .filter_map(|c| classify_one(c, mapper))
        .collect()
}

/// Classify one constant, or `None` if it defers. The `.ts` type annotation and the wrap
/// bang both ride the constant's declared nullability (a non-null global asserts the wrap
/// with `!`; a nullable one keeps `T | null`), exactly as [`crate::emit_class`] does for an
/// object return.
fn classify_one(c: &Constant, mapper: &TsFfiTypeMapper) -> Option<ConstItem> {
    // A `.swiftinterface`-sourced global typed by a Swift nominal type (`Class{Tuple}`) is not an
    // object: it can be neither wrapped nor imported, so it defers whole — the constant dual of
    // the method frontier's gate (`class_binding`, k66).
    deferred_class(c.source, std::iter::once(&c.constant_type), mapper)
        .is_none()
        .then_some(())?;
    let ts_type = mapper.map_type(&c.constant_type, true);
    let bang = if c.constant_type.nullable { "" } else { "!" };

    // A CFSTR macro has a compile-time value and no symbol — emit it regardless of
    // `objc_exposed` (nothing is read from the ABI).
    if let Some(value) = &c.macro_value {
        return Some(ConstItem {
            name: c.name.clone(),
            ts_type,
            class_ref: object_class_name(&c.constant_type, mapper, true),
            protocol_refs: referenced_protocol_types(std::iter::once(&c.constant_type), mapper),
            init: ConstInit::Cfstr {
                wrap_class: wrap_class(&c.constant_type.kind, mapper),
                type_arg: id_surface_type(&c.constant_type, mapper, true),
                value: value.clone(),
                bang,
            },
        });
    }

    // Every non-macro read crosses the C ABI by symbol, so a Swift-native global defers to
    // the Step-4 trampoline (the sbcl residual analogue).
    if !c.objc_exposed {
        return None;
    }

    // An array-typed global (`Constant::array_element` present) never reaches the general match
    // below honestly: `constant_type` still reads `Pointer` (the ABI-correct shape), but the
    // symbol's own address IS the array — not a stored pointer the general match's `P`/`P_n` split
    // would be reading THROUGH (`array-constant-symbol-value-k109`, module doc arm 3).
    if let Some(element) = &c.array_element {
        return classify_array_element(c, element);
    }

    match &c.constant_type.kind {
        // Pointer-valued object global: read the pointer, wrap borrowed.
        TypeRefKind::Class { .. } | TypeRefKind::Id { .. } | TypeRefKind::Instancetype => {
            Some(ConstItem {
                name: c.name.clone(),
                ts_type,
                class_ref: object_class_name(&c.constant_type, mapper, true),
                protocol_refs: referenced_protocol_types(std::iter::once(&c.constant_type), mapper),
                init: ConstInit::ObjectGlobal {
                    wrap_class: wrap_class(&c.constant_type.kind, mapper),
                    type_arg: id_surface_type(&c.constant_type, mapper, true),
                    // `is_object = true`: this arm matched Class/Id/Instancetype, exactly
                    // `is_object_type`'s definition — the addon's `P` entry folds a `+1`.
                    entry: constant_entry_name(&c.constant_type, true)?,
                    bang,
                },
            })
        }
        // A by-value struct global (its address is the handle — the sbcl `foreign-symbol-sap`
        // flavour) has no first-pass surface; defer.
        _ if mapper.is_struct_type(&c.constant_type) => None,
        // Scalar / enum / C-string / opaque-pointer global: read the value by its ABI shape,
        // forked on the wrap-boundary ownership predicate — never `false` hardcoded, so this
        // arm cannot silently misclassify if `is_object_type` ever recognizes a fourth kind
        // (`pointer-constant-ownership-k92`). `None` (a `void` / non-routable alias) defers.
        _ => Some(ConstItem {
            name: c.name.clone(),
            ts_type,
            class_ref: None,
            protocol_refs: BTreeSet::new(),
            init: ConstInit::Scalar {
                entry: constant_entry_name(
                    &c.constant_type,
                    mapper.is_object_type(&c.constant_type),
                )?,
                cast: mapper.known_enum_name(&c.constant_type).map(str::to_string),
            },
        }),
    }
}

/// Classify an array-typed global (`Constant::array_element`, module doc arm 3), or `None` if it
/// defers. The only population this leaf gives a first-pass surface is a **byte/char element**
/// (`unsigned char[]`/`char[]` — the measured *VersionString banner-string shape): read as a
/// NUL-terminated string straight off the symbol's own address, through the non-load-through
/// [`ARRAY_STRING_CONST_ENTRY`] — distinct from `aw_ts_const_N` (a *stored* `char * const` global,
/// which loads THROUGH its address). Every other element (a `CGFloat[6]` geometry matrix, say) has
/// no first-pass surface: a fixed-size numeric array needs runtime marshalling this leaf does not
/// build, so it defers, same as any other non-routable shape (module doc).
fn classify_array_element(c: &Constant, element: &TypeRef) -> Option<ConstItem> {
    let is_byte_element = matches!(
        &element.kind,
        TypeRefKind::Primitive { name } if name == "int8" || name == "uint8"
    );
    if !is_byte_element {
        return None;
    }
    Some(ConstItem {
        name: c.name.clone(),
        ts_type: "string".to_string(),
        class_ref: None,
        protocol_refs: BTreeSet::new(),
        init: ConstInit::Scalar {
            entry: ARRAY_STRING_CONST_ENTRY.to_string(),
            cast: None,
        },
    })
}

/// The concrete TS class a wrap primitive instantiates for an object constant — `Class{name}` → that
/// class (or the degraded root), and **`None` when the IR names no class**: a bare or
/// protocol-qualified `id`, which takes the wrap primitive's class-less arm and resolves the
/// object's real ObjC class at run time (`dynamic-class-wrap-k88`, [`crate::emit_class::wrap_call`]).
/// `instancetype` cannot occur on a global; it keeps the root.
fn wrap_class(kind: &TypeRefKind, mapper: &TsFfiTypeMapper) -> Option<String> {
    match kind {
        TypeRefKind::Class { name, .. } => Some(surface_class_name(name, mapper)),
        TypeRefKind::Id { .. } => None,
        _ => Some("NSObject".to_string()),
    }
}

// --- header + imports ------------------------------------------------------------------

/// The generated-file banner — a `.ts` vs `.d.ts` variant (only the second banner line and
/// the co-generation note differ).
fn emit_banner(w: &mut CodeWriter, framework: &str, is_ts: bool) {
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    if is_ts {
        write_line!(
            w,
            "// Constants: {framework} (module {})",
            module_specifier(framework)
        );
        w.line("//");
        w.line(
            "// Each constant is a module-load-initialized exported `const` (ADR-0055 §6): a CFSTR",
        );
        w.line(
            "// macro built from its literal, a pointer-valued global read + wrapped borrowed, a",
        );
        w.line("// scalar/enum global read — a runtime address is not a TS literal (ADR-0025).");
    } else {
        write_line!(w, "// Type surface: constants ({framework})");
        w.line("//");
        w.line("// Declaration-only .d.ts, co-generated with constants.ts from the same IR pass");
        w.line("// (ADR-0055 §2): the declared `const` types, no module-load initializers.");
    }
    w.blank_line();
}

/// The per-module import blocks — class-type value imports (routed through the `resolver`),
/// with the `.ts`-only runtime-seam symbols merged into the `@apianyware/runtime` block, then
/// the type-only enum imports (routed through the `enum_resolver`). Identical grouping to
/// [`crate::emit_class`] / [`crate::emit_dts`], so the two artifacts cannot drift.
fn emit_imports(
    w: &mut CodeWriter,
    items: &[ConstItem],
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    mapper: &TsFfiTypeMapper,
    include_seam: bool,
) {
    let mut class_refs: BTreeSet<String> = BTreeSet::new();
    let mut enum_refs: BTreeSet<String> = BTreeSet::new();
    let mut protocol_refs: BTreeSet<String> = BTreeSet::new();
    for item in items {
        protocol_refs.extend(item.protocol_refs.iter().cloned());
        // The declared type's class (what the annotation spells) AND the wrap primitive's class
        // (what the initializer names) — a union, because since k88 they differ: a bare `id` global
        // declares `NSObject` but wraps class-lessly. Both are value references; both must import.
        class_refs.extend(item.class_ref.clone());
        match &item.init {
            ConstInit::Cfstr { wrap_class, .. } | ConstInit::ObjectGlobal { wrap_class, .. } => {
                class_refs.extend(wrap_class.clone());
            }
            ConstInit::Scalar { cast, .. } => {
                if let Some(enum_name) = cast {
                    enum_refs.insert(enum_name.clone());
                }
            }
        }
    }

    let mut map = class_type_imports(&class_refs, resolver);
    if include_seam {
        let seam = seam_symbols(items);
        if !seam.is_empty() {
            map.entry(RUNTIME_MODULE.to_string())
                .or_default()
                .extend(seam);
        }
    }
    // Enum + protocol interfaces coalesce into one type-only section per module (the
    // `emit_class`/`emit_dts` grouping): both are erased at compile, so neither forms a runtime edge.
    let type_map = merge_type_imports(
        enum_type_imports(&enum_refs, enum_resolver),
        protocol_type_imports(&protocol_refs, protocol_resolver, mapper),
    );

    render_import_blocks(&map, w);
    render_type_import_blocks(&type_map, w);
    if !map.is_empty() || !type_map.is_empty() {
        w.blank_line();
    }
}

/// The runtime-seam symbols the emitted `.ts` initializers call — a `.ts`-only concern the
/// `.d.ts` never has: `__cfstr` + `__wrapOwned` per CFSTR macro, `__dispatch` +
/// `__wrapRetained` per pointer-valued object global, `__dispatch` per scalar read.
fn seam_symbols(items: &[ConstItem]) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    for item in items {
        match &item.init {
            ConstInit::Cfstr { .. } => {
                set.insert("__cfstr".to_string());
                set.insert("__wrapOwned".to_string());
            }
            ConstInit::ObjectGlobal { .. } => {
                set.insert("__dispatch".to_string());
                set.insert("__wrapRetained".to_string());
            }
            ConstInit::Scalar { .. } => {
                set.insert("__dispatch".to_string());
            }
        }
    }
    set
}

/// Escape a single-quoted TS string literal — backslash and single-quote, the only realistic
/// concerns for post-preprocessor CFSTR values (mirrors the sbcl `escape_string_literal`).
fn escape(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for ch in s.chars() {
        match ch {
            '\\' => out.push_str("\\\\"),
            '\'' => out.push_str("\\'"),
            other => out.push(other),
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::class_graph::ClassRegistry;
    use crate::enum_graph::EnumRegistry;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::type_ref::TypeRef;
    use std::sync::Arc;

    fn constant(name: &str, kind: TypeRefKind, nullable: bool) -> Constant {
        Constant {
            name: name.into(),
            constant_type: TypeRef { nullable, kind },
            array_element: None,
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: true,
        }
    }

    /// An array-typed global (`array-constant-symbol-value-k109`) — `constant_type` stays
    /// `Pointer` (the extractor's shape, module doc arm 3) while `array_element` names the
    /// array's element type, exactly what `extract_constant` populates.
    fn array_constant(name: &str, element: TypeRefKind) -> Constant {
        Constant {
            name: name.into(),
            constant_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Pointer,
            },
            array_element: Some(TypeRef {
                nullable: false,
                kind: element,
            }),
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: true,
        }
    }

    fn cfstr(name: &str, value: &str) -> Constant {
        Constant {
            name: name.into(),
            constant_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
            },
            array_element: None,
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: Some(value.into()),
            objc_exposed: true,
        }
    }

    /// A registry that owns `NSString` — the class every object-constant fixture names, and the
    /// class a real Foundation emit would have in its whole-program set. A `Class{name}` outside
    /// the set is not a class the emitter emits, so k66 degrades it to `NSObject`.
    fn foundation() -> ClassRegistry {
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        reg
    }

    /// A mapper over `registry`'s declared classes — the count's half of the orchestrator's
    /// shape (`emitted_constant_count` must be computed with the same knowledge the render pass
    /// uses, or the barrel would re-export a module the renderer wrote nothing into).
    fn count(constants: &[Constant], registry: &ClassRegistry) -> usize {
        emitted_constant_count(
            constants,
            &TsFfiTypeMapper::with_known_classes(Arc::new(registry.names())),
        )
    }

    /// Render both artifacts for a framework `fw`, with a class registry routing cross-
    /// framework classes and an enum recognition set — the orchestrator's per-framework shape.
    fn render(
        constants: &[Constant],
        fw: &str,
        registry: &ClassRegistry,
        known_enums: &[&str],
    ) -> (String, String) {
        let resolver = ClassModuleResolver::new(fw, registry, Arc::new(registry.names()));
        let enum_reg = EnumRegistry::new();
        let known: Arc<BTreeSet<String>> =
            Arc::new(known_enums.iter().map(|s| s.to_string()).collect());
        let enum_resolver = EnumModuleResolver::new(fw, &enum_reg, known);
        let proto_reg = ProtocolRegistry::new();
        let protocol_resolver =
            ProtocolModuleResolver::new(fw, &proto_reg, Arc::new(BTreeSet::new()));
        (
            render_constants_module(constants, fw, &resolver, &enum_resolver, &protocol_resolver),
            render_constants_dts(constants, fw, &resolver, &enum_resolver, &protocol_resolver),
        )
    }

    #[test]
    fn pointer_valued_object_global_reads_and_wraps_borrowed() {
        // NSString * const NSFontAttributeName — owned by Foundation via the registry: read
        // the pointer through the addon's `P` entry, wrap borrowed (+0), non-null `!`.
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let consts = vec![constant(
            "NSFontAttributeName",
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
            false,
        )];
        let (ts, dts) = render(&consts, "AppKit", &reg, &[]);
        assert!(
            ts.contains("export const NSFontAttributeName: NSString = __wrapRetained(NSString, __dispatch.aw_ts_const_P('NSFontAttributeName'))!;"),
            "{ts}"
        );
        // Value import of the class from its owning module + the seam block.
        assert!(
            ts.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "{ts}"
        );
        assert!(ts.contains("  __dispatch,\n"), "{ts}");
        assert!(ts.contains("  __wrapRetained,\n"), "{ts}");
        // The .d.ts declares the type, no initializer, no seam.
        assert!(
            dts.contains("export const NSFontAttributeName: NSString;"),
            "{dts}"
        );
        assert!(!dts.contains("__wrapRetained"), "{dts}");
        assert!(!dts.contains("__dispatch"), "{dts}");
        assert!(
            dts.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "{dts}"
        );
    }

    #[test]
    fn nullable_object_global_keeps_union_and_drops_bang() {
        let consts = vec![constant(
            "NSSomeOptionalKey",
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
            true,
        )];
        let (ts, dts) = render(&consts, "Foundation", &foundation(), &[]);
        // The IR names no class for an `id` global, so the initializer takes the wrap primitive's
        // **class-less arm** and the runtime resolves the object's real ObjC class
        // (`dynamic-class-wrap-k88`, extended here to constants). It used to pass `NSObject` —
        // minting a root object with none of the real class's methods.
        assert!(
            ts.contains("export const NSSomeOptionalKey: NSObject | null = __wrapRetained(__dispatch.aw_ts_const_P('NSSomeOptionalKey'));"),
            "{ts}"
        );
        // IMPORT HONESTY. The wrap no longer names a class, but the *declared type* still spells
        // `NSObject` — so the value import must still be there. The import set follows the rendered
        // token, never the wrap; collecting it from the wrap is how this artifact would come to name
        // a symbol it never imported.
        assert!(
            ts.contains("import {\n  NSObject,\n  __dispatch,\n  __wrapRetained,\n} from '@apianyware/runtime';"),
            "{ts}"
        );
        assert!(
            dts.contains("export const NSSomeOptionalKey: NSObject | null;"),
            "{dts}"
        );
    }

    #[test]
    fn cfstr_macro_builds_retained_nsstring_from_the_literal() {
        // No symbol exists — build a +1 NSString from the string and wrap owned.
        let consts = vec![cfstr("kAXWindowsAttribute", "AXWindows")];
        let (ts, _) = render(&consts, "ApplicationServices", &foundation(), &[]);
        assert!(
            ts.contains("export const kAXWindowsAttribute: NSString = __wrapOwned(NSString, __cfstr('AXWindows'))!;"),
            "{ts}"
        );
        assert!(ts.contains("  __cfstr,\n"), "{ts}");
        assert!(ts.contains("  __wrapOwned,\n"), "{ts}");
        // No addon symbol read for a CFSTR macro.
        assert!(!ts.contains("aw_ts_const"), "{ts}");
    }

    #[test]
    fn cfstr_escapes_quotes_and_backslashes() {
        let consts = vec![cfstr("kFoo", "a'b\\c")];
        let (ts, _) = render(&consts, "TestKit", &foundation(), &[]);
        assert!(ts.contains("__cfstr('a\\'b\\\\c')"), "{ts}");
    }

    #[test]
    fn scalar_global_reads_by_its_abi_shape() {
        let consts = vec![constant(
            "NSTimeIntervalSince1970",
            TypeRefKind::Primitive {
                name: "double".into(),
            },
            false,
        )];
        let (ts, dts) = render(&consts, "Foundation", &foundation(), &[]);
        assert!(
            ts.contains("export const NSTimeIntervalSince1970: number = __dispatch.aw_ts_const_d('NSTimeIntervalSince1970');"),
            "{ts}"
        );
        // A scalar read needs only __dispatch (no wrap, no class import).
        assert!(
            ts.contains("import {\n  __dispatch,\n} from '@apianyware/runtime';"),
            "{ts}"
        );
        assert!(!ts.contains("__wrap"), "{ts}");
        assert!(
            dts.contains("export const NSTimeIntervalSince1970: number;"),
            "{dts}"
        );
        // The .d.ts has no runtime import at all (the scalar type carries no reference).
        assert!(!dts.contains("@apianyware/runtime"), "{dts}");
    }

    #[test]
    fn opaque_pointer_global_reads_through_the_non_retaining_entry() {
        // A raw C pointer global (never Class/Id/Instancetype) is pointer-shaped at the ABI but
        // is NOT an object — routes to the non-retaining `aw_ts_const_P_n` sibling, distinct
        // from the object-retaining `aw_ts_const_P` (`pointer-constant-ownership-k92`). Reads
        // as a bare `bigint`, no wrap call, exactly like a scalar.
        let consts = vec![constant("glutBitmap9By15", TypeRefKind::Pointer, false)];
        let (ts, dts) = render(&consts, "GLUT", &ClassRegistry::new(), &[]);
        assert!(
            ts.contains("export const glutBitmap9By15: bigint = __dispatch.aw_ts_const_P_n('glutBitmap9By15');"),
            "{ts}"
        );
        assert!(!ts.contains("__wrap"), "{ts}");
        assert!(
            ts.contains("import {\n  __dispatch,\n} from '@apianyware/runtime';"),
            "{ts}"
        );
        assert!(
            dts.contains("export const glutBitmap9By15: bigint;"),
            "{dts}"
        );
        assert!(!dts.contains("@apianyware/runtime"), "{dts}");
    }

    #[test]
    fn byte_array_global_reads_as_a_string_off_its_own_address() {
        // `extern const unsigned char CoreSpotlightVersionString[]` — a byte-element array-typed
        // global: the symbol's own address IS the array (`array-constant-symbol-value-k109`), so
        // this reads through the non-load-through `aw_ts_const_N_a`, distinct from `aw_ts_const_N`
        // (a *stored* char* global). No wrap, no cast, no bang — a plain `string`.
        let consts = vec![array_constant(
            "CoreSpotlightVersionString",
            TypeRefKind::Primitive {
                name: "uint8".into(),
            },
        )];
        let (ts, dts) = render(&consts, "CoreSpotlight", &ClassRegistry::new(), &[]);
        assert!(
            ts.contains("export const CoreSpotlightVersionString: string = __dispatch.aw_ts_const_N_a('CoreSpotlightVersionString');"),
            "{ts}"
        );
        assert!(!ts.contains("__wrap"), "{ts}");
        assert!(
            ts.contains("import {\n  __dispatch,\n} from '@apianyware/runtime';"),
            "{ts}"
        );
        assert!(
            dts.contains("export const CoreSpotlightVersionString: string;"),
            "{dts}"
        );
        assert!(!dts.contains("@apianyware/runtime"), "{dts}");

        // A signed `char[]` (int8) is the same banner-string shape on a signed-char platform.
        let signed = vec![array_constant(
            "SignedBanner",
            TypeRefKind::Primitive {
                name: "int8".into(),
            },
        )];
        let (ts, _) = render(&signed, "TestKit", &ClassRegistry::new(), &[]);
        assert!(
            ts.contains("export const SignedBanner: string = __dispatch.aw_ts_const_N_a('SignedBanner');"),
            "{ts}"
        );
    }

    #[test]
    fn non_byte_array_global_has_no_first_pass_surface() {
        // `AppKit::NSFontIdentityMatrix`, a `CGFloat[6]` geometry array — a different, deferred
        // question from the banner-string population (module doc arm 3); not emitted, not counted.
        let consts = vec![array_constant(
            "NSFontIdentityMatrix",
            TypeRefKind::Primitive {
                name: "double".into(),
            },
        )];
        assert_eq!(count(&consts, &ClassRegistry::new()), 0);
        let (ts, _) = render(&consts, "AppKit", &ClassRegistry::new(), &[]);
        assert!(!ts.contains("NSFontIdentityMatrix"), "{ts}");
    }

    #[test]
    fn enum_typed_global_casts_the_read_and_imports_type_only() {
        let consts = vec![constant(
            "TKDefaultAlignment",
            TypeRefKind::Alias {
                name: "TKAlignment".into(),
                framework: None,
                underlying_primitive: Some("int64".into()),
            },
            false,
        )];
        let (ts, dts) = render(&consts, "TestKit", &ClassRegistry::new(), &["TKAlignment"]);
        assert!(
            ts.contains("export const TKDefaultAlignment: TKAlignment = __dispatch.aw_ts_const_q('TKDefaultAlignment') as TKAlignment;"),
            "{ts}"
        );
        assert!(
            ts.contains("import type {\n  TKAlignment,\n} from '@apianyware/testkit';"),
            "{ts}"
        );
        assert!(
            dts.contains("export const TKDefaultAlignment: TKAlignment;"),
            "{dts}"
        );
        assert!(
            dts.contains("import type {\n  TKAlignment,\n} from '@apianyware/testkit';"),
            "{dts}"
        );
    }

    #[test]
    fn swift_native_and_struct_and_void_constants_defer() {
        let mut swift_native = constant(
            "TKSwiftGlobal",
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
            false,
        );
        swift_native.objc_exposed = false;
        let struct_global = constant(
            "TKMainQueue",
            TypeRefKind::Struct {
                name: "dispatch_queue_s".into(),
            },
            false,
        );
        let void_global = constant(
            "TKNothing",
            TypeRefKind::Primitive {
                name: "void".into(),
            },
            false,
        );
        let consts = vec![swift_native, struct_global, void_global];
        assert_eq!(count(&consts, &ClassRegistry::new()), 0);
        let (ts, _) = render(&consts, "TestKit", &ClassRegistry::new(), &[]);
        assert!(!ts.contains("TKSwiftGlobal"), "{ts}");
        assert!(!ts.contains("TKMainQueue"), "{ts}");
        assert!(!ts.contains("TKNothing"), "{ts}");
    }

    #[test]
    fn empty_constants_emit_only_a_banner() {
        let (ts, dts) = render(&[], "TestKit", &ClassRegistry::new(), &[]);
        assert!(ts.contains("// Constants: TestKit (module @apianyware/testkit)"));
        assert!(!ts.contains("export const"));
        assert!(dts.contains("// Type surface: constants (TestKit)"));
        assert!(!dts.contains("export const"));
        assert_eq!(count(&[], &ClassRegistry::new()), 0);
    }

    #[test]
    fn count_matches_emitted_lines() {
        let consts = vec![
            constant(
                "NSFontAttributeName",
                TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                },
                false,
            ),
            constant(
                "NSTimeout",
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
                false,
            ),
            cfstr("kFoo", "bar"),
        ];
        assert_eq!(count(&consts, &foundation()), 3);
    }
}
