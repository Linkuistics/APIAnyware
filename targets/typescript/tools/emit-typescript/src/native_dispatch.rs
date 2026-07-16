//! The **dispatch-shape mapper** — the per-signature ABI contract the emitted
//! method bodies call into (ADR-0054 §1/§4). The TS analogue of racket's
//! `native_dispatch.rs` (ADR-0013), **TS-facing only**: it computes the
//! content-addressed dispatch-entry *name* the emitted `.ts` calls, not the Swift
//! `@_cdecl` body (that is the Step-4 native adapter).
//!
//! ## Two type surfaces, one settled here
//!
//! TypeScript is the first statically-typed target, so a bound method has two type
//! projections (ADR-0055; [`crate::ffi_type_mapping`] owns the first):
//!
//! 1. the **type surface** — the idiomatic `.ts`/`.d.ts` type ([`TsFfiTypeMapper`]);
//! 2. the **dispatch shape** — *this module* — the machine-ABI shape a signature
//!    collapses to, which names the addon's per-signature entry.
//!
//! An emitted body is a *coercion-free* call into one dispatch entry: objects cross
//! as `bigint` handles (unwrapped at the boundary, [`crate::emit_class`]), scalars
//! as their JS primitive. The entry **name** must be scalar-precise (`Int32` and
//! `Int64` are distinct ABIs → distinct entries) and shared byte-for-byte with the
//! future Swift `@_cdecl("aw_ts_msg_…")`, so it is **content-addressed** by the
//! signature — a pure function, no shared counter: two classes that share a
//! signature independently compute the same name (the ADR-0013 precedent).
//!
//! ## Source of truth: the IR `TypeRef`, not a spelling
//!
//! racket parses [`AbiType`] from its FFI spelling (`_id`, `_uint64`) because racket
//! *has* one; TS's "type surface" (`NSString`, `number`) is not an ABI spelling. So
//! [`AbiType::from_type_ref`] classifies the IR [`TypeRef`] directly — the ABI shape
//! is genuinely orthogonal to the type surface (an object is `NSString` on the
//! surface, a `Ptr` handle at the ABI), so this is not redundant with the type
//! mapper. The code scheme is racket's proven, collision-free one.
//!
//! Scope (k18 / k17): the **plain object/scalar/geometry surface** only — no NSError
//! out-param routing, no Swift-value structs, no Swift generation. Blocks/raw
//! pointers are deferred upstream by [`crate::method_filter`]; classified here as
//! `Ptr` (ABI-truthful) for completeness but never reached by an emitted body yet.
//!
//! [`TsFfiTypeMapper`]: crate::ffi_type_mapping::TsFfiTypeMapper

use apianyware_emit::ffi_type_mapping::is_generic_type_param;
use apianyware_types::ir::{Function, Method};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::pod_struct_type;

/// The C-ABI prefix every generated TS dispatch entry carries (ADR-0054 §1). Shares
/// the `aw_ts_` namespace `APIAnywareTypeScript` owns (ADR-0011 hermetic isolation).
pub const ENTRY_PREFIX: &str = "aw_ts_msg_";

/// The largest visible-arg count an error-out (`…_e`) entry can dispatch — the size of
/// `awexc.m`'s cast switch (`AW_ERR_MAX_ARGS`; the two constants must stay equal). A
/// fallible method with more visible args defers ([`NativeSig::error_out_from_method`]).
pub const ERROR_OUT_MAX_ARGS: usize = 8;

/// A by-value geometry struct that crosses the dispatch seam (population A, ADR-0042;
/// the closed set [`crate::ffi_type_mapping::pod_struct_type`] canonicalises to). Each
/// carries a unique [`code`](GeoStruct::code) char for the content-addressed entry
/// name so two distinct struct casts never share an entry. The variants are the
/// **canonical POD names** the type mapper already collapses NS/CG spellings onto.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum GeoStruct {
    CGRect,
    CGPoint,
    CGSize,
    NSRange,
    NSEdgeInsets,
    NSDirectionalEdgeInsets,
    NSAffineTransformStruct,
    CGAffineTransform,
    CGVector,
}

impl GeoStruct {
    /// Parse a **canonical POD name** (the output of
    /// [`crate::ffi_type_mapping::pod_struct_type`]) into a known geometry struct.
    pub fn from_pod_name(name: &str) -> Option<GeoStruct> {
        Some(match name {
            "CGRect" => GeoStruct::CGRect,
            "CGPoint" => GeoStruct::CGPoint,
            "CGSize" => GeoStruct::CGSize,
            "NSRange" => GeoStruct::NSRange,
            "NSEdgeInsets" => GeoStruct::NSEdgeInsets,
            "NSDirectionalEdgeInsets" => GeoStruct::NSDirectionalEdgeInsets,
            "NSAffineTransformStruct" => GeoStruct::NSAffineTransformStruct,
            "CGAffineTransform" => GeoStruct::CGAffineTransform,
            "CGVector" => GeoStruct::CGVector,
            _ => return None,
        })
    }

    /// The single-char entry-name code — chosen (as in racket) from letters no scalar
    /// code uses, so a struct code never collides with a scalar in the concatenated
    /// name. Asserted collision-free in [`tests`]. `pub(crate)`: also read by
    /// `inbound_table.rs`'s `InboundType::code` (`inbound-struct-arg-surface-k123`), which
    /// reuses this exact alphabet so the outbound and inbound code alphabets stay consistent.
    pub(crate) fn code(self) -> char {
        match self {
            GeoStruct::CGRect => 'R',
            GeoStruct::CGPoint => 'O',
            GeoStruct::CGSize => 'Z',
            GeoStruct::NSRange => 'G',
            GeoStruct::NSEdgeInsets => 'E',
            GeoStruct::NSDirectionalEdgeInsets => 'D',
            GeoStruct::NSAffineTransformStruct => 'A',
            GeoStruct::CGAffineTransform => 'T',
            GeoStruct::CGVector => 'V',
        }
    }
}

/// One machine-ABI shape a signature argument/result collapses to. Deliberately
/// coarser than the type surface: every opaque pointer-like (`Class`/`id`/
/// `instancetype`/`Class`-ref/`SEL`/block/raw pointer) is one [`Ptr`](AbiType::Ptr),
/// because at the call ABI they are one register-width pointer. Two shapes keep
/// their identity though they too cross as a pointer: [`CStr`](AbiType::CStr) (the
/// addon marshals `char*` ⇄ JS string) and [`Struct`](AbiType::Struct) (its cast is
/// struct-specific) — distinct codes ⇒ distinct entries.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum AbiType {
    Ptr,
    CStr,
    Bool,
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
    Struct(GeoStruct),
    /// Valid only as a return type.
    Void,
}

