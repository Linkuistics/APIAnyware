//! Per-selector generic dispatch (ADR-0034 §2, D6) — the heart of the emitter.
//!
//! Over the metaclass-backed class graph ([`crate::emit_class`]), each distinct
//! selector becomes **one** `defgeneric` in the `ns:` package (the named contract
//! surface, spec §3.2) and each `(class × selector)` becomes **one** `defmethod`
//! **specialized on the receiver**, whose body is the direct `objc_msgSend`
//! `sb-alien` crossing (ADR-0015/0038 §3). This is CLOS generic dispatch + method
//! combination + `call-next-method` — **not** literal multiple-argument dispatch
//! (ObjC is single-receiver).
//!
//! ## The dispatch body
//!
//! `objc_msgSend` is variadic at the C level and arm64 forbids calling it
//! variadically — every call shape needs its own typed cast. The `sb-alien` idiom:
//! take the function's address once (the runtime SAP global `+objc-msgsend+`,
//! re-resolved at startup) and `sap-alien`-cast it to the exact `(function …)` type
//! at each call site:
//!
//! ```lisp
//! (defmethod ns:object-at-index ((self ns:ns-array) index)
//!   (aw-wrap
//!    (sb-alien:alien-funcall
//!     (sb-alien:sap-alien +objc-msgsend+
//!      (sb-alien:function sb-alien:system-area-pointer
//!                         sb-alien:system-area-pointer sb-alien:system-area-pointer
//!                         (sb-alien:unsigned 64)))
//!     (aw-ptr self) (aw-sel "objectAtIndex:") index)))
//! ```
//!
//! The leading two arg types are always `system-area-pointer` (the `id` receiver +
//! the `SEL`); the rest come from [`crate::ffi_type_mapping`]. Object args coerce
//! through `aw-ptr` (instance|nil → `id`), object returns wrap through `aw-wrap`
//! (the exact bound type via the ADR-0034 class registry, retained-aware); scalars
//! and `(boolean 8)` cross directly. This is the open-coded analogue of chez's
//! per-selector `foreign-procedure`; SBCL needs **no** `generics.ss`-style sharding
//! (ADR-0034 §3 — the compile-cost blow-up does not reproduce in native CLOS).
//!
//! ## The `objc_exposed == false` residual: no direct body, a trampoline `defmethod`
//!
//! A Swift-native method/init (`objc_exposed == false`, charter #4 / ADR-0026 §3)
//! has **no** `objc_msgSend` entry — binding it *directly* is a latent crash, so it
//! gets no `objc_msgSend` body. It is collected ([`collect_residual`]) for the §6d
//! count (`554 method` + `576 init`) and, for a **class** owner, wired by
//! [`emit_swift_native_residual`] (leaf 045) into a receiver-specialized `defmethod` /
//! `make-<owner>` constructor that crosses the `libAPIAnywareSbcl` trampoline instead
//! (the residual method generics fold into [`collect_generics`] for the lockstep).
//!
//! ## Conformed-protocol flattening (leaf 040/030)
//!
//! A bound class's dispatch surface is its **own** declared methods *plus* the
//! methods of every protocol it directly conforms to (closed over protocol
//! inheritance) — but **not** its superclass-inherited methods, which CLOS method
//! inheritance covers structurally (a `defmethod` on `ns:ns-view` applies to
//! `ns:ns-control` instances). Class inheritance rides the `defclass` graph;
//! protocol conformance does **not** (a protocol is no CLOS superclass), so a
//! conformed protocol's methods (`NSData`'s `copyWithZone:` from `NSCopying`) live
//! on no ancestor and are flattened here, as receiver-specialized `defmethod`s.
//! [`class_dispatches`] takes the [`ProtocolRegistry`] and folds in the
//! `all_methods` entries whose `origin` is in the class's own conformance closure
//! ([`effective_methods`]); own methods win ties. An empty registry (the default /
//! per-class convenience path) flattens nothing — identical to the pre-flattening
//! surface.
//!
//! ## Class methods + error-out methods
//!
//! - **Class methods** dispatch on the class metaobject via an `(eql (find-class
//!   'ns:<cls>))` receiver — still per-selector generics specialized on the
//!   receiver (D6), the receiver being the class object. The body's receiver is the
//!   re-resolved `Class` SAP `(aw-class "<ObjCName>")`.
//! - **`NSError**` out-param methods** (ADR-0006 / 0037) surface errors as
//!   **signalled conditions**, not `(values result error)` tuples. The visible CLOS
//!   arity drops the trailing `NSError**`; the body runs inside the runtime macro
//!   `aw-with-error-cell`, which allocates the cell, threads it as the trailing
//!   `id*` arg, and signals `ns:cocoa-error` when the primary return indicates
//!   failure (the signalling logic is runtime-owned, leaf 050).
//!
//! ## Runtime contract (the 040 → 050 seam, fixed here)
//!
//! Emitted bodies reference these runtime-owned symbols (leaf 050 provides them;
//! an inbox note records the contract). Written **bare** (the binding file is read
//! in the runtime/impl package); bound names are `ns:`-qualified; `sb-alien:`
//! operators stay fully qualified.
//!
//! - **`+objc-msgsend+`** — the `objc_msgSend` SAP (re-resolved at startup).
//! - **`aw-ptr`** `(instance|nil → id SAP)` — outbound object coercion.
//! - **`aw-wrap`** `(id SAP [retained?] → instance)` — inbound object wrap.
//! - **`aw-sel`** `(string → SEL SAP)` — selector resolution (lazy, cached,
//!   re-resolved per process from the baked string — ADR-0034 §6).
//! - **`aw-class`** `(string → Class SAP)` — class lookup (lazy/cached) for the
//!   class-method receiver.
//! - **`aw-block`** `(closure → block SAP)` — Lisp closure → C block (the bounce is
//!   runtime, ADR-0035).
//! - **`aw-with-error-cell`** `((var) body…)` — the `NSError**` cell + condition
//!   signaller (ADR-0037).
//! - **`register-objc-init`** `('ns:<cls> "<initSelector>" (:kw…))` — bakes an
//!   `objc_exposed` init's selector + keyword list for the runtime's
//!   `make-instance`→alloc/init mapping (ADR-0034 §5).

use std::collections::{BTreeMap, BTreeSet, HashSet};

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::enrichment::class_error_selectors;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Class, Framework, Method, Property};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::{SbclFfiTypeMapper, SAP};
use crate::method_filter::{is_error_out_method, is_supported_method_ctx};
use crate::naming::{qualified_class_name, qualified_generic_name, selector_keyword_symbols};
use crate::protocol_registry::ProtocolRegistry;
use crate::trampoline::{
    class_residual_inits, class_residual_methods, struct_residual_methods, MethodTrampoline,
};

