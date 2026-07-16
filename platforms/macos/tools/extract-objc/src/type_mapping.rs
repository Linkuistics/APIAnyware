//! Mapping from libclang types to IR [`TypeRef`] values.
//!
//! Handles the full range of Objective-C types including id, instancetype,
//! class references, block types, pointers, primitives, structs, selectors,
//! and typedef aliases.

use clang::{Entity, Type, TypeKind};

use apianyware_types::type_ref::{TypeRef, TypeRefKind};

/// The declaration a type is being mapped for. Carried purely so a deferral can
/// name the declaration it came from — the lowering itself never reads it.
#[derive(Clone, Copy)]
pub struct TypeSite<'a> {
    /// Owning class / protocol / struct; empty for top-level functions and constants.
    pub owner: &'a str,
    /// Selector, property, function, constant or field name.
    pub member: &'a str,
}

impl<'a> TypeSite<'a> {
    pub fn new(owner: &'a str, member: &'a str) -> Self {
        Self { owner, member }
    }

    /// A top-level declaration (function, constant) with no owning type.
    pub fn top_level(member: &'a str) -> Self {
        Self { owner: "", member }
    }
}

/// A protocol qualifier the IR has nowhere to put, recorded rather than dropped.
///
/// `TypeRefKind::Id` models the qualifier because `id<P>` is where it overwhelmingly
/// occurs. Clang allows two other qualified positions — `Class<P>` and `NSFoo<P> *` —
/// and both lower to their unqualified selves. Those are a **counted deferral**, not a
/// modelling axis: they are named here and totalled in the extraction pass log, so a
/// future decision to model them starts from a measurement instead of a guess.
#[derive(Debug, Clone)]
pub struct DeferredQualifier {
    pub owner: String,
    pub member: String,
    /// The declared type, e.g. `Class<NSItemProviderReading>`.
    pub type_display: String,
    /// The protocols dropped from it.
    pub protocols: Vec<String>,
}

/// Everything a type-mapping pass records besides the types themselves.
#[derive(Debug, Default)]
pub struct TypeMapLog {
    pub deferred_qualifiers: Vec<DeferredQualifier>,
}

impl TypeMapLog {
    fn defer_qualifier(&mut self, site: TypeSite<'_>, ty: &Type<'_>, protocols: Vec<String>) {
        self.deferred_qualifiers.push(DeferredQualifier {
            owner: site.owner.to_string(),
            member: site.member.to_string(),
            type_display: ty.get_display_name(),
            protocols,
        });
    }
}

/// Check if a pointee type is `char` (i.e., the pointer is `char *` or
/// `const char *`). Only matches the `char` type itself (CharS on
/// signed-char platforms, CharU on unsigned-char platforms), not
/// `signed char` or `unsigned char` which are byte/integer types.
///
/// Callers must additionally check `pointee.is_const_qualified()` to
/// distinguish `const char *` (C input strings → `CString`) from
/// `char *` (output buffers → `Pointer`).
fn is_c_string_pointee(pointee: &Type<'_>) -> bool {
    matches!(pointee.get_kind(), TypeKind::CharS | TypeKind::CharU)
}

/// Map a libclang `Type` to our IR `TypeRef`.
///
/// `site` and `log` exist only for the deferral audit trail (see [`DeferredQualifier`]);
/// no lowering decision reads them.
pub fn map_type(clang_type: &Type<'_>, site: TypeSite<'_>, log: &mut TypeMapLog) -> TypeRef {
    let nullable = is_nullable(clang_type);
    let kind = map_type_kind(clang_type, site, log);
    TypeRef { nullable, kind }
}

/// Determine if a type has a `_Nullable` annotation.
fn is_nullable(clang_type: &Type<'_>) -> bool {
    matches!(
        clang_type.get_nullability(),
        Some(clang::Nullability::Nullable)
    )
}

