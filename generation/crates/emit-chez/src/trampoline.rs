//! Generated C-ABI trampolines for the Swift-native residual — chez target.
//!
//! Leaf 060 ports the proven racket trampoline mechanism (ADR-0027 + spec
//! `docs/specs/2026-06-15-racket-trampoline.md`) to chez. 030 made the
//! direct-vs-trampoline boundary an explicit IR fact (`objc_exposed`, ADR-0026)
//! and *retained* top-level Swift-native (`s:` USR) functions/constants instead of
//! dropping them. This module is the chez target acting on that fact: for every
//! retained `objc_exposed == false` declaration it vends a **call-by-name
//! `@_cdecl` trampoline** in `Generated/Trampolines.swift` — a C-linkable Swift
//! function that `import`s the owning framework module and calls the API by its
//! reconstructed Swift name + argument labels, letting swiftc own ABI correctness
//! (ADR-0027 §1). The chez emitter (`emit_functions` / `emit_constants`) binds
//! those entries with a plain `foreign-procedure` against the already-loaded
//! `libAPIAnywareChez.dylib`, computing the same content-addressed entry name
//! independently.
//!
//! **Hermetic duplication (ADR-0011).** The classification and Swift codegen here
//! mirror `emit-racket/src/trampoline.rs`; the targets share no native substrate,
//! so the entry prefix (`aw_chez_swift_`), the Swift runtime helpers (`awChezBox`
//! / `awChezUnbox` / `awChezTry`), and the binding rendering (chez
//! `foreign-procedure` + Scheme-side marshalling, ADR-0015 — *not* racket's native
//! coercers) all diverge. The shared half is the classification *taxonomy*, which
//! is a property of the shared IR + the flat C ABI, not of either target. See the
//! ADR-0011 call recorded in this leaf's brief.
//!
//! **Marshalling taxonomy (spec §3 / §5, identical residual — same shared IR).**
//! `map_swift_type` already normalises Swift value types into the ObjC-bridged
//! vocabulary (`String`→`NSString`, `Int`→`int64`, …), so the bindable half falls
//! out of the existing `TypeRef`:
//!
//! - **Return** has a universal safe rep: a scalar/`Bool` returns directly, a
//!   `String` bridges to a chez string (Scheme-side), and anything else is wrapped
//!   in the generic `awChezBox` opaque handle — the return type never has to be
//!   *named* in generated Swift.
//! - **Params** are the constraint: a scalar/`Bool`/`String` param binds; a value
//!   struct the owning framework defines (`MLTensor`) is unboxed from the opaque
//!   handle chez holds (`awChezUnbox(aN!, as: Name.self)`); a CF/ObjC reference, a
//!   closure, or an `id`/`Any` param is deferred with a reason and counted.
//! - **`throws`** → a trailing `NSError **` out-param run through `awChezTry`.
//! - **`async`** and **generic free functions** are recorded with a reason + count,
//!   never silently dropped (spec §5).
//!
//! Naming is content-addressed (ADR-0013 precedent): `aw_chez_swift_<Fw>_<name>`,
//! with a short signature hash appended when a `(module, name)` is overloaded
//! within its framework; constants are `aw_chez_swift_const_<Fw>_<name>`.

use std::collections::{BTreeMap, HashSet};

use apianyware_macos_types::ir::{Constant, Framework, Function, Struct};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

/// Prefix for a Swift-native **function** trampoline entry.
pub const FN_PREFIX: &str = "aw_chez_swift_";
/// Prefix for a Swift-native **constant** trampoline entry.
pub const CONST_PREFIX: &str = "aw_chez_swift_const_";

// ---------------------------------------------------------------------------
// Marshalling taxonomy
// ---------------------------------------------------------------------------

