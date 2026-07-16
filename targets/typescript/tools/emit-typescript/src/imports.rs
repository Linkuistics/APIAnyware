//! Per-module import grouping — the single place the `.ts` class body
//! ([`crate::emit_class`]) and the co-generated `.d.ts` ([`crate::emit_dts`]) turn a
//! class's referenced types into `import { … } from '<mod>'` blocks, so the two group
//! and sort identically and cannot drift (ADR-0055 §2 — the same discipline
//! [`crate::class_surface`] enforces for method signatures, now for imports).
//!
//! A bound class references types owned by three kinds of module: the runtime
//! (`@apianyware/runtime` — the `NSObject` root + the `.ts` seam helpers), its **own**
//! framework (a same-framework superclass / sibling), and **other** frameworks (a
//! cross-framework superclass, param, or return). [`class_type_imports`] routes each
//! referenced *class type* to its owning module via the [`ClassModuleResolver`];
//! [`render_import_blocks`] writes the grouped blocks. The `.ts` additionally merges its
//! runtime-seam symbols
//! (`__dispatch`, `__wrapOwned`, …) into the runtime block before rendering — a
//! `.ts`-only concern the `.d.ts` never has.
//!
//! ## Enum + protocol types are `import type` (ADR-0055 §6 / §4)
//!
//! An enum referenced in a signature ([`crate::class_surface::referenced_enum_types`]) is
//! used only in **type positions** (the signature, and an `as <Enum>` return cast) — never
//! as a runtime value — so it is imported **type-only** ([`enum_type_imports`] +
//! [`render_type_import_blocks`], `import type { … }`). That is what keeps a same-framework
//! enum reference from forming a *runtime* import cycle through the package barrel (the enum
//! re-exports from `./enums`, the barrel re-exports both — but a type-only import erases, so
//! there is no runtime edge). Routed through the [`EnumModuleResolver`] exactly as class
//! types are through the class resolver, so a cross-framework enum lands on its owner's module.
//!
//! A **protocol interface** reference — a class `implements` clause or a protocol's
//! cross-framework `extends` base (ADR-0055 §4) — is likewise erased at compile, so it takes
//! the same type-only path ([`protocol_type_imports`], routed through the
//! [`ProtocolModuleResolver`]).
//!
//! A **POD geometry type** (`CGRect`, `NSRange`, … — ADR-0055 §5) is the third: a plain by-value
//! object type with no runtime value at all, owned by the runtime rather than by any framework, so
//! it needs no resolver ([`pod_type_imports`]) and imports type-only. It is the sibling of
//! `Result<T>` ([`runtime_result_type_import`]) — both are runtime-owned pure types the emitted
//! surface may name without owning.
//!
//! All four type-only kinds are unioned into one section per emitter ([`merge_type_imports`]) so a
//! module owning several coalesces into a single `import type` block; an empty side leaves the
//! others' output byte-identical.

use std::collections::{BTreeMap, BTreeSet};

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::write_line;

use crate::class_graph::{ClassModuleResolver, RUNTIME_MODULE};
use crate::enum_graph::EnumModuleResolver;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::protocol_binding::protocol_type_name;
use crate::protocol_graph::ProtocolModuleResolver;

/// The runtime-provided discriminated-union `Result<T>` type (ADR-0058) — imported
/// **type-only** from `@apianyware/runtime` by any class (or its `.d.ts`) with a fallible
/// `…error:` method, and referenced in that method's `Result<T>` return signature.
/// Runtime-provided (Step 3), never emitter-defined — the seam, like `__wrapRetained`.
pub const RESULT_TYPE: &str = "Result";

/// A type-only import map for the runtime `Result<T>` type, unioned into a class's
/// type-only import section ([`merge_type_imports`]) when it has at least one fallible
/// `…error:` method (`has_fallible`). Empty otherwise, so a class with no fallible method
/// keeps its imports byte-identical. The `.ts` and `.d.ts` both route through this helper,
/// so their `Result` import cannot drift (ADR-0055 §2).
pub fn runtime_result_type_import(has_fallible: bool) -> BTreeMap<String, BTreeSet<String>> {
    let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    if has_fallible {
        map.entry(RUNTIME_MODULE.to_string())
            .or_default()
            .insert(RESULT_TYPE.to_string());
    }
    map
}

