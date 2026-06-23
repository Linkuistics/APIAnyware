//! Generated C-ABI trampolines for the Swift-native residual — sbcl target.
//!
//! Leaf `040/050` ports the proven trampoline mechanism (ADR-0027 racket /
//! ADR-0028 chez / ADR-0029 gerbil, spec `docs/specs/2026-06-15-racket-trampoline.md`)
//! to sbcl under **ADR-0038**: `libAPIAnywareSbcl` is the SBCL target's **sole native
//! compilation unit** (a Lisp compiles neither ObjC nor Swift inline), so the Swift
//! trampolines live there. A trampoline *must* be Swift — only Swift can call the
//! Swift ABI — so for every retained `objc_exposed == false` declaration this module
//! vends a **call-by-name `@_cdecl` trampoline** in `Generated/Trampolines.swift`: a
//! C-linkable Swift function that `import`s the owning framework module and calls the
//! API by its reconstructed Swift name + argument labels, letting swiftc own ABI
//! correctness (ADR-0027 §1). The sbcl emitter binds each entry with a per-signature
//! typed `sb-alien` against the linked dylib's `aw_sbcl_swift_*` entry (the ADR-0015
//! compiled-FFI idiom — the same shape the direct `objc_msgSend` dispatch uses),
//! computing the same content-addressed entry name independently.
//!
//! **Hermetic duplication (ADR-0011 / ADR-0038).** The classification taxonomy here
//! is a *property of the shared IR + the flat C ABI*, not of any target, so it is
//! identical to racket/chez/gerbil — and the residual, a deterministic function of
//! that IR, reproduces theirs **exactly** (the §6d invariant: 51 function, 7 constant,
//! 576 init, and 554 method trampolines). The Swift codegen mirrors the peers'
//! `Generated/Trampolines.swift`, renamed to the sbcl runtime helpers (`awSbclBox` /
//! `awSbclUnbox` / `awSbclTry`, hosted by `libAPIAnywareSbcl`'s `.swift` files, ADR-0038
//! §1, runtime leaf 050). The genuinely-divergent half is the **Lisp binding**: typed
//! `sb-alien` (not chez's `foreign-procedure`, not gerbil's `define-c-lambda`), with an
//! **object** return wrapped to its exact bound type through the **ADR-0034 MOP class
//! registry** (`aw-wrap`) — the sbcl analogue of gerbil's ADR-0029 §2 divergence.
//!
//! **sbcl's object-return path (ADR-0038 §4).** Like gerbil (and unlike chez/racket,
//! which box every non-scalar/non-string return into an opaque handle), an **object**
//! return (`Class`/`id`/`instancetype`) is handed back as a raw `id` and `aw-wrap`ped
//! to its **exact bound type** via the MOP class registry (the same wrap every
//! `id`-returning method already gets). Only a genuinely non-object value (non-bridged
//! `struct`, tuple, existential) rides the opaque `awSbclBox` handle. So the chez single
//! `Handle` rep splits here into [`RetMarshal::Object`] (`aw-wrap`) vs
//! [`RetMarshal::OpaqueBox`] (raw value handle).
//!
//! Naming is content-addressed (ADR-0013 precedent): `aw_sbcl_swift_<Fw>_<name>`, with a
//! short signature hash appended when a `(module, name)` is overloaded within its
//! framework; constants are `aw_sbcl_swift_const_<Fw>_<name>`; methods
//! `aw_sbcl_swift_m_<Fw>_<Owner>_<base>`; inits `aw_sbcl_swift_init_<Fw>_<Owner>`.
//!
//! **Leaf split (ADR-0038 §"Build-leaf boundaries").** `040/050` (this leaf) builds the
//! classification, the global Swift pass (`run_sbcl_trampolines`), and the `sb-alien`
//! binding *rendering*; `040/060` (orchestration) wires those renderings into
//! `emit_framework`; the `.swift` native helpers + the runtime `swift-trampoline`
//! cluster (`aw-wrap` / `aw-ptr` / `aw-swift-string-*` / `aw-swift-call/error`) are the
//! runtime leaf (parent grove 050).

use std::collections::{BTreeMap, HashMap, HashSet};

use apianyware_macos_types::ir::{Constant, Framework, Function, Method, Struct};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::SAP;
use crate::naming::{
    qualified_class_name, qualified_swift_init_constructor_name,
    qualified_swift_method_generic_name, qualified_top_level_name,
};

/// Prefix for a Swift-native **function** trampoline entry.
pub const FN_PREFIX: &str = "aw_sbcl_swift_";
/// Prefix for a Swift-native **constant** trampoline entry.
pub const CONST_PREFIX: &str = "aw_sbcl_swift_const_";

// --- Lisp-side runtime helper names (the `swift-trampoline` cluster, ADR-0038 §3) ---
// These are the contract the runtime leaf (parent grove 050) implements; the rendered
// `sb-alien` bindings reference them. `aw-ptr` / `aw-wrap` are the *same* helpers the
// direct `objc_msgSend` dispatch uses (emit_generics); the `aw-swift-*` helpers are the
// trampoline cluster's string/error coercers (gerbil's `aw-swift-*` analogues).

/// Inbound object wrap (`id` SAP [retained?] → exact bound instance) — the MOP class
/// registry (ADR-0034). The trampoline `@_cdecl` returns a `+1`-retained `id`, so the
/// wrap is always `retained` (`t`).
const WRAP_FN: &str = "aw-wrap";
/// Outbound object coercion (instance|nil → `id` SAP) — the contract's `->ptr`.
const PTR_FN: &str = "aw-ptr";
/// A Lisp string → autoreleased `NSString` `id` for a trampoline **arg** (the
/// `@_cdecl` takes it unretained). The trampoline cluster's string-in coercer.
const STRING_ARG_FN: &str = "aw-swift-string-arg";
/// A `+1`-retained `NSString` `id` → a fresh `cl:string`, releasing the `+1`, for a
/// trampoline **result**. The trampoline cluster's string-out coercer (ADR-0038 §3 —
/// the existing-bridge position, hosted in the `swift-trampoline` cluster).
const STRING_RESULT_FN: &str = "aw-swift-string-result";
/// The Swift-`throws` out-cell macro for a TRAMPOLINE: allocates the `%err` cell, runs the
/// body, and signals `ns:cocoa-error` when the cell was written (ADR-0037). This is
/// `aw-swift-call/error`, NOT the direct path's `aw-with-error-cell`: the `ThrowsBridge`
/// (`awSbclWriteError`) writes a **+1-retained** `NSError`, so the macro must take that
/// ownership and release it (OWNED t) — `aw-with-error-cell` borrows a `+0` autoreleased
/// error (the direct `objc_msgSend` path) and would LEAK the bridge's `+1`. The two paths
/// are deliberately distinct conditions.lisp macros over the same `signal-cocoa-error`.
const SWIFT_THROWS_MACRO: &str = "aw-swift-call/error";
/// The constant-binding form (emit_constants): `(define-objc-constant <sym> <value>)`.
const DEFINE_CONSTANT: &str = "define-objc-constant";

// ---------------------------------------------------------------------------
// Marshalling taxonomy
// ---------------------------------------------------------------------------

/// How one value crosses the trampoline's flat C-ABI boundary, in a **parameter**
/// position. Bindable params are the constraint on trampolinability (the return side
/// has a universal rep — see [`RetMarshal`]). Identical to the racket/chez/gerbil
/// taxonomy (a property of the shared IR).
#[derive(Debug, Clone, PartialEq, Eq)]
enum ArgMarshal {
    /// A C scalar passed straight through. Carries the Swift type spelled at the
    /// `@_cdecl` boundary (`Int`, `Double`, `Int32`, …).
    Scalar(Scalar),
    /// A **scalar-backed named typedef** (`CGFloat`) that `map_swift_type` lossily
    /// lowered to a `Class`/`Struct`/`Alias` even though it is a single C scalar. The
    /// `@_cdecl` receives the underlying scalar (`Double` for `CGFloat`); the body wraps
    /// it as the named type (`CGFloat(a0)`) so the by-name call type-checks.
    ScalarTypedef { scalar: Scalar, name: String },
    /// `Swift.String` ⇄ `NSString`. The `@_cdecl` receives an `id`; the body
    /// reconstructs `… as String` before the call. The sbcl side bridges a Lisp string
    /// to an `NSString` `id` with `aw-swift-string-arg`.
    SwiftString,
    /// A **non-bridged Swift value struct** parameter that the owning framework defines
    /// in `Framework.structs`. sbcl holds it as the opaque handle a prior boxed return
    /// handed it; the `@_cdecl` receives that raw pointer and the body unboxes the
    /// *named* value (`awSbclUnbox(aN!, as: Name.self)`) before the by-name call.
    BoxedHandle { name: String },
    /// An **objc-bridged reference** parameter (R1, ADR-0030 addendum A3). The lossy
    /// Swift→ObjC normalization reports a Swift value param as its Foundation objc twin
    /// (`URL` → `NSURL`); sbcl holds the twin as an `id` pointer. The `@_cdecl` receives
    /// that raw pointer, reconstructs the objc reference (`Unmanaged<NSURL>`) and bridges
    /// it to the Swift value (`… as URL`). Only the curated [`objc_object_param_bridge`]
    /// set rides this path. sbcl passes the id pointer straight through (`aw-ptr`).
    ObjectRef { class_name: String, bridge_to: String },
}

/// The curated objc reference classes whose params bridge to a Swift value twin (R1,
/// ADR-0030 addendum A3). Returns the Swift value type to cast to, or `None` for a
/// `Class` name not in the set (stays deferred). The set mirrors racket's/chez's/gerbil's
/// (same shared IR ⇒ same residual): each pair is a verified `_ObjectiveCBridgeable`
/// value pair, proven against the whole-Foundation typecheck.
fn objc_object_param_bridge(name: &str) -> Option<&'static str> {
    Some(match name {
        "NSURL" => "URL",
        "NSURLRequest" => "URLRequest",
        _ => return None,
    })
}

/// How a **return** value crosses the boundary. Every shape here is producible without
/// naming the concrete Swift type, so any function with bindable params is trampolinable.
#[derive(Debug, Clone, PartialEq, Eq)]
enum RetMarshal {
    Void,
    Scalar(Scalar),
    /// A scalar-backed named typedef return (`-> CGFloat`): the `@_cdecl` returns the
    /// underlying scalar; the body converts the call result (`Double(<call>)`).
    ScalarTypedef { scalar: Scalar, name: String },
    /// `Swift.String` → bridged `NSString`, returned `+1`-retained as an `id`; the sbcl
    /// side copies to a `cl:string` and releases (`aw-swift-string-result`).
    SwiftString,
    /// An **ObjC/bridged object** return (`Class`/`id`/`instancetype`). The `@_cdecl`
    /// returns the raw `id` (`+1`-retained); the sbcl binding `aw-wrap`s it to its exact
    /// bound type via the ADR-0034 MOP class registry. sbcl's divergence from chez/racket
    /// (which box objects too), mirroring gerbil (ADR-0038 §4 / ADR-0029 §2).
    Object,
    /// A non-object value (non-bridged `struct`, tuple, value-backed existential, opaque
    /// `some P`) — wrapped in `awSbclBox` and returned as an opaque handle pointer. The
    /// optional `String` is a nameable Swift return type used to disambiguate the by-name
    /// call (`(call) as CGFloat`) when the residual has cross-module return-type
    /// overloads; `None` when not safely nameable.
    OpaqueBox(Option<String>),
}

/// The closed set of C scalar shapes a trampoline param/return can be. The Swift
/// spelling is what the `@_cdecl` uses *and* what the by-name call passes, so they agree
/// by construction; the `sb-alien` spelling is what the Lisp binding's `extern-alien`
/// signature uses.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Scalar {
    Bool,
    Int,
    UInt,
    Int8,
    UInt8,
    Int16,
    UInt16,
    Int32,
    UInt32,
    Int64,
    UInt64,
    Float,
    Double,
}

impl Scalar {
    /// The Swift type at the `@_cdecl` boundary. `int64`/`uint64` map to Swift's word
    /// types `Int`/`UInt` (the overwhelmingly common Swift spelling, and what a by-name
    /// call to an `Int`-taking API needs); fixed widths stay fixed.
    fn swift(self) -> &'static str {
        match self {
            Scalar::Bool => "Bool",
            Scalar::Int | Scalar::Int64 => "Int",
            Scalar::UInt | Scalar::UInt64 => "UInt",
            Scalar::Int8 => "Int8",
            Scalar::UInt8 => "UInt8",
            Scalar::Int16 => "Int16",
            Scalar::UInt16 => "UInt16",
            Scalar::Int32 => "Int32",
            Scalar::UInt32 => "UInt32",
            Scalar::Float => "Float",
            Scalar::Double => "Double",
        }
    }

    /// The `sb-alien` type spelling for the crossing's arg/return slot — the same
    /// spellings [`crate::ffi_type_mapping::SbclFfiTypeMapper`] emits for the direct
    /// bindings. `Int`/`UInt` are word-sized (64-bit on arm64); ObjC `BOOL` is
    /// `(boolean 8)` (1-byte, auto-converts T/NIL).
    fn sbcl_alien(self) -> &'static str {
        match self {
            Scalar::Bool => "(sb-alien:boolean 8)",
            Scalar::Int | Scalar::Int64 => "(sb-alien:signed 64)",
            Scalar::UInt | Scalar::UInt64 => "(sb-alien:unsigned 64)",
            Scalar::Int8 => "(sb-alien:signed 8)",
            Scalar::UInt8 => "(sb-alien:unsigned 8)",
            Scalar::Int16 => "(sb-alien:signed 16)",
            Scalar::UInt16 => "(sb-alien:unsigned 16)",
            Scalar::Int32 => "(sb-alien:signed 32)",
            Scalar::UInt32 => "(sb-alien:unsigned 32)",
            Scalar::Float => "sb-alien:float",
            Scalar::Double => "sb-alien:double",
        }
    }

    /// Is this an integer scalar (so a width-agnostic `numericCast` is valid)?
    /// `Bool`/`Float`/`Double` are not `BinaryInteger` and pass through unconverted. The
    /// method/init path opts into `numericCast` (the IR collapses `Int`/`Int64` etc. onto
    /// one token); free functions keep the bare pass-through.
    fn is_integer(self) -> bool {
        !matches!(self, Scalar::Bool | Scalar::Float | Scalar::Double)
    }

    /// The `awSbclTry` fallback literal for this scalar on the throwing path.
    fn fallback(self) -> &'static str {
        match self {
            Scalar::Bool => "false",
            _ => "0",
        }
    }
}

/// Normalise an IR primitive name (`Swift.Int` / `NSInteger` / `double`) to the
/// lowercase, unqualified token the scalar mapper keys on.
fn normalize_primitive(name: &str) -> String {
    let unqualified = match name.rsplit_once('.') {
        Some((_, suffix)) => suffix,
        None => name,
    };
    unqualified.to_ascii_lowercase()
}

