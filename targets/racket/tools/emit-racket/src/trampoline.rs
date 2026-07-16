//! Generated C-ABI trampolines for the Swift-native residual (ADR-0027).
//!
//! 030 made the direct-vs-trampoline boundary an explicit IR fact (`objc_exposed`,
//! ADR-0026) and *retained* top-level Swift-native (`s:` USR) functions/constants
//! instead of dropping them. This module is the racket target acting on that fact:
//! for every retained `objc_exposed == false` declaration it vends a **call-by-name
//! `@_cdecl` trampoline** in `Generated/Trampolines.swift` — a C-linkable Swift
//! function that `import`s the owning framework module and calls the API by its
//! reconstructed Swift name + argument labels, letting swiftc own ABI correctness
//! (ADR-0027 §1). The racket emitter (`emit_functions` / `emit_constants`) binds
//! those entries against `libAPIAnywareRacket` (`_aw-lib`) instead of the framework
//! dylib, computing the same content-addressed entry name independently.
//!
//! **Marshalling taxonomy (this leaf — spec §3 / §5, user-confirmed scope).**
//! Because `map_swift_type` already normalises Swift value types into the
//! ObjC-bridged vocabulary (`String`→`NSString`, `Int`→`int64`, …), the bindable
//! half of the taxonomy falls out of the existing `TypeRef`:
//!
//! - **Return** has a *universal* safe rep: a scalar/`Bool` returns directly, a
//!   `String` bridges to a racket string, and **anything else** is wrapped in the
//!   generic `awRacketBox` (an opaque [`OpaqueHandle`]-style handle) — so the
//!   return type never has to be *named* in generated Swift. Every function whose
//!   params are bindable is therefore trampolinable.
//! - **Params** are the constraint: a scalar/`Bool`/`String` param can be
//!   reconstructed and passed by-value/with the `as String` bridge; a **value
//!   struct the owning framework defines** (`MLTensor`) is unboxed from the opaque
//!   handle racket holds (`awRacketUnbox(aN!, as: Name.self)`, leaf 040/040/030);
//!   a CF/ObjC reference type, a closure, or an `id`/`Any` param still cannot be
//!   soundly unboxed and is deferred with a reason and counted.
//! - **`throws`** → a trailing `NSError **` out-param run through `awRacketTry`
//!   (the `ThrowsBridge.swift` runtime, mirroring the dispatch `error_out` shape).
//! - **`async`** and **generic free functions** are recorded with a reason + count
//!   ([`Deferred`]), never silently dropped (spec §5).
//!
//! Naming is content-addressed (ADR-0013 precedent) so the emitter reconstructs
//! the same symbol with no shared counter: `aw_racket_swift_<Fw>_<name>`, with a
//! short signature hash appended when a `(module, name)` is overloaded within its
//! framework; constants are `aw_racket_swift_const_<Fw>_<name>`.

use std::collections::{BTreeMap, HashMap, HashSet};

use apianyware_types::ir::{Constant, Framework, Function, Method, Struct};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

/// Prefix for a Swift-native **function** trampoline entry.
pub const FN_PREFIX: &str = "aw_racket_swift_";
/// Prefix for a Swift-native **constant** trampoline entry.
pub const CONST_PREFIX: &str = "aw_racket_swift_const_";

// ---------------------------------------------------------------------------
// Marshalling taxonomy
// ---------------------------------------------------------------------------

/// How one value crosses the trampoline's flat C-ABI boundary, in a **parameter**
/// position. Bindable params are the constraint on trampolinability (the return
/// side has a universal boxed rep — see [`RetMarshal`]).
#[derive(Debug, Clone, PartialEq, Eq)]
enum ArgMarshal {
    /// A C scalar passed straight through. Carries the Swift type spelled at the
    /// `@_cdecl` boundary (`Int`, `Double`, `Int32`, …) — which is also the type
    /// the by-name call receives, so no conversion is generated.
    Scalar(Scalar),
    /// A **scalar-backed named typedef** (`CGFloat`) that `map_swift_type` lossily
    /// lowered to a `Class`/`Struct`/`Alias` even though it is a single C scalar at
    /// the ABI. The `@_cdecl` receives the underlying scalar (`Double` for
    /// `CGFloat`); the body wraps it as the named type (`CGFloat(a0)`) so the
    /// by-name call type-checks against the real (non-bridged-struct) parameter.
    ScalarTypedef { scalar: Scalar, name: String },
    /// `Swift.String` ⇄ `NSString`. The `@_cdecl` receives an `id`; the body
    /// reconstructs `… as String` before the call.
    SwiftString,
    /// A **non-bridged Swift value struct** parameter (`MLTensor`, `MLUntypedColumn`,
    /// …) that the owning framework defines in `Framework.structs`. Racket holds it
    /// as the opaque [`OpaqueHandle`]-style handle a prior boxed return handed it;
    /// the `@_cdecl` receives that raw pointer and the body unboxes the *named* value
    /// (`awRacketUnbox(aN!, as: Name.self)`) before the by-name call — sound only
    /// because the name is in the struct set, i.e. a value type the box round-trips,
    /// not a CF/ObjC reference that would trap (spec §5a, leaf 040/040/030 fork 1).
    BoxedHandle { name: String },
    /// An **objc-bridged reference** parameter (R1, leaf 030/020). The lossy
    /// Swift→ObjC normalization reports a Swift value param as its Foundation objc
    /// twin (`URL` → `NSURL`, `Data` → `NSData`). Racket holds the twin as an `id`
    /// cpointer; the `@_cdecl` receives that raw pointer, reconstructs the objc
    /// reference (`Unmanaged<NSURL>`) and bridges it to the Swift value the by-name
    /// call wants (`… as URL`). Only the curated [`objc_object_param_bridge`] set
    /// rides this path — an unknown `Class` param stays deferred (a Swift-native
    /// struct lowered to `Class`, like `GeoRect`, must not be mistaken for a bridge).
    ObjectRef {
        class_name: String,
        bridge_to: String,
    },
}

/// The curated objc reference classes whose params bridge to a Swift value twin
/// (R1). The digester reports a Swift `URL`/`Data`/… param as its Foundation objc
/// class (`NSURL`/`NSData`/…); the trampoline reconstructs that reference and
/// bridges to the value the by-name call needs. Returns the Swift value type to
/// cast to, or `None` for a `Class` name not in the set (stays deferred). The set
/// grows as the whole-framework typecheck demands (the §6 honest-residual
/// discipline) — every entry is a verified `_ObjectiveCBridgeable` value pair.
fn objc_object_param_bridge(name: &str) -> Option<&'static str> {
    Some(match name {
        // Verified clean against the whole Foundation residual (`swiftc -typecheck`,
        // Swift 6). The set is deliberately small: an objc twin like `NSDate` also
        // appears as a hidden `inout Date` param (e.g. `Calendar.dateIntervalOf-
        // Weekend`), and `inout` is invisible in the IR — so a speculative entry can
        // surface an uncompilable method. Each pair here is proven, not assumed; the
        // full-pipeline typecheck in `030-rerun-verify` (over enriched IR that may
        // expose `inout`) is where the set widens.
        "NSURL" => "URL",
        "NSURLRequest" => "URLRequest",
        _ => return None,
    })
}

/// How a **return** value crosses the boundary. Every shape here is producible
/// without naming the concrete Swift type, so any function with bindable params
/// is trampolinable.
#[derive(Debug, Clone, PartialEq, Eq)]
enum RetMarshal {
    Void,
    Scalar(Scalar),
    /// A scalar-backed named typedef return (`-> CGFloat`): the `@_cdecl` returns
    /// the underlying scalar; the body converts the call result (`Double(<call>)`).
    /// Strictly better than boxing a number behind an opaque handle, and what makes
    /// `acos`/`nan`-style math residual resolve to a plain racket `real?`.
    ScalarTypedef {
        scalar: Scalar,
        name: String,
    },
    /// `Swift.String` → bridged `NSString`, returned +1-retained as an `id`; the
    /// racket side copies to a string and releases.
    SwiftString,
    /// Anything else (non-bridged struct, object, tuple, existential, …) — wrapped
    /// in the generic `awRacketBox` and returned as an opaque handle pointer. The
    /// optional `String` is a nameable Swift return type (a typedef alias like
    /// `CGFloat`) used to disambiguate the by-name call (`(call) as CGFloat`) when
    /// the residual has cross-module return-type overloads (`nan` in CoreGraphics
    /// and _DarwinFoundation1); `None` when the return type is not safely nameable.
    Handle(Option<String>),
}

/// The closed set of C scalar shapes a trampoline param/return can be. The Swift
/// spelling is what the `@_cdecl` uses *and* what the by-name call passes, so they
/// agree by construction.
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
    /// The Swift type at the `@_cdecl` boundary. `int64`/`uint64` map to Swift's
    /// word types `Int`/`UInt` (the overwhelmingly common Swift spelling, and what
    /// a by-name call to an `Int`-taking API needs); fixed widths stay fixed.
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

    /// The Racket `ffi/unsafe` spelling for the binding's `_fun` arrow.
    fn ffi(self) -> &'static str {
        match self {
            Scalar::Bool => "_bool",
            Scalar::Int | Scalar::Int64 => "_int64",
            Scalar::UInt | Scalar::UInt64 => "_uint64",
            Scalar::Int8 => "_int8",
            Scalar::UInt8 => "_uint8",
            Scalar::Int16 => "_int16",
            Scalar::UInt16 => "_uint16",
            Scalar::Int32 => "_int32",
            Scalar::UInt32 => "_uint32",
            Scalar::Float => "_float",
            Scalar::Double => "_double",
        }
    }

    /// Is this an integer scalar (so a width-agnostic `numericCast` is valid)?
    /// `Bool`/`Float`/`Double` are not `BinaryInteger` and pass through unconverted.
    fn is_integer(self) -> bool {
        !matches!(self, Scalar::Bool | Scalar::Float | Scalar::Double)
    }

    /// The `awRacketTry` fallback literal for this scalar on the throwing path.
    fn fallback(self) -> &'static str {
        match self {
            Scalar::Bool => "false",
            Scalar::Float | Scalar::Double => "0",
            _ => "0",
        }
    }

    /// The Racket `provide/contract` predicate for this scalar (post-coercion,
    /// racket-visible type).
    fn contract(self) -> &'static str {
        match self {
            Scalar::Bool => "boolean?",
            Scalar::Float | Scalar::Double => "real?",
            Scalar::Int | Scalar::Int8 | Scalar::Int16 | Scalar::Int32 | Scalar::Int64 => {
                "exact-integer?"
            }
            Scalar::UInt | Scalar::UInt8 | Scalar::UInt16 | Scalar::UInt32 | Scalar::UInt64 => {
                "exact-nonnegative-integer?"
            }
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

/// `map_swift_type` lowers an anonymous Swift tuple to `Class { name: "Tuple", … }`
/// — a sentinel name that cannot be spelled as a Swift type. A tuple return must
/// therefore box **unnamed** (the opaque `awRacketBox` infers the element types);
/// emitting `as Tuple` does not compile. (`remquo`/`lgamma` return `(CGFloat, Int)`.)
fn is_unspellable_type_name(name: &str) -> bool {
    name == "Tuple"
}

/// A **scalar-backed named typedef**: a Swift type that `map_swift_type` lowers to
/// a named `Class`/`Struct`/`Alias` but which is a single C scalar at the ABI, so
/// it marshals by value as that scalar rather than behind an opaque handle.
///
/// `CGFloat` is the dominant case in the real residual (44 of the 69
/// `deferred_nonbridged_struct_param` functions were CGFloat-only — it is
/// `Foundation.CGFloat`, a `Double` on every 64-bit Apple platform). Kept a small,
/// principled allowlist: a member here must be a *single scalar* with a Swift
/// `init(_:)` from and conversion to that scalar, so the generated `Name(a0)` /
/// `Double(call)` round-trips type-check.
fn scalar_typedef(name: &str) -> Option<Scalar> {
    match name {
        "CGFloat" => Some(Scalar::Double),
        _ => None,
    }
}

/// Classify a param `TypeRef` into its marshalling, or the [`DeferReason`] that
/// records why it cannot be trampolined this leaf. Both the global pass and the
/// racket emitter call [`classify_function`], which calls this, so the recorded
/// reason and the emitted binding always agree.
///
/// `value_structs` is the owning framework's **own** set of `Framework.structs`
/// names — a param whose named type is in it is a Swift value struct the box
/// round-trips, so it rides the [`ArgMarshal::BoxedHandle`] unbox path. The set is
/// per-framework (not global) on purpose: the `@_cdecl` `import`s only its owning
/// module, so a cross-module struct type would not be in scope to spell, and a
/// per-framework set keeps the global pass and the per-framework emitter — which
/// each build it from the same single `Framework.structs` — classifying identically
/// (leaf 040/040/030 fork 2: the smallest sound option).
fn classify_param(t: &TypeRef, value_structs: &HashSet<&str>) -> Result<ArgMarshal, DeferReason> {
    if is_swift_string(t) {
        return Ok(ArgMarshal::SwiftString);
    }
    match &t.kind {
        TypeRefKind::Primitive { name } => scalar_of_primitive(name)
            .map(ArgMarshal::Scalar)
            .ok_or(DeferReason::NonBridgedStructParam),
        // A named type lowered from a non-bridged Swift value. Three sub-cases, most
        // specific first: a scalar-backed typedef (`CGFloat`) marshals by value; a
        // value struct the owning framework defines (`MLTensor`) rides the named-type
        // handle-unbox path; anything else (a CF/ObjC reference type, a bridged
        // collection) still cannot be soundly unboxed and stays deferred.
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
        // A closure/function-pointer parameter — a distinct, harder case than an
        // unboxable value (it needs a Swift closure synthesised over a C callback),
        // recorded under its own reason so the residual is honestly categorised.
        TypeRefKind::Block { .. } | TypeRefKind::FunctionPointer { .. } => {
            Err(DeferReason::ClosureParam)
        }
        // `id`/`Any`, raw pointers, selectors, … — not a nameable type the body can
        // unbox to, so they cannot ride the handle path at all.
        _ => Err(DeferReason::UnnameableParam),
    }
}

/// Classify a return `TypeRef`. Total: every shape maps somewhere (the boxed
/// handle is the universal fallback), so the return never blocks trampolinability.
fn classify_return(t: &TypeRef) -> RetMarshal {
    if is_swift_string(t) {
        return RetMarshal::SwiftString;
    }
    match &t.kind {
        TypeRefKind::Primitive { name } => match scalar_of_primitive(name) {
            Some(s) => RetMarshal::Scalar(s),
            // `void` is the only non-scalar primitive; anything else unknown boxes.
            None if normalize_primitive(name) == "void" => RetMarshal::Void,
            None => RetMarshal::Handle(None),
        },
        // A scalar-backed named typedef (`CGFloat`) returns by value as its scalar,
        // not boxed behind a handle — `acos`/`nan` resolve to a racket `real?`.
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
        // An anonymous tuple (sentinel name `Tuple`) cannot be spelled — box unnamed.
        TypeRefKind::Alias { name, .. }
        | TypeRefKind::Class { name, .. }
        | TypeRefKind::Struct { name }
            if is_unspellable_type_name(name) =>
        {
            RetMarshal::Handle(None)
        }
        // A typedef alias (`NSTimeInterval`) or a named class/struct is a valid
        // in-scope Swift type (via the module `import`) — carry the name so the
        // by-name call's result type can be pinned with `as <Type>`, which both
        // disambiguates cross-module return-type overloads and is a harmless
        // identity cast otherwise.
        TypeRefKind::Alias { name, .. } | TypeRefKind::Class { name, .. } => {
            RetMarshal::Handle(Some(name.clone()))
        }
        _ => RetMarshal::Handle(None),
    }
}

// ---------------------------------------------------------------------------
// Trampoline plans
// ---------------------------------------------------------------------------

/// A function the racket target trampolines: the resolved marshalling plan plus
/// everything both the Swift codegen and the racket emitter need, computed purely
/// from `(module, Function)` so the two sides agree without shared state.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FnTrampoline {
    /// Owning Swift module (the enclosing `Framework.name`) — the `import` target
    /// and the call's implicit namespace.
    pub module: String,
    /// Bare Swift function name (`Function.name`) used in the by-name call.
    pub swift_name: String,
    /// The **racket-visible** binding name (the `(define …)` / `provide` identifier).
    /// Equal to `swift_name`, except a same-module overload carries the same content
    /// hash its `entry` does (`show_06c0f52a`) — racket has no overloading, so three
    /// `(define show)` would collide; mirroring the entry's content-addressing keeps
    /// every overload reachable and deterministic (ADR-0013; leaf 040/040/030).
    pub binding_name: String,
    /// Content-addressed C entry symbol (`aw_racket_swift_<Fw>_<name>[_<hash>]`).
    pub entry: String,
    /// Per-param argument label (from `Param.name`); `"_"` means no label.
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    ret: RetMarshal,
    /// The Swift function `throws` — the trampoline takes a trailing `NSError **`.
    throwing: bool,
    /// The macOS version the wrapped API was `introduced:` (from IR provenance),
    /// emitted as `@available(macOS <v>, *)` on the `@_cdecl` so swiftc accepts a
    /// call to a version-gated API. `None` when unversioned.
    availability: Option<String>,
}

