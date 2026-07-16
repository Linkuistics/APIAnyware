//! Generated napi-callback trampolines for the Swift-native `s:` residual
//! (`fn-trampoline-spine-k53`, ADR-0027 ported to the TS/N-API target).
//!
//! A `objc_exposed == false` free function has **no C symbol** — it is reachable only across
//! the Swift ABI (ADR-0025 trampoline-elision limit). So the addon carries, per residual
//! function, a generated napi callback that `import`s the owning framework module and calls the
//! API **by name**, letting swiftc own Swift-ABI correctness (ADR-0027 §1; the mangled-`s:` +
//! hand-cast route was rejected there). This is the **napi-callback** analogue of racket's
//! plain-C `@_cdecl`: read the JS args → call by name → marshal the scalar result to a napi
//! value. The TS divergence from racket: the entry is registered in the addon's **exports
//! object** (`napiDefine`), so it is a plain napi callback under its `aw_ts_swift_<Module>_<name>`
//! key ([`crate::native_dispatch::swift_function_entry_name`]) — not an exported `@_cdecl` symbol.
//!
//! ## Scope: scalar params → scalar / **object** return — no silent narrowing
//!
//! This module binds the **scalar** free-function residual (`Double`/`Int`/`CGFloat` params →
//! `Double`/`Int`/`CGFloat`/`Void` return, `fn-trampoline-spine-k53`) **plus object / Foundation-
//! bridged value / string returns** (`object-bridged-returns-k55`, ADR-0061 §3): a call result
//! bridged to an `id` and handed to JS at a uniform +1 ([`RetMarshal::Object`]). Everything else
//! is **deferred with a recorded reason** ([`DeferReason`]) — an **object/string param** (the
//! ARC-on-bitcast / Object-ref curated-set frontier), a **non-bridged value-struct return**,
//! `throws` (→ the ADR-0058 `Result` channel), `async`, a Swift **operator** declaration, and the
//! genuinely-unbindable generic free function (`@_cdecl` cannot be generic). The
//! method/init/value-struct residual is a follow-up-grove deferral (ADR-0061 §4). The classifier
//! and the codegen share
//! [`classify_function`], so the recorded deferral and the emitted binding always agree, and the
//! emitter's `.ts` call site ([`crate::emit_functions`]) reconstructs the same content-addressed
//! entry with no shared state.
//!
//! An object return is empirically ~absent from the real free-function residual (an SDK survey
//! found no headless, non-throwing, object-returning Swift-native free function — the object
//! residual lives at the **method** level, ADR-0061 §4). This binds the **mechanism** (ADR-0027 §2
//! taxonomy completeness); the ownership shape is proven headless by a native probe
//! (`trampolines.swift`), the codegen by the goldens/units below.
//!
//! ## `TypeRefKind::Class` is overloaded — the real-IR trap (`swift-residual-cli-pass-k65`)
//!
//! A `.swiftinterface`-sourced declaration lowers **every Swift nominal type** to
//! `kind: "class"`. So the real IR spells `CoreGraphics.hypot` as
//! `(Class{CGFloat}, Class{CGFloat}) -> Class{CGFloat}`, and `lgamma`/`remquo` as returning
//! `Class{Tuple}` — neither name is a class CoreGraphics declares (it declares exactly eight).
//! Two guards keep the classification honest, and **both must precede the object arm**:
//!
//! 1. [`scalar_value_type`] — a named type that is one C scalar at the ABI (`CGFloat`) marshals
//!    **by value**, whatever `TypeRefKind` carries the name.
//! 2. The **ObjC-class recognition set** ([`objc_class_names`]) — an object return binds only for
//!    a name the IR declares as a class; a Swift tuple defers
//!    ([`DeferReason::SwiftNominalReturn`]).
//!
//! Without (1) a generated `hypot` would `passRetained` a `__SwiftValue` box instead of returning
//! a `Double`; without (2) `remquo` would bridge a Swift tuple through `as AnyObject?`. The same
//! overload afflicts the *method* surface — that is `swift-nominal-type-surface-k66`, not here.

use std::collections::{BTreeMap, BTreeSet};

use apianyware_types::ir::{Framework, Function};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::naming::is_valid_ts_identifier;
use crate::native_dispatch::swift_function_entry_name;

// ---------------------------------------------------------------------------
// Scalar alphabet
// ---------------------------------------------------------------------------

/// The closed set of scalar shapes the spine's free-function trampoline can marshal. The Swift
/// spelling is what the by-name call passes and what the napi reader/maker helpers target, so
/// the boundary and the call agree by construction. Deliberately small (the honest spine): the
/// realistic scalar residual is math (`Double`/`CGFloat`) and counts (`Int`); other widths /
/// `Bool` / unsigned defer with a reason ([`DeferReason::NonScalarType`]) as a clean next-child
/// widening — never a silent drop.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Scalar {
    /// A JS number read via `napiReadDouble`, returned via `napiMakeDouble`. Swift `Double`.
    Double,
    /// A JS number read via `napiReadInt64`, returned via `napiMakeInt64`. Swift `Int`.
    Int,
}

impl Scalar {
    /// The napi reader helper (`napi_support.swift`) that reads a JS arg into the boundary type.
    fn reader(self) -> &'static str {
        match self {
            Scalar::Double => "napiReadDouble",
            Scalar::Int => "napiReadInt64",
        }
    }

    /// The Swift type the reader produces (may be wider than [`swift`](Scalar::swift) — the napi
    /// readers give `Double`/`Int64`, converted to the call's exact type in [`arg_expr`]).
    fn boundary_type(self) -> &'static str {
        match self {
            Scalar::Double => "Double",
            Scalar::Int => "Int64",
        }
    }

    /// The napi maker helper that marshals the (converted) call result to a JS value.
    fn maker(self) -> &'static str {
        match self {
            Scalar::Double => "napiMakeDouble",
            Scalar::Int => "napiMakeInt64",
        }
    }
}

/// Normalise an IR primitive name (`Swift.Int` / `NSInteger` / `double`) to the lowercase,
/// unqualified token the scalar mapper keys on (mirrors `native_dispatch::normalize_primitive_name`).
fn normalize_primitive(name: &str) -> String {
    let unqualified = name.rsplit_once('.').map_or(name, |(_, suffix)| suffix);
    unqualified.to_ascii_lowercase()
}