/// Map an IR primitive name to a [`Scalar`], or `None` for `void`/unknown.
fn scalar_of_primitive(name: &str) -> Option<Scalar> {
    Some(match normalize_primitive(name).as_str() {
        "bool" => Scalar::Bool,
        "int" | "nsinteger" => Scalar::Int,
        "uint" | "nsuinteger" => Scalar::UInt,
        "int8" => Scalar::Int8,
        "uint8" => Scalar::UInt8,
        "int16" => Scalar::Int16,
        "uint16" => Scalar::UInt16,
        "int32" => Scalar::Int32,
        "uint32" => Scalar::UInt32,
        "int64" => Scalar::Int64,
        "uint64" => Scalar::UInt64,
        "float" => Scalar::Float,
        "double" => Scalar::Double,
        _ => return None,
    })
}

/// Is this `TypeRef` the Foundation-bridged `String` rep (`Class { NSString }`)?
/// `map_swift_type` lowers `Swift.String` to exactly this.
fn is_swift_string(t: &TypeRef) -> bool {
    matches!(&t.kind, TypeRefKind::Class { name, .. } if name == "NSString")
}

/// `map_swift_type` lowers an anonymous Swift tuple to `Class { name: "Tuple", … }` — a
/// sentinel name that cannot be spelled as a Swift type. A tuple return must therefore
/// box **unnamed** (`as Tuple` does not compile).
fn is_unspellable_type_name(name: &str) -> bool {
    name == "Tuple"
}

/// A **scalar-backed named typedef**: a Swift type that `map_swift_type` lowers to a
/// named `Class`/`Struct`/`Alias` but which is a single C scalar at the ABI, so it
/// marshals by value as that scalar rather than behind an opaque handle. `CGFloat` is the
/// dominant case in the real residual (spec §5a).
fn scalar_typedef(name: &str) -> Option<Scalar> {
    match name {
        "CGFloat" => Some(Scalar::Double),
        _ => None,
    }
}

/// Classify a param `TypeRef` into its marshalling, or the [`DeferReason`] that records
/// why it cannot be trampolined this leaf. `value_structs` is the owning framework's own
/// `Framework.structs` name set — a param whose named type is in it is a Swift value
/// struct the box round-trips (spec §5c).
fn classify_param(t: &TypeRef, value_structs: &HashSet<&str>) -> Result<ArgMarshal, DeferReason> {
    if is_swift_string(t) {
        return Ok(ArgMarshal::SwiftString);
    }
    match &t.kind {
        TypeRefKind::Primitive { name } => scalar_of_primitive(name)
            .map(ArgMarshal::Scalar)
            .ok_or(DeferReason::NonBridgedStructParam),
        TypeRefKind::Class { name, .. }
        | TypeRefKind::Struct { name }
        | TypeRefKind::Alias { name, .. } => {
            if let Some(scalar) = scalar_typedef(name) {
                Ok(ArgMarshal::ScalarTypedef {
                    scalar,
                    name: name.clone(),
                })
            } else if value_structs.contains(name.as_str()) {
                Ok(ArgMarshal::BoxedHandle { name: name.clone() })
            } else if let Some(bridge_to) = objc_object_param_bridge(name) {
                Ok(ArgMarshal::ObjectRef {
                    class_name: name.clone(),
                    bridge_to: bridge_to.to_string(),
                })
            } else {
                Err(DeferReason::NonBridgedStructParam)
            }
        }
        TypeRefKind::Block { .. } | TypeRefKind::FunctionPointer { .. } => {
            Err(DeferReason::ClosureParam)
        }
        _ => Err(DeferReason::UnnameableParam),
    }
}

/// Classify a return `TypeRef`. Total: every shape maps somewhere, so the return never
/// blocks trampolinability. sbcl splits chez's single boxed `Handle` into
/// [`RetMarshal::Object`] (ObjC/bridged object → `aw-wrap`) and
/// [`RetMarshal::OpaqueBox`] (non-object value → `awSbclBox`).
fn classify_return(t: &TypeRef) -> RetMarshal {
    if is_swift_string(t) {
        return RetMarshal::SwiftString;
    }
    match &t.kind {
        TypeRefKind::Primitive { name } => match scalar_of_primitive(name) {
            Some(s) => RetMarshal::Scalar(s),
            None if normalize_primitive(name) == "void" => RetMarshal::Void,
            None => RetMarshal::OpaqueBox(None),
        },
        // A scalar-backed named typedef (`CGFloat`) returns by value as its scalar.
        TypeRefKind::Alias { name, .. }
        | TypeRefKind::Class { name, .. }
        | TypeRefKind::Struct { name }
            if scalar_typedef(name).is_some() =>
        {
            RetMarshal::ScalarTypedef {
                scalar: scalar_typedef(name).unwrap(),
                name: name.clone(),
            }
        }
        // An anonymous tuple (sentinel `Tuple`) cannot be spelled — box unnamed.
        TypeRefKind::Alias { name, .. }
        | TypeRefKind::Class { name, .. }
        | TypeRefKind::Struct { name }
            if is_unspellable_type_name(name) =>
        {
            RetMarshal::OpaqueBox(None)
        }
        // An ObjC/bridged object (`Class`) or `id`/`instancetype` is a real ObjC pointer:
        // hand it back raw and `aw-wrap` it Lisp-side to its exact bound type (ADR-0038
        // §4). A genuinely-Swift class would also land here; its dynamic ObjC class is
        // unbound, so `aw-wrap` walks to the nearest bound ancestor (NSObject worst case).
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            RetMarshal::Object
        }
        // A typedef alias (`NSTimeInterval`) names a valid in-scope Swift type; carry the
        // name so the by-name call's result can be pinned with `as <Type>` (disambiguates
        // cross-module return-type overloads). It is a value typedef, so it boxes.
        TypeRefKind::Alias { name, .. } => RetMarshal::OpaqueBox(Some(name.clone())),
        _ => RetMarshal::OpaqueBox(None),
    }
}

// ---------------------------------------------------------------------------
// Trampoline plans
// ---------------------------------------------------------------------------

/// A function the sbcl target trampolines: the resolved marshalling plan plus everything
/// both the Swift codegen and the sbcl emitter need, computed purely from
/// `(module, Function)` so the two sides agree without shared state.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FnTrampoline {
    /// Owning Swift module (the enclosing `Framework.name`) — the `import` target and the
    /// call's implicit namespace.
    pub module: String,
    /// Bare Swift function name (`Function.name`) used in the by-name call.
    pub swift_name: String,
    /// The **sbcl-visible** binding symbol — the `(defun ns:<name> …)` identifier. Equal
    /// to `qualified_top_level_name(swift_name)` (`ns:<kebab>`), except a same-module
    /// overload carries the same content hash its `entry` does (CL has no overloading, so
    /// two `(defun ns:show …)` would collide).
    pub binding_symbol: String,
    /// Content-addressed C entry symbol (`aw_sbcl_swift_<Fw>_<name>[_<hash>]`).
    pub entry: String,
    /// Per-param argument label (from `Param.name`); `"_"`/empty means no label. Drives the
    /// by-name `@_cdecl` call `name(label0: a0, …)`.
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    ret: RetMarshal,
    /// The Swift function `throws` — the trampoline takes a trailing `NSError **`.
    throwing: bool,
    /// The macOS version the wrapped API was `introduced:` (from IR provenance), emitted
    /// as `@available(macOS <v>, *)` on the `@_cdecl`. `None` when unversioned.
    availability: Option<String>,
}

/// A Swift-native constant the sbcl target trampolines: a `@_cdecl` reader that returns
/// the global's current value (Swift-native globals have no C symbol to resolve, so even
/// scalar ones need a reader).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConstTrampoline {
    pub module: String,
    pub swift_name: String,
    /// The sbcl-visible binding symbol (`ns:<kebab>`); constants are not overloadable.
    pub binding_symbol: String,
    pub entry: String,
    ret: RetMarshal,
    /// `@available(macOS <v>, *)` for a version-gated global; `None` otherwise.
    availability: Option<String>,
}

/// The macOS `introduced:` version from a declaration's IR provenance, if any. Public so
/// the `emit_class` routing folds an owning struct's version into its method gate exactly
/// as the global pass does (B3 agreement).
pub fn introduced_macos(
    provenance: &Option<apianyware_macos_types::provenance::SourceProvenance>,
) -> Option<String> {
    provenance
        .as_ref()
        .and_then(|p| p.availability.as_ref())
        .and_then(|a| a.introduced.clone())
}

/// Parse a dotted macOS version (`"26.4"`, `"15"`) into comparable components.
fn version_key(v: &str) -> Vec<u32> {
    v.split('.').map(|c| c.parse().unwrap_or(0)).collect()
}

/// The higher of two `@available(macOS …)` gates (B3). A method's own `introduced:` can
/// be **lower** than its owning type's (or absent while the type's is present): a
/// `@_cdecl` calling `Owner.method()` must be gated to the *max* of the two, else swiftc
/// rejects the call to the unavailable type (ADR-0030 addendum B3).
fn max_macos_version(a: Option<String>, b: Option<&str>) -> Option<String> {
    match (a, b) {
        (Some(a), Some(b)) => {
            if version_key(&a) >= version_key(b) {
                Some(a)
            } else {
                Some(b.to_string())
            }
        }
        (Some(a), None) => Some(a),
        (None, Some(b)) => Some(b.to_string()),
        (None, None) => None,
    }
}

/// A residual declaration that is **not** trampolined this leaf, recorded with a
/// machine-readable reason and surfaced in the pass log (spec §5).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Deferred {
    pub module: String,
    pub name: String,
    pub reason: DeferReason,
}

/// Why a residual declaration was not trampolined. Identical reason set to
/// racket/chez/gerbil (the residual is IR-deterministic).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DeferReason {
    /// Generic free function — `@_cdecl` cannot be generic; a *hard* limit.
    UnbindableGenericFreeFunction,
    /// `async` function — runtime-ready, codegen is a follow-up.
    Async,
    /// A non-Foundation-bridged Swift struct/tuple/existential **parameter** that is a
    /// *nameable value type* (or CF/ObjC reference, or bridged collection).
    NonBridgedStructParam,
    /// A closure / function-pointer **parameter**.
    ClosureParam,
    /// A parameter that is not a nameable type at all (`id`/`Any`, a raw pointer, a
    /// selector, …).
    UnnameableParam,
    /// A **generic method** (`generic_sig` present). Like a generic free function,
    /// `@_cdecl` cannot be generic — a hard limit.
    UnbindableGenericMethod,
    /// A `consuming self` method (D3): the call destroys the receiver, so the handle the
    /// sbcl side still holds would dangle. Deferred-with-count.
    ConsumingReceiver,
    /// A method whose base name is not a callable Swift identifier — an operator
    /// (`==`, `<`), a subscript — so `receiver.<name>(args)` does not parse.
    NonNameableMethod,
    /// A `static`/class method: no receiver instance to unbox; out of the sync structural
    /// perimeter, recorded + counted.
    StaticMethod,
    /// A variadic method — a flat `@_cdecl` cannot forward a Swift variadic.
    VariadicMethod,
    /// A method returning a **nullable scalar** (`Int?`) — a C scalar cannot carry `nil`.
    /// Nullable String/handle/object returns *are* handled (NULL/`nil`).
    NullableScalarReturn,
    /// An `async` **mutating value-receiver** method (D5/R4): the single-identity
    /// write-back (D3) is ill-defined across the async hop. Deferred-with-count.
    AsyncMutatingReceiver,
    /// An `async` method returning a **scalar** (`async -> Int`): `AwSbclAsyncOutcome`
    /// carries a pointer payload, not a scalar. Deferred-with-count.
    AsyncScalarReturn,

    // --- Curated-residual reasons (ADR-0030 addendum B4): swiftc rejects the @_cdecl for
    // a cause the lossy IR cannot predict. Suppressed via the [`KNOWN_UNBINDABLE`] table,
    // each counted under its own reason. Same decl *set* as racket/chez/gerbil. ---
    /// The method/init is **actor-isolated** (`@MainActor` or an `actor` member): a
    /// synchronous nonisolated `@_cdecl` cannot call it. `swift-api-digester` does not
    /// surface isolation at all, so this is curated.
    ActorIsolated,
    /// A `Module.Owner` whose owner name is not a spellable top-level member of the module
    /// (`CloudKit.ID` is really `CKRecord.ID`).
    ModuleMemberMissing,
    /// A type referenced in the call resolves to something that is not a member type — a
    /// nested or re-exported type the IR named unspellably.
    UnresolvedMemberType,
    /// An init/method parameter requires a **compile-time constant literal**
    /// (`@const`-position): the runtime-marshalled arg cannot satisfy it.
    CompileTimeConstantParam,
    /// A call whose **generic parameter could not be inferred** from the marshalled
    /// arguments — the method is not itself generic but the call site needs a type witness
    /// the C boundary cannot supply.
    GenericInferenceFailure,
    /// A `~Copyable` (noncopyable) receiver or value: `Unmanaged`/`as!` reconstruction is
    /// illegal on a noncopyable type.
    NoncopyableReceiver,
    /// The decl is only available in a macOS newer than the deployment floor, but its IR
    /// provenance (and its owning type's) carries **no** `introduced:` version — so no
    /// `@available` gate can be synthesised.
    UnknownAvailability,
    /// A method passing `self` (or a returned value) as an `inout` argument where the
    /// source is immutable: the by-value receiver copy is not addressable.
    ImmutableInoutArgument,
    /// The decl (or an overload swiftc selects) is `internal`/`private` — the by-name call
    /// cannot reach it even though the digester surfaced the symbol.
    InaccessibleDecl,
    /// The marshalled `@_cdecl` argument list does not match any overload's shape: the IR's
    /// flattened param list diverged from the real signature.
    ArgumentShapeMismatch,
}

impl DeferReason {
    /// The stable diagnostic string logged + recorded for this reason.
    pub fn as_str(self) -> &'static str {
        match self {
            DeferReason::UnbindableGenericFreeFunction => "unbindable_generic_free_function",
            DeferReason::Async => "deferred_async",
            DeferReason::NonBridgedStructParam => "deferred_nonbridged_struct_param",
            DeferReason::ClosureParam => "deferred_closure_param",
            DeferReason::UnnameableParam => "deferred_unnameable_param",
            DeferReason::UnbindableGenericMethod => "unbindable_generic_method",
            DeferReason::ConsumingReceiver => "deferred_consuming_receiver",
            DeferReason::NonNameableMethod => "deferred_non_nameable_method",
            DeferReason::StaticMethod => "deferred_static_method",
            DeferReason::VariadicMethod => "deferred_variadic_method",
            DeferReason::NullableScalarReturn => "deferred_nullable_scalar_return",
            DeferReason::AsyncMutatingReceiver => "deferred_async_mutating_receiver",
            DeferReason::AsyncScalarReturn => "deferred_async_scalar_return",
            DeferReason::ActorIsolated => "deferred_actor_isolated",
            DeferReason::ModuleMemberMissing => "deferred_module_member_missing",
            DeferReason::UnresolvedMemberType => "deferred_unresolved_member_type",
            DeferReason::CompileTimeConstantParam => "deferred_compile_time_constant_param",
            DeferReason::GenericInferenceFailure => "deferred_generic_inference_failure",
            DeferReason::NoncopyableReceiver => "deferred_noncopyable_receiver",
            DeferReason::UnknownAvailability => "deferred_unknown_availability",
            DeferReason::ImmutableInoutArgument => "deferred_immutable_inout_argument",
            DeferReason::InaccessibleDecl => "deferred_inaccessible_decl",
            DeferReason::ArgumentShapeMismatch => "deferred_argument_shape_mismatch",
        }
    }
}

