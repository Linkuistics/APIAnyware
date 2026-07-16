//! How an [`AbiType`] renders on the **Swift side** of the N-API seam — the rendering
//! vocabulary every generated entry table speaks.
//!
//! [`crate::native_dispatch`] classifies an IR `TypeRef` to its machine-ABI shape and names
//! the entries the emitted `.ts` calls. This module is the other half of that contract: given
//! a shape, what Swift type does the `@convention(c)` cast use, how is a JS argument read into
//! it, and how does a result marshal back. [`crate::dispatch_table`] (methods, through
//! `objc_msgSend`) and [`crate::function_table`] (free C functions, by their own address) both
//! render from here, so a shape cannot mean one thing in one table and something else in the
//! other — a second `swift_abi_type` would be a second alphabet by another name.
//!
//! ## The retain fold is the one place the two tables meet
//!
//! Under uniform-+1 (ADR-0057 §4) every wrapper owns exactly one retain, so an entry whose
//! object return is **+0** must fold an `objcRetain` in before the handle crosses to JS, and an
//! entry whose return is already **+1** must not. The two tables decide *which* by different
//! facts — a method by its `_o` suffix (the `ns_returns_retained` family), a free function by
//! the CF **Create Rule** on its symbol name — but both reduce to one boolean at the point of
//! rendering, so [`marshal_return`] takes it as an argument and owns the fold.
//!
//! **The fold is gated on being a real object, not on the ABI being a pointer.** `AbiType::Ptr`
//! collapses `id`/`Class`/`SEL` (they are one register-width pointer), but only an `id` is
//! wrapped `.ts`-side. Retaining a `Class` would leak (nothing releases it) and retaining a
//! `SEL` is undefined behaviour (`objc_retain` on a non-object). Callers pass
//! `fold_object_retain: false` for a `Ptr` return that is not an object.

use crate::native_dispatch::{AbiType, GeoStruct};

/// The Swift type in the `@convention(c)` cast for one ABI shape — the *real* ABI the
/// compiler lays out (structs by value, exact scalar widths).
pub(crate) fn swift_abi_type(t: AbiType) -> &'static str {
    match t {
        AbiType::Ptr => "UInt",
        AbiType::CStr => "UnsafePointer<CChar>?",
        AbiType::Bool => "Bool",
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
        AbiType::Struct(g) => geo_swift_type(g),
        AbiType::Void => "Void",
    }
}

/// The concrete Swift geometry type (real AppKit/Foundation/CoreGraphics types —
/// guaranteed C layout and arm64 ABI, the racket `GeoStruct::swift_type` precedent).
pub(crate) fn geo_swift_type(g: GeoStruct) -> &'static str {
    match g {
        GeoStruct::CGRect => "CGRect",
        GeoStruct::CGPoint => "CGPoint",
        GeoStruct::CGSize => "CGSize",
        GeoStruct::NSRange => "NSRange",
        GeoStruct::NSEdgeInsets => "NSEdgeInsets",
        GeoStruct::NSDirectionalEdgeInsets => "NSDirectionalEdgeInsets",
        GeoStruct::NSAffineTransformStruct => "NSAffineTransformStruct",
        GeoStruct::CGAffineTransform => "CGAffineTransform",
        GeoStruct::CGVector => "CGVector",
    }
}

/// The napi helper-name stem for one geometry struct — `napiRead<stem>` reads a plain
/// JS object arg into the by-value struct, `napiMake<stem>` marshals a struct result
/// back (napi_support.swift; the POD-object surface, ADR-0042).
pub(crate) fn geo_helper_stem(g: GeoStruct) -> &'static str {
    match g {
        GeoStruct::CGRect => "Rect",
        GeoStruct::CGPoint => "Point",
        GeoStruct::CGSize => "Size",
        GeoStruct::NSRange => "Range",
        GeoStruct::NSEdgeInsets => "EdgeInsets",
        GeoStruct::NSDirectionalEdgeInsets => "DirectionalEdgeInsets",
        GeoStruct::NSAffineTransformStruct => "AffineTransformStruct",
        GeoStruct::CGAffineTransform => "AffineTransform",
        GeoStruct::CGVector => "Vector",
    }
}