/// An IR primitive name → the spine's [`Scalar`], or `None` for `void`/`bool`/other widths/unknown
/// (which defer). `int`/`nsinteger`/`int64` collapse to `Int`; `double` to `Double`.
fn scalar_of_primitive(name: &str) -> Option<Scalar> {
    Some(match normalize_primitive(name).as_str() {
        "double" => Scalar::Double,
        "int" | "nsinteger" | "int64" => Scalar::Int,
        _ => return None,
    })
}

/// A **scalar-backed named value type**: a Swift type the IR lowers to a named
/// `Class`/`Struct`/`Alias` but which is a single C scalar at the ABI, so it marshals by value.
/// `CGFloat` (a `Double` on 64-bit Apple platforms) is the dominant scalar residual (racket
/// found 44 of 69 deferred functions were CGFloat-only). Kept a principled allowlist: a member
/// must be a single scalar with a Swift `init(_:)` round-trip, so `CGFloat(a0)` / `Double(call)`
/// type-check.
///
/// Keyed on the **name alone**, deliberately. A `.swiftinterface`-sourced decl lowers every
/// Swift nominal type to `kind: "class"`, so the real IR spells `CGFloat` as
/// `Class { name: "CGFloat", framework: "CoreGraphics" }`; an ObjC header spells the same
/// typedef `Alias { name: "CGFloat", … }`. Both marshal by value, so **every** `TypeRefKind`
/// that carries a name consults this before deciding the value is an object.
fn scalar_value_type(name: &str) -> Option<Scalar> {
    match name {
        "CGFloat" => Some(Scalar::Double),
        _ => None,
    }
}

// ---------------------------------------------------------------------------
// Marshalling taxonomy (scalar spine)
// ---------------------------------------------------------------------------

/// How one value crosses the trampoline boundary in a **parameter** position.
#[derive(Debug, Clone, PartialEq, Eq)]
enum ArgMarshal {
    /// A plain scalar passed through (converted from the reader's boundary type to the call's
    /// exact scalar type).
    Scalar(Scalar),
    /// A scalar-backed named typedef (`CGFloat`): the boundary reads the underlying scalar; the
    /// body re-wraps it as the named type (`CGFloat(a0)`) so the by-name call binds the real
    /// (typedef-taking) overload.
    ScalarTypedef { scalar: Scalar, name: String },
}

/// How a **return** value crosses the boundary.
#[derive(Debug, Clone, PartialEq, Eq)]
enum RetMarshal {
    Void,
    Scalar(Scalar),
    /// A scalar-backed named typedef return (`-> CGFloat`): the call result is converted to the
    /// underlying scalar (`Double((call) as CGFloat)`) before the napi maker.
    ScalarTypedef {
        scalar: Scalar,
        name: String,
    },
    /// An **object / Foundation-bridged value / string** return (`-> String`, `-> [T]`, `->
    /// NSData`, a class instance) — `object-bridged-returns-k55`, ADR-0061 §3. The call result
    /// bridges to an `id` via `as AnyObject?` (`String`→`NSString`, `Array`→`NSArray`, or identity
    /// for a class), and the trampoline hands JS a **+1** handle (`Unmanaged.passRetained`) the
    /// runtime's `__wrapOwned` takes (ADR-0057 §4 uniform +1). Nullability rides the `.ts` side
    /// (the `!` assertion off `TypeRef.nullable`); the native marshaller maps a nil object to `0n`.
    Object,
}

/// Classify a param `TypeRef` into its marshalling, or the [`DeferReason`] recording why it is
/// not scalar-trampolinable this child.
fn classify_param(t: &TypeRef) -> Result<ArgMarshal, DeferReason> {
    match &t.kind {
        TypeRefKind::Primitive { name } => scalar_of_primitive(name)
            .map(ArgMarshal::Scalar)
            .ok_or(DeferReason::NonScalarType),
        // A named type: a scalar-backed value type (`CGFloat`) marshals by value; anything else
        // (an object/value-struct/string param) defers to the method-frontier residual.
        TypeRefKind::Class { name, .. }
        | TypeRefKind::Struct { name }
        | TypeRefKind::Alias { name, .. } => scalar_value_type(name)
            .map(|scalar| ArgMarshal::ScalarTypedef {
                scalar,
                name: name.clone(),
            })
            .ok_or(DeferReason::NonScalarParam),
        _ => Err(DeferReason::NonScalarParam),
    }
}

/// Classify a return `TypeRef`: scalar / scalar-typedef / void / **object** bind; everything else
/// defers with a reason.
///
/// `objc_classes` is the **ObjC-class recognition set** (every class the IR declares), and it is
/// what makes the object arm sound. `TypeRefKind::Class` is overloaded: for an ObjC-header decl it
/// names a real class, but for a `.swiftinterface` decl it names *any* Swift nominal type —
/// `CGFloat`, or the `Tuple` that `CoreGraphics.lgamma` / `remquo` return. Only a name the IR
/// actually declares as a class can be handed to JS as an `id` handle; a Swift nominal type with
/// no ObjC identity defers ([`DeferReason::SwiftNominalReturn`]). Order matters: a scalar-backed
/// value type is checked first, so `CGFloat` marshals as a `Double` rather than being boxed into a
/// `__SwiftValue` by `as AnyObject?`.
fn classify_return(
    t: &TypeRef,
    objc_classes: &BTreeSet<String>,
) -> Result<RetMarshal, DeferReason> {
    match &t.kind {
        TypeRefKind::Primitive { name } => {
            if normalize_primitive(name) == "void" {
                Ok(RetMarshal::Void)
            } else {
                scalar_of_primitive(name)
                    .map(RetMarshal::Scalar)
                    .ok_or(DeferReason::NonScalarType)
            }
        }
        // `id`/`instancetype` are unconditionally objects — they are rooted in `NSObject`, carry
        // no name to check, and cannot be a Swift value type.
        TypeRefKind::Id { .. } | TypeRefKind::Instancetype => Ok(RetMarshal::Object),
        TypeRefKind::Class { name, .. } => {
            if let Some(scalar) = scalar_value_type(name) {
                Ok(RetMarshal::ScalarTypedef {
                    scalar,
                    name: name.clone(),
                })
            } else if objc_classes.contains(name) {
                // An object / Foundation-bridged value / string return binds as a +1 handle
                // (object-bridged-returns-k55, ADR-0061 §3). The IR's lossy Swift→ObjC
                // normalization reports `String`/`Array`/… as their Foundation `Class` twin, so
                // those land here alongside a genuine class instance — all cross as one `id`
                // handle at a uniform +1 (`as AnyObject?` + `Unmanaged.passRetained`).
                Ok(RetMarshal::Object)
            } else {
                Err(DeferReason::SwiftNominalReturn)
            }
        }
        // A scalar-backed value type (`CGFloat` as an ObjC typedef) marshals by value; a
        // non-bridged value struct or any other non-routable alias defers (the value-struct /
        // method-frontier residual, ADR-0061 §4).
        TypeRefKind::Struct { name } | TypeRefKind::Alias { name, .. } => scalar_value_type(name)
            .map(|scalar| RetMarshal::ScalarTypedef {
                scalar,
                name: name.clone(),
            })
            .ok_or(DeferReason::NonScalarReturn),
        _ => Err(DeferReason::NonScalarReturn),
    }
}

