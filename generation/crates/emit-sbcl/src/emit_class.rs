//! Per-class CLOS emission — the metaclass-backed `defclass` graph (ADR-0034 §1)
//! plus the baked Class string table the runtime startup re-resolution pass
//! consumes (ADR-0034 §6).
//!
//! Each bound ObjC class becomes one
//!
//! ```lisp
//! (defclass ns:ns-string (ns:ns-object) (<foreign ivar slots…>) (:metaclass objc-class))
//! (register-objc-class 'ns:ns-string "NSString" "NSObject")
//! ```
//!
//! - the `defclass` derives from the class's resolved parent
//!   ([`crate::class_graph`]), `ns:`-qualified ([`crate::naming`]); the
//!   runtime-owned root `ns:ns-object` (which carries the foreign `ptr`) is never
//!   re-defined here;
//! - `(:metaclass objc-class)` installs the MOP projection — the metaclass and its
//!   `sb-mop` hooks live in the runtime (leaf 050);
//! - the slot list is the class's **own** opt-in **foreign ivar slots** (ADR-0034
//!   §4): `(<name> :offset <bits> :ctype <kw>)` specs the runtime's
//!   `direct-slot-definition-class` picks up by the presence of `:offset`. The
//!   always-safe accessor-selector path is the default; baked offsets are the
//!   opt-in fast path, so this list is empty unless ivar layout is supplied (the
//!   current IR surfaces none — ivars are reached through accessor selectors);
//! - `(register-objc-class '<sym> "<ObjCName>" "<ObjCSuper>")` bakes class identity
//!   **by string** (never a baked pointer): the startup pass re-`dlopen`s each
//!   framework, then `objc_getClass`es every baked name and stores the fresh
//!   `Class` SAP on the metaclass metaobject (ADR-0034 §6). The ObjC super string
//!   backs the subclass-synthesis fallback and the re-resolution walk order.
//!
//! ## Selector re-resolution lives in the bodies, not a class table
//!
//! ADR-0034 §6 bakes selector *strings*, never `SEL` pointers — but unlike
//! classes, selectors need no eager re-resolution table: `SEL`s live in
//! always-mapped libobjc and survive a `save-lisp-and-die` dump as strings that
//! re-register trivially (spike §6 — `NSObject` survives while `NSString` needs a
//! re-`dlopen`). So the baked **SEL** strings live inline in the dispatch bodies as
//! `(aw-sel "<selector>")` ([`crate::emit_generics`]), lazily resolved+cached per
//! process; only the **Class** string table (`register-objc-class`) needs the
//! framework re-`dlopen` pass. This keeps the two baked tables where each is used.
//!
//! ## Runtime contract (the 040 → 050 seam, fixed here)
//!
//! The emitted forms reference these runtime-owned symbols (leaf 050 must provide
//! them; an inbox note records the contract):
//!
//! - **`objc-class`** — the metaclass (a `standard-class` subclass), ADR-0034 §1.
//! - **`ns:ns-object`** — the root class carrying the foreign `ptr` slot.
//! - **`register-objc-class`** `(symbol objc-name objc-super)` — records a class in
//!   the baked re-resolution table.
//! - foreign slot specs use the keys **`:offset`** (bit offset) + **`:ctype`** (a
//!   keyword the runtime's `slot-value-using-class` `ecase` dispatches on), matching
//!   spike `3-slot-mechanism.lisp`.
//!
//! These names are written **bare**: a generated binding file is read in the
//! runtime/impl package (which `(:use :cl sb-mop)` + the `aw-*` helpers); bound
//! Cocoa names are `ns:`-qualified, and `sb-alien:` operators stay fully qualified
//! ([`crate::ffi_type_mapping`]). The per-file `(in-package …)` header + the
//! `(export …)` of bound names are the orchestration leaf's job (060).

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::write_line;
use apianyware_types::ir::Class;

use crate::class_graph::{ParentRef, RUNTIME_ROOT};
use crate::naming::qualified_class_name;

/// The metaclass every bound ObjC class is defined with (`(:metaclass objc-class)`),
/// ADR-0034 §1. Runtime-owned (leaf 050).
pub const METACLASS: &str = "objc-class";

/// The runtime form that records a class in the baked Class string table for the
/// startup re-resolution pass (ADR-0034 §6). `(register-objc-class '<sym>
/// "<ObjCName>" "<ObjCSuper>")`.
pub const REGISTER_CLASS_FN: &str = "register-objc-class";

/// One opt-in **foreign ivar slot** (ADR-0034 §4): a CLOS slot whose value lives in
/// the ObjC object's foreign memory at a baked **bit** offset, read/written by the
/// runtime's `slot-value-using-class` over `(ptr + offset/8)`.
///
/// Emitted as `(<name> :offset <bits> :ctype <ctype>)`; the `:offset` key is the
/// discriminator the runtime's `direct-slot-definition-class` keys the foreign
/// slot-definition class off (spike `3-slot-mechanism.lisp`). The current IR
/// surfaces no ivar layout, so per-class slot lists are empty in practice — this
/// is the always-ready machinery for the SDK-ivar-layout fast path (ADR-0034 §4:
/// opt-in, not the spine).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ForeignSlot {
    /// The CLOS slot name (kebab-case), reachable via `slot-value`.
    pub name: String,
    /// The ivar's **bit** offset within the ObjC object (the runtime divides by 8;
    /// matches the spike's `(truncate offset 8)`).
    pub offset_bits: u64,
    /// The foreign C-type keyword the runtime's `slot-value-using-class` `ecase`
    /// dispatches on (e.g. `:int`, `:double`, `:sap`). Written verbatim with a
    /// leading colon.
    pub ctype: String,
}