/// Map the inner type kind.
fn map_type_kind(clang_type: &Type<'_>, site: TypeSite<'_>, log: &mut TypeMapLog) -> TypeRefKind {
    match clang_type.get_kind() {
        // ObjC object pointer: could be id, instancetype, or a specific class
        TypeKind::ObjCObjectPointer => map_objc_object_pointer(clang_type, site, log),

        // ObjC id type (unqualified)
        TypeKind::ObjCId => TypeRefKind::Id {
            protocols: Vec::new(),
        },

        // instancetype
        TypeKind::ObjCTypeParam => {
            // Check if this is instancetype
            let spelling = clang_type.get_display_name();
            if spelling == "instancetype" {
                TypeRefKind::Instancetype
            } else {
                TypeRefKind::Id {
                    protocols: Vec::new(),
                }
            }
        }

        // ObjC Class type
        TypeKind::ObjCClass => TypeRefKind::ClassRef,

        // ObjC SEL type
        TypeKind::ObjCSel => TypeRefKind::Selector,

        // Block pointer
        TypeKind::BlockPointer => map_block_type(clang_type, site, log),

        // C pointer types: function pointer, C string, or generic pointer
        TypeKind::Pointer => {
            if let Some(pointee) = clang_type.get_pointee_type() {
                if pointee.get_kind() == TypeKind::FunctionPrototype {
                    return map_function_pointer_type(&pointee, None, site, log);
                }
                // Only const char * → CString (input strings).
                // Non-const char * is an output buffer — must stay as Pointer
                // so callers can pass malloc'd memory and read back results.
                if is_c_string_pointee(&pointee) && pointee.is_const_qualified() {
                    return TypeRefKind::CString;
                }
            }
            TypeRefKind::Pointer
        }

        // Typedef (alias)
        TypeKind::Typedef => map_typedef(clang_type, site, log),

        // Elaborated types (e.g., `struct NSPoint`)
        TypeKind::Elaborated => {
            if let Some(named) = clang_type.get_elaborated_type() {
                map_type_kind(&named, site, log)
            } else {
                TypeRefKind::Pointer
            }
        }

        // Record (struct)
        TypeKind::Record => {
            let name = clang_type.get_display_name();
            TypeRefKind::Struct { name }
        }

        // Enum
        TypeKind::Enum => {
            let name = clang_type.get_display_name();
            TypeRefKind::Alias {
                name,
                framework: None,
                underlying_primitive: enum_underlying_primitive(clang_type),
            }
        }

        // Primitive types
        TypeKind::Void => TypeRefKind::Primitive {
            name: "void".to_string(),
        },
        TypeKind::Bool
        | TypeKind::CharS
        | TypeKind::CharU
        | TypeKind::SChar
        | TypeKind::UChar
        | TypeKind::Short
        | TypeKind::UShort
        | TypeKind::Int
        | TypeKind::UInt
        | TypeKind::Long
        | TypeKind::ULong
        | TypeKind::LongLong
        | TypeKind::ULongLong
        | TypeKind::Float
        | TypeKind::Double
        | TypeKind::LongDouble => TypeRefKind::Primitive {
            name: map_primitive_name(clang_type),
        },

        // Incomplete array
        TypeKind::IncompleteArray => TypeRefKind::Pointer,

        // Constant array
        TypeKind::ConstantArray => TypeRefKind::Pointer,

        // Attributed type (e.g., with nullability attributes)
        TypeKind::Attributed => {
            if let Some(modified) = clang_type.get_modified_type() {
                map_type_kind(&modified, site, log)
            } else {
                TypeRefKind::Pointer
            }
        }

        // ObjC interface (the type of the class itself, not a pointer to it)
        TypeKind::ObjCInterface => {
            let name = clang_type.get_display_name();
            TypeRefKind::Class {
                name,
                framework: None,
                params: Vec::new(),
            }
        }

        // Fallback for unhandled types
        _other => {
            tracing::debug!(
                type_kind = ?_other,
                spelling = %clang_type.get_display_name(),
                "unhandled type kind, mapping to pointer"
            );
            TypeRefKind::Pointer
        }
    }
}