// ---------------------------------------------------------------------------
// Deferral reasons (no silent narrowing — ADR-0027 §2 / the residual honesty clause)
// ---------------------------------------------------------------------------

/// Why a Swift-native free function is **not** trampolined this child, recorded (never silently
/// dropped). A hard limit (a generic `@_cdecl`) vs a staged one (a non-scalar shape the next
/// child binds) is distinguished by the variant, so the pass log is honest about what remains.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DeferReason {
    /// The Swift declaration's name is **not a valid TS identifier** — a Swift *operator*
    /// declaration (`+`, `-`, `*`, `/`, `&&`, `||`, `!`; 13 across `TabularData` and
    /// `RealityFoundation`). A **hard** limit on two counts: no emitted `.ts` can name the entry
    /// (so it would be an unreachable export), and [`swift_function_entry_name`] sanitises every
    /// non-alphanumeric to `_`, so `TabularData./`'s four overloads would all collide on one
    /// entry name. Checked **first**, because without a nameable entry no other reason is
    /// actionable. Sharing this check with `emit_functions`'s admission gate is what makes the
    /// strong mirror invariant (`collected == referenced`) hold exactly.
    UnrepresentableName,
    /// A generic free function — `@_cdecl` cannot be generic. A **hard** limit (ADR-0027 §2).
    UnbindableGenericFreeFunction,
    /// An `async` function — the completion-callback shape is a follow-up.
    Async,
    /// A `throws` function — routes to the ADR-0058 `Result` channel; the next child.
    Throwing,
    /// A **parameter** that is not a spine scalar (an object/string/value-struct param, or a
    /// scalar width the spine alphabet does not yet carry) — the next child widens this.
    NonScalarParam,
    /// A **return** that is neither a scalar nor a bound object — a **non-bridged value struct**
    /// (or other non-routable alias). The value-struct / method-frontier residual (ADR-0061 §4),
    /// a follow-up grove; object/string/class returns now bind (`object-bridged-returns-k55`).
    NonScalarReturn,
    /// A **return** the IR spells `TypeRefKind::Class` but whose name is **not a class the IR
    /// declares** — a `.swiftinterface`-lowered Swift nominal type with no ObjC identity, so it
    /// cannot cross as an `id` handle. The measured population is the Swift **tuple** return
    /// (`CoreGraphics.lgamma`/`remquo` → `(CGFloat, Int)`). Distinct from
    /// [`NonScalarReturn`](DeferReason::NonScalarReturn) because the *cause* differs: not "a
    /// struct we chose not to bind" but "a name that only looks like a class".
    SwiftNominalReturn,
    /// A scalar width/kind outside the spine alphabet (`Bool`/`Float`/narrow/unsigned) in a
    /// param **or** return position — a clean next-child widening, distinct from a genuinely
    /// non-scalar type.
    NonScalarType,
}

impl DeferReason {
    /// The stable diagnostic string logged for this reason.
    pub fn as_str(self) -> &'static str {
        match self {
            DeferReason::UnrepresentableName => "unrepresentable_name",
            DeferReason::UnbindableGenericFreeFunction => "unbindable_generic_free_function",
            DeferReason::Async => "deferred_async",
            DeferReason::Throwing => "deferred_throwing",
            DeferReason::NonScalarParam => "deferred_non_scalar_param",
            DeferReason::NonScalarReturn => "deferred_non_scalar_return",
            DeferReason::SwiftNominalReturn => "deferred_swift_nominal_return",
            DeferReason::NonScalarType => "deferred_non_scalar_type",
        }
    }
}

// ---------------------------------------------------------------------------
// Trampoline plan
// ---------------------------------------------------------------------------

/// A Swift-native scalar free function the TS target trampolines: the resolved marshalling plan
/// plus everything both the Swift codegen and the `.ts` emitter need, computed purely from
/// `(module, Function)` so the two sides agree without shared state.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FnTrampoline {
    /// Owning Swift module (the enclosing `Framework.name`) — the `import` target and the call's
    /// namespace qualifier.
    module: String,
    /// Bare Swift function name (`Function.name`) used in the by-name call.
    swift_name: String,
    /// Content-addressed entry key (`aw_ts_swift_<Module>_<name>`) — the exports key the `.ts`
    /// call site and this trampoline share.
    pub entry: String,
    /// Per-param argument label (from `Param.name`); empty / `_` means no label.
    labels: Vec<String>,
    params: Vec<ArgMarshal>,
    ret: RetMarshal,
}

/// What a bound residual function's **TypeScript** return looks like — the projection of
/// [`RetMarshal`] the `.ts` emitter needs, without exposing the Swift-side marshalling detail.
/// A residual function's *parameters* need no such projection: only scalars bind, so every
/// param is a plain `number` on the TS side (an object/string param defers).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ResidualReturn {
    Void,
    /// A JS `number` — a scalar or a scalar-backed value type (`CGFloat`).
    Number,
    /// A `+1` object handle the emitted body hands to `__wrapOwned` (ADR-0061 §3).
    Object,
}

impl FnTrampoline {
    /// The TS-side shape of this trampoline's return ([`ResidualReturn`]). The `.ts` emitter reads
    /// its header, body and seam-import set from here, so the emitted call site and the generated
    /// napi callback cannot disagree about what crosses the boundary.
    pub fn ts_return(&self) -> ResidualReturn {
        match self.ret {
            RetMarshal::Void => ResidualReturn::Void,
            RetMarshal::Scalar(_) | RetMarshal::ScalarTypedef { .. } => ResidualReturn::Number,
            RetMarshal::Object => ResidualReturn::Object,
        }
    }
}

