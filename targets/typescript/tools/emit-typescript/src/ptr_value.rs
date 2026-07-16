//! The two **pointer-but-not-object** IR kinds — `TypeRefKind::Selector` (ObjC `SEL`) and
//! `TypeRefKind::ClassRef` (the `Class` metatype) — and how each crosses the dispatch seam.
//!
//! ## Why these two need their own module
//!
//! At the ABI they are indistinguishable from an object: [`AbiType::from_type_ref`] collapses
//! `Class`/`Id`/`Instancetype`/`ClassRef`/`Selector` alike to [`AbiType::Ptr`], so all five share a
//! dispatch entry. At the **TS surface** they are nothing like an object: a `SEL` is a `string`
//! (ADR-0055 §3), a `Class` is the bound constructor, and neither is ever *wrapped* — no retain, no
//! uniqued wrapper, no disposal (ADR-0057 §4: `objc_retain` on a `SEL` is UB, and retaining a
//! `Class` leaks; this is exactly why they route to the non-folding, non-wrapping `_n` entry).
//!
//! That gap is what made them wrong: [`FfiTypeMapper::is_object_type`] is `Class | Id |
//! Instancetype`, so **both** emitter families' param arms fell through to "pass it raw" and their
//! return arms to "return the raw handle" — a JS `string` crossing into a `bigint` slot (a nil
//! `SEL`: `-[NSControl setAction:]` bound no action), and a `bigint` handle returned under a
//! declared `string` / `typeof NSObject`.
//!
//! ## One decision, four readers
//!
//! The crossing is a property of the *kind*, identical for a method and a free function, so it is
//! computed **here, once**, and read by all four sites that must agree — each family's param arm,
//! return arm, and runtime-seam import set ([`crate::emit_class`], [`crate::emit_functions`]). The
//! same mirror discipline the retain axis follows (`method_retain_axis`, one predicate / three
//! readers): an emitted body and the helper it imports can never disagree, because neither derives
//! the fact independently.
//!
//! The dispatch **entry name is untouched** — the ABI is still `Ptr` — so the collected==referenced
//! mirror invariant over the native tables holds with no table change.

use apianyware_types::type_ref::{TypeRef, TypeRefKind};

/// A pointer-shaped IR kind that is **not** a retainable object, and so crosses the seam by
/// conversion rather than by wrapping.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PtrValue {
    /// ObjC `SEL` ⟷ its selector-name `string` (ADR-0055 §3).
    Selector,
    /// ObjC `Class` metatype ⟷ the bound TS constructor (`typeof NSObject`).
    ClassRef,
}

impl PtrValue {
    /// The [`PtrValue`] of a type, or `None` for every other kind (objects — which wrap — scalars,
    /// structs, strings, blocks). The single classifier; never re-match `TypeRefKind` elsewhere.
    pub fn of(t: &TypeRef) -> Option<Self> {
        match t.kind {
            TypeRefKind::Selector => Some(Self::Selector),
            TypeRefKind::ClassRef => Some(Self::ClassRef),
            _ => None,
        }
    }

    /// The argument expression for a value of this kind crossing **in** — the `__unwrap` analogue.
    /// `__sel` interns the name (and maps `null` to the nil `SEL`); `__classArg` resolves the
    /// constructor to its `Class` handle.
    pub fn param_expr(self, name: &str) -> String {
        match self {
            Self::Selector => format!("__sel({name})"),
            Self::ClassRef => format!("__classArg({name})"),
        }
    }

    /// The expression converting a raw handle crossing **out** back to the declared TS type —
    /// wrapped around the dispatch call. Both helpers return `T | null` (the nil `SEL` / nil
    /// `Class`), so the caller appends the same `!` non-null assertion the object arms use when the
    /// IR declares the return non-null.
    pub fn return_expr(self, call: &str) -> String {
        match self {
            Self::Selector => format!("__selName({call})"),
            Self::ClassRef => format!("__classCtor({call})"),
        }
    }

    /// The runtime-seam symbol [`Self::param_expr`] calls — imported by whichever emitter renders it.
    pub fn param_symbol(self) -> &'static str {
        match self {
            Self::Selector => "__sel",
            Self::ClassRef => "__classArg",
        }
    }

    /// The runtime-seam symbol [`Self::return_expr`] calls.
    pub fn return_symbol(self) -> &'static str {
        match self {
            Self::Selector => "__selName",
            Self::ClassRef => "__classCtor",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    #[test]
    fn classifies_only_the_two_non_object_pointer_kinds() {
        assert_eq!(
            PtrValue::of(&ty(TypeRefKind::Selector)),
            Some(PtrValue::Selector)
        );
        assert_eq!(
            PtrValue::of(&ty(TypeRefKind::ClassRef)),
            Some(PtrValue::ClassRef)
        );
        // An object wraps (it is not a PtrValue); so do scalars, strings and raw pointers.
        assert_eq!(
            PtrValue::of(&ty(TypeRefKind::Id {
                protocols: Vec::new()
            })),
            None
        );
        assert_eq!(
            PtrValue::of(&ty(TypeRefKind::Class {
                name: "NSView".into(),
                framework: None,
                params: vec![],
            })),
            None
        );
        assert_eq!(PtrValue::of(&ty(TypeRefKind::Instancetype)), None);
        assert_eq!(PtrValue::of(&ty(TypeRefKind::Pointer)), None);
        assert_eq!(PtrValue::of(&ty(TypeRefKind::CString)), None);
        assert_eq!(PtrValue::of(&TypeRef::void()), None);
    }

    #[test]
    fn crossings_and_their_seam_symbols_agree() {
        // The property the mirror discipline rests on: the expression an emitter renders and the
        // symbol it imports name the same helper.
        for (pv, param, ret) in [
            (PtrValue::Selector, "__sel", "__selName"),
            (PtrValue::ClassRef, "__classArg", "__classCtor"),
        ] {
            assert!(pv.param_expr("x").starts_with(param));
            assert_eq!(pv.param_symbol(), param);
            assert!(pv.return_expr("call").starts_with(ret));
            assert_eq!(pv.return_symbol(), ret);
        }
        assert_eq!(PtrValue::Selector.param_expr("action"), "__sel(action)");
        assert_eq!(
            PtrValue::ClassRef.param_expr("aClass"),
            "__classArg(aClass)"
        );
        assert_eq!(
            PtrValue::Selector.return_expr("__dispatch.aw_ts_msg_0_P_n(x)"),
            "__selName(__dispatch.aw_ts_msg_0_P_n(x))"
        );
    }
}