/// Map an ObjC object pointer to the appropriate IR type.
///
/// The pointee kind is the discriminator, and it is **not** `ObjCInterface` as often
/// as it looks: libclang reports an `ObjCObject` pointee the moment the type carries
/// any refinement — a protocol qualifier (`id<P>`, `NSView<P> *`), a generic argument
/// (`NSArray<NSString *> *`), or `__kindof`. A bare `NSString *` is the only shape that
/// reaches `ObjCInterface`.
fn map_objc_object_pointer(
    clang_type: &Type<'_>,
    site: TypeSite<'_>,
    log: &mut TypeMapLog,
) -> TypeRefKind {
    let pointee = match clang_type.get_pointee_type() {
        Some(p) => p,
        None => {
            return TypeRefKind::Id {
                protocols: Vec::new(),
            }
        }
    };

    match pointee.get_kind() {
        // A bare class pointer: `NSString *`. Cannot carry generic arguments — a
        // pointee that has them is `ObjCObject`, handled below.
        TypeKind::ObjCInterface => TypeRefKind::Class {
            name: pointee.get_display_name(),
            framework: None,
            params: Vec::new(),
        },

        // A refined object type. Its base says which of the three it is.
        TypeKind::ObjCObject => map_objc_object(clang_type, &pointee, site, log),

        TypeKind::ObjCId => TypeRefKind::Id {
            protocols: Vec::new(),
        },
        TypeKind::ObjCClass => TypeRefKind::ClassRef,

        _ => {
            let display = clang_type.get_display_name();
            if display == "instancetype" {
                TypeRefKind::Instancetype
            } else {
                TypeRefKind::Id {
                    protocols: Vec::new(),
                }
            }
        }
    }
}

/// Map an `ObjCObject` pointee — an `id`, a `Class`, or a class pointer, refined by a
/// protocol qualifier, generic arguments, or `__kindof`.
///
/// The base — what the refinement refines — decides the shape: `ObjCId` → `Id { protocols }`
/// (the qualifier is modelled directly); `ObjCInterface` → `Class { name, params }`, its base
/// class recovered and any generic type arguments read off the *pointee* and mapped
/// recursively; `ObjCClass` → `ClassRef`, the metatype recovered. `__kindof` needs no
/// separate handling — libclang reports the same `ObjCObject`/base pair for `__kindof NSView *`
/// as for any other refined `NSView` pointer, and `__kindof` only relaxes assignability, not
/// identity, so `Class { name: "NSView", .. }` is the honest lowering either way.
///
/// A protocol qualifier on a non-`Id` base (`NSFoo<P> *`, `Class<P>`) is not a modelling axis
/// `Class`/`ClassRef` can hold — the IR still has nowhere to put it, so it is **counted, not
/// dropped**: recorded in `log` with the declaration it came from, exactly as before this
/// change. What moves here is the base class, no longer erased alongside the qualifier.
fn map_objc_object(
    pointer: &Type<'_>,
    pointee: &Type<'_>,
    site: TypeSite<'_>,
    log: &mut TypeMapLog,
) -> TypeRefKind {
    let protocols: Vec<String> = pointee
        .get_objc_protocol_declarations()
        .iter()
        .filter_map(Entity::get_name)
        .collect();

    // The base is what the refinement refines. Read it — like the protocols above — off the
    // *pointee*: both accessors return empty when handed the pointer.
    let base = pointee.get_objc_object_base_type();
    let base_kind = base.as_ref().map(Type::get_kind);

    if base_kind == Some(TypeKind::ObjCId) {
        return TypeRefKind::Id { protocols };
    }

    if !protocols.is_empty() {
        log.defer_qualifier(site, pointer, protocols);
    }

    match base_kind {
        Some(TypeKind::ObjCInterface) => {
            let params: Vec<TypeRef> = pointee
                .get_objc_type_arguments()
                .iter()
                .map(|arg| map_type(arg, site, log))
                .collect();
            TypeRefKind::Class {
                name: base.expect("ObjCInterface base is Some").get_display_name(),
                framework: None,
                params,
            }
        }
        Some(TypeKind::ObjCClass) => TypeRefKind::ClassRef,
        // No base at all (rare/unknown refinement shape) keeps the pre-existing `id` erasure.
        _ => TypeRefKind::Id {
            protocols: Vec::new(),
        },
    }
}