/// The disposition of a residual function: bind a scalar trampoline, or defer (recorded).
pub enum FnDisposition {
    Trampoline(FnTrampoline),
    Deferred(DeferReason),
}

/// Classify a Swift-native (`objc_exposed == false`) free function into a scalar trampoline plan
/// or a recorded deferral. Both the codegen pass and the `.ts` emitter call this, so the emitted
/// binding and the generated napi callback always agree. (The caller filters on `!objc_exposed`;
/// an ObjC-exposed function binds directly via `aw_ts_fn_*` and never reaches here.)
///
/// `objc_classes` is the ObjC-class recognition set [`classify_return`] gates its object arm on.
/// The two callers derive it identically — [`collect_trampolines`] unions every framework's IR
/// classes, and `emit_framework` unions the cross-framework `ClassRegistry` with the framework's
/// own — so the bind-or-defer decision is the same on both sides of the mirror.
pub fn classify_function(
    module: &str,
    func: &Function,
    objc_classes: &BTreeSet<String>,
) -> FnDisposition {
    if !is_valid_ts_identifier(&func.name) {
        return FnDisposition::Deferred(DeferReason::UnrepresentableName);
    }
    if let Some(info) = &func.swift_fn {
        if info.is_generic {
            return FnDisposition::Deferred(DeferReason::UnbindableGenericFreeFunction);
        }
        if info.is_async {
            return FnDisposition::Deferred(DeferReason::Async);
        }
        if info.throwing {
            return FnDisposition::Deferred(DeferReason::Throwing);
        }
    }

    let mut params = Vec::with_capacity(func.params.len());
    for p in &func.params {
        match classify_param(&p.param_type) {
            Ok(m) => params.push(m),
            // The first non-bindable param's reason wins — deterministic, most specific recorded.
            Err(reason) => return FnDisposition::Deferred(reason),
        }
    }
    let ret = match classify_return(&func.return_type, objc_classes) {
        Ok(r) => r,
        Err(reason) => return FnDisposition::Deferred(reason),
    };
    let labels = func.params.iter().map(|p| p.name.clone()).collect();

    FnDisposition::Trampoline(FnTrampoline {
        module: module.to_string(),
        swift_name: func.name.clone(),
        entry: swift_function_entry_name(module, &func.name),
        labels,
        params,
        ret,
    })
}

/// A residual function not trampolined this child, recorded for the pass log.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Deferred {
    pub module: String,
    pub name: String,
    pub reason: DeferReason,
}

/// The whole-program trampoline plan: every retained `objc_exposed == false` free function
/// (trampolined or deferred) across all frameworks. Built once over all frameworks by the global
/// codegen pass (the racket `collect_trampolines` precedent, scalar-scoped).
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct TrampolineSet {
    pub functions: Vec<FnTrampoline>,
    pub deferred: Vec<Deferred>,
}

impl TrampolineSet {
    /// Per-reason deferral counts for the pass log, in a stable order — the "defer nothing, but
    /// say what truly can't be bound" contract's only output (ADR-0061 §3, the racket
    /// `defer_counts` precedent).
    pub fn defer_counts(&self) -> Vec<(&'static str, usize)> {
        let mut counts: BTreeMap<&'static str, usize> = BTreeMap::new();
        for d in &self.deferred {
            *counts.entry(d.reason.as_str()).or_default() += 1;
        }
        counts.into_iter().collect()
    }
}

/// Every class name the IR declares, across `frameworks` — the ObjC-class recognition set
/// [`classify_return`] gates its object arm on. `emit_framework` builds the same set from the
/// cross-framework `ClassRegistry` unioned with the framework's own classes; both reduce to "the
/// classes of every loaded framework" under the real generate CLI, which is what keeps the
/// collector's bind-or-defer decision identical to the `.ts` emitter's.
pub fn objc_class_names(frameworks: &[Framework]) -> BTreeSet<String> {
    frameworks
        .iter()
        .flat_map(|fw| fw.classes.iter().map(|c| c.name.clone()))
        .collect()
}

/// Collect the whole-program scalar free-function trampoline plan.
pub fn collect_trampolines(frameworks: &[Framework]) -> TrampolineSet {
    let objc_classes = objc_class_names(frameworks);
    let mut set = TrampolineSet::default();
    for fw in frameworks {
        for func in &fw.functions {
            if func.objc_exposed {
                continue; // direct-bound (trampoline-elided) — binds via aw_ts_fn_*
            }
            match classify_function(&fw.name, func, &objc_classes) {
                FnDisposition::Trampoline(t) => set.functions.push(t),
                FnDisposition::Deferred(reason) => set.deferred.push(Deferred {
                    module: fw.name.clone(),
                    name: func.name.clone(),
                    reason,
                }),
            }
        }
    }
    set
}

// ---------------------------------------------------------------------------
// Swift codegen (the generated napi-callback trampoline file)
// ---------------------------------------------------------------------------

/// The by-name call's argument expression for one marshalled param `a{i}`: a scalar converts from
/// the reader's boundary type to the call's exact type (`Int(a0)`; `Double` is identity); a
/// scalar typedef re-wraps (`CGFloat(a0)`). Prefixed with the label when present.
fn arg_expr(i: usize, m: &ArgMarshal, label: &str) -> String {
    let value = match m {
        // Double reader → Double call arg: identity. Int reader → Int64; the call wants `Int`.
        ArgMarshal::Scalar(Scalar::Double) => format!("a{i}"),
        ArgMarshal::Scalar(Scalar::Int) => format!("Int(a{i})"),
        ArgMarshal::ScalarTypedef { name, .. } => format!("{name}(a{i})"),
    };
    if label.is_empty() || label == "_" {
        value
    } else {
        format!("{label}: {value}")
    }
}

