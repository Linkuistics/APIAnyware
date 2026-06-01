//! Generated typed native dispatch (ADR-0013).
//!
//! The `racket` target dispatches Objective-C methods through **native dispatch
//! entry points generated per distinct ABI signature** from the API analysis,
//! called from a thin ffi2 binding — rather than through in-Racket
//! `get-ffi-obj objc_msgSend`/`tell`. This module owns the native side:
//!
//! - [`AbiType`] — the small closed set of ABI shapes a `_fun … -> …` signature
//!   collapses to. Objects (`_id`), pointers (`_pointer`), C strings (`_string`),
//!   selectors and blocks all collapse to a single [`AbiType::Ptr`]: at the ABI
//!   level they are one machine pointer (the spike's 213 IR signatures → ~160 ABI
//!   shapes collapse, `FINDINGS.md` §2b). The emitter's *ffi2 binding* keeps the
//!   richer spelling (`string_t`, so ffi2 still marshals the Racket string to a
//!   `char*`); the native entry only sees the collapsed pointer. Both lower to the
//!   same machine ABI, so they interoperate.
//! - [`NativeSig`] — a full (params → return) ABI signature with a stable,
//!   content-addressed [`NativeSig::entry_name`]. Because the name is a pure
//!   function of the signature, per-class emission needs no global counter: two
//!   classes that share a signature independently compute the same entry name.
//! - [`generate_dispatch_swift`] — emits one `@_cdecl` Swift entry per signature
//!   into `swift/Sources/APIAnywareRacket/Generated/Dispatch.swift`. Each entry
//!   casts `objc_msgSend` (fetched via `dlsym(RTLD_DEFAULT, …)`, since the
//!   ObjectiveC overlay marks the symbol unavailable in pure Swift) to the
//!   concrete `@convention(c)` shape — the shipped form of the spike's `aw_t_*`
//!   C entries.
//!
//! **Struct-by-value (leaf 050/020).** The geometry family (`_NSRect`, `_NSPoint`,
//! `_NSSize`, `_NSRange`, `_NSEdgeInsets`, `_NSDirectionalEdgeInsets`,
//! `_NSAffineTransformStruct`, `_CGAffineTransform`, `_CGVector`) now routes
//! natively too — the §3 "Depth 1" 8× headline (struct return ~90 ns in-Racket →
//! ~11 ns native). The two stacked ABI problems are split: the generated `@_cdecl`
//! entry casts `objc_msgSend` to the *concrete* struct-returning/-taking
//! `@convention(c)` shape (the Swift compiler emits the correct arm64 convention —
//! ≤16 B in regs, HFAs in `v0–v3`, larger via the `x8` indirect pointer — so we
//! sidestep the `objc_msgSend_stret` minefield), and **ffi2 only ever sees an
//! opaque `ptr_t`** to the struct's bytes: a struct *param* crosses as a pointer to
//! the caller's cstruct, a struct *return* as a caller-allocated out-buffer pointer
//! the entry writes into (the spike's `aw_t_rectfor` convention, FINDINGS.md §1b).
//! The emitter hands back the existing `ffi/unsafe` `_NSRect`-family cstruct
//! ([`crate::emit_class`] `malloc` + `ptr-ref`), keeping one struct representation
//! across the whole binding (functions, `make-nsrect`, accessors) rather than
//! introducing a divergent ffi2 `struct_t`. The entry name still encodes the struct
//! identity (one code char per shape) so distinct struct casts get distinct
//! entries. *Unknown* (non-geometry) structs and C strings stay non-routable (the
//! `from_ffi_unsafe` `None` arm) and keep the retained `get-ffi-obj` fallback — the
//! escape hatch for shapes the emitter cannot lay out statically (spec §6/§8.2);
//! variadics are already filtered upstream.

use std::collections::BTreeSet;

use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::ir::{Class, Framework};

use crate::method_filter::{all_params_are_object_type, is_supported_method};

/// The C-ABI prefix every generated native dispatch entry carries. Shares the
/// `aw_racket_` namespace the rest of `libAPIAnywareRacket` uses (ADR-0011,
/// hermetic isolation — the library owns its full symbol surface).
pub const ENTRY_PREFIX: &str = "aw_racket_msg_";

/// One of the known geometry structs that crosses the native dispatch seam
/// by value (the closed set the `ffi_type_mapping` mapper recognises).
///
/// Each carries three facets the dispatch generator needs: a unique [`code`] char
/// for the content-addressed entry name (so two distinct struct casts never share
/// an entry); the concrete Swift type the generated `@_cdecl` entry casts
/// `objc_msgSend` to (real CoreGraphics/Foundation/AppKit types — guaranteed C
/// layout and arm64 ABI, unlike a hand-rolled Swift struct whose field order Swift
/// may reorder); and the `ffi/unsafe` cstruct spelling ([`racket_cstruct`]) the
/// emitter `malloc`s / `ptr-ref`s, matching `runtime/type-mapping.rkt`.
///
/// [`code`]: GeoStruct::code
/// [`racket_cstruct`]: GeoStruct::racket_cstruct
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum GeoStruct {
    NSRect,
    NSPoint,
    NSSize,
    NSRange,
    NSEdgeInsets,
    NSDirectionalEdgeInsets,
    NSAffineTransformStruct,
    CGAffineTransform,
    CGVector,
}