/// Map a block pointer type to a Block TypeRef.
fn map_block_type(clang_type: &Type<'_>, site: TypeSite<'_>, log: &mut TypeMapLog) -> TypeRefKind {
    let pointee = match clang_type.get_pointee_type() {
        Some(p) => p,
        None => {
            return TypeRefKind::Block {
                params: Vec::new(),
                return_type: Box::new(TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "void".to_string(),
                    },
                }),
            };
        }
    };

    let return_type = match pointee.get_result_type() {
        Some(rt) => Box::new(map_type(&rt, site, log)),
        None => Box::new(TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        }),
    };

    let arg_types = pointee.get_argument_types().unwrap_or_default();
    let params: Vec<TypeRef> = arg_types.iter().map(|t| map_type(t, site, log)).collect();

    TypeRefKind::Block {
        params,
        return_type,
    }
}

/// Map a typedef to either a known special type or an alias.
fn map_typedef(clang_type: &Type<'_>, site: TypeSite<'_>, log: &mut TypeMapLog) -> TypeRefKind {
    let name = clang_type.get_display_name();

    // Check for well-known ObjC typedefs
    match name.as_str() {
        "instancetype" => return TypeRefKind::Instancetype,
        "id" => {
            return TypeRefKind::Id {
                protocols: Vec::new(),
            }
        }
        "Class" => return TypeRefKind::ClassRef,
        "SEL" => return TypeRefKind::Selector,
        // ObjC BOOL and Carbon Boolean (unsigned char used as boolean).
        // Without this, Boolean resolves to uint8 and Racket treats 0 as
        // truthy (only #f is falsy), silently breaking boolean-context usage.
        "BOOL" | "Boolean" => {
            return TypeRefKind::Primitive {
                name: "bool".to_string(),
            }
        }
        "NSInteger" => {
            return TypeRefKind::Primitive {
                name: "int64".to_string(),
            }
        }
        "NSUInteger" => {
            return TypeRefKind::Primitive {
                name: "uint64".to_string(),
            }
        }
        "CGFloat" => {
            return TypeRefKind::Primitive {
                name: "double".to_string(),
            }
        }
        "NSTimeInterval" => {
            return TypeRefKind::Primitive {
                name: "double".to_string(),
            }
        }
        _ => {}
    }

    // Resolve the canonical (underlying) type to determine the true FFI type.
    // This handles typedefs like NSImageName (typedef NSString *) which should
    // map to _id, not _uint64.
    let canonical = clang_type.get_canonical_type();
    match canonical.get_kind() {
        TypeKind::BlockPointer => map_block_type(&canonical, site, log),

        // Object pointer typedefs (NSImageName → NSString *, etc.) → resolve to id/class
        TypeKind::ObjCObjectPointer => map_objc_object_pointer(&canonical, site, log),

        // Pointer typedefs: function pointer, C string, or generic pointer
        TypeKind::Pointer => {
            if let Some(pointee) = canonical.get_pointee_type() {
                if pointee.get_kind() == TypeKind::FunctionPrototype {
                    return map_function_pointer_type(&pointee, Some(name), site, log);
                }
                if is_c_string_pointee(&pointee) && pointee.is_const_qualified() {
                    return TypeRefKind::CString;
                }
            }
            TypeRefKind::Pointer
        }

        // Struct typedefs (NSRect → CGRect, CFDictionaryKeyCallBacks, etc.)
        // → Struct with the typedef name. The FFI mapper's geometry struct
        // detection works on both Struct and Alias names, and is_struct_data_symbol
        // needs Struct to correctly emit ffi-obj-ref for struct-typed globals.
        TypeKind::Record => TypeRefKind::Struct { name },

        // Enum typedefs (NSBezelStyle, etc.) → keep as Alias so emitters can
        // translate to their target language's enum-like type, but carry
        // the underlying primitive so FFI mappers pick the right fixed
        // width (e.g. CF_ENUM(uint32_t, AXValueType) → _uint32, not the
        // historical _uint64 default).
        TypeKind::Enum => TypeRefKind::Alias {
            name,
            framework: None,
            underlying_primitive: enum_underlying_primitive(&canonical),
        },

        // Integer/float typedefs not caught by the well-known check above
        // (e.g., int64_t, uint32_t, FourCharCode) → resolve to primitive
        TypeKind::Bool
        | TypeKind::CharS
        | TypeKind::CharU
        | TypeKind::SChar
        | TypeKind::UChar
        | TypeKind::Short
        | TypeKind::UShort
        | TypeKind::Int
        | TypeKind::UInt
        | TypeKind::Long
        | TypeKind::ULong
        | TypeKind::LongLong
        | TypeKind::ULongLong
        | TypeKind::Float
        | TypeKind::Double
        | TypeKind::LongDouble => TypeRefKind::Primitive {
            name: map_primitive_name(&canonical),
        },

        // Everything else (uncommon typedefs) → keep as Alias
        _ => TypeRefKind::Alias {
            name,
            framework: None,
            underlying_primitive: None,
        },
    }
}

