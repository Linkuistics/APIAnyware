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
//!   reconstructed and passed by-value/with the `as String` bridge; any other
//!   param (a non-bridged Swift struct, tuple, existential, …) would require the
//!   body to unbox a *named* Swift type, deferred to a follow-up leaf and recorded.
//! - **`throws`** → a trailing `NSError **` out-param run through `awRacketTry`
//!   (the `ThrowsBridge.swift` runtime, mirroring the dispatch `error_out` shape).
//! - **`async`** and **generic free functions** are recorded with a reason + count
//!   ([`Deferred`]), never silently dropped (spec §5).
//!
//! Naming is content-addressed (ADR-0013 precedent) so the emitter reconstructs
//! the same symbol with no shared counter: `aw_racket_swift_<Fw>_<name>`, with a
//! short signature hash appended when a `(module, name)` is overloaded within its
//! framework; constants are `aw_racket_swift_const_<Fw>_<name>`.

use std::collections::BTreeMap;

use apianyware_macos_types::ir::{Constant, Framework, Function};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

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
    ScalarTypedef { scalar: Scalar, name: String },
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
            Scalar::UInt
            | Scalar::UInt8
            | Scalar::UInt16
            | Scalar::UInt32
            | Scalar::UInt64 => "exact-nonnegative-integer?",
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
fn classify_param(t: &TypeRef) -> Result<ArgMarshal, DeferReason> {
    if is_swift_string(t) {
        return Ok(ArgMarshal::SwiftString);
    }
    match &t.kind {
        TypeRefKind::Primitive { name } => scalar_of_primitive(name)
            .map(ArgMarshal::Scalar)
            .ok_or(DeferReason::NonBridgedStructParam),
        // A named type lowered from a non-bridged Swift value: a scalar-backed
        // typedef (`CGFloat`) marshals by value; anything else (a genuine opaque
        // value struct, a CF/ObjC reference type, a bridged collection) still needs
        // the named-type handle-unbox path — deferred to a focused follow-up leaf.
        TypeRefKind::Class { name, .. }
        | TypeRefKind::Struct { name }
        | TypeRefKind::Alias { name, .. } => match scalar_typedef(name) {
            Some(scalar) => Ok(ArgMarshal::ScalarTypedef {
                scalar,
                name: name.clone(),
            }),
            None => Err(DeferReason::NonBridgedStructParam),
        },
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
fn introduced_macos(provenance: &Option<apianyware_macos_types::provenance::SourceProvenance>) -> Option<String> {
    provenance
        .as_ref()
        .and_then(|p| p.availability.as_ref())
        .and_then(|a| a.introduced.clone())
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
        }
    }
}

/// The whole-program trampoline plan: what to emit into `Trampolines.swift` and
/// what was deferred. Built once over all enriched frameworks by the global pass.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct TrampolineSet {
    pub functions: Vec<FnTrampoline>,
    pub constants: Vec<ConstTrampoline>,
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