impl GeoStruct {
    /// Parse the Racket `ffi/unsafe` cstruct spelling (`_NSRect`, …) — the output
    /// of [`apianyware_macos_emit::ffi_type_mapping::RacketFfiTypeMapper`] for the
    /// geometry typedefs — into a known struct, or `None`.
    pub fn from_ffi_unsafe(spelling: &str) -> Option<GeoStruct> {
        Some(match spelling {
            "_NSRect" => GeoStruct::NSRect,
            "_NSPoint" => GeoStruct::NSPoint,
            "_NSSize" => GeoStruct::NSSize,
            "_NSRange" => GeoStruct::NSRange,
            "_NSEdgeInsets" => GeoStruct::NSEdgeInsets,
            "_NSDirectionalEdgeInsets" => GeoStruct::NSDirectionalEdgeInsets,
            "_NSAffineTransformStruct" => GeoStruct::NSAffineTransformStruct,
            "_CGAffineTransform" => GeoStruct::CGAffineTransform,
            "_CGVector" => GeoStruct::CGVector,
            _ => return None,
        })
    }

    /// The single-character entry-name code. Chosen from the uppercase letters the
    /// scalar codes do *not* use (`P`/`C`/`S`/`I`/`Q` are taken), so a struct code
    /// never collides with a scalar code in the concatenated entry name. Asserted
    /// collision-free against the full code space in [`tests`].
    fn code(self) -> char {
        match self {
            GeoStruct::NSRect => 'R',
            GeoStruct::NSPoint => 'O',
            GeoStruct::NSSize => 'Z',
            GeoStruct::NSRange => 'G',
            GeoStruct::NSEdgeInsets => 'E',
            GeoStruct::NSDirectionalEdgeInsets => 'D',
            GeoStruct::NSAffineTransformStruct => 'A',
            GeoStruct::CGAffineTransform => 'T',
            GeoStruct::CGVector => 'V',
        }
    }

    /// The Swift type the generated entry casts `objc_msgSend` to. These are the
    /// real framework types (guaranteed layout + arm64 ABI); the out-buffer /
    /// caller cstruct must be byte-identical (it is — same field order and widths).
    fn swift_type(self) -> &'static str {
        match self {
            GeoStruct::NSRect => "CGRect",
            GeoStruct::NSPoint => "CGPoint",
            GeoStruct::NSSize => "CGSize",
            GeoStruct::NSRange => "NSRange",
            GeoStruct::NSEdgeInsets => "NSEdgeInsets",
            GeoStruct::NSDirectionalEdgeInsets => "NSDirectionalEdgeInsets",
            GeoStruct::NSAffineTransformStruct => "NSAffineTransformStruct",
            GeoStruct::CGAffineTransform => "CGAffineTransform",
            GeoStruct::CGVector => "CGVector",
        }
    }

    /// The `ffi/unsafe` cstruct spelling (`runtime/type-mapping.rkt`) the emitter
    /// `malloc`s for a struct return and `ptr-ref`s back, and that a struct param's
    /// value already carries. The inverse of [`from_ffi_unsafe`].
    ///
    /// [`from_ffi_unsafe`]: GeoStruct::from_ffi_unsafe
    pub fn racket_cstruct(self) -> &'static str {
        match self {
            GeoStruct::NSRect => "_NSRect",
            GeoStruct::NSPoint => "_NSPoint",
            GeoStruct::NSSize => "_NSSize",
            GeoStruct::NSRange => "_NSRange",
            GeoStruct::NSEdgeInsets => "_NSEdgeInsets",
            GeoStruct::NSDirectionalEdgeInsets => "_NSDirectionalEdgeInsets",
            GeoStruct::NSAffineTransformStruct => "_NSAffineTransformStruct",
            GeoStruct::CGAffineTransform => "_CGAffineTransform",
            GeoStruct::CGVector => "_CGVector",
        }
    }
}

/// One ABI shape a `_fun` argument/result collapses to.
///
/// This is deliberately coarser than the Racket FFI spelling: every pointer-like
/// spelling (`_id`, `_pointer`, `_string`, selector, block) is one [`Ptr`], because
/// at the machine-call level they are one register-width pointer. The richer
/// distinction survives in the emitter's ffi2 binding, not here. The exception is
/// [`Struct`]: the geometry family crosses ffi2 as a `ptr_t` too, but each shape
/// keeps its identity here because the native entry's `objc_msgSend` cast is
/// struct-specific (so distinct shapes need distinct entries).
///
/// [`Ptr`]: AbiType::Ptr
/// [`Struct`]: AbiType::Struct
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum AbiType {
    Ptr,
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
    /// A geometry struct passed/returned by value (crosses ffi2 as a `ptr_t`).
    Struct(GeoStruct),
    /// Valid only as a return type.
    Void,
}