/// Resolve an enum's underlying integer type to a canonical primitive
/// name (e.g. `"uint32"`, `"int64"`, `"bool"`). Returns `None` if the
/// type has no declaration or no underlying type (should not happen for
/// well-formed enum typedefs in Apple SDK headers).
///
/// Canonicalizes through typedef wrappers: `CF_ENUM(UInt32, ...)`
/// reports `UInt32` as the underlying type, which is itself a typedef
/// for `unsigned int`. Without `get_canonical_type()` we get `"UInt32"`
/// (the typedef name) rather than `"uint32"`; downstream FFI mappers
/// only understand the canonical primitive names.
fn enum_underlying_primitive(enum_type: &Type<'_>) -> Option<String> {
    let underlying = enum_type
        .get_declaration()?
        .get_enum_underlying_type()?
        .get_canonical_type();
    Some(map_primitive_name(&underlying))
}

/// Map a `FunctionPrototype` clang type to a `FunctionPointer` TypeRefKind.
///
/// Extracts the return type and all parameter types from the function prototype.
/// The optional `name` carries the typedef name (e.g., `"CGEventTapCallBack"`)
/// when the function pointer was reached through a typedef; absent for anonymous
/// function pointers in parameter positions.
fn map_function_pointer_type(
    func_type: &Type<'_>,
    name: Option<String>,
    site: TypeSite<'_>,
    log: &mut TypeMapLog,
) -> TypeRefKind {
    let return_type = match func_type.get_result_type() {
        Some(rt) => Box::new(map_type(&rt, site, log)),
        None => Box::new(TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        }),
    };

    let arg_types = func_type.get_argument_types().unwrap_or_default();
    let params: Vec<TypeRef> = arg_types.iter().map(|t| map_type(t, site, log)).collect();

    TypeRefKind::FunctionPointer {
        name,
        params,
        return_type,
    }
}

