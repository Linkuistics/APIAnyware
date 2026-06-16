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
    /// `Swift.String` → bridged `NSString`, returned +1-retained as an `id`; the
    /// racket side copies to a string and releases.
    SwiftString,
    /// Anything else (non-bridged struct, object, tuple, existential, …) — wrapped
    /// in the generic `awRacketBox` and returned as an opaque handle pointer.
    Handle,
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

/// Classify a param `TypeRef`, or `None` if it is not bindable this leaf (the
/// function is then [`Deferred`] with `deferred_nonbridged_struct_param`).
fn classify_param(t: &TypeRef) -> Option<ArgMarshal> {
    if is_swift_string(t) {
        return Some(ArgMarshal::SwiftString);
    }
    match &t.kind {
        TypeRefKind::Primitive { name } => scalar_of_primitive(name).map(ArgMarshal::Scalar),
        _ => None,
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
            None => RetMarshal::Handle,
        },
        _ => RetMarshal::Handle,
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
    /// A non-Foundation-bridged Swift struct/tuple/existential **parameter** —
    /// needs a named unbox, deferred with the handle-accessor surface.
    NonBridgedStructParam,
}

impl DeferReason {
    /// The stable diagnostic string logged + recorded for this reason.
    pub fn as_str(self) -> &'static str {
        match self {
            DeferReason::UnbindableGenericFreeFunction => "unbindable_generic_free_function",
            DeferReason::Async => "deferred_async",
            DeferReason::NonBridgedStructParam => "deferred_nonbridged_struct_param",
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
            Some(m) => params.push(m),
            None => return FnDisposition::Deferred(DeferReason::NonBridgedStructParam),
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
                ArgMarshal::SwiftString => format!("s{i}"),
            };
            if label == "_" || label.is_empty() {
                value
            } else {
                format!("{label}: {value}")
            }
        })
        .collect();
    format!("{}({})", t.swift_name, args.join(", "))
}

/// The `@_cdecl` parameter list (named) and the body's reconstruction prelude.
fn decl_params_and_prelude(t: &FnTrampoline) -> (Vec<String>, String) {
    let mut decl = Vec::with_capacity(t.params.len());
    let mut prelude = String::new();
    for (i, m) in t.params.iter().enumerate() {
        match m {
            ArgMarshal::Scalar(s) => decl.push(format!("_ a{i}: {}", s.swift())),
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

/// The C return type spelled at the `@_cdecl` boundary, and the success-path
/// expression that marshals `<call>` to it (with `{call}` substituted in).
fn return_shape(ret: &RetMarshal) -> (String, fn(&str) -> String) {
    match ret {
        RetMarshal::Void => ("Void".to_string(), (|c| c.to_string()) as fn(&str) -> String),
        RetMarshal::Scalar(s) => (
            s.swift().to_string(),
            // Pass the scalar straight back.
            (|c| c.to_string()) as fn(&str) -> String,
        ),
        RetMarshal::SwiftString => (
            "UnsafeMutableRawPointer?".to_string(),
            // Bridge to NSString, hand racket a +1-retained id.
            (|c| format!("Unmanaged.passRetained(({c}) as NSString).toOpaque()"))
                as fn(&str) -> String,
        ),
        RetMarshal::Handle => (
            "UnsafeMutableRawPointer?".to_string(),
            // Box any non-bridged value behind the uniform opaque handle.
            (|c| format!("awRacketBox({c})")) as fn(&str) -> String,
        ),
    }
}

/// The `awRacketTry` fallback for the throwing path, given the return rep.
fn throw_fallback(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "()",
        RetMarshal::Scalar(s) => s.fallback(),
        RetMarshal::SwiftString | RetMarshal::Handle => "nil",
    }
}

/// Emit one function trampoline.
fn emit_fn(s: &mut String, t: &FnTrampoline) {
    let (mut decl, prelude) = decl_params_and_prelude(t);
    let (cret, marshal) = return_shape(&t.ret);

    if t.throwing {
        decl.push("_ awErrOut: UnsafeMutableRawPointer?".to_string());
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
            RetMarshal::Scalar(_) => format!(
                "  return awRacketTry(awErrOut, {fb}) {{ try {call} }}\n",
                fb = throw_fallback(&t.ret)
            ),
            RetMarshal::SwiftString | RetMarshal::Handle => {
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
        RetMarshal::Scalar(s) => s.ffi(),
        RetMarshal::SwiftString | RetMarshal::Handle => "_pointer",
    }
}

/// The racket-visible `provide/contract` predicate for a return marshalling.
fn ret_contract(ret: &RetMarshal) -> &'static str {
    match ret {
        RetMarshal::Void => "void?",
        RetMarshal::Scalar(s) => s.contract(),
        // `String` returns map NULL → `#f` through the coercion.
        RetMarshal::SwiftString => "(or/c string? #f)",
        // An opaque handle is a raw cpointer on the racket side.
        RetMarshal::Handle => "cpointer?",
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
                ArgMarshal::Scalar(s) => s.ffi(),
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
                ArgMarshal::Scalar(s) => s.contract(),
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
                ArgMarshal::Scalar(_) => a.clone(),
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
        assert!(s.contains("return compute(x: a0)"), "{s}");
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
            s.contains("return Unmanaged.passRetained((greeting(name: s0)) as NSString).toOpaque()"),
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
        assert!(s.contains("return awRacketBox(makePoint(x: a0, y: a1))"), "{s}");
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
        assert!(s.contains("return awRacketTry(awErrOut, 0) { try risky(input: a0) }"), "{s}");
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
                "return awRacketTry(awErrOut, nil) { Optional(Unmanaged.passRetained((try load()) as NSString).toOpaque()) }"
            ),
            "{s}"
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
        assert!(s.contains("return awRacketBox(TestKit.defaultConfig)"), "{s}");
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