/// The `objc_msgSend` function SAP, runtime-owned + startup-re-resolved (ADR-0038).
pub const MSGSEND_SAP: &str = "+objc-msgsend+";
/// Outbound object coercion (instance|nil → `id` SAP) — the contract's `->ptr`.
pub const PTR_FN: &str = "aw-ptr";
/// Inbound object wrap (`id` SAP [retained?] → exact bound instance).
pub const WRAP_FN: &str = "aw-wrap";
/// Selector resolution (string → cached/re-resolved `SEL` SAP).
pub const SEL_FN: &str = "aw-sel";
/// Class lookup (string → cached/re-resolved `Class` SAP) for class-method receivers.
pub const CLASS_FN: &str = "aw-class";
/// Lisp closure → C block SAP (the main-thread bounce is runtime, ADR-0035).
pub const BLOCK_FN: &str = "aw-block";
/// The `NSError**` cell + condition signaller macro (ADR-0037).
pub const ERROR_CELL_MACRO: &str = "aw-with-error-cell";
/// Bakes an `objc_exposed` init selector + keyword list for `make-instance` (§5).
pub const REGISTER_INIT_FN: &str = "register-objc-init";

// --- the global defgeneric set --------------------------------------------

/// One generic-function declaration: the `ns:`-qualified name + its **visible**
/// arity (receiver excluded). Congruent across all classes binding the selector —
/// arity is fixed by the selector (its colon count, minus one for an error-out
/// method's `NSError**`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GenericDecl {
    /// The `ns:`-qualified generic-function symbol (e.g. `ns:object-at-index`).
    pub name: String,
    /// The number of arguments after the receiver.
    pub arity: usize,
}

/// Collect the global set of distinct generics across every loaded framework — one
/// `defgeneric` per selector, exactly the selectors [`emit_class_dispatch`] emits a
/// `defmethod` for (so the declared surface and the methods stay in lock-step,
/// mirroring gerbil's `collect_global_surface_selectors`). Sorted by name.
///
/// Two classes binding the same selector add methods to the **same** generic (the
/// natural CL package model — one symbol, one binding). A selector that kebabs to a
/// name already seen with a *different* arity is a genuine congruence conflict the
/// orchestration leaf (060) resolves by collision-rename; here the first arity
/// wins and the clash is surfaced via [`generic_arity_conflicts`].
pub fn collect_generics(
    frameworks: &[&Framework],
    protocols: &ProtocolRegistry,
) -> Vec<GenericDecl> {
    let mut by_name: BTreeMap<String, usize> = BTreeMap::new();
    for fw in frameworks {
        for cls in &fw.classes {
            let class_errs = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
            for d in class_dispatches(cls, &class_errs, protocols) {
                by_name.entry(d.generic_name()).or_insert(d.arity());
            }
            // 045: the Swift-native residual method `defmethod`s extend their own
            // selector-analogous generics (base + labels); fold them into the same set
            // so each has a matching `defgeneric` (the lockstep). Inserted after the
            // ObjC dispatches, so a name shared with an ObjC selector keeps the ObjC
            // arity (first-wins); a genuine arity clash is surfaced by
            // [`generic_arity_conflicts`].
            for t in class_residual_methods(&fw.name, &cls.name, &cls.methods) {
                let (name, arity) = t.generic_decl();
                by_name.entry(name).or_insert(arity);
            }
        }
        // ADR-0042: a value struct's residual methods are `defmethod`s on the struct's
        // CLOS class, so they extend the same selector-analogous generics — fold them
        // into the one set (the lockstep, exactly like the class residual above).
        for st in &fw.structs {
            for t in struct_residual_methods(&fw.name, &st.name, &st.methods) {
                let (name, arity) = t.generic_decl();
                by_name.entry(name).or_insert(arity);
            }
        }
    }
    by_name
        .into_iter()
        .map(|(name, arity)| GenericDecl { name, arity })
        .collect()
}

/// The canonical (qualified-generic-name → arity) map for a framework's generic set —
/// the first-wins arity `collect_generics` settled per name. Used to keep every emitted
/// residual `defmethod` congruent with its `defgeneric` (ADR-0042): a selector that
/// post-kebabs to an already-declared name at a DIFFERENT arity cannot share the generic.
pub fn generic_arity_index(generics: &[GenericDecl]) -> BTreeMap<String, usize> {
    generics.iter().map(|d| (d.name.clone(), d.arity)).collect()
}

/// True when a residual method named NAME at ARITY may extend the canonical generic — i.e.
/// the generic is unknown to INDEX (no conflict possible) or declared at the same arity.
/// A name present at a *different* arity is a CLOS congruence conflict; the caller drops
/// that method's `defmethod` (it would crash at load).
pub fn arity_consistent(name: &str, arity: usize, index: &BTreeMap<String, usize>) -> bool {
    index.get(name).is_none_or(|&a| a == arity)
}

/// Selectors that kebab to one generic name under **two** different arities across
/// the program — a CL congruence conflict the orchestration leaf must collision-
/// rename. Empty in practice (distinct ObjC selectors rarely collide post-kebab);
/// surfaced so a future framework that does trip it fails loudly, not silently.
pub fn generic_arity_conflicts(
    frameworks: &[&Framework],
    protocols: &ProtocolRegistry,
) -> Vec<String> {
    let mut seen: BTreeMap<String, usize> = BTreeMap::new();
    let mut conflicts: BTreeSet<String> = BTreeSet::new();
    let mut record = |name: String, arity: usize| match seen.get(&name) {
        Some(&a) if a != arity => {
            conflicts.insert(name);
        }
        None => {
            seen.insert(name, arity);
        }
        _ => {}
    };
    for fw in frameworks {
        for cls in &fw.classes {
            let class_errs = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
            for d in class_dispatches(cls, &class_errs, protocols) {
                record(d.generic_name(), d.arity());
            }
            // 045: the residual method generics share the one congruence namespace, so
            // a residual method whose name clashes an ObjC selector at a *different*
            // arity is surfaced loudly here too (not silently mis-emitted).
            for t in class_residual_methods(&fw.name, &cls.name, &cls.methods) {
                let (name, arity) = t.generic_decl();
                record(name, arity);
            }
        }
        // ADR-0042: value-struct residual generics share the one congruence namespace
        // too, so a struct method clashing an ObjC selector at a different arity surfaces.
        for st in &fw.structs {
            for t in struct_residual_methods(&fw.name, &st.name, &st.methods) {
                let (name, arity) = t.generic_decl();
                record(name, arity);
            }
        }
    }
    conflicts.into_iter().collect()
}

/// Render the global `defgeneric` block: one `(defgeneric ns:<sel> (receiver
/// arg0…) (:documentation …))` per declaration. The arglist names are neutral
/// (`receiver`, `argN`) — CLOS requires only congruent *arity* across the methods,
/// not matching names, and the methods supply their own param-derived names.
pub fn render_generics(decls: &[GenericDecl]) -> String {
    let mut w = CodeWriter::new();
    for d in decls {
        let mut arglist = String::from("receiver");
        for i in 0..d.arity {
            arglist.push_str(&format!(" arg{i}"));
        }
        write_line!(
            w,
            "(defgeneric {} ({}) (:documentation \"ObjC selector generic ({} arg{}).\"))",
            d.name,
            arglist,
            d.arity,
            if d.arity == 1 { "" } else { "s" }
        );
    }
    w.finish()
}