impl AbiType {
    /// Classify an IR [`TypeRef`] to its ABI shape, or `None` for a shape with no
    /// static ABI layout (an unknown struct / unresolvable alias — non-routable, the
    /// escape hatch). Pointer-likes collapse to [`Ptr`](AbiType::Ptr); a known
    /// geometry struct/alias to [`Struct`](AbiType::Struct); primitives and
    /// enum-typedef aliases to their scalar shape.
    pub fn from_type_ref(t: &TypeRef) -> Option<AbiType> {
        match &t.kind {
            TypeRefKind::Class { .. }
            | TypeRefKind::Id { .. }
            | TypeRefKind::Instancetype
            | TypeRefKind::ClassRef
            | TypeRefKind::Selector
            | TypeRefKind::Block { .. }
            | TypeRefKind::Pointer
            | TypeRefKind::FunctionPointer { .. } => Some(AbiType::Ptr),
            TypeRefKind::CString => Some(AbiType::CStr),
            TypeRefKind::Primitive { name } => primitive_abi(name),
            TypeRefKind::Struct { name } => pod_struct_type(name)
                .and_then(GeoStruct::from_pod_name)
                .map(AbiType::Struct),
            TypeRefKind::Alias {
                name,
                underlying_primitive,
                ..
            } => alias_abi(name, underlying_primitive.as_deref()),
        }
    }

    /// Whether this shape can cross the **error-out (`…_e`) mechanism** (`awexc.m`,
    /// ADR-0058 §Mechanics). The shim dispatches the visible args as an array of
    /// pointer-width integers (`uintptr_t`) and returns the primary as one — so only
    /// shapes that travel in **integer registers** are routable: an object/SEL pointer,
    /// a `BOOL`, or an integer scalar (bit-pattern packed). A float/double travels in a
    /// v register, a by-value struct spans several, a C string needs a marshalled
    /// buffer, and a `void` primary cannot key failure (Cocoa's "check the return") —
    /// none survive the packing, so a fallible method carrying one **defers**
    /// (`error_out_from_method` → `None`, surfaced by the collection pass — a
    /// mirror-consistent narrowing, never a call site without an entry).
    fn is_error_routable(self) -> bool {
        matches!(
            self,
            AbiType::Ptr
                | AbiType::Bool
                | AbiType::Int8
                | AbiType::UInt8
                | AbiType::Int16
                | AbiType::UInt16
                | AbiType::Int32
                | AbiType::UInt32
                | AbiType::Int64
                | AbiType::UInt64
        )
    }

    /// The single-char code in the content-addressed entry name — the collision-free,
    /// valid-C-identifier tail (racket's proven scheme).
    fn code(self) -> char {
        match self {
            AbiType::Ptr => 'P',
            AbiType::CStr => 'N',
            AbiType::Bool => 'b',
            AbiType::Int8 => 'c',
            AbiType::UInt8 => 'C',
            AbiType::Int16 => 's',
            AbiType::UInt16 => 'S',
            AbiType::Int32 => 'i',
            AbiType::UInt32 => 'I',
            AbiType::Int64 => 'q',
            AbiType::UInt64 => 'Q',
            AbiType::Float => 'f',
            AbiType::Double => 'd',
            AbiType::Struct(g) => g.code(),
            AbiType::Void => 'v',
        }
    }
}

/// The retain-convention axis of a **pointer-shaped (`Ptr`) return** — the three
/// conventions one ABI shape carries at the wrap boundary (ADR-0057 §4).
/// [`AbiType::Ptr`] deliberately collapses `id`/`Class`/`SEL` into one register-width
/// shape, so the entry *name* must carry what the ABI cannot: whether the returned
/// pointer is a wrapped object and, if so, who owns the wrapper's +1. Suffixing the
/// axis onto the content address keeps the three conventions from ever sharing an
/// entry (the k70 defect was exactly that sharing).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum RetainAxis {
    /// A **+0 object** return — the entry folds the wrapper's `objcRetain` in (bare
    /// name); the emitted `.ts` wraps via `__wrapRetained`, which takes an
    /// already-folded +1.
    FoldRetain,
    /// A **+1-convention object** return (the `init`/`new`/`copy`/`mutableCopy`/
    /// `ns_returns_retained` family) — the method's own +1 *is* the wrapper's, so the
    /// `_o` sibling folds nothing; the `.ts` wraps via `__wrapOwned`.
    Owned,
    /// A pointer-shaped return that is **not an object** (`SEL`, the `Class`
    /// metatype) — the emitted `.ts` never wraps it, so the `_n` sibling folds
    /// nothing and hands the raw handle through: retaining a class leaks (nothing
    /// ever releases it), and `objc_retain` on a `SEL` is undefined behaviour.
    NoWrap,
}

/// A full method ABI signature: the receiver (`self`) and `_cmd` (`SEL`) are always
/// the two implicit leading pointers, so `params` holds only the *visible* arguments
/// and `ret` the result.
///
/// `error_out` marks the **`NSError**` out-param** shape (ADR-0058): a fallible
/// `…error:` selector whose trailing `NSError **` is *not* a normal `params` entry —
/// the native `@_cdecl` entry synthesises the `NSError*` cell locally, passes `&err`
/// to `objc_msgSend`, `@catch`es any `NSException`, keys failure on the primary return
/// (nil/`NO`), and hands a structured discriminant back to the boundary. So `params`
/// holds only the *visible* arguments (the trailing error cell removed); the error
/// crossing is encoded by this flag, which adds the `_e` suffix to [`entry_name`] so an
/// error-out entry never collides with the same visible signature dispatched plainly
/// (the racket `NativeSig.error_out` precedent).
///
/// [`entry_name`]: NativeSig::entry_name
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct NativeSig {
    pub params: Vec<AbiType>,
    pub ret: AbiType,
    pub error_out: bool,
}

impl NativeSig {
    /// The ABI signature of a method's *visible* params + return, or `None` if any
    /// param/return has no static ABI shape (an unknown struct/alias — non-routable)
    /// or a `void` appears in a parameter position (only valid as a return).
    pub fn from_method(method: &Method) -> Option<NativeSig> {
        let mut params = Vec::with_capacity(method.params.len());
        for p in &method.params {
            let t = AbiType::from_type_ref(&p.param_type)?;
            if t == AbiType::Void {
                return None;
            }
            params.push(t);
        }
        let ret = AbiType::from_type_ref(&method.return_type)?;
        Some(NativeSig {
            params,
            ret,
            error_out: false,
        })
    }