/// How one value crosses the trampoline's flat C-ABI boundary, in a **parameter**
/// position. Bindable params are the constraint on trampolinability (the return
/// side has a universal boxed rep — see [`RetMarshal`]).
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
    /// reconstructs `… as String` before the call.
    SwiftString,
    /// A **non-bridged Swift value struct** parameter that the owning framework
    /// defines in `Framework.structs`. Chez holds it as the opaque handle a prior
    /// boxed return handed it; the `@_cdecl` receives that raw pointer and the body
    /// unboxes the *named* value (`awChezUnbox(aN!, as: Name.self)`) before the
    /// by-name call — sound only because the name is in the struct set.
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
    ScalarTypedef { scalar: Scalar, name: String },
    /// `Swift.String` → bridged `NSString`, returned +1-retained as an `id`; the
    /// chez side copies to a string and releases (Scheme-side, ADR-0015).
    SwiftString,
    /// Anything else (non-bridged struct, object, tuple, existential, …) — wrapped
    /// in `awChezBox` and returned as an opaque handle pointer. The optional
    /// `String` is a nameable Swift return type used to disambiguate the by-name
    /// call (`(call) as CGFloat`) when the residual has cross-module return-type
    /// overloads; `None` when the return type is not safely nameable.
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

    /// The Chez `foreign-procedure` type token for the binding's arg/return list.
    /// `Int`/`UInt` are word-sized (64-bit on this target); `boolean` maps a C int
    /// to `#t`/`#f` as the rest of the chez runtime does.
    fn chez(self) -> &'static str {
        match self {
            Scalar::Bool => "boolean",
            Scalar::Int | Scalar::Int64 => "integer-64",
            Scalar::UInt | Scalar::UInt64 => "unsigned-64",
            Scalar::Int8 => "integer-8",
            Scalar::UInt8 => "unsigned-8",
            Scalar::Int16 => "integer-16",
            Scalar::UInt16 => "unsigned-16",
            Scalar::Int32 => "integer-32",
            Scalar::UInt32 => "unsigned-32",
            Scalar::Float => "single-float",
            Scalar::Double => "double-float",
        }
    }

    /// The `awChezTry` fallback literal for this scalar on the throwing path.
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

/// Classify a return `TypeRef`. Total: every shape maps somewhere (the boxed
/// handle is the universal fallback), so the return never blocks trampolinability.
fn classify_return(t: &TypeRef) -> RetMarshal {
    if is_swift_string(t) {
        return RetMarshal::SwiftString;
    }
    match &t.kind {
        TypeRefKind::Primitive { name } => match scalar_of_primitive(name) {
            Some(s) => RetMarshal::Scalar(s),
            None if normalize_primitive(name) == "void" => RetMarshal::Void,
            None => RetMarshal::Handle(None),
        },
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
        TypeRefKind::Alias { name, .. }
        | TypeRefKind::Class { name, .. }
        | TypeRefKind::Struct { name }
            if is_unspellable_type_name(name) =>
        {
            RetMarshal::Handle(None)
        }
        TypeRefKind::Alias { name, .. } | TypeRefKind::Class { name, .. } => {
            RetMarshal::Handle(Some(name.clone()))
        }
        _ => RetMarshal::Handle(None),
    }
}

// ---------------------------------------------------------------------------
// Trampoline plans
// ---------------------------------------------------------------------------

/// A function the chez target trampolines: the resolved marshalling plan plus
/// everything both the Swift codegen and the chez emitter need, computed purely
/// from `(module, Function)` so the two sides agree without shared state.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FnTrampoline {
    /// Owning Swift module (the enclosing `Framework.name`) — the `import` target
    /// and the call's implicit namespace.
    pub module: String,
    /// Bare Swift function name (`Function.name`) used in the by-name call.
    pub swift_name: String,
    /// The **chez-visible** binding name (the `(define …)` / `export` identifier).
    /// Equal to `swift_name`, except a same-module overload carries the same content
    /// hash its `entry` does (`show_06c0f52a`) — Scheme has no overloading, so
    /// three `(define show)` would collide (spec §5c).
    pub binding_name: String,
    /// Content-addressed C entry symbol (`aw_chez_swift_<Fw>_<name>[_<hash>]`).
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

/// A Swift-native constant the chez target trampolines: a `@_cdecl` reader that
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
    /// A non-Foundation-bridged Swift struct/tuple/existential **parameter** that is
    /// a *nameable value type* (or CF/ObjC reference, or bridged collection).
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
                    "  let u{i} = awChezUnbox(a{i}!, as: {name}.self)\n"
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
        RetMarshal::Handle(ty) => (
            "UnsafeMutableRawPointer?".to_string(),
            match ty {
                Some(name) => {
                    let name = name.clone();
                    Box::new(move |c: &str| format!("awChezBox(({c}) as {name})"))
                }
                None => Box::new(|c: &str| format!("awChezBox({c})")),
            },
        ),
    }
}