// --- the Swift-native residual --------------------------------------------

/// One `objc_exposed == false` declaration routed to the trampoline residual (leaf
/// 050) rather than emitted as a direct `objc_msgSend` body.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ResidualEntry {
    /// The owning ObjC class name.
    pub owner: String,
    /// The Swift-native selector.
    pub selector: String,
    /// An initializer (vs a regular method) — feeds the §6d `init` vs `method`
    /// breakdown.
    pub is_init: bool,
}

/// Collect a class's **declared** Swift-native methods/inits (`objc_exposed ==
/// false`) for the trampoline residual. The global trampoline pass (leaf 050) emits
/// `@_cdecl` entries for *declared* methods only, so this walks `cls.methods` (not
/// inherited/effective). These are deliberately **not** emitted as `defmethod`
/// bodies here.
pub fn collect_residual(cls: &Class) -> Vec<ResidualEntry> {
    cls.methods
        .iter()
        .filter(|m| !m.objc_exposed)
        .map(|m| ResidualEntry {
            owner: cls.name.clone(),
            selector: m.selector.clone(),
            is_init: m.init_method,
        })
        .collect()
}

// --- per-class defmethod emission -----------------------------------------

/// Emit one class's dispatch surface into `w`: a `defmethod` per `objc_exposed`
/// instance/class method and property accessor (specialized on the receiver), plus
/// a `register-objc-init` per `objc_exposed` init for the runtime's `make-instance`
/// (§5). `objc_exposed == false` methods/inits are skipped here ([`collect_residual`]
/// routes them to the trampoline). `error_selectors` is the class's
/// enrichment-derived `NSError**` set.
pub fn emit_class_dispatch(
    w: &mut CodeWriter,
    cls: &Class,
    framework: &str,
    error_selectors: &HashSet<String>,
    protocols: &ProtocolRegistry,
) {
    let dispatches = class_dispatches(cls, error_selectors, protocols);
    let inits = exposed_inits(cls);
    if dispatches.is_empty() && inits.is_empty() {
        return;
    }
    write_line!(
        w,
        ";; --- {} ({}) — dispatch (ADR-0034 §2) ---",
        cls.name,
        framework
    );
    for d in &dispatches {
        emit_defmethod(w, &cls.name, d, error_selectors);
    }
    for m in &inits {
        emit_register_init(w, &cls.name, m);
    }
    w.blank_line();
}

/// Convenience: render one class's dispatch surface to a string (no enrichment
/// error selectors, **no** conformed-protocol flattening). Used by snapshot tests
/// that exercise own-method emission in isolation.
pub fn render_class_dispatch(cls: &Class, framework: &str) -> String {
    render_class_dispatch_with(cls, framework, &ProtocolRegistry::new())
}

/// Like [`render_class_dispatch`] but with a [`ProtocolRegistry`] driving
/// conformed-protocol flattening — the shape the orchestration facade (060) uses,
/// and the one flattening tests exercise.
pub fn render_class_dispatch_with(
    cls: &Class,
    framework: &str,
    protocols: &ProtocolRegistry,
) -> String {
    let mut w = CodeWriter::new();
    emit_class_dispatch(&mut w, cls, framework, &HashSet::new(), protocols);
    w.finish()
}

/// Emit a **class** owner's Swift-native residual section (leaf 045): a
/// receiver-specialized `(defmethod ns:<generic> ((self ns:<owner>) …) …)` per bindable
/// Swift-native instance method (`objc_exposed == false`) and a `(defun ns:make-<owner>
/// …)` constructor per bindable initializer — each trampolined through
/// `libAPIAnywareSbcl`, not `objc_msgSend`. Walks `cls.methods` (the *declared* methods,
/// the §6d agreement). A residual method whose generic name collides with one the class
/// already ObjC-dispatches is **dropped** (the direct ObjC binding wins — two methods on
/// one generic + receiver specializer would silently redefine). `async` residual methods
/// are deferred (a runtime-coupled completion bridge); value-struct (population-B) owners
/// are out of scope (no CLOS class to specialize on) — both a follow-up leaf.
pub fn emit_swift_native_residual(
    w: &mut CodeWriter,
    cls: &Class,
    framework: &str,
    error_selectors: &HashSet<String>,
    protocols: &ProtocolRegistry,
    generic_arity: &BTreeMap<String, usize>,
) {
    let methods = class_residual_methods(framework, &cls.name, &cls.methods);
    let inits = class_residual_inits(framework, &cls.name, &cls.methods);
    if methods.is_empty() && inits.is_empty() {
        return;
    }
    // The ObjC dispatch wins any generic-name collision; an arity clash against the
    // canonical generic (ADR-0042) is dropped too — its `defmethod` cannot share the
    // generic and would crash at load (latent for class owners, manifest for structs).
    let objc_generics: HashSet<String> = class_dispatches(cls, error_selectors, protocols)
        .iter()
        .map(|d| d.generic_name())
        .collect();
    let visible: Vec<&MethodTrampoline> = methods
        .iter()
        .filter(|t| {
            let (name, arity) = t.generic_decl();
            !objc_generics.contains(&name) && arity_consistent(&name, arity, generic_arity)
        })
        .collect();
    if visible.is_empty() && inits.is_empty() {
        return;
    }

    write_line!(
        w,
        ";; --- {} ({}) — Swift-native residual (receiver-handle trampolines, ADR-0038) ---",
        cls.name,
        framework
    );
    for t in &visible {
        for line in t.render_defmethod().lines() {
            write_line!(w, "{}", line);
        }
    }
    for t in &inits {
        for line in t.render_constructor().lines() {
            write_line!(w, "{}", line);
        }
    }
    w.blank_line();
}

// --- internal: the lowered dispatch representation ------------------------

/// A coercion role for one outbound argument (drives `aw-ptr`/`aw-sel`/`aw-block`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ArgRole {
    /// An `id`/object argument — coerced via `aw-ptr`.
    Object,
    /// A `SEL` argument — coerced via `aw-sel`.
    Selector,
    /// A block argument — coerced via `aw-block`.
    Block,
    /// A scalar / struct-by-value — passed through.
    Plain,
}

/// One outbound argument: its CLOS formal name, alien type, and coercion role.
#[derive(Debug, Clone)]
struct DispatchArg {
    name: String,
    alien: String,
    role: ArgRole,
}

/// A lowered, target-neutral dispatch — a method, class method, or property
/// accessor reduced to the data the body renderer needs.
#[derive(Debug, Clone)]
struct Dispatch {
    /// The ObjC selector (for `aw-sel` + arity).
    selector: String,
    /// Dispatch on the class metaobject (class method) vs an instance.
    class_receiver: bool,
    /// Visible outbound args (excludes the `NSError**` cell of an error-out method).
    args: Vec<DispatchArg>,
    /// The alien return type spelling.
    ret_alien: String,
    /// Whether the return is an object (⇒ wrap) ...
    ret_object: bool,
    /// ... and if so, whether it is +1 retained (`init`/`copy`/`new` families).
    ret_retained: bool,
    /// An `NSError**` out-param method (⇒ wrap the body in `aw-with-error-cell`).
    error_out: bool,
}