impl AbiType {
    /// Parse a Racket `ffi/unsafe` spelling (as produced by
    /// [`apianyware_macos_emit::ffi_type_mapping::RacketFfiTypeMapper`]) into an
    /// ABI shape. Returns `None` for C strings and any unrecognised spelling —
    /// those do not route natively (the retained `get-ffi-obj` escape hatch).
    pub fn from_ffi_unsafe(spelling: &str) -> Option<AbiType> {
        Some(match spelling {
            // Genuinely-opaque pointer-likes (object, raw pointer, selector)
            // collapse to one machine pointer and route with no marshalling.
            // `_string` (C `char*`) is deliberately *not* here: routing it would
            // either collide on the content-addressed entry name (a `string_t`
            // and a `ptr_t` binding sharing one symbol) or need `char*<->string`
            // marshalling — both Depth-2/leaf-050/030 concerns. So `_string`
            // signatures stay on the existing typed path (`None` arm).
            "_id" | "_pointer" => AbiType::Ptr,
            "_bool" => AbiType::Bool,
            "_int8" => AbiType::Int8,
            "_uint8" => AbiType::UInt8,
            "_int16" => AbiType::Int16,
            "_uint16" => AbiType::UInt16,
            "_int32" => AbiType::Int32,
            "_uint32" => AbiType::UInt32,
            "_int64" => AbiType::Int64,
            "_uint64" => AbiType::UInt64,
            "_float" => AbiType::Float,
            "_double" => AbiType::Double,
            "_void" => AbiType::Void,
            // Geometry structs (`_NSRect`, `_NSPoint`, …) cross by value — native
            // owns the arm64 struct convention, ffi2 sees a `ptr_t` (leaf 050/020).
            other => match GeoStruct::from_ffi_unsafe(other) {
                Some(g) => AbiType::Struct(g),
                // Unknown structs and anything unrecognised: not routable.
                None => return None,
            },
        })
    }

    /// The single-character code used in the content-addressed entry name.
    /// Chosen so the concatenation is a collision-free, valid C identifier tail.
    fn code(self) -> char {
        match self {
            AbiType::Ptr => 'P',
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

    /// The ffi2 type spelling for this ABI shape in a *parameter* position of the
    /// emitter's `define-aw-msg` binding arrow. Pointer-likes — and structs, which
    /// cross as a pointer to their bytes — are the opaque `ptr_t`. (A struct
    /// *return* is special: it crosses as a trailing out-buffer `ptr_t` with a
    /// `void_t` result; see [`NativeSig::ffi2_arrow`].)
    fn ffi2_type(self) -> &'static str {
        match self {
            AbiType::Ptr | AbiType::Struct(_) => "ptr_t",
            AbiType::Bool => "bool_t",
            AbiType::Int8 => "int8_t",
            AbiType::UInt8 => "uint8_t",
            AbiType::Int16 => "int16_t",
            AbiType::UInt16 => "uint16_t",
            AbiType::Int32 => "int32_t",
            AbiType::UInt32 => "uint32_t",
            AbiType::Int64 => "int64_t",
            AbiType::UInt64 => "uint64_t",
            AbiType::Float => "float_t",
            AbiType::Double => "double_t",
            AbiType::Void => "void_t",
        }
    }

    /// The Swift type for this ABI shape in the **`@convention(c)` cast** of
    /// `objc_msgSend` — i.e. the *real* method ABI. `Struct` is the concrete
    /// by-value geometry type (so the compiler emits the arm64 struct convention);
    /// the `@_cdecl` boundary itself crosses structs as raw pointers, handled in
    /// [`emit_one_entry`]. `Void` has no parameter form (filtered before use).
    fn swift_type(self) -> &'static str {
        match self {
            AbiType::Ptr => "UnsafeMutableRawPointer?",
            AbiType::Bool => "CBool",
            AbiType::Int8 => "Int8",
            AbiType::UInt8 => "UInt8",
            AbiType::Int16 => "Int16",
            AbiType::UInt16 => "UInt16",
            AbiType::Int32 => "Int32",
            AbiType::UInt32 => "UInt32",
            AbiType::Int64 => "Int64",
            AbiType::UInt64 => "UInt64",
            AbiType::Float => "Float",
            AbiType::Double => "Double",
            AbiType::Struct(g) => g.swift_type(),
            AbiType::Void => "Void",
        }
    }

    /// Whether this shape is a by-value geometry struct.
    fn is_struct(self) -> bool {
        matches!(self, AbiType::Struct(_))
    }
}

/// A full method ABI signature: `self` and `_cmd` (always two leading pointers)
/// are implicit; `params` are the *real* arguments, `ret` the result.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct NativeSig {
    pub params: Vec<AbiType>,
    pub ret: AbiType,
}

impl NativeSig {
    /// Build from Racket `ffi/unsafe` spellings, or `None` if any token is a
    /// struct-by-value / unrecognised shape (not routable this leaf), or if a
    /// non-final `_void` appears (only valid as a return).
    pub fn from_ffi_unsafe(param_spellings: &[String], ret_spelling: &str) -> Option<NativeSig> {
        let mut params = Vec::with_capacity(param_spellings.len());
        for p in param_spellings {
            let t = AbiType::from_ffi_unsafe(p)?;
            if t == AbiType::Void {
                return None; // void is not a valid parameter shape
            }
            params.push(t);
        }
        let ret = AbiType::from_ffi_unsafe(ret_spelling)?;
        Some(NativeSig { params, ret })
    }