/// The `awChezTry` fallback for the throwing path, given the return rep.
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
        let body = match &t.ret {
            RetMarshal::Void => format!("  _ = awChezTry(awErrOut, ()) {{ try {call} }}\n"),
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => format!(
                "  return awChezTry(awErrOut, {fb}) {{ {marshalled} }}\n",
                fb = throw_fallback(&t.ret),
                marshalled = marshal(&format!("try {call}"))
            ),
            RetMarshal::SwiftString | RetMarshal::Handle(_) => {
                let marshalled = marshal(&format!("try {call}"));
                format!("  return awChezTry(awErrOut, nil) {{ Optional({marshalled}) }}\n")
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
        RetMarshal::Void => s.push_str(&format!("  return awChezBox({read})\n")),
        _ => s.push_str(&format!("  return {}\n", marshal(&read))),
    }
    s.push_str("}\n");
}

/// Generate `Generated/Trampolines.swift`: the imports, then one `@_cdecl` per
/// trampolined function and constant. Deferred decls produce no Swift.
pub fn generate_trampolines_swift(set: &TrampolineSet) -> String {
    let mut s = String::new();
    s.push_str("// Generated C-ABI trampolines for the Swift-native residual (chez; ADR-0027).\n");
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-macos-generate` from the IR.\n");
    s.push_str("// One @_cdecl per retained `objc_exposed == false` Swift-native decl; each\n");
    s.push_str("// imports the owning framework and calls the API by name (swiftc owns ABI\n");
    s.push_str("// correctness). Bound from the generated chez bindings with foreign-procedure\n");
    s.push_str("// against libAPIAnywareChez. See:\n");
    s.push_str("//   docs/specs/2026-06-15-racket-trampoline.md (mechanism, ported to chez)\n");
    s.push_str("//   docs/adr/0027-racket-trampoline-structure.md\n\n");
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
// Chez binding rendering (consumed by emit_functions / emit_constants)
// ---------------------------------------------------------------------------

/// The chez `foreign-procedure` return-type token for a return marshalling.
fn chez_ret_token(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "void",
        RetMarshal::Scalar(s) | RetMarshal::ScalarTypedef { scalar: s, .. } => s.chez(),
        // A bridged NSString id and an opaque value handle both cross as a pointer.
        RetMarshal::SwiftString | RetMarshal::Handle(_) => "void*",
    }
}

impl FnTrampoline {
    /// The chez `foreign-procedure` argument-type tokens, including the trailing
    /// `void*` error out-buffer when the function `throws` (spec §4).
    fn chez_arg_tokens(&self) -> Vec<&'static str> {
        let mut parts: Vec<&'static str> = self
            .params
            .iter()
            .map(|m| match m {
                ArgMarshal::Scalar(s) | ArgMarshal::ScalarTypedef { scalar: s, .. } => s.chez(),
                ArgMarshal::SwiftString | ArgMarshal::BoxedHandle { .. } => "void*",
            })
            .collect();
        if self.throwing {
            parts.push("void*"); // NSError** out-buffer
        }
        parts
    }

    /// Whether the binding needs a coercion wrapper (string in/out or throws);
    /// a pure-scalar / handle binding is the bare `foreign-procedure`.
    fn needs_wrapper(&self) -> bool {
        self.throwing
            || matches!(self.ret, RetMarshal::SwiftString)
            || self.params.contains(&ArgMarshal::SwiftString)
    }

    /// Render the `(define <name> …)` chez binding against the chez dylib.
    pub fn render_chez(&self) -> String {
        let fp = format!(
            "(foreign-procedure \"{}\" ({}) {})",
            self.entry,
            self.chez_arg_tokens().join(" "),
            chez_ret_token(&self.ret),
        );
        if !self.needs_wrapper() {
            // Bare foreign procedure — scalars/handle pass straight through.
            return format!("(define {} {})", self.binding_name, fp);
        }

        let arg_names: Vec<String> = (0..self.params.len()).map(|i| format!("a{i}")).collect();
        // Each positional argument, with `String` args bridged to an NSString id.
        let call_args: Vec<String> = self
            .params
            .iter()
            .zip(&arg_names)
            .map(|(m, a)| match m {
                ArgMarshal::SwiftString => format!("(aw-string-arg {a})"),
                ArgMarshal::Scalar(_)
                | ArgMarshal::ScalarTypedef { .. }
                | ArgMarshal::BoxedHandle { .. } => a.clone(),
            })
            .collect();
        let lambda_params = arg_names.join(" ");

        if self.throwing {
            // `aw-call/error` allocates the NSError** cell, calls, raises on error,
            // else coerces the success result.
            let coerce = match self.ret {
                RetMarshal::SwiftString => "aw-string-result",
                _ => "values",
            };
            let maybe_space = if call_args.is_empty() { "" } else { " " };
            format!(
                "(define {name}\n  \
                 (let ([%raw {fp}])\n    \
                 (lambda ({lambda_params})\n      \
                 (aw-call/error %raw {coerce}{maybe_space}{args}))))",
                name = self.binding_name,
                args = call_args.join(" "),
            )
        } else {
            // Non-throwing string coercion: bridge args in, coerce result out.
            let body = match self.ret {
                RetMarshal::SwiftString => {
                    format!("(aw-string-result (%raw {}))", call_args.join(" "))
                }
                _ => format!("(%raw {})", call_args.join(" ")),
            };
            format!(
                "(define {name}\n  \
                 (let ([%raw {fp}])\n    \
                 (lambda ({lambda_params})\n      {body})))",
                name = self.binding_name,
            )
        }
    }
}

impl ConstTrampoline {
    /// Render the `(define <name> …)` chez binding — a zero-arg reader of the Swift
    /// global, evaluated once at load (mirroring the `foreign-ref` constants it
    /// replaces), with `String` results coerced Scheme-side.
    pub fn render_chez(&self) -> String {
        let fp = format!(
            "(foreign-procedure \"{}\" () {})",
            self.entry,
            chez_ret_token(&self.ret),
        );
        match self.ret {
            RetMarshal::SwiftString => {
                format!("(define {} (aw-string-result ({})))", self.swift_name, fp)
            }
            _ => format!("(define {} ({}))", self.swift_name, fp),
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

    #[test]
    fn scalar_function_renders_bare_foreign_procedure() {
        let f = swift_func(
            "timestampSeed",
            vec![],
            prim("int64"),
            SwiftFnInfo::default(),
        );
        let FnDisposition::Trampoline(t) =
            classify_function("CreateML", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!("expected trampoline");
        };
        assert_eq!(t.entry, "aw_chez_swift_CreateML_timestampSeed");
        assert_eq!(
            t.render_chez(),
            "(define timestampSeed (foreign-procedure \"aw_chez_swift_CreateML_timestampSeed\" () integer-64))"
        );
    }

    #[test]
    fn scalar_args_map_to_chez_tokens() {
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
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!();
        };
        assert_eq!(
            t.render_chez(),
            "(define scale (foreign-procedure \"aw_chez_swift_TestKit_scale\" (double-float integer-32 boolean) double-float))"
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
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!();
        };
        let out = t.render_chez();
        // String arg bridged in, string result coerced out — both Scheme-side.
        assert!(out.contains("(aw-string-arg a0)"), "{out}");
        assert!(out.contains("(aw-string-result (%raw (aw-string-arg a0)))"), "{out}");
        // The C-ABI rep for both is a pointer.
        assert!(
            out.contains("(foreign-procedure \"aw_chez_swift_TestKit_greeting\" (void*) void*)"),
            "{out}"
        );
    }

    #[test]
    fn throwing_function_threads_error_out_param() {
        let f = swift_func(
            "validate",
            vec![param("_", prim("int64"))],
            prim("bool"),
            SwiftFnInfo {
                throwing: true,
                ..Default::default()
            },
        );
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!();
        };
        let out = t.render_chez();
        // The foreign-procedure carries a trailing void* NSError** buffer.
        assert!(
            out.contains("(foreign-procedure \"aw_chez_swift_TestKit_validate\" (integer-64 void*) boolean)"),
            "{out}"
        );
        // The wrapper routes through aw-call/error with a `values` (identity) coerce.
        assert!(out.contains("(aw-call/error %raw values a0)"), "{out}");
    }

    #[test]
    fn struct_return_boxes_through_handle_pointer() {
        // A return type that is neither scalar nor String boxes to an opaque handle
        // (void* on the chez side); the function still trampolines.
        let f = swift_func(
            "makeWidget",
            vec![],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Class {
                    name: "TKWidget".into(),
                    framework: Some("TestKit".into()),
                    params: vec![],
                },
            },
            SwiftFnInfo::default(),
        );
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs())
        else {
            panic!();
        };
        assert_eq!(
            t.render_chez(),
            "(define makeWidget (foreign-procedure \"aw_chez_swift_TestKit_makeWidget\" () void*))"
        );
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
    fn value_struct_param_unboxes_through_the_handle() {
        let value_struct = Struct {
            name: "TKColumn".into(),
            fields: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
        };
        let f = swift_func(
            "summarize",
            vec![param(
                "_",
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Class {
                        name: "TKColumn".into(),
                        framework: Some("TestKit".into()),
                        params: vec![],
                    },
                },
            )],
            prim("int64"),
            SwiftFnInfo::default(),
        );
        let structs = value_struct_names(std::slice::from_ref(&value_struct));
        // With the struct set, the param binds (BoxedHandle → void* on the chez side).
        let FnDisposition::Trampoline(t) =
            classify_function("TestKit", &f, std::slice::from_ref(&f), &structs)
        else {
            panic!("value-struct param should trampoline");
        };
        assert_eq!(
            t.render_chez(),
            "(define summarize (foreign-procedure \"aw_chez_swift_TestKit_summarize\" (void*) integer-64))"
        );
        // Without it, the param defers as a non-bridged struct param.
        assert!(matches!(
            classify_function("TestKit", &f, std::slice::from_ref(&f), &no_structs()),
            FnDisposition::Deferred(DeferReason::NonBridgedStructParam)
        ));
    }

    #[test]
    fn overloads_get_distinct_content_addressed_entries_and_bindings() {
        let a = swift_func("show", vec![param("_", prim("int64"))], prim("void"), SwiftFnInfo::default());
        let b = swift_func("show", vec![param("_", prim("double"))], prim("void"), SwiftFnInfo::default());
        let siblings = vec![a.clone(), b.clone()];
        let FnDisposition::Trampoline(ta) = classify_function("M", &a, &siblings, &no_structs()) else { panic!() };
        let FnDisposition::Trampoline(tb) = classify_function("M", &b, &siblings, &no_structs()) else { panic!() };
        assert_ne!(ta.entry, tb.entry, "overloads need distinct C entries");
        assert_ne!(ta.binding_name, tb.binding_name, "overloads need distinct chez names");
        assert!(ta.binding_name.starts_with("show_"), "{}", ta.binding_name);
    }

    #[test]
    fn swift_codegen_calls_by_name_and_imports_owning_module() {
        let f = swift_func("timestampSeed", vec![], prim("int64"), SwiftFnInfo::default());
        let mut set = TrampolineSet::default();
        if let FnDisposition::Trampoline(t) =
            classify_function("CreateML", &f, std::slice::from_ref(&f), &no_structs())
        {
            set.functions.push(t);
        }
        let swift = generate_trampolines_swift(&set);
        assert!(swift.contains("import CreateML"), "{swift}");
        assert!(swift.contains("@_cdecl(\"aw_chez_swift_CreateML_timestampSeed\")"), "{swift}");
        assert!(swift.contains("return CreateML.timestampSeed()"), "{swift}");
        assert!(swift.contains("1 function + 0 constant trampoline."), "{swift}");
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
        assert_eq!(t.entry, "aw_chez_swift_const_CreateML_MLCreateErrorDomain");
        assert_eq!(
            t.render_chez(),
            "(define MLCreateErrorDomain (aw-string-result ((foreign-procedure \"aw_chez_swift_const_CreateML_MLCreateErrorDomain\" () void*))))"
        );
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
        // ObjC-exposed function — skipped (direct-bound elsewhere).
        let mut direct = swift_func("TKDirect", vec![], prim("void"), SwiftFnInfo::default());
        direct.objc_exposed = true;
        direct.swift_fn = None;
        fw.functions.push(direct);
        // Residual function — trampolined.
        fw.functions
            .push(swift_func("seed", vec![], prim("int64"), SwiftFnInfo::default()));
        let set = collect_trampolines(std::slice::from_ref(&fw));
        assert_eq!(set.functions.len(), 1);
        assert_eq!(set.functions[0].swift_name, "seed");
    }
}
