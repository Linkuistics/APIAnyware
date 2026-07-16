//! Which methods the TypeScript emitter can bind — the bindable **frontier**.
//!
//! A conservative first pass (this scaffold leaf), mirroring the scheme/sbcl
//! filters' discipline: bind the methods whose whole signature reduces to types
//! the emitted class body + `.d.ts` can already express, and **defer** the rest
//! until the leaf that adds their machinery. Deferred here:
//!
//! - **variadic**, **deprecated**, and **Swift-paren** selectors (`data(from:)` —
//!   a Swift-native residual whose call shape is not the ObjC `msgSend` path);
//! - **raw / function pointers** by param or return (no idiomatic TS surface) — **except** the
//!   narrow, hand-verified [`ADMITTED_OPAQUE_POINTER_FUNCTIONS`]/[`ADMITTED_OPAQUE_POINTER_METHODS`]
//!   carve-out (`coregraphics-context-function-surface-k124`): a `CGContextRef` handle, which
//!   crosses as an opaque `bigint` (never wrapped) between `NSGraphicsContext.CGContext()` and the
//!   direct-C CoreGraphics drawing functions;
//! - **non-geometry structs by value** (population-A geometry is supported as a
//!   plain by-value object; population-B Swift value structs — branded handle
//!   classes — are re-admitted once the declaration's `objc_exposed` is in scope,
//!   a later leaf);
//! - **blocks** by param or return — the general typed callback/delegate bridging is
//!   ADR-0059, a dedicated later leaf; until then a block-carrying method defers,
//!   **except** the narrow, hand-verified [`ADMITTED_COMPLETION_HANDLER_SELECTORS`]
//!   carve-out (`block-call-site-emission-k120`): a genuinely *escaping* completion
//!   handler whose block shape was checked by hand against the IR, not pattern-matched.
//!   A block-typed **return** always defers — no carve-out reaches it.
//! - **Swift nominal types** ([`swift_nominal_deferral`]) — a `.swiftinterface`-sourced decl
//!   naming a `Class{…}` the IR does not declare. It is not an object at all (a tuple, a key
//!   path, a value type), so it can be neither wrapped nor imported; the whole member defers.
//!   Unlike the frontiers above this is **permanent**, not a machinery gap: `Tuple` will never
//!   be bindable through `objc_msgSend`. The rule, and why an *ObjC*-sourced unbound class
//!   degrades rather than defers, are in [`crate::class_binding`].
//!
//! `emit-class` widens this frontier (blocks, value structs); the **`NSError**`
//! error-out** case is re-admitted by [`is_supported_method_ctx`] (ADR-0058, the
//! `error-model` leaf) — a fallible `…error:` selector whose *visible* signature (params
//! minus the trailing `NSError**` cell) is bindable emits a `Result<T>`, so the trailing
//! error pointer is permitted while any *other* raw pointer still defers. Keeping the
//! deferral explicit and counted is the honest posture (no silent narrowing).

use std::collections::HashSet;

use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_types::ir::{Function, Method, Param};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_binding::deferred_class;
use crate::ffi_type_mapping::{is_geometry_struct, TsFfiTypeMapper};
use crate::native_dispatch::NativeSig;
use crate::ptr_value::PtrValue;

/// True when the emitter can bind `method` with the machinery present so far.
/// Deferrals are documented at the module level; each is a frontier a later leaf
/// widens, never a permanent exclusion.
pub fn is_supported_method(method: &Method, mapper: &TsFfiTypeMapper) -> bool {
    !method.deprecated && is_supported_method_modulo_deprecation(method, mapper)
}

/// Every gate of [`is_supported_method`] **except** the deprecation exclusion. Exists for
/// exactly one caller: the deprecated-conformance carve-out
/// ([`crate::class_surface::bound_methods`], ADR-0055 §4b) must ask "is deprecation the
/// *sole* blocker?" — a deprecated method that would also defer on its signature stays
/// deferred, carve-out or not.
pub fn is_supported_method_modulo_deprecation(method: &Method, mapper: &TsFfiTypeMapper) -> bool {
    if method.variadic || method.selector.contains('(') {
        return false;
    }
    if swift_nominal_deferral(method, mapper).is_some() {
        return false;
    }
    if is_block(&method.return_type) {
        return false;
    }
    if has_block(&method.params) && !is_admitted_completion_handler(method) {
        return false;
    }
    if has_unsupported_struct(&method.params, mapper)
        || is_unsupported_struct(&method.return_type, mapper)
    {
        return false;
    }
    if (has_raw_pointer(&method.params) || is_raw_pointer(&method.return_type))
        && !is_admitted_opaque_pointer_method(method)
    {
        return false;
    }
    // ABI routability is the FINAL gate — the filter/dispatch agreement invariant made
    // structural (outbound-dispatch-table-k58): an admitted method must have a dispatch
    // signature, or the emitted call site would name an entry no table can provide. The
    // real corpus's residual here is the simd/vector alias family (`simd_float3`,
    // `vector_float2`, …) — aliases with no static ABI shape the structural checks above
    // cannot see; they defer exactly like non-geometry structs (a later `emit-simd` leaf
    // could widen this).
    NativeSig::from_method(method).is_some()
}

