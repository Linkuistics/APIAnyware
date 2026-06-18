//! Generated C-ABI trampolines for the Swift-native residual — gerbil target.
//!
//! Leaf 070/020 ports the proven trampoline mechanism (ADR-0027 racket /
//! ADR-0028 chez, spec `docs/specs/2026-06-15-racket-trampoline.md`) to gerbil,
//! the **hard case**: gerbil has no Swift dylib by design (ObjC-in-`gsc` native
//! core, ADR-0017). A trampoline *must* be Swift — only Swift can call the Swift
//! ABI — so ADR-0029 admits a small `libAPIAnywareGerbil.dylib` *for the
//! trampoline only*. For every retained `objc_exposed == false` declaration this
//! module vends a **call-by-name `@_cdecl` trampoline** in
//! `Generated/Trampolines.swift`: a C-linkable Swift function that `import`s the
//! owning framework module and calls the API by its reconstructed Swift name +
//! argument labels, letting swiftc own ABI correctness (ADR-0027 §1). The gerbil
//! emitter (`emit_functions` / `emit_constants`) binds those entries with a
//! per-signature `define-c-lambda` against the linked dylib's `aw_gerbil_swift_*`
//! entry (ADR-0017's dispatch idiom), computing the same content-addressed entry
//! name independently.
//!
//! **Hermetic duplication (ADR-0011 / ADR-0029).** The classification and Swift
//! codegen here mirror `emit-chez/src/trampoline.rs`; the targets share no native
//! substrate, so the entry prefix (`aw_gerbil_swift_`), the Swift runtime helpers
//! (`awGerbilBox` / `awGerbilUnbox` / `awGerbilTry`), and the binding rendering
//! (gerbil `define-c-lambda` + Scheme-side marshalling, ADR-0015 — *not* chez's
//! `foreign-procedure`) all diverge. The shared half is the classification
//! *taxonomy*, which is a property of the shared IR + the flat C ABI, not of any
//! target. Because the residual is a deterministic function of the shared IR, the
//! gerbil pass reproduces racket's and chez's classification **exactly** (51
//! function trampolines, 7 constants).
//!
//! **Gerbil's substantive divergence from chez (ADR-0029 §2).** chez/racket box
//! *every* non-scalar/non-string return into an opaque handle. Gerbil's ADR-0020
//! manifest class graph lets it do better: an **object** return (`Class`/`id`/
//! `instancetype`) is handed back as a raw `id` and `wrap`ped to its **exact bound
//! type** through the `register-objc-class!` registry (the same wrapping every
//! `id`-returning method already gets). Only a genuinely non-object value
//! (non-bridged `struct`, tuple, existential) rides the opaque `awGerbilBox`. So
//! the chez single `Handle` rep splits here into [`RetMarshal::Object`] (wrap) vs
//! [`RetMarshal::OpaqueBox`] (raw value handle).
//!
//! Naming is content-addressed (ADR-0013 precedent): `aw_gerbil_swift_<Fw>_<name>`,
//! with a short signature hash appended when a `(module, name)` is overloaded
//! within its framework; constants are `aw_gerbil_swift_const_<Fw>_<name>`.

use std::collections::{BTreeMap, HashSet};

use apianyware_macos_types::ir::{Constant, Framework, Function, Struct};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::{c_type_for_token, POINTER};

/// Prefix for a Swift-native **function** trampoline entry.
pub const FN_PREFIX: &str = "aw_gerbil_swift_";
/// Prefix for a Swift-native **constant** trampoline entry.
pub const CONST_PREFIX: &str = "aw_gerbil_swift_const_";

/// The gerbil FFI token for the throwing path's trailing `NSError **` out-cell.
/// `alloc-id-cell` (runtime/ffi.ss) hands back exactly this type; the C boundary
/// reduces it to `void *` (the Swift `@_cdecl` takes `UnsafeMutableRawPointer?`).
const ERR_CELL_TOKEN: &str = "(pointer (pointer void))";

// ---------------------------------------------------------------------------
// Marshalling taxonomy
// ---------------------------------------------------------------------------