/// The whole-program trampoline plan: what to emit into `Trampolines.swift` and what was
/// deferred. Built once over all enriched frameworks by the global pass.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct TrampolineSet {
    pub functions: Vec<FnTrampoline>,
    pub constants: Vec<ConstTrampoline>,
    /// Receiver-handle method trampolines (the method frontier, ADR-0030).
    pub methods: Vec<MethodTrampoline>,
    /// Initializer producers — the population-B root handle producers (D2).
    pub inits: Vec<InitTrampoline>,
    pub deferred: Vec<Deferred>,
}

impl TrampolineSet {
    /// Per-reason deferred counts, for the pass log.
    pub fn defer_counts(&self) -> BTreeMap<&'static str, usize> {
        let mut counts: BTreeMap<&'static str, usize> = BTreeMap::new();
        for d in &self.deferred {
            *counts.entry(d.reason.as_str()).or_default() += 1;
        }
        counts
    }
}

// ---------------------------------------------------------------------------
// Classification (shared by the pass and the emitter)
// ---------------------------------------------------------------------------

/// The disposition of a residual function: bind a trampoline, or defer (recorded).
pub enum FnDisposition {
    Trampoline(FnTrampoline),
    Deferred(DeferReason),
}

/// The owning framework's own value-struct names — the gate for the
/// [`ArgMarshal::BoxedHandle`] param-unbox path.
pub fn value_struct_names(structs: &[Struct]) -> HashSet<&str> {
    structs.iter().map(|s| s.name.as_str()).collect()
}

/// Classify a Swift-native (`objc_exposed == false`) function. `siblings` is the full
/// residual-function set of the *same* module (used only for overload disambiguation in
/// the entry/binding name). `value_structs` gates unboxing a value-struct parameter.
pub fn classify_function(
    module: &str,
    func: &Function,
    siblings: &[Function],
    value_structs: &HashSet<&str>,
) -> FnDisposition {
    if let Some(info) = &func.swift_fn {
        if info.is_generic {
            return FnDisposition::Deferred(DeferReason::UnbindableGenericFreeFunction);
        }
        if info.is_async {
            return FnDisposition::Deferred(DeferReason::Async);
        }
    }

    let mut params = Vec::with_capacity(func.params.len());
    for p in &func.params {
        match classify_param(&p.param_type, value_structs) {
            Ok(m) => params.push(m),
            Err(reason) => return FnDisposition::Deferred(reason),
        }
    }
    let ret = classify_return(&func.return_type);
    let throwing = func.swift_fn.as_ref().is_some_and(|i| i.throwing);
    let labels: Vec<String> = func.params.iter().map(|p| p.name.clone()).collect();
    let overloaded = is_overloaded(func, siblings);
    let binding_symbol = if overloaded {
        format!(
            "{}-{}",
            qualified_top_level_name(&func.name),
            overload_hash(func)
        )
    } else {
        qualified_top_level_name(&func.name)
    };
    let entry = function_entry_name(module, func, siblings);

    FnDisposition::Trampoline(FnTrampoline {
        module: module.to_string(),
        swift_name: func.name.clone(),
        binding_symbol,
        entry,
        labels,
        params,
        ret,
        throwing,
        availability: introduced_macos(&func.provenance),
    })
}

/// Classify a Swift-native constant. Always trampolinable (the return rep is total), so
/// this returns the plan directly.
pub fn classify_constant(module: &str, constant: &Constant) -> ConstTrampoline {
    ConstTrampoline {
        module: module.to_string(),
        swift_name: constant.name.clone(),
        binding_symbol: qualified_top_level_name(&constant.name),
        entry: constant_entry_name(module, &constant.name),
        ret: classify_return(&constant.constant_type),
        availability: introduced_macos(&constant.provenance),
    }
}

// ---------------------------------------------------------------------------
// Entry naming (content-addressed; emitter reconstructs the same symbol)
// ---------------------------------------------------------------------------

/// Sanitise a module/name fragment into a valid C-identifier tail.
fn sanitize(fragment: &str) -> String {
    fragment
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '_' })
        .collect()
}

/// A short, stable hex hash of an overloaded function's argument-label + ABI shape,
/// appended to the entry name so two overloads of the same `(module, name)` get distinct
/// symbols computable without a global counter (ADR-0013 precedent).
fn overload_hash(func: &Function) -> String {
    // FNV-1a over the printed param/return shape — deterministic and dependency-free.
    let mut h: u64 = 0xcbf2_9ce4_8422_2325;
    let mut feed = |s: &str| {
        for b in s.bytes() {
            h ^= b as u64;
            h = h.wrapping_mul(0x0000_0100_0000_01b3);
        }
        h ^= 0xff;
        h = h.wrapping_mul(0x0000_0100_0000_01b3);
    };
    for p in &func.params {
        feed(&p.name);
        feed(&type_shape(&p.param_type));
    }
    feed(&type_shape(&func.return_type));
    format!("{:08x}", (h ^ (h >> 32)) as u32)
}

/// A coarse stable string for a `TypeRef`'s shape — enough to distinguish overloads.
fn type_shape(t: &TypeRef) -> String {
    let body = match &t.kind {
        TypeRefKind::Primitive { name } => format!("p:{}", normalize_primitive(name)),
        TypeRefKind::Class { name, .. } => format!("c:{name}"),
        TypeRefKind::Alias { name, .. } => format!("a:{name}"),
        TypeRefKind::Struct { name } => format!("s:{name}"),
        TypeRefKind::Id => "id".into(),
        TypeRefKind::Instancetype => "instancetype".into(),
        TypeRefKind::CString => "cstr".into(),
        TypeRefKind::Pointer => "ptr".into(),
        TypeRefKind::Selector => "sel".into(),
        TypeRefKind::ClassRef => "classref".into(),
        TypeRefKind::Block { .. } => "block".into(),
        TypeRefKind::FunctionPointer { .. } => "fnptr".into(),
    };
    if t.nullable {
        format!("?{body}")
    } else {
        body
    }
}

/// True when `(module, func.name)` is overloaded within `siblings`.
fn is_overloaded(func: &Function, siblings: &[Function]) -> bool {
    siblings
        .iter()
        .filter(|f| !f.objc_exposed && f.name == func.name)
        .count()
        > 1
}

/// The content-addressed function entry symbol.
fn function_entry_name(module: &str, func: &Function, siblings: &[Function]) -> String {
    let base = format!("{FN_PREFIX}{}_{}", sanitize(module), sanitize(&func.name));
    if is_overloaded(func, siblings) {
        format!("{base}_{}", overload_hash(func))
    } else {
        base
    }
}

/// The constant entry symbol. Constants are not overloadable, so no hash.
fn constant_entry_name(module: &str, name: &str) -> String {
    format!("{CONST_PREFIX}{}_{}", sanitize(module), sanitize(name))
}

// ---------------------------------------------------------------------------
// Collection over enriched frameworks
// ---------------------------------------------------------------------------

/// Collect the whole-program trampoline plan: every retained `objc_exposed == false`
/// function (trampolined or deferred) and constant across all frameworks. The walk
/// matches racket/chez/gerbil **exactly** (it filters only on `objc_exposed`, so the §6d
/// invariant reproduces) — the inline/variadic gate the 040 `collect_*_residual` helpers
/// apply is a no-op here (Swift-ABI residual decls carry no C `inline`/`variadic` flag).
pub fn collect_trampolines(frameworks: &[Framework]) -> TrampolineSet {
    let mut set = TrampolineSet::default();
    for fw in frameworks {
        let value_structs = value_struct_names(&fw.structs);
        for func in &fw.functions {
            if func.objc_exposed {
                continue; // direct-bound (trampoline-elided)
            }
            match classify_function(&fw.name, func, &fw.functions, &value_structs) {
                FnDisposition::Trampoline(t) => set.functions.push(t),
                FnDisposition::Deferred(reason) => set.deferred.push(Deferred {
                    module: fw.name.clone(),
                    name: func.name.clone(),
                    reason,
                }),
            }
        }
        for constant in &fw.constants {
            if constant.objc_exposed {
                continue;
            }
            set.constants.push(classify_constant(&fw.name, constant));
        }
        // Receiver-handle method + init trampolines (the method frontier, ADR-0030). Walk
        // both classes (reference receivers) and structs (value receivers); a method is
        // Swift-native iff it carries `swift_fn` (⇔ `objc_exposed == false`).
        for c in &fw.classes {
            // `Class` carries no `provenance` field (unlike `Struct`); the type-gated
            // availability residual is entirely value-struct owners (B3).
            collect_type_methods(
                &mut set,
                &fw.name,
                &c.name,
                true,
                &c.methods,
                &value_structs,
                None,
            );
        }
        for st in &fw.structs {
            let owner_intro = introduced_macos(&st.provenance);
            collect_type_methods(
                &mut set,
                &fw.name,
                &st.name,
                false,
                &st.methods,
                &value_structs,
                owner_intro.as_deref(),
            );
        }
    }
    // Remap each class-owner trampoline's `swift_owner` to the owning class's Swift name
    // (the obsoleted ObjC runtime name does not compile as a Swift type — `NSScanner` →
    // `Scanner`). The entry symbol + Lisp specializer keep the runtime `owner`; only the
    // `@_cdecl` body's type reference uses `swift_owner`. Struct (value) owners are not
    // overlay-renamed, so they keep the default (`owner`).
    let swift_owner_of: HashMap<(&str, &str), &str> = frameworks
        .iter()
        .flat_map(|fw| {
            fw.classes.iter().map(move |c| {
                (
                    (fw.name.as_str(), c.name.as_str()),
                    c.swift_name.as_deref().unwrap_or(&c.name),
                )
            })
        })
        .collect();
    for t in &mut set.methods {
        if let Some(sn) = swift_owner_of.get(&(t.module.as_str(), t.owner.as_str())) {
            t.swift_owner = sn.to_string();
        }
    }
    for t in &mut set.inits {
        if let Some(sn) = swift_owner_of.get(&(t.module.as_str(), t.owner.as_str())) {
            t.swift_owner = sn.to_string();
        }
    }

    // A duplicate entry *is* the same trampoline (a category re-listing, a digester dupe),
    // which would otherwise emit two `@_cdecl`s with the identical content-addressed entry
    // — a Swift redeclaration error. Keep the first per entry.
    dedup_by_entry(&mut set);
    set
}

/// Drop duplicate trampolines that resolve to the same C entry symbol (keep first).
fn dedup_by_entry(set: &mut TrampolineSet) {
    let mut seen = HashSet::new();
    set.functions.retain(|t| seen.insert(t.entry.clone()));
    set.constants.retain(|t| seen.insert(t.entry.clone()));
    set.inits.retain(|t| seen.insert(t.entry.clone()));
    set.methods.retain(|t| seen.insert(t.entry.clone()));
}

/// Collect the method/init trampolines (or deferrals) for one owning type's method list —
/// `owner_is_class` selects the reference (`Unmanaged`) vs value (`AwSbclValueBox`)
/// receiver path.
fn collect_type_methods(
    set: &mut TrampolineSet,
    module: &str,
    owner: &str,
    owner_is_class: bool,
    methods: &[Method],
    value_structs: &HashSet<&str>,
    owner_introduced: Option<&str>,
) {
    for m in methods {
        if m.swift_fn.is_none() {
            continue; // ObjC method — binds via msgSend, no trampoline
        }
        match classify_method(
            module,
            owner,
            owner_is_class,
            m,
            methods,
            value_structs,
            owner_introduced,
        ) {
            MethodDisposition::Method(t) => set.methods.push(t),
            MethodDisposition::Init(t) => set.inits.push(t),
            MethodDisposition::Deferred(reason) => set.deferred.push(Deferred {
                module: module.to_string(),
                name: format!("{owner}.{}", method_base_name(&m.selector)),
                reason,
            }),
        }
    }
}

/// Collect a **class** owner's bindable Swift-native instance-method trampolines (045)
/// — the receiver-handle methods whose `(defmethod …)` the class file renders, in
/// lockstep with the `defgeneric`s [`crate::emit_generics::collect_generics`] folds in.
/// `methods` MUST be the owner's *declared* methods (`cls.methods`), matching the
/// global pass (the §6d agreement). Sync methods only: `async` residual methods are
/// runtime-coupled (the completion-callback bridge) and deferred to a follow-up. Within
/// the owner, two methods that collapse to the same generic name keep the **first** (a
/// CLOS generic cannot carry two methods with one receiver specializer + arity).
pub fn class_residual_methods(
    module: &str,
    owner: &str,
    methods: &[Method],
) -> Vec<MethodTrampoline> {
    let no_value_structs = HashSet::new();
    let mut out: Vec<MethodTrampoline> = Vec::new();
    let mut seen: HashSet<String> = HashSet::new();
    for m in methods {
        if m.swift_fn.is_none() {
            continue; // ObjC method — binds via msgSend, no trampoline
        }
        if let MethodDisposition::Method(t) =
            classify_method(module, owner, true, m, methods, &no_value_structs, None)
        {
            if t.is_async() {
                continue; // async residual: runtime-coupled, follow-up leaf
            }
            if seen.insert(t.generic_decl().0) {
                out.push(t);
            }
        }
    }
    out
}

/// Collect a **class** owner's bindable Swift-native initializer producers (045) — the
/// `(defun ns:make-<owner>… )` constructors the class file renders. `methods` MUST be
/// the owner's declared methods (the §6d agreement). Two inits collapsing to one
/// constructor symbol keep the first.
pub fn class_residual_inits(module: &str, owner: &str, methods: &[Method]) -> Vec<InitTrampoline> {
    let no_value_structs = HashSet::new();
    let mut out: Vec<InitTrampoline> = Vec::new();
    let mut seen: HashSet<String> = HashSet::new();
    for m in methods {
        if m.swift_fn.is_none() {
            continue;
        }
        if let MethodDisposition::Init(t) =
            classify_method(module, owner, true, m, methods, &no_value_structs, None)
        {
            if seen.insert(t.binding_symbol()) {
                out.push(t);
            }
        }
    }
    out
}

// ===========================================================================
// Receiver-handle method trampolines (the Swift-native method frontier, ADR-0030)
// ===========================================================================
//
// A method trampoline generalises [`FnTrampoline`]'s call-by-name from free functions to
// methods: the `@_cdecl` takes an **opaque receiver handle** as its first C param,
// reconstructs the receiver, and calls `receiver.method(labels:)` by name. An
// [`InitTrampoline`] is the population-B *root producer*: it calls `Owner(labels:)` and
// boxes a handle of the owning type. Receiver marshalling is by the **owner's kind**: a
// class owner is `Unmanaged<Owner>.fromOpaque(recv).takeUnretainedValue()`; a value
// struct owner is `awSbclUnbox(recv, as: Owner.self)` with mutating write-back (D3). sbcl
// binds the entries with a per-signature `sb-alien` crossing (the receiver coerces
// through `(aw-ptr self)`); an **object** return `aw-wrap`s to its exact bound type via
// the ADR-0034 registry (the sbcl divergence, ADR-0038 §4), a value return rides the box.