/// The **Swift-nominal-type** name this method defers on, or `None` when every `Class{…}` in
/// its signature binds or degrades ([`crate::class_binding`]). Exposed so the table collectors
/// can *count* the deferral by owner + selector + name — the k57 "defer nothing silently"
/// discipline — rather than merely observing the method's absence.
///
/// The `.swiftinterface` extractor lowers every Swift nominal type to `TypeRefKind::Class`, so
/// `NEPacketTunnelFlow.readPackets(): Tuple` reaches the emitter looking exactly like an object
/// return. It is not one: `objc_retain` on a tuple is undefined behaviour, and no module can
/// export a `Tuple` to import. The member therefore defers, whole.
pub fn swift_nominal_deferral<'m>(method: &'m Method, mapper: &TsFfiTypeMapper) -> Option<&'m str> {
    deferred_class(
        method.source,
        std::iter::once(&method.return_type).chain(method.params.iter().map(|p| &p.param_type)),
        mapper,
    )
}

/// The free-function dual of [`swift_nominal_deferral`] — the same gate over a `Function`'s own
/// [`DeclarationSource`](apianyware_types::provenance::DeclarationSource), so the direct-C stream
/// defers on a Swift nominal exactly as the method stream does. (The **Swift-native residual**
/// stream reaches the same conclusion by a different route: `classify_function` already gates its
/// object return on IR-declared-class membership — `swift-residual-cli-pass-k65`.)
pub fn function_swift_nominal_deferral<'f>(
    function: &'f Function,
    mapper: &TsFfiTypeMapper,
) -> Option<&'f str> {
    deferred_class(
        function.source,
        std::iter::once(&function.return_type).chain(function.params.iter().map(|p| &p.param_type)),
        mapper,
    )
}

/// Whether a method routes to the **`NSError**` out-param** path (ADR-0058): its selector
/// is in the class's enrichment-derived `error_selectors` set
/// ([`apianyware_emit::enrichment::class_error_selectors`], the same cross-target source of
/// truth racket/gerbil/sbcl key on) **and** its trailing param is a raw
/// [`TypeRefKind::Pointer`] — the `NSError**` cell the extractor keeps no identity for
/// (so the selector set is what disambiguates it from any other `T**` out-param). The TS
/// surface differs from the CL targets (a type-visible `Result<T>`, not a signalled
/// condition), but the *bindability* question is identical: the trailing error pointer is
/// permitted while any other visible raw pointer still defers.
pub fn is_error_out_method(method: &Method, error_selectors: &HashSet<String>) -> bool {
    error_selectors.contains(&method.selector)
        && matches!(
            method.params.last().map(|p| &p.param_type.kind),
            Some(TypeRefKind::Pointer)
        )
}

/// Supportedness honouring **`NSError**` out-param** routing (ADR-0058). An error-out
/// method ([`is_error_out_method`]) is bindable when its **visible** signature (params
/// minus the trailing `NSError**` cell) is *both* expressible in the class body/`.d.ts`
/// ([`is_supported_method`] over the visible method) **and** routable through the `…_e`
/// dispatch entry ([`NativeSig::error_out_from_method`], which additionally requires every
/// visible param and the primary to be *error-routable* — pointer/BOOL/integer shapes the
/// `awexc.m` `uintptr_t` packing can carry, bounded by its dispatch switch; a float/double/
/// struct/void/C-string anywhere in the fallible signature defers). The two must agree so
/// the emit-body's dispatch build never faces an admitted-but-unroutable method. A fallible
/// `writeToFile:error:` whose only non-error arg is an `NSString` binds even though its
/// trailing raw pointer would otherwise defer it in [`is_supported_method`]; a hypothetical
/// `-rectForKey:error:` → CGRect defers (struct primary). Non-error methods fall through to
/// plain [`is_supported_method`]. This is the
/// class-method context gate the class emitters use; the free-function frontier
/// ([`is_supported_function`]) carries no error channel yet (a free-function `NSError**` is
/// an anonymous pointer with no owning class to key a selector set on).
pub fn is_supported_method_ctx(
    method: &Method,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
) -> bool {
    !method.deprecated && is_supported_method_ctx_modulo_deprecation(method, mapper, error_selectors)
}