/// A Swift-native constant the racket target trampolines: a `@_cdecl` reader that
/// returns the global's current value (Swift-native globals have no C symbol to
/// `dlsym`, so even scalar ones need a reader — not just pointer-valued ones).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConstTrampoline {
    pub module: String,
    pub swift_name: String,
    pub entry: String,
    ret: RetMarshal,
    /// `@available(macOS <v>, *)` for a version-gated global; `None` otherwise.
    availability: Option<String>,
}

/// The macOS `introduced:` version from a declaration's IR provenance, if any —
/// the trampoline emits it as `@available(macOS <v>, *)` so swiftc accepts the
/// call to a version-gated API (the residual is full of them).
pub fn introduced_macos(
    provenance: &Option<apianyware_types::provenance::SourceProvenance>,
) -> Option<String> {
    provenance
        .as_ref()
        .and_then(|p| p.availability.as_ref())
        .and_then(|a| a.introduced.clone())
}

/// Parse a dotted macOS version (`"26.4"`, `"15"`) into comparable components so two
/// `introduced:` strings can be ordered.
fn version_key(v: &str) -> Vec<u32> {
    v.split('.').map(|c| c.parse().unwrap_or(0)).collect()
}

/// The higher of two `@available(macOS …)` gates. A method's own `introduced:` can be
/// **lower** than its owning type's (or absent while the type's is present): a
/// `@_cdecl` calling `Owner.method()` must be gated to the *max* of the two, else
/// swiftc rejects the call ("'Owner' is only available in macOS N or newer"). Used to
/// fold the owner type's availability into the method/init gate (spec §8.8).
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
/// machine-readable reason and surfaced in the pass log (spec §5 — defer nothing,
/// but be honest).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Deferred {
    pub module: String,
    pub name: String,
    pub reason: DeferReason,
}

/// Why a residual declaration was not trampolined.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DeferReason {
    /// Generic free function — `@_cdecl` cannot be generic; a *hard* limit.
    UnbindableGenericFreeFunction,
    /// `async` function — runtime-ready, codegen is a follow-up leaf.
    Async,
    /// A non-Foundation-bridged Swift struct/tuple/existential **parameter** that is
    /// a *nameable value type* (or CF/ObjC reference, or bridged collection) — needs
    /// the named-type handle-unbox path (a focused follow-up leaf; see the spec §5
    /// kick-back). The scalar-backed-typedef subset (`CGFloat`) is recovered here.
    NonBridgedStructParam,
    /// A closure / function-pointer **parameter** — needs a Swift closure synthesised
    /// over a C callback, a distinct case from an unboxable value.
    ClosureParam,
    /// A parameter that is not a nameable type at all (`id`/`Any`, a raw pointer, a
    /// selector, …) — cannot ride the handle-unbox path even in principle.
    UnnameableParam,
    /// A **generic method** (`generic_sig` present). Like a generic free function,
    /// `@_cdecl` cannot be generic — a hard limit. The bulk of the residual (every
    /// protocol requirement, the heavily-generic SwiftUI value types).
    UnbindableGenericMethod,
    /// A `consuming self` method (D3): the call destroys the receiver, so the handle
    /// the racket side still holds would dangle. Deferred-with-count regardless of
    /// receiver kind.
    ConsumingReceiver,
    /// A method whose base name is not a callable Swift identifier — an operator
    /// (`==`, `<`), a subscript, etc. — so `receiver.<name>(args)` does not parse.
    NonNameableMethod,
    /// A `static`/class method (`+`): no receiver instance to unbox; a small
    /// population handled like a namespaced free function — deferred-with-count in
    /// the sync structural leaf, a clean follow-up.
    StaticMethod,
    /// A variadic method — a flat `@_cdecl` cannot forward a Swift variadic; deferred.
    VariadicMethod,
    /// A method returning a **nullable scalar** (`Int?`) — a C scalar cannot carry
    /// `nil`, so it cannot ride the by-value return; deferred (a boxed-optional return
    /// is a clean follow-up). Nullable String/handle returns *are* handled (NULL/#f).
    NullableScalarReturn,
    /// An `async` **mutating value-receiver** method (D5/R4): the mutated copy would
    /// have to be written back into the handle box, but the write happens on the
    /// cooperative thread *after* the call site returned — the single-identity
    /// write-back (D3) is ill-defined across the async hop. Deferred-with-count.
    AsyncMutatingReceiver,
    /// An `async` method returning a **scalar** (`async -> Int`): the completion
    /// rides `AwAsyncOutcome`, whose payload is a pointer; a C scalar cannot cross
    /// it without boxing. Deferred-with-count (a boxed-scalar async carrier is a
    /// clean follow-up); the dominant async returns are objects/tuples/void.
    AsyncScalarReturn,

    // --- Curated-residual reasons (spec §8.8): swiftc rejects the @_cdecl for a
    // cause the lossy IR cannot predict. Suppressed via the [`KNOWN_UNBINDABLE`]
    // USR table, each counted under its own reason. ---
    /// The method/init is **actor-isolated** (`@MainActor` or an `actor` member):
    /// a synchronous nonisolated `@_cdecl` cannot call it (`#ActorIsolatedCall`).
    /// `swift-api-digester` does not surface isolation at all, so this is curated.
    /// A future async-hopping trampoline could recover the `@MainActor` slice.
    ActorIsolated,
    /// A `Module.Owner` whose owner name is not a spellable top-level member of the
    /// module (`CloudKit.ID` is really `CKRecord.ID`; `MediaExtension.Integer` is a
    /// generic-context placeholder): `module 'X' has no member named 'Y'`. Recovering
    /// the qualified/nested name is a follow-up.
    ModuleMemberMissing,
    /// A type referenced in the call resolves to something that is not a member type
    /// (`'X' is not a member type of 'Y'` / `type 'X' has no member 'Y'`) — a nested
    /// or re-exported type the IR named unspellably.
    UnresolvedMemberType,
    /// An init/method parameter requires a **compile-time constant literal**
    /// (`@const`-position): the runtime-marshalled `@_cdecl` arg cannot satisfy it.
    CompileTimeConstantParam,
    /// A call whose **generic parameter could not be inferred** from the marshalled
    /// arguments — the method is not itself generic (that is `UnbindableGenericMethod`)
    /// but the call site needs a type witness the C boundary cannot supply.
    GenericInferenceFailure,
    /// A `~Copyable` (noncopyable) receiver or value: `Unmanaged`/`as!` reconstruction
    /// and the `AwValueBox` `as!` cast are both illegal on a noncopyable type.
    NoncopyableReceiver,
    /// The decl is only available in a macOS newer than the deployment floor, but its
    /// IR provenance carries **no** `introduced:` version (and neither does its owning
    /// type) — so no `@available` gate can be synthesised. Distinct from the gated
    /// residual the deployment-target bump cleared.
    UnknownAvailability,
    /// A method passing `self` (or a returned value) as an `inout` argument where the
    /// source is immutable (`cannot pass immutable value as inout`): the by-value
    /// receiver copy is not addressable for the mutation the API wants.
    ImmutableInoutArgument,
    /// The decl (or an overload swiftc selects) is `internal`/`private` —
    /// `inaccessible due to '…' protection level` — so the by-name call cannot reach
    /// it even though the digester surfaced the symbol.
    InaccessibleDecl,
    /// The marshalled `@_cdecl` argument list does not match any overload's shape
    /// (`extra arguments at positions …`): the IR's flattened param list diverged from
    /// the real initializer/method signature.
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

/// The whole-program trampoline plan: what to emit into `Trampolines.swift` and
/// what was deferred. Built once over all enriched frameworks by the global pass.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct TrampolineSet {
    pub functions: Vec<FnTrampoline>,
    pub constants: Vec<ConstTrampoline>,
    /// Receiver-handle method trampolines (the method frontier, this grove).
    pub methods: Vec<MethodTrampoline>,
    /// Initializer producers — the population-B root handle producers (D2).
    pub inits: Vec<InitTrampoline>,
    pub deferred: Vec<Deferred>,
}

impl TrampolineSet {
    /// Per-reason deferred counts, for the pass log (`"N trampolined, M unbindable …"`).
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
/// An ObjC-exposed function never reaches here (the caller filters on
/// `!objc_exposed`); both the global pass and the racket emitter call this so the
/// emitted binding and the generated `@_cdecl` always agree.
pub enum FnDisposition {
    Trampoline(FnTrampoline),
    Deferred(DeferReason),
}

/// The owning framework's own value-struct names — the gate for the
/// [`ArgMarshal::BoxedHandle`] param-unbox path. Built from `Framework.structs`
/// (every entry there is a Swift value type the `AwValueBox` round-trips); a
/// CF/ObjC reference type is in `classes` or absent, so it is correctly excluded.
pub fn value_struct_names(structs: &[Struct]) -> HashSet<&str> {
    structs.iter().map(|s| s.name.as_str()).collect()
}

/// Classify a Swift-native (`objc_exposed == false`) function. `siblings` is the
/// full residual-function set of the *same* module (used only for overload
/// disambiguation in the entry name) — pass the framework's functions; the
/// classifier filters them itself. `value_structs` is the owning framework's
/// [`value_struct_names`] — the gate for unboxing a value-struct parameter.
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
            // The first non-bindable param's reason wins — deterministic, and the
            // most specific category is recorded rather than a blanket umbrella.
            Err(reason) => return FnDisposition::Deferred(reason),
        }
    }
    let ret = classify_return(&func.return_type);
    let throwing = func.swift_fn.as_ref().is_some_and(|i| i.throwing);
    let labels = func.params.iter().map(|p| p.name.clone()).collect();
    // Racket has no overloading: a same-module overload's binding name carries the
    // same content hash its C entry does, so three `(define show)` don't collide.
    let binding_name = if is_overloaded(func, siblings) {
        format!("{}_{}", func.name, overload_hash(func))
    } else {
        func.name.clone()
    };
    let entry = function_entry_name(module, func, siblings);

    FnDisposition::Trampoline(FnTrampoline {
        module: module.to_string(),
        swift_name: func.name.clone(),
        binding_name,
        entry,
        labels,
        params,
        ret,
        throwing,
        availability: introduced_macos(&func.provenance),
    })
}

/// Classify a Swift-native constant. Always trampolinable (the return rep is
/// total), so this returns the plan directly.
pub fn classify_constant(module: &str, constant: &Constant) -> ConstTrampoline {
    ConstTrampoline {
        module: module.to_string(),
        swift_name: constant.name.clone(),
        entry: constant_entry_name(module, &constant.name),
        ret: classify_return(&constant.constant_type),
        availability: introduced_macos(&constant.provenance),
    }
}

// ---------------------------------------------------------------------------
// Entry naming (content-addressed; emitter reconstructs the same symbol)
// ---------------------------------------------------------------------------

/// Sanitise a module/name fragment into a valid C-identifier tail (digester names
/// are already identifier-shaped, but be defensive about stray punctuation).
fn sanitize(fragment: &str) -> String {
    fragment
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '_' })
        .collect()
}

/// A short, stable hex hash of an overloaded function's argument-label + ABI shape,
/// appended to the entry name so two overloads of the same `(module, name)` get
/// distinct symbols computable without a global counter (ADR-0013 precedent).
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
        TypeRefKind::Id { .. } => "id".into(),
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

