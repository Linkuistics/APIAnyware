//! Per-class `.d.ts` **type-surface** emission — the binding's first-class type
//! deliverable (ADR-0055 §2), the new idiom axis no prior target had (root brief).
//!
//! The `.d.ts` is co-generated with the `.ts` class body ([`crate::emit_class`]) from
//! the **same IR pass**, through the shared [`crate::class_surface`] helpers (same
//! method set, same class header, same per-method signature), so runtime and types
//! provably cannot drift. It is a **declaration-only** projection: the public
//! `extends` chain and `;`-terminated method signatures a consumer and `tsc` see — no
//! bodies, no `__cls`/dispatch internals, no runtime-seam helpers (those live only in
//! the `.ts`). For the `Widget` fixture, beside `widget.ts`:
//!
//! ```ts
//! export class Widget extends NSObject {
//!   static widgetWithName_(name: NSObject): Widget;
//!   initWithName_(name: NSObject): this | null;
//!   length(): number;
//!   objectAtIndex_(index: number): NSObject | null;
//!   setLength_(length: number): void;
//! }
//! ```
//!
//! `instancetype` on an **instance** method renders as the polymorphic `this` (above) —
//! identically in the `.ts` ([`crate::class_surface`], `override-signature-mismatch-k100`).
//!
//! ## Scope — render one class, cross-class imports routed
//!
//! [`render_dts`] renders a single class's `.d.ts`, routing each referenced class type
//! to its owning module through the shared [`crate::imports`] grouping (the same the
//! `.ts` uses, so the two cannot drift). The orchestrator ([`crate::emit_framework`])
//! writes the paired files per framework, in superclass-before-subclass order, with the
//! barrel and real-framework goldens.

use std::collections::{BTreeSet, HashSet};

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::write_line;
use apianyware_types::ir::{Class, Method};

use crate::class_graph::ClassModuleResolver;
use crate::class_surface::{
    bound_methods, class_header, deprecation_doc, has_bindable_init, method_header,
    protocol_import_names, referenced_class_types, referenced_enum_types, referenced_pod_types,
};
use crate::enum_graph::EnumModuleResolver;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::imports::{
    class_type_imports, enum_type_imports, merge_type_imports, pod_type_imports,
    protocol_type_imports, render_import_blocks, render_type_import_blocks,
    runtime_result_type_import,
};
use crate::method_filter::is_error_out_method;
use crate::naming::class_type_name;
use crate::override_widening::OverrideWidenings;
use crate::protocol_graph::ProtocolModuleResolver;