/// The `_ctx` (error-out-aware) form of [`is_supported_method_modulo_deprecation`] — the
/// deprecation-sole-blocker question asked over the same frontier
/// [`is_supported_method_ctx`] gates, so the carve-out and the ordinary path can never
/// disagree about a signature's bindability.
pub fn is_supported_method_ctx_modulo_deprecation(
    method: &Method,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
) -> bool {
    if is_error_out_method(method, error_selectors) {
        // A `SEL`/`Class` **primary** cannot ride the `Result<T>` channel: it is pointer-shaped, so
        // the `…_e` entry happily carries it, but the `Result` helpers only wrap an object
        // (`__resultRetained`/`__resultOwned`) or pass a scalar through (`__resultScalar`) — the
        // latter would seat the raw handle in the ok-branch under a declared `string`/`typeof
        // NSObject`, reinstating exactly the lie this leaf removes. It DEFERS (counted like every
        // other frontier shape — "defer nothing silently"); the corpus population today is **zero**,
        // so this closes a latent hole rather than dropping any real API (`sel-classref-surface-k72`).
        if PtrValue::of(&method.return_type).is_some() {
            return false;
        }
        let mut visible = method.clone();
        visible.params.pop();
        return is_supported_method_modulo_deprecation(&visible, mapper)
            && NativeSig::error_out_from_method(method).is_some();
    }
    is_supported_method_modulo_deprecation(method, mapper)
}

/// True when the emitter can bind free `function` with the machinery present so far — the
/// free-function analogue of [`is_supported_method`], sharing the same type frontier
/// (blocks, raw pointers, and non-geometry structs defer; scalars, objects, C strings,
/// geometry structs, and enum aliases bind). Two function-only gates replace the method's
/// selector/deprecation ones:
/// - **variadic** functions defer (the addon's fixed-signature `@_cdecl` cannot be variadic
///   — method_filter parity);
/// - **inline** functions defer (no exported C symbol to call — the sbcl precedent).
///
/// It closes on the same **ABI-routability** gate ([`NativeSig::from_function`]) — a
/// function whose params/return carry no static ABI shape cannot be dispatched, so it must
/// not be emitted.
///
/// The **Swift-native** (`objc_exposed == false`) split is applied by the caller (it needs a
/// trampoline, Step 4 — ADR-0026/0027), exactly as [`crate::class_surface::bound_methods`]
/// filters `objc_exposed` for methods. A raw `NSError**` out-param arrives as a
/// [`TypeRefKind::Pointer`](apianyware_types::type_ref::TypeRefKind::Pointer) (the extractor
/// keeps no NSError identity), so it defers here with every other raw pointer — the
/// free-function `Result<T>` channel is deferred to its own `error-model` leaf (ADR-0058).
pub fn is_supported_function(function: &Function, mapper: &TsFfiTypeMapper) -> bool {
    if function.variadic || function.inline {
        return false;
    }
    if function_swift_nominal_deferral(function, mapper).is_some() {
        return false;
    }
    if has_block(&function.params) || is_block(&function.return_type) {
        return false;
    }
    if has_unsupported_struct(&function.params, mapper)
        || is_unsupported_struct(&function.return_type, mapper)
    {
        return false;
    }
    if (has_raw_pointer(&function.params) || is_raw_pointer(&function.return_type))
        && !is_admitted_opaque_pointer_function(function)
    {
        return false;
    }
    // ABI routability is the FINAL gate, exactly as in `is_supported_method` — the
    // filter/dispatch agreement invariant made structural, here for the free-function
    // family (`fn-entry-spine-k68`). An admitted function must have a dispatch signature,
    // or the emitted `aw_ts_fn_<symbol>` call site would name an entry no table can
    // provide. The real corpus's residual is 107 functions, all aliases the structural
    // checks above cannot see: the **SIMD/vector** family (`vFloat` ×44, `vUInt32` ×30,
    // `vSInt32` ×15, `vector_float2`/`simd_float2` — vecLib and Vision), **C array
    // typedefs** (`io_string_t` = `char[512]` ×8 in ICADevices, `Str255`, `DVDDiscID`),
    // and `ALvoid` (OpenAL's `void` alias, which carries no `underlying_primitive`). Each
    // defers like a non-geometry struct; a later `emit-simd` leaf could widen this.
    NativeSig::from_function(function).is_some()
}

