//! The emitted **per-class overridable-method catalogue** (`static readonly __overridable`,
//! ADR-0059 §4, `emitted-subclass-surface-k96`) — the data a JS class needs to `extends` a bound
//! ObjC class: which of its OWN instance methods a subclass may override, and everything the
//! runtime's `__allocSubclass`/`this.$super` (`super.ts`) need to install and dispatch one.
//!
//! ## Why per class, never accumulated
//!
//! A class's catalogue is its **own** [`bound_methods`] instance frontier — never its ancestors' —
//! mirroring the k57 discipline every other per-class artifact follows (`bound_methods` is
//! explicitly "the class's own declared, bindable methods... inherited methods ride `extends`").
//! The runtime merges the WHOLE ancestor chain at use ([`super.ts`]'s `overridableCatalogue`,
//! walking `Object.getPrototypeOf` on constructors) — the mechanical dual of how `extends` itself
//! lets a subclass see its grandparent's methods with no re-declaration.
//!
//! ## The mirror invariant, closed for the THIRD inbound surface
//!
//! [`overridable_methods`] walks the *identical* frontier [`crate::inbound_table::collect_inbound_table`]
//! generates the native `aw_ts_super_*` table from — the same [`bound_methods`] instance set, the
//! same [`InboundSig::from_method`] admission test, the same [`method_retain_axis`] retain-fold
//! predicate feeding [`SuperEntry::name`]. So a `superEntry` this module emits always names a napi
//! entry the native side really registers (`awRegisterGeneratedSuperSends`); a method whose
//! signature falls outside the inbound alphabet (a geometry struct, a C string) is **omitted and
//! counted** ([`DeferredOverridable`]) rather than emitted as an uninstallable super-send — the k57
//! "defer nothing silently" posture, exactly as [`crate::delegate_spec`]'s deferred members are.
//!
//! ## Reuse, not re-derivation
//!
//! The value-kind classification is [`crate::delegate_spec::arg_kind`]/[`ret_kind`] **verbatim** —
//! not a fork. Those already read `method_retain_axis`, whose own doc names "the emitted call sites
//! and the `$super` entries" as its readers; this module is that reader materialising. The wire
//! vocabulary (`RAW`/`SEL`/`CLS`/`OBJ`/`RET_OBJ`/`RET_RAW`) is `marshal.ts`'s, imported by the
//! emitted class exactly as `delegates.ts` imports it — one runtime-facing spelling for a value kind,
//! regardless of which direction is converting it.

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::write_line;
use apianyware_types::ir::Class;
use std::collections::{BTreeSet, HashSet};

use crate::class_surface::bound_methods;
use crate::delegate_spec::{arg_kind, ret_kind};
use crate::emit_class::method_retain_axis;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::inbound_table::{InboundSig, SuperEntry};
use crate::naming::method_name;
use crate::protocol_graph::ProtocolRegistry;

/// One catalogued overridable instance method — the emitted literal object's fields (module doc).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OverridableEntry {
    pub name: String,
    pub selector: String,
    pub encoding: String,
    pub super_entry: String,
    pub args: Vec<&'static str>,
    pub ret: &'static str,
}

/// An own instance method whose signature falls outside the inbound alphabet (a geometry struct, a
/// C string) — omitted from the catalogue and counted, never emitted as an uninstallable
/// `superEntry` (module doc). Same shape as [`crate::inbound_table::DeferredInbound`] / the
/// delegate spec's [`crate::delegate_spec::DeferredSpecMethod`]; the k57 family.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DeferredOverridable {
    pub owner: String,
    pub selector: String,
}

/// `cls`'s own overridable-instance-method catalogue, in [`bound_methods`] order, plus what
/// deferred. Walks the identical frontier [`crate::inbound_table::collect_inbound_table`] does for
/// this class (module doc) — never a class's static methods (not installable instance IMPs) and
/// never an ancestor's (the runtime merges those at use).
pub fn overridable_methods(
    cls: &Class,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    protocol_registry: &ProtocolRegistry,
) -> (Vec<OverridableEntry>, Vec<DeferredOverridable>) {
    let (_statics, instances) = bound_methods(cls, mapper, error_selectors, protocol_registry);
    let mut methods = Vec::new();
    let mut deferred = Vec::new();
    for m in instances {
        let Some(sig) = InboundSig::from_method(m) else {
            deferred.push(DeferredOverridable {
                owner: cls.name.clone(),
                selector: m.selector.clone(),
            });
            continue;
        };
        let axis = method_retain_axis(m, mapper);
        let super_entry = SuperEntry {
            sig: sig.clone(),
            axis,
        }
        .name();
        methods.push(OverridableEntry {
            name: method_name(&m.selector),
            selector: m.selector.clone(),
            encoding: sig.type_encoding(),
            super_entry,
            args: m
                .params
                .iter()
                .map(|p| arg_kind(&p.param_type, mapper))
                .collect(),
            ret: ret_kind(m, mapper),
        });
    }
    (methods, deferred)
}