/// The runtime-provided `OverridableMethod` type (ADR-0059 §4) — imported **type-only** from
/// `@apianyware/runtime` by any class that emits a `static readonly __overridable` catalogue
/// ([`crate::subclass_surface`]). The sibling of [`runtime_result_type_import`]: a runtime-owned
/// pure type the emitted surface may name without owning, gated on the same "has at least one" test
/// (`has_overridable`) so a class with no overridable instance method keeps its imports
/// byte-identical.
pub fn runtime_overridable_type_import(
    has_overridable: bool,
) -> BTreeMap<String, BTreeSet<String>> {
    let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    if has_overridable {
        map.entry(RUNTIME_MODULE.to_string())
            .or_default()
            .insert("OverridableMethod".to_string());
    }
    map
}

/// A surface's referenced **POD geometry type** names
/// ([`crate::class_surface::referenced_pod_types`] and its per-emitter siblings), grouped into a
/// type-only import map. Every POD type is owned by the **runtime** — the set is fixed, closed, and
/// keyed by memory layout rather than framework (one `CGRect` serves AppKit, Foundation and
/// CoreGraphics alike), so unlike a class, an enum or a protocol there is nothing to *route*: the
/// module is always [`RUNTIME_MODULE`]. Hence no resolver parameter.
///
/// Rendered **type-only** ([`render_type_import_blocks`]) and unioned into the emitter's one
/// `import type` section ([`merge_type_imports`]), where it coalesces with `Result<T>` into a single
/// runtime block: a POD type is a plain object type with no runtime value, so the import erases at
/// emit and forms no runtime edge. Empty in, empty out — a geometry-free class keeps its imports
/// byte-identical.
pub fn pod_type_imports(referenced: &BTreeSet<String>) -> BTreeMap<String, BTreeSet<String>> {
    let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    if !referenced.is_empty() {
        map.entry(RUNTIME_MODULE.to_string())
            .or_default()
            .extend(referenced.iter().cloned());
    }
    map
}

/// A class's referenced class-type names ([`crate::class_surface::referenced_class_types`]),
/// grouped into per-module import sets by routing each through the resolver to its
/// owning module (ADR-0055 §2). The map key is the module specifier
/// (`@apianyware/foundation`), the value the sorted symbol set. `BTreeMap`/`BTreeSet`
/// give deterministic module and name order; the `.ts` (which merges its runtime-seam
/// block on top) and the `.d.ts` both build from this helper, so their class-type blocks
/// stay identical.
pub fn class_type_imports(
    referenced: &BTreeSet<String>,
    resolver: &ClassModuleResolver<'_>,
) -> BTreeMap<String, BTreeSet<String>> {
    let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    for name in referenced {
        map.entry(resolver.module_for(name))
            .or_default()
            .insert(name.clone());
    }
    map
}

/// A class's referenced **enum** type names ([`crate::class_surface::referenced_enum_types`]),
/// grouped into per-module import sets by routing each through the [`EnumModuleResolver`] to
/// its owning module (a same-framework enum → the current framework's package barrel, a
/// cross-framework enum → its owner's). Same `BTreeMap`/`BTreeSet` determinism as
/// [`class_type_imports`]; rendered as **type-only** `import type` blocks
/// ([`render_type_import_blocks`]) because an enum in a signature is never a runtime value.
pub fn enum_type_imports(
    referenced: &BTreeSet<String>,
    resolver: &EnumModuleResolver<'_>,
) -> BTreeMap<String, BTreeSet<String>> {
    let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    for name in referenced {
        map.entry(resolver.module_for(name))
            .or_default()
            .insert(name.clone());
    }
    map
}