/// Whether the method's return type is an object (drives handle-wrapping in
/// `emit-class`).
pub fn returns_object_type(method: &Method, mapper: &TsFfiTypeMapper) -> bool {
    mapper.is_object_type(&method.return_type)
}

/// Whether the method returns `void`.
pub fn returns_void(method: &Method, mapper: &TsFfiTypeMapper) -> bool {
    mapper.is_void(&method.return_type)
}

fn has_block(params: &[Param]) -> bool {
    params.iter().any(|p| is_block(&p.param_type))
}

fn is_block(t: &TypeRef) -> bool {
    matches!(t.kind, TypeRefKind::Block { .. })
}

/// Selectors admitted despite carrying a block param — a narrow, hand-verified
/// carve-out (`block-call-site-emission-k120`), not a general block-parameter-method
/// gate. Each entry was checked by hand against the real macOS SDK corpus before
/// being added here: `beginSheetModalForWindow:completionHandler:` is `void (^)
/// (NSModalResponse)` on **both** its corpus occurrences (`NSAlert`, `NSSavePanel` —
/// the only two in the whole SDK, `grep -c` verified), a genuinely *escaping*
/// completion handler (the framework stores and fires it later, on dismissal) whose
/// one `int64` param + `void` return (the `"q_v"` inbound signature,
/// [`crate::inbound_table::InboundSig::code_string`]) already has a generated
/// escaping block-maker corpus-wide ([`crate::inbound_table::collect_inbound_table`]
/// walks every class/protocol method's block params regardless of this filter). Widen
/// this set only after checking a new selector's block shape by hand the same way —
/// selector-name matching alone cannot see whether a *different* class reuses the
/// name for an incompatible shape, so [`emit_class::emit_body`](crate::emit_class)
/// derives the actual signature code from the IR at emit time rather than assuming
/// `"q_v"`, and panics loudly if a future corpus regeneration ever disagrees.
const ADMITTED_COMPLETION_HANDLER_SELECTORS: &[&str] =
    &["beginSheetModalForWindow:completionHandler:"];

/// Whether `method` is in the narrow completion-handler carve-out above — checked by
/// selector name only (the shape was verified by hand for every corpus occurrence of
/// each admitted selector, module doc).
fn is_admitted_completion_handler(method: &Method) -> bool {
    ADMITTED_COMPLETION_HANDLER_SELECTORS.contains(&method.selector.as_str())
}

fn has_unsupported_struct(params: &[Param], mapper: &dyn FfiTypeMapper) -> bool {
    params
        .iter()
        .any(|p| is_unsupported_struct(&p.param_type, mapper))
}

/// A struct-by-value the scaffold cannot yet honour: a struct kind the IR mapper
/// recognises that is not one of the curated population-A geometry aggregates.
fn is_unsupported_struct(t: &TypeRef, mapper: &dyn FfiTypeMapper) -> bool {
    if !mapper.is_struct_type(t) {
        return false;
    }
    let name = match &t.kind {
        TypeRefKind::Struct { name } | TypeRefKind::Alias { name, .. } => name,
        _ => return true,
    };
    !is_geometry_struct(name)
}

fn has_raw_pointer(params: &[Param]) -> bool {
    params.iter().any(|p| is_raw_pointer(&p.param_type))
}

fn is_raw_pointer(t: &TypeRef) -> bool {
    matches!(
        t.kind,
        TypeRefKind::Pointer | TypeRefKind::FunctionPointer { .. }
    )
}

/// Free C functions admitted despite an untyped (`CGContextRef`) pointer parameter — a narrow,
/// hand-verified carve-out (`coregraphics-context-function-surface-k124`), not a general
/// opaque-pointer-parameter policy. `CGContextRef` collapses to the same untyped
/// `TypeRefKind::Pointer` as every other C opaque-struct pointer (`extract-objc`'s `map_typedef`
/// drops the typedef name for this shape — a shared, cross-target fact deliberately left alone
/// here; ADR-0011), so the crossing is by **function name**, checked by hand against the real SDK
/// corpus (`extracted.kdl`) before being added: each of these eight `CGContext*` symbols takes the
/// drawing context as its **first and only** pointer-shaped parameter — every other parameter is
/// already a bound scalar or enum alias. It crosses as a plain `bigint` handle (already how
/// `TsFfiTypeMapper` renders `TypeRefKind::Pointer`, `ffi_type_mapping.rs`), never wrapped or
/// retained/released — `NSGraphicsContext.CGContext()` below is the paired source of that handle.
/// Widen this list only after checking a new function's signature by hand the same way: a pointer
/// **elsewhere** in an admitted function's signature (not this app's drawing-context receiver)
/// still defers, since name matching alone cannot see a future corpus regeneration changing the
/// shape underneath.
const ADMITTED_OPAQUE_POINTER_FUNCTIONS: &[&str] = &[
    "CGContextSetRGBStrokeColor",
    "CGContextSetLineWidth",
    "CGContextSetLineCap",
    "CGContextSetLineJoin",
    "CGContextBeginPath",
    "CGContextMoveToPoint",
    "CGContextAddLineToPoint",
    "CGContextStrokePath",
];