/// Render one bound ObjC class as its declaration-only `.d.ts` module string: the
/// banner, the per-module import of every referenced class type (routed through the
/// `resolver`) and every referenced enum type (type-only, via the `enum_resolver`), and
/// the `export class … extends …` with a `;`-terminated signature per bindable method —
/// public surface only, no bodies. Co-generated with
/// [`crate::emit_class::render_class`] through [`crate::class_surface`] +
/// [`crate::imports`], so the two share method set, signatures, **and** import grouping
/// and cannot drift. The `enum_resolver` also carries the recognition set the enum-aware
/// [`TsFfiTypeMapper`] is built from (enum-alias-typing, ADR-0055 §6).
#[allow(clippy::too_many_arguments)]
pub fn render_dts(
    cls: &Class,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    error_selectors: &HashSet<String>,
    widenings: &OverrideWidenings,
    synthetic_init_blocklist: &BTreeSet<String>,
) -> String {
    // All three recognition sets — the identical mapper [`crate::emit_class`] builds, which is what
    // makes the `.d.ts` signatures the `.ts` bodies' own (ADR-0055 §2): enums (an alias upgrades off
    // `number`, §6), the whole-program declared classes (`class_binding`, k66) and the protocol
    // recognition set (a bound `id<P>` types by its interface, `protocol_binding`, k89).
    let mapper = TsFfiTypeMapper::with_known(
        enum_resolver.known_enums(),
        resolver.known_classes(),
        protocol_resolver.known_protocols(),
    );
    let (class_methods, instance_methods) =
        bound_methods(cls, &mapper, error_selectors, protocol_resolver.registry());

    // The same decision [`crate::emit_class::render_class`] reads — one flattened-ancestry check
    // plus the whole-program blocklist exception — so the `.ts` body and this declaration cannot
    // drift on whether the synthetic init exists (`nsobject-plain-init-surface-gap-k122`).
    let needs_synthetic_init =
        !has_bindable_init(cls, &mapper, error_selectors) && !synthetic_init_blocklist.contains(&cls.name);

    let mut w = CodeWriter::new();
    emit_header(
        &mut w,
        cls,
        &class_methods,
        &instance_methods,
        &mapper,
        resolver,
        enum_resolver,
        protocol_resolver,
        error_selectors,
        widenings,
    );

    write_line!(w, "{} {{", class_header(cls, protocol_resolver, &mapper));
    w.indent();
    // Statics first, then instance methods — the same order the `.ts` emits. A
    // declaration is one compact `;`-terminated line (no bodies ⇒ no blank-line
    // spacing, unlike the `.ts`). A fallible `…error:` declaration reads `Result<T>`,
    // the out-param dropped — identical to the `.ts` signature (ADR-0058 / ADR-0055 §2).
    for m in class_methods.iter().chain(instance_methods.iter()) {
        if let Some(doc) = deprecation_doc(m) {
            w.line(doc);
        }
        write_line!(
            w,
            "{};",
            method_header(cls, m, &mapper, error_selectors, widenings)
        );
    }
    // A class whose real ancestry never redeclares `-init` declares the same synthetic plain
    // initializer the `.ts` implements (module doc on [`crate::emit_class::emit_synthetic_init`]).
    if needs_synthetic_init {
        w.line("init(): this;");
    }
    w.dedent();
    w.line("}");
    w.finish()
}

