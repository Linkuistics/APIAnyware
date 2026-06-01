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
//! **Depth-0 scope (leaf 040).** Only *non-struct* signatures route natively in
//! this leaf — scalars, floats, pointers, objects (the bulk). Struct-by-value
//! params/returns (`_NSRect` & co.) keep the existing typed `get-ffi-obj` path;
//! their out-buffer marshalling is leaf 050's headline (design spec §3). The
//! single libffi generic dispatcher (spec §6) is the escape hatch for anything
//! the emitter cannot type statically; variadics are already filtered upstream.

use std::collections::BTreeSet;

use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::ir::{Class, Framework};

use crate::method_filter::{
    all_params_are_object_type, dispatch_strategy, is_supported_method, DispatchStrategy,
};

/// The C-ABI prefix every generated native dispatch entry carries. Shares the
/// `aw_racket_` namespace the rest of `libAPIAnywareRacket` uses (ADR-0011,
/// hermetic isolation — the library owns its full symbol surface).
pub const ENTRY_PREFIX: &str = "aw_racket_msg_";

/// One ABI shape a `_fun` argument/result collapses to.
///
/// This is deliberately coarser than the Racket FFI spelling: every pointer-like
/// spelling (`_id`, `_pointer`, `_string`, selector, block) is one [`Ptr`], because
/// at the machine-call level they are one register-width pointer. The richer
/// distinction survives in the emitter's ffi2 binding, not here.
///
/// [`Ptr`]: AbiType::Ptr
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
    /// Valid only as a return type.
    Void,
}

impl AbiType {
    /// Parse a Racket `ffi/unsafe` spelling (as produced by
    /// [`apianyware_macos_emit::ffi_type_mapping::RacketFfiTypeMapper`]) into an
    /// ABI shape. Returns `None` for struct-by-value spellings (`_NSRect` & co.)
    /// — those do not route natively in this leaf (Depth-0; see module docs).
    pub fn from_ffi_unsafe(spelling: &str) -> Option<AbiType> {
        Some(match spelling {
            // Genuinely-opaque pointer-likes (object, raw pointer, selector)
            // collapse to one machine pointer and route with no marshalling.
            // `_string` (C `char*`) is deliberately *not* here: routing it would
            // either collide on the content-addressed entry name (a `string_t`
            // and a `ptr_t` binding sharing one symbol) or need `char*<->string`
            // marshalling — both Depth-1/leaf-050 concerns. So `_string` signatures
            // stay on the existing typed path (falls through to the `None` arm).
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
            // `_NSRect`, `_NSPoint`, … and anything unrecognised: not routable.
            _ => return None,
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
            AbiType::Void => 'v',
        }
    }

    /// The Swift type for this ABI shape in a `@convention(c)` / `@_cdecl`
    /// signature. `Void` has no parameter form (filtered before use).
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
            AbiType::Void => "Void",
        }
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