/// A class's / protocol's referenced **protocol** interface names (the conformed
/// protocols of a class `implements` clause, or the cross-framework bases of a protocol
/// `extends`), grouped into per-module import sets by routing each through the
/// [`ProtocolModuleResolver`] to its owning module (a same-framework protocol → the current
/// framework's package barrel, a cross-framework protocol → its owner's). Same
/// `BTreeMap`/`BTreeSet` determinism as [`class_type_imports`]; rendered as **type-only**
/// `import type` blocks ([`render_type_import_blocks`]) because an interface reference —
/// `implements` or an `extends` base — is erased at compile (no runtime value), so it forms
/// no runtime cycle through the barrel.
///
/// `referenced` carries **raw** ObjC protocol names — the registry's routing key — but the
/// imported *identifier* is [`protocol_type_name`]: a name a declared class also carries
/// (`protocol-class-name-collapse-k90`) imports under its re-encoded `<Name>Protocol` spelling,
/// the same one its declaration and every other reference use.
pub fn protocol_type_imports(
    referenced: &BTreeSet<String>,
    resolver: &ProtocolModuleResolver<'_>,
    mapper: &TsFfiTypeMapper,
) -> BTreeMap<String, BTreeSet<String>> {
    let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    for name in referenced {
        map.entry(resolver.module_for(name))
            .or_default()
            .insert(protocol_type_name(name, mapper));
    }
    map
}

/// The **`DelegateSpec` value** imports a class's bodies need — `SPEC_<P>` for every protocol whose
/// slots this class bridges (`emitted-delegate-spec-k84`), routed to that protocol's owning module by
/// the same `resolver` its *interface* is routed to. A **value** import, unlike
/// [`protocol_type_imports`]: a spec is real runtime data (the forwarder's method table + its value
/// surface). Safe to import from the barrel all the same, because a `delegates.ts` imports **nothing**
/// but `@apianyware/runtime` — there is no path back into a class module, so no cycle to close
/// ([`crate::delegate_spec`]).
pub fn protocol_spec_imports(
    referenced: &BTreeSet<String>,
    resolver: &ProtocolModuleResolver<'_>,
) -> BTreeMap<String, BTreeSet<String>> {
    let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    for name in referenced {
        map.entry(resolver.module_for(name))
            .or_default()
            .insert(crate::delegate_spec::spec_symbol(name));
    }
    map
}

/// Merge two type-only import maps (enum references + protocol interface references) into
/// one, so a module owning both an enum and a protocol the surface references coalesces into
/// a single `import type { … } from '<mod>'` block rather than two. `extra`'s names union
/// into `base`'s per-module sets; both keep `BTreeMap`/`BTreeSet` ordering, so the merged map
/// renders deterministically. An empty `extra` returns `base` unchanged (the enum-only case
/// stays byte-identical to the pre-protocol output).
pub fn merge_type_imports(
    mut base: BTreeMap<String, BTreeSet<String>>,
    extra: BTreeMap<String, BTreeSet<String>>,
) -> BTreeMap<String, BTreeSet<String>> {
    for (module, names) in extra {
        base.entry(module).or_default().extend(names);
    }
    base
}

/// Render per-module import blocks — one `import { … } from '<mod>';` per module,
/// modules sorted by specifier, names sorted within each block (each on its own line
/// with a trailing comma, the shared idiom the goldens lock). Blocks are written
/// back-to-back; the caller emits the trailing blank line before the code body (and
/// omits it when the map is empty).
pub fn render_import_blocks(map: &BTreeMap<String, BTreeSet<String>>, w: &mut CodeWriter) {
    for (module, names) in map {
        w.line("import {");
        for name in names {
            write_line!(w, "  {name},");
        }
        write_line!(w, "}} from '{module}';");
    }
}