/// The generated-file banner + the per-module import of every referenced class type
/// (routed through the resolver; the shared [`crate::imports`] grouping the `.ts` uses,
/// minus its runtime-seam block — the `.d.ts` has no seam helpers), then the type-only
/// enum imports (via the `enum_resolver`, identical to the `.ts` so the two cannot drift).
#[allow(clippy::too_many_arguments)]
fn emit_header(
    w: &mut CodeWriter,
    cls: &Class,
    class_methods: &[&Method],
    instance_methods: &[&Method],
    mapper: &TsFfiTypeMapper,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    error_selectors: &HashSet<String>,
    widenings: &OverrideWidenings,
) {
    let has_fallible = class_methods
        .iter()
        .chain(instance_methods.iter())
        .any(|m| is_error_out_method(m, error_selectors));

    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(
        w,
        "// Type surface: {} ({})",
        class_type_name(&cls.name),
        resolver.framework()
    );
    w.line("//");
    w.line("// Declaration-only .d.ts, co-generated with the .ts class body from one IR pass");
    w.line("// (ADR-0055 §2) so runtime and types cannot drift: the public type surface tsc and");
    w.line("// consumers see — no bodies, no __cls/dispatch internals, no runtime-seam helpers.");
    w.blank_line();

    // Identical import grouping to the `.ts` (module doc): class-type value imports, then the
    // combined type-only section — referenced enums merged with the conformed protocol
    // interfaces of the `implements` clause, the referenced POD geometry types (ADR-0055 §5),
    // plus the runtime `Result<T>` type for a class with a fallible `…error:` method (ADR-0058)
    // — minus the `.ts`-only runtime-seam block.
    let referenced =
        referenced_class_types(cls, class_methods, instance_methods, mapper, widenings);
    let map = class_type_imports(&referenced, resolver);
    let enum_map = enum_type_imports(
        &referenced_enum_types(class_methods, instance_methods, mapper),
        enum_resolver,
    );
    let proto_map = protocol_type_imports(
        &protocol_import_names(
            cls,
            class_methods,
            instance_methods,
            mapper,
            protocol_resolver,
            widenings,
        ),
        protocol_resolver,
        mapper,
    );
    let pod_map = pod_type_imports(&referenced_pod_types(class_methods, instance_methods));
    let type_map = merge_type_imports(
        merge_type_imports(merge_type_imports(enum_map, proto_map), pod_map),
        runtime_result_type_import(has_fallible),
    );
    render_import_blocks(&map, w);
    render_type_import_blocks(&type_map, w);
    if !map.is_empty() || !type_map.is_empty() {
        w.blank_line();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::class_graph::ClassRegistry;
    use crate::enum_graph::EnumRegistry;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::ir::{Class, Method, Param};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};
    use std::collections::BTreeSet;
    use std::sync::Arc;

    /// The declared-class recognition set for a one-class render — the exact shape
    /// [`crate::emit_framework`] builds (`registry.names()` ∪ the framework's own classes), with
    /// `cls` standing in for the framework's class list. A test referencing **another** class
    /// must register it, precisely as the whole-program registry would: a `Class{name}` outside
    /// the set is not a class the emitter emits, so k66 degrades it to `NSObject`.
    fn known_classes(cls: &Class, registry: &ClassRegistry) -> Arc<BTreeSet<String>> {
        let mut set = registry.names();
        set.insert(cls.name.clone());
        Arc::new(set)
    }

    /// Render through a class resolver for framework `fw` backed by `registry` and an enum
    /// resolver aware of `known_enums`. No conformed protocols (the common case here).
    fn render_with_enums(
        cls: &Class,
        fw: &str,
        registry: &ClassRegistry,
        known_enums: &[&str],
    ) -> String {
        render_full(
            cls,
            fw,
            registry,
            known_enums,
            &ProtocolRegistry::new(),
            &[],
        )
    }

    /// The full per-framework `.d.ts` render: class resolver (`registry`), enum resolver
    /// (`known_enums`), and protocol resolver (`proto_reg` + `known_protocols` — the
    /// `implements` surface).
    fn render_full(
        cls: &Class,
        fw: &str,
        registry: &ClassRegistry,
        known_enums: &[&str],
        proto_reg: &ProtocolRegistry,
        known_protocols: &[&str],
    ) -> String {
        let enum_reg = EnumRegistry::new();
        let known: Arc<BTreeSet<String>> =
            Arc::new(known_enums.iter().map(|s| s.to_string()).collect());
        let enum_resolver = EnumModuleResolver::new(fw, &enum_reg, known);
        let known_p: Arc<BTreeSet<String>> =
            Arc::new(known_protocols.iter().map(|s| s.to_string()).collect());
        let protocol_resolver = ProtocolModuleResolver::new(fw, proto_reg, known_p);
        render_dts(
            cls,
            &ClassModuleResolver::new(fw, registry, known_classes(cls, registry)),
            &enum_resolver,
            &protocol_resolver,
            &HashSet::new(),
            &OverrideWidenings::empty(),
            &BTreeSet::new(),
        )
    }

    /// Render through a resolver for framework `fw` backed by `registry` (no known enums).
    fn render(cls: &Class, fw: &str, registry: &ClassRegistry) -> String {
        render_with_enums(cls, fw, registry, &[])
    }

    /// The common case: render in framework `fw` with an empty registry.
    fn render_in(cls: &Class, fw: &str) -> String {
        render(cls, fw, &ClassRegistry::new())
    }

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn nullable(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: true,
            kind,
        }
    }

    fn param(name: &str, param_type: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type,
        }
    }

    fn method(
        selector: &str,
        class_method: bool,
        params: Vec<Param>,
        return_type: TypeRef,
        returns_retained: Option<bool>,
    ) -> Method {
        Method {
            selector: selector.into(),
            class_method,
            init_method: false,
            params,
            return_type,
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    /// The same hand-built fixture the `.ts` golden (k18) uses: a static factory
    /// (non-null instancetype), an `init` (nullable instancetype), a scalar getter, a
    /// scalar-param + nullable-object return, and a void setter — so the `.ts` and
    /// `.d.ts` goldens are read side by side.
    fn widget() -> Class {
        Class {
            name: "Widget".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                method(
                    "widgetWithName:",
                    true,
                    vec![param(
                        "name",
                        ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    )],
                    ty(TypeRefKind::Instancetype),
                    None,
                ),
                method(
                    "initWithName:",
                    false,
                    vec![param(
                        "name",
                        ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    )],
                    nullable(TypeRefKind::Instancetype),
                    Some(true),
                ),
                method(
                    "length",
                    false,
                    vec![],
                    ty(TypeRefKind::Primitive {
                        name: "NSUInteger".into(),
                    }),
                    None,
                ),
                method(
                    "objectAtIndex:",
                    false,
                    vec![param(
                        "index",
                        ty(TypeRefKind::Primitive {
                            name: "NSUInteger".into(),
                        }),
                    )],
                    nullable(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                    None,
                ),
                method(
                    "setLength:",
                    false,
                    vec![param(
                        "length",
                        ty(TypeRefKind::Primitive {
                            name: "NSUInteger".into(),
                        }),
                    )],
                    TypeRef::void(),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    /// The full emitted-`.d.ts` golden — the declaration-only surface paired with the
    /// k18 `.ts` golden, from the same shared pass.
    const WIDGET_DTS_GOLDEN: &str = r#"// Generated by apianyware emit-typescript — DO NOT EDIT.
// Type surface: Widget (TestKit)
//
// Declaration-only .d.ts, co-generated with the .ts class body from one IR pass
// (ADR-0055 §2) so runtime and types cannot drift: the public type surface tsc and
// consumers see — no bodies, no __cls/dispatch internals, no runtime-seam helpers.

import {
  NSObject,
} from '@apianyware/runtime';

export class Widget extends NSObject {
  static widgetWithName_(name: NSObject): Widget;
  initWithName_(name: NSObject): this | null;
  length(): number;
  objectAtIndex_(index: number): NSObject | null;
  setLength_(length: number): void;
  init(): this;
}
"#;

    #[test]
    fn widget_matches_full_dts_golden() {
        assert_eq!(render_in(&widget(), "TestKit"), WIDGET_DTS_GOLDEN);
    }

    #[test]
    fn is_declaration_only_no_bodies_or_internals() {
        let out = render_in(&widget(), "TestKit");
        // Every line inside the class body is a `;`-terminated declaration — no
        // `{ … }` method bodies.
        let open = out
            .find("export class Widget extends NSObject {")
            .expect("class opener");
        let body = &out[open..];
        for line in body.lines().skip(1) {
            let trimmed = line.trim();
            if trimmed == "}" {
                break;
            }
            assert!(
                trimmed.ends_with(';'),
                "a class-body line must be a `;`-terminated declaration, got `{trimmed}`:\n{out}"
            );
        }
        // None of the `.ts`-only implementation surface leaks into the emitted class
        // body (checked over the code region — the banner *names* these to say it omits
        // them, so scope past it).
        for internal in [
            "__cls",
            "__dispatch",
            "__sel",
            "__unwrap",
            "__wrap",
            "return ",
        ] {
            assert!(
                !body.contains(internal),
                "declaration surface must not contain `{internal}`:\n{out}"
            );
        }
    }

    #[test]
    fn static_factory_instancetype_is_the_concrete_class() {
        // The receiver of a static factory is the class, so instancetype → Widget
        // (both artifacts agree here).
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("static widgetWithName_(name: NSObject): Widget;"),
            "static factory instancetype → concrete class:\n{out}"
        );
    }

    #[test]
    fn instance_instancetype_is_this_not_the_concrete_class() {
        // The k19 nuance: the `.d.ts` expresses an instance method's instancetype as
        // the polymorphic `this` (the `.ts` used concrete `Widget` for cast-free
        // bodies).
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("initWithName_(name: NSObject): this | null;"),
            "instance instancetype → `this` in the .d.ts:\n{out}"
        );
        assert!(
            !out.contains("): Widget | null;"),
            "instance instancetype must NOT be the concrete class in the .d.ts:\n{out}"
        );
    }

    #[test]
    fn nullable_and_non_null_returns_split_from_annotations() {
        let out = render_in(&widget(), "TestKit");
        // Nullable object return keeps `| null`; a non-null return does not.
        assert!(
            out.contains("objectAtIndex_(index: number): NSObject | null;"),
            "nullable id return → NSObject | null:\n{out}"
        );
        assert!(
            out.contains("static widgetWithName_(name: NSObject): Widget;"),
            "non-null instancetype return → bare Widget (no | null):\n{out}"
        );
        // Scalars/void never gain `| null`.
        assert!(out.contains("length(): number;"), "scalar return:\n{out}");
        assert!(
            out.contains("setLength_(length: number): void;"),
            "void:\n{out}"
        );
    }

    #[test]
    fn the_dts_type_imports_the_same_pod_types_the_ts_does() {
        // ADR-0055 §2's no-drift discipline applied to the POD arm: the `.d.ts` and the `.ts`
        // route through ONE shared computation (`class_surface::referenced_pod_types`), so they
        // cannot disagree about which geometry types the surface names. The `.d.ts` half of
        // `emit_class::a_geometry_carrying_class_type_imports_its_pod_types_from_the_runtime`.
        let mut cls = widget();
        cls.methods.push(Method {
            selector: "frame".into(),
            class_method: false,
            init_method: false,
            params: vec![Param {
                name: "point".into(),
                param_type: ty(TypeRefKind::Struct {
                    name: "NSPoint".into(),
                }),
            }],
            return_type: ty(TypeRefKind::Struct {
                name: "NSRect".into(),
            }),
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
        });
        let out = render_in(&cls, "TestKit");
        assert!(
            out.contains("import type {\n  CGPoint,\n  CGRect,\n} from '@apianyware/runtime';"),
            "the `.d.ts` type-imports the referenced PODs from the runtime:\n{out}"
        );
        assert!(
            out.contains("frame(point: CGPoint): CGRect;"),
            "declared with the POD types it imports:\n{out}"
        );
    }

    #[test]
    fn imports_referenced_class_types_not_the_runtime_seam() {
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("import {\n  NSObject,\n} from '@apianyware/runtime';"),
            "imports the referenced runtime class type NSObject:\n{out}"
        );
        // The `.d.ts` references no runtime-seam helpers (they are `.ts`-only).
        for seam in ["__dispatch", "__sel", "__class", "__wrapRetained"] {
            assert!(!out.contains(seam), "no seam import `{seam}`:\n{out}");
        }
    }

    #[test]
    fn extends_chain_roots_at_nsobject() {
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("export class Widget extends NSObject {"),
            "real extends chain:\n{out}"
        );
    }

    #[test]
    fn self_type_is_not_imported() {
        // A method taking/returning the declaring class must not import it (it is
        // defined in this very file). `instancetype` returns already exercise the
        // return side; add a param typed as the concrete class to exercise params.
        let mut cls = widget();
        cls.methods.push(method(
            "sibling:",
            false,
            vec![param(
                "other",
                ty(TypeRefKind::Class {
                    name: "Widget".into(),
                    framework: None,
                    params: vec![],
                }),
            )],
            nullable(TypeRefKind::Class {
                name: "Widget".into(),
                framework: None,
                params: vec![],
            }),
            None,
        ));
        let out = render_in(&cls, "TestKit");
        assert!(
            out.contains("sibling_(other: Widget): Widget | null;"),
            "self-typed param/return render as Widget:\n{out}"
        );
        // The import set is still just NSObject — Widget is defined here.
        assert!(
            out.contains("import {\n  NSObject,\n} from '@apianyware/runtime';"),
            "the declaring class is never imported:\n{out}"
        );
    }

    #[test]
    fn cross_class_dts_imports_group_by_owning_module() {
        // A Gadget extends Widget (same fw) with a cross-fw param (NSColor) and return
        // (NSString): the `.d.ts` groups each into its owning module's block, sorted by
        // specifier, and — having no runtime reference — imports no runtime module at
        // all (no NSObject, no seam helpers).
        let gadget = Class {
            name: "Gadget".into(),
            superclass: "Widget".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                method(
                    "gadgetWithColor:",
                    true,
                    vec![param(
                        "color",
                        ty(TypeRefKind::Class {
                            name: "NSColor".into(),
                            framework: None,
                            params: vec![],
                        }),
                    )],
                    ty(TypeRefKind::Instancetype),
                    None,
                ),
                method(
                    "title",
                    false,
                    vec![],
                    nullable(TypeRefKind::Class {
                        name: "NSString".into(),
                        framework: None,
                        params: vec![],
                    }),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let mut reg = ClassRegistry::new();
        reg.insert("NSColor", "appkit");
        reg.insert("NSString", "foundation");
        let out = render(&gadget, "TestKit", &reg);
        assert!(
            out.contains("import {\n  NSColor,\n} from '@apianyware/appkit';"),
            "cross-fw param → its owning module:\n{out}"
        );
        assert!(
            out.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "cross-fw return → its owning module:\n{out}"
        );
        assert!(
            out.contains("import {\n  Widget,\n} from '@apianyware/testkit';"),
            "same-fw superclass → the current framework's package:\n{out}"
        );
        assert!(
            out.contains("export class Gadget extends Widget {"),
            "extends the same-framework superclass:\n{out}"
        );
        // No runtime import: the `.d.ts` has no seam helpers, and this class references
        // no NSObject (the fixed unconditional import).
        assert!(
            !out.contains("@apianyware/runtime"),
            "no runtime import when NSObject is unreferenced:\n{out}"
        );
    }

    #[test]
    fn dts_declares_exactly_the_ts_method_surface() {
        // The "cannot drift" invariant (ADR-0055 §2) made observable: both artifacts
        // flow from the same shared `bound_methods`, so the `.d.ts` types exactly the
        // methods the `.ts` implements — no more, no fewer.
        let cls = widget();
        let reg = ClassRegistry::new();
        let resolver = ClassModuleResolver::new("TestKit", &reg, Arc::new(reg.names()));
        let enum_reg = EnumRegistry::new();
        let enum_resolver = EnumModuleResolver::new("TestKit", &enum_reg, Arc::default());
        let proto_reg = ProtocolRegistry::new();
        let protocol_resolver = ProtocolModuleResolver::new("TestKit", &proto_reg, Arc::default());
        let ts = crate::emit_class::render_class(
            &cls,
            &resolver,
            &enum_resolver,
            &protocol_resolver,
            &HashSet::new(),
            &HashSet::new(),
            &OverrideWidenings::empty(),
            &BTreeSet::new(),
        );
        let dts = render_dts(
            &cls,
            &resolver,
            &enum_resolver,
            &protocol_resolver,
            &HashSet::new(),
            &OverrideWidenings::empty(),
            &BTreeSet::new(),
        );
        for name in [
            "widgetWithName_",
            "initWithName_",
            "length",
            "objectAtIndex_",
            "setLength_",
        ] {
            assert!(ts.contains(name), "the `.ts` implements {name}:\n{ts}");
            assert!(dts.contains(name), "the `.d.ts` declares {name}:\n{dts}");
        }
    }

    #[test]
    fn fallible_dts_declares_result_and_imports_it_type_only() {
        // ADR-0058 / ADR-0055 §2: the `.d.ts` declares the same `Result<T>` signature the
        // `.ts` implements (out-param dropped), importing `Result` type-only from the
        // runtime — and no runtime-seam helpers (those are `.ts`-only).
        let cls = Class {
            name: "NSData".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![method(
                "writeToFile:error:",
                false,
                vec![
                    param(
                        "path",
                        ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    ),
                    param("error", ty(TypeRefKind::Pointer)),
                ],
                ty(TypeRefKind::Primitive {
                    name: "bool".into(),
                }),
                None,
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let reg = ClassRegistry::new();
        let resolver = ClassModuleResolver::new("Foundation", &reg, Arc::new(reg.names()));
        let enum_reg = EnumRegistry::new();
        let enum_resolver = EnumModuleResolver::new("Foundation", &enum_reg, Arc::default());
        let proto_reg = ProtocolRegistry::new();
        let protocol_resolver =
            ProtocolModuleResolver::new("Foundation", &proto_reg, Arc::default());
        let errs: HashSet<String> = ["writeToFile:error:".to_string()].into_iter().collect();
        let out = render_dts(
            &cls,
            &resolver,
            &enum_resolver,
            &protocol_resolver,
            &errs,
            &OverrideWidenings::empty(),
            &BTreeSet::new(),
        );
        assert!(
            out.contains("writeToFile_error_(path: NSObject): Result<boolean>;"),
            "declaration-only Result<T> signature, out-param dropped:\n{out}"
        );
        assert!(
            out.contains("import type {\n  Result,\n} from '@apianyware/runtime';"),
            "Result imported type-only:\n{out}"
        );
        for seam in ["__dispatch", "__resultScalar", "__sel", "return "] {
            assert!(!out.contains(seam), "no `.ts`-only seam `{seam}`:\n{out}");
        }
    }

    #[test]
    fn dts_carries_the_implements_clause_and_type_only_import() {
        // The `.d.ts` header shares `class_header`, so the `implements` clause and its
        // type-only interface import appear identically to the `.ts` (ADR-0055 §2/§4).
        let mut cls = widget();
        cls.protocols = vec!["TKRefreshing".into()];
        let out = render_full(
            &cls,
            "TestKit",
            &ClassRegistry::new(),
            &[],
            &ProtocolRegistry::new(),
            &["TKRefreshing"],
        );
        assert!(
            out.contains("export class Widget extends NSObject implements TKRefreshing {"),
            "implements clause in the .d.ts header:\n{out}"
        );
        assert!(
            out.contains("import type {\n  TKRefreshing,\n} from '@apianyware/testkit';"),
            "interface imported type-only in the .d.ts:\n{out}"
        );
    }

    #[test]
    fn dts_tags_a_carved_out_deprecated_conformance_member() {
        // deprecated-protocol-member-policy-k111: the `.d.ts` declaration is where a
        // consumer's editor reads `@deprecated` from — the shared `deprecation_doc`
        // renders the tag identically to the `.ts`, so the pair cannot drift.
        let mut cls = widget();
        cls.name = "TKLocker".into();
        cls.protocols = vec!["TKLocking".to_string()];
        cls.methods = vec![Method {
            deprecated: true,
            ..method("lock", false, vec![], TypeRef::void(), None)
        }];
        let mut proto_reg = ProtocolRegistry::new();
        proto_reg.insert("TKLocking", "testkit");
        proto_reg.insert_conformance("TKLocking", vec![], [("lock".to_string(), false)]);
        let out = render_full(
            &cls,
            "TestKit",
            &ClassRegistry::new(),
            &[],
            &proto_reg,
            &["TKLocking"],
        );
        assert!(
            out.contains("export class TKLocker extends NSObject implements TKLocking {"),
            "the conformance stays promised in the .d.ts:\n{out}"
        );
        assert!(
            out.contains("/** @deprecated */\n  lock(): void;"),
            "the admitted member declares under the deprecation tag:\n{out}"
        );
    }
}