    /// The ABI signature of a **free function**'s params + return, or `None` if any has no
    /// static ABI shape (an unknown struct/alias) or a `void` appears in a parameter
    /// position. The free-function dual of [`from_method`](NativeSig::from_method), and the
    /// **routability gate** [`crate::method_filter::is_supported_function`] closes on.
    ///
    /// Two things differ from a method's signature, both structural:
    ///
    /// - **No implicit `self`/`_cmd`.** A method multiplexes through `objc_msgSend`, which
    ///   always takes the receiver and selector first; a C function is called by its own
    ///   address, so `params` *is* the whole argument list.
    /// - **No entry name comes from here.** A method's entry is content-addressed by these
    ///   codes ([`entry_name`](NativeSig::entry_name)); a free function's is content-addressed
    ///   by its **symbol** ([`function_entry_name`]). The signature still matters — it is what
    ///   the addon's `@convention(c)` cast must be — but it names nothing.
    ///
    /// `error_out` is always `false`: a free function's `NSError**` out-param arrives as an
    /// anonymous raw [`TypeRefKind::Pointer`] with no owning class to key a selector set on,
    /// so it defers with every other raw pointer (ADR-0058 is a per-class enrichment fact).
    pub fn from_function(function: &Function) -> Option<NativeSig> {
        let mut params = Vec::with_capacity(function.params.len());
        for p in &function.params {
            let t = AbiType::from_type_ref(&p.param_type)?;
            if t == AbiType::Void {
                return None;
            }
            params.push(t);
        }
        let ret = AbiType::from_type_ref(&function.return_type)?;
        Some(NativeSig {
            params,
            ret,
            error_out: false,
        })
    }

    /// The **`NSError**` out-param** variant: the signature of the method's *visible*
    /// params (all but the trailing `NSError **` cell, which the caller confirmed is a
    /// raw pointer, [`crate::method_filter::is_error_out_method`]) + the primary return
    /// (ADR-0058). `None` when the method has no params (nothing to drop — not a real
    /// error-out method), or when the visible signature cannot cross the `awexc.m`
    /// `@try`/`@catch` mechanism: every visible param **and the primary return** must be
    /// [error-routable](AbiType::is_error_routable) (pointer / BOOL / integer scalar —
    /// the shim packs args into a `uintptr_t` array and returns the primary in one), and
    /// the visible arg count is bounded by [`ERROR_OUT_MAX_ARGS`] (the shim's dispatch
    /// switch). A fallible method outside that frontier **defers** — the admission gate
    /// ([`crate::method_filter::is_supported_method_ctx`]) shares this decision, so the
    /// emitted call sites and the generated `…_e` table agree by construction. The
    /// dropped trailing pointer is *not* re-validated here (it is the error cell, an
    /// implicit `&err` the native entry owns), only removed.
    pub fn error_out_from_method(method: &Method) -> Option<NativeSig> {
        if method.params.is_empty() {
            return None;
        }
        let visible = &method.params[..method.params.len() - 1];
        if visible.len() > ERROR_OUT_MAX_ARGS {
            return None; // beyond the awexc.m dispatch switch — defers, recorded
        }
        let mut params = Vec::with_capacity(visible.len());
        for p in visible {
            let t = AbiType::from_type_ref(&p.param_type)?;
            if !t.is_error_routable() {
                return None;
            }
            params.push(t);
        }
        let ret = AbiType::from_type_ref(&method.return_type)?;
        if !ret.is_error_routable() {
            return None; // v-register / struct / void / C-string primary — defers
        }
        Some(NativeSig {
            params,
            ret,
            error_out: true,
        })
    }

    /// The stable, content-addressed entry name, e.g. `aw_ts_msg_PQ_v`
    /// (`(Ptr, UInt64) -> Void`). A no-arg signature uses `0` for the empty param
    /// list: `aw_ts_msg_0_Q` (`() -> UInt64`). A pure function of the signature (plus
    /// the two axes below) — no shared counter — so the emitted `.ts` call and the
    /// Swift `@_cdecl` agree.
    ///
    /// Two orthogonal axes append single-letter suffixes after the ret code; `o`, `n`
    /// and `e` all sit outside the code alphabet (the ret is one char, and none is a
    /// scalar/struct code), so a suffix never collides with a signature code:
    ///
    /// - **the retain axis** ([`RetainAxis`], ADR-0057 §4) — present exactly for a
    ///   pointer (`Ptr`) return, `None` otherwise (a scalar carries no retain
    ///   convention; asserted below). [`FoldRetain`](RetainAxis::FoldRetain) (+0
    ///   object) keeps the bare name — its native entry folds the +1 in;
    ///   [`Owned`](RetainAxis::Owned) (+1 object) routes to the distinct non-folding
    ///   `_o` sibling so a +1 method is never double-retained;
    ///   [`NoWrap`](RetainAxis::NoWrap) (non-object pointer — `SEL`/`Class`) routes to
    ///   the non-folding, non-wrapping `_n` sibling so a pointer that is no object is
    ///   never retained at all (k70).
    /// - **`error_out`** (`_e`) — the `NSError**` out-param axis (ADR-0058), so a
    ///   fallible `(NSString) -> BOOL` `…error:` is `aw_ts_msg_P_b_e`, distinct from its
    ///   plain sibling `aw_ts_msg_P_b` (the racket precedent).
    ///
    /// The retain suffix precedes `_e` (a +1 fallible `init…error:` factory is
    /// `…_o_e`; `_o` and `_n` are mutually exclusive states of one axis).
    pub fn entry_name(&self, axis: Option<RetainAxis>) -> String {
        debug_assert_eq!(
            axis.is_some(),
            matches!(self.ret, AbiType::Ptr),
            "the retain axis exists exactly for a pointer (Ptr) return"
        );
        let mut name = format!("{ENTRY_PREFIX}{}", self.sig_code());
        match axis {
            Some(RetainAxis::Owned) => name.push_str("_o"),
            Some(RetainAxis::NoWrap) => name.push_str("_n"),
            Some(RetainAxis::FoldRetain) | None => {}
        }
        if self.error_out {
            name.push_str("_e");
        }
        name
    }