/// Render one foreign ivar slot spec: `(<name> :offset <bits> :ctype :<ctype>)`.
/// The `ctype` is written with a single leading colon if it lacks one.
pub fn render_foreign_slot(slot: &ForeignSlot) -> String {
    let ctype = if slot.ctype.starts_with(':') {
        slot.ctype.clone()
    } else {
        format!(":{}", slot.ctype)
    };
    format!(
        "({} :offset {} :ctype {})",
        slot.name, slot.offset_bits, ctype
    )
}

/// The `ns:`-qualified CLOS superclass spelling for a resolved parent
/// ([`ParentRef`]): the runtime root maps to `ns:ns-object`, every other parent to
/// its `ns:`-qualified name.
fn super_clos_name(parent: &ParentRef) -> String {
    qualified_class_name(parent.objc_name())
}

/// Emit one class's CLOS forms (the `defclass` + the baked Class registration) into
/// `w`, deriving the `defclass` from `parent` ([`crate::class_graph`]) and adding
/// its own opt-in foreign ivar `slots`. The runtime-owned [`RUNTIME_ROOT`] is never
/// emitted (the runtime defines `ns:ns-object`).
pub fn emit_class_forms(
    w: &mut CodeWriter,
    cls: &Class,
    framework: &str,
    parent: &ParentRef,
    slots: &[ForeignSlot],
) {
    if cls.name == RUNTIME_ROOT {
        return;
    }
    write_line!(
        w,
        ";; --- {} ({}) — metaclass-backed class (ADR-0034) ---",
        cls.name,
        framework
    );
    emit_defclass(w, &cls.name, &super_clos_name(parent), slots);
    emit_register_class(w, &cls.name, &cls.superclass);
    w.blank_line();
}

/// Render a **bare synthesized intermediate node** ([`crate::class_graph`]): a class
/// referenced as a superclass but not collected, with no methods. Its own parent is
/// unknowable from an unordered ancestor set, so it roots on the runtime
/// [`RUNTIME_ROOT`] (`ns:ns-object`) with an empty ObjC super string.
pub fn emit_bare_node(w: &mut CodeWriter, class_name: &str, framework: &str) {
    write_line!(
        w,
        ";; --- {} ({}) — synthesized bare class-graph node ---",
        class_name,
        framework
    );
    emit_defclass(w, class_name, &qualified_class_name(RUNTIME_ROOT), &[]);
    emit_register_class(w, class_name, "");
    w.blank_line();
}

/// The `(defclass ns:<cls> (ns:<super>) (<slots>) (:metaclass objc-class))` form.
fn emit_defclass(w: &mut CodeWriter, class_name: &str, super_clos: &str, slots: &[ForeignSlot]) {
    let cls_clos = qualified_class_name(class_name);
    if slots.is_empty() {
        write_line!(
            w,
            "(defclass {cls_clos} ({super_clos}) () (:metaclass {METACLASS}))"
        );
    } else {
        write_line!(w, "(defclass {cls_clos} ({super_clos})");
        w.line("  (");
        for slot in slots {
            write_line!(w, "   {}", render_foreign_slot(slot));
        }
        w.line("   )");
        write_line!(w, "  (:metaclass {METACLASS}))");
    }
}

/// The `(register-objc-class 'ns:<cls> "<ObjCName>" "<ObjCSuper>")` form baking
/// class identity by string for the startup re-resolution pass (ADR-0034 §6).
fn emit_register_class(w: &mut CodeWriter, class_name: &str, objc_super: &str) {
    write_line!(
        w,
        "({REGISTER_CLASS_FN} '{} \"{}\" \"{}\")",
        qualified_class_name(class_name),
        class_name,
        objc_super
    );
}

/// Convenience: render one class's CLOS forms to a string (no foreign slots).
/// Used by snapshot tests and the orchestration facade.
pub fn render_class(cls: &Class, framework: &str, parent: &ParentRef) -> String {
    let mut w = CodeWriter::new();
    emit_class_forms(&mut w, cls, framework, parent, &[]);
    w.finish()
}