/// How a method's receiver (`self`) is reconstructed from its opaque handle.
#[derive(Debug, Clone, PartialEq, Eq)]
enum SelfMarshal {
    /// A **class** owner (objc-exposed instance held as `id`, or a Swift-native class
    /// boxed via `Unmanaged.passRetained`) — both reference types reconstructed
    /// identically: `Unmanaged<M.O>.fromOpaque(recv).takeUnretainedValue()`.
    ClassRef,
    /// A **value struct** owner (population B): the receiver is an `AwSbclValueBox`
    /// handle. `mutating` selects the write-back path (`var v = box.value as! T;
    /// v.method(); box.value = v`) so the sbcl side's handle reflects the mutation (D3);
    /// non-mutating just unboxes a copy.
    ValueBox { mutating: bool },
}

/// A Swift-native instance method the sbcl target trampolines: a `@_cdecl` taking an
/// opaque receiver handle + the marshalled args, calling `receiver.name(labels:)`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MethodTrampoline {
    pub module: String,
    /// The owning type's **ObjC runtime name** — the entry-symbol stem and the Lisp
    /// `defmethod` receiver specializer (`ns:<owner>`). Equals `swift_owner` unless the
    /// Swift overlay renamed the class.
    pub owner: String,
    /// The owning type's **Swift name** — what the `@_cdecl` body spells as the receiver
    /// type (`Unmanaged<module.swift_owner>`), since the obsoleted ObjC runtime name does
    /// not compile as a Swift type (`NSScanner` → `Scanner`). Set to `owner` by
    /// `classify_method`; remapped from the class's `swift_name` in [`collect_trampolines`].
    pub swift_owner: String,
    /// Base method name (the selector up to `(`), used in the by-name call.
    pub swift_name: String,
    /// Content-addressed C entry symbol (`aw_sbcl_swift_m_<Fw>_<Owner>_<base>[_<hash>]`).
    pub entry: String,
    recv: SelfMarshal,
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    ret: RetMarshal,
    /// The return type is `Optional` — the marshalling maps `nil` to NULL/`nil`
    /// (String/handle/object returns); a nullable *scalar* return is deferred upstream.
    ret_nullable: bool,
    throwing: bool,
    /// The method is `async` (D5/R4): instead of a synchronous return, the `@_cdecl` takes
    /// a trailing ctx + C completion callback and drives `awSbclAsyncDispatch`.
    is_async: bool,
    availability: Option<String>,
}

/// An initializer producer — the population-B root handle producer (D2). Calls
/// `Owner(labels:)` and returns a boxed handle of the **owning type** (a value box for a
/// struct owner, an `Unmanaged.passRetained` instance for a class owner).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct InitTrampoline {
    pub module: String,
    pub owner: String,
    /// The owning type's **Swift name** — what the `@_cdecl` body spells as the
    /// constructed type (`module.swift_owner(labels:)`), since the obsoleted ObjC runtime
    /// name does not compile as a Swift type. Set to `owner` by `classify_method`;
    /// remapped from the class's `swift_name` in [`collect_trampolines`].
    pub swift_owner: String,
    pub entry: String,
    /// Box a class instance via `Unmanaged.passRetained` (reference identity) vs a value
    /// via `awSbclBox` — picked from the owner's kind, not the lossy IR return type (R2:
    /// `init(integer:)` reports `NSIndexSet`, must box `IndexSet`). On the sbcl side a
    /// class init additionally `aw-wrap`s the returned id to its exact bound type
    /// (ADR-0038 §4); a value init hands back the raw opaque handle.
    owner_is_class: bool,
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    throwing: bool,
    availability: Option<String>,
}

/// The disposition of a Swift-native method: an instance-method trampoline, an
/// initializer producer, or a recorded deferral.
pub enum MethodDisposition {
    Method(MethodTrampoline),
    Init(InitTrampoline),
    Deferred(DeferReason),
}

/// The base method name = the selector up to the first `(` (`update(with:)` → `update`,
/// `init(integer:)` → `init`, `contains(_:)` → `contains`).
fn method_base_name(selector: &str) -> &str {
    selector.split('(').next().unwrap_or(selector)
}

/// Is `name` a callable Swift identifier (so `receiver.name(args)` parses)? Filters out
/// operators (`==`, `<`) and other non-identifier selectors.
fn is_identifier(name: &str) -> bool {
    let mut chars = name.chars();
    matches!(chars.next(), Some(c) if c.is_ascii_alphabetic() || c == '_')
        && name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_')
}

/// The curated suppression table (ADR-0030 addendum B4): decls swiftc rejects for a cause
/// the lossy IR cannot mechanically predict — `@MainActor`/actor isolation (which
/// `swift-api-digester` does not emit at all) and a scatter of per-decl semantic failures.
/// Keyed by the **sbcl** content-addressed entry name (the one `method_entry_name` /
/// `init_entry_name` compute and swiftc names in the build error), so suppression is exact
/// per overload and reproduces from a cold collect. **Same decl set** as
/// racket's/chez's/gerbil's (the residual is IR-deterministic — the suffix after the prefix
/// and the overload hash are target-independent), under the sbcl `aw_sbcl_swift_*` prefix.
/// The full-residual `swift build` is the regression guard — a stale entry re-surfaces as
/// a compile error.
const KNOWN_UNBINDABLE: &[(&str, DeferReason)] = &[
    ("aw_sbcl_swift_init_AppIntents_IntentCollectionSize_66a66a84", DeferReason::CompileTimeConstantParam),
    ("aw_sbcl_swift_init_AppIntents_IntentCollectionSize_8398302c", DeferReason::CompileTimeConstantParam),
    ("aw_sbcl_swift_init_AuthenticationServices_ASCredentialDataManager", DeferReason::UnknownAvailability),
    ("aw_sbcl_swift_init_CloudKit_ID_180762ef", DeferReason::ModuleMemberMissing),
    ("aw_sbcl_swift_init_CloudKit_ID_c6665c26", DeferReason::ModuleMemberMissing),
    ("aw_sbcl_swift_init_IdentityDocumentServicesUI_IdentityDocumentWebPresentmentController", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_init_ImagePlayground_ImageCreator", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_init_ImmersiveMediaSupport_ImmersiveMediaRemotePreviewReceiver", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_init_MediaExtension_Boolean", DeferReason::ModuleMemberMissing),
    ("aw_sbcl_swift_init_MediaExtension_FloatingPoint", DeferReason::ModuleMemberMissing),
    ("aw_sbcl_swift_init_MediaExtension_Integer", DeferReason::ModuleMemberMissing),
    ("aw_sbcl_swift_init_RealityFoundation_RealityRenderer", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_init_StoreKit_AdvancedCommerceProduct", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_init_SwiftUICore_PropertyList", DeferReason::ModuleMemberMissing),
    ("aw_sbcl_swift_init_SwiftUICore_RectangleCornerRadii_dfe2fe2f", DeferReason::ArgumentShapeMismatch),
    ("aw_sbcl_swift_init_Translation_LanguageAvailability_960d49c3", DeferReason::UnresolvedMemberType),
    ("aw_sbcl_swift_init_WebKit_URLScheme", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_AuthenticationServices_ASCredentialDataManager_reportUnusedPasswordCredential", DeferReason::UnknownAvailability),
    ("aw_sbcl_swift_m_CompositorServices_Frame_predictTiming", DeferReason::GenericInferenceFailure),
    ("aw_sbcl_swift_m_CompositorServices_Frame_queryDrawables", DeferReason::GenericInferenceFailure),
    ("aw_sbcl_swift_m_CoreHID_HIDDeviceClient_seizeDevice", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_CoreVideo_CVMutablePixelBuffer_fillExtendedPixels", DeferReason::NoncopyableReceiver),
    ("aw_sbcl_swift_m_ImmersiveMediaSupport_VenueDescriptor_cameraViewModel", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_ImmersiveMediaSupport_VenueDescriptor_removeCamera", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_ImmersiveMediaSupport_VenueDescriptor_save", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_RealityFoundation_AudioGeneratorController_play", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_RealityFoundation_AudioGeneratorController_stop", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_RealityFoundation_EntityGeometricPins_makeIterator", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_RealityFoundation_EntityGeometricPins_remove", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_RealityFoundation_LowLevelTexture_read", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_RealityFoundation_MeshInstanceCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_sbcl_swift_m_RealityFoundation_MeshModelCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_sbcl_swift_m_RealityFoundation_MeshPartCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_sbcl_swift_m_RealityFoundation_MeshSkeletonCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_sbcl_swift_m_RealityFoundation_RealityRenderer_update", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_SwiftUICore_EdgeInsets_round_61f6b07c", DeferReason::InaccessibleDecl),
    ("aw_sbcl_swift_m_SwiftUICore_EdgeInsets_rounded_c7dec5cb", DeferReason::InaccessibleDecl),
    ("aw_sbcl_swift_m_Translation_TranslationSession_cancel", DeferReason::UnresolvedMemberType),
    ("aw_sbcl_swift_m_Translation_TranslationSession_prepareTranslation", DeferReason::UnresolvedMemberType),
    ("aw_sbcl_swift_m_Translation_TranslationSession_translate_770bd52c", DeferReason::UnresolvedMemberType),
    ("aw_sbcl_swift_m_VisionKit_ImageAnalysisOverlayView_beginSubjectAnalysisIfNecessary", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_VisionKit_ImageAnalysisOverlayView_resetSelection", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_VisionKit_ImageAnalysisOverlayView_setContentsRectNeedsUpdate", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_VisionKit_ImageAnalysisOverlayView_setSupplementaryInterfaceHidden", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_WebKit_WebPage_load_4808a66d", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_WebKit_WebPage_load_60456c20", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_WebKit_WebPage_load_6dde058d", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_WebKit_WebPage_load_77ec487a", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_WebKit_WebPage_reload", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m_WebKit_WebPage_stopLoading", DeferReason::ActorIsolated),
    ("aw_sbcl_swift_m__StoreKit_SwiftUI_RequestReviewAction_callAsFunction", DeferReason::ActorIsolated),
];

/// Look up a method/init in [`KNOWN_UNBINDABLE`] by its content-addressed entry name.
fn known_unbindable(
    module: &str,
    owner: &str,
    method: &Method,
    siblings: &[Method],
) -> Option<DeferReason> {
    let entry = if method.init_method {
        init_entry_name(module, owner, method, siblings)
    } else {
        method_entry_name(module, owner, method, siblings)
    };
    KNOWN_UNBINDABLE
        .iter()
        .find(|(e, _)| *e == entry)
        .map(|(_, r)| *r)
}

/// Classify one Swift-native method on a type. `owner_is_class` is true for a
/// `Framework.classes` reference type (→ `Unmanaged` receiver path), false for a
/// `Framework.structs` value type (→ `AwSbclValueBox` path). `siblings` is the owner's
/// full method list (overload disambiguation); `value_structs` is reserved (value-struct
/// method params defer this leaf). Mirrors racket/chez/gerbil `classify_method` exactly so
/// the sbcl residual reproduces theirs (the §6d invariant).
#[allow(clippy::too_many_arguments)]
pub fn classify_method(
    module: &str,
    owner: &str,
    owner_is_class: bool,
    method: &Method,
    siblings: &[Method],
    // Reserved: value-struct **method** params are deferred this leaf (nested type names
    // like `Data.Base64EncodingOptions` are not bare-spellable). Object params ride R1.
    _value_structs: &HashSet<&str>,
    // The owning type's `introduced:` macOS version, folded into the `@available` gate.
    owner_introduced: Option<&str>,
) -> MethodDisposition {
    // Curated suppression first (B4) — keyed by the content-addressed entry name, so the
    // global pass and the emitter agree.
    if let Some(reason) = known_unbindable(module, owner, method, siblings) {
        return MethodDisposition::Deferred(reason);
    }
    let info = method.swift_fn.as_ref();
    if let Some(i) = info {
        if i.is_generic {
            return MethodDisposition::Deferred(DeferReason::UnbindableGenericMethod);
        }
        if i.self_kind.as_deref() == Some("Consuming") {
            return MethodDisposition::Deferred(DeferReason::ConsumingReceiver);
        }
    }
    // Static/class methods have no receiver instance — out of the instance-method
    // perimeter, recorded + counted.
    if method.class_method && !method.init_method {
        return MethodDisposition::Deferred(DeferReason::StaticMethod);
    }
    if method.variadic {
        return MethodDisposition::Deferred(DeferReason::VariadicMethod);
    }

    // Args reuse the free-function scalar/string taxonomy; value-struct params defer
    // (empty struct set). The first non-bindable param's reason wins.
    let no_value_structs = HashSet::new();
    let mut params = Vec::with_capacity(method.params.len());
    for p in &method.params {
        match classify_param(&p.param_type, &no_value_structs) {
            Ok(m) => params.push(m),
            Err(reason) => return MethodDisposition::Deferred(reason),
        }
    }
    let labels: Vec<String> = method.params.iter().map(|p| p.name.clone()).collect();
    let throwing = info.is_some_and(|i| i.throwing);
    let availability = max_macos_version(introduced_macos(&method.provenance), owner_introduced);

    if method.init_method {
        // Object-ref params (R1) bridge to a value twin, right for a method call but wrong
        // for a bridging *constructor* (`Data(referencing: NSData)` wants the reference);
        // the lossy IR cannot tell them apart, so init object params defer (a
        // no-regression carve-out — they deferred pre-R1).
        if params
            .iter()
            .any(|m| matches!(m, ArgMarshal::ObjectRef { .. }))
        {
            return MethodDisposition::Deferred(DeferReason::NonBridgedStructParam);
        }
        return MethodDisposition::Init(InitTrampoline {
            module: module.to_string(),
            owner: owner.to_string(),
            // Defaults to the runtime name; [`collect_trampolines`] remaps renamed classes.
            swift_owner: owner.to_string(),
            entry: init_entry_name(module, owner, method, siblings),
            owner_is_class,
            labels,
            params,
            throwing,
            availability,
        });
    }

    let base = method_base_name(&method.selector);
    if !is_identifier(base) {
        return MethodDisposition::Deferred(DeferReason::NonNameableMethod);
    }

    // A method's non-scalar return boxes/wraps **unnamed**: an object return wraps to its
    // bound type (no `as <Type>` pin needed), a value return boxes; the lossy IR often
    // yields an unspellable/inaccessible return name. A nullable scalar can't carry `nil`.
    let ret_nullable = method.return_type.nullable;
    let ret = match classify_return(&method.return_type) {
        RetMarshal::OpaqueBox(_) => RetMarshal::OpaqueBox(None),
        RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } if ret_nullable => {
            return MethodDisposition::Deferred(DeferReason::NullableScalarReturn);
        }
        other => other,
    };

    // Write-back only applies to value receivers; a class receiver is a reference.
    let mutating =
        !owner_is_class && info.and_then(|i| i.self_kind.as_deref()) == Some("Mutating");

    // Async (D5/R4): drives the completion-callback bridge instead of a synchronous
    // return. Two sub-cases defer-with-count: a `mutating` value receiver (write-back
    // ill-defined across the hop) and a scalar return (`AwSbclAsyncOutcome` carries a
    // pointer payload).
    let is_async = info.is_some_and(|i| i.is_async);
    if is_async {
        if mutating {
            return MethodDisposition::Deferred(DeferReason::AsyncMutatingReceiver);
        }
        if matches!(ret, RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. }) {
            return MethodDisposition::Deferred(DeferReason::AsyncScalarReturn);
        }
    }

    let recv = if owner_is_class {
        SelfMarshal::ClassRef
    } else {
        SelfMarshal::ValueBox { mutating }
    };
    MethodDisposition::Method(MethodTrampoline {
        module: module.to_string(),
        owner: owner.to_string(),
        // Defaults to the runtime name; [`collect_trampolines`] remaps renamed classes.
        swift_owner: owner.to_string(),
        swift_name: base.to_string(),
        entry: method_entry_name(module, owner, method, siblings),
        recv,
        labels,
        params,
        ret,
        ret_nullable,
        throwing,
        is_async,
        availability,
    })
}

// --- Method/init entry naming (content-addressed; emitter reconstructs it) ---

/// FNV-1a hash of a method's selector + param/return ABI shape — appended when
/// `(module, owner, base)` is overloaded (same precedent as [`overload_hash`]).
fn method_hash(method: &Method) -> String {
    let mut h: u64 = 0xcbf2_9ce4_8422_2325;
    let mut feed = |s: &str| {
        for b in s.bytes() {
            h ^= b as u64;
            h = h.wrapping_mul(0x0000_0100_0000_01b3);
        }
        h ^= 0xff;
        h = h.wrapping_mul(0x0000_0100_0000_01b3);
    };
    feed(&method.selector);
    for p in &method.params {
        feed(&p.name);
        feed(&type_shape(&p.param_type));
    }
    feed(&type_shape(&method.return_type));
    format!("{:08x}", (h ^ (h >> 32)) as u32)
}

/// True when a Swift-native instance method's base name is overloaded among the owner's
/// Swift-native instance methods.
fn method_is_overloaded(method: &Method, siblings: &[Method]) -> bool {
    let base = method_base_name(&method.selector);
    siblings
        .iter()
        .filter(|m| {
            m.swift_fn.is_some()
                && !m.init_method
                && !m.class_method
                && method_base_name(&m.selector) == base
        })
        .count()
        > 1
}

/// True when an initializer is overloaded among the owner's Swift-native inits.
fn init_is_overloaded(siblings: &[Method]) -> bool {
    siblings
        .iter()
        .filter(|m| m.swift_fn.is_some() && m.init_method)
        .count()
        > 1
}

fn method_entry_name(module: &str, owner: &str, method: &Method, siblings: &[Method]) -> String {
    let base = format!(
        "{FN_PREFIX}m_{}_{}_{}",
        sanitize(module),
        sanitize(owner),
        sanitize(method_base_name(&method.selector))
    );
    if method_is_overloaded(method, siblings) {
        format!("{base}_{}", method_hash(method))
    } else {
        base
    }
}

fn init_entry_name(module: &str, owner: &str, method: &Method, siblings: &[Method]) -> String {
    let base = format!("{FN_PREFIX}init_{}_{}", sanitize(module), sanitize(owner));
    if init_is_overloaded(siblings) {
        format!("{base}_{}", method_hash(method))
    } else {
        base
    }
}

// ===========================================================================
// Swift codegen (Generated/Trampolines.swift)
// ===========================================================================

/// The per-argument `label: value` strings inside a by-name call's parentheses,
/// reconstructing each marshalled param from its `@_cdecl` boundary binding. Shared by the
/// free-function [`call_expr`] and the method/init call builders. The method/init path
/// opts into `numeric_cast` (IR width collapse); free functions keep the bare pass-through.
fn arg_values(params: &[ArgMarshal], labels: &[String], numeric_cast: bool) -> Vec<String> {
    params
        .iter()
        .zip(labels)
        .enumerate()
        .map(|(i, (m, label))| {
            let value = match m {
                ArgMarshal::Scalar(s) if numeric_cast && s.is_integer() => {
                    format!("numericCast(a{i})")
                }
                ArgMarshal::Scalar(_) => format!("a{i}"),
                ArgMarshal::ScalarTypedef { name, .. } => format!("{name}(a{i})"),
                ArgMarshal::SwiftString => format!("s{i}"),
                ArgMarshal::BoxedHandle { .. } => format!("u{i}"),
                ArgMarshal::ObjectRef { .. } => format!("o{i}"),
            };
            if label == "_" || label.is_empty() {
                value
            } else {
                format!("{label}: {value}")
            }
        })
        .collect()
}

/// Render the by-name call expression `name(label0: a0, label1: s1, …)`.
fn call_expr(t: &FnTrampoline) -> String {
    // Module-qualify the call so a free function a second imported module also exports is
    // unambiguous; the owning module is always in scope (we `import` it).
    format!(
        "{}.{}({})",
        t.module,
        t.swift_name,
        arg_values(&t.params, &t.labels, false).join(", ")
    )
}

/// The `@_cdecl` parameter list (named) and the body's reconstruction prelude, for a
/// sequence of marshalled args. The receiver-handle method/init trampolines reuse this for
/// their *argument* params (the receiver is prepended separately).
fn args_decl_and_prelude(params: &[ArgMarshal]) -> (Vec<String>, String) {
    let mut decl = Vec::with_capacity(params.len());
    let mut prelude = String::new();
    for (i, m) in params.iter().enumerate() {
        match m {
            ArgMarshal::Scalar(s) => decl.push(format!("_ a{i}: {}", s.swift())),
            ArgMarshal::ScalarTypedef { scalar, .. } => {
                decl.push(format!("_ a{i}: {}", scalar.swift()))
            }
            ArgMarshal::SwiftString => {
                decl.push(format!("_ a{i}: UnsafeMutableRawPointer?"));
                prelude.push_str(&format!(
                    "  let s{i} = Unmanaged<NSString>.fromOpaque(a{i}!).takeUnretainedValue() as String\n"
                ));
            }
            ArgMarshal::BoxedHandle { name } => {
                decl.push(format!("_ a{i}: UnsafeMutableRawPointer?"));
                prelude.push_str(&format!("  let u{i} = awSbclUnbox(a{i}!, as: {name}.self)\n"));
            }
            ArgMarshal::ObjectRef {
                class_name,
                bridge_to,
            } => {
                decl.push(format!("_ a{i}: UnsafeMutableRawPointer?"));
                prelude.push_str(&format!(
                    "  let o{i} = Unmanaged<{class_name}>.fromOpaque(a{i}!).takeUnretainedValue() as {bridge_to}\n"
                ));
            }
        }
    }
    (decl, prelude)
}

/// Marshals a call expression (`{call}`) to the `@_cdecl` boundary's C rep.
type Marshaller = Box<dyn Fn(&str) -> String>;

/// The C return type spelled at the `@_cdecl` boundary, and the success-path expression
/// that marshals `<call>` to it (with `{call}` substituted in).
fn return_shape(ret: &RetMarshal) -> (String, Marshaller) {
    match ret {
        RetMarshal::Void => ("Void".to_string(), Box::new(|c: &str| c.to_string())),
        RetMarshal::Scalar(s) => (s.swift().to_string(), Box::new(|c: &str| c.to_string())),
        RetMarshal::ScalarTypedef { scalar, name } => {
            let conv = scalar.swift();
            let name = name.clone();
            (
                scalar.swift().to_string(),
                Box::new(move |c: &str| format!("{conv}(({c}) as {name})")),
            )
        }
        RetMarshal::SwiftString => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| format!("Unmanaged.passRetained(({c}) as NSString).toOpaque()")),
        ),
        // Object: hand back a raw +1-retained `id`; nil-safe (an `Optional` object return
        // passes `nil` straight through). sbcl `aw-wrap`s it Lisp-side.
        RetMarshal::Object => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| {
                format!("(({c}) as AnyObject?).map {{ Unmanaged.passRetained($0).toOpaque() }}")
            }),
        ),
        RetMarshal::OpaqueBox(ty) => (
            "UnsafeMutableRawPointer?".to_string(),
            match ty {
                Some(name) => {
                    let name = name.clone();
                    Box::new(move |c: &str| format!("awSbclBox(({c}) as {name})"))
                }
                None => Box::new(|c: &str| format!("awSbclBox({c})")),
            },
        ),
    }
}