    /// The bare `<param-codes>_<ret-code>` content address, with `0` for an empty param list
    /// (`0_Q`, `PQ_v`, `dd_d`) — the tail [`entry_name`](NativeSig::entry_name) prefixes.
    ///
    /// Exposed for the **free-function table**, whose exports are keyed per *symbol*
    /// ([`function_entry_name`]) but whose Swift bodies are shared per *signature*
    /// (`aw_ts_fnsig_<sig_code>`, ADR-0054 §1a). That is a **private Swift symbol name**, never a
    /// wire name, so it reuses this alphabet rather than inventing a second one.
    pub fn sig_code(&self) -> String {
        let params: String = if self.params.is_empty() {
            "0".to_string()
        } else {
            self.params.iter().map(|t| t.code()).collect()
        };
        format!("{params}_{}", self.ret.code())
    }
}

/// The C-ABI prefix every generated **free-function** dispatch entry carries — the
/// free-function dual of [`ENTRY_PREFIX`] (ADR-0054 §1). A free C function is a distinct
/// symbol (unlike a method, which multiplexes through one `objc_msgSend` recast), so its
/// entry is content-addressed by the **symbol name**, not the ABI-signature codes: one
/// `@_cdecl` wrapper per C function, named `aw_ts_fn_<symbol>`, calling the symbol directly
/// (the trampoline-elided limit for a named C export). Shares the `aw_ts_` namespace
/// `APIAnywareTypeScript` owns (ADR-0011).
pub const FN_ENTRY_PREFIX: &str = "aw_ts_fn_";

/// The prefix every generated **Swift-native `s:` residual** trampoline entry carries
/// (ADR-0027 ported to TS/N-API, `fn-trampoline-spine-k53`). A `objc_exposed == false` free
/// function has **no C symbol** — it is reachable only across the Swift ABI (ADR-0025), so its
/// entry is a generated napi-callback `@_cdecl`-shaped trampoline that `import`s the owning
/// framework and calls the API **by name**. Distinct from the plain-C [`FN_ENTRY_PREFIX`]
/// (`aw_ts_fn_`, an ObjC/C symbol dispatched directly): the Swift-native residual is
/// content-addressed by **module + symbol** (a bare name can collide across modules —
/// `nan` in CoreGraphics and _DarwinFoundation1), so its entry keys on both. Shares the `aw_ts_`
/// namespace `APIAnywareTypeScript` owns (ADR-0011).
pub const SWIFT_FN_ENTRY_PREFIX: &str = "aw_ts_swift_";

/// The addon entry a **Swift-native** free function's emitted body calls —
/// `aw_ts_swift_<Module>_<name>`, content-addressed by module + symbol
/// ([`SWIFT_FN_ENTRY_PREFIX`]). A pure function of `(module, name)`, shared byte-for-byte with
/// the generated Swift trampoline (`crate::trampoline`), so the emitted `.ts` call and the
/// napi-callback trampoline agree with no shared counter. (Overload disambiguation — a short
/// content hash when a `(module, name)` is overloaded within its module, ADR-0027 — is a
/// follow-up refinement; the spine's residual has no same-module overloads.)
pub fn swift_function_entry_name(module: &str, name: &str) -> String {
    format!(
        "{SWIFT_FN_ENTRY_PREFIX}{}_{}",
        sanitize_entry_fragment(module),
        sanitize_entry_fragment(name)
    )
}

/// Sanitise a module/name fragment into a valid C-identifier tail (digester names are already
/// identifier-shaped, but be defensive about stray punctuation — the racket `sanitize` precedent).
fn sanitize_entry_fragment(fragment: &str) -> String {
    fragment
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '_' })
        .collect()
}

/// The C-ABI prefix every generated **constant-read** dispatch entry carries (ADR-0055 §6,
/// the pointer-valued / scalar-global read). A constant global's *value* is a link-time
/// fact (ADR-0025), so it is read through the addon at module load, content-addressed by
/// the single **result ABI shape** — `aw_ts_const_P` reads an object-pointer global (the
/// raw handle, wrapped borrowed), `aw_ts_const_d`/`aw_ts_const_q`/… a scalar global (its JS
/// primitive). The constant-read dual of the method-dispatch entry: same content-addressing
/// discipline, keyed on the result shape because a constant has no arguments.
///
/// The result shape alone is not the whole story for a pointer read (`P`): see the
/// **ownership axis** on [`constant_entry_name`] (`pointer-constant-ownership-k92`).
pub const CONST_ENTRY_PREFIX: &str = "aw_ts_const_";

/// The addon entry for an **array-typed global read as a banner string** — the symbol's own
/// address IS the array (`array-constant-symbol-value-k109`), not a stored pointer to load
/// through the way [`CONST_ENTRY_PREFIX`]'s ordinary `P`/`P_n` reads are. `Constant::array_element`
/// names the one population this leaf gives a first-pass surface: a byte/char element
/// (`unsigned char[]`/`char[]`, the measured *VersionString banner shape) reads as a
/// NUL-terminated C string straight off the `dlsym`'d address — no intervening load. Any other
/// element (a `CGFloat[6]` geometry matrix, say) has no first-pass surface yet and defers
/// (`emit_constants.rs`), so this is the array population's only entry — a fixed name, not a
/// content-addressed family, since there is exactly one shape to read this leaf models.
pub const ARRAY_STRING_CONST_ENTRY: &str = "aw_ts_const_N_a";

/// The addon entry a free function's emitted body calls — `aw_ts_fn_<name>`, content-
/// addressed by the C symbol name ([`FN_ENTRY_PREFIX`]). A pure function of the name, shared
/// byte-for-byte with the Step-4 Swift `@_cdecl("aw_ts_fn_<name>")`, so the emitted `.ts`
/// call and the native wrapper agree with no shared counter.
pub fn function_entry_name(name: &str) -> String {
    format!("{FN_ENTRY_PREFIX}{name}")
}

