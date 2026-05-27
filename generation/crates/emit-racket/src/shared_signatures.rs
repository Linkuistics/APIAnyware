//! Shared objc_msgSend signature collection and deduplication.
//!
//! Collects all unique typed `objc_msgSend` signatures needed by a class's methods
//! and properties, assigns sequential IDs, and provides lookup for reuse.

/// Racket `ffi-lib` argument for a framework.
///
/// Real frameworks live at
/// `/System/Library/Frameworks/{Name}.framework/{Name}`. Synthetic
/// pseudo-frameworks like `libdispatch` have no `.framework` bundle —
/// their symbols are re-exported by `libSystem`, which dyld resolves
/// via the shared cache on modern macOS (no standalone file on disk).
pub fn framework_ffi_lib_arg(framework_name: &str) -> String {
    if framework_name == "libdispatch" {
        return "libSystem".to_string();
    }
    format!(
        "/System/Library/Frameworks/{0}.framework/{0}",
        framework_name
    )
}

/// Returns `true` if the symbol is declared in libdispatch/pthread
/// headers but is not exported by the live `libSystem` dylib on modern
/// macOS (Ventura 13+). These are typically deprecated or never-
/// -implemented APIs that survive in the headers for source
/// compatibility.
///
/// Emitting a `get-ffi-obj` for any of these causes
/// `ffi-obj: could not find export from foreign library` at module
/// load time. The list is verified by dlsym in the runtime load
/// harness — if macOS ever starts exporting one, the harness will
/// flag it (and we can remove it) via a new canary.
pub fn is_libdispatch_unexported(symbol: &str) -> bool {
    matches!(
        symbol,
        "dispatch_cancel"
            | "dispatch_notify"
            | "dispatch_testcancel"
            | "dispatch_wait"
            | "pthread_jit_write_with_callback_np"
    )
}

use std::collections::BTreeMap;

use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_types::ir::{Class, Method};
use apianyware_macos_types::type_ref::TypeRef;

use crate::method_filter::{
    all_params_are_object_type, dispatch_strategy, is_supported_method, DispatchStrategy,
};

/// A signature key: space-separated param FFI types + " -> " + return FFI type.
///
/// Example: `"_id _uint64 -> _void"`
fn make_signature_key(param_types: &[String], return_type: &str) -> String {
    format!("{} -> {}", param_types.join(" "), return_type)
}

/// Map of unique signature keys to sequential integer IDs.
///
/// Provides lookup by signature key and iteration in sorted order.
#[derive(Debug)]
pub struct SignatureMap {
    entries: BTreeMap<String, usize>,
}

impl SignatureMap {
    /// Number of unique signatures.
    pub fn len(&self) -> usize {
        self.entries.len()
    }

    /// Whether there are any signatures.
    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }

    /// Look up the binding name (e.g., "_msg-3") for a given signature.
    pub fn lookup(&self, param_types: &[String], return_type: &str) -> Option<String> {
        let key = make_signature_key(param_types, return_type);
        self.entries.get(&key).map(|id| format!("_msg-{id}"))
    }

    /// Iterate over (key, id) pairs in sorted order.
    pub fn iter_sorted(&self) -> impl Iterator<Item = (&str, usize)> {
        self.entries.iter().map(|(k, &v)| (k.as_str(), v))
    }

    /// Parse a signature key into (param_types, return_type).
    pub fn parse_key(key: &str) -> (&str, &str) {
        let parts: Vec<&str> = key.splitn(2, " -> ").collect();
        if parts.len() == 2 {
            (parts[0], parts[1])
        } else {
            ("", key)
        }
    }
}