/// The `awSbclTry` fallback for the throwing path, given the return rep.
fn throw_fallback(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "()",
        RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => s.fallback(),
        RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => "nil",
    }
}

/// Emit one function trampoline.
fn emit_fn(s: &mut String, t: &FnTrampoline) {
    let (mut decl, prelude) = args_decl_and_prelude(&t.params);
    let (cret, marshal) = return_shape(&t.ret);

    if t.throwing {
        decl.push("_ awErrOut: UnsafeMutableRawPointer?".to_string());
    }

    if let Some(v) = &t.availability {
        s.push_str(&format!("@available(macOS {v}, *)\n"));
    }
    s.push_str(&format!("@_cdecl(\"{}\")\n", t.entry));
    let sig_ret = if cret == "Void" {
        String::new()
    } else {
        format!(" -> {cret}")
    };
    s.push_str(&format!(
        "public func {}({}){} {{\n",
        t.entry,
        decl.join(", "),
        sig_ret
    ));
    s.push_str(&prelude);

    let call = call_expr(t);
    if t.throwing {
        let body = match &t.ret {
            RetMarshal::Void => format!("  _ = awSbclTry(awErrOut, ()) {{ try {call} }}\n"),
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => format!(
                "  return awSbclTry(awErrOut, {fb}) {{ {marshalled} }}\n",
                fb = throw_fallback(&t.ret),
                marshalled = marshal(&format!("try {call}"))
            ),
            RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => {
                let marshalled = marshal(&format!("try {call}"));
                format!("  return awSbclTry(awErrOut, nil) {{ {marshalled} }}\n")
            }
        };
        s.push_str(&body);
    } else {
        match &t.ret {
            RetMarshal::Void => s.push_str(&format!("  {call}\n")),
            _ => s.push_str(&format!("  return {}\n", marshal(&call))),
        }
    }
    s.push_str("}\n");
}

/// Emit one constant trampoline (a zero-arg reader of the Swift global).
fn emit_const(s: &mut String, t: &ConstTrampoline) {
    let (cret, marshal) = return_shape(&t.ret);
    let read = format!("{}.{}", t.module, t.swift_name);
    if let Some(v) = &t.availability {
        s.push_str(&format!("@available(macOS {v}, *)\n"));
    }
    s.push_str(&format!("@_cdecl(\"{}\")\n", t.entry));
    let sig_ret = if cret == "Void" {
        " -> UnsafeMutableRawPointer?".to_string()
    } else {
        format!(" -> {cret}")
    };
    s.push_str(&format!("public func {}(){} {{\n", t.entry, sig_ret));
    match &t.ret {
        RetMarshal::Void => s.push_str(&format!("  return awSbclBox({read})\n")),
        _ => s.push_str(&format!("  return {}\n", marshal(&read))),
    }
    s.push_str("}\n");
}

/// Map an **implementation-detail** module to the umbrella that re-exports it (B2), for
/// the Swift `import` line and the `Module.Owner` type qualifier only. Swift forbids
/// `import RealityFoundation` ("it is an implementation detail of RealityKit; import
/// RealityKit instead"), but `RealityKit.MeshResource` names the identical type. The
/// trampoline's `module` field is left untouched (it drives the content-addressed entry
/// symbol + the sbcl binding identity, which both sides must agree on); only the *Swift
/// spelling* is re-attributed here (ADR-0030 addendum B2).
fn swift_import_module(module: &str) -> &str {
    match module {
        "RealityFoundation" => "RealityKit",
        "SwiftUICore" => "SwiftUI",
        other => other,
    }
}