/// How one value crosses the trampoline's flat C-ABI boundary, in a **parameter**
/// position. Bindable params are the constraint on trampolinability (the return
/// side has a universal rep — see [`RetMarshal`]).
#[derive(Debug, Clone, PartialEq, Eq)]
enum ArgMarshal {
    /// A C scalar passed straight through. Carries the Swift type spelled at the
    /// `@_cdecl` boundary (`Int`, `Double`, `Int32`, …).
    Scalar(Scalar),
    /// A **scalar-backed named typedef** (`CGFloat`) that `map_swift_type` lossily
    /// lowered to a `Class`/`Struct`/`Alias` even though it is a single C scalar.
    /// The `@_cdecl` receives the underlying scalar (`Double` for `CGFloat`); the
    /// body wraps it as the named type (`CGFloat(a0)`) so the by-name call
    /// type-checks against the real parameter.
    ScalarTypedef { scalar: Scalar, name: String },
    /// `Swift.String` ⇄ `NSString`. The `@_cdecl` receives an `id`; the body
    /// reconstructs `… as String` before the call. The gerbil side bridges a
    /// Scheme string to an NSString `id` with the existing `string->nsstring`.
    SwiftString,
    /// A **non-bridged Swift value struct** parameter that the owning framework
    /// defines in `Framework.structs`. Gerbil holds it as the opaque handle a
    /// prior boxed return handed it; the `@_cdecl` receives that raw pointer and
    /// the body unboxes the *named* value (`awGerbilUnbox(aN!, as: Name.self)`)
    /// before the by-name call — sound only because the name is in the struct set.
    BoxedHandle { name: String },
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
    ScalarTypedef {
        scalar: Scalar,
        name: String,
    },
    /// `Swift.String` → bridged `NSString`, returned +1-retained as an `id`; the
    /// gerbil side copies to a Scheme string and releases (Scheme-side, ADR-0015).
    SwiftString,
    /// An **ObjC/bridged object** return (`Class`/`id`/`instancetype`). The
    /// `@_cdecl` returns the raw `id` (+1-retained); the gerbil binding `wrap`s it
    /// to its exact bound type via the ADR-0020 `register-objc-class!` registry.
    /// This is gerbil's divergence from chez/racket (which box objects too).
    Object,
    /// A non-object value (non-bridged `struct`, tuple, value-backed existential,
    /// opaque `some P`) — wrapped in `awGerbilBox` and returned as an opaque
    /// handle pointer. The optional `String` is a nameable Swift return type used
    /// to disambiguate the by-name call (`(call) as CGFloat`) when the residual
    /// has cross-module return-type overloads; `None` when not safely nameable.
    OpaqueBox(Option<String>),
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

    /// The Gambit `define-c-lambda` FFI token for the crossing's arg/return list.
    /// `Int`/`UInt` are word-sized (64-bit on this target); `bool` maps a C int to
    /// `#t`/`#f` as the rest of the gerbil runtime does. These are the same tokens
    /// `GerbilFfiTypeMapper` emits for the direct bindings.
    fn gerbil(self) -> &'static str {
        match self {
            Scalar::Bool => "bool",
            Scalar::Int | Scalar::Int64 => "int64",
            Scalar::UInt | Scalar::UInt64 => "unsigned-int64",
            Scalar::Int8 => "int8",
            Scalar::UInt8 => "unsigned-int8",
            Scalar::Int16 => "int16",
            Scalar::UInt16 => "unsigned-int16",
            Scalar::Int32 => "int32",
            Scalar::UInt32 => "unsigned-int32",
            Scalar::Float => "float",
            Scalar::Double => "double",
        }
    }

    /// The `awGerbilTry` fallback literal for this scalar on the throwing path.
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

/// `map_swift_type` lowers an anonymous Swift tuple to `Class { name: "Tuple", … }`
/// — a sentinel name that cannot be spelled as a Swift type. A tuple return must
/// therefore box **unnamed** (`as Tuple` does not compile).
fn is_unspellable_type_name(name: &str) -> bool {
    name == "Tuple"
}

/// A **scalar-backed named typedef**: a Swift type that `map_swift_type` lowers to
/// a named `Class`/`Struct`/`Alias` but which is a single C scalar at the ABI, so
/// it marshals by value as that scalar rather than behind an opaque handle.
/// `CGFloat` is the dominant case in the real residual (spec §5a).
fn scalar_typedef(name: &str) -> Option<Scalar> {
    match name {
        "CGFloat" => Some(Scalar::Double),
        _ => None,
    }
}

/// Classify a param `TypeRef` into its marshalling, or the [`DeferReason`] that
/// records why it cannot be trampolined this leaf. `value_structs` is the owning
/// framework's own `Framework.structs` name set — a param whose named type is in
/// it is a Swift value struct the box round-trips (spec §5c).
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

/// Classify a return `TypeRef`. Total: every shape maps somewhere, so the return
/// never blocks trampolinability. Gerbil splits chez's single boxed `Handle` into
/// [`RetMarshal::Object`] (ObjC/bridged object → `wrap`) and
/// [`RetMarshal::OpaqueBox`] (non-object value → `awGerbilBox`).
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
        // An ObjC/bridged object (`Class`) or `id`/`instancetype` is a real ObjC
        // pointer: hand it back raw and `wrap` it Scheme-side to its exact bound
        // type (ADR-0029 §2). A genuinely-Swift class would also land here; its
        // dynamic ObjC class is unbound, so `wrap` walks to the nearest bound
        // ancestor (NSObject worst case) — never a crash.
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            RetMarshal::Object
        }
        // A typedef alias (`NSTimeInterval`) names a valid in-scope Swift type;
        // carry the name so the by-name call's result can be pinned with
        // `as <Type>` (disambiguates cross-module return-type overloads). It is a
        // value typedef, so it boxes.
        TypeRefKind::Alias { name, .. } => RetMarshal::OpaqueBox(Some(name.clone())),
        _ => RetMarshal::OpaqueBox(None),
    }
}