/// The arg-reading expression for one non-CStr shape (a CStr arg needs a `strdup` prelude —
/// [`cstr_prelude`]). `idx` is the napi arg slot: a method's visible param `i` sits at
/// `a[i + 2]` (after receiver + selector), a free function's at `a[i]`.
pub(crate) fn reader_expr(t: AbiType, idx: usize) -> String {
    match t {
        AbiType::Ptr => format!("napiReadHandle(env, a[{idx}])"),
        AbiType::Bool => format!("napiGetBool(env, a[{idx}])"),
        AbiType::Int8 => format!("Int8(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        AbiType::UInt8 => format!("UInt8(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        AbiType::Int16 => format!("Int16(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        AbiType::UInt16 => format!("UInt16(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        AbiType::Int32 => format!("Int32(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        AbiType::UInt32 => format!("UInt32(truncatingIfNeeded: napiReadInt64(env, a[{idx}]))"),
        AbiType::Int64 => format!("napiReadInt64(env, a[{idx}])"),
        AbiType::UInt64 => format!("napiReadUInt64(env, a[{idx}])"),
        AbiType::Float => format!("Float(napiReadDouble(env, a[{idx}]))"),
        AbiType::Double => format!("napiReadDouble(env, a[{idx}])"),
        AbiType::Struct(g) => format!("napiRead{}(env, a[{idx}])", geo_helper_stem(g)),
        AbiType::CStr | AbiType::Void => {
            unreachable!("CStr args use a prelude; Void is never a param")
        }
    }
}

/// The `strdup` + `defer free` prelude one CStr arg needs, binding `s{i}`. Keeps the C buffer
/// alive across the call without nesting a `withCString` closure per string arg; the callee
/// reads it as `UnsafePointer(s{i})` ([`cstr_arg_expr`]).
pub(crate) fn cstr_prelude(i: usize, idx: usize) -> String {
    format!(
        "  let s{i} = strdup(napiReadString(env, a[{idx}]) ?? \"\")\n  defer {{ free(s{i}) }}\n"
    )
}

/// The call argument for a CStr param whose [`cstr_prelude`] bound `s{i}`.
pub(crate) fn cstr_arg_expr(i: usize) -> String {
    format!("UnsafePointer(s{i})")
}

/// Append the result-marshalling lines for one entry: bind `let r = <call>` where the shape
/// needs it, then `return napiMake…`. `fold_object_retain` folds an `objcRetain` into a **+0
/// object** return so the handle reaches JS at the uniform +1 the runtime's `__wrapRetained`
/// takes (ADR-0057 §4); a **+1** return and a non-object `Ptr` (`Class`/`SEL`) pass the raw
/// handle through — see the module docs on why that gate is `is_object_type`, not `== Ptr`.
pub(crate) fn marshal_return(s: &mut String, ret: AbiType, call: &str, fold_object_retain: bool) {
    match ret {
        AbiType::Void => {
            s.push_str(&format!("  {call}\n  return napiUndefined(env)\n"));
        }
        AbiType::Ptr => {
            s.push_str(&format!("  let r = {call}\n"));
            if fold_object_retain {
                s.push_str("  return napiMakeHandle(env, objcRetain(r))\n");
            } else {
                s.push_str("  return napiMakeHandle(env, r)\n");
            }
        }
        AbiType::CStr => {
            // A returned char* is +0/borrowed (the -UTF8String shape) — copy, never free.
            s.push_str(&format!("  let r = {call}\n"));
            s.push_str("  return napiMakeString(env, r.map { String(cString: $0) } ?? \"\")\n");
        }
        AbiType::Struct(g) => {
            s.push_str(&format!("  let r = {call}\n"));
            s.push_str(&format!(
                "  return napiMake{}(env, r)\n",
                geo_helper_stem(g)
            ));
        }
        AbiType::Bool => {
            s.push_str(&format!("  return napiMakeBool(env, {call})\n"));
        }
        AbiType::Int8 | AbiType::Int16 | AbiType::Int32 => {
            s.push_str(&format!("  return napiMakeInt64(env, Int64({call}))\n"));
        }
        AbiType::Int64 => {
            s.push_str(&format!("  return napiMakeInt64(env, {call})\n"));
        }
        AbiType::UInt8 | AbiType::UInt16 | AbiType::UInt32 => {
            s.push_str(&format!("  return napiMakeInt64(env, Int64({call}))\n"));
        }
        AbiType::UInt64 => {
            s.push_str(&format!("  return napiMakeUInt64(env, {call})\n"));
        }
        AbiType::Float => {
            s.push_str(&format!("  return napiMakeDouble(env, Double({call}))\n"));
        }
        AbiType::Double => {
            s.push_str(&format!("  return napiMakeDouble(env, {call})\n"));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn a_plus_zero_object_return_folds_a_retain_and_a_plus_one_does_not() {
        // The ADR-0057 §4 seam, in the one renderer both tables share.
        let mut folded = String::new();
        marshal_return(&mut folded, AbiType::Ptr, "call()", true);
        assert!(
            folded.contains("return napiMakeHandle(env, objcRetain(r))"),
            "{folded}"
        );

        let mut raw = String::new();
        marshal_return(&mut raw, AbiType::Ptr, "call()", false);
        assert!(raw.contains("return napiMakeHandle(env, r)"), "{raw}");
        assert!(!raw.contains("objcRetain"), "{raw}");
    }

    #[test]
    fn a_cstr_return_copies_and_never_frees() {
        let mut s = String::new();
        marshal_return(&mut s, AbiType::CStr, "call()", false);
        assert!(s.contains("String(cString: $0)"), "{s}");
        assert!(!s.contains("free("), "{s}");
    }

    #[test]
    fn struct_and_scalar_returns_route_through_their_napi_makers() {
        let mut s = String::new();
        marshal_return(&mut s, AbiType::Struct(GeoStruct::NSRange), "call()", false);
        assert!(s.contains("return napiMakeRange(env, r)"), "{s}");

        let mut f = String::new();
        marshal_return(&mut f, AbiType::Float, "call()", false);
        assert!(
            f.contains("return napiMakeDouble(env, Double(call()))"),
            "{f}"
        );

        let mut v = String::new();
        marshal_return(&mut v, AbiType::Void, "call()", false);
        assert!(v.contains("  call()\n  return napiUndefined(env)"), "{v}");
    }
}