    /// The ffi2 binding arrow for `(define-aw-msg <entry> <arrow>)`:
    /// `(-> ptr_t ptr_t <param ffi2 types…> <ret ffi2 type>)`. The two leading
    /// `ptr_t`s are the implicit `self` + `_cmd`.
    ///
    /// A **struct return** crosses as a caller-allocated out-buffer: the arrow
    /// gains a trailing `ptr_t` parameter (the buffer) and its result becomes
    /// `void_t` (the entry writes through the pointer rather than returning the
    /// struct). Struct *params* are already `ptr_t` (see [`AbiType::ffi2_type`]).
    pub fn ffi2_arrow(&self) -> String {
        let mut parts = vec!["ptr_t".to_string(), "ptr_t".to_string()];
        for p in &self.params {
            parts.push(p.ffi2_type().to_string());
        }
        if self.ret.is_struct() {
            parts.push("ptr_t".to_string()); // out-buffer
            parts.push("void_t".to_string());
        } else {
            parts.push(self.ret.ffi2_type().to_string());
        }
        format!("(-> {})", parts.join(" "))
    }

    /// Whether this signature returns a struct by value (out-buffer convention).
    pub fn ret_is_struct(&self) -> bool {
        self.ret.is_struct()
    }

    /// The stable, content-addressed C entry name, e.g. `aw_racket_msg_PQ_v`
    /// (`(_id _uint64) -> _void`). A no-arg signature uses `0` for the empty
    /// parameter list: `aw_racket_msg_0_Q` (`() -> _uint64`). A struct return
    /// carries its struct code in the result position (`aw_racket_msg_0_R` for
    /// `() -> _NSRect`), distinguishing distinct struct casts even though both
    /// cross ffi2 via an out-buffer `ptr_t`.
    pub fn entry_name(&self) -> String {
        let params: String = if self.params.is_empty() {
            "0".to_string()
        } else {
            self.params.iter().map(|t| t.code()).collect()
        };
        format!("{ENTRY_PREFIX}{params}_{}", self.ret.code())
    }
}

/// The thin ffi2 binding the emitter emits for a routable signature, computed
/// from the Racket `ffi/unsafe` param/return spellings the emitter already has.
///
/// Returns `(entry_name, ffi2_arrow)` or `None` if the signature is not routable
/// (C-string token or unknown struct — those keep the existing typed path). The
/// entry name and arrow are both pure functions of the parsed [`NativeSig`], so
/// they stay in lockstep with [`generate_dispatch_swift`]'s output and the
/// out-buffer convention for struct returns ([`NativeSig::ffi2_arrow`]).
pub fn native_dispatch_binding(
    param_spellings: &[String],
    ret_spelling: &str,
) -> Option<(String, String)> {
    let sig = NativeSig::from_ffi_unsafe(param_spellings, ret_spelling)?;
    Some((sig.entry_name(), sig.ffi2_arrow()))
}

/// Whether a typed signature routes through the generated native dispatch table
/// (vs. the retained `get-ffi-obj` fallback). Convenience over
/// [`native_dispatch_binding`] for call sites that only need the yes/no.
pub fn is_routable(param_spellings: &[String], ret_spelling: &str) -> bool {
    NativeSig::from_ffi_unsafe(param_spellings, ret_spelling).is_some()
}

/// Collect every routable native dispatch signature used by a class's typed
/// dispatch paths (instance/class methods, typed constructors, typed property
/// setters) — mirroring exactly which methods [`crate::emit_class`] routes
/// natively, so the generated entry set and the emitted bindings never drift.
pub fn collect_class_native_sigs(cls: &Class, mapper: &dyn FfiTypeMapper) -> BTreeSet<NativeSig> {
    let methods = if cls.all_methods.is_empty() {
        &cls.methods
    } else {
        &cls.all_methods
    };
    let properties = if cls.all_properties.is_empty() {
        &cls.properties
    } else {
        &cls.all_properties
    };

    let mut sigs = BTreeSet::new();

    // Typed constructors: init methods with at least one non-object param.
    for m in methods {
        if m.init_method
            && is_supported_method(m)
            && m.selector != "init"
            && !all_params_are_object_type(&m.params, mapper)
        {
            let params: Vec<String> = m
                .params
                .iter()
                .map(|p| mapper.map_type(&p.param_type, false))
                .collect();
            if let Some(sig) = NativeSig::from_ffi_unsafe(&params, "_id") {
                sigs.insert(sig);
            }
        }
    }

    // Instance / class methods. Since leaf 050/010 every *routable* signature
    // dispatches natively — not just the scalar (`TypedMsgSend`) shapes but also
    // the all-object ones (`_id` collapses to `ptr_t`). Only struct-by-value /
    // C-string shapes stay non-routable (the `from_ffi_unsafe` `None` arm) and
    // keep the `get-ffi-obj` fallback. This must mirror `emit_class::emit_method`
    // exactly, erring toward over-collection (an unused entry is a harmless dead
    // binding; a missing one is an undefined identifier at Racket load).
    for m in methods {
        if !m.init_method && is_supported_method(m) {
            let params: Vec<String> = m
                .params
                .iter()
                .map(|p| mapper.map_type(&p.param_type, false))
                .collect();
            let ret = mapper.map_type(&m.return_type, true);
            if let Some(sig) = NativeSig::from_ffi_unsafe(&params, &ret) {
                sigs.insert(sig);
            }
        }
    }

    // Property getters (`() -> <type>`) and setters (`(<type>) -> _void`). Both
    // route natively for every routable shape (objects + scalars) since leaf
    // 050/010; struct-typed accessors stay non-routable and keep `tell`.
    for p in properties {
        let ffi_type = mapper.map_type(&p.property_type, false);
        if let Some(sig) = NativeSig::from_ffi_unsafe(&[], &ffi_type) {
            sigs.insert(sig);
        }
        if !p.readonly {
            if let Some(sig) = NativeSig::from_ffi_unsafe(&[ffi_type], "_void") {
                sigs.insert(sig);
            }
        }
    }

    sigs
}