// ---------------------------------------------------------------------------
// Trampoline plans
// ---------------------------------------------------------------------------

/// A function the gerbil target trampolines: the resolved marshalling plan plus
/// everything both the Swift codegen and the gerbil emitter need, computed purely
/// from `(module, Function)` so the two sides agree without shared state.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FnTrampoline {
    /// Owning Swift module (the enclosing `Framework.name`) — the `import` target
    /// and the call's implicit namespace.
    pub module: String,
    /// Bare Swift function name (`Function.name`) used in the by-name call.
    pub swift_name: String,
    /// The **gerbil-visible** binding name (the `(define …)` / `export`
    /// identifier). Equal to `swift_name`, except a same-module overload carries
    /// the same content hash its `entry` does (`show_06c0f52a`) — Scheme has no
    /// overloading, so three `(define show)` would collide (spec §5c).
    pub binding_name: String,
    /// Content-addressed C entry symbol (`aw_gerbil_swift_<Fw>_<name>[_<hash>]`).
    pub entry: String,
    /// Per-param argument label (from `Param.name`); `"_"` means no label.
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    ret: RetMarshal,
    /// The Swift function `throws` — the trampoline takes a trailing `NSError **`.
    throwing: bool,
    /// The macOS version the wrapped API was `introduced:` (from IR provenance),
    /// emitted as `@available(macOS <v>, *)` on the `@_cdecl`. `None` when
    /// unversioned.
    availability: Option<String>,
}

/// A Swift-native constant the gerbil target trampolines: a `@_cdecl` reader that
/// returns the global's current value (Swift-native globals have no C symbol to
/// resolve, so even scalar ones need a reader).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConstTrampoline {
    pub module: String,
    pub swift_name: String,
    pub entry: String,
    ret: RetMarshal,
    /// `@available(macOS <v>, *)` for a version-gated global; `None` otherwise.
    availability: Option<String>,
}

/// The macOS `introduced:` version from a declaration's IR provenance, if any.
fn introduced_macos(
    provenance: &Option<apianyware_macos_types::provenance::SourceProvenance>,
) -> Option<String> {
    provenance
        .as_ref()
        .and_then(|p| p.availability.as_ref())
        .and_then(|a| a.introduced.clone())
}

/// A residual declaration that is **not** trampolined this leaf, recorded with a
/// machine-readable reason and surfaced in the pass log (spec §5).
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
    /// `async` function — runtime-ready, codegen is a follow-up.
    Async,
    /// A non-Foundation-bridged Swift struct/tuple/existential **parameter** that
    /// is a *nameable value type* (or CF/ObjC reference, or bridged collection).
    NonBridgedStructParam,
    /// A closure / function-pointer **parameter**.
    ClosureParam,
    /// A parameter that is not a nameable type at all (`id`/`Any`, a raw pointer, a
    /// selector, …).
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

/// Classify a Swift-native (`objc_exposed == false`) function. `siblings` is the
/// full residual-function set of the *same* module (used only for overload
/// disambiguation in the entry name). `value_structs` gates unboxing a
/// value-struct parameter.
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
    let labels = func.params.iter().map(|p| p.name.clone()).collect();
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

/// Sanitise a module/name fragment into a valid C-identifier tail.
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
/// function (trampolined or deferred) and constant across all frameworks.
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
                ArgMarshal::ScalarTypedef { name, .. } => format!("{name}(a{i})"),
                ArgMarshal::SwiftString => format!("s{i}"),
                ArgMarshal::BoxedHandle { .. } => format!("u{i}"),
            };
            if label == "_" || label.is_empty() {
                value
            } else {
                format!("{label}: {value}")
            }
        })
        .collect();
    // Module-qualify the call so a free function a second imported module also
    // exports is unambiguous; the owning module is always in scope (we `import` it).
    format!("{}.{}({})", t.module, t.swift_name, args.join(", "))
}

/// The `@_cdecl` parameter list (named) and the body's reconstruction prelude.
fn decl_params_and_prelude(t: &FnTrampoline) -> (Vec<String>, String) {
    let mut decl = Vec::with_capacity(t.params.len());
    let mut prelude = String::new();
    for (i, m) in t.params.iter().enumerate() {
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
                prelude.push_str(&format!(
                    "  let u{i} = awGerbilUnbox(a{i}!, as: {name}.self)\n"
                ));
            }
        }
    }
    (decl, prelude)
}

/// Marshals a call expression (`{call}`) to the `@_cdecl` boundary's C rep.
type Marshaller = Box<dyn Fn(&str) -> String>;