/// Generate `Generated/Trampolines.swift`: the imports, then one `@_cdecl` per
/// trampolined function, constant, init, and method. Deferred decls produce no Swift.
pub fn generate_trampolines_swift(set: &TrampolineSet) -> String {
    let mut s = String::new();
    s.push_str("// Generated C-ABI trampolines for the Swift-native residual (sbcl; ADR-0038).\n");
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-macos-generate` from the IR.\n");
    s.push_str("// One @_cdecl per retained `objc_exposed == false` Swift-native decl; each\n");
    s.push_str("// imports the owning framework and calls the API by name (swiftc owns ABI\n");
    s.push_str("// correctness). Bound from the generated sbcl bindings with typed sb-alien\n");
    s.push_str("// against libAPIAnywareSbcl. See:\n");
    s.push_str("//   docs/specs/2026-06-15-racket-trampoline.md (mechanism, ported to sbcl)\n");
    s.push_str("//   docs/adr/0038-sbcl-trampoline-libapianywaresbcl-sole-native-unit.md\n\n");
    s.push_str("import Foundation\n");

    // One `import` per distinct module with an emitted trampoline; implementation-detail
    // modules are re-attributed to their umbrella (B2) so the `import` is legal.
    let mut modules: Vec<&str> = set
        .functions
        .iter()
        .map(|t| swift_import_module(t.module.as_str()))
        .chain(
            set.constants
                .iter()
                .map(|t| swift_import_module(t.module.as_str())),
        )
        .chain(
            set.methods
                .iter()
                .map(|t| swift_import_module(t.module.as_str())),
        )
        .chain(
            set.inits
                .iter()
                .map(|t| swift_import_module(t.module.as_str())),
        )
        .filter(|m| *m != "Foundation")
        .collect();
    modules.sort_unstable();
    modules.dedup();
    for m in &modules {
        s.push_str(&format!("import {m}\n"));
    }
    s.push('\n');

    for t in &set.functions {
        emit_fn(&mut s, t);
        s.push('\n');
    }
    for t in &set.constants {
        emit_const(&mut s, t);
        s.push('\n');
    }
    for t in &set.inits {
        emit_init_tramp(&mut s, t);
        s.push('\n');
    }
    for t in &set.methods {
        emit_method_tramp(&mut s, t);
        s.push('\n');
    }

    let counts = set.defer_counts();
    let deferred_note = if counts.is_empty() {
        String::new()
    } else {
        let parts: Vec<String> = counts.iter().map(|(r, n)| format!("{n} {r}")).collect();
        format!("; deferred — {}", parts.join(", "))
    };
    s.push_str(&format!(
        "// {} function + {} constant + {} init + {} method trampolines{}.\n",
        set.functions.len(),
        set.constants.len(),
        set.inits.len(),
        set.methods.len(),
        deferred_note
    ));
    s
}

/// The `@available` line + `@_cdecl` + `public func <entry>(<decl>)<sig_ret> {` header
/// shared by the method and init emitters.
fn emit_cdecl_header(
    s: &mut String,
    availability: &Option<String>,
    entry: &str,
    decl: &[String],
    sig_ret: &str,
) {
    if let Some(v) = availability {
        s.push_str(&format!("@available(macOS {v}, *)\n"));
    }
    s.push_str(&format!("@_cdecl(\"{entry}\")\n"));
    s.push_str(&format!(
        "public func {entry}({}){sig_ret} {{\n",
        decl.join(", ")
    ));
}

/// Is the success-path marshalled expression already an `Optional` C-pointer? An object
/// return is always optional (the `as AnyObject?` map); a String/box return is optional
/// only when nullable. Drives whether the throwing path wraps in `Optional(…)`.
fn marshalled_is_optional(ret: &RetMarshal, nullable: bool) -> bool {
    match ret {
        RetMarshal::Object => true,
        RetMarshal::SwiftString | RetMarshal::OpaqueBox(_) => nullable,
        _ => false,
    }
}

/// The C return type + success marshaller for a **method** return. Differs from the
/// free-function [`return_shape`]: an integer scalar is `numericCast`-converted (IR width
/// collapse), an object return hands back a raw +1 id (wrapped Lisp-side), a value return
/// boxes, and a nullable String/box maps `nil` → NULL. A method's box return is always
/// `OpaqueBox(None)`; a nullable scalar/typedef is deferred upstream.
fn method_return_shape(ret: &RetMarshal, nullable: bool) -> (String, Marshaller) {
    match ret {
        RetMarshal::Void => ("Void".to_string(), Box::new(|c: &str| c.to_string())),
        RetMarshal::Scalar(s) if s.is_integer() => (
            s.swift().to_string(),
            Box::new(|c: &str| format!("numericCast({c})")),
        ),
        RetMarshal::Scalar(s) => (s.swift().to_string(), {
            let _ = s;
            Box::new(|c: &str| c.to_string())
        }),
        RetMarshal::ScalarTypedef { scalar, name } => {
            let conv = scalar.swift();
            let name = name.clone();
            (
                scalar.swift().to_string(),
                Box::new(move |c: &str| format!("{conv}(({c}) as {name})")),
            )
        }
        RetMarshal::SwiftString if nullable => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| {
                format!("(({c}) as String?).map {{ Unmanaged.passRetained($0 as NSString).toOpaque() }} ?? nil")
            }),
        ),
        RetMarshal::SwiftString => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| format!("Unmanaged.passRetained(({c}) as NSString).toOpaque()")),
        ),
        // Object: hand back a raw +1-retained id (nil-safe via the `as AnyObject?` map);
        // sbcl `aw-wrap`s it Lisp-side to its exact bound type (ADR-0038 §4).
        RetMarshal::Object => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| {
                format!("(({c}) as AnyObject?).map {{ Unmanaged.passRetained($0).toOpaque() }}")
            }),
        ),
        RetMarshal::OpaqueBox(_) if nullable => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| format!("({c}).map {{ awSbclBox($0) }} ?? nil")),
        ),
        RetMarshal::OpaqueBox(_) => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| format!("awSbclBox({c})")),
        ),
    }
}

/// The expression marshalling an async method's success result (`awR`) to the
/// `AwSbclAsyncOutcome.value` pointer payload, computed on the cooperative thread inside
/// the operation closure. `Void` is handled by the caller; scalar returns are deferred.
fn async_outcome_value(ret: &RetMarshal, nullable: bool) -> String {
    match ret {
        RetMarshal::SwiftString if nullable => {
            "(awR as String?).map { Unmanaged.passRetained($0 as NSString).toOpaque() } ?? nil"
                .to_string()
        }
        RetMarshal::SwiftString => "Unmanaged.passRetained(awR as NSString).toOpaque()".to_string(),
        RetMarshal::Object => {
            "(awR as AnyObject?).map { Unmanaged.passRetained($0).toOpaque() }".to_string()
        }
        RetMarshal::OpaqueBox(_) if nullable => "awR.map { awSbclBox($0) } ?? nil".to_string(),
        RetMarshal::OpaqueBox(_) => "awSbclBox(awR)".to_string(),
        RetMarshal::Void | RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => {
            "nil".to_string()
        }
    }
}

/// Emit one `async` method trampoline (D5/R4): the `@_cdecl` takes a trailing sbcl
/// completion context (`awCtx`) + C callback (`awCb`) and drives `awSbclAsyncDispatch` —
/// the operation closure unboxes the receiver, `await`s, and marshals to
/// `AwSbclAsyncOutcome` **on the cooperative thread**; the completion closure delivers it
/// through `awCb` **on the main thread** (ADR-0035). Errors ride `AwSbclAsyncOutcome.error`,
/// so there is no `NSError**` out-param.
fn emit_async_method_tramp(s: &mut String, t: &MethodTrampoline) {
    let (arg_decl, arg_prelude) = args_decl_and_prelude(&t.params);
    let mut decl = vec!["_ awRecv: UnsafeMutableRawPointer?".to_string()];
    decl.extend(arg_decl);
    decl.push("_ awCtx: Int".to_string());
    decl.push(
        "_ awCb: @convention(c) (Int, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void"
            .to_string(),
    );
    emit_cdecl_header(s, &t.availability, &t.entry, &decl, "");
    // Args reconstruct to Sendable values here (calling thread); the operation closure
    // captures those values (Sendable + copy), so no sbcl-owned handle dangles.
    s.push_str(&arg_prelude);

    let owner = format!("{}.{}", swift_import_module(&t.module), t.swift_owner);
    // The receiver pointer rides a `nonisolated(unsafe) let` across the hop (the caller's
    // lifetime contract makes the capture sound); the receiver is reconstructed *inside*
    // the `@Sendable` operation closure.
    s.push_str("  nonisolated(unsafe) let awRecvUnsafe = awRecv\n");
    let recv_line = match &t.recv {
        SelfMarshal::ClassRef => format!(
            "    let awSelf = Unmanaged<{owner}>.fromOpaque(awRecvUnsafe!).takeUnretainedValue()\n"
        ),
        SelfMarshal::ValueBox { .. } => {
            format!("    let awSelf = awSbclUnbox(awRecvUnsafe!, as: {owner}.self)\n")
        }
    };
    let call = format!(
        "awSelf.{}({})",
        t.swift_name,
        arg_values(&t.params, &t.labels, true).join(", ")
    );
    let value_expr = async_outcome_value(&t.ret, t.ret_nullable);

    s.push_str("  awSbclAsyncDispatch({ () async -> AwSbclAsyncOutcome in\n");
    s.push_str(&recv_line);
    match (t.throwing, &t.ret) {
        (true, RetMarshal::Void) => s.push_str(
            "    do {\n      try await __CALL__\n      return AwSbclAsyncOutcome()\n    } catch {\n      return AwSbclAsyncOutcome.failure(error)\n    }\n"
                .replace("__CALL__", &call)
                .as_str(),
        ),
        (true, _) => s.push_str(
            "    do {\n      let awR = try await __CALL__\n      return AwSbclAsyncOutcome(value: __VAL__)\n    } catch {\n      return AwSbclAsyncOutcome.failure(error)\n    }\n"
                .replace("__CALL__", &call)
                .replace("__VAL__", &value_expr)
                .as_str(),
        ),
        (false, RetMarshal::Void) => {
            s.push_str(&format!("    await {call}\n    return AwSbclAsyncOutcome()\n"))
        }
        (false, _) => s.push_str(&format!(
            "    let awR = await {call}\n    return AwSbclAsyncOutcome(value: {value_expr})\n"
        )),
    }
    s.push_str("  }, { awOutcome in\n    awCb(awCtx, awOutcome.value, awOutcome.error)\n  })\n");
    s.push_str("}\n");
}

/// Emit one method trampoline: receiver handle + args → `receiver.name(labels:)`.
fn emit_method_tramp(s: &mut String, t: &MethodTrampoline) {
    if t.is_async {
        emit_async_method_tramp(s, t);
        return;
    }
    let (arg_decl, arg_prelude) = args_decl_and_prelude(&t.params);
    let (cret, marshal) = method_return_shape(&t.ret, t.ret_nullable);

    let mut decl = vec!["_ awRecv: UnsafeMutableRawPointer?".to_string()];
    decl.extend(arg_decl);
    if t.throwing {
        decl.push("_ awErrOut: UnsafeMutableRawPointer?".to_string());
    }
    let sig_ret = if cret == "Void" {
        String::new()
    } else {
        format!(" -> {cret}")
    };
    emit_cdecl_header(s, &t.availability, &t.entry, &decl, &sig_ret);

    let owner = format!("{}.{}", swift_import_module(&t.module), t.swift_owner);
    let (recv_prelude, writeback) = match &t.recv {
        SelfMarshal::ClassRef => (
            format!("  let awSelf = Unmanaged<{owner}>.fromOpaque(awRecv!).takeUnretainedValue()\n"),
            None,
        ),
        SelfMarshal::ValueBox { mutating: false } => (
            format!("  let awSelf = awSbclUnbox(awRecv!, as: {owner}.self)\n"),
            None,
        ),
        SelfMarshal::ValueBox { mutating: true } => (
            format!(
                "  let awBox = Unmanaged<AwSbclValueBox>.fromOpaque(awRecv!).takeUnretainedValue()\n  \
                 var awSelf = awBox.value as! {owner}\n"
            ),
            Some("  awBox.value = awSelf\n".to_string()),
        ),
    };
    s.push_str(&recv_prelude);
    s.push_str(&arg_prelude);

    let call = format!(
        "awSelf.{}({})",
        t.swift_name,
        arg_values(&t.params, &t.labels, true).join(", ")
    );

    if t.throwing {
        let wb = writeback.as_deref().unwrap_or("");
        match &t.ret {
            RetMarshal::Void => {
                s.push_str(&format!("  awSbclTry(awErrOut, ()) {{ try {call}\n  {wb}}}\n"));
            }
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => {
                let m = marshal("awR");
                s.push_str(&format!(
                    "  return awSbclTry(awErrOut, {fb}) {{ let awR = try {call}\n  {wb}  return {m} }}\n",
                    fb = throw_fallback(&t.ret),
                ));
            }
            RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => {
                let m = marshal("awR");
                let wrapped = if marshalled_is_optional(&t.ret, t.ret_nullable) {
                    m
                } else {
                    format!("Optional({m})")
                };
                s.push_str(&format!(
                    "  return awSbclTry(awErrOut, nil) {{ let awR = try {call}\n  {wb}  return {wrapped} }}\n"
                ));
            }
        }
    } else {
        match (&t.ret, &writeback) {
            (RetMarshal::Void, None) => s.push_str(&format!("  {call}\n")),
            (RetMarshal::Void, Some(wb)) => s.push_str(&format!("  {call}\n{wb}")),
            (_, None) => s.push_str(&format!("  return {}\n", marshal(&call))),
            (_, Some(wb)) => {
                let m = marshal("awR");
                s.push_str(&format!("  let awR = {call}\n{wb}  return {m}\n"));
            }
        }
    }
    s.push_str("}\n");
}

/// Emit one initializer producer: `Owner(labels:)` → boxed handle of the owner.
fn emit_init_tramp(s: &mut String, t: &InitTrampoline) {
    let (arg_decl, arg_prelude) = args_decl_and_prelude(&t.params);
    let mut decl = arg_decl;
    if t.throwing {
        decl.push("_ awErrOut: UnsafeMutableRawPointer?".to_string());
    }
    emit_cdecl_header(
        s,
        &t.availability,
        &t.entry,
        &decl,
        " -> UnsafeMutableRawPointer?",
    );
    s.push_str(&arg_prelude);

    let owner = format!("{}.{}", swift_import_module(&t.module), t.swift_owner);
    // Init params pass with their declared width (no `numericCast`): an overloaded
    // initializer is selected *by* the param type, so a width-agnostic cast would make the
    // constructor call ambiguous.
    let ctor = format!("{owner}({})", arg_values(&t.params, &t.labels, false).join(", "));
    // Box the owning type (R2): a class instance keeps reference identity via
    // `Unmanaged.passRetained` (sbcl `aw-wrap`s it Lisp-side); a value rides the uniform
    // `awSbclBox`.
    let box_of = |expr: &str| -> String {
        if t.owner_is_class {
            format!("Unmanaged.passRetained({expr}).toOpaque()")
        } else {
            format!("awSbclBox({expr})")
        }
    };
    if t.throwing {
        s.push_str(&format!(
            "  return awSbclTry(awErrOut, nil) {{ Optional({}) }}\n",
            box_of(&format!("try {ctor}"))
        ));
    } else {
        s.push_str(&format!("  return {}\n", box_of(&ctor)));
    }
    s.push_str("}\n");
}

// ===========================================================================
// sbcl Lisp binding rendering (consumed by emit_framework — wired in leaf 060)
// ===========================================================================
//
// Each `aw_sbcl_*` entry is a distinct named C symbol in the linked dylib, bound by a
// per-signature typed `sb-alien` — the ADR-0015 compiled-FFI idiom, the same shape the
// direct `objc_msgSend` dispatch uses (emit_generics), only against a named `extern-alien`
// rather than the `objc_msgSend` SAP. A function/constant binds a top-level `ns:<name>`
// (`defun` / `define-objc-constant`); a method/init becomes a `defmethod` / constructor
// the orchestration leaf (060) assembles from the FFI rep + the call expression here.

/// The `(sb-alien:function <ret> <args>…)` signature spelling for an `extern-alien`.
fn alien_function_type(ret_alien: &str, arg_aliens: &[String]) -> String {
    if arg_aliens.is_empty() {
        format!("(sb-alien:function {ret_alien})")
    } else {
        format!("(sb-alien:function {ret_alien} {})", arg_aliens.join(" "))
    }
}

/// The `(sb-alien:alien-funcall (sb-alien:extern-alien "<entry>" <fn-type>) <actuals>…)`
/// raw crossing for an entry — the compiled-FFI call into the dylib.
fn alien_funcall(entry: &str, ret_alien: &str, arg_aliens: &[String], actuals: &[String]) -> String {
    let fn_type = alien_function_type(ret_alien, arg_aliens);
    if actuals.is_empty() {
        format!("(sb-alien:alien-funcall (sb-alien:extern-alien \"{entry}\" {fn_type}))")
    } else {
        format!(
            "(sb-alien:alien-funcall (sb-alien:extern-alien \"{entry}\" {fn_type}) {})",
            actuals.join(" ")
        )
    }
}

/// The `sb-alien` slot for one marshalled arg: a scalar's fixed-width spelling, else SAP
/// (string / value-box handle / object reference all cross as `system-area-pointer`).
fn arg_alien(m: &ArgMarshal) -> String {
    match m {
        ArgMarshal::Scalar(s) | ArgMarshal::ScalarTypedef { scalar: s, .. } => {
            s.sbcl_alien().to_string()
        }
        ArgMarshal::SwiftString | ArgMarshal::BoxedHandle { .. } | ArgMarshal::ObjectRef { .. } => {
            SAP.to_string()
        }
    }
}

/// The `sb-alien` return slot: void / scalar fixed-width / SAP (string, object, box).
fn ret_alien(ret: &RetMarshal) -> String {
    match ret {
        RetMarshal::Void => "sb-alien:void".to_string(),
        RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => {
            s.sbcl_alien().to_string()
        }
        RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => SAP.to_string(),
    }
}

/// Wrap a raw crossing result in the result coercion for a return rep: an object `aw-wrap`s
/// (`+1`-retained, so `t`), a String coerces to a `cl:string`, a scalar/box/void passes
/// through. Shared by functions, constants, methods, and init producers (a class init's
/// `Object` wrap).
fn coerce_result(ret: &RetMarshal, raw: &str) -> String {
    match ret {
        RetMarshal::Object => format!("({WRAP_FN} {raw} t)"),
        RetMarshal::SwiftString => format!("({STRING_RESULT_FN} {raw})"),
        _ => raw.to_string(),
    }
}

/// The CLOS/`defun` formal names for a residual method/init's visible args: each
/// argument label kebab-cased, a `_`/empty wildcard becoming a positional `argN` (so
/// two wildcard params don't collide as duplicate formals). Mirrors
/// [`crate::emit_generics`]'s `arg_name` convention (param formals use `camel_to_kebab`,
/// distinct from the acronym-aware *surface* names).
fn swift_formals(labels: &[String]) -> Vec<String> {
    labels
        .iter()
        .enumerate()
        .map(|(i, l)| {
            if l == "_" || l.is_empty() {
                format!("arg{i}")
            } else {
                apianyware_macos_emit::naming::camel_to_kebab(l)
            }
        })
        .collect()
}

/// Coerce one outbound Lisp actual per its marshalling: a String bridges in
/// (`aw-swift-string-arg`), an object/value-box handle coerces via `aw-ptr`, a scalar
/// passes through.
fn coerce_actual(m: &ArgMarshal, lisp_name: &str) -> String {
    match m {
        ArgMarshal::SwiftString => format!("({STRING_ARG_FN} {lisp_name})"),
        ArgMarshal::BoxedHandle { .. } | ArgMarshal::ObjectRef { .. } => {
            format!("({PTR_FN} {lisp_name})")
        }
        ArgMarshal::Scalar(_) | ArgMarshal::ScalarTypedef { .. } => lisp_name.to_string(),
    }
}

impl FnTrampoline {
    /// The `sb-alien` arg slots (each visible param, plus the trailing `NSError**` SAP cell
    /// when the function `throws`).
    fn arg_aliens(&self) -> Vec<String> {
        let mut v: Vec<String> = self.params.iter().map(arg_alien).collect();
        if self.throwing {
            v.push(SAP.to_string()); // NSError** out-cell
        }
        v
    }

    /// The `sb-alien` return slot.
    fn ret_alien(&self) -> String {
        ret_alien(&self.ret)
    }

    /// Render the outer `(defun ns:<name> (a0 a1 …) …)` sbcl binding against
    /// libAPIAnywareSbcl. Args coerce in (`aw-swift-string-arg` / `aw-ptr` / scalar
    /// pass-through), the crossing calls the dylib entry, the result coerces out (object →
    /// `aw-wrap`, String → `aw-swift-string-result`, scalar/box → through); a `throws`
    /// routes through the `aw-swift-call/error` macro (the `%err` cell is the trailing arg;
    /// the `ThrowsBridge` writes a +1 `NSError`, so the +1-owning macro — not the direct
    /// path's `aw-with-error-cell` — must release it).
    pub fn render_binding(&self) -> String {
        let arg_aliens = self.arg_aliens();
        let ret = self.ret_alien();
        let lisp_params: Vec<String> = (0..self.params.len()).map(|i| format!("a{i}")).collect();
        let mut actuals: Vec<String> = self
            .params
            .iter()
            .zip(&lisp_params)
            .map(|(m, name)| coerce_actual(m, name))
            .collect();

        let params_str = lisp_params.join(" ");
        if self.throwing {
            actuals.push("%err".to_string());
            let raw = alien_funcall(&self.entry, &ret, &arg_aliens, &actuals);
            let body = coerce_result(&self.ret, &raw);
            format!(
                "(defun {sym} ({params_str})\n  ({SWIFT_THROWS_MACRO} (%err)\n    {body}))",
                sym = self.binding_symbol,
            )
        } else {
            let raw = alien_funcall(&self.entry, &ret, &arg_aliens, &actuals);
            let body = coerce_result(&self.ret, &raw);
            format!(
                "(defun {sym} ({params_str})\n  {body})",
                sym = self.binding_symbol,
            )
        }
    }
}

impl ConstTrampoline {
    /// The `sb-alien` return slot for the zero-arg reader.
    fn ret_alien(&self) -> String {
        ret_alien(&self.ret)
    }

    /// Render the `(define-objc-constant ns:<name> <value>)` sbcl binding — a zero-arg
    /// reader of the Swift global, evaluated once at load (mirroring the direct
    /// `define-objc-constant` constants), wrapped per its rep (object → `aw-wrap`, String →
    /// `aw-swift-string-result`, scalar → through).
    pub fn render_binding(&self) -> String {
        let ret = self.ret_alien();
        let raw = alien_funcall(&self.entry, &ret, &[], &[]);
        let body = coerce_result(&self.ret, &raw);
        format!("({DEFINE_CONSTANT} {} {})", self.binding_symbol, body)
    }
}

impl MethodTrampoline {
    /// Whether this method is `async` (D5/R4) — the binding wraps it with the
    /// completion-callback form (the runtime leaf's `aw-async-call`) rather than a
    /// synchronous crossing.
    pub fn is_async(&self) -> bool {
        self.is_async
    }

    /// The `sb-alien` arg slots: the receiver SAP, each visible param, then (async) the
    /// trailing ctx (`(signed 64)`) + callback fptr (SAP), or (throwing) the `NSError**`
    /// out-cell SAP.
    pub fn arg_aliens(&self) -> Vec<String> {
        let mut v = vec![SAP.to_string()]; // receiver handle
        v.extend(self.params.iter().map(arg_alien));
        if self.is_async {
            v.push("(sb-alien:signed 64)".to_string()); // completion ctx (Swift `Int`)
            v.push(SAP.to_string()); // the GC-stable C callback fptr
        } else if self.throwing {
            v.push(SAP.to_string()); // NSError** out-cell
        }
        v
    }

    /// The `sb-alien` return slot. An `async` method returns `void` (the result is
    /// delivered through the callback).
    pub fn ret_alien(&self) -> String {
        if self.is_async {
            return "sb-alien:void".to_string();
        }
        ret_alien(&self.ret)
    }

    /// Render the raw `sb-alien` crossing for a synchronous method call, given the Lisp
    /// receiver expression (`(aw-ptr self)` for a class owner) and the visible arg
    /// expressions already coerced. The orchestration leaf (060) wraps this in a
    /// `(defmethod ns:<generic> ((self ns:<owner>) …) …)` and applies [`coerce_result`].
    /// `%err` (throwing) / ctx+cb (async) are appended by the caller from [`arg_aliens`].
    pub fn render_alien_funcall(&self, receiver_expr: &str, arg_exprs: &[String]) -> String {
        let mut actuals = vec![receiver_expr.to_string()];
        actuals.extend(arg_exprs.iter().cloned());
        alien_funcall(&self.entry, &self.ret_alien(), &self.arg_aliens(), &actuals)
    }

    /// Coerce the method's visible Lisp args (`a0 a1 …`) for the by-name crossing — the
    /// 060 wiring zips these with the formal names.
    pub fn arg_coercions(&self, lisp_names: &[String]) -> Vec<String> {
        self.params
            .iter()
            .zip(lisp_names)
            .map(|(m, name)| coerce_actual(m, name))
            .collect()
    }

    /// The result coercion for this method's return (object → `aw-wrap`, String →
    /// `aw-swift-string-result`, scalar/box/void → through), applied by 060 around the
    /// crossing.
    pub fn coerce_result(&self, raw: &str) -> String {
        coerce_result(&self.ret, raw)
    }

    /// The `(ns:`-qualified generic name, visible arity`)` this method's `defmethod`
    /// extends — folded into `collect_generics` so its `defgeneric` exists (the
    /// lockstep). Name is selector-analogous (base + labels); arity is the visible
    /// param count (the receiver is the specializer, not an arg).
    pub fn generic_decl(&self) -> (String, usize) {
        (
            qualified_swift_method_generic_name(&self.swift_name, &self.labels),
            self.labels.len(),
        )
    }

    /// Render the class-owner `(defmethod ns:<generic> ((self ns:<owner>) <formals>)
    /// …)` Lisp binding (045). The receiver coerces through `(aw-ptr self)` (a class
    /// owner is a reference receiver); the args coerce in, the crossing calls the
    /// `libAPIAnywareSbcl` entry, the result coerces out (object → `aw-wrap`, String →
    /// `aw-swift-string-result`); a `throws` routes through `aw-swift-call/error` (the +1
    /// `ThrowsBridge` consumer). Only the **class-owner** (`SelfMarshal::ClassRef`) sync
    /// path is rendered here — value (population-B) receivers have no CLOS class to
    /// specialize on (a follow-up leaf).
    pub fn render_defmethod(&self) -> String {
        let generic = qualified_swift_method_generic_name(&self.swift_name, &self.labels);
        let owner_clos = qualified_class_name(&self.owner);
        let formals = swift_formals(&self.labels);
        let coerced = self.arg_coercions(&formals);

        let mut head = format!("(defmethod {generic} ((self {owner_clos})");
        for f in &formals {
            head.push(' ');
            head.push_str(f);
        }
        head.push(')');

        let receiver = format!("({PTR_FN} self)");
        if self.throwing {
            let mut actuals = coerced;
            actuals.push("%err".to_string());
            let raw = self.render_alien_funcall(&receiver, &actuals);
            let body = self.coerce_result(&raw);
            format!("{head}\n  ({SWIFT_THROWS_MACRO} (%err)\n    {body}))")
        } else {
            let raw = self.render_alien_funcall(&receiver, &coerced);
            let body = self.coerce_result(&raw);
            format!("{head}\n  {body})")
        }
    }
}

impl InitTrampoline {
    /// The `sb-alien` arg slots: each marshalled arg, then the `NSError**` out-cell SAP
    /// when throwing. No receiver.
    pub fn arg_aliens(&self) -> Vec<String> {
        let mut v: Vec<String> = self.params.iter().map(arg_alien).collect();
        if self.throwing {
            v.push(SAP.to_string());
        }
        v
    }

    /// An init producer always returns the boxed/owner handle (a SAP).
    pub fn ret_alien(&self) -> String {
        SAP.to_string()
    }

    /// Whether the init's owner is a class (the returned id `aw-wrap`s to its bound type,
    /// ADR-0038 §4) vs a value (the raw opaque box handle is handed back).
    pub fn owner_is_class(&self) -> bool {
        self.owner_is_class
    }

    /// Render the raw `sb-alien` crossing for the init producer, given the visible arg
    /// expressions (already coerced). 060 wraps this in a constructor and, for a class
    /// owner, `aw-wrap`s the result; `%err` (throwing) is appended by the caller.
    pub fn render_alien_funcall(&self, arg_exprs: &[String]) -> String {
        alien_funcall(&self.entry, &self.ret_alien(), &self.arg_aliens(), arg_exprs)
    }

    /// Coerce the init's visible Lisp args for the crossing.
    pub fn arg_coercions(&self, lisp_names: &[String]) -> Vec<String> {
        self.params
            .iter()
            .zip(lisp_names)
            .map(|(m, name)| coerce_actual(m, name))
            .collect()
    }

    /// The `ns:`-qualified constructor symbol this init binds (`ns:make-<owner>[-<labels>]`,
    /// 045) — added to the framework's facade export surface.
    pub fn binding_symbol(&self) -> String {
        qualified_swift_init_constructor_name(&self.owner, &self.labels)
    }

    /// Render the `(defun ns:make-<owner>[-<labels>] (<formals>) …)` constructor (045) —
    /// a standalone constructor for the Swift-native init (it calls `Owner(labels:)`
    /// through the trampoline, not ObjC `alloc`/`init`, so it is not §3.3's
    /// `make-instance` path). Args coerce in, the crossing calls the entry; a **class**
    /// owner `aw-wrap`s the returned `+1` id to its exact bound type (ADR-0038 §4), a
    /// **value** owner hands back the raw opaque box; a `throws` routes through
    /// `aw-swift-call/error` (the +1 `ThrowsBridge` consumer).
    pub fn render_constructor(&self) -> String {
        let sym = self.binding_symbol();
        let formals = swift_formals(&self.labels);
        let coerced = self.arg_coercions(&formals);
        let params_str = formals.join(" ");
        if self.throwing {
            let mut actuals = coerced;
            actuals.push("%err".to_string());
            let raw = self.render_alien_funcall(&actuals);
            let body = self.coerce_init_result(&raw);
            format!("(defun {sym} ({params_str})\n  ({SWIFT_THROWS_MACRO} (%err)\n    {body}))")
        } else {
            let raw = self.render_alien_funcall(&coerced);
            let body = self.coerce_init_result(&raw);
            format!("(defun {sym} ({params_str})\n  {body})")
        }
    }

    /// The init's result coercion: a **class** owner `aw-wrap`s the `+1`-retained id to
    /// its exact bound type (ADR-0038 §4, always retained); a **value** owner hands the
    /// raw opaque box straight back.
    fn coerce_init_result(&self, raw: &str) -> String {
        if self.owner_is_class {
            format!("({WRAP_FN} {raw} t)")
        } else {
            raw.to_string()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Param, SwiftFnInfo};

    fn no_structs() -> HashSet<&'static str> {
        HashSet::new()
    }

    fn prim(name: &str) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive { name: name.into() },
        }
    }
    fn nsstring() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSString".into(),
                framework: Some("Foundation".into()),
                params: vec![],
            },
        }
    }
    fn idty() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        }
    }
    fn param(name: &str, t: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type: t,
        }
    }
    fn swift_func(name: &str, params: Vec<Param>, ret: TypeRef, info: SwiftFnInfo) -> Function {
        Function {
            name: name.into(),
            params,
            return_type: ret,
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
            swift_fn: Some(info),
        }
    }
    fn classify(module: &str, f: &Function) -> FnTrampoline {
        match classify_function(module, f, std::slice::from_ref(f), &no_structs()) {
            FnDisposition::Trampoline(t) => t,
            FnDisposition::Deferred(r) => panic!("unexpected defer {r:?}"),
        }
    }

    #[test]
    fn entry_name_uses_sbcl_prefix() {
        let f = swift_func("timestampSeed", vec![], prim("double"), SwiftFnInfo::default());
        let t = classify("CreateML", &f);
        assert_eq!(t.entry, "aw_sbcl_swift_CreateML_timestampSeed");
        assert_eq!(t.binding_symbol, "ns:timestamp-seed");
    }

    #[test]
    fn scalar_function_renders_bare_alien_funcall() {
        let f = swift_func(
            "scale",
            vec![param("factor", prim("double"))],
            prim("double"),
            SwiftFnInfo::default(),
        );
        let t = classify("TestKit", &f);
        assert_eq!(t.arg_aliens(), vec!["sb-alien:double"]);
        assert_eq!(t.ret_alien(), "sb-alien:double");
        let b = t.render_binding();
        assert!(b.contains("(defun ns:scale (a0)"), "{b}");
        assert!(
            b.contains(
                "(sb-alien:alien-funcall (sb-alien:extern-alien \"aw_sbcl_swift_TestKit_scale\" (sb-alien:function sb-alien:double sb-alien:double)) a0)"
            ),
            "{b}"
        );
        // No wrap/coercion for a pure-scalar return.
        assert!(!b.contains("aw-wrap"));
    }

    #[test]
    fn object_return_wraps_via_mop_registry() {
        let f = swift_func("makeWidget", vec![], idty(), SwiftFnInfo::default());
        let t = classify("TestKit", &f);
        assert_eq!(t.ret_alien(), "sb-alien:system-area-pointer");
        let b = t.render_binding();
        // Object return: aw-wrap … t (the +1-retained id → exact bound type).
        assert!(b.contains("(aw-wrap (sb-alien:alien-funcall"), "{b}");
        assert!(b.trim_end().ends_with("t))"), "{b}");
    }

    #[test]
    fn string_in_and_out_use_swift_trampoline_coercers() {
        let f = swift_func(
            "describe",
            vec![param("of", nsstring())],
            nsstring(),
            SwiftFnInfo::default(),
        );
        let t = classify("TestKit", &f);
        // Both the arg and return cross as SAP.
        assert_eq!(t.arg_aliens(), vec!["sb-alien:system-area-pointer"]);
        assert_eq!(t.ret_alien(), "sb-alien:system-area-pointer");
        let b = t.render_binding();
        assert!(b.contains("(aw-swift-string-arg a0)"), "{b}");
        assert!(b.contains("(aw-swift-string-result (sb-alien:alien-funcall"), "{b}");
    }

    #[test]
    fn object_arg_coerces_via_aw_ptr() {
        // URL bridges (R1 ObjectRef) → the id pointer passes via aw-ptr.
        let url = TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSURL".into(),
                framework: Some("Foundation".into()),
                params: vec![],
            },
        };
        let f = swift_func("load", vec![param("from", url)], prim("void"), SwiftFnInfo::default());
        let t = classify("TestKit", &f);
        let b = t.render_binding();
        assert!(b.contains("(aw-ptr a0)"), "{b}");
    }

    #[test]
    fn throwing_function_threads_error_cell() {
        let f = swift_func(
            "load",
            vec![param("path", nsstring())],
            idty(),
            SwiftFnInfo {
                throwing: true,
                ..SwiftFnInfo::default()
            },
        );
        let t = classify("TestKit", &f);
        // The arg list gains the trailing NSError** SAP cell.
        assert_eq!(
            t.arg_aliens(),
            vec![
                "sb-alien:system-area-pointer".to_string(),
                "sb-alien:system-area-pointer".to_string()
            ]
        );
        let b = t.render_binding();
        assert!(b.contains("(aw-swift-call/error (%err)"), "{b}");
        // %err is the trailing actual of the crossing.
        assert!(b.contains("(aw-swift-string-arg a0) %err)"), "{b}");
        // The object result still wraps.
        assert!(b.contains("(aw-wrap (sb-alien:alien-funcall"), "{b}");
    }

    #[test]
    fn generic_and_async_defer_with_reasons() {
        let g = swift_func(
            "map",
            vec![],
            idty(),
            SwiftFnInfo {
                is_generic: true,
                ..SwiftFnInfo::default()
            },
        );
        assert!(matches!(
            classify_function("TestKit", &g, std::slice::from_ref(&g), &no_structs()),
            FnDisposition::Deferred(DeferReason::UnbindableGenericFreeFunction)
        ));
        let a = swift_func(
            "fetch",
            vec![],
            idty(),
            SwiftFnInfo {
                is_async: true,
                ..SwiftFnInfo::default()
            },
        );
        assert!(matches!(
            classify_function("TestKit", &a, std::slice::from_ref(&a), &no_structs()),
            FnDisposition::Deferred(DeferReason::Async)
        ));
    }

    #[test]
    fn constant_renders_define_objc_constant() {
        let c = Constant {
            name: "MLCreateErrorDomain".into(),
            constant_type: nsstring(),
            source: None,
            macro_value: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
        };
        let t = classify_constant("CreateML", &c);
        assert_eq!(t.entry, "aw_sbcl_swift_const_CreateML_MLCreateErrorDomain");
        let b = t.render_binding();
        assert!(b.starts_with("(define-objc-constant ns:ml-create-error-domain"), "{b}");
        // A String constant coerces out to a cl:string.
        assert!(b.contains("(aw-swift-string-result (sb-alien:alien-funcall"), "{b}");
    }

    #[test]
    fn overloaded_functions_get_distinct_entries_and_symbols() {
        let a = swift_func("show", vec![param("x", prim("int64"))], prim("void"), SwiftFnInfo::default());
        let b = swift_func("show", vec![param("x", prim("double"))], prim("void"), SwiftFnInfo::default());
        let siblings = vec![a.clone(), b.clone()];
        let ta = match classify_function("TestKit", &a, &siblings, &no_structs()) {
            FnDisposition::Trampoline(t) => t,
            _ => panic!(),
        };
        let tb = match classify_function("TestKit", &b, &siblings, &no_structs()) {
            FnDisposition::Trampoline(t) => t,
            _ => panic!(),
        };
        assert_ne!(ta.entry, tb.entry);
        assert_ne!(ta.binding_symbol, tb.binding_symbol);
        assert!(ta.entry.starts_with("aw_sbcl_swift_TestKit_show_"));
        assert!(ta.binding_symbol.starts_with("ns:show-"));
    }

    #[test]
    fn method_arg_aliens_prepend_receiver() {
        let m = MethodTrampoline {
            module: "TestKit".into(),
            owner: "Widget".into(),
            swift_owner: "Widget".into(),
            swift_name: "resize".into(),
            entry: "aw_sbcl_swift_m_TestKit_Widget_resize".into(),
            recv: SelfMarshal::ClassRef,
            labels: vec!["to".into()],
            params: vec![ArgMarshal::Scalar(Scalar::Double)],
            ret: RetMarshal::Void,
            ret_nullable: false,
            throwing: false,
            is_async: false,
            availability: None,
        };
        assert_eq!(
            m.arg_aliens(),
            vec![
                "sb-alien:system-area-pointer".to_string(),
                "sb-alien:double".to_string()
            ]
        );
        assert_eq!(m.ret_alien(), "sb-alien:void");
        let call = m.render_alien_funcall("(aw-ptr self)", &["a0".to_string()]);
        assert!(call.contains("(sb-alien:extern-alien \"aw_sbcl_swift_m_TestKit_Widget_resize\""), "{call}");
        assert!(call.contains("(aw-ptr self) a0)"), "{call}");
    }

    #[test]
    fn init_producer_returns_sap_and_class_wraps() {
        let i = InitTrampoline {
            module: "TestKit".into(),
            owner: "Widget".into(),
            swift_owner: "Widget".into(),
            entry: "aw_sbcl_swift_init_TestKit_Widget".into(),
            owner_is_class: true,
            labels: vec!["title".into()],
            params: vec![ArgMarshal::SwiftString],
            throwing: false,
            availability: None,
        };
        assert_eq!(i.ret_alien(), "sb-alien:system-area-pointer");
        assert!(i.owner_is_class());
        let coerced = i.arg_coercions(&["a0".to_string()]);
        assert_eq!(coerced, vec!["(aw-swift-string-arg a0)".to_string()]);
        let call = i.render_alien_funcall(&coerced);
        assert!(call.contains("(sb-alien:extern-alien \"aw_sbcl_swift_init_TestKit_Widget\""), "{call}");
    }

    #[test]
    fn swift_codegen_emits_cdecl_and_counts() {
        let mut set = TrampolineSet::default();
        let f = swift_func("scale", vec![param("by", prim("double"))], prim("double"), SwiftFnInfo::default());
        set.functions.push(classify("TestKit", &f));
        let swift = generate_trampolines_swift(&set);
        assert!(swift.contains("import TestKit"), "{swift}");
        assert!(swift.contains("@_cdecl(\"aw_sbcl_swift_TestKit_scale\")"), "{swift}");
        assert!(swift.contains("TestKit.scale(by: a0)"), "{swift}");
        assert!(swift.contains("1 function + 0 constant + 0 init + 0 method trampolines."), "{swift}");
    }

    // --- 045: Lisp method/init residual wiring -------------------------------

    fn class_method_tramp(
        owner: &str,
        swift_name: &str,
        entry: &str,
        labels: Vec<String>,
        params: Vec<ArgMarshal>,
        ret: RetMarshal,
        throwing: bool,
    ) -> MethodTrampoline {
        MethodTrampoline {
            module: "TestKit".into(),
            owner: owner.into(),
            swift_owner: owner.into(),
            swift_name: swift_name.into(),
            entry: entry.into(),
            recv: SelfMarshal::ClassRef,
            labels,
            params,
            ret,
            ret_nullable: false,
            throwing,
            is_async: false,
            availability: None,
        }
    }

    #[test]
    fn defmethod_is_selector_analogous_and_specializes_on_owner() {
        // resize(to:) : Double -> Void on a class owner.
        let m = class_method_tramp(
            "Widget",
            "resize",
            "aw_sbcl_swift_m_TestKit_Widget_resize",
            vec!["to".into()],
            vec![ArgMarshal::Scalar(Scalar::Double)],
            RetMarshal::Void,
            false,
        );
        assert_eq!(m.generic_decl(), ("ns:resize-to".to_string(), 1));
        let d = m.render_defmethod();
        // Generic = base+labels; receiver in the specializer; arg formal = kebab label.
        assert!(d.starts_with("(defmethod ns:resize-to ((self ns:widget) to)"), "{d}");
        // The receiver coerces through (aw-ptr self); the scalar arg passes through.
        assert!(
            d.contains("(sb-alien:extern-alien \"aw_sbcl_swift_m_TestKit_Widget_resize\""),
            "{d}"
        );
        assert!(d.contains("(aw-ptr self) to)"), "{d}");
        // void return → no wrap.
        assert!(!d.contains("aw-wrap"), "{d}");
    }

    #[test]
    fn defmethod_object_return_wraps_via_mop_registry() {
        let m = class_method_tramp(
            "Factory",
            "make",
            "aw_sbcl_swift_m_TestKit_Factory_make",
            vec![],
            vec![],
            RetMarshal::Object,
            false,
        );
        assert_eq!(m.generic_decl(), ("ns:make".to_string(), 0));
        let d = m.render_defmethod();
        assert!(d.starts_with("(defmethod ns:make ((self ns:factory))"), "{d}");
        // Object return: aw-wrap … t (the +1 id → exact bound type).
        assert!(d.contains("(aw-wrap (sb-alien:alien-funcall"), "{d}");
        assert!(d.trim_end().ends_with("t))"), "{d}");
    }

    #[test]
    fn defmethod_string_in_and_out_use_trampoline_coercers() {
        let m = class_method_tramp(
            "Greeter",
            "describe",
            "aw_sbcl_swift_m_TestKit_Greeter_describe",
            vec!["of".into()],
            vec![ArgMarshal::SwiftString],
            RetMarshal::SwiftString,
            false,
        );
        let d = m.render_defmethod();
        assert!(d.contains("(aw-swift-string-arg of)"), "{d}");
        assert!(d.contains("(aw-swift-string-result (sb-alien:alien-funcall"), "{d}");
    }

    #[test]
    fn throwing_defmethod_threads_the_error_cell() {
        let m = class_method_tramp(
            "Loader",
            "load",
            "aw_sbcl_swift_m_TestKit_Loader_load",
            vec!["from".into()],
            vec![ArgMarshal::SwiftString],
            RetMarshal::Object,
            true,
        );
        let d = m.render_defmethod();
        assert!(d.contains("(aw-swift-call/error (%err)"), "{d}");
        // %err is the trailing actual of the crossing.
        assert!(d.contains("(aw-swift-string-arg from) %err)"), "{d}");
        // The object result still wraps.
        assert!(d.contains("(aw-wrap (sb-alien:alien-funcall"), "{d}");
    }

    #[test]
    fn init_constructor_class_owner_wraps_returned_id() {
        let i = InitTrampoline {
            module: "TestKit".into(),
            owner: "ImageCreator".into(),
            swift_owner: "ImageCreator".into(),
            entry: "aw_sbcl_swift_init_TestKit_ImageCreator".into(),
            owner_is_class: true,
            labels: vec!["title".into()],
            params: vec![ArgMarshal::SwiftString],
            throwing: false,
            availability: None,
        };
        assert_eq!(i.binding_symbol(), "ns:make-image-creator-title");
        let c = i.render_constructor();
        assert!(c.starts_with("(defun ns:make-image-creator-title (title)"), "{c}");
        assert!(c.contains("(aw-swift-string-arg title)"), "{c}");
        // A class owner aw-wraps the +1 returned id (ADR-0038 §4).
        assert!(c.contains("(aw-wrap (sb-alien:alien-funcall"), "{c}");
        assert!(c.trim_end().ends_with("t))"), "{c}");
    }

    #[test]
    fn init_constructor_value_owner_hands_back_raw_box() {
        let i = InitTrampoline {
            module: "TestKit".into(),
            owner: "IndexSet".into(),
            swift_owner: "IndexSet".into(),
            entry: "aw_sbcl_swift_init_TestKit_IndexSet".into(),
            owner_is_class: false,
            labels: vec!["integer".into()],
            params: vec![ArgMarshal::Scalar(Scalar::Int)],
            throwing: false,
            availability: None,
        };
        assert_eq!(i.binding_symbol(), "ns:make-index-set-integer");
        let c = i.render_constructor();
        // A value owner hands back the raw opaque box — no aw-wrap.
        assert!(!c.contains("aw-wrap"), "{c}");
        assert!(c.contains("(sb-alien:extern-alien \"aw_sbcl_swift_init_TestKit_IndexSet\""), "{c}");
    }

    #[test]
    fn throwing_init_constructor_threads_the_error_cell() {
        let i = InitTrampoline {
            module: "TestKit".into(),
            owner: "Doc".into(),
            swift_owner: "Doc".into(),
            entry: "aw_sbcl_swift_init_TestKit_Doc".into(),
            owner_is_class: true,
            labels: vec!["path".into()],
            params: vec![ArgMarshal::SwiftString],
            throwing: true,
            availability: None,
        };
        let c = i.render_constructor();
        assert!(c.contains("(aw-swift-call/error (%err)"), "{c}");
        assert!(c.contains("(aw-swift-string-arg path) %err)"), "{c}");
    }

    fn swift_method(selector: &str, init: bool, ret: TypeRef, params: Vec<Param>) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: init,
            params,
            return_type: ret,
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
            objc_exposed: false,
            swift_fn: Some(SwiftFnInfo::default()),
        }
    }

    #[test]
    fn class_residual_methods_dedup_same_generic_and_collect_inits() {
        // Two overloads of `tag(_:)` collapse to one ns:tag defmethod (first wins);
        // an `init(value:)` collects as a constructor.
        let methods = vec![
            swift_method("tag(_:)", false, prim("void"), vec![param("_", prim("int64"))]),
            swift_method("tag(_:)", false, prim("void"), vec![param("_", prim("double"))]),
            swift_method("init(value:)", true, idty(), vec![param("value", prim("int64"))]),
        ];
        let ms = class_residual_methods("TestKit", "Widget", &methods);
        assert_eq!(ms.len(), 1, "overloads dedup to one generic: {ms:?}");
        assert_eq!(ms[0].generic_decl(), ("ns:tag".to_string(), 1));

        let is = class_residual_inits("TestKit", "Widget", &methods);
        assert_eq!(is.len(), 1);
        assert_eq!(is[0].binding_symbol(), "ns:make-widget-value");
    }
}