/// Collect all unique typed objc_msgSend signatures for a class.
///
/// Only includes methods that use the typed msgSend path (not the `tell` path).
/// Returns a [`SignatureMap`] with sequential IDs.
pub fn collect_class_signatures(cls: &Class, mapper: &dyn FfiTypeMapper) -> SignatureMap {
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

    let mut sig_set: BTreeMap<String, ()> = BTreeMap::new();

    // Collect from init methods (typed path only)
    for m in methods {
        if m.init_method
            && is_supported_method(m)
            && m.selector != "init"
            && !all_params_are_object_type(&m.params, mapper)
        {
            let param_types = collect_param_ffi_types(m, mapper);
            let key = make_signature_key(&param_types, "_id");
            sig_set.insert(key, ());
        }
    }

    // Collect from instance/class methods (typed path only)
    for m in methods {
        if !m.init_method
            && is_supported_method(m)
            && dispatch_strategy(m, mapper) == DispatchStrategy::TypedMsgSend
        {
            let param_types = collect_param_ffi_types(m, mapper);
            let ret_type = mapper.map_type(&m.return_type, true);
            let key = make_signature_key(&param_types, &ret_type);
            sig_set.insert(key, ());
        }
    }

    // Collect from property setters (non-_id types only)
    for p in properties {
        if !p.readonly {
            let ffi_type = mapper.map_type(&p.property_type, false);
            if ffi_type != "_id" {
                let key = make_signature_key(&[ffi_type], "_void");
                sig_set.insert(key, ());
            }
        }
    }

    // Assign sequential IDs
    let entries: BTreeMap<String, usize> = sig_set
        .into_keys()
        .enumerate()
        .map(|(i, k)| (k, i))
        .collect();

    SignatureMap { entries }
}

fn collect_param_ffi_types(method: &Method, mapper: &dyn FfiTypeMapper) -> Vec<String> {
    method
        .params
        .iter()
        .map(|p| mapper.map_type(&p.param_type, false))
        .collect()
}

/// Collect block FFI types from a block TypeRef.
///
/// Returns (param_type_strings, return_type_string).
/// Filters out void params (a block with void param means no params).
pub fn block_ffi_types(
    block_params: &[TypeRef],
    block_return: &TypeRef,
    mapper: &dyn FfiTypeMapper,
) -> (Vec<String>, String) {
    let real_params: Vec<String> = block_params
        .iter()
        .filter(|p| !mapper.is_void(p))
        .map(|p| mapper.map_type(p, false))
        .collect();
    let ret = mapper.map_type(block_return, true);
    (real_params, ret)
}

/// Returns true if any type-ref in the iterator is a struct passed by value.
///
/// Single decision point for "does this emission unit need the
/// `runtime/type-mapping.rkt` require for its `define-cstruct` types?".
/// Callers (class wrappers, `functions.rkt`, `constants.rkt`) describe
/// *which* type-refs their unit carries; this helper applies
/// `mapper.is_struct_type` uniformly so future geometry struct additions
/// only require updating the allowlist in the FFI type mapper — not
/// three parallel detection sites.
pub fn any_struct_type<'a, I>(type_refs: I, mapper: &dyn FfiTypeMapper) -> bool
where
    I: IntoIterator<Item = &'a TypeRef>,
{
    type_refs.into_iter().any(|tr| mapper.is_struct_type(tr))
}

/// Check if a class has any methods with struct parameters or struct return types.
///
/// When struct types are present in typed msgSend signatures, the generated file
/// must require `type-mapping.rkt` which defines the cstruct types (`_NSRect`, etc.).
pub fn class_has_struct_types(cls: &Class, mapper: &dyn FfiTypeMapper) -> bool {
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
    let method_types = methods.iter().flat_map(|m| {
        std::iter::once(&m.return_type).chain(m.params.iter().map(|p| &p.param_type))
    });
    let property_types = properties.iter().map(|p| &p.property_type);
    any_struct_type(method_types.chain(property_types), mapper)
}

/// Check if a class has any methods with block parameters.
pub fn class_has_blocks(cls: &Class) -> bool {
    let methods = if cls.all_methods.is_empty() {
        &cls.methods
    } else {
        &cls.all_methods
    };
    methods.iter().any(|m| {
        m.params.iter().any(|p| {
            matches!(
                p.param_type.kind,
                apianyware_macos_types::type_ref::TypeRefKind::Block { .. }
            )
        })
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_signature_key() {
        assert_eq!(
            make_signature_key(&["_id".to_string(), "_uint64".to_string()], "_void"),
            "_id _uint64 -> _void"
        );
        assert_eq!(make_signature_key(&[], "_id"), " -> _id");
    }

    #[test]
    fn test_parse_key() {
        let (params, ret) = SignatureMap::parse_key("_id _uint64 -> _void");
        assert_eq!(params, "_id _uint64");
        assert_eq!(ret, "_void");
    }
}