/// The C return type spelled at the `@_cdecl` boundary, and the success-path
/// expression that marshals `<call>` to it (with `{call}` substituted in).
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
        // Object: hand back a raw +1-retained `id`; nil-safe (an `Optional` object
        // return passes `nil` straight through). gerbil `wrap`s it Scheme-side.
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
                    Box::new(move |c: &str| format!("awGerbilBox(({c}) as {name})"))
                }
                None => Box::new(|c: &str| format!("awGerbilBox({c})")),
            },
        ),
    }
}

/// The `awGerbilTry` fallback for the throwing path, given the return rep.
fn throw_fallback(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "()",
        RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => s.fallback(),
        RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => "nil",
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
        let body = match &t.ret {
            RetMarshal::Void => format!("  _ = awGerbilTry(awErrOut, ()) {{ try {call} }}\n"),
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => format!(
                "  return awGerbilTry(awErrOut, {fb}) {{ {marshalled} }}\n",
                fb = throw_fallback(&t.ret),
                marshalled = marshal(&format!("try {call}"))
            ),
            RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => {
                let marshalled = marshal(&format!("try {call}"));
                format!("  return awGerbilTry(awErrOut, nil) {{ {marshalled} }}\n")
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
        RetMarshal::Void => s.push_str(&format!("  return awGerbilBox({read})\n")),
        _ => s.push_str(&format!("  return {}\n", marshal(&read))),
    }
    s.push_str("}\n");
}

/// Generate `Generated/Trampolines.swift`: the imports, then one `@_cdecl` per
/// trampolined function and constant. Deferred decls produce no Swift.
pub fn generate_trampolines_swift(set: &TrampolineSet) -> String {
    let mut s = String::new();
    s.push_str(
        "// Generated C-ABI trampolines for the Swift-native residual (gerbil; ADR-0029).\n",
    );
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-macos-generate` from the IR.\n");
    s.push_str("// One @_cdecl per retained `objc_exposed == false` Swift-native decl; each\n");
    s.push_str("// imports the owning framework and calls the API by name (swiftc owns ABI\n");
    s.push_str("// correctness). Bound from the generated gerbil bindings with define-c-lambda\n");
    s.push_str("// against libAPIAnywareGerbil. See:\n");
    s.push_str("//   docs/specs/2026-06-15-racket-trampoline.md (mechanism, ported to gerbil)\n");
    s.push_str("//   docs/adr/0029-gerbil-trampoline-grows-a-swift-dylib.md\n\n");
    s.push_str("import Foundation\n");

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
// Gerbil binding rendering (consumed by emit_functions / emit_constants)
// ---------------------------------------------------------------------------

/// The internal `%swift-<binding>` crossing identifier — the `define-c-lambda`
/// that calls the dylib entry; the outer `(define <binding> …)` wraps it.
fn fn_crossing_name(binding_name: &str) -> String {
    format!("%swift-{binding_name}")
}

/// One emitted gerbil FFI crossing: the `(c-declare "extern …;")` prototype
/// (ADR-0021 — declare, never `#include`), the `define-c-lambda` line binding it,
/// and whether any slot is `bool` (so the module pulls in `<stdbool.h>`).
pub struct Crossing {
    pub proto: String,
    pub define_c_lambda: String,
    pub needs_stdbool: bool,
}

impl FnTrampoline {
    /// The gerbil FFI token + C type for each visible param, plus the trailing
    /// `NSError **` cell when the function `throws` (spec §4).
    fn arg_reps(&self) -> Vec<(&'static str, &'static str)> {
        let mut v: Vec<(&'static str, &'static str)> = self
            .params
            .iter()
            .map(|m| match m {
                ArgMarshal::Scalar(s) | ArgMarshal::ScalarTypedef { scalar: s, .. } => {
                    (s.gerbil(), c_type_for_token(s.gerbil()))
                }
                ArgMarshal::SwiftString | ArgMarshal::BoxedHandle { .. } => (POINTER, "void *"),
            })
            .collect();
        if self.throwing {
            v.push((ERR_CELL_TOKEN, "void *")); // NSError** out-cell
        }
        v
    }

    /// The gerbil FFI return token + C type.
    fn ret_rep(&self) -> (&'static str, &'static str) {
        match &self.ret {
            RetMarshal::Void => ("void", "void"),
            RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => {
                (s.gerbil(), c_type_for_token(s.gerbil()))
            }
            RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => {
                (POINTER, "void *")
            }
        }
    }

    /// The FFI crossing for this trampoline — the `extern` prototype + the
    /// `define-c-lambda` that binds the dylib entry, both emitted into the
    /// trampoline `begin-ffi` block.
    pub fn crossing(&self) -> Crossing {
        let args = self.arg_reps();
        let (ret_tok, ret_c) = self.ret_rep();
        let proto_args = if args.is_empty() {
            "void".to_string()
        } else {
            args.iter()
                .map(|(_, c)| (*c).to_string())
                .collect::<Vec<_>>()
                .join(", ")
        };
        let arg_tokens = args
            .iter()
            .map(|(t, _)| (*t).to_string())
            .collect::<Vec<_>>()
            .join(" ");
        Crossing {
            proto: format!("extern {} {}({});", ret_c, self.entry, proto_args),
            define_c_lambda: format!(
                "(define-c-lambda {} ({}) {} \"{}\")",
                fn_crossing_name(&self.binding_name),
                arg_tokens,
                ret_tok,
                self.entry
            ),
            needs_stdbool: args.iter().any(|(t, _)| *t == "bool") || ret_tok == "bool",
        }
    }

    /// Whether the binding needs the runtime helpers / wrap (string in/out,
    /// object wrap, or throws). A pure scalar / opaque-box binding is a bare alias
    /// to the crossing.
    fn needs_runtime(&self) -> bool {
        self.throwing
            || matches!(self.ret, RetMarshal::SwiftString | RetMarshal::Object)
            || self
                .params
                .iter()
                .any(|m| matches!(m, ArgMarshal::SwiftString | ArgMarshal::BoxedHandle { .. }))
    }

    /// Render the outer `(define <binding> …)` form. A pure-scalar / opaque-box
    /// crossing with no arg coercion is a bare alias; otherwise a lambda that
    /// coerces args in, calls the crossing, and wraps the result out.
    pub fn render_binding(&self) -> String {
        let crossing = fn_crossing_name(&self.binding_name);
        let arg_names: Vec<String> = (0..self.params.len()).map(|i| format!("a{i}")).collect();
        let coerced_args: Vec<String> = self
            .params
            .iter()
            .zip(&arg_names)
            .map(|(m, a)| match m {
                ArgMarshal::SwiftString => format!("(aw-swift-string-arg {a})"),
                ArgMarshal::BoxedHandle { .. } => format!("(->ptr {a})"),
                ArgMarshal::Scalar(_) | ArgMarshal::ScalarTypedef { .. } => a.clone(),
            })
            .collect();
        let lambda_params = arg_names.join(" ");
        let args_joined = coerced_args.join(" ");
        let maybe_space = if coerced_args.is_empty() { "" } else { " " };

        if self.throwing {
            // Route through the error cell: `call` takes the NSError** cell as its
            // trailing arg; on a written error `aw-swift-call/error` raises, else
            // it applies `coerce` to the success result.
            let coerce = match &self.ret {
                RetMarshal::SwiftString => "aw-swift-string-result".to_string(),
                RetMarshal::Object => "(lambda (p) (wrap p #t))".to_string(),
                _ => "values".to_string(),
            };
            return format!(
                "(define {name}\n  \
                 (lambda ({lambda_params})\n    \
                 (aw-swift-call/error\n      \
                 (lambda (%err) ({crossing}{maybe_space}{args_joined} %err))\n      \
                 {coerce})))",
                name = self.binding_name,
            );
        }

        if !self.needs_runtime() && self.params.is_empty() {
            // Pure passthrough, no args — alias the crossing directly.
            return format!("(define {} {})", self.binding_name, crossing);
        }

        let call = format!("({crossing}{maybe_space}{args_joined})");
        let body = match &self.ret {
            RetMarshal::SwiftString => format!("(aw-swift-string-result {call})"),
            RetMarshal::Object => format!("(wrap {call} #t)"),
            _ => call,
        };
        format!(
            "(define {name}\n  (lambda ({lambda_params})\n    {body}))",
            name = self.binding_name,
        )
    }
}

impl ConstTrampoline {
    fn ret_rep(&self) -> (&'static str, &'static str) {
        match &self.ret {
            RetMarshal::Void => (POINTER, "void *"),
            RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => {
                (s.gerbil(), c_type_for_token(s.gerbil()))
            }
            RetMarshal::SwiftString | RetMarshal::Object | RetMarshal::OpaqueBox(_) => {
                (POINTER, "void *")
            }
        }
    }

    /// The `%swift-const-<name>` crossing identifier.
    fn crossing_name(&self) -> String {
        format!("%swift-const-{}", self.swift_name)
    }

    /// The FFI crossing for this constant trampoline (zero-arg reader).
    pub fn crossing(&self) -> Crossing {
        let (ret_tok, ret_c) = self.ret_rep();
        Crossing {
            proto: format!("extern {} {}(void);", ret_c, self.entry),
            define_c_lambda: format!(
                "(define-c-lambda {} () {} \"{}\")",
                self.crossing_name(),
                ret_tok,
                self.entry
            ),
            needs_stdbool: ret_tok == "bool",
        }
    }

    /// Render the outer `(define <name> …)` form — the global read, evaluated once
    /// at load (mirroring the `%const-…` direct constants), wrapped per its rep.
    pub fn render_binding(&self) -> String {
        let read = format!("({})", self.crossing_name());
        let body = match &self.ret {
            RetMarshal::SwiftString => format!("(aw-swift-string-result {read})"),
            RetMarshal::Object => format!("(wrap {read} #t)"),
            _ => read,
        };
        format!("(define {} {})", self.swift_name, body)
    }
}

/// Does this binding's outer form reference the runtime helpers at all (object
/// wrap, string coercion, or throws)? Used by the emitter to decide whether the
/// pure-scalar fast path (a bare alias to the crossing) applies.
pub fn fn_needs_runtime(t: &FnTrampoline) -> bool {
    t.needs_runtime()
}

/// Does this function binding reference `wrap` / `->ptr` (the `objc` runtime)?
/// True for an object return (wrap to the bound type) or a value-struct handle
/// param (passed via `->ptr`).
pub fn fn_needs_objc(t: &FnTrampoline) -> bool {
    matches!(t.ret, RetMarshal::Object)
        || t.params
            .iter()
            .any(|m| matches!(m, ArgMarshal::BoxedHandle { .. }))
}

/// Does this function binding reference the `aw-swift-*` helpers
/// (`:gerbil-bindings/runtime/swift-trampoline`)? True for a `String` in/out or a
/// `throws` shape.
pub fn fn_needs_swift_helpers(t: &FnTrampoline) -> bool {
    t.throwing
        || matches!(t.ret, RetMarshal::SwiftString)
        || t.params
            .iter()
            .any(|m| matches!(m, ArgMarshal::SwiftString))
}

/// Does this constant binding reference `wrap` (the `objc` runtime)? True for an
/// object-typed global.
pub fn const_needs_objc(t: &ConstTrampoline) -> bool {
    matches!(t.ret, RetMarshal::Object)
}

/// Does this constant binding reference the `aw-swift-*` helpers? True for a
/// `String`-typed global.
pub fn const_needs_swift_helpers(t: &ConstTrampoline) -> bool {
    matches!(t.ret, RetMarshal::SwiftString)
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
    fn class(name: &str, fw: &str) -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: name.into(),
                framework: Some(fw.into()),
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

    fn tramp(module: &str, f: &Function, structs: &HashSet<&str>) -> FnTrampoline {
        match classify_function(module, f, std::slice::from_ref(f), structs) {
            FnDisposition::Trampoline(t) => t,
            FnDisposition::Deferred(_) => panic!("expected trampoline"),
        }
    }

    #[test]
    fn scalar_function_aliases_the_crossing() {
        let f = swift_func(
            "timestampSeed",
            vec![],
            prim("int64"),
            SwiftFnInfo::default(),
        );
        let t = tramp("CreateML", &f, &no_structs());
        assert_eq!(t.entry, "aw_gerbil_swift_CreateML_timestampSeed");
        let cx = t.crossing();
        assert_eq!(
            cx.define_c_lambda,
            "(define-c-lambda %swift-timestampSeed () int64 \"aw_gerbil_swift_CreateML_timestampSeed\")"
        );
        assert_eq!(
            cx.proto,
            "extern long long aw_gerbil_swift_CreateML_timestampSeed(void);"
        );
        // Pure scalar, zero args → bare alias.
        assert_eq!(
            t.render_binding(),
            "(define timestampSeed %swift-timestampSeed)"
        );
        assert!(!fn_needs_runtime(&t));
    }

    #[test]
    fn scalar_args_map_to_gerbil_tokens() {
        let f = swift_func(
            "scale",
            vec![
                param("_", prim("double")),
                param("by", prim("int32")),
                param("flag", prim("bool")),
            ],
            prim("double"),
            SwiftFnInfo::default(),
        );
        let t = tramp("TestKit", &f, &no_structs());
        let cx = t.crossing();
        assert_eq!(
            cx.define_c_lambda,
            "(define-c-lambda %swift-scale (double int32 bool) double \"aw_gerbil_swift_TestKit_scale\")"
        );
        assert_eq!(
            cx.proto,
            "extern double aw_gerbil_swift_TestKit_scale(double, int, bool);"
        );
        assert!(cx.needs_stdbool);
        // Scalar args still pass straight through, but there ARE args → lambda.
        assert_eq!(
            t.render_binding(),
            "(define scale\n  (lambda (a0 a1 a2)\n    (%swift-scale a0 a1 a2)))"
        );
    }

    #[test]
    fn swift_string_function_uses_scheme_side_coercers() {
        let f = swift_func(
            "greeting",
            vec![param("for", nsstring())],
            nsstring(),
            SwiftFnInfo::default(),
        );
        let t = tramp("TestKit", &f, &no_structs());
        let cx = t.crossing();
        // Both String slots cross as opaque pointers.
        assert_eq!(
            cx.define_c_lambda,
            "(define-c-lambda %swift-greeting ((pointer void)) (pointer void) \"aw_gerbil_swift_TestKit_greeting\")"
        );
        let out = t.render_binding();
        assert!(out.contains("(aw-swift-string-arg a0)"), "{out}");
        assert!(
            out.contains("(aw-swift-string-result (%swift-greeting (aw-swift-string-arg a0)))"),
            "{out}"
        );
        assert!(fn_needs_runtime(&t));
    }

    #[test]
    fn object_return_wraps_to_exact_bound_type() {
        // gerbil's substantive divergence (ADR-0029 §2): an object return is a raw
        // id wrapped to its exact bound type, NOT a boxed opaque handle.
        let f = swift_func(
            "makeWidget",
            vec![],
            class("TKWidget", "TestKit"),
            SwiftFnInfo::default(),
        );
        let t = tramp("TestKit", &f, &no_structs());
        // Crossing returns a raw pointer.
        assert_eq!(
            t.crossing().define_c_lambda,
            "(define-c-lambda %swift-makeWidget () (pointer void) \"aw_gerbil_swift_TestKit_makeWidget\")"
        );
        // Outer binding WRAPS (retained), it does not hand back a raw pointer.
        let out = t.render_binding();
        assert!(
            out.contains("(wrap (%swift-makeWidget) #t)"),
            "object return must wrap:\n{out}"
        );
        assert!(fn_needs_runtime(&t));
        // Swift codegen hands back a raw +1-retained id (not awGerbilBox).
        let mut set = TrampolineSet::default();
        set.functions.push(t);
        let swift = generate_trampolines_swift(&set);
        assert!(
            swift.contains("Unmanaged.passRetained($0).toOpaque()"),
            "{swift}"
        );
        assert!(
            !swift.contains("awGerbilBox"),
            "object must not box:\n{swift}"
        );
    }

    #[test]
    fn nonobject_value_return_boxes_opaque() {
        // A non-bridged value struct return boxes through awGerbilBox and the
        // gerbil side holds the raw handle (no wrap).
        let f = swift_func(
            "makeTuple",
            vec![],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Struct {
                    name: "Tuple".into(),
                },
            },
            SwiftFnInfo::default(),
        );
        let t = tramp("TestKit", &f, &no_structs());
        // Raw handle passthrough — no wrap, no runtime helpers.
        assert_eq!(t.render_binding(), "(define makeTuple %swift-makeTuple)");
        assert!(!fn_needs_runtime(&t));
        let mut set = TrampolineSet::default();
        set.functions.push(t);
        let swift = generate_trampolines_swift(&set);
        assert!(
            swift.contains("awGerbilBox("),
            "value return must box:\n{swift}"
        );
    }

    #[test]
    fn throwing_function_threads_error_cell() {
        let f = swift_func(
            "validate",
            vec![param("_", prim("int64"))],
            prim("bool"),
            SwiftFnInfo {
                throwing: true,
                ..Default::default()
            },
        );
        let t = tramp("TestKit", &f, &no_structs());
        let cx = t.crossing();
        // The crossing carries a trailing NSError** out-cell (void* at the C ABI).
        assert_eq!(
            cx.define_c_lambda,
            "(define-c-lambda %swift-validate (int64 (pointer (pointer void))) bool \"aw_gerbil_swift_TestKit_validate\")"
        );
        assert_eq!(
            cx.proto,
            "extern bool aw_gerbil_swift_TestKit_validate(long long, void *);"
        );
        let out = t.render_binding();
        assert!(out.contains("aw-swift-call/error"), "{out}");
        assert!(
            out.contains("(lambda (%err) (%swift-validate a0 %err))"),
            "{out}"
        );
        assert!(fn_needs_runtime(&t));
    }

    #[test]
    fn value_struct_param_unboxes_through_the_handle() {
        let value_struct = Struct {
            name: "TKColumn".into(),
            fields: vec![],
            methods: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
        };
        let f = swift_func(
            "summarize",
            vec![param("_", class("TKColumn", "TestKit"))],
            prim("int64"),
            SwiftFnInfo::default(),
        );
        let structs = value_struct_names(std::slice::from_ref(&value_struct));
        let t = tramp("TestKit", &f, &structs);
        // The handle param crosses as a pointer; the binding passes it via ->ptr.
        assert_eq!(
            t.crossing().define_c_lambda,
            "(define-c-lambda %swift-summarize ((pointer void)) int64 \"aw_gerbil_swift_TestKit_summarize\")"
        );
        assert!(t.render_binding().contains("(%swift-summarize (->ptr a0))"));
        // The Swift body unboxes the named value struct.
        let mut set = TrampolineSet::default();
        set.functions.push(t);
        let swift = generate_trampolines_swift(&set);
        assert!(
            swift.contains("awGerbilUnbox(a0!, as: TKColumn.self)"),
            "{swift}"
        );
        // Without the struct set, it defers as a non-bridged struct param.
        assert!(matches!(
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs()),
            FnDisposition::Deferred(DeferReason::NonBridgedStructParam)
        ));
    }

    #[test]
    fn generic_and_async_defer_with_reasons() {
        let g = swift_func(
            "mapAll",
            vec![],
            prim("void"),
            SwiftFnInfo {
                is_generic: true,
                ..Default::default()
            },
        );
        let a = swift_func(
            "fetch",
            vec![],
            prim("void"),
            SwiftFnInfo {
                is_async: true,
                ..Default::default()
            },
        );
        assert!(matches!(
            classify_function("M", &g, std::slice::from_ref(&g), &no_structs()),
            FnDisposition::Deferred(DeferReason::UnbindableGenericFreeFunction)
        ));
        assert!(matches!(
            classify_function("M", &a, std::slice::from_ref(&a), &no_structs()),
            FnDisposition::Deferred(DeferReason::Async)
        ));
    }

    #[test]
    fn overloads_get_distinct_content_addressed_entries_and_bindings() {
        let a = swift_func(
            "show",
            vec![param("_", prim("int64"))],
            prim("void"),
            SwiftFnInfo::default(),
        );
        let b = swift_func(
            "show",
            vec![param("_", prim("double"))],
            prim("void"),
            SwiftFnInfo::default(),
        );
        let siblings = vec![a.clone(), b.clone()];
        let FnDisposition::Trampoline(ta) = classify_function("M", &a, &siblings, &no_structs())
        else {
            panic!()
        };
        let FnDisposition::Trampoline(tb) = classify_function("M", &b, &siblings, &no_structs())
        else {
            panic!()
        };
        assert_ne!(ta.entry, tb.entry, "overloads need distinct C entries");
        assert_ne!(
            ta.binding_name, tb.binding_name,
            "overloads need distinct gerbil names"
        );
        assert!(ta.binding_name.starts_with("show_"), "{}", ta.binding_name);
        // The crossing name carries the disambiguated binding name.
        assert!(ta
            .crossing()
            .define_c_lambda
            .contains(&format!("%swift-{}", ta.binding_name)));
    }

    #[test]
    fn swift_codegen_calls_by_name_and_imports_owning_module() {
        let f = swift_func(
            "timestampSeed",
            vec![],
            prim("int64"),
            SwiftFnInfo::default(),
        );
        let mut set = TrampolineSet::default();
        set.functions.push(tramp("CreateML", &f, &no_structs()));
        let swift = generate_trampolines_swift(&set);
        assert!(swift.contains("import CreateML"), "{swift}");
        assert!(
            swift.contains("@_cdecl(\"aw_gerbil_swift_CreateML_timestampSeed\")"),
            "{swift}"
        );
        assert!(swift.contains("return CreateML.timestampSeed()"), "{swift}");
        assert!(
            swift.contains("1 function + 0 constant trampoline."),
            "{swift}"
        );
    }

    #[test]
    fn string_constant_reads_through_scheme_side_coercion() {
        let c = Constant {
            name: "MLCreateErrorDomain".into(),
            constant_type: nsstring(),
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: false,
        };
        let t = classify_constant("CreateML", &c);
        assert_eq!(
            t.entry,
            "aw_gerbil_swift_const_CreateML_MLCreateErrorDomain"
        );
        let cx = t.crossing();
        assert_eq!(
            cx.define_c_lambda,
            "(define-c-lambda %swift-const-MLCreateErrorDomain () (pointer void) \"aw_gerbil_swift_const_CreateML_MLCreateErrorDomain\")"
        );
        assert_eq!(
            t.render_binding(),
            "(define MLCreateErrorDomain (aw-swift-string-result (%swift-const-MLCreateErrorDomain)))"
        );
        assert!(const_needs_swift_helpers(&t));
    }

    #[test]
    fn scalar_constant_reads_by_value() {
        let c = Constant {
            name: "MLDefaultTimeout".into(),
            constant_type: prim("double"),
            source: None,
            provenance: None,
            doc_refs: None,
            macro_value: None,
            objc_exposed: false,
        };
        let t = classify_constant("CreateML", &c);
        assert_eq!(
            t.render_binding(),
            "(define MLDefaultTimeout (%swift-const-MLDefaultTimeout))"
        );
        assert!(!const_needs_swift_helpers(&t));
    }

    #[test]
    fn collect_skips_objc_exposed_and_keeps_residual() {
        let mut fw = Framework {
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
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            api_patterns: vec![],
            enrichment: None,
            verification: None,
        };
        let mut direct = swift_func("TKDirect", vec![], prim("void"), SwiftFnInfo::default());
        direct.objc_exposed = true;
        direct.swift_fn = None;
        fw.functions.push(direct);
        fw.functions.push(swift_func(
            "seed",
            vec![],
            prim("int64"),
            SwiftFnInfo::default(),
        ));
        let set = collect_trampolines(std::slice::from_ref(&fw));
        assert_eq!(set.functions.len(), 1);
        assert_eq!(set.functions[0].swift_name, "seed");
    }
}