/// The addon entry a constant's module-load read calls, content-addressed by the constant's
/// **result ABI shape** ([`CONST_ENTRY_PREFIX`]) plus, for a pointer result, the **ownership
/// axis** — `Some("aw_ts_const_<code>")` for a shape with a static ABI layout (an object
/// pointer `P`, a scalar, a C string `N`, a geometry struct), `None` for a `void` /
/// non-routable type (an unknown struct/alias — deferred by the constant emitter).
///
/// `is_object` is the same wrap-boundary predicate every other retain-fold decision in this
/// target reads (`FfiTypeMapper::is_object_type` — `Class`/`Id`/`Instancetype`; ADR-0057 §4's
/// rule, "the fold gates on the wrap boundary, never on the ABI shape being `Ptr`", applied
/// here to constants for the first time, `pointer-constant-ownership-k92`). `AbiType`
/// deliberately collapses every pointer-like — an object, a `Class`/`SEL` metatype, a block, a
/// raw `void *` — onto one ABI code (`P`), because that collapse is exactly right for the
/// *call shape*; it says nothing about who owns the pointee, which is a wrap-boundary fact the
/// ABI code was never meant to carry. So a pointer result forks on `is_object`: `true` keeps
/// the bare `aw_ts_const_P` (the object arm — the addon folds a `+1` retain, mirroring the
/// method-dispatch `RetainAxis::FoldRetain` bare name), `false` routes to the distinct
/// `aw_ts_const_P_n` (the opaque-pointer arm — no retain, mirroring `RetainAxis::NoWrap`'s `_n`
/// suffix): retaining a non-object dereferences a nonexistent `isa` and crashes or corrupts
/// (measured: `CoreSpotlightVersionString`, a `unsigned char[]` array symbol whose "pointer
/// value" is ASCII banner text). Every other result shape ignores `is_object` — a scalar/
/// C-string/struct read carries no retain convention.
pub fn constant_entry_name(t: &TypeRef, is_object: bool) -> Option<String> {
    match AbiType::from_type_ref(t)? {
        AbiType::Void => None,
        AbiType::Ptr if !is_object => Some(format!("{CONST_ENTRY_PREFIX}P_n")),
        abi => Some(format!("{CONST_ENTRY_PREFIX}{}", abi.code())),
    }
}

/// A C/ObjC primitive name → its ABI scalar shape, or `None` for an unknown
/// primitive. Widths follow macOS arm64 (`NSInteger`/`NSUInteger` are 64-bit); a bare
/// `pointer` primitive is an opaque [`Ptr`](AbiType::Ptr).
fn primitive_abi(name: &str) -> Option<AbiType> {
    Some(match normalize_primitive_name(name).as_str() {
        "void" => AbiType::Void,
        "bool" => AbiType::Bool,
        "int8" => AbiType::Int8,
        "uint8" => AbiType::UInt8,
        "int16" => AbiType::Int16,
        "uint16" => AbiType::UInt16,
        "int32" => AbiType::Int32,
        "uint32" => AbiType::UInt32,
        "int64" | "nsinteger" => AbiType::Int64,
        "uint64" | "nsuinteger" => AbiType::UInt64,
        "float" => AbiType::Float,
        "double" => AbiType::Double,
        "pointer" => AbiType::Ptr,
        _ => return None,
    })
}

/// A typedef alias → ABI shape: geometry aliases (libclang classifies `NSRect`/
/// `CGRect` as typedefs) → the geometry struct; ObjC generic type params
/// (`ObjectType`) → an object [`Ptr`](AbiType::Ptr); an enum-typedef alias → its
/// resolved underlying scalar; anything else → `None` (non-routable).
fn alias_abi(name: &str, underlying_primitive: Option<&str>) -> Option<AbiType> {
    if let Some(pod) = pod_struct_type(name) {
        return GeoStruct::from_pod_name(pod).map(AbiType::Struct);
    }
    if name.ends_with("Type") && is_generic_type_param(name) {
        return Some(AbiType::Ptr);
    }
    underlying_primitive.and_then(primitive_abi)
}