/// Emit one function trampoline (a napi callback registered under [`FnTrampoline::entry`] by
/// [`generate_trampolines_swift`]'s `awRegisterGeneratedTrampolines`, so it stays `private` to
/// the generated file).
fn emit_fn(s: &mut String, t: &FnTrampoline) {
    // Doc line: what this binds and why it needs a trampoline.
    s.push_str(&format!(
        "/// `{}.{}` — a Swift-native (`objc_exposed == false`) scalar free function, reachable\n\
         /// only by name across the Swift ABI (ADR-0025). Registered as `\"{}\"`.\n",
        t.module, t.swift_name, t.entry
    ));
    s.push_str(&format!(
        "private func {}(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {{\n",
        t.entry
    ));
    // A zero-arg entry still calls `napiCallbackArgs` (it consumes the callback info), but binding
    // the empty array would warn `never used` — swiftc is strict about that in the addon build.
    let bind = if t.params.is_empty() { "_" } else { "let a" };
    s.push_str(&format!(
        "  {bind} = napiCallbackArgs(env, info, {})\n",
        t.params.len()
    ));
    for (i, m) in t.params.iter().enumerate() {
        let reader = match m {
            ArgMarshal::Scalar(sc) => sc.reader(),
            ArgMarshal::ScalarTypedef { scalar, .. } => scalar.reader(),
        };
        s.push_str(&format!("  let a{i} = {reader}(env, a[{i}])\n"));
    }

    let args: Vec<String> = t
        .params
        .iter()
        .enumerate()
        .map(|(i, m)| arg_expr(i, m, &t.labels[i]))
        .collect();
    let call = format!("{}.{}({})", t.module, t.swift_name, args.join(", "));

    match &t.ret {
        RetMarshal::Void => {
            s.push_str(&format!("  {call}\n"));
            s.push_str("  return napiUndefined(env)\n");
        }
        RetMarshal::Scalar(sc) => {
            // Double: pass through. Int: the call yields `Int`; the maker wants `Int64`.
            let marshalled = match sc {
                Scalar::Double => call,
                Scalar::Int => format!("Int64({call})"),
            };
            s.push_str(&format!("  return {}(env, {marshalled})\n", sc.maker()));
        }
        RetMarshal::ScalarTypedef { scalar, name } => {
            // Pin the typedef with `as <Type>`, then convert to the maker's scalar (disambiguates
            // a cross-module return-type overload; a harmless identity cast otherwise).
            let conv = scalar.boundary_type();
            let marshalled = format!("{conv}(({call}) as {name})");
            s.push_str(&format!("  return {}(env, {marshalled})\n", scalar.maker()));
        }
        RetMarshal::Object => {
            // Bridge the result to an `id` (`String`→`NSString`, `Array`→`NSArray`, or identity
            // for a class) and hand JS a **+1** handle (ADR-0057 §4 → `__wrapOwned`).
            // `napiMakeRetainedObject` `passRetained`s the bridge (nil → `0n`).
            s.push_str(&format!(
                "  return napiMakeRetainedObject(env, ({call}) as AnyObject?)\n"
            ));
        }
    }
    s.push_str("}\n");
}