impl Dispatch {
    /// The `ns:`-qualified generic-function name.
    fn generic_name(&self) -> String {
        qualified_generic_name(&self.selector)
    }
    /// The visible arity (receiver excluded).
    fn arity(&self) -> usize {
        self.args.len()
    }
}

/// The mapper used throughout (zero-sized).
fn mapper() -> SbclFfiTypeMapper {
    SbclFfiTypeMapper
}

/// Lower one class's `objc_exposed` instance/class methods + property accessors to
/// the deduped, ordered dispatch list. Precedence (gerbil-aligned): property >
/// instance method > class method, deduped within a receiver kind by generic name.
/// `objc_exposed == false` methods are excluded (they route to the residual).
///
/// The method set is [`effective_methods`] — own declared methods **plus** the
/// conformed-protocol methods flattened from `all_methods` via the class's own
/// conformance closure (`protocols`), but **not** superclass-inherited methods
/// (CLOS inheritance covers those). See the module-level "Conformed-protocol
/// flattening" note.
fn class_dispatches(
    cls: &Class,
    error_selectors: &HashSet<String>,
    protocols: &ProtocolRegistry,
) -> Vec<Dispatch> {
    let m = mapper();
    let mut out: Vec<Dispatch> = Vec::new();
    // (class_receiver, generic-name) → already emitted, for dedup.
    let mut seen: HashSet<(bool, String)> = HashSet::new();

    let mut push = |d: Dispatch| {
        let key = (d.class_receiver, qualified_generic_name(&d.selector));
        if seen.insert(key) {
            out.push(d);
        }
    };

    // 1. Properties (getter + setter) — highest precedence.
    for p in &cls.properties {
        if !p.objc_exposed {
            continue;
        }
        push(property_getter_dispatch(p));
        if !p.readonly {
            push(property_setter_dispatch(p));
        }
    }

    // 2. Instance methods, then 3. class methods (non-init, objc_exposed, supported)
    // — over the effective set (own + conformed-protocol, superclass-inherited
    // excluded).
    let conformed = protocols.conformance_closure(&cls.protocols);
    let methods = effective_methods(cls, &conformed);
    for class_receiver in [false, true] {
        for &meth in &methods {
            if meth.init_method || meth.class_method != class_receiver || !meth.objc_exposed {
                continue;
            }
            if !is_supported_method_ctx(meth, &m, error_selectors) {
                continue;
            }
            push(method_dispatch(meth, error_selectors));
        }
    }

    out
}

/// The methods a class emits dispatch for: its **own** declared methods chained
/// with the **conformed-protocol** methods the resolve phase flattened into
/// `all_methods` (origin ∈ the class's own conformance closure), but **not** the
/// superclass-inherited set (CLOS method inheritance over the `defclass` graph
/// covers a subclass dispatching to an ancestor's method — re-emitting would be
/// redundant). `all_methods` entries whose `origin` is a conformed protocol are
/// exactly the protocol-contributed set; superclass-inherited entries carry an
/// ancestor-*class* origin and stay filtered out. Own methods win ties; deduped by
/// selector. With an empty closure this is just `cls.methods`.
fn effective_methods<'a>(cls: &'a Class, conformed: &BTreeSet<String>) -> Vec<&'a Method> {
    let mut seen: HashSet<&str> = HashSet::new();
    cls.methods
        .iter()
        .chain(cls.all_methods.iter().filter(|m| {
            m.origin
                .as_deref()
                .is_some_and(|origin| conformed.contains(origin))
        }))
        .filter(|m| seen.insert(m.selector.as_str()))
        .collect()
}

/// The class's `objc_exposed`, supported, **explicit** init methods (the
/// `make-instance` factory data baked via `register-objc-init`). `init` itself is
/// the bare alloc/init the runtime's default `make-instance` already covers.
fn exposed_inits(cls: &Class) -> Vec<&Method> {
    let m = mapper();
    cls.methods
        .iter()
        .filter(|meth| {
            meth.init_method
                && meth.objc_exposed
                && meth.selector != "init"
                && is_supported_method_ctx(meth, &m, &HashSet::new())
        })
        .collect()
}

/// Lower a regular (instance or class) method to a [`Dispatch`].
fn method_dispatch(meth: &Method, error_selectors: &HashSet<String>) -> Dispatch {
    let m = mapper();
    let error_out = is_error_out_method(meth, error_selectors);
    // An error-out method drops the trailing NSError** from the visible CLOS arity.
    let visible = if error_out {
        &meth.params[..meth.params.len() - 1]
    } else {
        &meth.params[..]
    };
    let args = visible
        .iter()
        .enumerate()
        .map(|(i, p)| lower_arg(&arg_name(&p.name, i), &p.param_type))
        .collect();
    Dispatch {
        selector: meth.selector.clone(),
        class_receiver: meth.class_method,
        args,
        ret_alien: m.map_type(&meth.return_type, true),
        ret_object: m.is_object_type(&meth.return_type),
        ret_retained: method_returns_retained(meth),
        error_out,
    }
}

/// Lower a property getter to a 0-arg [`Dispatch`] on selector `<name>`.
fn property_getter_dispatch(p: &Property) -> Dispatch {
    let m = mapper();
    Dispatch {
        selector: p.name.clone(),
        class_receiver: p.class_property,
        args: vec![],
        ret_alien: m.map_type(&p.property_type, true),
        ret_object: m.is_object_type(&p.property_type),
        // A `copy` property hands back a +1 object (acts like a copy family).
        ret_retained: p.is_copy,
        error_out: false,
    }
}

/// Lower a writable property setter to a 1-arg [`Dispatch`] on selector
/// `set<Name>:`, returning `void`.
fn property_setter_dispatch(p: &Property) -> Dispatch {
    Dispatch {
        selector: setter_selector_for(&p.name),
        class_receiver: p.class_property,
        args: vec![lower_arg("value", &p.property_type)],
        ret_alien: "sb-alien:void".to_string(),
        ret_object: false,
        ret_retained: false,
        error_out: false,
    }
}

/// Lower one argument to its formal name, alien type, and coercion role.
fn lower_arg(name: &str, ty: &TypeRef) -> DispatchArg {
    let m = mapper();
    let role = match &ty.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => ArgRole::Object,
        TypeRefKind::Selector => ArgRole::Selector,
        TypeRefKind::Block { .. } => ArgRole::Block,
        _ => ArgRole::Plain,
    };
    DispatchArg {
        name: name.to_string(),
        alien: m.map_type(ty, false),
        role,
    }
}

// --- internal: rendering ---------------------------------------------------