/// Map primitive C types to consistent Go-compatible names
/// to match the POC output format.
fn map_primitive_name(clang_type: &Type<'_>) -> String {
    match clang_type.get_kind() {
        TypeKind::Bool => "bool".to_string(),
        TypeKind::CharS | TypeKind::CharU | TypeKind::SChar => "int8".to_string(),
        TypeKind::UChar => "uint8".to_string(),
        TypeKind::Short => "int16".to_string(),
        TypeKind::UShort => "uint16".to_string(),
        TypeKind::Int => "int32".to_string(),
        TypeKind::UInt => "uint32".to_string(),
        // On macOS arm64: long is 64-bit
        TypeKind::Long => "int64".to_string(),
        TypeKind::ULong => "uint64".to_string(),
        TypeKind::LongLong => "int64".to_string(),
        TypeKind::ULongLong => "uint64".to_string(),
        TypeKind::Float => "float".to_string(),
        TypeKind::Double | TypeKind::LongDouble => "double".to_string(),
        _ => clang_type.get_display_name(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    use std::sync::LazyLock;

    use clang::{Clang, EntityKind, Index};

    /// Every shape whose pointee libclang reports as `ObjCObject` — a protocol
    /// qualifier, a generic argument, `__kindof` — plus the two that reach
    /// `ObjCInterface` / `ObjCId`, so the discriminator is pinned by test and not
    /// by belief.
    const HEADER: &str = r#"
@protocol NSCopying @end
@protocol NSCoding @end
@interface NSObject @end
@interface NSString : NSObject @end
@interface NSArray<ObjectType> : NSObject
- (void)acceptSameGeneric:(NSArray<ObjectType> *)other;
@end

@interface Probe : NSObject
- (void)plainId:(id)a;
- (void)qualifiedId:(id<NSCopying>)a;
- (void)multiQualifiedId:(id<NSCopying, NSCoding>)a;
- (void)qualifiedClass:(Class<NSCopying>)a;
- (void)qualifiedInterface:(NSObject<NSCopying> *)a;
- (void)genericInterface:(NSArray<NSString *> *)a;
- (void)qualifiedGenericInterface:(NSArray<NSString *><NSCopying> *)a;
- (void)kindofInterface:(__kindof NSObject *)a;
- (void)plainInterface:(NSString *)a;
@end
"#;

    /// The probe's lowering, computed once: libclang's `Clang` is a
    /// process-wide singleton, so the unit tests — which share one process,
    /// unlike the per-binary integration tests — cannot each build their own.
    static PROBE: LazyLock<(Vec<(String, TypeRefKind)>, TypeMapLog)> =
        LazyLock::new(map_probe_params);

    /// Map every `Probe` selector's single parameter, returning the lowering and
    /// whatever the pass recorded.
    fn map_probe_params() -> (Vec<(String, TypeRefKind)>, TypeMapLog) {
        let dir = std::env::temp_dir().join("apianyware_extract_objc_type_mapping_test");
        std::fs::create_dir_all(&dir).expect("temp dir");
        let header = dir.join("probe.h");
        std::fs::write(&header, HEADER).expect("write probe header");

        let clang = Clang::new().expect("libclang");
        let index = Index::new(&clang, false, true);
        let tu = index
            .parser(&header)
            .arguments(&["-x", "objective-c", "-w"])
            .parse()
            .expect("parse probe header");

        let mut log = TypeMapLog::default();
        let mut mapped = Vec::new();

        fn visit(
            entity: &clang::Entity<'_>,
            mapped: &mut Vec<(String, TypeRefKind)>,
            log: &mut TypeMapLog,
        ) {
            if entity.get_kind() == EntityKind::ObjCInstanceMethodDecl {
                let selector = entity.get_name().unwrap_or_default();
                for child in entity.get_children() {
                    if child.get_kind() == EntityKind::ParmDecl {
                        if let Some(t) = child.get_type() {
                            let site = TypeSite::new("Probe", &selector);
                            mapped.push((selector.clone(), map_type(&t, site, log).kind));
                        }
                    }
                }
            }
            for child in entity.get_children() {
                visit(&child, mapped, log);
            }
        }
        visit(&tu.get_entity(), &mut mapped, &mut log);

        (mapped, log)
    }

    fn kind_of<'a>(mapped: &'a [(String, TypeRefKind)], selector: &str) -> &'a TypeRefKind {
        mapped
            .iter()
            .find(|(s, _)| s == selector)
            .map(|(_, k)| k)
            .unwrap_or_else(|| panic!("selector {selector} not mapped"))
    }

    #[test]
    fn qualified_id_carries_its_protocol() {
        let (mapped, _) = &*PROBE;
        match kind_of(mapped, "qualifiedId:") {
            TypeRefKind::Id { protocols } => assert_eq!(protocols, &["NSCopying"]),
            other => panic!("expected a qualified Id, got {other:?}"),
        }
    }

    /// `id<NSCopying, NSCoding>` is legal, so the qualifier is a list — in
    /// declaration order.
    #[test]
    fn multi_qualified_id_carries_every_protocol_in_order() {
        let (mapped, _) = &*PROBE;
        match kind_of(mapped, "multiQualifiedId:") {
            TypeRefKind::Id { protocols } => assert_eq!(protocols, &["NSCopying", "NSCoding"]),
            other => panic!("expected a qualified Id, got {other:?}"),
        }
    }

    #[test]
    fn plain_id_stays_unqualified() {
        let (mapped, _) = &*PROBE;
        match kind_of(mapped, "plainId:") {
            TypeRefKind::Id { protocols } => assert!(protocols.is_empty()),
            other => panic!("expected a bare Id, got {other:?}"),
        }
    }

    #[test]
    fn plain_class_pointer_still_lowers_to_its_class() {
        let (mapped, _) = &*PROBE;
        match kind_of(mapped, "plainInterface:") {
            TypeRefKind::Class { name, params, .. } => {
                assert_eq!(name, "NSString");
                assert!(params.is_empty());
            }
            other => panic!("expected Class{{NSString}}, got {other:?}"),
        }
    }

    /// A protocol-qualified `Class<P>` and a protocol-qualified interface pointer both
    /// recover their base — `objc-object-type-lowering-k85`'s repair — while the
    /// qualifier itself stays a position the IR cannot hold: **counted, not dropped**,
    /// exactly as before this change.
    #[test]
    fn qualifier_on_class_and_on_interface_recovers_the_base_and_still_defers_the_qualifier() {
        let (mapped, log) = &*PROBE;

        match kind_of(mapped, "qualifiedClass:") {
            TypeRefKind::ClassRef => {}
            other => panic!("expected the Class<P> metatype recovered as ClassRef, got {other:?}"),
        }
        match kind_of(mapped, "qualifiedInterface:") {
            TypeRefKind::Class { name, params, .. } => {
                assert_eq!(name, "NSObject");
                assert!(params.is_empty());
            }
            other => panic!("expected Class{{NSObject}} recovered, got {other:?}"),
        }

        let deferred: Vec<_> = log
            .deferred_qualifiers
            .iter()
            .filter(|d| d.member == "qualifiedClass:" || d.member == "qualifiedInterface:")
            .map(|d| (d.member.as_str(), d.protocols.clone()))
            .collect();
        assert_eq!(
            deferred,
            vec![
                ("qualifiedClass:", vec!["NSCopying".to_string()]),
                ("qualifiedInterface:", vec!["NSCopying".to_string()]),
            ],
            "both deferrals are still recorded, with the selector they came from"
        );
        assert!(
            log.deferred_qualifiers.iter().all(|d| d.owner == "Probe"),
            "a deferral names its owner"
        );
    }

    /// A generic class pointer recovers its base class *and* its type arguments,
    /// each mapped recursively — `NSArray<NSString *> *` reaches the IR as
    /// `Class{NSArray, params:[Class{NSString}]}`, not a bare `id`. No protocol
    /// qualifier was declared, so nothing is deferred.
    #[test]
    fn generic_class_pointer_recovers_its_base_and_its_type_arguments() {
        let (mapped, log) = &*PROBE;
        match kind_of(mapped, "genericInterface:") {
            TypeRefKind::Class { name, params, .. } => {
                assert_eq!(name, "NSArray");
                match params.as_slice() {
                    [TypeRef {
                        kind: TypeRefKind::Class { name, params, .. },
                        ..
                    }] => {
                        assert_eq!(name, "NSString");
                        assert!(params.is_empty());
                    }
                    other => panic!("expected a single Class{{NSString}} type argument, got {other:?}"),
                }
            }
            other => panic!("expected Class{{NSArray, params:[NSString]}}, got {other:?}"),
        }
        assert!(
            !log.deferred_qualifiers
                .iter()
                .any(|d| d.member == "genericInterface:"),
            "no qualifier was declared, so nothing was deferred"
        );
    }

    /// A generic argument and a protocol qualifier together (`NSArray<NSString *><NSCopying> *`)
    /// recover the base and its type arguments *and* still defer the qualifier — the two axes
    /// are independent, so satisfying one must not silently drop the other.
    #[test]
    fn generic_and_qualified_interface_recovers_params_and_still_defers_the_qualifier() {
        let (mapped, log) = &*PROBE;
        match kind_of(mapped, "qualifiedGenericInterface:") {
            TypeRefKind::Class { name, params, .. } => {
                assert_eq!(name, "NSArray");
                assert_eq!(params.len(), 1);
            }
            other => panic!("expected Class{{NSArray, params:[NSString]}}, got {other:?}"),
        }
        assert!(
            log.deferred_qualifiers
                .iter()
                .any(|d| d.member == "qualifiedGenericInterface:"
                    && d.protocols == vec!["NSCopying".to_string()]),
            "the qualifier is still counted even though the base and its type argument recovered"
        );
    }

    /// `__kindof NSObject *` needs no special-casing: libclang reports the same
    /// `ObjCObject` pointee / `ObjCInterface` base as any other refined `NSObject`
    /// pointer, and `__kindof` only relaxes assignability, not identity — so the base
    /// dispatch alone lowers it to `Class{NSObject}`, the honest lowering either way.
    #[test]
    fn kindof_interface_lowers_to_its_base_class_via_the_same_dispatch() {
        let (mapped, _) = &*PROBE;
        match kind_of(mapped, "kindofInterface:") {
            TypeRefKind::Class { name, params, .. } => {
                assert_eq!(name, "NSObject");
                assert!(params.is_empty());
            }
            other => panic!("expected Class{{NSObject}}, got {other:?}"),
        }
    }

    /// A generic argument that is itself an unspecialized `ObjCTypeParam` — `ObjectType`
    /// used bare inside `NSArray<ObjectType>`'s own declaration, not a concrete class —
    /// is not a `Class`. It falls through the existing `TypeKind::ObjCTypeParam` arm to
    /// `Id{protocols:[]}`, the same total fallback every other unresolvable type-parameter
    /// position already gets; `Class.params` is not restricted to `Class` entries.
    #[test]
    fn self_referential_generic_argument_lowers_its_type_param_to_id() {
        let (mapped, _) = &*PROBE;
        match kind_of(mapped, "acceptSameGeneric:") {
            TypeRefKind::Class { name, params, .. } => {
                assert_eq!(name, "NSArray");
                match params.as_slice() {
                    [TypeRef {
                        kind: TypeRefKind::Id { protocols },
                        ..
                    }] => assert!(protocols.is_empty()),
                    other => panic!("expected a single Id type argument, got {other:?}"),
                }
            }
            other => panic!("expected Class{{NSArray, params:[Id]}}, got {other:?}"),
        }
    }
}