/// Generate the whole `Generated/TrampolineTable.swift` — the banner, `import`s (one per distinct
/// module with a trampoline, plus `Foundation`), one napi callback per trampolined function, and
/// the `awRegisterGeneratedTrampolines` registration the hand-written `napi_register_module_v1`
/// calls. Deferred decls produce no Swift (they are recorded in [`TrampolineSet::deferred`] and
/// counted in the pass log instead).
///
/// Entries render in **collection order**, which is the IR's framework-then-function order — a
/// pure function of the input artifacts, so regeneration is byte-stable.
pub fn generate_trampolines_swift(set: &TrampolineSet) -> String {
    let mut s = String::new();
    s.push_str("// Generated napi-callback trampolines for the Swift-native `s:` residual\n");
    s.push_str("// (ADR-0061, the racket ADR-0027 shape). DO NOT EDIT — regenerated by\n");
    s.push_str("// `apianyware-generate` from the IR. One napi callback per retained\n");
    s.push_str("// `objc_exposed == false` scalar free function; each imports the owning\n");
    s.push_str("// framework and calls the API by name (swiftc owns Swift-ABI correctness).\n");
    s.push_str("// Entry names are content-addressed by module + symbol (native_dispatch.rs\n");
    s.push_str("// `swift_function_entry_name`) — the emitted `.ts` call sites compute the\n");
    s.push_str("// same names with no shared state.\n\n");

    // One `import` per distinct module that has at least one trampoline, plus Foundation (the
    // napi helpers live there). Deterministic order (BTreeSet).
    let mut modules: BTreeSet<&str> = BTreeSet::new();
    modules.insert("Foundation");
    for t in &set.functions {
        modules.insert(t.module.as_str());
    }
    for m in &modules {
        s.push_str(&format!("import {m}\n"));
    }
    s.push('\n');

    for t in &set.functions {
        emit_fn(&mut s, t);
        s.push('\n');
    }

    s.push_str("/// Register every generated Swift-native residual trampoline on the addon's\n");
    s.push_str("/// exports object — called by `napi_register_module_v1` (dispatch.swift).\n");
    s.push_str("func awRegisterGeneratedTrampolines(_ env: napi_env?, _ exports: napi_value?) {\n");
    for t in &set.functions {
        s.push_str(&format!(
            "  napiDefine(env, exports, \"{0}\", {0})\n",
            t.entry
        ));
    }
    s.push_str("}\n\n");

    let n = set.functions.len();
    s.push_str(&format!(
        "// {n} generated Swift-native residual trampoline{}.\n",
        if n == 1 { "" } else { "s" }
    ));
    let deferred: Vec<String> = set
        .defer_counts()
        .iter()
        .map(|(reason, n)| format!("{n} {reason}"))
        .collect();
    s.push_str(&format!(
        "// Deferred (recorded, never silent): {}.\n",
        if deferred.is_empty() {
            "none".to_string()
        } else {
            deferred.join(", ")
        }
    ));
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::class_graph::ClassRegistry;
    use crate::emit_framework::emit_framework;
    use crate::enum_graph::EnumRegistry;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::ir::{Class, Function, Param, SwiftFnInfo};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    /// A minimal ObjC class declaration — enough for `Framework.classes`, which is the
    /// recognition set the object-return arm consults.
    fn cls(name: &str) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn prim(name: &str) -> TypeRef {
        ty(TypeRefKind::Primitive { name: name.into() })
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

    /// The real IR's spelling of `CGFloat`: a `.swiftinterface` decl lowers every Swift nominal
    /// type to `kind: "class"`. The pre-k65 fixtures used `Alias`, a shape the real IR never
    /// produces for a Swift-native function — which is why the `Class{..} => Object` bug survived.
    fn cgfloat() -> TypeRef {
        ty(TypeRefKind::Class {
            name: "CGFloat".into(),
            framework: Some("CoreGraphics".into()),
            params: vec![],
        })
    }

    /// An ObjC-class recognition set from bare names — what `objc_class_names` derives from the IR.
    fn classes(names: &[&str]) -> BTreeSet<String> {
        names.iter().map(|s| s.to_string()).collect()
    }

    fn plan(module: &str, f: &Function) -> FnTrampoline {
        plan_with(module, f, &classes(&[]))
    }

    fn plan_with(module: &str, f: &Function, objc_classes: &BTreeSet<String>) -> FnTrampoline {
        match classify_function(module, f, objc_classes) {
            FnDisposition::Trampoline(t) => t,
            FnDisposition::Deferred(r) => panic!("expected trampoline, deferred: {}", r.as_str()),
        }
    }

    fn defer_reason(module: &str, f: &Function, objc_classes: &BTreeSet<String>) -> DeferReason {
        match classify_function(module, f, objc_classes) {
            FnDisposition::Deferred(r) => r,
            FnDisposition::Trampoline(_) => panic!("expected a deferral"),
        }
    }

    #[test]
    fn cgfloat_function_generates_the_proven_hypot_shape_in_both_ir_spellings() {
        // The real headless proof's shape: CoreGraphics.hypot(CGFloat, CGFloat) -> CGFloat. The
        // params read as Double, re-wrap as CGFloat for the by-name call, and the CGFloat result
        // converts back to Double for the maker — matching the retired hand-written trampoline.
        //
        // Both IR spellings of CGFloat must produce it. The real IR (a `.swiftinterface` decl)
        // says `Class{CGFloat}`; an ObjC header says `Alias{CGFloat}`. Before k65 only the Alias
        // arm consulted the scalar allowlist in RETURN position, so real-IR `hypot` would have
        // boxed its CGFloat result into a `__SwiftValue` via `as AnyObject?` and handed JS a
        // handle — `test/swift-native.mjs` (`hypot(3,4) === 5`) would have failed.
        let alias_cgfloat = || {
            ty(TypeRefKind::Alias {
                name: "CGFloat".into(),
                framework: None,
                underlying_primitive: None,
            })
        };
        for make in [&cgfloat as &dyn Fn() -> TypeRef, &alias_cgfloat] {
            let f = swift_fn(
                "hypot",
                vec![param("_", make()), param("_", make())],
                make(),
                SwiftFnInfo::default(),
            );
            // An empty class set: CGFloat must not need to be a known class to marshal by value.
            let t = plan("CoreGraphics", &f);
            assert_eq!(t.entry, "aw_ts_swift_CoreGraphics_hypot");
            assert_eq!(t.ts_return(), ResidualReturn::Number);
            let mut s = String::new();
            emit_fn(&mut s, &t);
            assert!(
                s.contains("func aw_ts_swift_CoreGraphics_hypot(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {"),
                "{s}"
            );
            assert!(s.contains("let a = napiCallbackArgs(env, info, 2)"), "{s}");
            assert!(s.contains("let a0 = napiReadDouble(env, a[0])"), "{s}");
            assert!(s.contains("let a1 = napiReadDouble(env, a[1])"), "{s}");
            // The by-name call re-wraps each arg as CGFloat and converts the result back to Double.
            assert!(
                s.contains("return napiMakeDouble(env, Double((CoreGraphics.hypot(CGFloat(a0), CGFloat(a1))) as CGFloat))"),
                "{s}"
            );
            assert!(!s.contains("napiMakeRetainedObject"), "{s}");
        }
    }

    #[test]
    fn a_swift_nominal_return_defers_unless_the_ir_declares_it_a_class() {
        // `TypeRefKind::Class` is overloaded. `CoreGraphics.remquo(CGFloat, CGFloat) ->
        // (CGFloat, Int)` reaches the IR as a `Class{Tuple}` return — but `Tuple` is not a class
        // CoreGraphics declares, so the object arm must NOT fire (a Swift tuble bridged through
        // `as AnyObject?` is a useless `__SwiftValue` box). Only a name in the recognition set
        // binds as an object.
        let tuple_ret = swift_fn(
            "remquo",
            vec![param("_", cgfloat()), param("_", cgfloat())],
            ty(TypeRefKind::Class {
                name: "Tuple".into(),
                framework: Some("CoreGraphics".into()),
                params: vec![],
            }),
            SwiftFnInfo::default(),
        );
        assert_eq!(
            defer_reason("CoreGraphics", &tuple_ret, &classes(&["CGColor", "CGPath"])),
            DeferReason::SwiftNominalReturn
        );
        // The same shape whose class the IR *does* declare binds as a +1 object handle.
        let obj_ret = swift_fn(
            "makeThing",
            vec![],
            ty(TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            }),
            SwiftFnInfo::default(),
        );
        let t = plan_with("TestKit", &obj_ret, &classes(&["NSString"]));
        assert_eq!(t.ts_return(), ResidualReturn::Object);
    }

    #[test]
    fn a_swift_operator_declaration_defers_with_an_unrepresentable_name() {
        // 13 residual decls are Swift operators (`+`, `-`, `*`, `/`, `&&`, `||`, `!` across
        // TabularData and RealityFoundation). No `.ts` can name the entry, and the entry-name
        // sanitiser would collapse `TabularData./`'s four overloads onto one symbol — so the
        // name check comes FIRST, before any signature reason. Sharing it with `emit_functions`'s
        // admission gate is what makes `collected == referenced` hold exactly.
        let op = swift_fn("/", vec![], prim("double"), SwiftFnInfo::default());
        assert_eq!(
            defer_reason("TabularData", &op, &classes(&[])),
            DeferReason::UnrepresentableName
        );
        // Even a generic operator reports the name first — without a nameable entry no other
        // reason is actionable.
        let generic_op = swift_fn(
            "+",
            vec![],
            prim("double"),
            SwiftFnInfo {
                is_generic: true,
                ..Default::default()
            },
        );
        assert_eq!(
            defer_reason("TabularData", &generic_op, &classes(&[])),
            DeferReason::UnrepresentableName
        );
    }

    #[test]
    fn plain_scalar_function_reads_and_returns_directly() {
        // TestKit.TKSwiftScale(double) -> double : Double args pass through, Double returns direct.
        let f = swift_fn(
            "TKSwiftScale",
            vec![param("factor", prim("double"))],
            prim("double"),
            SwiftFnInfo::default(),
        );
        let t = plan("TestKit", &f);
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("let a0 = napiReadDouble(env, a[0])"), "{s}");
        // A labelled param carries the label; a Double passes through unconverted.
        assert!(
            s.contains("return napiMakeDouble(env, TestKit.TKSwiftScale(factor: a0))"),
            "{s}"
        );
    }

    #[test]
    fn int_scalar_function_converts_at_both_boundaries() {
        // TestKit.timestampSeed() -> Int : no args, Int read/return convert Int64<->Int.
        // A zero-arg entry discards the args array (`_ =`) — binding it warns `never used`, and
        // the addon build compiles the generated file alongside the hand-written sources.
        let f = swift_fn("timestampSeed", vec![], prim("Int"), SwiftFnInfo::default());
        let t = plan("TestKit", &f);
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("  _ = napiCallbackArgs(env, info, 0)"), "{s}");
        assert!(
            s.contains("return napiMakeInt64(env, Int64(TestKit.timestampSeed()))"),
            "{s}"
        );
    }

    #[test]
    fn void_return_is_a_bare_call_then_undefined() {
        let f = swift_fn(
            "reset",
            vec![param("_", prim("Int"))],
            TypeRef::void(),
            SwiftFnInfo::default(),
        );
        let t = plan("TestKit", &f);
        let mut s = String::new();
        emit_fn(&mut s, &t);
        assert!(s.contains("  TestKit.reset(Int(a0))\n"), "{s}");
        assert!(s.contains("  return napiUndefined(env)\n"), "{s}");
    }

    #[test]
    fn throwing_async_and_generic_defer_with_distinct_reasons() {
        let throwing = swift_fn(
            "risky",
            vec![],
            prim("Int"),
            SwiftFnInfo {
                throwing: true,
                ..Default::default()
            },
        );
        let is_async = swift_fn(
            "later",
            vec![],
            prim("Int"),
            SwiftFnInfo {
                is_async: true,
                ..Default::default()
            },
        );
        let generic = swift_fn(
            "identity",
            vec![],
            prim("Int"),
            SwiftFnInfo {
                is_generic: true,
                ..Default::default()
            },
        );
        for (f, reason) in [
            (&throwing, DeferReason::Throwing),
            (&is_async, DeferReason::Async),
            (&generic, DeferReason::UnbindableGenericFreeFunction),
        ] {
            assert_eq!(defer_reason("TestKit", f, &classes(&[])), reason);
        }
    }

    #[test]
    fn object_and_string_returns_bind_as_a_plus1_handle() {
        // An `id` return, a Foundation-bridged `String` (lossily `Class{NSString}`), and a class
        // instance all bind to the object marshalling (object-bridged-returns-k55): the by-name
        // call bridges `as AnyObject?` and hands JS a +1 handle via `napiMakeRetainedObject`.
        // `id`/`instancetype` need no recognition-set entry; a named class does.
        let known = classes(&["NSString"]);
        for ret in [
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
            ty(TypeRefKind::Instancetype),
            ty(TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            }),
        ] {
            let f = swift_fn("makeThing", vec![], ret, SwiftFnInfo::default());
            let t = plan_with("TestKit", &f, &known);
            assert_eq!(t.ret, RetMarshal::Object);
            let mut s = String::new();
            emit_fn(&mut s, &t);
            assert!(
                s.contains(
                    "return napiMakeRetainedObject(env, (TestKit.makeThing()) as AnyObject?)"
                ),
                "{s}"
            );
        }
    }

    #[test]
    fn object_string_params_and_value_struct_returns_still_defer() {
        // Object/string PARAMS stay deferred this child (the ARC-on-bitcast / Object-ref
        // curated-set frontier) — NonScalarParam.
        let obj_param = swift_fn(
            "consume",
            vec![param(
                "x",
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
            prim("Int"),
            SwiftFnInfo::default(),
        );
        assert_eq!(
            defer_reason("TestKit", &obj_param, &classes(&[])),
            DeferReason::NonScalarParam
        );
        // A non-bridged value-struct return stays deferred (the value-struct / method frontier).
        let struct_ret = swift_fn(
            "makePoint",
            vec![],
            ty(TypeRefKind::Struct {
                name: "SomeValueStruct".into(),
            }),
            SwiftFnInfo::default(),
        );
        assert_eq!(
            defer_reason("TestKit", &struct_ret, &classes(&[])),
            DeferReason::NonScalarReturn
        );
    }

    fn framework(name: &str, functions: Vec<Function>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions,
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn objc_exposed_functions_are_skipped_by_collect() {
        // A plain-C (objc_exposed) function binds directly (aw_ts_fn_*), never trampolined here.
        let mut c_fn = swift_fn(
            "CGColorGetAlpha",
            vec![],
            prim("double"),
            SwiftFnInfo::default(),
        );
        c_fn.objc_exposed = true;
        c_fn.swift_fn = None;
        let native = swift_fn("hypot", vec![], prim("double"), SwiftFnInfo::default());
        let set = collect_trampolines(&[framework("CoreGraphics", vec![c_fn, native])]);
        assert_eq!(set.functions.len(), 1);
        assert_eq!(set.functions[0].swift_name, "hypot");
    }

    #[test]
    fn every_deferral_is_recorded_and_counted() {
        // The honesty clause (ADR-0061 §3): a residual decl the pass does not bind is recorded
        // with a reason and surfaced in the counts — never silently dropped.
        let mut generic = swift_fn("identity", vec![], prim("Int"), SwiftFnInfo::default());
        generic.swift_fn = Some(SwiftFnInfo {
            is_generic: true,
            ..Default::default()
        });
        let operator = swift_fn("/", vec![], prim("double"), SwiftFnInfo::default());
        let bound = swift_fn("hypot", vec![], prim("double"), SwiftFnInfo::default());
        let set = collect_trampolines(&[framework("CoreGraphics", vec![generic, operator, bound])]);
        assert_eq!(set.functions.len(), 1);
        assert_eq!(set.deferred.len(), 2);
        assert_eq!(
            set.defer_counts(),
            vec![
                ("unbindable_generic_free_function", 1),
                ("unrepresentable_name", 1),
            ]
        );
        // The counts reach the generated file, so a reader of the artifact sees them too.
        let out = generate_trampolines_swift(&set);
        assert!(
            out.contains(
                "// Deferred (recorded, never silent): 1 unbindable_generic_free_function, 1 unrepresentable_name."
            ),
            "{out}"
        );
    }

    #[test]
    fn generated_file_imports_each_module_once_and_registers_every_entry() {
        let f = swift_fn("hypot", vec![], prim("double"), SwiftFnInfo::default());
        let g = swift_fn("timestampSeed", vec![], prim("Int"), SwiftFnInfo::default());
        let set = TrampolineSet {
            functions: vec![plan("CoreGraphics", &f), plan("CreateML", &g)],
            deferred: vec![],
        };
        let out = generate_trampolines_swift(&set);
        assert!(out.contains("import CoreGraphics\n"), "{out}");
        assert!(out.contains("import CreateML\n"), "{out}");
        assert!(out.contains("import Foundation\n"), "{out}");
        // Foundation appears once even though it is also a possible module.
        assert_eq!(out.matches("import Foundation").count(), 1, "{out}");
        // These are napi callbacks, so the generated file registers them itself (the k58 shape),
        // and each entry is `private` to it.
        assert!(
            out.contains(
                "func awRegisterGeneratedTrampolines(_ env: napi_env?, _ exports: napi_value?) {"
            ),
            "{out}"
        );
        for t in &set.functions {
            let name = &t.entry;
            assert!(out.contains(&format!("private func {name}(")), "{out}");
            assert!(
                out.contains(&format!("napiDefine(env, exports, \"{name}\", {name})")),
                "missing registration for {name}"
            );
        }
        assert!(
            out.contains("// 2 generated Swift-native residual trampolines."),
            "{out}"
        );
    }

    /// Every `aw_ts_swift_*` token referenced in `text` (the emitted call sites), skipping the
    /// bare `aw_ts_swift_*` prefix that appears in the emitted banner comment.
    fn referenced_entries(text: &str) -> BTreeSet<String> {
        let mut out = BTreeSet::new();
        let mut rest = text;
        while let Some(pos) = rest.find("aw_ts_swift_") {
            let tail = &rest[pos..];
            let end = tail
                .find(|c: char| !c.is_ascii_alphanumeric() && c != '_')
                .unwrap_or(tail.len());
            if end > "aw_ts_swift_".len() {
                out.insert(tail[..end].to_string());
            }
            rest = &rest[pos + end..];
        }
        out
    }

    #[test]
    fn collection_mirrors_the_emitted_call_sites_exactly() {
        // THE STRONG MIRROR INVARIANT (the k58 form, available here because the `.ts` call sites
        // name these entries): the entry set the collection computes == the entry names the
        // rendered `.ts` bodies reference. A referenced entry the table lacks is a JS `TypeError`
        // at dispatch time; a collected entry no call site names is dead Swift — and for a Swift
        // operator, a compile error and a name collision.
        //
        // The fixture exercises every arm at once: a bound scalar, a bound CGFloat-in-real-IR-
        // spelling, a bound object return, and one deferral of each kind that has ever been a bug
        // (Swift tuple return, operator name, object param, generic).
        let mut fw = framework(
            "CoreGraphics",
            vec![
                // Binds: () -> Double.
                swift_fn("cbrt", vec![], prim("double"), SwiftFnInfo::default()),
                // Binds: (CGFloat, CGFloat) -> CGFloat, in the real IR's `Class` spelling.
                swift_fn(
                    "hypot",
                    vec![param("_", cgfloat()), param("_", cgfloat())],
                    cgfloat(),
                    SwiftFnInfo::default(),
                ),
                // Binds: () -> CGColor (+1 object handle) — CGColor IS a class the IR declares.
                swift_fn(
                    "makeColor",
                    vec![],
                    ty(TypeRefKind::Class {
                        name: "CGColor".into(),
                        framework: Some("CoreGraphics".into()),
                        params: vec![],
                    }),
                    SwiftFnInfo::default(),
                ),
                // Defers: a Swift tuple return (`Class{Tuple}`, not a declared class).
                swift_fn(
                    "remquo",
                    vec![param("_", cgfloat()), param("_", cgfloat())],
                    ty(TypeRefKind::Class {
                        name: "Tuple".into(),
                        framework: Some("CoreGraphics".into()),
                        params: vec![],
                    }),
                    SwiftFnInfo::default(),
                ),
                // Defers: a Swift operator declaration.
                swift_fn("/", vec![], prim("double"), SwiftFnInfo::default()),
                // Defers: an object param.
                swift_fn(
                    "consume",
                    vec![param(
                        "x",
                        ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    )],
                    prim("Int"),
                    SwiftFnInfo::default(),
                ),
                // Defers: a generic free function (the hard floor).
                swift_fn(
                    "identity",
                    vec![],
                    prim("double"),
                    SwiftFnInfo {
                        is_generic: true,
                        ..Default::default()
                    },
                ),
            ],
        );
        fw.classes = vec![cls("CGColor")];

        let dir = tempfile::tempdir().unwrap();
        emit_framework(
            &fw,
            dir.path(),
            &ClassRegistry::default(),
            &EnumRegistry::default(),
            &ProtocolRegistry::default(),
            &BTreeSet::new(),
        )
        .unwrap();

        let mut referenced = BTreeSet::new();
        for entry in std::fs::read_dir(dir.path().join("coregraphics")).unwrap() {
            let path = entry.unwrap().path();
            if path.extension().is_some_and(|e| e == "ts") {
                referenced.extend(referenced_entries(&std::fs::read_to_string(&path).unwrap()));
            }
        }

        let table = collect_trampolines(std::slice::from_ref(&fw));
        let collected: BTreeSet<String> = table.functions.iter().map(|t| t.entry.clone()).collect();
        assert_eq!(collected, referenced);
        // The known shape of the fixture, spelled out for the reader.
        assert_eq!(
            collected,
            [
                "aw_ts_swift_CoreGraphics_cbrt",
                "aw_ts_swift_CoreGraphics_hypot",
                "aw_ts_swift_CoreGraphics_makeColor",
            ]
            .into_iter()
            .map(String::from)
            .collect()
        );
        // The four deferrals were recorded, not silently dropped.
        assert_eq!(
            table.defer_counts(),
            vec![
                ("deferred_non_scalar_param", 1),
                ("deferred_swift_nominal_return", 1),
                ("unbindable_generic_free_function", 1),
                ("unrepresentable_name", 1),
            ]
        );
    }
}