/// Convenience: render a bare synthesized node to a string.
pub fn render_bare_node(class_name: &str, framework: &str) -> String {
    let mut w = CodeWriter::new();
    emit_bare_node(&mut w, class_name, framework);
    w.finish()
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::Class;

    fn cls(name: &str, superclass: &str) -> Class {
        Class {
            name: name.into(),
            superclass: superclass.into(),
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

    #[test]
    fn root_class_derives_from_ns_object() {
        // NSString : NSObject — the defclass roots on the runtime-owned ns:ns-object,
        // metaclass objc-class, empty slots; the Class string table bakes the
        // identity + super by string.
        let out = render_class(
            &cls("NSString", "NSObject"),
            "Foundation",
            &ParentRef::RuntimeRoot,
        );
        assert!(out.contains("(defclass ns:ns-string (ns:ns-object) () (:metaclass objc-class))"));
        assert!(out.contains("(register-objc-class 'ns:ns-string \"NSString\" \"NSObject\")"));
        // The runtime-owned root is never re-defined as ns:ns-object's own parent.
        assert!(out.contains(";; --- NSString (Foundation)"));
    }

    #[test]
    fn local_parent_is_ns_qualified() {
        let out = render_class(
            &cls("NSView", "NSResponder"),
            "AppKit",
            &ParentRef::Local("NSResponder".into()),
        );
        assert!(out.contains("(defclass ns:ns-view (ns:ns-responder) () (:metaclass objc-class))"));
        assert!(out.contains("(register-objc-class 'ns:ns-view \"NSView\" \"NSResponder\")"));
    }

    #[test]
    fn cross_framework_parent_is_ns_qualified() {
        // The parent's owning framework does not change the ns: package — every
        // bound class is one ns: symbol.
        let out = render_class(
            &cls("NSTextStorage", "NSMutableAttributedString"),
            "AppKit",
            &ParentRef::CrossFramework {
                name: "NSMutableAttributedString".into(),
                fw_low: "foundation".into(),
            },
        );
        assert!(out.contains(
            "(defclass ns:ns-text-storage (ns:ns-mutable-attributed-string) () (:metaclass objc-class))"
        ));
    }

    #[test]
    fn acronym_aware_class_names() {
        let out = render_class(
            &cls("NSURLSession", "NSObject"),
            "Foundation",
            &ParentRef::RuntimeRoot,
        );
        // URL stays whole (acronym-aware), not ns-u-r-l-session.
        assert!(out.contains("(defclass ns:ns-url-session (ns:ns-object)"));
        assert!(out.contains("(register-objc-class 'ns:ns-url-session \"NSURLSession\""));
    }

    #[test]
    fn runtime_root_is_not_emitted() {
        // NSObject itself is runtime-owned (ns:ns-object) — the emitter never
        // re-defines it.
        let out = render_class(&cls("NSObject", ""), "Foundation", &ParentRef::RuntimeRoot);
        assert_eq!(out, "");
    }

    #[test]
    fn synthesized_bare_node_roots_on_ns_object() {
        let out = render_bare_node("Mid", "Widgets");
        assert!(out.contains("(defclass ns:mid (ns:ns-object) () (:metaclass objc-class))"));
        // Empty ObjC super string for a synthesized node.
        assert!(out.contains("(register-objc-class 'ns:mid \"Mid\" \"\")"));
        assert!(out.contains("synthesized bare class-graph node"));
    }

    #[test]
    fn empty_objc_super_for_independent_root() {
        // NSProxy : (nothing) — CLOS roots it on ns:ns-object for the ptr slot, but
        // the baked ObjC super string is empty (an independent ObjC root).
        let out = render_class(&cls("NSProxy", ""), "Foundation", &ParentRef::RuntimeRoot);
        assert!(out.contains("(defclass ns:ns-proxy (ns:ns-object) () (:metaclass objc-class))"));
        assert!(out.contains("(register-objc-class 'ns:ns-proxy \"NSProxy\" \"\")"));
    }

    #[test]
    fn foreign_slot_spec_carries_offset_and_ctype() {
        let slot = ForeignSlot {
            name: "counter".into(),
            offset_bits: 64,
            ctype: "int".into(),
        };
        assert_eq!(
            render_foreign_slot(&slot),
            "(counter :offset 64 :ctype :int)"
        );
        // An already-colon'd ctype is left as-is.
        let slot2 = ForeignSlot {
            name: "scale".into(),
            offset_bits: 128,
            ctype: ":double".into(),
        };
        assert_eq!(
            render_foreign_slot(&slot2),
            "(scale :offset 128 :ctype :double)"
        );
    }

    #[test]
    fn class_with_foreign_slots_renders_slot_list() {
        let mut w = CodeWriter::new();
        let slots = vec![
            ForeignSlot {
                name: "counter".into(),
                offset_bits: 0,
                ctype: "int".into(),
            },
            ForeignSlot {
                name: "scale".into(),
                offset_bits: 64,
                ctype: "double".into(),
            },
        ];
        emit_class_forms(
            &mut w,
            &cls("NSFoo", "NSObject"),
            "Widgets",
            &ParentRef::RuntimeRoot,
            &slots,
        );
        let out = w.finish();
        assert!(out.contains("(defclass ns:ns-foo (ns:ns-object)"));
        assert!(out.contains("(counter :offset 0 :ctype :int)"));
        assert!(out.contains("(scale :offset 64 :ctype :double)"));
        assert!(out.contains("(:metaclass objc-class))"));
    }
}