    /// The stable, content-addressed C entry name, e.g. `aw_racket_msg_PQ_v`
    /// (`(_id _uint64) -> _void`). A no-arg signature uses `0` for the empty
    /// parameter list: `aw_racket_msg_0_Q` (`() -> _uint64`).
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
/// (struct or C-string token — those keep the existing typed path). For routable
/// signatures every pointer-like is a bare `ptr_t` and every scalar its plain
/// ffi2 type, so the arrow is built mechanically via [`ffi_unsafe_to_ffi2`] with
/// no second mapper pass. The two leading `ptr_t`s are the implicit `self`+`_cmd`.
///
/// [`ffi_unsafe_to_ffi2`]: apianyware_macos_emit::ffi_type_mapping::ffi_unsafe_to_ffi2
pub fn native_dispatch_binding(
    param_spellings: &[String],
    ret_spelling: &str,
) -> Option<(String, String)> {
    use apianyware_macos_emit::ffi_type_mapping::ffi_unsafe_to_ffi2;

    let sig = NativeSig::from_ffi_unsafe(param_spellings, ret_spelling)?;
    let entry = sig.entry_name();

    let mut arrow_types = vec!["ptr_t".to_string(), "ptr_t".to_string()];
    for p in param_spellings {
        arrow_types.push(ffi_unsafe_to_ffi2(p));
    }
    arrow_types.push(ffi_unsafe_to_ffi2(ret_spelling));
    let arrow = format!("(-> {})", arrow_types.join(" "));

    Some((entry, arrow))
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

    // Instance / class methods on the typed msgSend path.
    for m in methods {
        if !m.init_method
            && is_supported_method(m)
            && dispatch_strategy(m, mapper) == DispatchStrategy::TypedMsgSend
        {
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

    // Typed property setters: non-`_id` value type, `(value) -> _void`.
    for p in properties {
        if !p.readonly {
            let ffi_type = mapper.map_type(&p.property_type, false);
            if ffi_type != "_id" {
                if let Some(sig) = NativeSig::from_ffi_unsafe(&[ffi_type], "_void") {
                    sigs.insert(sig);
                }
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
/// the signature's `params` follow. The result is returned directly (the
/// out-buffer convention the spike used for *struct* returns is a leaf-050
/// concern — struct signatures never reach here, see [`AbiType::from_ffi_unsafe`]).
pub fn generate_dispatch_swift(sigs: &BTreeSet<NativeSig>) -> String {
    let mut s = String::new();
    s.push_str("// Generated typed Objective-C dispatch entries (ADR-0013).\n");
    s.push_str("// DO NOT EDIT — regenerated by `apianyware-macos-generate` from the IR.\n");
    s.push_str("// One @_cdecl entry per distinct ABI signature; each casts objc_msgSend\n");
    s.push_str("// to the concrete @convention(c) shape. Called from thin ffi2 bindings\n");
    s.push_str("// in the generated Racket class files. See:\n");
    s.push_str("//   docs/specs/2026-05-31-racket-native-binding-design.md §2\n");
    s.push_str("//   docs/adr/0013-generated-typed-native-dispatch.md\n\n");
    s.push_str("import Darwin // dlsym, RTLD_DEFAULT\n\n");
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

    // The convention(c) function-pointer type that objc_msgSend is cast to.
    // Leading two pointers are self + _cmd.
    let mut conv_args = vec!["UnsafeMutableRawPointer?", "UnsafeMutableRawPointer?"];
    for p in &sig.params {
        conv_args.push(p.swift_type());
    }
    let conv_ret = sig.ret.swift_type();

    // The @_cdecl entry's own parameter list (named).
    let mut decl_params = vec![
        "_ recv: UnsafeMutableRawPointer?".to_string(),
        "_ sel: UnsafeMutableRawPointer?".to_string(),
    ];
    let mut call_args = vec!["recv".to_string(), "sel".to_string()];
    for (i, p) in sig.params.iter().enumerate() {
        decl_params.push(format!("_ a{i}: {}", p.swift_type()));
        call_args.push(format!("a{i}"));
    }

    s.push_str(&format!("@_cdecl(\"{name}\")\n"));
    if sig.ret == AbiType::Void {
        s.push_str(&format!("public func {name}({}) {{\n", decl_params.join(", ")));
        s.push_str(&format!(
            "  typealias Fn = @convention(c) ({}) -> Void\n",
            conv_args.join(", ")
        ));
        s.push_str(&format!(
            "  unsafeBitCast(_awMsgSend, to: Fn.self)({})\n",
            call_args.join(", ")
        ));
        s.push_str("}\n");
    } else {
        s.push_str(&format!(
            "public func {name}({}) -> {conv_ret} {{\n",
            decl_params.join(", ")
        ));
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
    fn abi_parse_rejects_structs_and_strings() {
        // Structs: out-buffer marshalling is leaf 050.
        assert_eq!(AbiType::from_ffi_unsafe("_NSRect"), None);
        assert_eq!(AbiType::from_ffi_unsafe("_NSPoint"), None);
        assert_eq!(AbiType::from_ffi_unsafe("_CGAffineTransform"), None);
        // C strings: char*<->string marshalling is leaf 050 (see from_ffi_unsafe).
        assert_eq!(AbiType::from_ffi_unsafe("_string"), None);
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
    fn struct_signatures_do_not_route() {
        // A struct param or return makes the whole signature non-routable.
        assert_eq!(
            NativeSig::from_ffi_unsafe(&["_NSRect".into()], "_void"),
            None
        );
        assert_eq!(NativeSig::from_ffi_unsafe(&[], "_NSRect"), None);
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

        // struct / string signatures do not produce a binding.
        assert!(native_dispatch_binding(&["_NSRect".into()], "_void").is_none());
        assert!(native_dispatch_binding(&[], "_string").is_none());
    }

    #[test]
    fn empty_surface_still_valid_swift() {
        let swift = generate_dispatch_swift(&BTreeSet::new());
        assert!(swift.contains("import Darwin"));
        assert!(swift.contains("0 generated dispatch entries."));
    }
}