/// The runtime-seam **value** symbols an emitted `__overridable` catalogue needs, beyond
/// `OverridableMethod` (a type-only import, [`crate::imports::runtime_overridable_type_import`]):
/// exactly the `ArgKind`/`RetKind` constants the rendered entries reference, computed from the SAME
/// entries that get rendered — so the import block and the literal it accompanies cannot drift
/// (mirrors [`crate::delegate_spec::render_spec_imports`]'s kind collection). Empty for a class with
/// no catalogue (nothing rendered, nothing to import).
pub fn overridable_seam_symbols(methods: &[OverridableEntry]) -> BTreeSet<String> {
    let mut set = BTreeSet::new();
    for m in methods {
        set.extend(m.args.iter().map(|k| k.to_string()));
        set.insert(if m.ret.starts_with("RET_OBJ") {
            "RET_OBJ".to_string()
        } else {
            m.ret.to_string()
        });
    }
    set
}

/// Render `static readonly __overridable: readonly OverridableMethod[] = […];` — the class body's
/// literal catalogue, or nothing at all when `methods` is empty (a class with no overridable
/// instance method needs no static, exactly as a class with no static method needs no `__cls`).
pub fn render_overridable_static(w: &mut CodeWriter, methods: &[OverridableEntry]) {
    if methods.is_empty() {
        return;
    }
    w.line("static readonly __overridable: readonly OverridableMethod[] = [");
    w.indent();
    for m in methods {
        write_line!(
            w,
            "{{ name: '{}', selector: '{}', encoding: '{}', superEntry: '{}', args: [{}], ret: {} }},",
            m.name,
            m.selector,
            m.encoding,
            m.super_entry,
            m.args.join(", "),
            m.ret
        );
    }
    w.dedent();
    w.line("];");
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::naming::class_type_name;
    use apianyware_types::ir::{Method, Param};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};
    use std::sync::Arc;

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn param(name: &str, t: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type: t,
        }
    }

    fn method(
        selector: &str,
        class_method: bool,
        params: Vec<Param>,
        return_type: TypeRef,
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
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn class(name: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
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

    fn id() -> TypeRef {
        ty(TypeRefKind::Id {
            protocols: Vec::new(),
        })
    }

    fn nsinteger() -> TypeRef {
        ty(TypeRefKind::Primitive {
            name: "NSInteger".into(),
        })
    }

    fn mapper(classes: &[&str]) -> TsFfiTypeMapper {
        TsFfiTypeMapper::with_known_classes(Arc::new(
            classes.iter().map(|s| s.to_string()).collect(),
        ))
    }

    #[test]
    fn catalogues_own_instance_methods_and_carries_the_super_entry_the_table_generates() {
        // (id) -> NSInteger : q@:@ — the compare: shape (k37/k63 battery). `+0`-convention → the
        // plain FoldRetain entry name has no suffix; the retain-fold notion does not apply to a
        // scalar return, but this exercises the args/entry-name plumbing.
        let cls = class(
            "TKWidget",
            vec![method(
                "compare:",
                false,
                vec![param("other", id())],
                nsinteger(),
            )],
        );
        let mp = mapper(&[]);
        let (methods, deferred) =
            overridable_methods(&cls, &mp, &HashSet::new(), &ProtocolRegistry::new());
        assert!(deferred.is_empty());
        assert_eq!(methods.len(), 1);
        let m = &methods[0];
        assert_eq!(m.name, "compare_");
        assert_eq!(m.selector, "compare:");
        assert_eq!(m.encoding, "q@:@");
        // No retain axis on a scalar return — the plain code string, no `_o`/`_n` suffix.
        assert_eq!(m.super_entry, "aw_ts_super_P_q");
        assert_eq!(m.args, vec!["OBJ"]);
        assert_eq!(m.ret, "RET_RAW");
    }

    #[test]
    fn a_plus_one_object_return_names_the_non_folding_owned_sibling() {
        // -copyWithZone: — the `init`/`copy` family +1 convention (method_retain_axis::Owned).
        let cls = class(
            "TKWidget",
            vec![method("copyWithZone:", false, vec![param("z", id())], id())],
        );
        let mp = mapper(&[]);
        let (methods, _) =
            overridable_methods(&cls, &mp, &HashSet::new(), &ProtocolRegistry::new());
        assert_eq!(methods[0].super_entry, "aw_ts_super_P_P_o");
        assert_eq!(methods[0].ret, "RET_OBJ('owned')");
    }

    #[test]
    fn a_static_method_is_never_catalogued() {
        // Statics are not installable instance IMPs — only bound_methods' instance half feeds this.
        let cls = class(
            "TKWidget",
            vec![method(
                "widgetWithName:",
                true,
                vec![param("n", id())],
                id(),
            )],
        );
        let mp = mapper(&[]);
        let (methods, deferred) =
            overridable_methods(&cls, &mp, &HashSet::new(), &ProtocolRegistry::new());
        assert!(methods.is_empty());
        assert!(deferred.is_empty());
    }

    #[test]
    fn a_struct_param_is_admitted_ray_kind_and_its_own_super_entry() {
        // `inbound-struct-arg-surface-k123`: a geometry struct PARAM (the drawRect:/setFrame:
        // shape) now gets an installable inbound trampoline + `$super` entry — bound as an
        // ordinary catalogued method. Its value kind is RAW (`arg_kind`'s existing not-an-object
        // branch — unchanged by this widening: `PtrValue::of` is `None` for a struct and
        // `is_object_type` is `false`).
        let cls = class(
            "TKWidget",
            vec![method(
                "setFrame:",
                false,
                vec![param(
                    "f",
                    ty(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    }),
                )],
                TypeRef::void(),
            )],
        );
        let mp = mapper(&[]);
        let (methods, deferred) =
            overridable_methods(&cls, &mp, &HashSet::new(), &ProtocolRegistry::new());
        assert!(deferred.is_empty());
        assert_eq!(methods.len(), 1);
        let m = &methods[0];
        assert_eq!(m.name, "setFrame_");
        assert_eq!(m.encoding, "v@:{CGRect={CGPoint=dd}{CGSize=dd}}");
        assert_eq!(m.super_entry, "aw_ts_super_R_v");
        assert_eq!(m.args, vec!["RAW"]);
    }

    #[test]
    fn a_struct_return_still_defers_and_is_counted() {
        // A struct RETURN is bound OUTBOUND but still has no installable inbound trampoline
        // (`InboundSig::from_method` → None — the single-slot delivery-core limitation stays
        // out of scope for this widening) — omitted, never emitted as a superEntry the native
        // side would refuse. Same species as the IMP table's own deferrals.
        let cls = class(
            "TKWidget",
            vec![method(
                "frame",
                false,
                vec![],
                ty(TypeRefKind::Struct {
                    name: "CGRect".into(),
                }),
            )],
        );
        let mp = mapper(&[]);
        let (methods, deferred) =
            overridable_methods(&cls, &mp, &HashSet::new(), &ProtocolRegistry::new());
        assert!(methods.is_empty());
        assert_eq!(deferred.len(), 1);
        assert_eq!(deferred[0].owner, "TKWidget");
        assert_eq!(deferred[0].selector, "frame");
    }

    #[test]
    fn seam_symbols_are_computed_from_the_rendered_entries_never_assumed() {
        let cls = class(
            "TKWidget",
            vec![
                method("compare:", false, vec![param("o", id())], nsinteger()),
                method("copyWithZone:", false, vec![param("z", id())], id()),
                method("integerValue", false, vec![], nsinteger()),
            ],
        );
        let mp = mapper(&[]);
        let (methods, _) =
            overridable_methods(&cls, &mp, &HashSet::new(), &ProtocolRegistry::new());
        let seam = overridable_seam_symbols(&methods);
        let names: Vec<&str> = seam.iter().map(String::as_str).collect();
        assert_eq!(names, vec!["OBJ", "RET_OBJ", "RET_RAW"]);
    }

    #[test]
    fn an_empty_catalogue_renders_nothing() {
        let mut w = CodeWriter::new();
        render_overridable_static(&mut w, &[]);
        assert_eq!(w.finish(), "");
    }

    #[test]
    fn renders_one_literal_object_per_entry() {
        let cls = class(
            "TKWidget",
            vec![method(
                "compare:",
                false,
                vec![param("o", id())],
                nsinteger(),
            )],
        );
        let mp = mapper(&[]);
        let (methods, _) =
            overridable_methods(&cls, &mp, &HashSet::new(), &ProtocolRegistry::new());
        let mut w = CodeWriter::new();
        render_overridable_static(&mut w, &methods);
        let out = w.finish();
        assert!(out.contains("static readonly __overridable: readonly OverridableMethod[] = ["));
        assert!(out.contains(
            "{ name: 'compare_', selector: 'compare:', encoding: 'q@:@', superEntry: 'aw_ts_super_P_q', args: [OBJ], ret: RET_RAW },"
        ), "{out}");
        // Sanity: the class type name helper this module's caller uses stays importable here too.
        assert_eq!(class_type_name(&cls.name), "TKWidget");
    }
}