/// True when `(module, func.name)` is overloaded within `siblings` (>1 residual,
/// non-deferred-by-attribute function shares the bare name) — the only case that
/// needs an overload hash. Both the pass and the emitter see the same per-module
/// `siblings`, so they agree on whether the hash is present.
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
/// function (trampolined or deferred) and constant across all frameworks.
pub fn collect_trampolines(frameworks: &[Framework]) -> TrampolineSet {
    let mut set = TrampolineSet::default();
    for fw in frameworks {
        // The owning framework's own value structs gate the param-unbox path; the
        // emitter rebuilds the identical set from the same `Framework.structs`.
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
        // Receiver-handle method + init trampolines (the method frontier). Walk both
        // classes (reference receivers) and structs (value receivers); a method is
        // Swift-native iff it carries `swift_fn` (⇔ `objc_exposed == false`).
        for c in &fw.classes {
            // `Class` carries no `provenance` field (unlike `Struct`); a class-owned
            // method's own gate suffices, and the type-gated availability residual is
            // entirely value-struct owners (spec §8.8).
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
    // `Scanner`). The entry symbol + the racket dispatch identity keep the runtime `owner`;
    // only the `@_cdecl` body's type reference uses `swift_owner`. Struct (value) owners are
    // not overlay-renamed, so they keep the default (`owner`).
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

    // The IR can carry the same decl twice (a category re-listing it, or a digester
    // duplicate), which would emit two `@_cdecl`s with the identical content-addressed
    // entry — a Swift redeclaration error. A duplicate entry *is* the same trampoline,
    // so keep the first occurrence of each entry across every kind.
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

/// Collect the method/init trampolines (or deferrals) for one owning type's method
/// list — `owner_is_class` selects the reference (`Unmanaged`) vs value (`AwValueBox`)
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

// ---------------------------------------------------------------------------
// Swift codegen (Generated/Trampolines.swift)
// ---------------------------------------------------------------------------

/// The per-argument `label: value` strings inside a by-name call's parentheses,
/// reconstructing each marshalled param from its `@_cdecl` boundary binding (the
/// scalar `a{i}`, the bridged string `s{i}`, the unboxed value `u{i}`, …). Shared
/// by the free-function [`call_expr`] and the method/init call builders so the
/// reconstruction rules live in one place.
fn arg_values(params: &[ArgMarshal], labels: &[String], numeric_cast: bool) -> Vec<String> {
    params
        .iter()
        .zip(labels)
        .enumerate()
        .map(|(i, (m, label))| {
            let value = match m {
                // The IR collapses `Int`/`Int64` (and the unsigned/narrower widths)
                // onto one `int64`/etc. token, so the `@_cdecl` param type may not be
                // the exact width the API wants (e.g. an API taking `Int64` where we
                // declared `Int`). `numericCast` bridges any integer width the by-name
                // call infers — the method/init path opts in; free functions (whose
                // residual has no width mismatch) keep the bare pass-through.
                ArgMarshal::Scalar(s) if numeric_cast && s.is_integer() => {
                    format!("numericCast(a{i})")
                }
                ArgMarshal::Scalar(_) => format!("a{i}"),
                // Re-wrap the underlying scalar as the named typedef so the by-name
                // call binds the real (CGFloat-taking) overload: `CGFloat(a0)`.
                ArgMarshal::ScalarTypedef { name, .. } => format!("{name}(a{i})"),
                ArgMarshal::SwiftString => format!("s{i}"),
                // The prelude unboxed the handle to `u{i}: Name`; pass that value.
                ArgMarshal::BoxedHandle { .. } => format!("u{i}"),
                // The prelude bridged the objc reference to `o{i}: <value twin>`.
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
    // Module-qualify the call (`CoreGraphics.nan(…)`): the residual has free
    // functions a second imported module also exports (`nan` in CoreGraphics and
    // _DarwinFoundation1), so a bare name is ambiguous; the owning module
    // disambiguates and is always in scope (we `import` it).
    format!(
        "{}.{}({})",
        t.module,
        t.swift_name,
        arg_values(&t.params, &t.labels, false).join(", ")
    )
}

/// The `@_cdecl` parameter list (named) and the body's reconstruction prelude, for
/// a sequence of marshalled args (`a0`, `a1`, …). The receiver-handle method/init
/// trampolines reuse this for their *argument* params (the receiver is prepended
/// separately by the method/init emitter).
fn args_decl_and_prelude(params: &[ArgMarshal]) -> (Vec<String>, String) {
    let mut decl = Vec::with_capacity(params.len());
    let mut prelude = String::new();
    for (i, m) in params.iter().enumerate() {
        match m {
            ArgMarshal::Scalar(s) => decl.push(format!("_ a{i}: {}", s.swift())),
            // Boundary param is the underlying scalar (`Double`); `call_expr` wraps
            // it back to the typedef.
            ArgMarshal::ScalarTypedef { scalar, .. } => {
                decl.push(format!("_ a{i}: {}", scalar.swift()))
            }
            ArgMarshal::SwiftString => {
                decl.push(format!("_ a{i}: UnsafeMutableRawPointer?"));
                prelude.push_str(&format!(
                    "  let s{i} = Unmanaged<NSString>.fromOpaque(a{i}!).takeUnretainedValue() as String\n"
                ));
            }
            // Boundary param is the opaque value handle; unbox the named value the
            // by-name call needs. Sound because `name` is in the framework's struct
            // set (an `AwValueBox`-round-trippable value type, not a reference).
            ArgMarshal::BoxedHandle { name } => {
                decl.push(format!("_ a{i}: UnsafeMutableRawPointer?"));
                prelude.push_str(&format!(
                    "  let u{i} = awRacketUnbox(a{i}!, as: {name}.self)\n"
                ));
            }
            // Boundary param is an opaque `id`; reconstruct the objc reference and
            // bridge it to the Swift value twin the by-name call wants (R1).
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

/// Marshals a call expression (`{call}`) to the `@_cdecl` boundary's C rep —
/// owned so the boxed-handle arm can capture its disambiguating type name.
type Marshaller = Box<dyn Fn(&str) -> String>;

/// The C return type spelled at the `@_cdecl` boundary, and the success-path
/// expression that marshals `<call>` to it (with `{call}` substituted in).
fn return_shape(ret: &RetMarshal) -> (String, Marshaller) {
    match ret {
        RetMarshal::Void => ("Void".to_string(), Box::new(|c: &str| c.to_string())),
        RetMarshal::Scalar(s) => (
            s.swift().to_string(),
            // Pass the scalar straight back.
            Box::new(|c: &str| c.to_string()),
        ),
        RetMarshal::ScalarTypedef { scalar, name } => {
            let conv = scalar.swift(); // e.g. "Double"
            let name = name.clone();
            (
                scalar.swift().to_string(),
                // Convert the typedef result to the underlying scalar, pinning the
                // typedef with `as <Type>` first: `Double((call) as CGFloat)`. The
                // cast disambiguates cross-module return-type overloads (`nan` is
                // declared in both CoreGraphics and _DarwinFoundation1, returning
                // CGFloat vs Float) — without it `Double(...)` accepts either and the
                // call is ambiguous; it is a harmless identity cast otherwise.
                Box::new(move |c: &str| format!("{conv}(({c}) as {name})")),
            )
        }
        RetMarshal::SwiftString => (
            "UnsafeMutableRawPointer?".to_string(),
            // Bridge to NSString, hand racket a +1-retained id.
            Box::new(|c: &str| format!("Unmanaged.passRetained(({c}) as NSString).toOpaque()")),
        ),
        RetMarshal::Handle(ty) => (
            "UnsafeMutableRawPointer?".to_string(),
            // Box any non-bridged value behind the uniform opaque handle, with an
            // `as <Type>` cast when the return type is nameable (disambiguates a
            // cross-module return-type overload like `nan`).
            match ty {
                Some(name) => {
                    let name = name.clone();
                    Box::new(move |c: &str| format!("awRacketBox(({c}) as {name})"))
                }
                None => Box::new(|c: &str| format!("awRacketBox({c})")),
            },
        ),
    }
}

/// The `awRacketTry` fallback for the throwing path, given the return rep.
fn throw_fallback(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "()",
        RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => s.fallback(),
        RetMarshal::SwiftString | RetMarshal::Handle(_) => "nil",
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
        // Run the (possibly result-producing) call inside awRacketTry, which
        // writes any thrown error through `awErrOut` and returns the fallback.
        let body = match &t.ret {
            RetMarshal::Void => format!("  awRacketTry(awErrOut, ()) {{ try {call} }}\n"),
            // A scalar (or scalar-backed typedef, marshalled to its underlying
            // scalar) returns directly with the scalar fallback — no `Optional`.
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => format!(
                "  return awRacketTry(awErrOut, {fb}) {{ {marshalled} }}\n",
                fb = throw_fallback(&t.ret),
                marshalled = marshal(&format!("try {call}"))
            ),
            RetMarshal::SwiftString | RetMarshal::Handle(_) => {
                // The success branch marshals the value to its pointer rep; the
                // closure result is `UnsafeMutableRawPointer?` so the `nil`
                // fallback unifies.
                let marshalled = marshal(&format!("try {call}"));
                format!("  return awRacketTry(awErrOut, nil) {{ Optional({marshalled}) }}\n")
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
        // A `Void` constant is meaningless; treat as a handle of `()` defensively.
        " -> UnsafeMutableRawPointer?".to_string()
    } else {
        format!(" -> {cret}")
    };
    s.push_str(&format!("public func {}(){} {{\n", t.entry, sig_ret));
    match &t.ret {
        RetMarshal::Void => s.push_str(&format!("  return awRacketBox({read})\n")),
        _ => s.push_str(&format!("  return {}\n", marshal(&read))),
    }
    s.push_str("}\n");
}

/// Generate `Generated/Trampolines.swift`: the imports, then one `@_cdecl` per
/// trampolined function and constant. Deferred decls produce no Swift.
/// Map an **implementation-detail** module to the umbrella module that re-exports
/// it (`@_exported import`), for the Swift `import` line and the `Module.Owner`
/// type qualifier only. Swift forbids `import RealityFoundation` ("it is an
/// implementation detail of RealityKit; import RealityKit instead"), but the same
/// types are reachable through the umbrella's namespace — `RealityKit.MeshResource`
/// names the identical type as the illegal `RealityFoundation.MeshResource`. The
/// trampoline's `module` field is left untouched (it drives the content-addressed
/// entry symbol + the Racket binding identity, which both sides must agree on); only
/// the *Swift spelling* is re-attributed here. ADR-0030, spec §8.8. The residual
/// decls that the umbrella does not re-export, or that fail for an orthogonal reason
/// (actor isolation, …), are caught by the build and suppressed via
/// [`KNOWN_UNBINDABLE`].
fn swift_import_module(module: &str) -> &str {
    match module {
        "RealityFoundation" => "RealityKit",
        "SwiftUICore" => "SwiftUI",
        other => other,
    }
}

pub fn generate_trampolines_swift(set: &TrampolineSet) -> String {
    let mut s = String::new();
    s.push_str("// Generated C-ABI trampolines for the Swift-native residual (ADR-0027).\n");
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-generate` from the IR.\n");
    s.push_str("// One @_cdecl per retained `objc_exposed == false` Swift-native decl; each\n");
    s.push_str("// imports the owning framework and calls the API by name (swiftc owns ABI\n");
    s.push_str("// correctness). Bound from the generated Racket bindings against _aw-lib. See:\n");
    s.push_str("//   targets/racket/docs/design/2026-06-15-racket-trampoline.md\n");
    s.push_str("//   adr/0027-racket-trampoline-structure.md\n\n");
    s.push_str("import Foundation\n");

    // One `import` per distinct module that has at least one emitted trampoline.
    // Implementation-detail modules are re-attributed to their umbrella (e.g.
    // RealityFoundation → RealityKit) so the `import` is legal; entry names keep the
    // original module (see [`swift_import_module`]).
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

// ---------------------------------------------------------------------------
// Racket binding rendering (consumed by emit_functions / emit_constants)
// ---------------------------------------------------------------------------

/// The `_fun` arrow keyword used by **method/init trampoline** bindings.
///
/// A class file that routes ObjC `msgSend` natively (ADR-0013) drops
/// `ffi/unsafe`'s `->` via `(except-in ffi/unsafe ->)` so ffi2's own `->` (for the
/// native dispatch arrow types) is unambiguous. But a method-trampoline binding is
/// an ordinary `(_fun … -> …)` and needs `ffi/unsafe`'s arrow, which `_fun` matches
/// by binding identity. So trampoline files import `ffi/unsafe`'s `->` under the
/// alias `aw->` ([`AW_ARROW_REQUIRE`]) and the trampoline arrows are spelled with
/// it — `_fun` recognises the renamed arrow (free-identifier match), and it coexists
/// with ffi2's `->` in a native file. Non-native trampoline files get the alias too
/// (harmless: a second name for the same binding).
pub const AW_ARROW: &str = "aw->";

/// The require clause a trampoline-bearing class file adds so [`AW_ARROW`] resolves.
pub const AW_ARROW_REQUIRE: &str = "(only-in ffi/unsafe [-> aw->])";

/// The ffi/unsafe result spelling for a return marshalling (C-ABI rep).
fn ret_ffi(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "_void",
        RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => s.ffi(),
        RetMarshal::SwiftString | RetMarshal::Handle(_) => "_pointer",
    }
}

/// The racket-visible `provide/contract` predicate for a return marshalling.
fn ret_contract(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "void?",
        RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => s.contract(),
        // `String` returns map NULL → `#f` through the coercion.
        RetMarshal::SwiftString => "(or/c string? #f)",
        // An opaque handle is a raw cpointer on the racket side.
        RetMarshal::Handle(_) => "cpointer?",
    }
}

impl FnTrampoline {
    /// The ffi `_fun` arrow at the C-ABI rep, including the trailing `_pointer`
    /// error out-buffer when the function `throws` (spec §4).
    pub fn ffi_arrow(&self) -> String {
        let mut parts: Vec<&'static str> = self
            .params
            .iter()
            .map(|m| match m {
                ArgMarshal::Scalar(s) | ArgMarshal::ScalarTypedef { scalar: s, .. } => s.ffi(),
                // A boxed value handle, an objc reference and a bridged string all
                // cross as a pointer.
                ArgMarshal::SwiftString
                | ArgMarshal::BoxedHandle { .. }
                | ArgMarshal::ObjectRef { .. } => "_pointer",
            })
            .collect();
        if self.throwing {
            parts.push("_pointer"); // NSError** out-buffer
        }
        if parts.is_empty() {
            format!("(_fun -> {})", ret_ffi(&self.ret))
        } else {
            format!("(_fun {} -> {})", parts.join(" "), ret_ffi(&self.ret))
        }
    }

    /// The racket-visible `[name (c-> …)]` provide/contract line (post-coercion).
    pub fn provide_contract(&self) -> String {
        let params: Vec<&'static str> = self
            .params
            .iter()
            .map(|m| match m {
                ArgMarshal::Scalar(s) | ArgMarshal::ScalarTypedef { scalar: s, .. } => s.contract(),
                ArgMarshal::SwiftString => "string?",
                // Racket sees a value handle or an objc reference as an opaque
                // cpointer (the binding passes it straight to the trampoline).
                ArgMarshal::BoxedHandle { .. } | ArgMarshal::ObjectRef { .. } => "cpointer?",
            })
            .collect();
        let ret = ret_contract(&self.ret);
        if params.is_empty() {
            format!("[{} (c-> {ret})]", self.binding_name)
        } else {
            format!("[{} (c-> {} {ret})]", self.binding_name, params.join(" "))
        }
    }

    /// Whether the binding needs a coercion wrapper (string in/out or throws);
    /// a pure-scalar / handle-return binding is the bare `get-ffi-obj`.
    fn needs_wrapper(&self) -> bool {
        self.throwing
            || matches!(self.ret, RetMarshal::SwiftString)
            || self.params.contains(&ArgMarshal::SwiftString)
    }

    /// Render the `(define <name> …)` racket binding against `_aw-lib`.
    pub fn render_racket(&self) -> String {
        let arrow = self.ffi_arrow();
        if !self.needs_wrapper() {
            // Bare foreign object — scalars/handle pass straight through.
            return format!(
                "(define {} (get-ffi-obj '{} _aw-lib {arrow}))",
                self.binding_name, self.entry
            );
        }

        let arg_names: Vec<String> = (0..self.params.len()).map(|i| format!("a{i}")).collect();
        // Each positional argument, with `String` args bridged to an NSString id.
        let call_args: Vec<String> = self
            .params
            .iter()
            .zip(&arg_names)
            .map(|(m, a)| match m {
                ArgMarshal::SwiftString => format!("(aw-string-arg {a})"),
                // Scalars and scalar-backed typedefs pass straight through (racket
                // hands a number; the `@_cdecl` re-wraps it to the typedef). A boxed
                // value handle is already a cpointer — pass it straight through too.
                ArgMarshal::Scalar(_)
                | ArgMarshal::ScalarTypedef { .. }
                | ArgMarshal::BoxedHandle { .. }
                | ArgMarshal::ObjectRef { .. } => a.clone(),
            })
            .collect();
        // Success-path result coercion.
        let ret_coerce = match self.ret {
            RetMarshal::SwiftString => "aw-string-result",
            _ => "values",
        };
        let lambda_params = arg_names.join(" ");

        if self.throwing {
            // `aw-call/error` allocates the NSError** cell, calls, raises on error,
            // else coerces the success result.
            format!(
                "(define {name}\n  \
                 (let ([raw (get-ffi-obj '{entry} _aw-lib {arrow})])\n    \
                 (lambda ({lambda_params})\n      \
                 (aw-call/error raw {ret_coerce}{maybe_space}{args}))))",
                name = self.binding_name,
                entry = self.entry,
                args = call_args.join(" "),
                maybe_space = if call_args.is_empty() { "" } else { " " },
            )
        } else {
            // Non-throwing string coercion: bridge args in, coerce result out.
            let body = match self.ret {
                RetMarshal::SwiftString => {
                    format!("(aw-string-result (raw {}))", call_args.join(" "))
                }
                _ => format!("(raw {})", call_args.join(" ")),
            };
            format!(
                "(define {name}\n  \
                 (let ([raw (get-ffi-obj '{entry} _aw-lib {arrow})])\n    \
                 (lambda ({lambda_params})\n      {body})))",
                name = self.binding_name,
                entry = self.entry,
            )
        }
    }
}

impl ConstTrampoline {
    /// The racket-visible `[name <contract>]` provide/contract line.
    pub fn provide_contract(&self) -> String {
        format!("[{} {}]", self.swift_name, ret_contract(&self.ret))
    }

    /// Render the `(define <name> …)` racket binding — a zero-arg reader of the
    /// Swift global, evaluated once at load (mirroring the `get-ffi-obj` constants
    /// it replaces), with `String` results coerced.
    pub fn render_racket(&self) -> String {
        let arrow = format!("(_fun -> {})", ret_ffi(&self.ret));
        match self.ret {
            RetMarshal::SwiftString => format!(
                "(define {name} (aw-string-result ((get-ffi-obj '{entry} _aw-lib {arrow}))))",
                name = self.swift_name,
                entry = self.entry,
            ),
            _ => format!(
                "(define {name} ((get-ffi-obj '{entry} _aw-lib {arrow})))",
                name = self.swift_name,
                entry = self.entry,
            ),
        }
    }
}

// ===========================================================================
// Receiver-handle method trampolines (the Swift-native method frontier)
// ===========================================================================
//
// A method trampoline generalises [`FnTrampoline`]'s call-by-name from free
// functions to methods: the `@_cdecl` takes an **opaque receiver handle** as its
// first C param, reconstructs the receiver, and calls `receiver.method(labels:)`
// by name — letting swiftc own ABI correctness exactly as the free-function path
// does. An [`InitTrampoline`] is the population-B *root producer*: it calls
// `Owner(labels:)` and boxes a handle of the owning type.
//
// Receiver marshalling ([`SelfMarshal`]) is by the **owner's kind**, not the A/B
// split: a **class** owner (objc-exposed *or* Swift-native — both reference types)
// is `Unmanaged<Owner>.fromOpaque(recv).takeUnretainedValue()`; a **value struct**
// owner is `awRacketUnbox(recv, as: Owner.self)`, with mutating write-back (D3).
// The A/B split (owner `objc_exposed`) only governs whether an init *producer* is
// needed — orthogonal to how the receiver is unboxed.

/// How a method's receiver (`self`) is reconstructed from its opaque handle.
#[derive(Debug, Clone, PartialEq, Eq)]
enum SelfMarshal {
    /// A **class** owner (objc-exposed instance the target already holds as `id`, or
    /// a Swift-native class boxed via `Unmanaged.passRetained`). Both are reference
    /// types reconstructed identically: `Unmanaged<M.O>.fromOpaque(recv).takeUnretainedValue()`.
    ClassRef,
    /// A **value struct** owner (population B): the receiver is an `AwValueBox`
    /// handle. `mutating` selects the write-back path (`var v = box.value as! T;
    /// v.method(); box.value = v`) so the racket side's handle reflects the mutation
    /// (D3); non-mutating just unboxes a copy.
    ValueBox { mutating: bool },
}

/// A Swift-native instance method the racket target trampolines: a `@_cdecl` taking
/// an opaque receiver handle + the marshalled args, calling `receiver.name(labels:)`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MethodTrampoline {
    pub module: String,
    /// The owning type's **ObjC runtime name** — the entry-symbol stem and the racket
    /// dispatch identity (`module.owner` at the binding call site / generic name). Equals
    /// `swift_owner` unless the Swift overlay renamed the class.
    pub owner: String,
    /// The owning type's **Swift name** — what the `@_cdecl` body spells as the receiver
    /// type (`Unmanaged<module.swift_owner>`), since the obsoleted ObjC runtime name does
    /// not compile as a Swift type (`NSScanner` → `Scanner`). Set to `owner` by
    /// `classify_method`; remapped from the class's `swift_name` in [`collect_trampolines`].
    pub swift_owner: String,
    /// Base method name (the selector up to `(`), used in the by-name call.
    pub swift_name: String,
    /// Content-addressed C entry symbol (`aw_racket_swift_m_<Fw>_<Owner>_<name>[_<hash>]`).
    pub entry: String,
    recv: SelfMarshal,
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    ret: RetMarshal,
    /// The return type is `Optional` — the marshalling must map `nil` to NULL/`#f`
    /// (String/handle returns); a nullable *scalar* return is deferred upstream.
    ret_nullable: bool,
    throwing: bool,
    /// The method is `async` (D5/R4): instead of a synchronous return, the `@_cdecl`
    /// takes a trailing ctx + C completion callback and drives `awRacketAsyncDispatch`
    /// (the non-blocking, main-thread-delivery bridge). The racket binding wraps it
    /// with `aw-async-call` (the callback form — no blocking await, per R4).
    is_async: bool,
    availability: Option<String>,
}

/// An initializer producer — the population-B root handle producer (D2). Calls
/// `Owner(labels:)` and returns a boxed handle of the **owning type** (a value box
/// for a struct owner, an `Unmanaged.passRetained` instance for a class owner).
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
    /// Box a class instance via `Unmanaged.passRetained` (reference identity) vs a
    /// value via `awRacketBox` — picked from the owner's kind, not the lossy IR
    /// return type (R2: `init(integer:)` reports `NSIndexSet`, must box `IndexSet`).
    owner_is_class: bool,
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    throwing: bool,
    availability: Option<String>,
}

/// The disposition of a Swift-native method: an instance-method trampoline, an
/// initializer producer, or a recorded deferral. The owner-iteration caller filters
/// on `swift_fn.is_some()` (⇔ `objc_exposed == false`); both the global pass and the
/// `emit_class` routing call this so the emitted binding and the `@_cdecl` agree.
pub enum MethodDisposition {
    Method(MethodTrampoline),
    Init(InitTrampoline),
    Deferred(DeferReason),
}

/// The base method name = the selector up to the first `(` (`update(with:)` →
/// `update`, `init(integer:)` → `init`, `contains(_:)` → `contains`).
fn method_base_name(selector: &str) -> &str {
    selector.split('(').next().unwrap_or(selector)
}

/// Is `name` a callable Swift identifier (so `receiver.name(args)` parses)? Filters
/// out operators (`==`, `<`) and other non-identifier selectors.
fn is_identifier(name: &str) -> bool {
    let mut chars = name.chars();
    matches!(chars.next(), Some(c) if c.is_ascii_alphabetic() || c == '_')
        && name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_')
}

/// The curated suppression table (spec §8.8): decls swiftc rejects for a cause the
/// lossy IR cannot mechanically predict — `@MainActor`/actor isolation (which
/// `swift-api-digester` does not emit at all — `swift_attributes` carries an opaque
/// `Custom`, not `MainActor`), and a scatter of per-decl semantic failures
/// (unspellable nested owners, `@const` params, un-inferrable generics, noncopyable
/// receivers, immutable-`inout` receivers, `internal`/`private` overloads, version-
/// gated decls with no `introduced:` provenance, arg-shape divergence).
///
/// Keyed by the **content-addressed entry name** (the same string
/// [`method_entry_name`]/[`init_entry_name`] compute and the one swiftc names in the
/// build error), so the suppression is exact per overload and reproduces from a cold
/// collect (the entry name is a pure function of the IR). Each entry is counted under
/// its reason ("defer nothing, but be honest"). This is the method analogue of the
/// libobjc curated bridge (Option B): a hand-verified list earns its place where
/// mechanical detection has no signal to act on. The full-residual `swift build` is
/// the regression guard — a stale entry here re-surfaces as a compile error.
const KNOWN_UNBINDABLE: &[(&str, DeferReason)] = &[
    ("aw_racket_swift_init_AppIntents_IntentCollectionSize_66a66a84", DeferReason::CompileTimeConstantParam),
    ("aw_racket_swift_init_AppIntents_IntentCollectionSize_8398302c", DeferReason::CompileTimeConstantParam),
    ("aw_racket_swift_init_AuthenticationServices_ASCredentialDataManager", DeferReason::UnknownAvailability),
    ("aw_racket_swift_init_CloudKit_ID_180762ef", DeferReason::ModuleMemberMissing),
    ("aw_racket_swift_init_CloudKit_ID_c6665c26", DeferReason::ModuleMemberMissing),
    ("aw_racket_swift_init_IdentityDocumentServicesUI_IdentityDocumentWebPresentmentController", DeferReason::ActorIsolated),
    ("aw_racket_swift_init_ImagePlayground_ImageCreator", DeferReason::ActorIsolated),
    ("aw_racket_swift_init_ImmersiveMediaSupport_ImmersiveMediaRemotePreviewReceiver", DeferReason::ActorIsolated),
    ("aw_racket_swift_init_MediaExtension_Boolean", DeferReason::ModuleMemberMissing),
    ("aw_racket_swift_init_MediaExtension_FloatingPoint", DeferReason::ModuleMemberMissing),
    ("aw_racket_swift_init_MediaExtension_Integer", DeferReason::ModuleMemberMissing),
    ("aw_racket_swift_init_RealityFoundation_RealityRenderer", DeferReason::ActorIsolated),
    ("aw_racket_swift_init_StoreKit_AdvancedCommerceProduct", DeferReason::ActorIsolated),
    ("aw_racket_swift_init_SwiftUICore_PropertyList", DeferReason::ModuleMemberMissing),
    ("aw_racket_swift_init_SwiftUICore_RectangleCornerRadii_dfe2fe2f", DeferReason::ArgumentShapeMismatch),
    ("aw_racket_swift_init_Translation_LanguageAvailability_960d49c3", DeferReason::UnresolvedMemberType),
    ("aw_racket_swift_init_WebKit_URLScheme", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_AuthenticationServices_ASCredentialDataManager_reportUnusedPasswordCredential", DeferReason::UnknownAvailability),
    ("aw_racket_swift_m_CompositorServices_Frame_predictTiming", DeferReason::GenericInferenceFailure),
    ("aw_racket_swift_m_CompositorServices_Frame_queryDrawables", DeferReason::GenericInferenceFailure),
    ("aw_racket_swift_m_CoreHID_HIDDeviceClient_seizeDevice", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_CoreVideo_CVMutablePixelBuffer_fillExtendedPixels", DeferReason::NoncopyableReceiver),
    ("aw_racket_swift_m_ImmersiveMediaSupport_VenueDescriptor_cameraViewModel", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_ImmersiveMediaSupport_VenueDescriptor_removeCamera", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_ImmersiveMediaSupport_VenueDescriptor_save", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_RealityFoundation_AudioGeneratorController_play", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_RealityFoundation_AudioGeneratorController_stop", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_RealityFoundation_EntityGeometricPins_makeIterator", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_RealityFoundation_EntityGeometricPins_remove", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_RealityFoundation_LowLevelTexture_read", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_RealityFoundation_MeshInstanceCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_racket_swift_m_RealityFoundation_MeshModelCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_racket_swift_m_RealityFoundation_MeshPartCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_racket_swift_m_RealityFoundation_MeshSkeletonCollection_formIndex", DeferReason::ImmutableInoutArgument),
    ("aw_racket_swift_m_RealityFoundation_RealityRenderer_update", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_SwiftUICore_EdgeInsets_round_61f6b07c", DeferReason::InaccessibleDecl),
    ("aw_racket_swift_m_SwiftUICore_EdgeInsets_rounded_c7dec5cb", DeferReason::InaccessibleDecl),
    ("aw_racket_swift_m_Translation_TranslationSession_cancel", DeferReason::UnresolvedMemberType),
    ("aw_racket_swift_m_Translation_TranslationSession_prepareTranslation", DeferReason::UnresolvedMemberType),
    ("aw_racket_swift_m_Translation_TranslationSession_translate_770bd52c", DeferReason::UnresolvedMemberType),
    ("aw_racket_swift_m_VisionKit_ImageAnalysisOverlayView_beginSubjectAnalysisIfNecessary", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_VisionKit_ImageAnalysisOverlayView_resetSelection", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_VisionKit_ImageAnalysisOverlayView_setContentsRectNeedsUpdate", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_VisionKit_ImageAnalysisOverlayView_setSupplementaryInterfaceHidden", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_WebKit_WebPage_load_4808a66d", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_WebKit_WebPage_load_60456c20", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_WebKit_WebPage_load_6dde058d", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_WebKit_WebPage_load_77ec487a", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_WebKit_WebPage_reload", DeferReason::ActorIsolated),
    ("aw_racket_swift_m_WebKit_WebPage_stopLoading", DeferReason::ActorIsolated),
    ("aw_racket_swift_m__StoreKit_SwiftUI_RequestReviewAction_callAsFunction", DeferReason::ActorIsolated),
];

/// Look up a method/init in [`KNOWN_UNBINDABLE`] by the content-addressed entry name
/// it would emit (init vs instance-method prefix), the same string swiftc names in a
/// build error.
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

/// Classify one Swift-native method on a type. `owner_is_class` is true when the
/// owner is in `Framework.classes` (a reference type → `Unmanaged` receiver path),
/// false for a `Framework.structs` value type (→ `AwValueBox` path). `siblings` is
/// the owner's full method list (overload disambiguation); `value_structs` is the
/// owning framework's [`value_struct_names`] (the param-unbox gate).
pub fn classify_method(
    module: &str,
    owner: &str,
    owner_is_class: bool,
    method: &Method,
    siblings: &[Method],
    // Reserved: value-struct **method** params are deferred in the sync structural
    // leaf (the `Framework.structs` set carries *nested* type names like
    // `Data.Base64EncodingOptions` that are not bare-spellable in an `awRacketUnbox`
    // cast — a qualified-name follow-up). Object params are the async leaf's R1.
    _value_structs: &HashSet<&str>,
    // The owning type's `introduced:` macOS version (from its IR provenance), folded
    // into the `@available` gate: a method whose own provenance is absent or lower
    // than its type's would otherwise call an unavailable type (spec §8.8).
    owner_introduced: Option<&str>,
) -> MethodDisposition {
    // Curated suppression: a small set of decls that swiftc rejects for a reason the
    // lossy IR cannot predict (actor isolation — absent from the digester entirely —
    // and assorted per-decl semantic failures). Keyed by the content-addressed entry
    // name, each carries its counted reason (spec §8.8, "defer nothing, but be
    // honest"). Consulted first so the global pass and the emitter agree.
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
    // Static/class methods have no receiver instance — out of the sync structural
    // leaf's instance-method perimeter, recorded + counted.
    if method.class_method && !method.init_method {
        return MethodDisposition::Deferred(DeferReason::StaticMethod);
    }
    if method.variadic {
        return MethodDisposition::Deferred(DeferReason::VariadicMethod);
    }

    // Args reuse the free-function scalar/string taxonomy; value-struct + object
    // params defer (empty struct set, per `_value_structs`). The first non-bindable
    // param's reason wins.
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
        // Object-ref params (R1) bridge to a Swift value twin (`NSData` → `Data`),
        // which is right for a *method* call but wrong for a bridging *constructor*
        // (`Data(referencing: NSData)` genuinely wants the reference — the same objc
        // param type means different things at different call sites, and the lossy IR
        // cannot tell them apart). Init object params were deferred pre-R1, so this
        // is a no-regression carve-out, not new suppression.
        if params
            .iter()
            .any(|m| matches!(m, ArgMarshal::ObjectRef { .. }))
        {
            return MethodDisposition::Deferred(DeferReason::NonBridgedStructParam);
        }
        return MethodDisposition::Init(InitTrampoline {
            module: module.to_string(),
            owner: owner.to_string(),
            // Defaults to the runtime `owner`; `collect_trampolines` remaps a
            // Swift-overlay-renamed class to its `swift_name`.
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

    // The return type of an unambiguous method call needs no `as <Type>` pin (unlike
    // a cross-module-overloaded free function — the `nan` case), and the IR's lossy
    // normalization often yields an unspellable/inaccessible name (`Iterator`,
    // `ProtocolComposition`, a nested type). So a method's non-scalar return always
    // boxes **unnamed** (`Handle(None)`); a `CGFloat`-style scalar typedef keeps its
    // by-value conversion. A nullable scalar can't carry `nil` across a C scalar.
    let ret_nullable = method.return_type.nullable;
    let ret = match classify_return(&method.return_type) {
        RetMarshal::Handle(_) => RetMarshal::Handle(None),
        RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } if ret_nullable => {
            return MethodDisposition::Deferred(DeferReason::NullableScalarReturn);
        }
        other => other,
    };

    // Write-back only applies to value receivers; a class receiver is a reference,
    // so a `mutating` class method (rare) needs no special handling.
    let mutating = !owner_is_class && info.and_then(|i| i.self_kind.as_deref()) == Some("Mutating");

    // Async (D5/R4): the method drives the completion-callback bridge instead of a
    // synchronous return. Two sub-cases cannot ride it and defer-with-count: a
    // `mutating` value receiver (the write-back is ill-defined across the async hop)
    // and a scalar return (`AwAsyncOutcome` carries a pointer payload, not a scalar).
    let is_async = info.is_some_and(|i| i.is_async);
    if is_async {
        if mutating {
            return MethodDisposition::Deferred(DeferReason::AsyncMutatingReceiver);
        }
        if matches!(
            ret,
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. }
        ) {
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
        // Defaults to the runtime `owner`; `collect_trampolines` remaps a
        // Swift-overlay-renamed class to its `swift_name`.
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

/// FNV-1a hash of a method's selector + param/return ABI shape — appended to the
/// entry name when `(module, owner, base)` is overloaded (same precedent as
/// [`overload_hash`]).
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

/// True when a Swift-native instance method's base name is overloaded among the
/// owner's Swift-native instance methods (the only case needing a hash).
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

// --- Method/init Swift codegen ---

/// The `@available` line + `@_cdecl` + `public func <entry>(<decl>)<-> ret> {`
/// header shared by the method and init emitters.
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

/// The C return type + success marshaller for a **method** return. Differs from the
/// free-function [`return_shape`]: an integer scalar is `numericCast`-converted (IR
/// width collapse), and a nullable String/handle maps `nil` → NULL/`#f`. A method's
/// handle return is always `Handle(None)` (unambiguous call ⇒ no `as` pin), and a
/// nullable scalar/typedef return is deferred upstream so never reaches here.
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
        RetMarshal::Handle(_) if nullable => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| format!("({c}).map {{ awRacketBox($0) }} ?? nil")),
        ),
        RetMarshal::Handle(_) => (
            "UnsafeMutableRawPointer?".to_string(),
            Box::new(|c: &str| format!("awRacketBox({c})")),
        ),
    }
}

/// The expression marshalling an async method's success result (`awR`) to the
/// `AwAsyncOutcome.value` pointer payload, computed on the cooperative thread
/// inside the operation closure. `Void` is handled by the caller (no `awR`);
/// scalar returns never reach here (deferred `AsyncScalarReturn` upstream). Mirrors
/// [`method_return_shape`]'s pointer arms, but always lands in `AwAsyncOutcome`.
fn async_outcome_value(ret: &RetMarshal, nullable: bool) -> String {
    match ret {
        RetMarshal::SwiftString if nullable => {
            "(awR as String?).map { Unmanaged.passRetained($0 as NSString).toOpaque() } ?? nil"
                .to_string()
        }
        RetMarshal::SwiftString => "Unmanaged.passRetained(awR as NSString).toOpaque()".to_string(),
        RetMarshal::Handle(_) if nullable => "awR.map { awRacketBox($0) } ?? nil".to_string(),
        RetMarshal::Handle(_) => "awRacketBox(awR)".to_string(),
        // Void is handled by the caller; scalars are deferred upstream.
        RetMarshal::Void | RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => {
            "nil".to_string()
        }
    }
}

/// Emit one `async` method trampoline (D5/R4): the `@_cdecl` takes a trailing
/// racket completion context (`awCtx`) + C callback (`awCb`) and drives
/// `awRacketAsyncDispatch` — the operation closure unboxes the receiver, `await`s,
/// and marshals to `AwAsyncOutcome` **on the cooperative thread**; the completion
/// closure delivers it through `awCb` **on the main thread** (the SIGILL-safe hop).
/// Errors ride `AwAsyncOutcome.error`, so there is no `NSError**` out-param.
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
    // Args reconstruct to Sendable values here, on the calling thread; the operation
    // closure captures those values (URL/String/scalars are Sendable + copy), so no
    // racket-owned handle dangles while the Task runs.
    s.push_str(&arg_prelude);

    let owner = format!("{}.{}", swift_import_module(&t.module), t.swift_owner);
    // The receiver pointer is captured into the `@Sendable` operation closure and
    // the receiver reconstructed *inside* (it lives only on the cooperative thread —
    // capturing the receiver object directly would fail Swift 6 Sendable checking for
    // a non-Sendable class). `UnsafeMutableRawPointer` is deliberately not Sendable,
    // so `nonisolated(unsafe)` carries the bare pointer across the hop: the racket
    // caller's lifetime contract (keep the receiver alive until completion) makes the
    // capture sound, which is exactly what `nonisolated(unsafe)` asserts.
    s.push_str("  nonisolated(unsafe) let awRecvUnsafe = awRecv\n");
    let recv_line = match &t.recv {
        SelfMarshal::ClassRef => format!(
            "    let awSelf = Unmanaged<{owner}>.fromOpaque(awRecvUnsafe!).takeUnretainedValue()\n"
        ),
        // Mutating-async is deferred upstream, so a value receiver is non-mutating:
        // unbox a copy for the call.
        SelfMarshal::ValueBox { .. } => {
            format!("    let awSelf = awRacketUnbox(awRecvUnsafe!, as: {owner}.self)\n")
        }
    };
    let call = format!(
        "awSelf.{}({})",
        t.swift_name,
        arg_values(&t.params, &t.labels, true).join(", ")
    );
    let value_expr = async_outcome_value(&t.ret, t.ret_nullable);

    s.push_str("  awRacketAsyncDispatch({ () async -> AwAsyncOutcome in\n");
    s.push_str(&recv_line);
    match (t.throwing, &t.ret) {
        (true, RetMarshal::Void) => s.push_str(&format!(
            "    do {{\n      try await {call}\n      return AwAsyncOutcome()\n    }} catch {{\n      return AwAsyncOutcome.failure(error)\n    }}\n"
        )),
        (true, _) => s.push_str(&format!(
            "    do {{\n      let awR = try await {call}\n      return AwAsyncOutcome(value: {value_expr})\n    }} catch {{\n      return AwAsyncOutcome.failure(error)\n    }}\n"
        )),
        (false, RetMarshal::Void) => {
            s.push_str(&format!("    await {call}\n    return AwAsyncOutcome()\n"))
        }
        (false, _) => s.push_str(&format!(
            "    let awR = await {call}\n    return AwAsyncOutcome(value: {value_expr})\n"
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

    // Signature: receiver handle first, then args, then the throwing out-param.
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

    // Receiver reconstruction prelude, and (for a mutating value receiver) the
    // write-back line that must run after the call.
    let owner = format!("{}.{}", swift_import_module(&t.module), t.swift_owner);
    let (recv_prelude, writeback) = match &t.recv {
        SelfMarshal::ClassRef => (
            format!(
                "  let awSelf = Unmanaged<{owner}>.fromOpaque(awRecv!).takeUnretainedValue()\n"
            ),
            None,
        ),
        SelfMarshal::ValueBox { mutating: false } => (
            format!("  let awSelf = awRacketUnbox(awRecv!, as: {owner}.self)\n"),
            None,
        ),
        SelfMarshal::ValueBox { mutating: true } => (
            format!(
                "  let awBox = Unmanaged<AwValueBox>.fromOpaque(awRecv!).takeUnretainedValue()\n  \
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
        // The write-back, when present, runs inside the try-closure on success so a
        // throw leaves the receiver untouched. A pointer-rep return is already
        // `UnsafeMutableRawPointer?` when nullable; otherwise the non-null marshaller
        // produces a non-optional pointer wrapped with `Optional(...)` to unify with
        // the `nil` fallback.
        let wb = writeback.as_deref().unwrap_or("");
        match &t.ret {
            RetMarshal::Void => {
                s.push_str(&format!(
                    "  awRacketTry(awErrOut, ()) {{ try {call}\n  {wb}}}\n"
                ));
            }
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => {
                let m = marshal("awR");
                s.push_str(&format!(
                    "  return awRacketTry(awErrOut, {fb}) {{ let awR = try {call}\n  {wb}  return {m} }}\n",
                    fb = throw_fallback(&t.ret),
                ));
            }
            RetMarshal::SwiftString | RetMarshal::Handle(_) => {
                let m = marshal("awR");
                let wrapped = if t.ret_nullable {
                    m
                } else {
                    format!("Optional({m})")
                };
                s.push_str(&format!(
                    "  return awRacketTry(awErrOut, nil) {{ let awR = try {call}\n  {wb}  return {wrapped} }}\n"
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
    // initializer (`Decimal(Int)` vs `Decimal(UInt)`) is selected *by* the param type,
    // so a width-agnostic cast would make the constructor call ambiguous.
    let ctor = format!(
        "{owner}({})",
        arg_values(&t.params, &t.labels, false).join(", ")
    );
    // Box the owning type (R2): a class instance keeps reference identity via
    // `Unmanaged.passRetained`; a value rides the uniform `awRacketBox`.
    let box_of = |expr: &str| -> String {
        if t.owner_is_class {
            format!("Unmanaged.passRetained({expr}).toOpaque()")
        } else {
            format!("awRacketBox({expr})")
        }
    };
    if t.throwing {
        s.push_str(&format!(
            "  return awRacketTry(awErrOut, nil) {{ Optional({}) }}\n",
            box_of(&format!("try {ctor}"))
        ));
    } else {
        s.push_str(&format!("  return {}\n", box_of(&ctor)));
    }
    s.push_str("}\n");
}

// --- Method racket binding (consumed by emit_class routing) ---

impl MethodTrampoline {
    /// The ffi `_fun` arrow for the C entry: receiver pointer first, then the arg
    /// reps, then the trailing `NSError**` when throwing.
    pub fn ffi_arrow(&self) -> String {
        let mut parts: Vec<&'static str> = vec!["_pointer"]; // receiver handle
        for m in &self.params {
            parts.push(match m {
                ArgMarshal::Scalar(s) | ArgMarshal::ScalarTypedef { scalar: s, .. } => s.ffi(),
                ArgMarshal::SwiftString
                | ArgMarshal::BoxedHandle { .. }
                | ArgMarshal::ObjectRef { .. } => "_pointer",
            });
        }
        // Async (D5/R4): no synchronous return + no NSError** out-param — instead a
        // trailing completion context (`_intptr`) and the stable C callback function
        // pointer (`_fpointer`, the GC-stable `aw-async-call` shares; not a
        // `_cprocedure` param, which would per-call wrap a soon-GC'd callback). The
        // trampoline itself returns void.
        if self.is_async {
            parts.push("_intptr");
            parts.push("_fpointer");
            return format!("(_fun {} {AW_ARROW} _void)", parts.join(" "));
        }
        if self.throwing {
            parts.push("_pointer");
        }
        format!(
            "(_fun {} {AW_ARROW} {})",
            parts.join(" "),
            ret_ffi(&self.ret)
        )
    }

    /// Render the full `(define <fn-name> …)` racket binding against `_aw-lib`,
    /// given the racket-visible method name + kebab param names `emit_class`
    /// computes. The receiver (`self`) is coerced to its raw handle pointer and
    /// passed first; `String` args bridge in, the result coerces out.
    pub fn render_racket_method(&self, fn_name: &str, param_names: &[String]) -> String {
        let arrow = self.ffi_arrow();
        if self.is_async {
            return self.render_async_racket_method(fn_name, param_names, &arrow);
        }
        let call_args: Vec<String> = self
            .params
            .iter()
            .zip(param_names)
            .map(|(m, p)| match m {
                ArgMarshal::SwiftString => format!("(aw-string-arg {p})"),
                _ => p.clone(),
            })
            .collect();
        let args_str = if call_args.is_empty() {
            String::new()
        } else {
            format!(" {}", call_args.join(" "))
        };
        let lambda_params = if param_names.is_empty() {
            "self".to_string()
        } else {
            format!("self {}", param_names.join(" "))
        };
        let ret_coerce = matches!(self.ret, RetMarshal::SwiftString);
        if self.throwing {
            // aw-call/error allocates the error cell, raises on error, else coerces.
            let coerce = if ret_coerce {
                "aw-string-result"
            } else {
                "values"
            };
            format!(
                "(define {fn_name}\n  (let ([raw (get-ffi-obj '{entry} _aw-lib {arrow})])\n    \
                 (lambda ({lambda_params})\n      (aw-call/error raw {coerce} (coerce-arg self){args_str}))))",
                entry = self.entry,
            )
        } else {
            let body = if ret_coerce {
                format!("(aw-string-result (raw (coerce-arg self){args_str}))")
            } else {
                format!("(raw (coerce-arg self){args_str})")
            };
            format!(
                "(define {fn_name}\n  (let ([raw (get-ffi-obj '{entry} _aw-lib {arrow})])\n    \
                 (lambda ({lambda_params})\n      {body})))",
                entry = self.entry,
            )
        }
    }

    /// Render the callback-form racket binding for an `async` method (R4). The
    /// generated procedure takes a trailing `complete` continuation; it threads the
    /// receiver + args into the kicker (which `aw-async-call` invokes with a fresh
    /// ctx id + the shared C callback), and `complete` is delivered the coerced
    /// result (or an error) on the main thread when the operation finishes. No
    /// blocking await — the racket app keeps servicing its run loop.
    fn render_async_racket_method(
        &self,
        fn_name: &str,
        param_names: &[String],
        arrow: &str,
    ) -> String {
        let call_args: Vec<String> = self
            .params
            .iter()
            .zip(param_names)
            .map(|(m, p)| match m {
                ArgMarshal::SwiftString => format!("(aw-string-arg {p})"),
                _ => p.clone(),
            })
            .collect();
        let args_str = if call_args.is_empty() {
            String::new()
        } else {
            format!(" {}", call_args.join(" "))
        };
        let lambda_params = if param_names.is_empty() {
            "self complete".to_string()
        } else {
            format!("self {} complete", param_names.join(" "))
        };
        // A String result coerces to a racket string; everything else (boxed handle,
        // void) passes the raw value through to `complete`.
        let coerce = if matches!(self.ret, RetMarshal::SwiftString) {
            "aw-string-result"
        } else {
            "values"
        };
        format!(
            "(define {fn_name}\n  (let ([raw (get-ffi-obj '{entry} _aw-lib {arrow})])\n    \
             (lambda ({lambda_params})\n      (aw-async-call\n        \
             (lambda (id cb) (raw (coerce-arg self){args_str} id cb))\n        {coerce}\n        complete))))",
            entry = self.entry,
        )
    }

    /// Whether this method is `async` (D5/R4) — the class file requires
    /// `async-bridge.rkt` (for `aw-async-call`) iff any of its methods is async.
    pub fn is_async(&self) -> bool {
        self.is_async
    }
}

impl InitTrampoline {
    /// The ffi `_fun` arrow for an initializer producer: the marshalled args, the
    /// trailing `NSError**` out-buffer when throwing, and an opaque handle return
    /// (the boxed owner — a value box or a retained class instance).
    pub fn ffi_arrow(&self) -> String {
        let mut parts: Vec<&'static str> = Vec::with_capacity(self.params.len() + 1);
        for m in &self.params {
            parts.push(match m {
                ArgMarshal::Scalar(s) | ArgMarshal::ScalarTypedef { scalar: s, .. } => s.ffi(),
                ArgMarshal::SwiftString
                | ArgMarshal::BoxedHandle { .. }
                | ArgMarshal::ObjectRef { .. } => "_pointer",
            });
        }
        if self.throwing {
            parts.push("_pointer");
        }
        if parts.is_empty() {
            format!("(_fun {AW_ARROW} _pointer)")
        } else {
            format!("(_fun {} {AW_ARROW} _pointer)", parts.join(" "))
        }
    }

    /// Render the `(define <name> …)` racket binding for an initializer producer
    /// against `_aw-lib`. The binding is a constructor: it takes the init's args,
    /// calls the `@_cdecl`, and returns the boxed owner handle (a raw `cpointer`).
    /// A throwing init routes through `aw-call/error` (allocates the `NSError**`
    /// cell, raises on error). The result is always an opaque handle — never
    /// String-coerced — so the value passes straight through.
    pub fn render_racket_init(&self, fn_name: &str, param_names: &[String]) -> String {
        let arrow = self.ffi_arrow();
        let call_args: Vec<String> = self
            .params
            .iter()
            .zip(param_names)
            .map(|(m, p)| match m {
                ArgMarshal::SwiftString => format!("(aw-string-arg {p})"),
                _ => p.clone(),
            })
            .collect();
        let args_str = if call_args.is_empty() {
            String::new()
        } else {
            format!(" {}", call_args.join(" "))
        };
        let lambda_params = param_names.join(" ");
        if self.throwing {
            format!(
                "(define {fn_name}\n  (let ([raw (get-ffi-obj '{entry} _aw-lib {arrow})])\n    \
                 (lambda ({lambda_params})\n      (aw-call/error raw values{args_str}))))",
                entry = self.entry,
            )
        } else {
            format!(
                "(define {fn_name}\n  (let ([raw (get-ffi-obj '{entry} _aw-lib {arrow})])\n    \
                 (lambda ({lambda_params})\n      (raw{args_str}))))",
                entry = self.entry,
            )
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Param, SwiftFnInfo};

    /// The empty value-struct set — the default for tests that exercise scalar /
    /// string / reference-param paths (no framework-owned value struct in play).
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
    fn swift_class(name: &str, module: &str) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: name.into(),
                framework: Some(module.into()),
                params: vec![],
            },
        }
    }
    fn param(name: &str, t: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type: t,
        }
    }
    fn swift_fn(name: &str, params: Vec<Param>, ret: TypeRef, info: SwiftFnInfo) -> Function {
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

    fn plain(name: &str, params: Vec<Param>, ret: TypeRef) -> Function {
        swift_fn(name, params, ret, SwiftFnInfo::default())
    }

    #[test]
    fn scalar_function_trampolines_directly() {
        let f = plain("compute", vec![param("x", prim("double"))], prim("double"));
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("expected trampoline");
        };
        assert_eq!(t.entry, "aw_racket_swift_TestKit_compute");
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(
            s.contains("@_cdecl(\"aw_racket_swift_TestKit_compute\")"),
            "{s}"
        );
        assert!(
            s.contains("public func aw_racket_swift_TestKit_compute(_ a0: Double) -> Double"),
            "{s}"
        );
        assert!(s.contains("return TestKit.compute(x: a0)"), "{s}");
        // ffi arrow + racket binding (no coercion → bare get-ffi-obj).
        assert_eq!(t.ffi_arrow(), "(_fun _double -> _double)");
        assert_eq!(
            t.render_racket(),
            "(define compute (get-ffi-obj 'aw_racket_swift_TestKit_compute _aw-lib (_fun _double -> _double)))"
        );
        assert_eq!(t.provide_contract(), "[compute (c-> real? real?)]");
    }

    #[test]
    fn string_function_bridges_both_ways() {
        let f = plain("greeting", vec![param("name", nsstring())], nsstring());
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(
            s.contains("_ a0: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?"),
            "{s}"
        );
        assert!(
            s.contains(
                "let s0 = Unmanaged<NSString>.fromOpaque(a0!).takeUnretainedValue() as String"
            ),
            "{s}"
        );
        assert!(
            s.contains("return Unmanaged.passRetained((TestKit.greeting(name: s0)) as NSString).toOpaque()"),
            "{s}"
        );
        assert_eq!(t.ffi_arrow(), "(_fun _pointer -> _pointer)");
        // Racket side bridges the string arg in and coerces the string result out.
        let rkt = t.render_racket();
        assert!(
            rkt.contains("(aw-string-result (raw (aw-string-arg a0)))"),
            "{rkt}"
        );
        assert_eq!(
            t.provide_contract(),
            "[greeting (c-> string? (or/c string? #f))]"
        );
    }

    #[test]
    fn nonbridged_struct_return_is_boxed_handle() {
        // (Double, Double) -> SomeSwiftStruct  → scalar params, boxed return.
        let f = plain(
            "makePoint",
            vec![param("x", prim("double")), param("y", prim("double"))],
            swift_class("GeoPoint", "TestKit"),
        );
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("-> UnsafeMutableRawPointer?"), "{s}");
        assert!(
            s.contains("return awRacketBox((TestKit.makePoint(x: a0, y: a1)) as GeoPoint)"),
            "{s}"
        );
    }

    #[test]
    fn throwing_function_takes_error_out_param() {
        let f = swift_fn(
            "risky",
            vec![param("input", prim("int64"))],
            prim("int64"),
            SwiftFnInfo {
                throwing: true,
                ..Default::default()
            },
        );
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(
            s.contains("_ a0: Int, _ awErrOut: UnsafeMutableRawPointer?) -> Int"),
            "{s}"
        );
        assert!(
            s.contains("return awRacketTry(awErrOut, 0) { try TestKit.risky(input: a0) }"),
            "{s}"
        );
        // The arrow carries the trailing error out-buffer pointer; the racket side
        // routes through aw-call/error (raise on error, else identity coerce).
        assert_eq!(t.ffi_arrow(), "(_fun _int64 _pointer -> _int64)");
        let rkt = t.render_racket();
        assert!(rkt.contains("(aw-call/error raw values a0)"), "{rkt}");
    }

    #[test]
    fn throwing_string_return_unifies_nil_fallback() {
        let f = swift_fn(
            "load",
            vec![],
            nsstring(),
            SwiftFnInfo {
                throwing: true,
                ..Default::default()
            },
        );
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(
            s.contains(
                "return awRacketTry(awErrOut, nil) { Optional(Unmanaged.passRetained((try TestKit.load()) as NSString).toOpaque()) }"
            ),
            "{s}"
        );
    }

    #[test]
    fn version_gated_decl_emits_available_attribute() {
        use apianyware_types::provenance::{Availability, SourceProvenance};
        let mut f = plain("newAPI", vec![], prim("int64"));
        f.provenance = Some(SourceProvenance {
            header: None,
            line: None,
            availability: Some(Availability {
                introduced: Some("26.0".into()),
                deprecated: None,
            }),
        });
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(
            s.contains("@available(macOS 26.0, *)\n@_cdecl(\"aw_racket_swift_TestKit_newAPI\")"),
            "version-gated trampoline must carry @available:\n{s}"
        );
    }

    #[test]
    fn async_and_generic_are_deferred_not_dropped() {
        let a = swift_fn(
            "fetch",
            vec![],
            prim("void"),
            SwiftFnInfo {
                is_async: true,
                ..Default::default()
            },
        );
        let g = swift_fn(
            "identity",
            vec![param("x", prim("int64"))],
            prim("int64"),
            SwiftFnInfo {
                is_generic: true,
                ..Default::default()
            },
        );
        assert!(matches!(
            classify_function("TestKit", &a, std::slice::from_ref(&a), &no_structs()),
            FnDisposition::Deferred(DeferReason::Async)
        ));
        assert!(matches!(
            classify_function("TestKit", &g, std::slice::from_ref(&g), &no_structs()),
            FnDisposition::Deferred(DeferReason::UnbindableGenericFreeFunction)
        ));
    }

    #[test]
    fn nonbridged_struct_param_is_deferred() {
        let f = plain(
            "area",
            vec![param("of", swift_class("GeoRect", "TestKit"))],
            prim("double"),
        );
        // With no framework-owned value struct of that name, the param cannot be
        // soundly unboxed → still deferred (a CF/ObjC reference would land here too).
        assert!(matches!(
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs()),
            FnDisposition::Deferred(DeferReason::NonBridgedStructParam)
        ));
    }

    #[test]
    fn value_struct_param_unboxes_through_the_handle() {
        // `MLUntypedColumn`-style: a param whose named type the owning framework
        // defines in `Framework.structs` rides the handle-unbox path. The `@_cdecl`
        // takes the opaque handle and unboxes the named value before the by-name
        // call; racket passes the cpointer it holds straight through (leaf 040/040/030).
        let f = plain(
            "show",
            vec![param("_", swift_class("MLUntypedColumn", "CreateML"))],
            swift_class("MLStreamingVisualizable", "CreateML"),
        );
        let value_structs: HashSet<&str> = ["MLUntypedColumn"].into_iter().collect();
        let FnDisposition::Trampoline(t) =
            classify_function("CreateML", &f, std::slice::from_ref(&f), &value_structs)
        else {
            panic!("a framework-owned value-struct param must trampoline, not defer");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        // The handle crosses as a raw pointer; the body unboxes the named value.
        assert!(
            s.contains("public func aw_racket_swift_CreateML_show(_ a0: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?"),
            "{s}"
        );
        assert!(
            s.contains("let u0 = awRacketUnbox(a0!, as: MLUntypedColumn.self)"),
            "{s}"
        );
        // The unboxed value feeds the by-name call (label is `_`, so positional).
        assert!(
            s.contains("return awRacketBox((CreateML.show(u0)) as MLStreamingVisualizable)"),
            "{s}"
        );
        // Racket side: pointer in, pointer out, no coercion wrapper → bare get-ffi-obj.
        assert_eq!(t.ffi_arrow(), "(_fun _pointer -> _pointer)");
        assert_eq!(
            t.render_racket(),
            "(define show (get-ffi-obj 'aw_racket_swift_CreateML_show _aw-lib (_fun _pointer -> _pointer)))"
        );
        assert_eq!(t.provide_contract(), "[show (c-> cpointer? cpointer?)]");
    }

    #[test]
    fn mixed_value_struct_and_reference_param_defers_on_the_reference() {
        // `pointwiseMin(MLTensor, id)`-style: the value-struct param alone would
        // bind, but a mixed-in unnameable `id` param blocks the whole function —
        // and the recorded reason is the *actual* blocker, not the struct (fork 3).
        let f = plain(
            "pointwiseMin",
            vec![
                param("_", swift_class("MLTensor", "CoreML")),
                param(
                    "_",
                    TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Id {
                            protocols: Vec::new(),
                        },
                    },
                ),
            ],
            swift_class("MLTensor", "CoreML"),
        );
        let value_structs: HashSet<&str> = ["MLTensor"].into_iter().collect();
        assert!(matches!(
            classify_function("CoreML", &f, std::slice::from_ref(&f), &value_structs),
            FnDisposition::Deferred(DeferReason::UnnameableParam)
        ));
    }

    #[test]
    fn cgfloat_param_and_return_marshal_as_double() {
        // CGFloat is lossily lowered to `Class { CGFloat }`, but is a `Double`
        // scalar at the ABI: `acos(_ x: CGFloat) -> CGFloat` trampolines as a clean
        // `Double -> Double`, the dominant recovery in the residual (44/69).
        let f = plain(
            "acos",
            vec![param("_", swift_class("CGFloat", "CoreGraphics"))],
            swift_class("CGFloat", "CoreGraphics"),
        );
        let FnDisposition::Trampoline(t) =
            classify_function("CoreGraphics", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("CGFloat param/return must trampoline, not defer");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        // Boundary is Double both ways; the body re-wraps the arg as CGFloat and
        // converts the CGFloat result back to Double.
        assert!(
            s.contains("public func aw_racket_swift_CoreGraphics_acos(_ a0: Double) -> Double"),
            "{s}"
        );
        assert!(
            s.contains("return Double((CoreGraphics.acos(CGFloat(a0))) as CGFloat)"),
            "{s}"
        );
        // Pure scalar on the racket side — bare get-ffi-obj, no coercion wrapper.
        assert_eq!(t.ffi_arrow(), "(_fun _double -> _double)");
        assert_eq!(
            t.render_racket(),
            "(define acos (get-ffi-obj 'aw_racket_swift_CoreGraphics_acos _aw-lib (_fun _double -> _double)))"
        );
        assert_eq!(t.provide_contract(), "[acos (c-> real? real?)]");
    }

    #[test]
    fn closure_and_unnameable_params_get_distinct_reasons() {
        // A block param and an `id`/`Any` param are recorded under their own reasons
        // rather than the nonbridged-struct umbrella (spec §5 honest categorisation).
        let block = TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(prim("void")),
            },
        };
        let with_block = plain("onEvent", vec![param("handler", block)], prim("void"));
        assert!(matches!(
            classify_function(
                "TestKit",
                &with_block,
                std::slice::from_ref(&with_block),
                &no_structs()
            ),
            FnDisposition::Deferred(DeferReason::ClosureParam)
        ));
        let any = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id {
                protocols: Vec::new(),
            },
        };
        let with_any = plain("accept", vec![param("value", any)], prim("void"));
        assert!(matches!(
            classify_function(
                "TestKit",
                &with_any,
                std::slice::from_ref(&with_any),
                &no_structs()
            ),
            FnDisposition::Deferred(DeferReason::UnnameableParam)
        ));
    }

    #[test]
    fn overloads_get_distinct_content_addressed_entries() {
        let a = plain("scale", vec![param("by", prim("int64"))], prim("int64"));
        let b = plain("scale", vec![param("by", prim("double"))], prim("double"));
        let siblings = vec![a.clone(), b.clone()];
        let FnDisposition::Trampoline(ta) =
            classify_function("TestKit", &a, &siblings, &no_structs())
        else {
            panic!()
        };
        let FnDisposition::Trampoline(tb) =
            classify_function("TestKit", &b, &siblings, &no_structs())
        else {
            panic!()
        };
        assert_ne!(ta.entry, tb.entry, "overloads must not collide");
        assert!(ta.entry.starts_with("aw_racket_swift_TestKit_scale_"));
        // The racket-visible name is also disambiguated (racket has no overloading,
        // so a bare `(define scale)` twice would collide) — same hash as the entry.
        assert_ne!(
            ta.binding_name, tb.binding_name,
            "racket names must not collide"
        );
        assert!(ta.binding_name.starts_with("scale_"), "{}", ta.binding_name);
        assert!(
            ta.render_racket().contains("(define scale_"),
            "{}",
            ta.render_racket()
        );
        assert!(
            ta.provide_contract().starts_with("[scale_"),
            "{}",
            ta.provide_contract()
        );
        // Deterministic: recomputing yields the same symbol (no global counter).
        let FnDisposition::Trampoline(ta2) =
            classify_function("TestKit", &a, &siblings, &no_structs())
        else {
            panic!()
        };
        assert_eq!(ta.entry, ta2.entry);
        assert_eq!(ta.binding_name, ta2.binding_name);
    }

    #[test]
    fn non_overloaded_binding_keeps_the_bare_name() {
        let f = plain("compute", vec![param("x", prim("double"))], prim("double"));
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!()
        };
        assert_eq!(t.binding_name, "compute");
    }

    #[test]
    fn constant_reader_returns_value() {
        let c = Constant {
            name: "sharedToken".into(),
            constant_type: nsstring(),
            array_element: None,
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: false,
        };
        let t = classify_constant("TestKit", &c);
        assert_eq!(t.entry, "aw_racket_swift_const_TestKit_sharedToken");
        let mut s = String::new();
        emit_const(&mut s, &t);
        assert!(
            s.contains("public func aw_racket_swift_const_TestKit_sharedToken() -> UnsafeMutableRawPointer?"),
            "{s}"
        );
        assert!(
            s.contains(
                "return Unmanaged.passRetained((TestKit.sharedToken) as NSString).toOpaque()"
            ),
            "{s}"
        );
    }

    #[test]
    fn pointer_constant_returns_handle() {
        let c = Constant {
            name: "defaultConfig".into(),
            constant_type: swift_class("Config", "TestKit"),
            array_element: None,
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: false,
        };
        let t = classify_constant("TestKit", &c);
        let mut s = String::new();
        emit_const(&mut s, &t);
        assert!(
            s.contains("return awRacketBox((TestKit.defaultConfig) as Config)"),
            "{s}"
        );
        assert_eq!(
            t.render_racket(),
            "(define defaultConfig ((get-ffi-obj 'aw_racket_swift_const_TestKit_defaultConfig _aw-lib (_fun -> _pointer))))"
        );
        assert_eq!(t.provide_contract(), "[defaultConfig cpointer?]");
    }

    #[test]
    fn generated_file_imports_modules_and_logs_counts() {
        let fw = Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: "TestKit".into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![
                plain("compute", vec![param("x", prim("double"))], prim("double")),
                swift_fn(
                    "fetch",
                    vec![],
                    prim("void"),
                    SwiftFnInfo {
                        is_async: true,
                        ..Default::default()
                    },
                ),
            ],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        };
        let set = collect_trampolines(std::slice::from_ref(&fw));
        assert_eq!(set.functions.len(), 1);
        assert_eq!(set.deferred.len(), 1);
        let swift = generate_trampolines_swift(&set);
        assert!(swift.contains("import Foundation"), "{swift}");
        assert!(swift.contains("import TestKit"), "{swift}");
        assert!(
            swift.contains(
                "1 function + 0 constant + 0 init + 0 method trampolines; deferred — 1 deferred_async."
            ),
            "{swift}"
        );
    }

    // --- Method / init trampoline codegen (the method frontier) ---

    fn method(selector: &str, params: Vec<Param>, ret: TypeRef, info: SwiftFnInfo) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: selector.starts_with("init"),
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
            swift_fn: Some(info),
        }
    }

    fn swiftk() -> SwiftFnInfo {
        SwiftFnInfo::default()
    }

    fn mutating() -> SwiftFnInfo {
        SwiftFnInfo {
            self_kind: Some("Mutating".into()),
            ..Default::default()
        }
    }

    fn asyncthrows() -> SwiftFnInfo {
        SwiftFnInfo {
            is_async: true,
            throwing: true,
            self_kind: Some("NonMutating".into()),
            ..Default::default()
        }
    }

    /// An `async throws` method (the `URLSession.data(from:)` headline) drives the
    /// completion-callback bridge (D5/R4): the `@_cdecl` takes a trailing ctx +
    /// C callback, captures the receiver pointer into an `@Sendable` operation
    /// closure that unboxes + `await`s + marshals to `AwAsyncOutcome` on the
    /// cooperative thread, and delivers it through `awRacketAsyncDispatch`.
    #[test]
    fn async_throws_method_drives_completion_callback() {
        let m = method(
            "data(from:)",
            vec![param("from", swift_class("NSURL", "Foundation"))],
            swift_class("Tuple", "Foundation"), // unspellable ⇒ Handle(None), boxed
            asyncthrows(),
        );
        let MethodDisposition::Method(t) = classify_method(
            "Foundation",
            "URLSession",
            true,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("an async method must trampoline (callback form), not defer");
        };
        assert!(t.is_async, "classified async");
        let mut s = String::new();
        emit_method_tramp(&mut s, &t);
        // Signature: receiver, the bridged object param, then ctx + completion
        // callback; the trampoline itself returns void (no throwing out-param).
        assert!(
            s.contains("_ awRecv: UnsafeMutableRawPointer?, _ a0: UnsafeMutableRawPointer?, _ awCtx: Int, _ awCb: @convention(c) (Int, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void)"),
            "{s}"
        );
        // Args reconstruct to Sendable values *at entry* (captured by value across
        // the async hop — no dangling handle).
        assert!(
            s.contains("let o0 = Unmanaged<NSURL>.fromOpaque(a0!).takeUnretainedValue() as URL"),
            "{s}"
        );
        // The operation closure captures the receiver pointer, unboxes inside,
        // awaits, and marshals to AwAsyncOutcome on the cooperative thread.
        // The receiver pointer rides `nonisolated(unsafe)` across the Sendable hop
        // (UnsafeMutableRawPointer is not Sendable); reconstructed inside the closure.
        assert!(
            s.contains("nonisolated(unsafe) let awRecvUnsafe = awRecv"),
            "{s}"
        );
        assert!(
            s.contains("awRacketAsyncDispatch({ () async -> AwAsyncOutcome in"),
            "{s}"
        );
        assert!(
            s.contains("let awSelf = Unmanaged<Foundation.URLSession>.fromOpaque(awRecvUnsafe!).takeUnretainedValue()"),
            "{s}"
        );
        assert!(
            s.contains("let awR = try await awSelf.data(from: o0)"),
            "{s}"
        );
        assert!(
            s.contains("return AwAsyncOutcome(value: awRacketBox(awR))"),
            "{s}"
        );
        assert!(s.contains("return AwAsyncOutcome.failure(error)"), "{s}");
        assert!(
            s.contains("awCb(awCtx, awOutcome.value, awOutcome.error)"),
            "{s}"
        );
        // ffi arrow: receiver, object pointer, ctx intptr, callback; returns void.
        assert_eq!(
            t.ffi_arrow(),
            "(_fun _pointer _pointer _intptr _fpointer aw-> _void)"
        );
        // Racket binding: the callback form via aw-async-call; `complete` is the
        // last lambda arg, threaded as ctx+cb into the kicker.
        let rkt = t.render_racket_method("url-session-data", &["url".into()]);
        assert!(rkt.contains("(lambda (self url complete)"), "{rkt}");
        assert!(rkt.contains("(aw-async-call"), "{rkt}");
        assert!(rkt.contains("(raw (coerce-arg self) url id cb)"), "{rkt}");
    }

    /// A value-struct owner's non-mutating method unboxes a copy and calls by name.
    #[test]
    fn value_receiver_nonmutating_method_unboxes_and_calls() {
        let m = method(
            "contains(_:)",
            vec![param("_", prim("int64"))],
            prim("bool"),
            swiftk(),
        );
        let MethodDisposition::Method(t) = classify_method(
            "Foundation",
            "IndexSet",
            false,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected method trampoline");
        };
        assert_eq!(t.entry, "aw_racket_swift_m_Foundation_IndexSet_contains");
        let mut s = String::new();
        emit_method_tramp(&mut s, &t);
        assert!(
            s.contains("@_cdecl(\"aw_racket_swift_m_Foundation_IndexSet_contains\")"),
            "{s}"
        );
        assert!(
            s.contains("_ awRecv: UnsafeMutableRawPointer?, _ a0: Int) -> Bool"),
            "{s}"
        );
        assert!(
            s.contains("let awSelf = awRacketUnbox(awRecv!, as: Foundation.IndexSet.self)"),
            "{s}"
        );
        // Integer params ride numericCast (IR int-width collapse); a Bool return is identity.
        assert!(s.contains("return awSelf.contains(numericCast(a0))"), "{s}");
        // ffi arrow: receiver pointer first, then the scalar.
        assert_eq!(t.ffi_arrow(), "(_fun _pointer _int64 aw-> _bool)");
        let rkt = t.render_racket_method("index-set-contains", &["n".into()]);
        assert!(rkt.contains("(lambda (self n)"), "{rkt}");
        assert!(rkt.contains("(raw (coerce-arg self) n)"), "{rkt}");
    }

    /// A `mutating` value-receiver method writes the mutated value back into the box.
    #[test]
    fn mutating_value_receiver_writes_back() {
        let m = method(
            "update(with:)",
            vec![param("with", prim("int64"))],
            prim("int64"),
            mutating(),
        );
        let MethodDisposition::Method(t) = classify_method(
            "Foundation",
            "IndexSet",
            false,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected method trampoline");
        };
        let mut s = String::new();
        emit_method_tramp(&mut s, &t);
        assert!(
            s.contains(
                "let awBox = Unmanaged<AwValueBox>.fromOpaque(awRecv!).takeUnretainedValue()"
            ),
            "{s}"
        );
        assert!(
            s.contains("var awSelf = awBox.value as! Foundation.IndexSet"),
            "{s}"
        );
        assert!(
            s.contains("let awR = awSelf.update(with: numericCast(a0))"),
            "{s}"
        );
        assert!(s.contains("awBox.value = awSelf"), "{s}");
        assert!(s.contains("return numericCast(awR)"), "{s}");
    }

    /// A class (reference) receiver reconstructs via `Unmanaged`, no write-back.
    #[test]
    fn class_receiver_uses_unmanaged() {
        let m = method("description", vec![], nsstring(), swiftk());
        let MethodDisposition::Method(t) = classify_method(
            "TestKit",
            "Widget",
            true,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected method trampoline");
        };
        let mut s = String::new();
        emit_method_tramp(&mut s, &t);
        assert!(
            s.contains(
                "let awSelf = Unmanaged<TestKit.Widget>.fromOpaque(awRecv!).takeUnretainedValue()"
            ),
            "{s}"
        );
        assert!(
            !s.contains("awBox.value ="),
            "no write-back for a class receiver: {s}"
        );
    }

    /// An initializer producer boxes the *owning type* (R2), not the lossy IR return.
    #[test]
    fn init_producer_boxes_owner_value() {
        // init(integer:) reports return NSIndexSet in the IR — must box IndexSet.
        let m = method(
            "init(integer:)",
            vec![param("integer", prim("int64"))],
            swift_class("NSIndexSet", "Foundation"),
            swiftk(),
        );
        let MethodDisposition::Init(t) = classify_method(
            "Foundation",
            "IndexSet",
            false,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected init trampoline");
        };
        assert_eq!(t.entry, "aw_racket_swift_init_Foundation_IndexSet");
        let mut s = String::new();
        emit_init_tramp(&mut s, &t);
        assert!(s.contains("_ a0: Int) -> UnsafeMutableRawPointer?"), "{s}");
        // Init params keep their declared width (no numericCast — overload selection).
        assert!(
            s.contains("return awRacketBox(Foundation.IndexSet(integer: a0))"),
            "{s}"
        );
    }

    /// The racket binding for an init producer is a constructor returning the
    /// boxed owner handle: it calls the `@_cdecl` and passes the cpointer through.
    #[test]
    fn init_producer_renders_racket_constructor() {
        let m = method(
            "init(integer:)",
            vec![param("integer", prim("int64"))],
            swift_class("NSIndexSet", "Foundation"),
            swiftk(),
        );
        let MethodDisposition::Init(t) = classify_method(
            "Foundation",
            "IndexSet",
            false,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected init trampoline");
        };
        assert_eq!(t.ffi_arrow(), "(_fun _int64 aw-> _pointer)");
        let rkt = t.render_racket_init("make-index-set-integer", &["integer".into()]);
        assert!(rkt.contains("(define make-index-set-integer"), "{rkt}");
        assert!(
            rkt.contains("'aw_racket_swift_init_Foundation_IndexSet _aw-lib"),
            "{rkt}"
        );
        assert!(rkt.contains("(lambda (integer)"), "{rkt}");
        assert!(rkt.contains("(raw integer)"), "{rkt}");
    }

    /// A no-arg init renders a zero-argument constructor (still a thunk, so the
    /// `@_cdecl` runs on call, not at module load).
    #[test]
    fn no_arg_init_renders_thunk_constructor() {
        let m = method("init", vec![], swift_class("Widget", "TestKit"), swiftk());
        let MethodDisposition::Init(t) = classify_method(
            "TestKit",
            "Widget",
            true,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected init trampoline");
        };
        assert_eq!(t.ffi_arrow(), "(_fun aw-> _pointer)");
        let rkt = t.render_racket_init("make-widget", &[]);
        assert!(rkt.contains("(lambda ()"), "{rkt}");
        assert!(rkt.contains("(raw)"), "{rkt}");
    }

    /// A class initializer keeps reference identity via `Unmanaged.passRetained`.
    #[test]
    fn class_init_passes_retained() {
        let m = method("init", vec![], swift_class("Widget", "TestKit"), swiftk());
        let MethodDisposition::Init(t) = classify_method(
            "TestKit",
            "Widget",
            true,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected init trampoline");
        };
        let mut s = String::new();
        emit_init_tramp(&mut s, &t);
        assert!(
            s.contains("return Unmanaged.passRetained(TestKit.Widget()).toOpaque()"),
            "{s}"
        );
    }

    /// Generic / consuming / operator / static methods defer with the right reason.
    #[test]
    fn method_deferrals_are_categorised() {
        let generic = method(
            "map(_:)",
            vec![],
            prim("void"),
            SwiftFnInfo {
                is_generic: true,
                ..Default::default()
            },
        );
        let consuming = method(
            "take",
            vec![],
            prim("void"),
            SwiftFnInfo {
                self_kind: Some("Consuming".into()),
                ..Default::default()
            },
        );
        let op = method("==(_:_:)", vec![], prim("bool"), swiftk());
        let mut stat = method("shared", vec![], prim("void"), swiftk());
        stat.class_method = true;
        for (m, want) in [
            (&generic, DeferReason::UnbindableGenericMethod),
            (&consuming, DeferReason::ConsumingReceiver),
            (&op, DeferReason::NonNameableMethod),
            (&stat, DeferReason::StaticMethod),
        ] {
            let MethodDisposition::Deferred(r) = classify_method(
                "Foundation",
                "IndexSet",
                false,
                m,
                std::slice::from_ref(m),
                &no_structs(),
                None,
            ) else {
                panic!("expected deferral for {:?}", m.selector);
            };
            assert_eq!(r, want, "selector {:?}", m.selector);
        }
    }

    /// Overloaded methods get distinct content-addressed entries; the collect pass
    /// walks both structs and classes and tallies inits/methods.
    #[test]
    fn collect_walks_types_and_disambiguates_overloads() {
        let fw = Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: "Foundation".into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![Struct {
                name: "IndexSet".into(),
                fields: vec![],
                methods: vec![
                    method(
                        "init(integer:)",
                        vec![param("integer", prim("int64"))],
                        swift_class("NSIndexSet", "Foundation"),
                        swiftk(),
                    ),
                    method(
                        "contains(_:)",
                        vec![param("_", prim("int64"))],
                        prim("bool"),
                        swiftk(),
                    ),
                    // Two overloads of `contains` → both need a hash.
                    method(
                        "contains(in:)",
                        vec![param("in", prim("int64"))],
                        prim("bool"),
                        swiftk(),
                    ),
                    method(
                        "update(with:)",
                        vec![param("with", prim("int64"))],
                        prim("int64"),
                        mutating(),
                    ),
                ],
                source: None,
                provenance: None,
                doc_refs: None,
                objc_exposed: false,
            }],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        };
        let set = collect_trampolines(std::slice::from_ref(&fw));
        assert_eq!(set.inits.len(), 1, "one init");
        assert_eq!(set.methods.len(), 3, "three instance methods");
        // The two `contains` overloads carry distinct content hashes.
        let contains: Vec<&str> = set
            .methods
            .iter()
            .filter(|m| m.swift_name == "contains")
            .map(|m| m.entry.as_str())
            .collect();
        assert_eq!(contains.len(), 2);
        assert_ne!(
            contains[0], contains[1],
            "overloads disambiguated: {contains:?}"
        );
        let swift = generate_trampolines_swift(&set);
        assert!(
            swift.contains("0 function + 0 constant + 1 init + 3 method trampolines."),
            "{swift}"
        );
    }

    /// An objc-bridged reference param (`NSURL`) reconstructs as its Swift value
    /// twin (`as URL`) before the by-name call (R1); racket passes the id cpointer
    /// straight in. The lossy IR reports `URL` params as their objc twin `NSURL`.
    #[test]
    fn object_ref_param_bridges_to_value_twin() {
        let m = method(
            "open(_:)",
            vec![param("_", swift_class("NSURL", "Foundation"))],
            prim("bool"),
            swiftk(),
        );
        let MethodDisposition::Method(t) = classify_method(
            "AppKit",
            "NSWorkspace",
            true,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("an objc-bridged reference param must trampoline, not defer");
        };
        let mut s = String::new();
        emit_method_tramp(&mut s, &t);
        // Boundary param is an opaque id; the body reconstructs the NSURL and
        // bridges to the URL value the by-name call wants.
        assert!(
            s.contains(
                "_ awRecv: UnsafeMutableRawPointer?, _ a0: UnsafeMutableRawPointer?) -> Bool"
            ),
            "{s}"
        );
        assert!(
            s.contains("let o0 = Unmanaged<NSURL>.fromOpaque(a0!).takeUnretainedValue() as URL"),
            "{s}"
        );
        assert!(s.contains("return awSelf.open(o0)"), "{s}");
        // ffi: receiver pointer, then the object pointer.
        assert_eq!(t.ffi_arrow(), "(_fun _pointer _pointer aw-> _bool)");
        // Racket passes the id cpointer straight through (no coercion wrapper).
        let rkt = t.render_racket_method("ns-workspace-open", &["url".into()]);
        assert!(rkt.contains("(raw (coerce-arg self) url)"), "{rkt}");
    }

    /// A non-throwing `async` method returning a handle marshals straight to
    /// `AwAsyncOutcome(value:)` with no do/catch, and `await`s without `try`.
    #[test]
    fn async_nonthrowing_method_has_no_try_or_catch() {
        let info = SwiftFnInfo {
            is_async: true,
            self_kind: Some("NonMutating".into()),
            ..Default::default()
        };
        let m = method(
            "response",
            vec![],
            swift_class("Response", "MusicKit"),
            info,
        );
        let MethodDisposition::Method(t) = classify_method(
            "MusicKit",
            "MusicDataRequest",
            true,
            &m,
            std::slice::from_ref(&m),
            &no_structs(),
            None,
        ) else {
            panic!("expected async method trampoline");
        };
        let mut s = String::new();
        emit_method_tramp(&mut s, &t);
        assert!(s.contains("let awR = await awSelf.response()"), "{s}");
        assert!(
            s.contains("return AwAsyncOutcome(value: awRacketBox(awR))"),
            "{s}"
        );
        assert!(
            !s.contains("try await"),
            "non-throwing must not use try: {s}"
        );
        assert!(!s.contains("catch"), "non-throwing must not catch: {s}");
    }

    /// An `async` void method delivers an empty outcome (the racket completion gets
    /// `#f`), and a `mutating`/scalar-return async method defers with its own reason.
    #[test]
    fn async_void_and_unsupportable_returns() {
        let void_async = method(
            "finish",
            vec![],
            prim("void"),
            SwiftFnInfo {
                is_async: true,
                self_kind: Some("NonMutating".into()),
                ..Default::default()
            },
        );
        let MethodDisposition::Method(t) = classify_method(
            "StoreKit",
            "Transaction",
            false,
            &void_async,
            std::slice::from_ref(&void_async),
            &no_structs(),
            None,
        ) else {
            panic!("expected async void method trampoline");
        };
        let mut s = String::new();
        emit_method_tramp(&mut s, &t);
        assert!(s.contains("await awSelf.finish()"), "{s}");
        assert!(s.contains("return AwAsyncOutcome()"), "{s}");

        // mutating-async and scalar-return-async defer with their own reasons.
        let mut_async = method(
            "advance",
            vec![],
            prim("void"),
            SwiftFnInfo {
                is_async: true,
                self_kind: Some("Mutating".into()),
                ..Default::default()
            },
        );
        let scalar_async = method(
            "count",
            vec![],
            prim("int64"),
            SwiftFnInfo {
                is_async: true,
                self_kind: Some("NonMutating".into()),
                ..Default::default()
            },
        );
        for (m, want) in [
            (&mut_async, DeferReason::AsyncMutatingReceiver),
            (&scalar_async, DeferReason::AsyncScalarReturn),
        ] {
            let MethodDisposition::Deferred(r) = classify_method(
                "Foundation",
                "Thing",
                false,
                m,
                std::slice::from_ref(m),
                &no_structs(),
                None,
            ) else {
                panic!("expected deferral for {:?}", m.selector);
            };
            assert_eq!(r, want, "selector {:?}", m.selector);
        }
    }

    /// Real-framework compile proof (run explicitly, needs local collected IR):
    /// generate the whole Foundation residual (functions/constants/inits/methods)
    /// from `collection/ir/collected/Foundation.json` and write it to
    /// `$AW_TRAMPOLINE_OUT` (default `/tmp/aw-trampoline-check/Trampolines.swift`)
    /// so swiftc can type-check it against real Foundation + the runtime. Proves the
    /// codegen emits compilable Swift over a large, diverse real framework.
    ///   AW_TRAMPOLINE_OUT=/tmp/aw/Trampolines.swift \
    ///     cargo test -p apianyware-emit-racket --lib -- --ignored generate_foundation
    #[test]
    #[ignore]
    fn generate_foundation_trampolines_to_disk() {
        let path = std::env::var("AW_TRAMPOLINE_OUT")
            .unwrap_or_else(|_| "/tmp/aw-trampoline-check/Trampolines.swift".to_string());
        // Walk up to the repo root to find the collected IR regardless of cwd.
        let mut dir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
        let json = loop {
            let candidate = dir.join("collection/ir/collected/Foundation.json");
            if candidate.exists() {
                break candidate;
            }
            if !dir.pop() {
                panic!("could not locate collection/ir/collected/Foundation.json");
            }
        };
        let fw: Framework = serde_json::from_str(&std::fs::read_to_string(&json).unwrap()).unwrap();
        let set = collect_trampolines(std::slice::from_ref(&fw));
        let swift = generate_trampolines_swift(&set);
        let out = std::path::PathBuf::from(&path);
        std::fs::create_dir_all(out.parent().unwrap()).unwrap();
        std::fs::write(&out, &swift).unwrap();
        eprintln!(
            "wrote {} ({} fn, {} const, {} init, {} method; deferred {:?})",
            path,
            set.functions.len(),
            set.constants.len(),
            set.inits.len(),
            set.methods.len(),
            set.defer_counts()
        );
    }
}