/// Emit one `defmethod` for a lowered dispatch.
fn emit_defmethod(
    w: &mut CodeWriter,
    class_name: &str,
    d: &Dispatch,
    _error_selectors: &HashSet<String>,
) {
    let generic = d.generic_name();
    let cls_clos = qualified_class_name(class_name);

    // Receiver specializer + receiver expression. Instance: typed on ns:<cls>,
    // receiver = (aw-ptr self). Class method: eql on the class metaobject,
    // receiver = the re-resolved Class SAP (aw-class "<ObjCName>").
    let (specializer, receiver_expr) = if d.class_receiver {
        (
            format!("(class (eql (find-class '{cls_clos})))"),
            format!("({CLASS_FN} \"{class_name}\")"),
        )
    } else {
        (format!("(self {cls_clos})"), format!("({PTR_FN} self)"))
    };

    // defmethod head + arglist.
    let mut head = format!("(defmethod {generic} ({specializer}");
    for a in &d.args {
        head.push(' ');
        head.push_str(&a.name);
    }
    head.push(')');
    write_line!(w, "{}", head);
    if d.class_receiver {
        // The receiver is pinned by the eql specializer; the body uses the literal
        // class. Mark it ignorable so an unused-formal style-warning never fires.
        w.line("  (declare (ignore class))");
    }

    let body = dispatch_call(d, &receiver_expr);
    if d.error_out {
        // The runtime macro allocates the NSError** cell, binds %err, runs the body,
        // and signals ns:cocoa-error when the primary return indicates failure
        // (ADR-0037; the cell is threaded as the trailing id* arg below).
        write_line!(w, "  ({ERROR_CELL_MACRO} (%err)");
        write_line!(w, "    {body}))");
    } else {
        write_line!(w, "  {body})");
    }
}

/// Render the `objc_msgSend` crossing (optionally object-wrapped). For an error-out
/// method the trailing `%err` cell is threaded as the final `id*` actual + alien
/// arg type.
fn dispatch_call(d: &Dispatch, receiver_expr: &str) -> String {
    // Alien function type: ret, then id + SEL, then each visible arg type, then the
    // error cell (id*) for an error-out method.
    let mut arg_aliens: Vec<String> = vec![SAP.to_string(), SAP.to_string()];
    arg_aliens.extend(d.args.iter().map(|a| a.alien.clone()));
    if d.error_out {
        arg_aliens.push(SAP.to_string());
    }
    let fn_type = format!(
        "(sb-alien:function {} {})",
        d.ret_alien,
        arg_aliens.join(" ")
    );

    // Actuals: receiver, selector, then coerced visible args, then the error cell.
    let mut actuals: Vec<String> = vec![
        receiver_expr.to_string(),
        format!("({SEL_FN} \"{}\")", d.selector),
    ];
    actuals.extend(d.args.iter().map(coerce_arg));
    if d.error_out {
        actuals.push("%err".to_string());
    }

    let call = format!(
        "(sb-alien:alien-funcall (sb-alien:sap-alien {MSGSEND_SAP} {fn_type}) {})",
        actuals.join(" ")
    );

    if d.ret_object {
        if d.ret_retained {
            format!("({WRAP_FN} {call} t)")
        } else {
            format!("({WRAP_FN} {call})")
        }
    } else {
        // void + scalar + (boolean 8) cross directly; sb-alien coerces.
        call
    }
}

/// Coerce one outbound argument per its role.
fn coerce_arg(a: &DispatchArg) -> String {
    match a.role {
        ArgRole::Object => format!("({PTR_FN} {})", a.name),
        ArgRole::Selector => format!("({SEL_FN} {})", a.name),
        ArgRole::Block => format!("({BLOCK_FN} {})", a.name),
        ArgRole::Plain => a.name.clone(),
    }
}

/// Emit a `register-objc-init` baking an explicit init's selector + keyword list +
/// a **typed applier closure** for the runtime's `make-instance`→alloc/init mapping
/// (§5, typed-arg support added 060/010 / ADR-0040). The keyword list maps initargs to
/// the selector (order-independent match); the applier is the only place that knows the
/// init's C signature, so it carries the literal `sb-alien` types `objc_msgSend` needs —
/// a multi-arg / by-value-struct / scalar / bool init that the runtime cannot build
/// from a runtime-data type list (an `alien-funcall` needs compile-time types).
fn emit_register_init(w: &mut CodeWriter, class_name: &str, meth: &Method) {
    let kws = selector_keyword_symbols(&meth.selector);
    // Lower the init like any method (no error-out init handled here — the rare
    // initWith…:error: shape is a documented follow-up); the Dispatch carries the
    // per-arg alien type + coercion role the applier renders against the initarg plist.
    let d = method_dispatch(meth, &HashSet::new());
    let applier = render_init_applier(&d, &kws);
    write_line!(
        w,
        "({REGISTER_INIT_FN} '{} \"{}\" ({}) {})",
        qualified_class_name(class_name),
        meth.selector,
        kws.join(" "),
        applier
    );
}

/// Render the typed init applier: `(lambda (%alloced %args) <typed objc_msgSend>)`.
/// `%alloced` is the freshly `alloc`'d `id`; `%args` is the make-instance initarg plist.
/// Each visible arg's value is pulled from the plist by its keyword and coerced per role
/// (object → `aw-ptr`, selector → `aw-sel`, plain scalar/bool/struct → as-is; sb-alien
/// coerces a Lisp generalized-boolean to `(boolean 8)` and an integer to a scalar). The
/// init returns the raw `+1` `id` (the metaclass `make-instance` wraps it), so the call
/// is NOT `aw-wrap`ped here.
fn render_init_applier(d: &Dispatch, keywords: &[String]) -> String {
    // Function type: raw id return, id receiver, SEL, then each arg's alien type.
    let mut arg_aliens: Vec<String> = vec![SAP.to_string(), SAP.to_string()];
    arg_aliens.extend(d.args.iter().map(|a| a.alien.clone()));
    let fn_type = format!("(sb-alien:function {SAP} {})", arg_aliens.join(" "));

    // Actuals: %alloced, the init selector, then each arg pulled from the plist + coerced.
    let mut actuals: Vec<String> = vec![
        "%alloced".to_string(),
        format!("({SEL_FN} \"{}\")", d.selector),
    ];
    for (a, kw) in d.args.iter().zip(keywords.iter()) {
        // kw is ":foo"; the plist read is (getf %args :foo), then coerced by role.
        let read = format!("(getf %args {kw})");
        let pulled = DispatchArg {
            name: read,
            alien: a.alien.clone(),
            role: a.role,
        };
        actuals.push(coerce_arg(&pulled));
    }
    let ignore = if d.args.is_empty() {
        " (declare (ignore %args))"
    } else {
        ""
    };
    format!(
        "(lambda (%alloced %args){ignore} (sb-alien:alien-funcall (sb-alien:sap-alien {MSGSEND_SAP} {fn_type}) {}))",
        actuals.join(" ")
    )
}

// --- helpers ---------------------------------------------------------------

/// The setter selector for a property name (`title` → `setTitle:`).
fn setter_selector_for(prop_name: &str) -> String {
    let first = prop_name.chars().next().unwrap_or('x');
    format!(
        "set{}{}:",
        first.to_uppercase(),
        &prop_name[first.len_utf8()..]
    )
}