/// Render per-module **type-only** import blocks — one `import type { … } from '<mod>';`
/// per module, same sorting/idiom as [`render_import_blocks`]. Used for enum type
/// references (module doc): the `type` keyword makes the import erase at emit, so a
/// same-framework enum reference forms no runtime cycle through the barrel. Written after
/// the value-import blocks; the caller manages the trailing blank line.
pub fn render_type_import_blocks(map: &BTreeMap<String, BTreeSet<String>>, w: &mut CodeWriter) {
    for (module, names) in map {
        w.line("import type {");
        for name in names {
            write_line!(w, "  {name},");
        }
        write_line!(w, "}} from '{module}';");
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::class_graph::ClassRegistry;
    use crate::enum_graph::EnumRegistry;
    use crate::protocol_graph::ProtocolRegistry;
    use std::sync::Arc;

    fn set(names: &[&str]) -> BTreeSet<String> {
        names.iter().map(|s| s.to_string()).collect()
    }

    fn arc_set(names: &[&str]) -> Arc<BTreeSet<String>> {
        Arc::new(set(names))
    }

    #[test]
    fn class_types_group_by_owning_module() {
        // Emitting AppKit with a populated registry: NSObject → runtime, a same-fw
        // sibling (NSView) → the current framework, a cross-fw class (NSString) → its
        // owning module.
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let resolver = ClassModuleResolver::new("AppKit", &reg, Arc::new(reg.names()));
        let map = class_type_imports(&set(&["NSObject", "NSView", "NSString"]), &resolver);
        assert_eq!(map.get("@apianyware/runtime"), Some(&set(&["NSObject"])));
        assert_eq!(map.get("@apianyware/appkit"), Some(&set(&["NSView"])));
        assert_eq!(map.get("@apianyware/foundation"), Some(&set(&["NSString"])));
    }

    #[test]
    fn render_blocks_sort_by_module_then_name_back_to_back() {
        let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
        map.insert(
            "@apianyware/runtime".into(),
            set(&["NSObject", "__dispatch"]),
        );
        map.insert("@apianyware/appkit".into(), set(&["NSColor", "NSView"]));
        let mut w = CodeWriter::new();
        render_import_blocks(&map, &mut w);
        // appkit sorts before runtime; names sorted within; no blank line between blocks.
        assert_eq!(
            w.finish(),
            "import {\n  NSColor,\n  NSView,\n} from '@apianyware/appkit';\n\
             import {\n  NSObject,\n  __dispatch,\n} from '@apianyware/runtime';\n"
        );
    }

    #[test]
    fn empty_map_renders_nothing() {
        let map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
        let mut w = CodeWriter::new();
        render_import_blocks(&map, &mut w);
        assert_eq!(w.finish(), "");
    }

    #[test]
    fn enum_types_group_by_owning_module() {
        // Emitting AppKit: a same-fw enum (NSCellType) → the current framework's barrel, a
        // cross-fw enum (NSComparisonResult, owned by Foundation) → its owning module.
        let mut reg = EnumRegistry::new();
        reg.insert("NSComparisonResult", "foundation");
        let resolver = EnumModuleResolver::new(
            "AppKit",
            &reg,
            arc_set(&["NSCellType", "NSComparisonResult"]),
        );
        let map = enum_type_imports(&set(&["NSCellType", "NSComparisonResult"]), &resolver);
        assert_eq!(map.get("@apianyware/appkit"), Some(&set(&["NSCellType"])));
        assert_eq!(
            map.get("@apianyware/foundation"),
            Some(&set(&["NSComparisonResult"]))
        );
    }

    #[test]
    fn render_type_blocks_use_the_type_keyword() {
        // Enum references are type-only imports (no runtime cycle through the barrel).
        let mut map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
        map.insert(
            "@apianyware/testkit".into(),
            set(&["TKAlignment", "TKKeyMask"]),
        );
        let mut w = CodeWriter::new();
        render_type_import_blocks(&map, &mut w);
        assert_eq!(
            w.finish(),
            "import type {\n  TKAlignment,\n  TKKeyMask,\n} from '@apianyware/testkit';\n"
        );
    }

    #[test]
    fn empty_enum_map_renders_nothing() {
        let map: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
        let mut w = CodeWriter::new();
        render_type_import_blocks(&map, &mut w);
        assert_eq!(w.finish(), "");
    }

    #[test]
    fn protocol_types_group_by_owning_module() {
        // Emitting TestKit with a populated protocol registry: a same-fw protocol
        // (TKRefreshing) → the current framework's barrel, a cross-fw protocol (NSCopying,
        // owned by Foundation) → its owning module. Same routing as enum type imports.
        let mut reg = ProtocolRegistry::new();
        reg.insert("NSCopying", "foundation");
        let resolver =
            ProtocolModuleResolver::new("TestKit", &reg, arc_set(&["TKRefreshing", "NSCopying"]));
        let map = protocol_type_imports(
            &set(&["TKRefreshing", "NSCopying"]),
            &resolver,
            &TsFfiTypeMapper::new(),
        );
        assert_eq!(
            map.get("@apianyware/testkit"),
            Some(&set(&["TKRefreshing"]))
        );
        assert_eq!(
            map.get("@apianyware/foundation"),
            Some(&set(&["NSCopying"]))
        );
    }

    #[test]
    fn a_protocol_colliding_with_a_declared_class_imports_under_the_renamed_identifier() {
        // k90: `referenced` carries the RAW ObjC name (the registry's routing key — `owner`/
        // `module_for` are keyed on it), but the imported *identifier* is `protocol_type_name`'s
        // rendering, so a colliding name imports as `<Name>Protocol` here too — the same string
        // its own declaration and every `implements`/`extends`/`id<P>` reference use.
        let reg = ProtocolRegistry::new();
        let resolver = ProtocolModuleResolver::new("TestKit", &reg, arc_set(&["TKWidget"]));
        let mapper = TsFfiTypeMapper::with_known(
            Arc::default(),
            arc_set(&["TKWidget"]),
            arc_set(&["TKWidget"]),
        );
        let map = protocol_type_imports(&set(&["TKWidget"]), &resolver, &mapper);
        assert_eq!(
            map.get("@apianyware/testkit"),
            Some(&set(&["TKWidgetProtocol"])),
            "the routing key stays raw, but the imported symbol is re-encoded"
        );
    }

    #[test]
    fn pod_types_all_route_to_the_runtime_and_coalesce_with_result() {
        // A POD is runtime-owned whatever framework references it — the set is keyed by memory
        // layout, not by framework — so there is no resolver and no routing decision to get wrong.
        let map = pod_type_imports(&set(&["CGRect", "NSRange"]));
        assert_eq!(
            map.get("@apianyware/runtime"),
            Some(&set(&["CGRect", "NSRange"]))
        );
        assert_eq!(map.len(), 1, "one module — the runtime");

        // It merges with `Result<T>` (the other runtime-owned pure type) into ONE `import type`
        // block, rather than emitting two blocks from the same specifier.
        let merged = merge_type_imports(map, runtime_result_type_import(true));
        assert_eq!(
            merged.get("@apianyware/runtime"),
            Some(&set(&["CGRect", "NSRange", "Result"]))
        );
        let mut w = CodeWriter::new();
        render_type_import_blocks(&merged, &mut w);
        assert_eq!(
            w.finish(),
            "import type {\n  CGRect,\n  NSRange,\n  Result,\n} from '@apianyware/runtime';\n"
        );
    }

    #[test]
    fn no_pod_reference_renders_nothing() {
        // Empty in, empty out: a geometry-free surface's import section is untouched.
        assert!(pod_type_imports(&BTreeSet::new()).is_empty());
    }

    #[test]
    fn merge_type_imports_unions_per_module_and_is_empty_extra_identity() {
        // An enum and a protocol owned by the same framework coalesce into one per-module set
        // (a single `import type` block); a disjoint module stays separate.
        let enum_map: BTreeMap<String, BTreeSet<String>> = [
            ("@apianyware/testkit".to_string(), set(&["TKAlignment"])),
            (
                "@apianyware/foundation".to_string(),
                set(&["NSComparisonResult"]),
            ),
        ]
        .into_iter()
        .collect();
        let proto_map: BTreeMap<String, BTreeSet<String>> =
            [("@apianyware/testkit".to_string(), set(&["TKRefreshing"]))]
                .into_iter()
                .collect();
        let merged = merge_type_imports(enum_map.clone(), proto_map);
        // testkit coalesces the enum + protocol; foundation carries the lone enum.
        assert_eq!(
            merged.get("@apianyware/testkit"),
            Some(&set(&["TKAlignment", "TKRefreshing"]))
        );
        assert_eq!(
            merged.get("@apianyware/foundation"),
            Some(&set(&["NSComparisonResult"]))
        );
        // An empty `extra` returns `base` unchanged — the enum-only case stays byte-identical.
        assert_eq!(
            merge_type_imports(enum_map.clone(), BTreeMap::new()),
            enum_map
        );
    }
}