/// Classify a Swift-native (`objc_exposed == false`) function. `siblings` is the
/// full residual-function set of the *same* module (used only for overload
/// disambiguation in the entry name) — pass the framework's functions; the
/// classifier filters them itself.
pub fn classify_function(module: &str, func: &Function, siblings: &[Function]) -> FnDisposition {
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
        match classify_param(&p.param_type) {
            Ok(m) => params.push(m),
            // The first non-bindable param's reason wins — deterministic, and the
            // most specific category is recorded rather than a blanket umbrella.
            Err(reason) => return FnDisposition::Deferred(reason),
        }
    }
    let ret = classify_return(&func.return_type);
    let throwing = func.swift_fn.as_ref().is_some_and(|i| i.throwing);
    let labels = func.params.iter().map(|p| p.name.clone()).collect();
    let entry = function_entry_name(module, func, siblings);

    FnDisposition::Trampoline(FnTrampoline {
        module: module.to_string(),
        swift_name: func.name.clone(),
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
    let base = format!(
        "{FN_PREFIX}{}_{}",
        sanitize(module),
        sanitize(&func.name)
    );
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
        for func in &fw.functions {
            if func.objc_exposed {
                continue; // direct-bound (trampoline-elided)
            }
            match classify_function(&fw.name, func, &fw.functions) {
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
    }
    set
}

// ---------------------------------------------------------------------------
// Swift codegen (Generated/Trampolines.swift)
// ---------------------------------------------------------------------------

/// Render the by-name call expression `name(label0: a0, label1: s1, …)`.
fn call_expr(t: &FnTrampoline) -> String {
    let args: Vec<String> = t
        .params
        .iter()
        .zip(&t.labels)
        .enumerate()
        .map(|(i, (m, label))| {
            let value = match m {
                ArgMarshal::Scalar(_) => format!("a{i}"),
                // Re-wrap the underlying scalar as the named typedef so the by-name
                // call binds the real (CGFloat-taking) overload: `CGFloat(a0)`.
                ArgMarshal::ScalarTypedef { name, .. } => format!("{name}(a{i})"),
                ArgMarshal::SwiftString => format!("s{i}"),
            };
            if label == "_" || label.is_empty() {
                value
            } else {
                format!("{label}: {value}")
            }
        })
        .collect();
    // Module-qualify the call (`CoreGraphics.nan(…)`): the residual has free
    // functions a second imported module also exports (`nan` in CoreGraphics and
    // _DarwinFoundation1), so a bare name is ambiguous; the owning module
    // disambiguates and is always in scope (we `import` it).
    format!("{}.{}({})", t.module, t.swift_name, args.join(", "))
}

/// The `@_cdecl` parameter list (named) and the body's reconstruction prelude.
fn decl_params_and_prelude(t: &FnTrampoline) -> (Vec<String>, String) {
    let mut decl = Vec::with_capacity(t.params.len());
    let mut prelude = String::new();
    for (i, m) in t.params.iter().enumerate() {
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
    let (mut decl, prelude) = decl_params_and_prelude(t);
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
            RetMarshal::Void => format!("  _ = awRacketTry(awErrOut, ()) {{ try {call} }}\n"),
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
pub fn generate_trampolines_swift(set: &TrampolineSet) -> String {
    let mut s = String::new();
    s.push_str("// Generated C-ABI trampolines for the Swift-native residual (ADR-0027).\n");
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-macos-generate` from the IR.\n");
    s.push_str("// One @_cdecl per retained `objc_exposed == false` Swift-native decl; each\n");
    s.push_str("// imports the owning framework and calls the API by name (swiftc owns ABI\n");
    s.push_str("// correctness). Bound from the generated Racket bindings against _aw-lib. See:\n");
    s.push_str("//   docs/specs/2026-06-15-racket-trampoline.md\n");
    s.push_str("//   docs/adr/0027-racket-trampoline-structure.md\n\n");
    s.push_str("import Foundation\n");

    // One `import` per distinct module that has at least one emitted trampoline.
    let mut modules: Vec<&str> = set
        .functions
        .iter()
        .map(|t| t.module.as_str())
        .chain(set.constants.iter().map(|t| t.module.as_str()))
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

    let counts = set.defer_counts();
    let deferred_note = if counts.is_empty() {
        String::new()
    } else {
        let parts: Vec<String> = counts.iter().map(|(r, n)| format!("{n} {r}")).collect();
        format!("; deferred — {}", parts.join(", "))
    };
    s.push_str(&format!(
        "// {} function + {} constant trampoline{}{}.\n",
        set.functions.len(),
        set.constants.len(),
        if set.functions.len() + set.constants.len() == 1 {
            ""
        } else {
            "s"
        },
        deferred_note
    ));
    s
}

// ---------------------------------------------------------------------------
// Racket binding rendering (consumed by emit_functions / emit_constants)
// ---------------------------------------------------------------------------

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
                ArgMarshal::SwiftString => "_pointer",
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
            })
            .collect();
        let ret = ret_contract(&self.ret);
        if params.is_empty() {
            format!("[{} (c-> {ret})]", self.swift_name)
        } else {
            format!("[{} (c-> {} {ret})]", self.swift_name, params.join(" "))
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
                self.swift_name, self.entry
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
                // hands a number; the `@_cdecl` re-wraps it to the typedef).
                ArgMarshal::Scalar(_) | ArgMarshal::ScalarTypedef { .. } => a.clone(),
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
                name = self.swift_name,
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
                name = self.swift_name,
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

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Param, SwiftFnInfo};

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
    fn swift_fn(
        name: &str,
        params: Vec<Param>,
        ret: TypeRef,
        info: SwiftFnInfo,
    ) -> Function {
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
        let FnDisposition::Trampoline(t) = classify_function("TestKit", &f, std::slice::from_ref(&f))
        else {
            panic!("expected trampoline");
        };
        assert_eq!(t.entry, "aw_racket_swift_TestKit_compute");
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("@_cdecl(\"aw_racket_swift_TestKit_compute\")"), "{s}");
        assert!(s.contains("public func aw_racket_swift_TestKit_compute(_ a0: Double) -> Double"), "{s}");
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
        let FnDisposition::Trampoline(t) = classify_function("TestKit", &f, std::slice::from_ref(&f))
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("_ a0: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?"), "{s}");
        assert!(
            s.contains("let s0 = Unmanaged<NSString>.fromOpaque(a0!).takeUnretainedValue() as String"),
            "{s}"
        );
        assert!(
            s.contains("return Unmanaged.passRetained((TestKit.greeting(name: s0)) as NSString).toOpaque()"),
            "{s}"
        );
        assert_eq!(t.ffi_arrow(), "(_fun _pointer -> _pointer)");
        // Racket side bridges the string arg in and coerces the string result out.
        let rkt = t.render_racket();
        assert!(rkt.contains("(aw-string-result (raw (aw-string-arg a0)))"), "{rkt}");
        assert_eq!(t.provide_contract(), "[greeting (c-> string? (or/c string? #f))]");
    }

    #[test]
    fn nonbridged_struct_return_is_boxed_handle() {
        // (Double, Double) -> SomeSwiftStruct  → scalar params, boxed return.
        let f = plain(
            "makePoint",
            vec![param("x", prim("double")), param("y", prim("double"))],
            swift_class("GeoPoint", "TestKit"),
        );
        let FnDisposition::Trampoline(t) = classify_function("TestKit", &f, std::slice::from_ref(&f))
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("-> UnsafeMutableRawPointer?"), "{s}");
        assert!(s.contains("return awRacketBox((TestKit.makePoint(x: a0, y: a1)) as GeoPoint)"), "{s}");
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
        let FnDisposition::Trampoline(t) = classify_function("TestKit", &f, std::slice::from_ref(&f))
        else {
            panic!("expected trampoline");
        };
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("_ a0: Int, _ awErrOut: UnsafeMutableRawPointer?) -> Int"), "{s}");
        assert!(s.contains("return awRacketTry(awErrOut, 0) { try TestKit.risky(input: a0) }"), "{s}");
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
        let FnDisposition::Trampoline(t) = classify_function("TestKit", &f, std::slice::from_ref(&f))
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
        use apianyware_macos_types::provenance::{Availability, SourceProvenance};
        let mut f = plain("newAPI", vec![], prim("int64"));
        f.provenance = Some(SourceProvenance {
            header: None,
            line: None,
            availability: Some(Availability {
                introduced: Some("26.0".into()),
                deprecated: None,
            }),
        });
        let FnDisposition::Trampoline(t) = classify_function("TestKit", &f, std::slice::from_ref(&f))
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
            classify_function("TestKit", &a, std::slice::from_ref(&a)),
            FnDisposition::Deferred(DeferReason::Async)
        ));
        assert!(matches!(
            classify_function("TestKit", &g, std::slice::from_ref(&g)),
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
        assert!(matches!(
            classify_function("TestKit", &f, std::slice::from_ref(&f)),
            FnDisposition::Deferred(DeferReason::NonBridgedStructParam)
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
            classify_function("CoreGraphics", &f, std::slice::from_ref(&f))
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
            classify_function("TestKit", &with_block, std::slice::from_ref(&with_block)),
            FnDisposition::Deferred(DeferReason::ClosureParam)
        ));
        let any = TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        };
        let with_any = plain("accept", vec![param("value", any)], prim("void"));
        assert!(matches!(
            classify_function("TestKit", &with_any, std::slice::from_ref(&with_any)),
            FnDisposition::Deferred(DeferReason::UnnameableParam)
        ));
    }

    #[test]
    fn overloads_get_distinct_content_addressed_entries() {
        let a = plain("scale", vec![param("by", prim("int64"))], prim("int64"));
        let b = plain("scale", vec![param("by", prim("double"))], prim("double"));
        let siblings = vec![a.clone(), b.clone()];
        let FnDisposition::Trampoline(ta) = classify_function("TestKit", &a, &siblings) else {
            panic!()
        };
        let FnDisposition::Trampoline(tb) = classify_function("TestKit", &b, &siblings) else {
            panic!()
        };
        assert_ne!(ta.entry, tb.entry, "overloads must not collide");
        assert!(ta.entry.starts_with("aw_racket_swift_TestKit_scale_"));
        // Deterministic: recomputing yields the same symbol (no global counter).
        let FnDisposition::Trampoline(ta2) = classify_function("TestKit", &a, &siblings) else {
            panic!()
        };
        assert_eq!(ta.entry, ta2.entry);
    }

    #[test]
    fn constant_reader_returns_value() {
        let c = Constant {
            name: "sharedToken".into(),
            constant_type: nsstring(),
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
            s.contains("return Unmanaged.passRetained((TestKit.sharedToken) as NSString).toOpaque()"),
            "{s}"
        );
    }

    #[test]
    fn pointer_constant_returns_handle() {
        let c = Constant {
            name: "defaultConfig".into(),
            constant_type: swift_class("Config", "TestKit"),
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: false,
        };
        let t = classify_constant("TestKit", &c);
        let mut s = String::new();
        emit_const(&mut s, &t);
        assert!(s.contains("return awRacketBox((TestKit.defaultConfig) as Config)"), "{s}");
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
            checkpoint: "enriched".into(),
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
            api_patterns: vec![],
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
            swift.contains("1 function + 0 constant trampoline; deferred — 1 deferred_async."),
            "{swift}"
        );
    }
}