/// A CLOS formal name for a param: kebab the label, falling back to `argN` for an
/// empty/wildcard label or one that collides with a CL defined constant (`t`/`nil` —
/// see [`crate::naming::is_cl_reserved_formal`]).
fn arg_name(label: &str, i: usize) -> String {
    let kebab = apianyware_macos_emit::naming::camel_to_kebab(label);
    if kebab.is_empty() || label == "_" || crate::naming::is_cl_reserved_formal(&kebab) {
        format!("arg{i}")
    } else {
        kebab
    }
}

/// Whether an object return is +1 retained — `returns_retained` if set, else the
/// ObjC method-family rule (`init`/`new`/`copy`/`mutableCopy`). Ported from the
/// gerbil/chez heuristic.
fn method_returns_retained(meth: &Method) -> bool {
    if let Some(r) = meth.returns_retained {
        return r;
    }
    let sel = &meth.selector;
    if !meth.class_method && is_family_match(sel, "init") {
        return true;
    }
    if meth.class_method && is_family_match(sel, "new") {
        return true;
    }
    is_family_match(sel, "copy") || is_family_match(sel, "mutableCopy")
}

fn is_family_match(selector: &str, family: &str) -> bool {
    if selector == family {
        return true;
    }
    if selector.len() > family.len() && selector.starts_with(family) {
        let next = selector.as_bytes()[family.len()];
        return next.is_ascii_uppercase() || next == b':' || next == b'(';
    }
    false
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Param, Property};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn prim(name: &str) -> TypeRef {
        ty(TypeRefKind::Primitive { name: name.into() })
    }

    fn method(selector: &str, class_method: bool, ret: TypeRef, params: Vec<Param>) -> Method {
        Method {
            selector: selector.into(),
            class_method,
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

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: ty(kind),
        }
    }

    fn prop(name: &str, kind: TypeRefKind, readonly: bool) -> Property {
        Property {
            name: name.into(),
            property_type: ty(kind),
            readonly,
            class_property: false,
            is_copy: false,
            deprecated: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            objc_exposed: true,
        }
    }

    fn class_with(name: &str, methods: Vec<Method>, properties: Vec<Property>) -> Class {
        Class {
            name: name.into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties,
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn fw(name: &str, classes: Vec<Class>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "enriched".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes,
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            api_patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn unary_scalar_method_renders_msgsend_body() {
        // length : NSUInteger — (id, SEL) -> unsigned 64, no wrap.
        let cls = class_with(
            "NSString",
            vec![method("length", false, prim("uint64"), vec![])],
            vec![],
        );
        let out = render_class_dispatch(&cls, "Foundation");
        assert!(out.contains("(defmethod ns:length ((self ns:ns-string))"));
        assert!(out.contains(
            "(sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ \
             (sb-alien:function (sb-alien:unsigned 64) \
             sb-alien:system-area-pointer sb-alien:system-area-pointer)) \
             (aw-ptr self) (aw-sel \"length\"))"
        ));
        // Scalar return → no aw-wrap.
        assert!(!out.contains("aw-wrap"));
    }

    #[test]
    fn object_arg_and_return_coerce_and_wrap() {
        // objectAtIndex: -> id, taking a uint64 index → object return wraps, index
        // passes through.
        let cls = class_with(
            "NSArray",
            vec![method(
                "objectAtIndex:",
                false,
                ty(TypeRefKind::Id),
                vec![param(
                    "index",
                    TypeRefKind::Primitive {
                        name: "uint64".into(),
                    },
                )],
            )],
            vec![],
        );
        let out = render_class_dispatch(&cls, "Foundation");
        assert!(out.contains("(defmethod ns:object-at-index_ ((self ns:ns-array) index)"));
        assert!(out.contains("(aw-wrap (sb-alien:alien-funcall"));
        assert!(out.contains("(aw-ptr self) (aw-sel \"objectAtIndex:\") index)"));
    }

    #[test]
    fn object_argument_is_ptr_coerced() {
        // addObject: (id) -> void → the id arg coerces via aw-ptr; void return, no wrap.
        let cls = class_with(
            "NSMutableArray",
            vec![method(
                "addObject:",
                false,
                TypeRef::void(),
                vec![param("anObject", TypeRefKind::Id)],
            )],
            vec![],
        );
        let out = render_class_dispatch(&cls, "Foundation");
        assert!(out.contains("(defmethod ns:add-object_ ((self ns:ns-mutable-array) an-object)"));
        assert!(out.contains("(aw-sel \"addObject:\") (aw-ptr an-object))"));
        // void return → the function type opens with sb-alien:void.
        assert!(out.contains("(sb-alien:function sb-alien:void"));
    }

    #[test]
    fn retained_family_return_is_marked() {
        // copy -> id is a +1 copy family → aw-wrap … t.
        let cls = class_with(
            "NSObject2",
            vec![method("copy", false, ty(TypeRefKind::Id), vec![])],
            vec![],
        );
        let out = render_class_dispatch(&cls, "Foundation");
        assert!(out.contains("(aw-wrap (sb-alien:alien-funcall"));
        assert!(out.trim_end().ends_with("(aw-sel \"copy\")) t))"));
    }

    #[test]
    fn class_method_uses_eql_specializer_and_aw_class_receiver() {
        // +[NSString stringWithString:] — eql on the class metaobject; receiver is
        // the re-resolved Class SAP.
        let cls = class_with(
            "NSString",
            vec![method(
                "stringWithString:",
                true,
                ty(TypeRefKind::Instancetype),
                vec![param("aString", TypeRefKind::Id)],
            )],
            vec![],
        );
        let out = render_class_dispatch(&cls, "Foundation");
        assert!(out.contains(
            "(defmethod ns:string-with-string_ ((class (eql (find-class 'ns:ns-string))) a-string)"
        ));
        assert!(out.contains("(declare (ignore class))"));
        assert!(out
            .contains("(aw-class \"NSString\") (aw-sel \"stringWithString:\") (aw-ptr a-string)"));
    }

    #[test]
    fn property_getter_and_setter_become_dispatches() {
        // A writable `title` (id) property → getter on `title`, setter on `setTitle:`.
        let cls = class_with(
            "NSWindow",
            vec![],
            vec![prop("title", TypeRefKind::Id, false)],
        );
        let out = render_class_dispatch(&cls, "AppKit");
        assert!(out.contains("(defmethod ns:title ((self ns:ns-window))"));
        assert!(out.contains("(aw-wrap (sb-alien:alien-funcall")); // object getter wraps
        assert!(out.contains("(defmethod ns:set-title_ ((self ns:ns-window) value)"));
        assert!(out.contains("(aw-sel \"setTitle:\") (aw-ptr value))"));
    }

    #[test]
    fn readonly_property_emits_only_getter() {
        let cls = class_with(
            "NSView",
            vec![],
            vec![prop(
                "frame",
                TypeRefKind::Struct {
                    name: "CGRect".into(),
                },
                true,
            )],
        );
        let out = render_class_dispatch(&cls, "AppKit");
        assert!(out.contains("(defmethod ns:frame ((self ns:ns-view))"));
        assert!(!out.contains("set-frame"));
        // Geometry struct return crosses by value as (sb-alien:struct ns-rect).
        assert!(out.contains("(sb-alien:function (sb-alien:struct ns-rect)"));
    }

    #[test]
    fn objc_exposed_false_method_is_residual_not_emitted() {
        let mut swift_native = method("nativeThing", false, ty(TypeRefKind::Id), vec![]);
        swift_native.objc_exposed = false;
        let cls = class_with("NSThing", vec![swift_native], vec![]);

        // No defmethod emitted for the Swift-native method.
        let out = render_class_dispatch(&cls, "Foundation");
        assert!(!out.contains("native-thing"));

        // …but it IS in the residual.
        let residual = collect_residual(&cls);
        assert_eq!(residual.len(), 1);
        assert_eq!(residual[0].selector, "nativeThing");
        assert!(!residual[0].is_init);
    }

    #[test]
    fn objc_exposed_false_init_is_residual() {
        let mut swift_init = method(
            "initNative:",
            false,
            ty(TypeRefKind::Instancetype),
            vec![param("x", TypeRefKind::Id)],
        );
        swift_init.objc_exposed = false;
        swift_init.init_method = true;
        let cls = class_with("NSThing", vec![swift_init], vec![]);
        let residual = collect_residual(&cls);
        assert_eq!(residual.len(), 1);
        assert!(residual[0].is_init);
    }

    #[test]
    fn exposed_explicit_init_is_baked_not_dispatched() {
        let mut init = method(
            "initWithFrame:",
            false,
            ty(TypeRefKind::Instancetype),
            vec![param(
                "frame",
                TypeRefKind::Struct {
                    name: "CGRect".into(),
                },
            )],
        );
        init.init_method = true;
        let cls = class_with("NSView", vec![init], vec![]);
        let out = render_class_dispatch(&cls, "AppKit");
        // No defmethod for an init (make-instance handles instantiation, §5)…
        assert!(!out.contains("(defmethod ns:init-with-frame"));
        // …but its selector + keyword list + a typed applier (ADR-0040) is baked for the
        // runtime's make-instance (§5): the CGRect arg crosses by value as a struct, read
        // from the initarg plist by its keyword.
        assert!(out.contains(
            "(register-objc-init 'ns:ns-view \"initWithFrame:\" (:init-with-frame) (lambda (%alloced %args)"
        ));
        assert!(out.contains("(sb-alien:struct ns-rect)"));
        assert!(out.contains("(getf %args :init-with-frame)"));
    }

    #[test]
    fn error_out_method_drops_cell_and_wraps_in_macro() {
        // writeToFile:error: — selector arity 2, visible arity 1; the error cell is
        // threaded as a trailing id* and the body runs inside aw-with-error-cell.
        let mut errs = HashSet::new();
        errs.insert("writeToFile:error:".to_string());
        let cls = class_with(
            "NSData",
            vec![method(
                "writeToFile:error:",
                false,
                prim("bool"),
                vec![
                    param("path", TypeRefKind::Id),
                    param("error", TypeRefKind::Pointer),
                ],
            )],
            vec![],
        );
        let mut w = CodeWriter::new();
        emit_class_dispatch(&mut w, &cls, "Foundation", &errs, &ProtocolRegistry::new());
        let out = w.finish();
        // Visible arity 1 (path); no `error` formal.
        assert!(out.contains("(defmethod ns:write-to-file_error_ ((self ns:ns-data) path)"));
        assert!(out.contains("(aw-with-error-cell (%err)"));
        // The trailing %err cell is the last actual + a trailing SAP arg type.
        assert!(out.contains("(aw-sel \"writeToFile:error:\") (aw-ptr path) %err)"));
        assert!(out.contains(
            "(sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer \
             sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)"
        ));
    }

    #[test]
    fn block_argument_is_block_coerced() {
        let cls = class_with(
            "NSArray",
            vec![method(
                "enumerateObjectsUsingBlock:",
                false,
                TypeRef::void(),
                vec![param(
                    "block",
                    TypeRefKind::Block {
                        params: vec![ty(TypeRefKind::Id)],
                        return_type: Box::new(TypeRef::void()),
                    },
                )],
            )],
            vec![],
        );
        let out = render_class_dispatch(&cls, "Foundation");
        assert!(out.contains("(aw-block block))"));
    }

    #[test]
    fn property_vs_method_collision_dedupes_property_wins() {
        // A `title` property and a `title` method on the same class: only one
        // ns:title defmethod (the property), no duplicate.
        let cls = class_with(
            "NSDoc",
            vec![method("title", false, ty(TypeRefKind::Id), vec![])],
            vec![prop("title", TypeRefKind::Id, true)],
        );
        let out = render_class_dispatch(&cls, "AppKit");
        assert_eq!(out.matches("(defmethod ns:title ").count(), 1);
    }

    #[test]
    fn collect_generics_unifies_shared_selector_across_classes() {
        // Two unrelated classes both expose `count` → one global defgeneric.
        let f1 = fw(
            "Foundation",
            vec![class_with(
                "NSArray",
                vec![method("count", false, prim("uint64"), vec![])],
                vec![],
            )],
        );
        let f2 = fw(
            "CoreData",
            vec![class_with(
                "NSFetchRequest",
                vec![method("count", false, prim("uint64"), vec![])],
                vec![],
            )],
        );
        let decls = collect_generics(&[&f1, &f2], &ProtocolRegistry::new());
        let count: Vec<_> = decls.iter().filter(|d| d.name == "ns:count").collect();
        assert_eq!(count.len(), 1, "shared selector unified: {decls:?}");
        assert_eq!(count[0].arity, 0);

        let rendered = render_generics(&decls);
        assert_eq!(
            rendered.matches("(defgeneric ns:count (receiver)").count(),
            1
        );
    }

    #[test]
    fn collect_generics_folds_in_residual_method_generics() {
        // A class with a Swift-native (objc_exposed == false) method `update(with:)`
        // must contribute ns:update-with to the global generic set (the 045 lockstep),
        // so the class file's residual defmethod has a matching defgeneric.
        let mut m = method(
            "update(with:)",
            false,
            TypeRef::void(),
            vec![param(
                "with",
                TypeRefKind::Primitive {
                    name: "int64".into(),
                },
            )],
        );
        m.objc_exposed = false;
        m.swift_fn = Some(apianyware_macos_types::ir::SwiftFnInfo::default());
        let f = fw("Foundation", vec![class_with("NSThing", vec![m], vec![])]);
        let decls = collect_generics(&[&f], &ProtocolRegistry::new());
        assert!(
            decls
                .iter()
                .any(|d| d.name == "ns:update-with" && d.arity == 1),
            "residual generic folded in: {decls:?}"
        );
    }

    #[test]
    fn collect_generics_folds_in_struct_residual_method_generics() {
        // ADR-0042: a value struct's Swift-native method `contains(_:)` extends the
        // shared `ns:contains` generic (it is a `defmethod` on the struct's CLOS class,
        // not a bare `defun`), so its `defgeneric` must be in the global set just like a
        // class owner's.
        let mut m = method(
            "contains(_:)",
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
            vec![param(
                "_",
                TypeRefKind::Primitive {
                    name: "int64".into(),
                },
            )],
        );
        m.objc_exposed = false;
        m.swift_fn = Some(apianyware_macos_types::ir::SwiftFnInfo::default());
        let mut f = fw("Foundation", vec![]);
        f.structs = vec![value_struct("IndexSet", vec![m])];
        let decls = collect_generics(&[&f], &ProtocolRegistry::new());
        assert!(
            decls
                .iter()
                .any(|d| d.name == "ns:contains" && d.arity == 1),
            "struct residual generic folded in: {decls:?}"
        );
    }

    fn value_struct(name: &str, methods: Vec<Method>) -> apianyware_macos_types::ir::Struct {
        apianyware_macos_types::ir::Struct {
            name: name.into(),
            fields: vec![],
            methods,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
        }
    }

    #[test]
    fn generics_arity_from_selector() {
        let f = fw(
            "Foundation",
            vec![class_with(
                "NSArray",
                vec![method(
                    "objectAtIndex:",
                    false,
                    ty(TypeRefKind::Id),
                    vec![param(
                        "index",
                        TypeRefKind::Primitive {
                            name: "uint64".into(),
                        },
                    )],
                )],
                vec![],
            )],
        );
        let decls = collect_generics(&[&f], &ProtocolRegistry::new());
        let d = decls
            .iter()
            .find(|d| d.name == "ns:object-at-index_")
            .unwrap();
        assert_eq!(d.arity, 1);
        let rendered = render_generics(&decls);
        assert!(rendered.contains("(defgeneric ns:object-at-index_ (receiver arg0)"));
    }

    #[test]
    fn no_arity_conflicts_on_clean_fixture() {
        let f = fw(
            "Foundation",
            vec![class_with(
                "NSArray",
                vec![method("count", false, prim("uint64"), vec![])],
                vec![],
            )],
        );
        assert!(generic_arity_conflicts(&[&f], &ProtocolRegistry::new()).is_empty());
    }

    // --- conformed-protocol flattening (leaf 040/030) ---

    /// Build an `all_methods` entry as the resolve phase produces it for a method
    /// declared on a conformed protocol (origin = the declaring protocol).
    fn flattened(selector: &str, origin: &str, params: Vec<Param>, ret: TypeRef) -> Method {
        let mut m = method(selector, false, ret, params);
        m.origin = Some(origin.into());
        m
    }

    #[test]
    fn conformed_protocol_method_flattens_onto_class() {
        // NSData conforms to NSCopying; copyWithZone: lives on the protocol (origin
        // NSCopying), in all_methods, not in NSData's own methods. With NSCopying in
        // the registry, it flattens onto ns:ns-data as a callable defmethod.
        let mut cls = class_with("NSData", vec![], vec![]);
        cls.protocols = vec!["NSCopying".into()];
        cls.all_methods = vec![
            flattened(
                "copyWithZone:",
                "NSCopying",
                vec![param("zone", TypeRefKind::Id)],
                ty(TypeRefKind::Id),
            ),
            // A superclass-inherited entry (class origin) must NOT flatten — the
            // CLOS graph carries it.
            flattened(
                "isEqual:",
                "NSObject",
                vec![param("other", TypeRefKind::Id)],
                prim("bool"),
            ),
        ];
        let mut reg = ProtocolRegistry::new();
        reg.insert("NSCopying", vec![]);

        let out = render_class_dispatch_with(&cls, "Foundation", &reg);
        assert!(out.contains("(defmethod ns:copy-with-zone_ ((self ns:ns-data) zone)"));
        // The class-origin inherited method is filtered out (no re-emit).
        assert!(!out.contains("is-equal"));
    }

    #[test]
    fn empty_registry_flattens_nothing() {
        // Same class, but an empty registry → the conformance closure is empty → no
        // protocol method flattens (the pre-flattening surface).
        let mut cls = class_with("NSData", vec![], vec![]);
        cls.protocols = vec!["NSCopying".into()];
        cls.all_methods = vec![flattened(
            "copyWithZone:",
            "NSCopying",
            vec![param("zone", TypeRefKind::Id)],
            ty(TypeRefKind::Id),
        )];
        let out = render_class_dispatch_with(&cls, "Foundation", &ProtocolRegistry::new());
        assert!(!out.contains("copy-with-zone"));
    }

    #[test]
    fn own_method_wins_over_protocol_duplicate() {
        // A class that re-declares a protocol selector in its own methods keeps its
        // own lowering; the flattened duplicate is deduped out (own wins).
        let mut cls = class_with(
            "NSData",
            vec![method(
                "copyWithZone:",
                false,
                ty(TypeRefKind::Id),
                vec![param("zone", TypeRefKind::Id)],
            )],
            vec![],
        );
        cls.protocols = vec!["NSCopying".into()];
        cls.all_methods = vec![flattened(
            "copyWithZone:",
            "NSCopying",
            vec![param("zone", TypeRefKind::Id)],
            ty(TypeRefKind::Id),
        )];
        let mut reg = ProtocolRegistry::new();
        reg.insert("NSCopying", vec![]);
        let out = render_class_dispatch_with(&cls, "Foundation", &reg);
        assert_eq!(out.matches("(defmethod ns:copy-with-zone_ ").count(), 1);
    }

    #[test]
    fn flattened_generic_enters_the_global_set() {
        // The lockstep guarantee: a flattened defmethod's generic must also be in
        // collect_generics' output (else the defmethod has no defgeneric).
        let mut cls = class_with("NSData", vec![], vec![]);
        cls.protocols = vec!["NSCopying".into()];
        cls.all_methods = vec![flattened(
            "copyWithZone:",
            "NSCopying",
            vec![param("zone", TypeRefKind::Id)],
            ty(TypeRefKind::Id),
        )];
        let f = fw("Foundation", vec![cls]);
        let mut reg = ProtocolRegistry::new();
        reg.insert("NSCopying", vec![]);
        let decls = collect_generics(&[&f], &reg);
        assert!(decls
            .iter()
            .any(|d| d.name == "ns:copy-with-zone_" && d.arity == 1));
    }

    #[test]
    fn unknown_protocol_does_not_flatten() {
        // NSData conforms to a protocol absent from the registry (unloaded
        // framework) → its all_methods stub must not flatten (wrong-arity risk).
        let mut cls = class_with("NSData", vec![], vec![]);
        cls.protocols = vec!["SomeUnloadedProtocol".into()];
        cls.all_methods = vec![flattened(
            "mysteryMethod:",
            "SomeUnloadedProtocol",
            vec![param("x", TypeRefKind::Id)],
            TypeRef::void(),
        )];
        let out = render_class_dispatch_with(&cls, "Foundation", &ProtocolRegistry::new());
        assert!(!out.contains("mystery-method"));
    }
}