/// Collect the global, deduplicated set of native dispatch signatures across all
/// frameworks — the entries [`generate_dispatch_swift`] compiles into the dylib.
pub fn collect_global_signatures(
    frameworks: &[Framework],
    mapper: &dyn FfiTypeMapper,
) -> BTreeSet<NativeSig> {
    let mut all = BTreeSet::new();
    for fw in frameworks {
        for cls in &fw.classes {
            all.extend(collect_class_native_sigs(cls, mapper));
        }
    }
    all
}

/// Emit `Dispatch.swift`: one `@_cdecl` typed entry per signature, each casting
/// `objc_msgSend` to the concrete `@convention(c)` shape and calling it.
///
/// `self` and `_cmd` are the two leading `UnsafeMutableRawPointer?` parameters;
/// the signature's `params` follow. Scalar/pointer results are returned directly.
/// A **struct return** uses the spike's out-buffer convention: the entry takes a
/// trailing `out` pointer, returns `Void`, and writes the by-value struct result
/// through it. A **struct param** is received as a raw pointer and loaded to the
/// by-value Swift struct before the call — so the `objc_msgSend` cast always sees
/// the real arm64 struct convention while ffi2 only ever passes `ptr_t`s.
pub fn generate_dispatch_swift(sigs: &BTreeSet<NativeSig>) -> String {
    let mut s = String::new();
    s.push_str("// Generated typed Objective-C dispatch entries (ADR-0013).\n");
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-macos-generate` from the IR.\n");
    s.push_str("// One @_cdecl entry per distinct ABI signature; each casts objc_msgSend\n");
    s.push_str("// to the concrete @convention(c) shape. Called from thin ffi2 bindings\n");
    s.push_str("// in the generated Racket class files. See:\n");
    s.push_str("//   docs/specs/2026-05-31-racket-native-binding-design.md §2\n");
    s.push_str("//   docs/adr/0013-generated-typed-native-dispatch.md\n\n");
    s.push_str("import Darwin // dlsym, RTLD_DEFAULT\n");
    s.push_str("// AppKit re-exports Foundation + CoreGraphics: the by-value geometry struct\n");
    s.push_str("// types (CGRect, CGPoint, NSRange, NSEdgeInsets, NSAffineTransformStruct, …)\n");
    s.push_str("// the struct-by-value entries cast objc_msgSend to (leaf 050/020).\n");
    s.push_str("import AppKit\n\n");
    s.push_str("// objc_msgSend is marked unavailable in Swift's ObjectiveC overlay, so we\n");
    s.push_str("// resolve the symbol at load time and cast per call site. RTLD_DEFAULT is\n");
    s.push_str("// (void *)-2 on Darwin. `nonisolated(unsafe)` matches the codebase's other\n");
    s.push_str("// raw-pointer globals (BlockBridge.swift) — the value is an immutable,\n");
    s.push_str("// resolve-once function pointer, safe to share across threads.\n");
    s.push_str(
        "private nonisolated(unsafe) let _awMsgSend: UnsafeMutableRawPointer = \
         dlsym(UnsafeMutableRawPointer(bitPattern: -2), \"objc_msgSend\")!\n\n",
    );

    for sig in sigs {
        emit_one_entry(&mut s, sig);
        s.push('\n');
    }

    // Touch the symbol count so an all-empty surface still produces valid Swift.
    s.push_str(&format!(
        "// {} generated dispatch entr{}.\n",
        sigs.len(),
        if sigs.len() == 1 { "y" } else { "ies" }
    ));
    s
}

fn emit_one_entry(s: &mut String, sig: &NativeSig) {
    let name = sig.entry_name();

    // The convention(c) function-pointer type objc_msgSend is cast to — the *real*
    // method ABI. Leading two pointers are self + _cmd; struct params/return are
    // the concrete by-value Swift geometry types (so the compiler emits the arm64
    // struct convention). This is unaffected by the @_cdecl boundary shaping below.
    let mut conv_args = vec![
        "UnsafeMutableRawPointer?".to_string(),
        "UnsafeMutableRawPointer?".to_string(),
    ];
    for p in &sig.params {
        conv_args.push(p.swift_type().to_string());
    }

    // The @_cdecl entry's own parameter list (named) and the call's argument list.
    // Struct params cross the @_cdecl boundary as raw pointers, loaded to the
    // by-value Swift struct before the cast call.
    let mut decl_params = vec![
        "_ recv: UnsafeMutableRawPointer?".to_string(),
        "_ sel: UnsafeMutableRawPointer?".to_string(),
    ];
    let mut call_args = vec!["recv".to_string(), "sel".to_string()];
    let mut prelude = String::new();
    for (i, p) in sig.params.iter().enumerate() {
        match p {
            AbiType::Struct(g) => {
                decl_params.push(format!("_ a{i}: UnsafeMutableRawPointer?"));
                prelude.push_str(&format!(
                    "  let s{i} = a{i}!.assumingMemoryBound(to: {}.self).pointee\n",
                    g.swift_type()
                ));
                call_args.push(format!("s{i}"));
            }
            _ => {
                decl_params.push(format!("_ a{i}: {}", p.swift_type()));
                call_args.push(format!("a{i}"));
            }
        }
    }

    s.push_str(&format!("@_cdecl(\"{name}\")\n"));
    match sig.ret {
        AbiType::Void => {
            s.push_str(&format!("public func {name}({}) {{\n", decl_params.join(", ")));
            s.push_str(&prelude);
            s.push_str(&format!(
                "  typealias Fn = @convention(c) ({}) -> Void\n",
                conv_args.join(", ")
            ));
            s.push_str(&format!(
                "  unsafeBitCast(_awMsgSend, to: Fn.self)({})\n",
                call_args.join(", ")
            ));
            s.push_str("}\n");
        }
        AbiType::Struct(g) => {
            // Out-buffer convention: an extra trailing pointer the caller allocated;
            // the cast call returns the struct by value and we write it through.
            decl_params.push("_ out: UnsafeMutableRawPointer?".to_string());
            s.push_str(&format!("public func {name}({}) {{\n", decl_params.join(", ")));
            s.push_str(&prelude);
            s.push_str(&format!(
                "  typealias Fn = @convention(c) ({}) -> {}\n",
                conv_args.join(", "),
                g.swift_type()
            ));
            s.push_str(&format!(
                "  let r = unsafeBitCast(_awMsgSend, to: Fn.self)({})\n",
                call_args.join(", ")
            ));
            s.push_str(&format!(
                "  out!.assumingMemoryBound(to: {}.self).pointee = r\n",
                g.swift_type()
            ));
            s.push_str("}\n");
        }
        scalar => {
            let conv_ret = scalar.swift_type();
            s.push_str(&format!(
                "public func {name}({}) -> {conv_ret} {{\n",
                decl_params.join(", ")
            ));
            s.push_str(&prelude);
            s.push_str(&format!(
                "  typealias Fn = @convention(c) ({}) -> {conv_ret}\n",
                conv_args.join(", ")
            ));
            s.push_str(&format!(
                "  return unsafeBitCast(_awMsgSend, to: Fn.self)({})\n",
                call_args.join(", ")
            ));
            s.push_str("}\n");
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn abi_parse_collapses_pointers() {
        assert_eq!(AbiType::from_ffi_unsafe("_id"), Some(AbiType::Ptr));
        assert_eq!(AbiType::from_ffi_unsafe("_pointer"), Some(AbiType::Ptr));
        assert_eq!(AbiType::from_ffi_unsafe("_uint64"), Some(AbiType::UInt64));
        assert_eq!(AbiType::from_ffi_unsafe("_double"), Some(AbiType::Double));
        assert_eq!(AbiType::from_ffi_unsafe("_void"), Some(AbiType::Void));
    }

    #[test]
    fn abi_parse_routes_geometry_structs() {
        // Geometry structs route by value (leaf 050/020).
        assert_eq!(
            AbiType::from_ffi_unsafe("_NSRect"),
            Some(AbiType::Struct(GeoStruct::NSRect))
        );
        assert_eq!(
            AbiType::from_ffi_unsafe("_NSPoint"),
            Some(AbiType::Struct(GeoStruct::NSPoint))
        );
        assert_eq!(
            AbiType::from_ffi_unsafe("_CGAffineTransform"),
            Some(AbiType::Struct(GeoStruct::CGAffineTransform))
        );
        // C strings stay non-routable (Depth-2, leaf 050/030).
        assert_eq!(AbiType::from_ffi_unsafe("_string"), None);
        // An unknown struct also stays non-routable (the escape hatch).
        assert_eq!(AbiType::from_ffi_unsafe("_NSDecimal"), None);
    }

    #[test]
    fn struct_codes_are_collision_free() {
        // Every struct code must differ from every other struct code AND from
        // every scalar/pointer/void code, or the concatenated entry name is
        // ambiguous. Assert uniqueness across the whole code space.
        let geo = [
            GeoStruct::NSRect,
            GeoStruct::NSPoint,
            GeoStruct::NSSize,
            GeoStruct::NSRange,
            GeoStruct::NSEdgeInsets,
            GeoStruct::NSDirectionalEdgeInsets,
            GeoStruct::NSAffineTransformStruct,
            GeoStruct::CGAffineTransform,
            GeoStruct::CGVector,
        ];
        let scalars = [
            AbiType::Ptr,
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
        let mut codes: Vec<char> = scalars.iter().map(|t| t.code()).collect();
        codes.extend(geo.iter().map(|g| g.code()));
        let mut deduped = codes.clone();
        deduped.sort_unstable();
        deduped.dedup();
        assert_eq!(deduped.len(), codes.len(), "code collision: {codes:?}");
    }

    #[test]
    fn entry_name_is_content_addressed() {
        // (_id _uint64) -> _void
        let sig = NativeSig::from_ffi_unsafe(&["_id".into(), "_uint64".into()], "_void").unwrap();
        assert_eq!(sig.entry_name(), "aw_racket_msg_PQ_v");

        // () -> _uint64  (no-arg scalar getter, e.g. -hash/-length)
        let sig = NativeSig::from_ffi_unsafe(&[], "_uint64").unwrap();
        assert_eq!(sig.entry_name(), "aw_racket_msg_0_Q");

        // (_id) -> _id  (pointer in / pointer out)
        let sig = NativeSig::from_ffi_unsafe(&["_id".into()], "_id").unwrap();
        assert_eq!(sig.entry_name(), "aw_racket_msg_P_P");

        // (_double _double) -> _double
        let sig =
            NativeSig::from_ffi_unsafe(&["_double".into(), "_double".into()], "_double").unwrap();
        assert_eq!(sig.entry_name(), "aw_racket_msg_dd_d");
    }

    #[test]
    fn pointer_collapse_unifies_id_and_pointer() {
        // _id and _pointer collapse to the same entry — the 213→160 ABI collapse
        // made structural (FINDINGS.md §2b). (_string is non-routable, see above.)
        let a = NativeSig::from_ffi_unsafe(&["_id".into()], "_id").unwrap();
        let b = NativeSig::from_ffi_unsafe(&["_pointer".into()], "_pointer").unwrap();
        assert_eq!(a.entry_name(), b.entry_name());
    }

    #[test]
    fn string_signatures_do_not_route() {
        assert_eq!(NativeSig::from_ffi_unsafe(&["_string".into()], "_void"), None);
        assert_eq!(NativeSig::from_ffi_unsafe(&[], "_string"), None);
    }

    #[test]
    fn struct_signatures_route_with_identity_encoded() {
        // Struct return: identity in the result code, out-buffer in the arrow.
        let (entry, arrow) = native_dispatch_binding(&[], "_NSRect").unwrap();
        assert_eq!(entry, "aw_racket_msg_0_R");
        // out-buffer ptr_t before the void_t result.
        assert_eq!(arrow, "(-> ptr_t ptr_t ptr_t void_t)");

        // Struct param (e.g. setFrame:): crosses as ptr_t, identity in the param
        // code. void return (no out-buffer).
        let (entry, arrow) = native_dispatch_binding(&["_NSRect".into()], "_void").unwrap();
        assert_eq!(entry, "aw_racket_msg_R_v");
        assert_eq!(arrow, "(-> ptr_t ptr_t ptr_t void_t)");

        // Distinct struct shapes get distinct entries even though both cross as
        // an out-buffer ptr_t — the cast differs (CGRect vs CGPoint).
        let (rect, _) = native_dispatch_binding(&[], "_NSRect").unwrap();
        let (point, _) = native_dispatch_binding(&[], "_NSPoint").unwrap();
        assert_ne!(rect, point);
        assert_eq!(point, "aw_racket_msg_0_O");

        // Struct param + struct return + object arg (e.g. -adjustRect:context:).
        let (entry, arrow) =
            native_dispatch_binding(&["_NSRect".into(), "_id".into()], "_NSRect").unwrap();
        assert_eq!(entry, "aw_racket_msg_RP_R");
        assert_eq!(arrow, "(-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t)");
    }

    #[test]
    fn generated_swift_struct_return_uses_out_buffer() {
        let mut sigs = BTreeSet::new();
        sigs.insert(NativeSig::from_ffi_unsafe(&[], "_NSRect").unwrap()); // -frame
        let swift = generate_dispatch_swift(&sigs);
        assert!(swift.contains("import AppKit"), "imports:\n{swift}");
        assert!(
            swift.contains(
                "public func aw_racket_msg_0_R(_ recv: UnsafeMutableRawPointer?, _ sel: UnsafeMutableRawPointer?, _ out: UnsafeMutableRawPointer?)"
            ),
            "struct-return decl with out-buffer:\n{swift}"
        );
        assert!(
            swift.contains("typealias Fn = @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> CGRect"),
            "cast to concrete CGRect:\n{swift}"
        );
        assert!(
            swift.contains("out!.assumingMemoryBound(to: CGRect.self).pointee = r"),
            "writes result through out-buffer:\n{swift}"
        );
    }

    #[test]
    fn generated_swift_struct_param_loads_pointee() {
        let mut sigs = BTreeSet::new();
        sigs.insert(NativeSig::from_ffi_unsafe(&["_NSRect".into()], "_void").unwrap()); // setFrame:
        let swift = generate_dispatch_swift(&sigs);
        assert!(
            swift.contains(
                "public func aw_racket_msg_R_v(_ recv: UnsafeMutableRawPointer?, _ sel: UnsafeMutableRawPointer?, _ a0: UnsafeMutableRawPointer?)"
            ),
            "struct-param decl as raw pointer:\n{swift}"
        );
        assert!(
            swift.contains("let s0 = a0!.assumingMemoryBound(to: CGRect.self).pointee"),
            "loads struct param to by-value before call:\n{swift}"
        );
        assert!(
            swift.contains("typealias Fn = @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, CGRect) -> Void"),
            "cast takes CGRect by value:\n{swift}"
        );
        assert!(
            swift.contains("unsafeBitCast(_awMsgSend, to: Fn.self)(recv, sel, s0)"),
            "passes loaded struct value:\n{swift}"
        );
    }

    #[test]
    fn void_param_is_rejected() {
        assert_eq!(NativeSig::from_ffi_unsafe(&["_void".into()], "_id"), None);
    }

    #[test]
    fn generated_swift_has_cdecl_and_cast() {
        let mut sigs = BTreeSet::new();
        sigs.insert(NativeSig::from_ffi_unsafe(&[], "_uint64").unwrap());
        sigs.insert(NativeSig::from_ffi_unsafe(&["_id".into()], "_void").unwrap());
        let swift = generate_dispatch_swift(&sigs);

        assert!(swift.contains("dlsym(UnsafeMutableRawPointer(bitPattern: -2), \"objc_msgSend\")"));
        // Scalar-return entry.
        assert!(swift.contains("@_cdecl(\"aw_racket_msg_0_Q\")"));
        assert!(swift.contains("public func aw_racket_msg_0_Q(_ recv: UnsafeMutableRawPointer?, _ sel: UnsafeMutableRawPointer?) -> UInt64"));
        assert!(swift.contains("typealias Fn = @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> UInt64"));
        // Void-return entry with one pointer arg.
        assert!(swift.contains("@_cdecl(\"aw_racket_msg_P_v\")"));
        assert!(swift.contains("public func aw_racket_msg_P_v(_ recv: UnsafeMutableRawPointer?, _ sel: UnsafeMutableRawPointer?, _ a0: UnsafeMutableRawPointer?)"));
        assert!(swift.contains("-> Void"));
        assert!(swift.contains("2 generated dispatch entries."));
    }

    #[test]
    fn binding_arrow_and_name() {
        // () -> _uint64  (e.g. -length): two implicit ptr_t + uint64_t return.
        let (entry, arrow) = native_dispatch_binding(&[], "_uint64").unwrap();
        assert_eq!(entry, "aw_racket_msg_0_Q");
        assert_eq!(arrow, "(-> ptr_t ptr_t uint64_t)");

        // (_id) -> _id  (e.g. -addObject: shape): object collapses to ptr_t.
        let (entry, arrow) = native_dispatch_binding(&["_id".into()], "_id").unwrap();
        assert_eq!(entry, "aw_racket_msg_P_P");
        assert_eq!(arrow, "(-> ptr_t ptr_t ptr_t ptr_t)");

        // (_id _uint64) -> _void  (e.g. -insertObject:atIndex:).
        let (entry, arrow) =
            native_dispatch_binding(&["_id".into(), "_uint64".into()], "_void").unwrap();
        assert_eq!(entry, "aw_racket_msg_PQ_v");
        assert_eq!(arrow, "(-> ptr_t ptr_t ptr_t uint64_t void_t)");

        // string / unknown-struct signatures do not produce a binding (escape
        // hatch); known geometry structs do (see struct_signatures_route_*).
        assert!(native_dispatch_binding(&[], "_string").is_none());
        assert!(native_dispatch_binding(&["_NSDecimal".into()], "_void").is_none());
    }

    #[test]
    fn empty_surface_still_valid_swift() {
        let swift = generate_dispatch_swift(&BTreeSet::new());
        assert!(swift.contains("import Darwin"));
        assert!(swift.contains("0 generated dispatch entries."));
    }

    /// Opt-in: write the `Dispatch.swift` the synthetic **TestKit** framework
    /// generates (the only local witness — real-framework IR is gitignored) to the
    /// real Generated/ path, so the worktree's dylib matches the committed TestKit
    /// golden's `define-aw-msg` entries (incl. the struct-by-value `aw_racket_msg_*_R`
    /// / `aw_racket_msg_R_*`) and `swift build` confirms they compile against the
    /// real CoreGraphics/Foundation/AppKit struct types. Run with:
    ///   AW_WRITE_DISPATCH=1 cargo test -p apianyware-macos-emit-racket \
    ///     --lib native_dispatch::tests::write_testkit_dispatch_swift -- --ignored
    /// then `cd swift && SDKROOT=macosx swift build --target APIAnywareRacket`.
    /// Gitignored output; not part of CI. Real-framework regen + the dylib-symlink
    /// repoint + runtime execution are the root-050 leaf's job (040 carryover).
    #[test]
    #[ignore]
    fn write_testkit_dispatch_swift() {
        use apianyware_macos_emit::ffi_type_mapping::RacketFfiTypeMapper;
        use apianyware_macos_emit::test_fixtures::build_snapshot_test_framework;

        if std::env::var("AW_WRITE_DISPATCH").as_deref() != Ok("1") {
            return;
        }
        let fw = build_snapshot_test_framework();
        let sigs = collect_global_signatures(std::slice::from_ref(&fw), &RacketFfiTypeMapper);
        let swift = generate_dispatch_swift(&sigs);
        let out = concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/../../../swift/Sources/APIAnywareRacket/Generated/Dispatch.swift"
        );
        std::fs::write(out, swift).expect("write Dispatch.swift");
        eprintln!("wrote TestKit Dispatch.swift ({} entries) to {out}", sigs.len());
    }
}