/// Strip a framework-qualified prefix (`Swift.Bool` → `bool`) and lowercase, so the
/// digester's qualified names match the ObjC extractor's canonical ones (mirrors the
/// shared/type-surface `normalize`).
fn normalize_primitive_name(name: &str) -> String {
    let unqualified = name.rsplit_once('.').map_or(name, |(_, suffix)| suffix);
    unqualified.to_ascii_lowercase()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Method, Param};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn abi(kind: TypeRefKind) -> Option<AbiType> {
        AbiType::from_type_ref(&ty(kind))
    }

    fn method(selector: &str, params: Vec<Param>, ret: TypeRef) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: false,
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
            objc_exposed: true,
            swift_fn: None,
        }
    }

    fn param(kind: TypeRefKind) -> Param {
        Param {
            name: "x".into(),
            param_type: ty(kind),
        }
    }

    #[test]
    fn pointer_likes_collapse_to_one_ptr() {
        // Objects, id, instancetype, Class metatype, SEL, blocks, raw pointers all
        // cross as one register-width pointer — the 213→160 ABI collapse (racket
        // FINDINGS §2b) made structural.
        for kind in [
            TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
            TypeRefKind::Id {
                protocols: Vec::new(),
            },
            TypeRefKind::Instancetype,
            TypeRefKind::ClassRef,
            TypeRefKind::Selector,
            TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(TypeRef::void()),
            },
            TypeRefKind::Pointer,
        ] {
            assert_eq!(abi(kind), Some(AbiType::Ptr));
        }
        // A C string keeps its own shape (the addon marshals char* ⇄ JS string).
        assert_eq!(abi(TypeRefKind::CString), Some(AbiType::CStr));
    }

    #[test]
    fn primitives_map_to_precise_abi_widths() {
        let p = |n: &str| abi(TypeRefKind::Primitive { name: n.into() });
        assert_eq!(p("void"), Some(AbiType::Void));
        assert_eq!(p("bool"), Some(AbiType::Bool));
        assert_eq!(p("int32"), Some(AbiType::Int32));
        assert_eq!(p("uint32"), Some(AbiType::UInt32));
        assert_eq!(p("int64"), Some(AbiType::Int64));
        assert_eq!(p("uint64"), Some(AbiType::UInt64));
        assert_eq!(p("float"), Some(AbiType::Float));
        assert_eq!(p("double"), Some(AbiType::Double));
        // NSInteger/NSUInteger are 64-bit on arm64; Swift-qualified names normalise.
        assert_eq!(p("NSInteger"), Some(AbiType::Int64));
        assert_eq!(p("NSUInteger"), Some(AbiType::UInt64));
        assert_eq!(p("Swift.Bool"), Some(AbiType::Bool));
        // An unknown primitive has no static ABI shape.
        assert_eq!(p("__int128"), None);
    }

    #[test]
    fn geometry_structs_and_aliases_map_to_struct_shapes() {
        // libclang emits geometry as both Struct and Alias; NS/CG pairs canonicalise.
        assert_eq!(
            abi(TypeRefKind::Struct {
                name: "NSRect".into()
            }),
            Some(AbiType::Struct(GeoStruct::CGRect))
        );
        assert_eq!(
            abi(TypeRefKind::Struct {
                name: "CGRect".into()
            }),
            Some(AbiType::Struct(GeoStruct::CGRect))
        );
        assert_eq!(
            abi(TypeRefKind::Alias {
                name: "NSRange".into(),
                framework: None,
                underlying_primitive: None,
            }),
            Some(AbiType::Struct(GeoStruct::NSRange))
        );
        // A non-geometry struct has no static layout here — non-routable.
        assert_eq!(
            abi(TypeRefKind::Struct {
                name: "NSDecimal".into()
            }),
            None
        );
    }

    #[test]
    fn aliases_generics_and_enums() {
        // A generic ObjC type param is an object → Ptr.
        assert_eq!(
            abi(TypeRefKind::Alias {
                name: "ObjectType".into(),
                framework: None,
                underlying_primitive: None,
            }),
            Some(AbiType::Ptr)
        );
        // An enum-typedef alias crosses as its resolved underlying scalar.
        assert_eq!(
            abi(TypeRefKind::Alias {
                name: "NSStringEncoding".into(),
                framework: None,
                underlying_primitive: Some("uint64".into()),
            }),
            Some(AbiType::UInt64)
        );
        // An alias with no geometry, no generic shape, no underlying → non-routable.
        assert_eq!(
            abi(TypeRefKind::Alias {
                name: "SomeOpaqueAlias".into(),
                framework: None,
                underlying_primitive: None,
            }),
            None
        );
    }

    #[test]
    fn entry_name_is_content_addressed() {
        let sig = |params: Vec<AbiType>, ret: AbiType| NativeSig {
            params,
            ret,
            error_out: false,
        };
        // () -> UInt64  (e.g. -length): the empty param list is `0`.
        assert_eq!(
            sig(vec![], AbiType::UInt64).entry_name(None),
            "aw_ts_msg_0_Q"
        );
        // (Ptr) -> Ptr  (e.g. -initWithString:): object in, object out.
        assert_eq!(
            sig(vec![AbiType::Ptr], AbiType::Ptr).entry_name(Some(RetainAxis::FoldRetain)),
            "aw_ts_msg_P_P"
        );
        // (UInt64) -> Void  (e.g. -setLength:).
        assert_eq!(
            sig(vec![AbiType::UInt64], AbiType::Void).entry_name(None),
            "aw_ts_msg_Q_v"
        );
        // (Ptr, UInt64) -> Void  (e.g. -insertObject:atIndex:).
        assert_eq!(
            sig(vec![AbiType::Ptr, AbiType::UInt64], AbiType::Void).entry_name(None),
            "aw_ts_msg_PQ_v"
        );
        // (Double, Double) -> Double.
        assert_eq!(
            sig(vec![AbiType::Double, AbiType::Double], AbiType::Double).entry_name(None),
            "aw_ts_msg_dd_d"
        );
        // A struct return carries its identity in the result code.
        assert_eq!(
            sig(vec![], AbiType::Struct(GeoStruct::CGRect)).entry_name(None),
            "aw_ts_msg_0_R"
        );
    }

    #[test]
    fn owned_object_returns_route_to_a_distinct_non_folding_entry() {
        let sig = |params: Vec<AbiType>, ret: AbiType, error_out: bool| NativeSig {
            params,
            ret,
            error_out,
        };
        // A +1 object return (`-copy`/`-mutableCopy`/`-initWith…`) gets the `_o` suffix so it
        // routes to a NON-folding native entry, distinct from its +0 sibling (ADR-0057 §4).
        assert_eq!(
            sig(vec![], AbiType::Ptr, false).entry_name(Some(RetainAxis::FoldRetain)),
            "aw_ts_msg_0_P" // +0: the native entry folds the +1 in
        );
        assert_eq!(
            sig(vec![], AbiType::Ptr, false).entry_name(Some(RetainAxis::Owned)),
            "aw_ts_msg_0_P_o" // +1: non-folding — the method's own +1 is the wrapper's +1
        );
        // `(id) -> id` +1 (e.g. `-initWithParent:`) vs its +0 sibling.
        assert_eq!(
            sig(vec![AbiType::Ptr], AbiType::Ptr, false).entry_name(Some(RetainAxis::Owned)),
            "aw_ts_msg_P_P_o"
        );
        // The `_o` axis is orthogonal to `_e`, and precedes it: a +1 fallible `init…error:`.
        assert_eq!(
            sig(vec![AbiType::Ptr], AbiType::Ptr, true).entry_name(Some(RetainAxis::Owned)),
            "aw_ts_msg_P_P_o_e"
        );
        // A +0 fallible object factory keeps just `_e` (no double-retain to avoid).
        assert_eq!(
            sig(vec![AbiType::Ptr], AbiType::Ptr, true).entry_name(Some(RetainAxis::FoldRetain)),
            "aw_ts_msg_P_P_e"
        );
    }

    #[test]
    fn non_object_ptr_returns_route_to_the_no_wrap_sibling() {
        let sig = |params: Vec<AbiType>, ret: AbiType, error_out: bool| NativeSig {
            params,
            ret,
            error_out,
        };
        // A pointer-shaped return that is not an object (`SEL`/`Class`) gets the `_n`
        // suffix so it routes to a non-folding, non-wrapping entry — distinct from the
        // folding bare name AND from the owned `_o` sibling (k70, ADR-0057 §4).
        assert_eq!(
            sig(vec![], AbiType::Ptr, false).entry_name(Some(RetainAxis::NoWrap)),
            "aw_ts_msg_0_P_n"
        );
        // `_n` slots where `_o` does (one axis, mutually exclusive states), ahead of `_e`.
        assert_eq!(
            sig(vec![AbiType::Ptr], AbiType::Ptr, true).entry_name(Some(RetainAxis::NoWrap)),
            "aw_ts_msg_P_P_n_e"
        );
    }

    #[test]
    #[should_panic(expected = "pointer (Ptr) return")]
    fn retain_axis_on_a_scalar_return_is_a_bug() {
        // A scalar carries no retain convention, so the axis must be `None` for a
        // non-Ptr return — the emitter computes it from one predicate
        // (`method_retain_axis`, matching the wrap-primitive decision).
        let sig = NativeSig {
            params: vec![],
            ret: AbiType::UInt64,
            error_out: false,
        };
        let _ = sig.entry_name(Some(RetainAxis::Owned));
    }

    #[test]
    fn function_entry_is_content_addressed_by_symbol_name() {
        // A free function's entry is its C symbol name (distinct symbols → distinct
        // entries), not the ABI-signature codes methods share.
        assert_eq!(
            function_entry_name("CGColorCreate"),
            "aw_ts_fn_CGColorCreate"
        );
        assert_eq!(function_entry_name("NSMakeRange"), "aw_ts_fn_NSMakeRange");
    }

    #[test]
    fn swift_function_entry_is_content_addressed_by_module_and_symbol() {
        // A Swift-native residual function's entry keys on module + symbol (a bare name can
        // collide across modules), distinct from the plain-C `aw_ts_fn_<name>`.
        assert_eq!(
            swift_function_entry_name("CoreGraphics", "hypot"),
            "aw_ts_swift_CoreGraphics_hypot"
        );
        assert_eq!(
            swift_function_entry_name("TestKit", "TKSwiftScale"),
            "aw_ts_swift_TestKit_TKSwiftScale"
        );
        // Stray punctuation in a fragment sanitises to `_` (valid C identifier tail).
        assert_eq!(
            swift_function_entry_name("_Concurrency", "with.detached"),
            "aw_ts_swift__Concurrency_with_detached"
        );
    }

    #[test]
    fn constant_entry_is_content_addressed_by_result_shape() {
        // An object-pointer global reads through the `P` entry (wrapped borrowed by the
        // emitter); a scalar global through its scalar-code entry; a C-string global `N`.
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
                true
            ),
            Some("aw_ts_const_P".to_string())
        );
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Id {
                    protocols: Vec::new()
                }),
                true
            ),
            Some("aw_ts_const_P".to_string())
        );
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Primitive {
                    name: "double".into()
                }),
                false
            ),
            Some("aw_ts_const_d".to_string())
        );
        // An enum-typedef alias reads by its underlying scalar width.
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Alias {
                    name: "NSComparisonResult".into(),
                    framework: None,
                    underlying_primitive: Some("int64".into()),
                }),
                false
            ),
            Some("aw_ts_const_q".to_string())
        );
        assert_eq!(
            constant_entry_name(&ty(TypeRefKind::CString), false),
            Some("aw_ts_const_N".to_string())
        );
        // `void` and a non-routable alias have no constant-read entry.
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Primitive {
                    name: "void".into()
                }),
                false
            ),
            None
        );
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Alias {
                    name: "SomeOpaqueAlias".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
                false
            ),
            None
        );
    }

    #[test]
    fn array_string_const_entry_is_a_fixed_name_distinct_from_n() {
        // The array-symbol population has exactly one first-pass shape (a byte/char element read
        // as a string), so its entry is a fixed name, not content-addressed — and it must differ
        // from `aw_ts_const_N` (a *stored* char* global, which loads THROUGH its address).
        assert_eq!(ARRAY_STRING_CONST_ENTRY, "aw_ts_const_N_a");
        assert_ne!(
            ARRAY_STRING_CONST_ENTRY,
            constant_entry_name(&ty(TypeRefKind::CString), false).unwrap()
        );
    }

    #[test]
    fn constant_entry_forks_on_ownership_for_a_pointer_result() {
        // The species this leaf fixes (k92): AbiType collapses every pointer-like onto one `P`
        // code, so the entry name alone must carry ownership — not the caller's classify arm.
        // A raw C pointer / opaque handle is NOT an object: routes to the non-folding `_n`
        // sibling so the addon never retains it (retaining a non-object dereferences a
        // nonexistent `isa` — measured crash: `CoreSpotlightVersionString`).
        assert_eq!(
            constant_entry_name(&ty(TypeRefKind::Pointer), false),
            Some("aw_ts_const_P_n".to_string())
        );
        // A block-typed global is likewise pointer-shaped and not an object.
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Block {
                    params: vec![],
                    return_type: Box::new(TypeRef::void()),
                }),
                false
            ),
            Some("aw_ts_const_P_n".to_string())
        );
        // An `id`/`Class`/`instancetype` global IS an object: keeps the bare, retain-folding
        // `P` entry — distinct from its `_n` sibling.
        assert_eq!(
            constant_entry_name(
                &ty(TypeRefKind::Id {
                    protocols: Vec::new()
                }),
                true
            ),
            Some("aw_ts_const_P".to_string())
        );
    }

    #[test]
    fn all_codes_are_collision_free() {
        // Every scalar/pointer/void code must differ from every other AND from every
        // geometry code, or a concatenated entry name is ambiguous.
        let scalars = [
            AbiType::Ptr,
            AbiType::CStr,
            AbiType::Bool,
            AbiType::Int8,
            AbiType::UInt8,
            AbiType::Int16,
            AbiType::UInt16,
            AbiType::Int32,
            AbiType::UInt32,
            AbiType::Int64,
            AbiType::UInt64,
            AbiType::Float,
            AbiType::Double,
            AbiType::Void,
        ];
        let geo = [
            GeoStruct::CGRect,
            GeoStruct::CGPoint,
            GeoStruct::CGSize,
            GeoStruct::NSRange,
            GeoStruct::NSEdgeInsets,
            GeoStruct::NSDirectionalEdgeInsets,
            GeoStruct::NSAffineTransformStruct,
            GeoStruct::CGAffineTransform,
            GeoStruct::CGVector,
        ];
        let mut codes: Vec<char> = scalars.iter().map(|t| t.code()).collect();
        codes.extend(geo.iter().map(|g| g.code()));
        let mut deduped = codes.clone();
        deduped.sort_unstable();
        deduped.dedup();
        assert_eq!(deduped.len(), codes.len(), "code collision: {codes:?}");
    }

    #[test]
    fn from_method_uses_visible_params_only() {
        // -objectAtIndex: (NSUInteger) -> id : self+_cmd are implicit, so the sig is
        // (UInt64) -> Ptr.
        let m = method(
            "objectAtIndex:",
            vec![param(TypeRefKind::Primitive {
                name: "NSUInteger".into(),
            })],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        let sig = NativeSig::from_method(&m).unwrap();
        assert_eq!(
            sig.entry_name(Some(RetainAxis::FoldRetain)),
            "aw_ts_msg_Q_P"
        );

        // -length () -> NSUInteger.
        let m = method(
            "length",
            vec![],
            ty(TypeRefKind::Primitive {
                name: "NSUInteger".into(),
            }),
        );
        assert_eq!(
            NativeSig::from_method(&m).unwrap().entry_name(None),
            "aw_ts_msg_0_Q"
        );
    }

    #[test]
    fn from_method_rejects_non_routable_and_void_param() {
        // A non-geometry struct return → non-routable.
        let m = method(
            "decimalValue",
            vec![],
            ty(TypeRefKind::Struct {
                name: "NSDecimal".into(),
            }),
        );
        assert_eq!(NativeSig::from_method(&m), None);
        // A `void` parameter is invalid (void is only a return shape).
        let m = method(
            "weird:",
            vec![param(TypeRefKind::Primitive {
                name: "void".into(),
            })],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        assert_eq!(NativeSig::from_method(&m), None);
    }

    #[test]
    fn error_out_sig_drops_the_trailing_pointer_and_suffixes_e() {
        // -writeToFile:(NSString)error:(NSError**) -> BOOL : the trailing NSError** cell
        // drops, the visible sig is (Ptr) -> Bool, and the entry gets the `_e` suffix so
        // it never collides with a plain `(NSString) -> BOOL` sibling.
        let m = method(
            "writeToFile:error:",
            vec![
                param(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
                param(TypeRefKind::Pointer), // the NSError** cell
            ],
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        let sig = NativeSig::error_out_from_method(&m).unwrap();
        assert_eq!(sig.params, vec![AbiType::Ptr]);
        assert_eq!(sig.ret, AbiType::Bool);
        assert!(sig.error_out);
        assert_eq!(sig.entry_name(None), "aw_ts_msg_P_b_e");
        // The plain sibling (same visible signature, no error channel) is distinct.
        let plain = method(
            "writeToFile:",
            vec![param(TypeRefKind::Id {
                protocols: Vec::new(),
            })],
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        assert_eq!(
            NativeSig::from_method(&plain).unwrap().entry_name(None),
            "aw_ts_msg_P_b"
        );
    }

    #[test]
    fn error_out_sig_with_object_primary_and_no_visible_args() {
        // -dataFromError:(NSError**) -> NSData : one param (the error cell), so the visible
        // signature is 0-arg; the object primary crosses as Ptr → `aw_ts_msg_0_P_e`.
        let m = method(
            "dataWithError:",
            vec![param(TypeRefKind::Pointer)],
            ty(TypeRefKind::Class {
                name: "NSData".into(),
                framework: None,
                params: vec![],
            }),
        );
        let sig = NativeSig::error_out_from_method(&m).unwrap();
        assert!(sig.params.is_empty());
        assert_eq!(sig.ret, AbiType::Ptr);
        assert_eq!(
            sig.entry_name(Some(RetainAxis::FoldRetain)),
            "aw_ts_msg_0_P_e"
        );
    }

    #[test]
    fn error_out_sig_rejects_non_error_routable_shapes() {
        // A double visible param travels in a v register — awexc.m's uintptr_t packing
        // cannot carry it, so the fallible method defers (mirror-consistent narrowing).
        let double_param = method(
            "setLevel:error:",
            vec![
                param(TypeRefKind::Primitive {
                    name: "double".into(),
                }),
                param(TypeRefKind::Pointer),
            ],
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        assert_eq!(NativeSig::error_out_from_method(&double_param), None);
        // A double primary comes back in v0, not the shim's uintptr_t — defers.
        let double_ret = method(
            "levelWithError:",
            vec![param(TypeRefKind::Pointer)],
            ty(TypeRefKind::Primitive {
                name: "double".into(),
            }),
        );
        assert_eq!(NativeSig::error_out_from_method(&double_ret), None);
        // A void primary cannot key failure (Cocoa's "check the return") — defers.
        let void_ret = method(
            "performWithError:",
            vec![param(TypeRefKind::Pointer)],
            TypeRef::void(),
        );
        assert_eq!(NativeSig::error_out_from_method(&void_ret), None);
        // More visible args than the awexc.m switch dispatches — defers.
        let mut many = vec![
            param(TypeRefKind::Id {
                protocols: Vec::new()
            });
            ERROR_OUT_MAX_ARGS + 1
        ];
        many.push(param(TypeRefKind::Pointer));
        let too_many = method(
            "wide:error:",
            many,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        assert_eq!(NativeSig::error_out_from_method(&too_many), None);
        // Integer scalars and BOOLs pack into integer registers — still routable.
        let scalar_ok = method(
            "readCount:error:",
            vec![
                param(TypeRefKind::Primitive {
                    name: "NSUInteger".into(),
                }),
                param(TypeRefKind::Pointer),
            ],
            ty(TypeRefKind::Primitive {
                name: "NSInteger".into(),
            }),
        );
        let sig = NativeSig::error_out_from_method(&scalar_ok).unwrap();
        assert_eq!(sig.entry_name(None), "aw_ts_msg_Q_q_e");
    }

    #[test]
    fn error_out_sig_rejects_no_params_struct_return_and_non_routable_visible() {
        // No params ⇒ nothing to drop ⇒ not an error-out shape.
        let no_params = method(
            "frob",
            vec![],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        assert_eq!(NativeSig::error_out_from_method(&no_params), None);
        // A by-value struct primary + error-out is out of scope (v1).
        let struct_ret = method(
            "rectOrError:",
            vec![param(TypeRefKind::Pointer)],
            ty(TypeRefKind::Struct {
                name: "CGRect".into(),
            }),
        );
        assert_eq!(NativeSig::error_out_from_method(&struct_ret), None);
        // A non-routable *visible* param (unknown struct) still defers.
        let bad_visible = method(
            "doThing:error:",
            vec![
                param(TypeRefKind::Struct {
                    name: "NSDecimal".into(),
                }),
                param(TypeRefKind::Pointer),
            ],
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        assert_eq!(NativeSig::error_out_from_method(&bad_visible), None);
    }

    #[test]
    fn id_and_class_share_the_ptr_entry() {
        // Distinct object kinds collapse to the same content-addressed entry.
        let a = method(
            "a",
            vec![param(TypeRefKind::Id {
                protocols: Vec::new(),
            })],
            ty(TypeRefKind::Id {
                protocols: Vec::new(),
            }),
        );
        let b = method(
            "b",
            vec![param(TypeRefKind::Class {
                name: "NSView".into(),
                framework: None,
                params: vec![],
            })],
            ty(TypeRefKind::Instancetype),
        );
        assert_eq!(
            NativeSig::from_method(&a)
                .unwrap()
                .entry_name(Some(RetainAxis::FoldRetain)),
            NativeSig::from_method(&b)
                .unwrap()
                .entry_name(Some(RetainAxis::FoldRetain))
        );
    }
}