/// Whether `function` is in the narrow `CGContextRef` carve-out above — checked by symbol name
/// only (the shape was verified by hand for every admitted function, module doc).
fn is_admitted_opaque_pointer_function(function: &Function) -> bool {
    ADMITTED_OPAQUE_POINTER_FUNCTIONS.contains(&function.name.as_str())
}

/// Methods admitted despite an untyped (`CGContextRef`) pointer return — the method-side twin of
/// [`ADMITTED_OPAQUE_POINTER_FUNCTIONS`] above (same leaf, same rationale). `NSGraphicsContext.
/// CGContext` is corpus-unique (`grep -c '"selector" "CGContext"'` across all 252 frameworks'
/// `extracted.kdl` = 1), so bare-selector matching cannot collide with an unrelated class reusing
/// the name. Its return is the exact `bigint` handle the eight admitted free functions above take
/// as their first parameter.
const ADMITTED_OPAQUE_POINTER_METHODS: &[&str] = &["CGContext"];

/// Whether `method` is in the narrow `CGContextRef` return carve-out above — checked by selector
/// name only (module doc).
fn is_admitted_opaque_pointer_method(method: &Method) -> bool {
    ADMITTED_OPAQUE_POINTER_METHODS.contains(&method.selector.as_str())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi_type_mapping::TsFfiTypeMapper;

    fn method(selector: &str, variadic: bool, deprecated: bool, ret: TypeRef) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: false,
            params: vec![],
            return_type: ret,
            deprecated,
            variadic,
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

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: ty(kind),
        }
    }

    #[test]
    fn plain_object_method_supported() {
        let m = TsFfiTypeMapper::new();
        assert!(is_supported_method(
            &method(
                "length",
                false,
                false,
                ty(TypeRefKind::Id {
                    protocols: Vec::new()
                })
            ),
            &m
        ));
    }

    #[test]
    fn variadic_deprecated_and_swift_paren_deferred() {
        let m = TsFfiTypeMapper::new();
        assert!(!is_supported_method(
            &method(
                "foo:",
                true,
                false,
                ty(TypeRefKind::Id {
                    protocols: Vec::new()
                })
            ),
            &m
        ));
        assert!(!is_supported_method(
            &method(
                "foo:",
                false,
                true,
                ty(TypeRefKind::Id {
                    protocols: Vec::new()
                })
            ),
            &m
        ));
        assert!(!is_supported_method(
            &method(
                "data(from:)",
                false,
                false,
                ty(TypeRefKind::Id {
                    protocols: Vec::new()
                })
            ),
            &m
        ));
    }

    #[test]
    fn geometry_struct_supported_other_struct_deferred() {
        let m = TsFfiTypeMapper::new();
        assert!(is_supported_method(
            &method(
                "frame",
                false,
                false,
                ty(TypeRefKind::Struct {
                    name: "CGRect".into()
                })
            ),
            &m
        ));
        assert!(!is_supported_method(
            &method(
                "weird",
                false,
                false,
                ty(TypeRefKind::Struct {
                    name: "SomeStruct".into()
                })
            ),
            &m
        ));
    }

    #[test]
    fn blocks_deferred_both_directions() {
        let m = TsFfiTypeMapper::new();
        let block = || {
            ty(TypeRefKind::Block {
                params: vec![ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                })],
                return_type: Box::new(TypeRef::void()),
            })
        };
        // Block return deferred.
        assert!(!is_supported_method(
            &method("handler", false, false, block()),
            &m
        ));
        // Block param deferred (callback bridging is ADR-0059, a later leaf) —
        // *except* the narrow completion-handler carve-out below.
        let mut meth = method("enumerateWithBlock:", false, false, TypeRef::void());
        meth.params = vec![Param {
            name: "block".into(),
            param_type: block(),
        }];
        assert!(!is_supported_method(&meth, &m));
    }

    #[test]
    fn admitted_completion_handler_selector_binds_despite_its_block_param() {
        // The narrow block-call-site-emission-k120 carve-out: an admitted selector binds
        // even though it carries a block param — every other block-param method still defers.
        let m = TsFfiTypeMapper::new();
        let handler_block = ty(TypeRefKind::Block {
            params: vec![ty(TypeRefKind::Primitive {
                name: "int64".into(),
            })],
            return_type: Box::new(TypeRef::void()),
        });
        let mut meth = method(
            "beginSheetModalForWindow:completionHandler:",
            false,
            false,
            TypeRef::void(),
        );
        meth.params = vec![
            param(
                "window",
                TypeRefKind::Class {
                    name: "NSWindow".into(),
                    framework: None,
                    params: vec![],
                },
            ),
            Param {
                name: "handler".into(),
                param_type: handler_block,
            },
        ];
        assert!(is_supported_method(&meth, &m));
        // A block *return* never rides the carve-out, admitted selector or not.
        let mut ret_block = meth.clone();
        ret_block.return_type = ty(TypeRefKind::Block {
            params: vec![],
            return_type: Box::new(TypeRef::void()),
        });
        assert!(!is_supported_method(&ret_block, &m));
    }

    #[test]
    fn simd_vector_aliases_defer_on_abi_routability() {
        // The real-corpus residual the final routability gate catches: a simd/vector
        // alias (no underlying primitive, not geometry) has no static ABI shape, so a
        // method carrying one defers — in a return OR a param position — instead of
        // panicking at emit ("a supported method has a routable dispatch signature").
        let m = TsFfiTypeMapper::new();
        let simd = || {
            ty(TypeRefKind::Alias {
                name: "simd_float3".into(),
                framework: None,
                underlying_primitive: None,
            })
        };
        assert!(!is_supported_method(
            &method("probeExtents", false, false, simd()),
            &m
        ));
        let mut setter = method("setProbeExtents:", false, false, TypeRef::void());
        setter.params = vec![Param {
            name: "extents".into(),
            param_type: simd(),
        }];
        assert!(!is_supported_method(&setter, &m));
        // An enum-typedef alias (underlying primitive resolved) still binds.
        let enum_ret = method(
            "alignment",
            false,
            false,
            ty(TypeRefKind::Alias {
                name: "NSTextAlignment".into(),
                framework: None,
                underlying_primitive: Some("int64".into()),
            }),
        );
        assert!(is_supported_method(&enum_ret, &m));
    }

    #[test]
    fn raw_pointer_params_and_returns_deferred() {
        let m = TsFfiTypeMapper::new();
        let mut meth = method("getBytes:", false, false, TypeRef::void());
        meth.params = vec![param("buf", TypeRefKind::Pointer)];
        assert!(!is_supported_method(&meth, &m));
        assert!(!is_supported_method(
            &method("bytes", false, false, ty(TypeRefKind::Pointer)),
            &m
        ));
        // A function-pointer return also defers.
        assert!(!is_supported_method(
            &method(
                "callback",
                false,
                false,
                ty(TypeRefKind::FunctionPointer {
                    name: None,
                    params: vec![],
                    return_type: Box::new(TypeRef::void()),
                })
            ),
            &m
        ));
    }

    #[test]
    fn admitted_opaque_pointer_method_binds_despite_its_pointer_return() {
        // The narrow coregraphics-context-function-surface-k124 carve-out: NSGraphicsContext's
        // `CGContext` selector binds despite a bare-pointer return — every other bare-pointer
        // return still defers (`raw_pointer_params_and_returns_deferred` above).
        let m = TsFfiTypeMapper::new();
        assert!(is_supported_method(
            &method("CGContext", false, false, ty(TypeRefKind::Pointer)),
            &m
        ));
        // An unrelated selector with the same bare-pointer return still defers.
        assert!(!is_supported_method(
            &method("bytes", false, false, ty(TypeRefKind::Pointer)),
            &m
        ));
    }

    fn func(
        name: &str,
        params: Vec<Param>,
        ret: TypeRef,
        inline: bool,
        variadic: bool,
    ) -> Function {
        Function {
            name: name.into(),
            params,
            return_type: ret,
            inline,
            variadic,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    #[test]
    fn function_frontier_mirrors_the_method_frontier() {
        let m = TsFfiTypeMapper::new();
        // A plain scalar/geometry/object function binds.
        assert!(is_supported_function(
            &func(
                "TKDistance",
                vec![param(
                    "a",
                    TypeRefKind::Id {
                        protocols: Vec::new()
                    }
                )],
                ty(TypeRefKind::Primitive {
                    name: "double".into()
                }),
                false,
                false
            ),
            &m
        ));
        // Variadic and inline defer (the two function-only gates).
        assert!(!is_supported_function(
            &func("TKLog", vec![], TypeRef::void(), false, true),
            &m
        ));
        assert!(!is_supported_function(
            &func(
                "TKFastHash",
                vec![],
                ty(TypeRefKind::Primitive {
                    name: "uint64".into()
                }),
                true,
                false
            ),
            &m
        ));
        // A raw-pointer param (an NSError** out-param arrives this way) defers — the
        // shared frontier, not a special case.
        assert!(!is_supported_function(
            &func(
                "TKReadInto",
                vec![param("err", TypeRefKind::Pointer)],
                TypeRef::void(),
                false,
                false
            ),
            &m
        ));
        // A non-geometry struct return defers; a geometry one binds.
        assert!(!is_supported_function(
            &func(
                "TKWeird",
                vec![],
                ty(TypeRefKind::Struct {
                    name: "NSDecimal".into()
                }),
                false,
                false
            ),
            &m
        ));
        assert!(is_supported_function(
            &func(
                "TKBounds",
                vec![],
                ty(TypeRefKind::Struct {
                    name: "CGRect".into()
                }),
                false,
                false
            ),
            &m
        ));
    }

    #[test]
    fn admitted_opaque_pointer_functions_bind_despite_their_pointer_param() {
        // The narrow coregraphics-context-function-surface-k124 carve-out: every admitted
        // CGContext* function binds despite its bare-pointer `c` receiver — an unrelated
        // function with the identical shape still defers (the shared frontier, not a
        // blanket pointer-param allowance).
        let m = TsFfiTypeMapper::new();
        for name in ADMITTED_OPAQUE_POINTER_FUNCTIONS {
            assert!(
                is_supported_function(
                    &func(
                        name,
                        vec![param("c", TypeRefKind::Pointer)],
                        TypeRef::void(),
                        false,
                        false
                    ),
                    &m
                ),
                "{name} should bind despite its CGContextRef param"
            );
        }
        assert!(!is_supported_function(
            &func(
                "CGContextSetShouldAntialias",
                vec![param("c", TypeRefKind::Pointer)],
                TypeRef::void(),
                false,
                false
            ),
            &m
        ));
    }

    #[test]
    fn unroutable_alias_functions_defer_on_the_final_abi_gate() {
        // The free-function dual of the method frontier's ABI-routability gate
        // (`fn-entry-spine-k68`). These aliases carry no `underlying_primitive` and are not
        // geometry, so every *structural* check above passes them — only
        // `NativeSig::from_function` sees they have no machine shape. All four are real
        // shapes from the committed corpus; before this gate they emitted 107 call sites
        // naming `aw_ts_fn_*` entries no table could ever provide.
        let m = TsFfiTypeMapper::new();
        let alias = |name: &str| {
            ty(TypeRefKind::Alias {
                name: name.into(),
                framework: None,
                underlying_primitive: None,
            })
        };

        // vecLib's SIMD vector family — 89 of the 107, by far the biggest population.
        assert!(!is_supported_function(
            &func(
                "vvrecf",
                vec![param(
                    "v",
                    TypeRefKind::Alias {
                        name: "vFloat".into(),
                        framework: None,
                        underlying_primitive: None,
                    }
                )],
                alias("vFloat"),
                false,
                false
            ),
            &m
        ));
        // Vision's `vector_float2` param.
        assert!(!is_supported_function(
            &func(
                "VNImagePointForFaceLandmarkPoint",
                vec![param(
                    "p",
                    TypeRefKind::Alias {
                        name: "vector_float2".into(),
                        framework: None,
                        underlying_primitive: None,
                    }
                )],
                TypeRef::void(),
                false,
                false
            ),
            &m
        ));
        // A C **array typedef** param (`io_string_t` is `char[512]`; ICADevices, 8 of them).
        // It is not a pointer, not a struct — it looks scalar-ish to every structural check.
        assert!(!is_supported_function(
            &func(
                "ICDConnectUSBDeviceWithIORegPath",
                vec![param(
                    "path",
                    TypeRefKind::Alias {
                        name: "io_string_t".into(),
                        framework: None,
                        underlying_primitive: None,
                    }
                )],
                ty(TypeRefKind::Primitive {
                    name: "int32".into()
                }),
                false,
                false
            ),
            &m
        ));
        // OpenAL's `ALvoid` return — a `void` alias whose underlying primitive is absent, so
        // it resolves to no ABI shape at all (not even `Void`).
        assert!(!is_supported_function(
            &func("alutExit", vec![], alias("ALvoid"), false, false),
            &m
        ));

        // The gate is precise, not blunt: an enum-typedef alias resolves its underlying
        // scalar and still binds, as does a geometry alias.
        assert!(is_supported_function(
            &func(
                "TKNormalize",
                vec![],
                ty(TypeRefKind::Alias {
                    name: "NSTextAlignment".into(),
                    framework: None,
                    underlying_primitive: Some("int64".into()),
                }),
                false,
                false
            ),
            &m
        ));
        assert!(is_supported_function(
            &func(
                "TKRangeOf",
                vec![],
                ty(TypeRefKind::Alias {
                    name: "NSRange".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false,
                false
            ),
            &m
        ));
    }

    #[test]
    fn error_out_method_recognised_and_bindable_in_context() {
        let m = TsFfiTypeMapper::new();
        let mut errs = HashSet::new();
        errs.insert("writeToFile:error:".to_string());
        // -writeToFile:(NSString)error:(NSError**) -> BOOL.
        let mut meth = method(
            "writeToFile:error:",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        meth.params = vec![
            param(
                "path",
                TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            ),
            param("error", TypeRefKind::Pointer),
        ];
        assert!(is_error_out_method(&meth, &errs));
        // Plain supportedness defers it (the trailing raw pointer).
        assert!(!is_supported_method(&meth, &m));
        // Error-context supportedness accepts it (the trailing pointer is the cell; the
        // one visible NSString arg is bindable).
        assert!(is_supported_method_ctx(&meth, &m, &errs));
        // Not in the enrichment set ⇒ stays deferred (a bare trailing pointer is not
        // enough — the selector membership is what proves it is an NSError** cell).
        assert!(!is_supported_method_ctx(&meth, &m, &HashSet::new()));
    }

    #[test]
    fn error_method_with_another_raw_pointer_still_defers() {
        // Only the trailing NSError** cell is forgiven; a second raw pointer among the
        // visible args keeps the method deferred.
        let m = TsFfiTypeMapper::new();
        let mut errs = HashSet::new();
        errs.insert("doThing:error:".to_string());
        let mut meth = method(
            "doThing:error:",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        meth.params = vec![
            param("raw", TypeRefKind::Pointer),
            param("error", TypeRefKind::Pointer),
        ];
        assert!(is_error_out_method(&meth, &errs));
        assert!(!is_supported_method_ctx(&meth, &m, &errs));
    }

    #[test]
    fn error_out_method_with_struct_primary_defers() {
        // A fallible method whose *primary* return is a by-value geometry struct is admitted
        // by is_supported_method over the visible sig (a geometry struct return is fine for a
        // plain method), but the `…_e` dispatch cannot combine a struct out-buffer with the
        // error channel (NativeSig::error_out_from_method → None). The context gate must
        // therefore defer it, so the emit-body's dispatch build never faces an unroutable
        // method (the filter/dispatch agreement invariant).
        let m = TsFfiTypeMapper::new();
        let mut errs = HashSet::new();
        errs.insert("rectForKey:error:".to_string());
        let mut meth = method(
            "rectForKey:error:",
            false,
            false,
            ty(TypeRefKind::Struct {
                name: "CGRect".into(),
            }),
        );
        meth.params = vec![
            param(
                "key",
                TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            ),
            param("error", TypeRefKind::Pointer),
        ];
        // It *is* recognised as an error-out shape (selector + trailing pointer)…
        assert!(is_error_out_method(&meth, &errs));
        // …but the struct primary makes the `…_e` dispatch unroutable, so it defers.
        assert!(NativeSig::error_out_from_method(&meth).is_none());
        assert!(!is_supported_method_ctx(&meth, &m, &errs));
    }

    #[test]
    fn error_selector_without_trailing_pointer_is_not_error_out() {
        // A selector the enrichment flagged, but whose last param is not a raw pointer
        // (a mis-annotation, or a differently-shaped signature), is not routed as
        // error-out — the structural corroboration guards against mis-routing.
        let mut errs = HashSet::new();
        errs.insert("compare:error:".to_string());
        let mut meth = method(
            "compare:error:",
            false,
            false,
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        meth.params = vec![
            param(
                "other",
                TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            ),
            param(
                "flag",
                TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            ),
        ];
        assert!(!is_error_out_method(&meth, &errs));
    }

    #[test]
    fn return_classifiers() {
        let m = TsFfiTypeMapper::new();
        assert!(returns_object_type(
            &method(
                "self",
                false,
                false,
                ty(TypeRefKind::Id {
                    protocols: Vec::new()
                })
            ),
            &m
        ));
        assert!(returns_void(
            &method("noop", false, false, TypeRef::void()),
            &m
        ));
        assert!(!returns_object_type(
            &method(
                "count",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "int64".into()
                })
            ),
            &m
        ));
    }
}
