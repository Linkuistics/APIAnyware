//! Gerbil class module emission — the manifest class graph + procedural binding.
//!
//! Each ObjC class becomes one Gerbil `.ss` module:
//!   - the class's slice of the **manifest `defclass` graph** (ADR-0020): one
//!     `(defclass (<Class> <Super>) () transparent: #t)` deriving from the class's
//!     resolved Gerbil parent ([`crate::class_graph`]), plus a
//!     `(register-objc-class! …)` form registering the ObjC-name↔Gerbil-type pair
//!     (the wrap boundary) and the ObjC superclass name (the subclassing bridge).
//!     This is the structural foundation the dispatch surfaces (leaf 040) hang on;
//!   - a single `begin-ffi` block holding **one inline-cast `objc_msgSend`
//!     `define-c-lambda` per distinct method ABI signature** (arm64 forbids a
//!     variadic `objc_msgSend`, so each call shape needs its own typed C cast —
//!     the compiled-FFI analogue of chez's per-selector `foreign-procedure`,
//!     but deduplicated by signature: ADR-0017, spike `01-reachability.ss`),
//!     plus `objc_getClass` / `sel_registerName`;
//!   - module-level selector caches (`sel_registerName` once at load);
//!   - a **procedural surface** — one plain procedure per emitted method,
//!     constructors, and properties.
//!
//! ## Object model (leaf 040 — dual consumption surfaces, ADR-0020)
//!
//! Over the manifest `defclass` graph (030), each emitted method gets an
//! **inlinable per-class proc core** plus **both** of Gerbil's dispatch surfaces,
//! sharing one source-level identifier (spike `07-dual-surface.ss`, FINDINGS §7):
//!
//! - **Proc core** — `(define (nsstring-length self) (%msg-… (NSObject-ptr self)
//!   …))`, the single implementation both surfaces forward to and the designated
//!   fast path (a module-level `(declare (inline))` lets the forwarders compile
//!   away — ADR-0020). The receiver is the typed `defclass` instance, so `self`'s
//!   pointer is the direct root-slot read `(NSObject-ptr self)`; `id` arguments
//!   coerce through the runtime's `->ptr` (instance → its `ptr`, `#f` → null);
//!   object returns wrap through the class-aware `wrap` (exact bound type via the
//!   030 registry, retained-aware).
//! - **Surface 1 — built-in `{}` MOP:** `(defmethod {length NSString} (lambda
//!   (self) (nsstring-length self)))`, called `{length obj}`. Dispatches by
//!   method-table symbol; inherits down the `defclass` graph.
//! - **Surface 2 — `:std/generic`:** `(g:defmethod (length (o NSString))
//!   (nsstring-length o))`, called `(length obj)`. The `(rename-in :std/generic
//!   (defgeneric g:defgeneric) (defmethod g:defmethod))` import dodges the
//!   built-in `defmethod` clash (spike `03b`). **Same identifier** as surface 1.
//!   The generic *itself* (`g:defgeneric length`) is declared ONCE in the shared
//!   [`crate::emit_generics`] module and imported here — not per class module — so
//!   a selector shared by unrelated classes is a single generic they all extend.
//!
//! Surfaces are emitted only for **instance** methods and **instance** properties
//! (a receiver to dispatch on); class methods/properties stay proc-only. Because
//! the `defclass` graph carries inheritance structurally, the plan is built over
//! the class's **own** methods/properties (`cls.methods`/`cls.properties`) plus
//! the **conformed-protocol** methods flattened from `all_methods` (leaf 120;
//! see [`effective_methods`] and [`crate::protocol_registry`]) — *not* the full
//! inheritance-flattened set chez/racket need: a subclass inherits an ancestor's
//! surface method through the graph rather than re-emitting it, but a conformed
//! protocol's methods live on no ancestor class and must be emitted here.
//! Protocol properties need no separate path — the collector surfaces their
//! accessors as protocol *methods*, so they ride the same flattening.
//!
//! The IR-shaping machinery (`build_class_plan`, `collect_exports`,
//! `dedupe_across_categories`, the property/class-method collision pre-pass) is
//! ported from `emit-chez/src/emit_class.rs` — it is target-neutral; only the
//! naming calls and the emitted source forms are Gerbil-specific.
//!
//! ## Error model (ADR-0006, leaf 050)
//!
//! A method whose selector is in the class's enrichment-derived NSError
//! out-param set (`error_selectors`, from the shared
//! [`apianyware_macos_emit::enrichment::class_error_selectors`]) **and** whose
//! trailing param is a raw pointer (the `NSError**` cell) returns `(values
//! result error)` instead of threading the pointer. The trailing `NSError**` is
//! dropped from the proc's visible arity; the per-signature crossing gains an
//! `-e` variant taking the visible args + a trailing `(pointer (pointer void))`
//! cell, casting that actual to `NSError**` so the method writes the `NSError*`
//! through it (the in-Gerbil out-param crossing — ADR-0017, *not* racket's
//! native `…_e` entry). The proc wraps the crossing in the runtime's
//! `call-with-nserror-out`, which allocates the cell and returns `(values
//! <wrapped-result> <nserror-or-#f>)`; both consumption surfaces forward to it,
//! so they return the two values too. Gerbil is the first target to actually
//! emit this (emit-chez reserved the `nserror` names but never wired emission).
//!
//! ## Runtime contract (names owned by leaf 050)
//!
//! Emitted against the runtime module `:gerbil-bindings/runtime/objc`:
//! - **`(defclass NSObject (ptr) transparent: #t)`** — the single runtime-owned
//!   class-graph root (holds the `ptr` slot + the ADR-0019 lifetime will); every
//!   emitted `defclass` chains up to it. ⇒ `NSObject` / `NSObject?` /
//!   `NSObject-ptr` / `make-NSObject`.
//! - **`(register-objc-class! (lambda (p) (make-<Class> ptr: p)) <Class>::t
//!   "<objc-name>" "<objc-super>")`** — records, against the ObjC class name: a
//!   POSITIONAL constructor closure (the runtime `wrap` calls `(ctor ptr)`; a
//!   bare class id is Gerbil *syntax*, not a runtime value, and `make-<Class>`
//!   is a keyword ctor — hence the adapter closure, settled at leaf 050/010),
//!   the Gerbil class descriptor `<Class>::t` (for the 030 subclassing bridge),
//!   and the ObjC superclass name (the wrap-boundary fallback walk +
//!   `objc_allocateClassPair`). The mapping backs the class-aware wrap
//!   (`object_getClass` → exact bound type, nearest bound ancestor as fallback).
//! - **`(wrap <id-ptr> [retained?])`** — class-aware wrap: a raw `id` pointer →
//!   the exact bound Gerbil instance (via `object_getClass` + the registry,
//!   nearest bound ancestor as fallback), registering the ADR-0019 will;
//!   `(wrap p)` autoreleased, `(wrap p #t)` retained.
//! - **`(->ptr x)`** — coerce a bound instance *or* `#f`/nil to a raw pointer for
//!   an outbound `id` argument (instance → its `ptr`, `#f` → null).
//! - **`(call-with-nserror-out thunk)`** + the **`nserror`** record
//!   (`make-nserror` / `nserror?` / `nserror-domain` / `nserror-code` /
//!   `nserror-localised-description` / `nserror-userinfo`, mirroring chez) — the
//!   error-model settler the `(values result error)` procs bottom out in
//!   (contract inbox-noted to 050).
//! - **The `:std/generic` rename import** + cross-module generic unification:
//!   declaring `(g:defgeneric <sel>)` per class module made two *unrelated* classes
//!   sharing a selector name (e.g. `count`, `title`) export colliding generics at
//!   the framework facade. **Fixed (leaf 060/020):** the global selector set is
//!   declared ONCE in the shared [`crate::emit_generics`] module (the analogue of
//!   the cross-framework `ClassRegistry`), written by the CLI pre-pass; each class
//!   imports it and extends the single shared generic.

use std::collections::{BTreeSet, HashSet};

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::naming::{camel_to_kebab, class_name_to_lowercase};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Class, Method, Param, Property, Struct};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_graph::{ParentRef, RUNTIME_ROOT};
use crate::ffi_type_mapping::{
    emit_geometry_decls, geometry_decl, is_known_geometry_alias, GeometryDecl, GerbilFfiTypeMapper,
    POINTER,
};
use crate::method_filter::{
    is_error_out_method, is_supported_method, is_supported_method_ctx, returns_object_type,
    returns_void,
};
use crate::naming::{
    make_class_method_name, make_class_property_getter_name, make_class_property_setter_name,
    make_method_name, make_property_getter_name, make_property_setter_name,
    make_selector_binding_name, make_swift_init_name, make_swift_method_name,
    make_unique_constructor_name,
};
use crate::protocol_registry::ProtocolRegistry;
use crate::trampoline::{classify_method, introduced_macos, Crossing, MethodDisposition};

/// The runtime module the generated class binds against (root class + `wrap` /
/// `->ptr` + lifetime).
const RUNTIME_OBJC_IMPORT: &str = ":gerbil-bindings/runtime/objc";

/// The runtime module supplying the Swift-native trampoline `aw-swift-*` coercers
/// (string in/out, the `throws` error-cell helper) — imported only when a class's
/// Swift-native method/init section needs them (ADR-0029 / ADR-0030).
const RUNTIME_TRAMPOLINE_IMPORT: &str = ":gerbil-bindings/runtime/swift-trampoline";

/// The runtime module supplying `aw-async-call` — imported only when a class has at
/// least one Swift-native `async` method (D5/R4; the first gerbil async path).
const RUNTIME_ASYNC_BRIDGE_IMPORT: &str = ":gerbil-bindings/runtime/async-bridge";

/// The `:std/generic` import, renamed so its `defgeneric`/`defmethod` don't clash
/// with the built-in `{}` MOP `defmethod` (spike `03b`). The generic surface is
/// emitted with `g:defgeneric` / `g:defmethod`.
pub(crate) const GENERIC_IMPORT: &str =
    "(rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))";

/// The shared global generics module ([`crate::emit_generics`]): every distinct
/// instance-surface selector across all frameworks is declared ONCE there as a
/// `:std/generic` generic, so a selector shared by unrelated classes (`count`,
/// `title`, …) is a single generic they all extend — not N per-module generics
/// that clash at the framework facade (the cross-module unification fix). A class
/// imports it to bring those generic identifiers into scope for its `g:defmethod`s.
pub(crate) const GENERICS_MODULE_IMPORT: &str = ":gerbil-bindings/generics";

/// The root-class `ptr` slot accessor — the direct, fast read of a typed
/// `defclass` instance's pointer (`(NSObject-ptr self)`), used as the receiver in
/// every instance proc core.
fn root_ptr_accessor(receiver: &str) -> String {
    format!("({}-ptr {})", RUNTIME_ROOT, receiver)
}

/// Generate the full `.ss` module text for one class, rooting its `defclass` on
/// the runtime [`RUNTIME_ROOT`]. Convenience over
/// [`generate_class_file_with_parent`] for the common root case (and tests).
pub fn generate_class_file(cls: &Class, framework: &str) -> String {
    generate_class_file_with_parent(
        cls,
        framework,
        &ParentRef::RuntimeRoot,
        &HashSet::new(),
        &ProtocolRegistry::new(),
    )
    .0
}

/// Compute the exported names for one class, in sorted order, without rendering
/// the body. Used by `emit_framework` to build the facade re-export list.
///
/// Computed with an empty error-selector set and an empty protocol registry —
/// the real pipeline reads exports from [`generate_class_file_with_parent`]'s
/// return value (which threads the class's enrichment error selectors and the
/// cross-framework [`ProtocolRegistry`]), so this convenience never gates the
/// facade; error and protocol-contributed methods would be excluded here
/// exactly as they are with no enrichment/registry.
pub fn class_exports(cls: &Class) -> Vec<String> {
    let mapper = GerbilFfiTypeMapper;
    let plan = build_class_plan(cls, &mapper, &HashSet::new(), &BTreeSet::new());
    merged_exports(cls, &plan)
}

/// The Gerbil class identifier + subtype predicate this class contributes to the
/// module's exports — the manifest-graph names sibling/subclass modules and user
/// subclassing (`(defclass (MyView NSView) …)`) need in scope. Empty for the
/// runtime-owned [`RUNTIME_ROOT`] (the runtime exports those).
fn class_graph_exports(cls: &Class) -> Vec<String> {
    if cls.name == RUNTIME_ROOT {
        return Vec::new();
    }
    vec![cls.name.clone(), format!("{}?", cls.name)]
}

/// Merge the proc-surface exports with the class-graph identifiers and the dual
/// consumption-surface selectors (ADR-0020), sorted + deduped. The bare surface
/// selectors are the `{}`/generic method names a caller writes (`{length obj}` /
/// `(length obj)`).
fn merged_exports(cls: &Class, plan: &ClassPlan) -> Vec<String> {
    let mut exports = plan.exports.clone();
    exports.extend(class_graph_exports(cls));
    exports.extend(instance_surface_selectors(cls, plan));
    exports.sort();
    exports.dedup();
    exports
}

/// The distinct bare-kebab surface selectors one class contributes to the global
/// generics set — the same computation [`instance_surface_selectors`] does, but
/// from a [`Class`] + its error selectors (building the plan internally). Used by
/// [`crate::emit_generics`] to union the global selector set across frameworks so
/// the per-class surface and the global declarations stay in lock-step.
pub(crate) fn class_surface_selectors(
    cls: &Class,
    error_selectors: &HashSet<String>,
    protocols: &ProtocolRegistry,
) -> Vec<String> {
    let mapper = GerbilFfiTypeMapper;
    let conformed = protocols.conformance_closure(&cls.protocols);
    let plan = build_class_plan(cls, &mapper, error_selectors, &conformed);
    instance_surface_selectors(cls, &plan)
}

/// The distinct bare-kebab surface selectors this class emits a `{}`/generic
/// method for: its instance methods + instance-property getters/setters. Sorted,
/// deduped — the generic-declaration block and the export list both consume it.
fn instance_surface_selectors(cls: &Class, plan: &ClassPlan) -> Vec<String> {
    let mapper = GerbilFfiTypeMapper;
    let mut sels: BTreeSet<String> = BTreeSet::new();
    for m in &plan.instance_methods {
        if is_supported_method_ctx(m, &mapper, &plan.error_selectors) {
            let proc = make_method_name(&cls.name, &m.selector);
            sels.insert(surface_selector(&cls.name, &proc));
        }
    }
    for p in &plan.properties {
        if p.class_property {
            continue;
        }
        let getter = make_property_getter_name(&cls.name, &p.name);
        sels.insert(surface_selector(&cls.name, &getter));
        if !p.readonly {
            let setter = make_property_setter_name(&cls.name, &p.name);
            sels.insert(surface_selector(&cls.name, &setter));
        }
    }
    sels.into_iter().collect()
}

/// Compute exports + render the class module in a single pass, deriving the
/// class's `defclass` from `parent` (resolved by [`crate::class_graph`]).
pub fn generate_class_file_with_parent(
    cls: &Class,
    framework: &str,
    parent: &ParentRef,
    error_selectors: &HashSet<String>,
    protocols: &ProtocolRegistry,
) -> (String, Vec<String>) {
    let mapper = GerbilFfiTypeMapper;
    let conformed = protocols.conformance_closure(&cls.protocols);
    let plan = build_class_plan(cls, &mapper, error_selectors, &conformed);

    // Swift-native methods/inits (`objc_exposed == false`) → receiver-handle
    // trampolines (ADR-0030, charter #4). A class is a reference receiver
    // (`owner_is_class = true`, `Unmanaged` path); a `Class` carries no provenance,
    // so the owner-availability fold (B3) is empty for class owners. MUST use
    // `cls.methods` (the *declared* methods), not `effective_methods`: the global
    // trampoline pass emits `@_cdecl` entries for declared methods only, so binding
    // an inherited/category method here would reference an entry the Swift side never
    // produced (the §6d agreement). Method params never unbox a value struct this
    // leaf (classify_method uses an empty set), so the value-struct gate is empty.
    let mut swift_native = collect_swift_native_bindings(
        &cls.name,
        framework,
        &cls.methods,
        true,
        &HashSet::new(),
        None,
    );

    // The ObjC bindings win any name collision (a duplicate `(define …)`/`(export …)`
    // is at best last-wins shadowing). Drop Swift duplicates against the ObjC export
    // set, then add the survivors so the facade re-exports them.
    let mut exports = merged_exports(cls, &plan);
    let objc_names: HashSet<String> = exports.iter().cloned().collect();
    swift_native.exclude(&objc_names);
    for name in swift_native.names() {
        exports.push(name.clone());
    }
    exports.sort();
    exports.dedup();

    let mut w = CodeWriter::new();

    let needs_default_constructor =
        !has_explicit_constructor(&plan.init_methods.iter().collect::<Vec<&Method>>(), &mapper);
    // The class extends the shared global generics only when it has an instance
    // surface — drives whether the generics module is imported in the header.
    let imports_generics = !instance_surface_selectors(cls, &plan).is_empty();

    emit_header(
        &mut w,
        cls,
        framework,
        &exports,
        parent,
        imports_generics,
        swift_native.needs_swift_helpers(),
        swift_native.needs_async_bridge(),
    );
    emit_class_graph_block(&mut w, &cls.name, &cls.superclass, parent);
    emit_ffi_block(&mut w, cls, &plan, needs_default_constructor, &mapper);
    emit_selector_caches(&mut w, cls, &plan);
    emit_surface_decls(&mut w, cls, &plan);

    if !plan.init_methods.is_empty() || needs_default_constructor {
        w.line(";; --- Constructors ---");
        if needs_default_constructor {
            emit_default_constructor(&mut w, &cls.name);
        }
        for m in &plan.init_methods {
            emit_constructor(&mut w, &cls.name, m, &mapper);
        }
    }

    if !plan.properties.is_empty() {
        w.line(";; --- Properties ---");
        for p in &plan.properties {
            emit_property(&mut w, &cls.name, p, &mapper);
        }
    }

    if !plan.instance_methods.is_empty() {
        w.line(";; --- Instance methods ---");
        for m in &plan.instance_methods {
            emit_method(&mut w, &cls.name, m, false, &mapper, &plan.error_selectors);
        }
    }

    if !plan.class_methods.is_empty() {
        w.line(";; --- Class methods ---");
        for m in &plan.class_methods {
            emit_method(&mut w, &cls.name, m, true, &mapper, &plan.error_selectors);
        }
    }

    // Charter #4: the Swift-native receiver-handle trampoline section (ADR-0030),
    // after the ObjC bindings.
    emit_swift_native_section(&mut w, &swift_native);

    (w.finish(), exports)
}

/// Render a **bare** synthesized intermediate node ([`crate::class_graph`]): a
/// `defclass`-only module with no proc surface. Emitted for a same-framework
/// ancestor referenced as a superclass but not collected as a class, so the
/// graph has no dangling parent. Its own parent is unknowable from an unordered
/// ancestor set, so it roots on the runtime [`RUNTIME_ROOT`].
pub fn generate_bare_module(class_name: &str, framework: &str) -> (String, Vec<String>) {
    let exports = vec![class_name.to_string(), format!("{}?", class_name)];
    let mut w = CodeWriter::new();
    write_line!(
        w,
        ";;; Generated binding for {} ({}) — synthesized bare class-graph node",
        class_name,
        framework
    );
    write_line!(w, "(import {})", RUNTIME_OBJC_IMPORT);
    w.line("(export");
    for name in &exports {
        write_line!(w, "  {}", name);
    }
    w.line("  )");
    w.blank_line();
    // No collected superclass for a synthesized node ⇒ empty ObjC super name.
    emit_class_graph_block(&mut w, class_name, "", &ParentRef::RuntimeRoot);
    (w.finish(), exports)
}

/// Render a **population-B value struct** module (ADR-0030 D2): a Swift-native value
/// struct (`objc_exposed == false`, e.g. `IndexSet`) that has at least one bindable
/// init producer or method. Unlike a class module there is no `defclass` graph and no
/// `objc_msgSend` substrate — the value is held as the opaque `awGerbilBox` handle the
/// init producer hands back (a raw pointer; no ObjC class to `wrap` to), and methods
/// take that handle as `self` (coerced through `(->ptr self)`, which passes a raw
/// pointer through). Returns `None` when the struct has no bindable trampoline (no file
/// is written then). `owner_introduced` folds the struct's `@available` into its method
/// gates (B3).
pub fn generate_struct_file(st: &Struct, framework: &str) -> Option<(String, Vec<String>)> {
    let owner_introduced = introduced_macos(&st.provenance);
    let swift_native = collect_swift_native_bindings(
        &st.name,
        framework,
        &st.methods,
        false,
        &HashSet::new(),
        owner_introduced.as_deref(),
    );
    if swift_native.is_empty() {
        return None;
    }
    let exports: Vec<String> = {
        let mut v: Vec<String> = swift_native.names().cloned().collect();
        v.sort();
        v.dedup();
        v
    };

    let mut w = CodeWriter::new();
    write_line!(
        w,
        ";;; Generated binding for {} value struct ({}) — do not edit",
        st.name,
        framework
    );
    // Imports: the FFI surface always; the objc runtime (`wrap`/`->ptr`), the
    // `aw-swift-*` coercers, and `aw-async-call` only when a binding needs them.
    let mut tail: Vec<&str> = Vec::new();
    if swift_native.needs_objc() {
        tail.push(RUNTIME_OBJC_IMPORT);
    }
    if swift_native.needs_swift_helpers() {
        tail.push(RUNTIME_TRAMPOLINE_IMPORT);
    }
    if swift_native.needs_async_bridge() {
        tail.push(RUNTIME_ASYNC_BRIDGE_IMPORT);
    }
    if tail.is_empty() {
        w.line("(import :std/foreign)");
    } else {
        w.line("(import :std/foreign");
        for (i, imp) in tail.iter().enumerate() {
            if i + 1 == tail.len() {
                write_line!(w, "        {})", imp);
            } else {
                write_line!(w, "        {}", imp);
            }
        }
    }
    w.line("(export");
    for name in &exports {
        write_line!(w, "  {}", name);
    }
    w.line("  )");
    w.blank_line();

    emit_swift_native_section(&mut w, &swift_native);

    Some((w.finish(), exports))
}

// --- class plan (ported from emit-chez, target-neutral) -------------------

/// Cleaned-up emission plan for one class.
struct ClassPlan {
    properties: Vec<Property>,
    init_methods: Vec<Method>,
    instance_methods: Vec<Method>,
    class_methods: Vec<Method>,
    exports: Vec<String>,
    /// This class's enrichment-derived NSError out-param selectors (ADR-0006).
    /// Threaded from `fw.enrichment` so every supportedness / signature /
    /// emission decision keys error routing off the one set and never drifts.
    error_selectors: HashSet<String>,
}

// --- Swift-native receiver-handle trampoline bindings (ADR-0030, charter #4) ----

/// The rendered receiver-handle trampoline bindings for one type's declared
/// Swift-native methods/inits (`objc_exposed == false`), plus the import flags they
/// imply. Each carries its FFI [`Crossing`] (the `%swift-…` `define-c-lambda` + the
/// synthesized `extern` prototype, emitted into a dedicated `begin-ffi` block) and
/// its outer `(define …)`. The gerbil analogue of emit-chez's `SwiftNativeBindings`,
/// split crossing-vs-binding for gerbil's compiled-FFI idiom (ADR-0029 §2).
struct SwiftNativeBindings {
    entries: Vec<SwiftNativeBinding>,
}

struct SwiftNativeBinding {
    name: String,
    crossing: Crossing,
    define: String,
    is_async: bool,
    needs_objc: bool,
    needs_swift_helpers: bool,
}

impl SwiftNativeBindings {
    fn names(&self) -> impl Iterator<Item = &String> {
        self.entries.iter().map(|e| &e.name)
    }
    fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }
    /// Any binding wrapping an object / coercing the receiver ⇒ the file needs the
    /// `objc` runtime (`wrap` / `->ptr`). Always true once any method is present (the
    /// receiver coerces via `(->ptr self)`); a value-init-only set may be false.
    fn needs_objc(&self) -> bool {
        self.entries.iter().any(|e| e.needs_objc)
    }
    /// Any string-in/out or `throws` binding ⇒ import `swift-trampoline` (`aw-swift-*`).
    fn needs_swift_helpers(&self) -> bool {
        self.entries.iter().any(|e| e.needs_swift_helpers)
    }
    /// Any `async` method present ⇒ import `async-bridge` (`aw-async-call`).
    fn needs_async_bridge(&self) -> bool {
        self.entries.iter().any(|e| e.is_async)
    }
    /// Drop bindings whose Scheme name collides with an already-bound ObjC name (the
    /// ObjC binding wins — a duplicate `(define …)` / `(export …)` is at best last-wins
    /// shadowing). The dropped Swift duplicate is a generation detail; the Swift-side
    /// trampoline residual is unchanged.
    fn exclude(&mut self, objc_names: &HashSet<String>) {
        self.entries.retain(|e| !objc_names.contains(&e.name));
    }
}

/// Lambda formal names for a Swift-native method/init: the argument labels, kebabed.
/// A wildcard label (`_`, e.g. `contains(_:)`) becomes a positional `argN` so two
/// wildcard params don't collide as duplicate `lambda` formals.
fn swift_param_names(params: &[Param]) -> Vec<String> {
    params
        .iter()
        .enumerate()
        .map(|(i, p)| {
            if p.name == "_" {
                format!("arg{i}")
            } else {
                camel_to_kebab(&p.name)
            }
        })
        .collect()
}

/// Collect + render the receiver-handle trampoline bindings for a type's declared
/// Swift-native methods/inits (D4 routing). `owner_is_class` picks the reference
/// (`Unmanaged`) vs value (`AwGerbilValueBox`) receiver path; it MUST match the
/// global trampoline pass (`collect_trampolines`) so every emitted binding references
/// an entry the `@_cdecl` pass actually produces. `methods` MUST be the type's
/// *declared* methods (`cls.methods` / `st.methods`), not effective/inherited — the
/// global pass walks declared methods only (the §6d agreement). Overloads that
/// collapse to the same Scheme name keep the first (a generation detail).
fn collect_swift_native_bindings(
    owner: &str,
    framework: &str,
    methods: &[Method],
    owner_is_class: bool,
    value_structs: &HashSet<&str>,
    owner_introduced: Option<&str>,
) -> SwiftNativeBindings {
    let mut entries: Vec<SwiftNativeBinding> = Vec::new();
    let mut seen = HashSet::new();
    for m in methods {
        if m.swift_fn.is_none() {
            continue; // ObjC method — binds via msgSend, no trampoline
        }
        match classify_method(
            framework,
            owner,
            owner_is_class,
            m,
            methods,
            value_structs,
            owner_introduced,
        ) {
            MethodDisposition::Method(t) => {
                let mutating = m.swift_fn.as_ref().and_then(|i| i.self_kind.as_deref())
                    == Some("Mutating");
                let name = make_swift_method_name(owner, &m.selector, mutating);
                if !seen.insert(name.clone()) {
                    continue;
                }
                let param_names = swift_param_names(&m.params);
                entries.push(SwiftNativeBinding {
                    crossing: t.crossing(&name),
                    define: t.render_binding(&name, &param_names),
                    is_async: t.is_async(),
                    needs_objc: t.needs_objc(),
                    needs_swift_helpers: t.needs_swift_helpers(),
                    name,
                });
            }
            MethodDisposition::Init(t) => {
                let name = make_swift_init_name(owner, &m.selector);
                if !seen.insert(name.clone()) {
                    continue;
                }
                let param_names = swift_param_names(&m.params);
                entries.push(SwiftNativeBinding {
                    crossing: t.crossing(&name),
                    define: t.render_binding(&name, &param_names),
                    is_async: false,
                    needs_objc: t.needs_objc(),
                    needs_swift_helpers: t.needs_swift_helpers(),
                    name,
                });
            }
            MethodDisposition::Deferred(_) => {} // counted by the global trampoline pass
        }
    }
    SwiftNativeBindings { entries }
}

/// Emit the Swift-native trampoline section into a class/struct module body: a
/// dedicated `begin-ffi` block holding the `%swift-…` crossings (synthesized `extern`
/// prototypes + `define-c-lambda`s against the linked libAPIAnywareGerbil entries,
/// ADR-0021/0029), then the outer `(define …)` bindings. No lazy-load forcing
/// reference (ADR-0029 §4 — the dylib is linked at `gxc -exe` time). Idempotent on
/// an empty set.
fn emit_swift_native_section(w: &mut CodeWriter, bindings: &SwiftNativeBindings) {
    if bindings.is_empty() {
        return;
    }
    w.line(";; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---");
    w.line(";; Trampolined through libAPIAnywareGerbil (aw_gerbil_swift_* entries),");
    w.line(";; not the framework dylib (ADR-0029); receiver coerced via (->ptr self).");
    w.line("(begin-ffi (");
    for e in &bindings.entries {
        write_line!(w, "            %swift-{}", e.name);
    }
    w.line("            )");
    if bindings.entries.iter().any(|e| e.crossing.needs_stdbool) {
        w.line("  (c-declare \"#include <stdbool.h>\")");
    }
    for e in &bindings.entries {
        write_line!(w, "  (c-declare \"{}\")", e.crossing.proto);
    }
    w.blank_line();
    for e in &bindings.entries {
        write_line!(w, "  {}", e.crossing.define_c_lambda);
    }
    w.line("  )");
    w.blank_line();
    for e in &bindings.entries {
        for line in e.define.lines() {
            write_line!(w, "{}", line);
        }
    }
    w.blank_line();
}

fn build_class_plan(
    cls: &Class,
    mapper: &dyn FfiTypeMapper,
    error_selectors: &HashSet<String>,
    conformed: &BTreeSet<String>,
) -> ClassPlan {
    let methods_owned: Vec<Method> = effective_methods(cls, conformed)
        .into_iter()
        .cloned()
        .collect();
    let mut properties_owned: Vec<Property> = effective_properties(cls)
        .into_iter()
        // Block-typed and unsupported-struct property bodies are deferred (their
        // names would otherwise land in the export list with no matching define).
        .filter(|p| {
            !is_unsupported_struct_property(&p.property_type, mapper)
                && !matches!(p.property_type.kind, TypeRefKind::Block { .. })
        })
        .cloned()
        .collect();

    // Suppress instance-property collisions with same-named class methods
    // (e.g. NSMenuItem's class method `separatorItem` wins over a property).
    let class_method_names: HashSet<String> = methods_owned
        .iter()
        .filter(|m| m.class_method && !m.init_method)
        .map(|m| make_method_name(&cls.name, &m.selector))
        .collect();
    properties_owned.retain(|p| {
        p.class_property
            || !class_method_names.contains(&make_property_getter_name(&cls.name, &p.name))
    });

    // Names taken by properties (both getter + setter sides), to suppress
    // methods that kebab to the same name (e.g. NSTask `setArguments:`).
    let instance_property_getter_names: HashSet<String> = properties_owned
        .iter()
        .filter(|p| !p.class_property)
        .map(|p| make_property_getter_name(&cls.name, &p.name))
        .collect();
    let instance_property_setter_names: HashSet<String> = properties_owned
        .iter()
        .filter(|p| !p.class_property && !p.readonly)
        .map(|p| make_property_setter_name(&cls.name, &p.name))
        .collect();
    let class_property_getter_names: HashSet<String> = properties_owned
        .iter()
        .filter(|p| p.class_property)
        .map(|p| make_class_property_getter_name(&cls.name, &p.name, false))
        .collect();
    let class_property_setter_names: HashSet<String> = properties_owned
        .iter()
        .filter(|p| p.class_property && !p.readonly)
        .map(|p| make_class_property_setter_name(&cls.name, &p.name, false))
        .collect();

    // Charter #4 (D4): only ObjC-exposed methods route through `objc_msgSend`.
    // Swift-native methods (`objc_exposed == false`) have no msgSend entry — binding
    // them there is a latent crash — so they are excluded here and routed to the
    // receiver-handle trampoline section (`collect_swift_native_bindings` in
    // `generate_class_file_with_parent`), or suppressed when deferred (the global
    // trampoline pass records + counts the deferral).
    let init_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| m.init_method && m.objc_exposed)
        .cloned()
        .collect();

    let class_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| {
            if !m.class_method || m.init_method || !m.objc_exposed {
                return false;
            }
            let n = make_method_name(&cls.name, &m.selector);
            !class_property_getter_names.contains(&n) && !class_property_setter_names.contains(&n)
        })
        .cloned()
        .collect();

    let instance_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| {
            if m.class_method || m.init_method || !m.objc_exposed {
                return false;
            }
            let n = make_method_name(&cls.name, &m.selector);
            !instance_property_getter_names.contains(&n)
                && !instance_property_setter_names.contains(&n)
        })
        .cloned()
        .collect();

    let init_refs: Vec<&Method> = init_methods.iter().collect();
    let instance_refs: Vec<&Method> = instance_methods.iter().collect();
    let class_refs: Vec<&Method> = class_methods.iter().collect();
    let property_refs: Vec<&Property> = properties_owned.iter().collect();

    let raw_exports = collect_exports(
        &cls.name,
        &property_refs,
        &init_refs,
        &instance_refs,
        &class_refs,
        mapper,
        error_selectors,
    );

    let (filtered_props, filtered_inst, filtered_class, exports) = dedupe_across_categories(
        cls,
        properties_owned,
        instance_methods,
        class_methods,
        raw_exports,
    );

    ClassPlan {
        properties: filtered_props,
        init_methods,
        instance_methods: filtered_inst,
        class_methods: filtered_class,
        exports,
        error_selectors: error_selectors.clone(),
    }
}

/// Final dedup pass (safety net for `setX:` selectors that kebab to a
/// property-setter name without matching the convention). Precedence:
/// property > instance method > class method; constructors pass through.
fn dedupe_across_categories(
    cls: &Class,
    properties: Vec<Property>,
    instance_methods: Vec<Method>,
    class_methods: Vec<Method>,
    raw_exports: Vec<String>,
) -> (Vec<Property>, Vec<Method>, Vec<Method>, Vec<String>) {
    let mut seen: HashSet<String> = HashSet::new();

    let mut kept_props = Vec::new();
    for p in properties {
        let getter = if p.class_property {
            make_class_property_getter_name(&cls.name, &p.name, false)
        } else {
            make_property_getter_name(&cls.name, &p.name)
        };
        if seen.contains(&getter) {
            continue;
        }
        seen.insert(getter);
        if !p.readonly {
            let setter = if p.class_property {
                make_class_property_setter_name(&cls.name, &p.name, false)
            } else {
                make_property_setter_name(&cls.name, &p.name)
            };
            seen.insert(setter);
        }
        kept_props.push(p);
    }

    let mut kept_inst = Vec::new();
    for m in instance_methods {
        let n = make_method_name(&cls.name, &m.selector);
        if seen.insert(n) {
            kept_inst.push(m);
        }
    }

    let mut kept_class = Vec::new();
    for m in class_methods {
        let n = make_method_name(&cls.name, &m.selector);
        if seen.insert(n) {
            kept_class.push(m);
        }
    }

    let exports: Vec<String> = raw_exports
        .into_iter()
        .filter(|n| n.starts_with("make-") || seen.contains(n))
        .collect();

    (kept_props, kept_inst, kept_class, exports)
}

/// The methods this class emits a surface for: its **own** declared methods
/// plus the **conformed-protocol** methods the resolve phase flattened into
/// `all_methods` (leaf 120) — but *not* the full inheritance-flattened set
/// chez/racket need. Gerbil's `defclass` graph (030) carries class inheritance
/// structurally — a subclass dispatches to an ancestor's `{}`/generic method
/// through the chain rather than re-emitting it (ADR-0020) — but a conformed
/// protocol's methods (`SCNNode`'s `runAction:` from `SCNActionable`) live on
/// no ancestor class, so this class is the place to emit them. `conformed` is
/// the class's own conformance closure
/// ([`ProtocolRegistry::conformance_closure`]); `all_methods` entries whose
/// `origin` is in it are exactly the protocol-contributed set (superclass-
/// inherited entries carry an ancestor-class origin and stay filtered out).
/// Own methods win ties; deduped by selector.
fn effective_methods<'a>(cls: &'a Class, conformed: &BTreeSet<String>) -> Vec<&'a Method> {
    let mut seen = HashSet::new();
    cls.methods
        .iter()
        .chain(cls.all_methods.iter().filter(|m| {
            m.origin
                .as_deref()
                .is_some_and(|origin| conformed.contains(origin))
        }))
        .filter(|m| seen.insert(m.selector.clone()))
        .collect()
}

/// This class's **own** declared properties (see [`effective_methods`] — the
/// manifest hierarchy makes flattening redundant). Deduped by name.
fn effective_properties(cls: &Class) -> Vec<&Property> {
    let mut seen = HashSet::new();
    cls.properties
        .iter()
        .filter(|p| seen.insert(make_property_getter_name("", &p.name)))
        .collect()
}

fn collect_exports(
    class_name: &str,
    properties: &[&Property],
    init_methods: &[&Method],
    instance_methods: &[&Method],
    class_methods: &[&Method],
    mapper: &dyn FfiTypeMapper,
    error_selectors: &HashSet<String>,
) -> Vec<String> {
    let mut exports: Vec<String> = Vec::new();

    for m in init_methods {
        if !is_supported_method(m, mapper) || m.selector == "init" {
            continue;
        }
        exports.push(make_unique_constructor_name(class_name, &m.selector));
    }
    if !has_explicit_constructor(init_methods, mapper) {
        exports.push(format!("make-{}", class_name_to_lowercase(class_name)));
    }

    for p in properties {
        let getter = if p.class_property {
            make_class_property_getter_name(class_name, &p.name, false)
        } else {
            make_property_getter_name(class_name, &p.name)
        };
        exports.push(getter);
        if !p.readonly {
            let setter = if p.class_property {
                make_class_property_setter_name(class_name, &p.name, false)
            } else {
                make_property_setter_name(class_name, &p.name)
            };
            exports.push(setter);
        }
    }

    for m in instance_methods {
        if !is_supported_method_ctx(m, mapper, error_selectors) {
            continue;
        }
        exports.push(make_method_name(class_name, &m.selector));
    }
    for m in class_methods {
        if !is_supported_method_ctx(m, mapper, error_selectors) {
            continue;
        }
        exports.push(make_class_method_name(class_name, &m.selector, false));
    }

    exports.sort();
    exports.dedup();
    exports
}

/// Whether the class's **own** init methods include a bindable explicit
/// constructor. Keyed off `origin: None` (a protocol-contributed init like
/// `NSCoding`'s `initWithCoder:` carries its protocol as origin): conforming
/// to a protocol must not suppress the synthesized default `make-<cls>` —
/// the protocol init is emitted as an *additional* constructor (leaf 120).
fn has_explicit_constructor(init_methods: &[&Method], mapper: &dyn FfiTypeMapper) -> bool {
    init_methods
        .iter()
        .any(|m| m.origin.is_none() && is_supported_method(m, mapper) && m.selector != "init")
}

fn is_unsupported_struct_property(t: &TypeRef, mapper: &dyn FfiTypeMapper) -> bool {
    if !mapper.is_struct_type(t) {
        return false;
    }
    let name = match &t.kind {
        TypeRefKind::Struct { name } => name,
        TypeRefKind::Alias { name, .. } => name,
        _ => return true,
    };
    !is_known_geometry_alias(name)
}

// --- signature collection / dispatch crossing -----------------------------

/// One distinct `objc_msgSend` ABI signature → one `define-c-lambda`. The
/// `binding` name is derived purely from the token shape, so any two call sites
/// with the same shape resolve to the same crossing (the per-signature dedup).
struct Signature {
    binding: String,
    /// Gambit FFI arg tokens, including the implicit leading `id` + `SEL`.
    arg_tokens: Vec<String>,
    /// Gambit FFI return token.
    ret_token: String,
    /// An NSError out-param crossing (ADR-0006): the trailing arg token is the
    /// [`NSERROR_CELL`] and the msgSend body casts that actual to `NSError**`.
    /// The binding carries an `-e` suffix (mirroring racket's `…_e` entry).
    error_out: bool,
}

/// The Gambit FFI token for the `NSError**` out-param cell threaded into an
/// error-out crossing: a pointer to a `(pointer void)` slot the method writes
/// the `NSError*` through. Cast to `NSError**` inside the msgSend body.
const NSERROR_CELL: &str = "(pointer (pointer void))";

/// The crossing arg tokens (leading `id`+`SEL`) for a method's NSError
/// out-param entry: the method's **visible** params (all but the trailing
/// `NSError**`) followed by the [`NSERROR_CELL`].
fn error_out_arg_tokens(params: &[Param], mapper: &dyn FfiTypeMapper) -> Vec<String> {
    let mut toks = vec![POINTER.to_string(), POINTER.to_string()];
    let visible = &params[..params.len().saturating_sub(1)];
    toks.extend(
        visible
            .iter()
            .map(|p| mapper.map_type(&p.param_type, false)),
    );
    toks.push(NSERROR_CELL.to_string());
    toks
}

/// The `%msg-…-e` binding name for a method's NSError out-param crossing — the
/// plain signature binding over its visible args + the error cell, suffixed
/// `-e` so it never collides with the same visible signature dispatched plainly.
/// Computed identically at the crossing definition ([`collect_signatures`]) and
/// the call site ([`emit_method`]) so the two never drift.
fn error_binding_name(method: &Method, mapper: &dyn FfiTypeMapper) -> String {
    let toks = error_out_arg_tokens(&method.params, mapper);
    let ret = mapper.map_type(&method.return_type, true);
    format!("{}-e", signature_binding_name(&toks[2..], &ret))
}

/// The `%msg-…` binding name for a msgSend shape. Built from the *variable*
/// param tokens (the leading `id`/`SEL` never vary) and the return token, via a
/// short per-token code, so the name is stable, legible, and injective on the
/// token set: `(id,SEL)->NSUInteger` ⇒ `%msg-v->u64`, `(id,SEL,double)->id` ⇒
/// `%msg-d->p`.
fn signature_binding_name(param_tokens: &[String], ret_token: &str) -> String {
    let mut s = String::from("%msg-");
    if param_tokens.is_empty() {
        s.push('v');
    } else {
        let codes: Vec<String> = param_tokens.iter().map(|t| token_code(t)).collect();
        s.push_str(&codes.join("-"));
    }
    s.push_str("->");
    s.push_str(&token_code(ret_token));
    s
}

/// Short identifier code for a Gambit FFI token (used in `%msg-…` names).
fn token_code(token: &str) -> String {
    match token {
        "(pointer void)" => "p".into(),
        // The NSError** out-param cell (a pointer to a pointer slot).
        "(pointer (pointer void))" => "pp".into(),
        "char-string" => "str".into(),
        "void" => "v".into(),
        "bool" => "b".into(),
        "float" => "f".into(),
        "double" => "d".into(),
        "int8" => "i8".into(),
        "unsigned-int8" => "u8".into(),
        "int16" => "i16".into(),
        "unsigned-int16" => "u16".into(),
        "int32" => "i32".into(),
        "unsigned-int32" => "u32".into(),
        "int64" => "i64".into(),
        "unsigned-int64" => "u64".into(),
        // struct token (CGRect, …): lowercase, valid in an identifier.
        other => other.to_ascii_lowercase(),
    }
}

/// The C type spelling for a Gambit FFI token, used inside the inline
/// `objc_msgSend` function-pointer cast. The unit compiles `-x objective-c`, so
/// `id`/`SEL`/`BOOL` and the geometry struct tags are in scope; `<stdint.h>`
/// (C-safe) backs the fixed-width integers.
fn c_cast_type(token: &str) -> &str {
    match token {
        "(pointer void)" => "id",
        "void" => "void",
        "bool" => "BOOL",
        "char-string" => "const char*",
        "float" => "float",
        "double" => "double",
        "int8" => "int8_t",
        "unsigned-int8" => "uint8_t",
        "int16" => "int16_t",
        "unsigned-int16" => "uint16_t",
        "int32" => "int32_t",
        "unsigned-int32" => "uint32_t",
        "int64" => "int64_t",
        "unsigned-int64" => "uint64_t",
        // struct token: the c-define-type name doubles as the C type spelling.
        other => other,
    }
}

/// The inline-cast `objc_msgSend` C body for one signature (spike
/// `01-reachability.ss` shape). `arg_tokens` includes the leading `id`/`SEL`.
///
/// When `error_out`, the trailing arg is the [`NSERROR_CELL`]: the cast
/// prototype's last type is `id*` and the trailing actual is cast `(id*)___argN`,
/// so the method writes the `NSError*` through it (ADR-0006; the in-Gerbil
/// out-param crossing, ADR-0017). The cell is spelled `id*`, NOT `NSError**`:
/// ADR-0021 includes no Foundation header, so `NSError` is an undeclared type
/// (a hard `gxc -O` error — found at leaf 100/050, the first imported class with
/// an error-out method, SCNScene's `sceneWithURL:options:error:`). `id` is
/// libobjc's `void *` (declared by the `<objc/*>` headers every module includes),
/// so `id*` is ABI-identical to `NSError**` and always in scope.
fn msgsend_body(arg_tokens: &[String], ret_token: &str, error_out: bool) -> String {
    let n = arg_tokens.len();
    // Cast prototype: id, SEL, then each extra param's C type (the trailing
    // error cell, if any, spelled `id*`).
    let mut proto = vec!["id".to_string(), "SEL".to_string()];
    for (idx, t) in arg_tokens.iter().enumerate().skip(2) {
        if error_out && idx == n - 1 {
            proto.push("id*".to_string());
        } else {
            proto.push(c_cast_type(t).to_string());
        }
    }
    let proto = proto.join(", ");

    // Call actuals: ___arg1 (receiver), (SEL)___arg2, then ___arg3… (the
    // trailing error cell, if any, cast `(id*)`).
    let mut actuals = vec!["___arg1".to_string(), "(SEL)___arg2".to_string()];
    for i in 2..n {
        if error_out && i == n - 1 {
            actuals.push(format!("(id*)___arg{}", i + 1));
        } else {
            actuals.push(format!("___arg{}", i + 1));
        }
    }
    let actuals = actuals.join(", ");

    if ret_token == "void" {
        format!("((void (*)({proto}))objc_msgSend)({actuals});")
    } else if ret_token == "char-string" {
        // const char* return → ___CAST off the const to avoid a cast-qual
        // warning (FINDINGS §1).
        format!("___return( ___CAST(char*, ((const char* (*)({proto}))objc_msgSend)({actuals})) );")
    } else {
        let cret = c_cast_type(ret_token);
        format!("___return( (({cret} (*)({proto}))objc_msgSend)({actuals}) );")
    }
}

/// Full Gambit arg-token list (with leading `id`+`SEL`) for a param list.
fn arg_tokens_for(params: &[Param], mapper: &dyn FfiTypeMapper) -> Vec<String> {
    let mut toks = vec![POINTER.to_string(), POINTER.to_string()];
    toks.extend(params.iter().map(|p| mapper.map_type(&p.param_type, false)));
    toks
}

/// Collect every distinct msgSend signature the class needs: methods,
/// constructors (init shapes + the shared `alloc` shape), and properties
/// (getter + setter). Deduplicated by binding name.
fn collect_signatures(
    cls: &Class,
    plan: &ClassPlan,
    needs_default_constructor: bool,
    mapper: &dyn FfiTypeMapper,
) -> Vec<Signature> {
    let mut by_name: std::collections::BTreeMap<String, Signature> =
        std::collections::BTreeMap::new();

    let mut add = |args: Vec<String>, ret: String, error_out: bool| {
        let param_tokens = args[2..].to_vec();
        let mut binding = signature_binding_name(&param_tokens, &ret);
        if error_out {
            binding.push_str("-e");
        }
        by_name.entry(binding.clone()).or_insert(Signature {
            binding,
            arg_tokens: args,
            ret_token: ret,
            error_out,
        });
    };

    // Alloc shape `(id, SEL) -> id` is needed by every constructor.
    if needs_default_constructor || !plan.init_methods.is_empty() {
        add(vec![POINTER.into(), POINTER.into()], POINTER.into(), false);
    }
    // Default ctor's `init` is the alloc shape; explicit ctors add their init.
    for m in &plan.init_methods {
        if !is_supported_method(m, mapper) || m.selector == "init" {
            continue;
        }
        add(arg_tokens_for(&m.params, mapper), POINTER.into(), false);
    }

    for m in plan
        .instance_methods
        .iter()
        .chain(plan.class_methods.iter())
    {
        if !is_supported_method_ctx(m, mapper, &plan.error_selectors) {
            continue;
        }
        if is_error_out_method(m, &plan.error_selectors) {
            // NSError out-param: a distinct `-e` crossing over the visible args
            // + the trailing error cell (the in-Gerbil out-param crossing).
            add(
                error_out_arg_tokens(&m.params, mapper),
                mapper.map_type(&m.return_type, true),
                true,
            );
        } else {
            add(
                arg_tokens_for(&m.params, mapper),
                mapper.map_type(&m.return_type, true),
                false,
            );
        }
    }

    for p in &plan.properties {
        // Getter: (id, SEL) -> prop-type.
        add(
            vec![POINTER.into(), POINTER.into()],
            mapper.map_type(&p.property_type, true),
            false,
        );
        if !p.readonly {
            // Setter: (id, SEL, prop-type) -> void.
            add(
                vec![
                    POINTER.into(),
                    POINTER.into(),
                    mapper.map_type(&p.property_type, false),
                ],
                "void".into(),
                false,
            );
        }
    }

    let _ = cls;
    by_name.into_values().collect()
}

/// Geometry struct tokens used anywhere in the class's signatures, each with the
/// C struct tag + scope (CG header / inline NS struct) it needs in the
/// `begin-ffi` `c-declare` prelude (ADR-0021).
fn geometry_decls(sigs: &[Signature]) -> Vec<GeometryDecl> {
    let mut seen = HashSet::new();
    let mut out = Vec::new();
    for sig in sigs {
        for tok in sig.arg_tokens.iter().chain(std::iter::once(&sig.ret_token)) {
            if let Some(decl) = geometry_decl(tok) {
                if seen.insert(decl.token) {
                    out.push(decl);
                }
            }
        }
    }
    out
}

// --- emission -------------------------------------------------------------

#[allow(clippy::too_many_arguments)]
fn emit_header(
    w: &mut CodeWriter,
    cls: &Class,
    framework: &str,
    exports: &[String],
    parent: &ParentRef,
    imports_generics: bool,
    needs_swift_helpers: bool,
    needs_async_bridge: bool,
) {
    write_line!(
        w,
        ";;; Generated binding for {} ({}) — do not edit",
        cls.name,
        framework
    );
    w.line("(import :std/foreign");
    // `:std/generic` (renamed) backs the generic consumption surface.
    write_line!(w, "        {}", GENERIC_IMPORT);
    // The shared global generics module: the class's `g:defmethod`s extend the
    // single generic each selector is declared as there (no per-module
    // `g:defgeneric` → no facade clash between unrelated same-named selectors).
    // Imported only when the class has an instance surface (else the module may
    // not exist for an all-empty IR).
    if imports_generics {
        write_line!(w, "        {}", GENERICS_MODULE_IMPORT);
    }
    // The parent's module must be in scope for `(defclass (Self Parent) …)`. The
    // runtime root needs no extra import (it lives in the runtime module already
    // imported below); local/cross-framework parents import their sibling/owning
    // module.
    if let Some(import_path) = parent_import_path(parent, &framework.to_ascii_lowercase()) {
        write_line!(w, "        {}", import_path);
    }
    // Tail imports: the objc runtime always (class graph + `wrap`/`->ptr`); the
    // Swift-native trampoline coercers + async-bridge only when the Swift-native
    // method/init section needs them. The last one closes the `(import …)` form.
    let mut tail = vec![RUNTIME_OBJC_IMPORT];
    if needs_swift_helpers {
        tail.push(RUNTIME_TRAMPOLINE_IMPORT);
    }
    if needs_async_bridge {
        tail.push(RUNTIME_ASYNC_BRIDGE_IMPORT);
    }
    for (i, imp) in tail.iter().enumerate() {
        if i + 1 == tail.len() {
            write_line!(w, "        {})", imp);
        } else {
            write_line!(w, "        {}", imp);
        }
    }

    if exports.is_empty() {
        w.line("(export)");
    } else {
        w.line("(export");
        for name in exports {
            write_line!(w, "  {}", name);
        }
        w.line("  )");
    }
    w.blank_line();
}

/// The `:gerbil-bindings/<fw>/<cls>` import the child module needs to bring the
/// parent class identifier into scope, or `None` for the runtime root (already
/// imported via the runtime module). A local parent lives under the current
/// framework; a cross-framework parent under its owning framework.
fn parent_import_path(parent: &ParentRef, framework_low: &str) -> Option<String> {
    let (fw_low, name) = match parent {
        ParentRef::RuntimeRoot => return None,
        ParentRef::Local(name) => (framework_low, name),
        ParentRef::CrossFramework { name, fw_low } => (fw_low.as_str(), name),
    };
    Some(format!(
        ":{}/{}/{}",
        crate::emit_framework::PACKAGE,
        fw_low,
        class_name_to_lowercase(name)
    ))
}

/// Emit the manifest class-graph forms (ADR-0020): the `defclass` deriving from
/// the resolved parent, then the runtime registration carrying the ObjC name and
/// ObjC superclass name (for the wrap boundary + subclassing bridge). The
/// runtime-owned [`RUNTIME_ROOT`] is never re-defined here.
fn emit_class_graph_block(
    w: &mut CodeWriter,
    class_name: &str,
    objc_super: &str,
    parent: &ParentRef,
) {
    if class_name == RUNTIME_ROOT {
        return;
    }
    w.line(";; --- Class graph (ADR-0020) ---");
    write_line!(
        w,
        "(defclass ({} {}) () transparent: #t)",
        class_name,
        parent.gerbil_name()
    );
    // The runtime registry maps the ObjC class name to a POSITIONAL constructor
    // closure (the runtime's `wrap` calls `(ctor ptr)`), plus the Gerbil class
    // descriptor `<Class>::t` (for the 030 subclassing bridge) and the ObjC
    // superclass name (the wrap-boundary fallback walk + subclass synthesis).
    // The closure adapts the keyword constructor `make-<Class>` — a bare class
    // identifier is Gerbil *syntax*, not a runtime value, so it cannot be passed
    // directly (settled at leaf 050/010). Contract: `(register-objc-class! ctor
    // descriptor objc-name objc-super)`.
    write_line!(
        w,
        "(register-objc-class! (lambda (p) (make-{} ptr: p)) {}::t \"{}\" \"{}\")",
        class_name,
        class_name,
        class_name,
        objc_super
    );
    w.blank_line();
}

fn emit_ffi_block(
    w: &mut CodeWriter,
    cls: &Class,
    plan: &ClassPlan,
    needs_default_constructor: bool,
    mapper: &dyn FfiTypeMapper,
) {
    let sigs = collect_signatures(cls, plan, needs_default_constructor, mapper);
    let geo = geometry_decls(&sigs);

    // begin-ffi export list: the FFI helpers + every crossing.
    w.line("(begin-ffi (objc_getClass sel_registerName");
    for sig in &sigs {
        write_line!(w, "            {}", sig.binding);
    }
    w.line("            )");

    // All C-safe under the default gcc-15 (ADR-0021): objc/CoreGraphics headers
    // plus inline plain-C decls for the NS geometry structs — no framework
    // umbrella `#include`.
    w.line("  (c-declare \"#include <objc/runtime.h>\")");
    w.line("  (c-declare \"#include <objc/message.h>\")");
    w.line("  (c-declare \"#include <stdint.h>\")");
    emit_geometry_decls(w, &geo);
    w.blank_line();

    w.line("  (define-c-lambda objc_getClass (char-string) (pointer void) \"objc_getClass\")");
    w.line(
        "  (define-c-lambda sel_registerName (char-string) (pointer void) \"sel_registerName\")",
    );

    for sig in &sigs {
        write_line!(
            w,
            "  (define-c-lambda {} ({}) {}",
            sig.binding,
            sig.arg_tokens.join(" "),
            sig.ret_token
        );
        write_line!(
            w,
            "    \"{}\")",
            msgsend_body(&sig.arg_tokens, &sig.ret_token, sig.error_out)
        );
    }
    w.line("  )");
    w.blank_line();
}

/// Module-level `sel_registerName` caches, one per distinct selector used by an
/// emitted method or property (registered once at module load).
fn emit_selector_caches(w: &mut CodeWriter, cls: &Class, plan: &ClassPlan) {
    let mut seen = HashSet::new();
    let mut emit_sel = |w: &mut CodeWriter, selector: &str| {
        if seen.insert(selector.to_string()) {
            write_line!(
                w,
                "(define {} (sel_registerName \"{}\"))",
                make_selector_binding_name(&cls.name, selector),
                selector
            );
        }
    };

    let mapper = GerbilFfiTypeMapper;
    let mut any = false;
    // Explicit constructors cache their init selector (the default ctor inlines
    // alloc/init, so it needs no cache); `init` itself is the default-ctor shape.
    for m in &plan.init_methods {
        if is_supported_method(m, &mapper) && m.selector != "init" {
            emit_sel(w, &m.selector);
            any = true;
        }
    }
    for m in plan
        .instance_methods
        .iter()
        .chain(plan.class_methods.iter())
    {
        if is_supported_method_ctx(m, &mapper, &plan.error_selectors) {
            emit_sel(w, &m.selector);
            any = true;
        }
    }
    for p in &plan.properties {
        emit_sel(w, &p.name);
        any = true;
        if !p.readonly {
            emit_sel(w, &setter_selector_for(&p.name));
        }
    }
    if any {
        w.blank_line();
    }
}

/// Declarations shared by the dual consumption surfaces (ADR-0020): the
/// module-level `(declare (inline))` that lets the surface forwarders inline the
/// proc core (the designated fast path). Emitted once, before the procs/surfaces
/// that need it, only when the class has an instance surface.
///
/// The generics themselves are **not** declared here. Each module declaring its
/// own `(g:defgeneric <sel>)` made two *unrelated* classes sharing a selector name
/// export colliding generics at the framework facade; the generics now live ONCE
/// in the shared [`crate::emit_generics`] module (imported via
/// [`GENERICS_MODULE_IMPORT`]), and this class's `g:defmethod`s extend those. The
/// built-in `{}` surface needs no declaration — it dispatches by method-table
/// symbol.
fn emit_surface_decls(w: &mut CodeWriter, cls: &Class, plan: &ClassPlan) {
    let selectors = instance_surface_selectors(cls, plan);
    if selectors.is_empty() {
        return;
    }
    w.line(";; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are");
    w.line(";;     declared once in :gerbil-bindings/generics and extended below ---");
    w.line("(declare (inline))");
    w.blank_line();
}

fn emit_default_constructor(w: &mut CodeWriter, class_name: &str) {
    let fn_name = format!("make-{}", class_name_to_lowercase(class_name));
    let alloc = signature_binding_name(&[], POINTER);
    write_line!(w, "(define ({})", fn_name);
    w.line("  (wrap");
    write_line!(
        w,
        "    ({alloc} ({alloc} (objc_getClass \"{cls}\") (sel_registerName \"alloc\"))",
        alloc = alloc,
        cls = class_name
    );
    w.line("          (sel_registerName \"init\"))");
    w.line("    #t))");
    w.blank_line();
}

fn emit_constructor(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    mapper: &dyn FfiTypeMapper,
) {
    if !is_supported_method(method, mapper) || method.selector == "init" {
        return;
    }
    let fn_name = make_unique_constructor_name(class_name, &method.selector);
    let param_vars = param_var_names(&method.params);
    let alloc = signature_binding_name(&[], POINTER);
    let init = signature_binding_name(&arg_tokens_for(&method.params, mapper)[2..], POINTER);
    let sel_var = make_selector_binding_name(class_name, &method.selector);

    let mut sig = format!("(define ({fn_name}");
    for v in &param_vars {
        sig.push(' ');
        sig.push_str(v);
    }
    sig.push(')');
    write_line!(w, "{}", sig);

    let coerced: Vec<String> = method
        .params
        .iter()
        .zip(param_vars.iter())
        .map(|(p, v)| coerce_arg_expr(p, v))
        .collect();
    let alloc_call =
        format!("({alloc} (objc_getClass \"{class_name}\") (sel_registerName \"alloc\"))");
    write_line!(
        w,
        "  (wrap ({init} {alloc_call} {sel}{sp}{args}) #t))",
        init = init,
        alloc_call = alloc_call,
        sel = sel_var,
        sp = if coerced.is_empty() { "" } else { " " },
        args = coerced.join(" ")
    );
    w.blank_line();
}

fn emit_method(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    is_class_method: bool,
    mapper: &dyn FfiTypeMapper,
    error_selectors: &HashSet<String>,
) {
    if !is_supported_method_ctx(method, mapper, error_selectors) {
        return;
    }
    // NSError out-param methods (ADR-0006) drop the trailing `NSError**` from
    // the proc's arity and return `(values result error)` via the runtime's
    // `call-with-nserror-out` (the error half is layered on the proc core, so
    // both surfaces inherit it). Every other method threads all its params.
    let is_err = is_error_out_method(method, error_selectors);
    let visible_params: &[Param] = if is_err {
        &method.params[..method.params.len() - 1]
    } else {
        &method.params
    };

    let fn_name = if is_class_method {
        make_class_method_name(class_name, &method.selector, false)
    } else {
        make_method_name(class_name, &method.selector)
    };
    let binding = if is_err {
        error_binding_name(method, mapper)
    } else {
        signature_binding_name(
            &arg_tokens_for(&method.params, mapper)[2..],
            &mapper.map_type(&method.return_type, true),
        )
    };
    let sel_var = make_selector_binding_name(class_name, &method.selector);
    let param_vars = param_var_names(visible_params);

    let mut sig = format!("(define ({fn_name}");
    if !is_class_method {
        sig.push_str(" self");
    }
    for v in &param_vars {
        sig.push(' ');
        sig.push_str(v);
    }
    sig.push(')');
    write_line!(w, "{}", sig);

    let receiver = if is_class_method {
        format!("(objc_getClass \"{class_name}\")")
    } else {
        root_ptr_accessor("self")
    };
    let mut actuals: Vec<String> = visible_params
        .iter()
        .zip(param_vars.iter())
        .map(|(p, v)| coerce_arg_expr(p, v))
        .collect();
    if is_err {
        // The runtime supplies the zeroed `NSError**` cell to the thunk.
        actuals.push("%err-cell".to_string());
    }
    let call = format!(
        "({binding} {receiver} {sel_var}{sp}{args})",
        sp = if actuals.is_empty() { "" } else { " " },
        args = actuals.join(" ")
    );
    let wrapped = wrap_return(method, &call, mapper);
    if is_err {
        // `call-with-nserror-out` allocates the cell, runs the thunk with it,
        // and returns `(values <thunk-result> <nserror-or-#f>)`; the proc only
        // adds its own result-wrapping inside the thunk (runtime contract owned
        // by node 050).
        w.line("  (call-with-nserror-out");
        w.line("    (lambda (%err-cell)");
        write_line!(w, "      {})))", wrapped);
    } else {
        write_line!(w, "  {})", wrapped);
    }

    // Both consumption surfaces over the proc core — instance methods only (a
    // receiver to dispatch on). Class methods are proc-only namespaced functions.
    // `emit_instance_surfaces` keeps the proc + its surfaces a tight unit and
    // emits the trailing blank; a class-method proc emits its own. Error-out
    // procs expose their visible arity, so the surfaces forward those args and
    // return the two values too.
    if is_class_method {
        w.blank_line();
    } else {
        emit_instance_surfaces(w, class_name, &fn_name, &param_vars);
    }
}

/// Emit the consumption surfaces (ADR-0020) forwarding to an instance proc
/// `proc_name` over receiver type `class_name`, sharing the bare-kebab surface
/// selector. `param_vars` are the proc's non-receiver argument names.
///
/// **The two surfaces are not equally expressive (discovered at the first
/// full-framework gxc compile, leaf 070/020).** The built-in `{}` MOP keys
/// dispatch on the receiver class via the method-table symbol, so its lambda
/// takes the remaining args *free* (untyped) — it expresses every method. The
/// `:std/generic` `defmethod` macro instead requires *every* formal to be a
/// typed `(arg type)` pair and dispatches on all of them, so it can only
/// express receiver-only (zero-extra-arg) methods safely; an untyped extra arg
/// is a syntax error, and typing an object arg would mis-dispatch on `#f`/nil.
/// So the `{}` MOP surface is emitted for every instance method, and the
/// `:std/generic` surface only for receiver-only methods (getters, zero-arg
/// actions) — exactly where generic-function dispatch reads idiomatically
/// (`(length obj)`, `(title obj)`). Arg-taking methods use the proc core or the
/// `{}` surface; the shared `(g:defgeneric sel)` stays declared (harmless if
/// some selectors carry no `:std/generic` method).
fn emit_instance_surfaces(
    w: &mut CodeWriter,
    class_name: &str,
    proc_name: &str,
    param_vars: &[String],
) {
    let sel = surface_selector(class_name, proc_name);
    let extra = param_vars.join(" ");
    let sp = if param_vars.is_empty() { "" } else { " " };
    // Surface 1 — built-in `{}` MOP: dispatches by method-table symbol; the
    // remaining args ride free, so this surface covers every instance method.
    write_line!(
        w,
        "(defmethod {{{sel} {class_name}}} (lambda (self{sp}{extra}) ({proc_name} self{sp}{extra})))"
    );
    // Surface 2 — `:std/generic`: receiver-specialized generic method (same id).
    // Only valid for receiver-only methods (see the doc comment): the macro
    // requires every formal typed, which cannot express free extra args.
    if param_vars.is_empty() {
        write_line!(w, "(g:defmethod ({sel} (o {class_name})) ({proc_name} o))");
    }
    w.blank_line();
}

/// The bare-kebab surface selector for a class-prefixed proc name: strip the
/// `<class-lowercase>-` prefix the proc carries (`nsstring-length` → `length`,
/// `nswindow-set-title!` → `set-title!`). Both surfaces share this identifier;
/// stripping the proc's own prefix keeps surface and proc in lockstep.
///
/// The bare name becomes a top-level binding (`(g:defgeneric <name>)`) in the
/// shared generics module, re-exported into every class module. If it collides
/// with a Gerbil/Gambit **syntactic keyword** it shadows that special form for
/// every importer — e.g. WebKit's `DOMHTMLObjectElement.declare` property yields
/// a generic `declare` that masks the `(declare (inline))` every class module
/// emits, turning it into a call to the generic (`inline` then unbound). The
/// proc core is unaffected (it keeps its class prefix), so only the veneer name
/// is escaped (suffixed `*`); the escape is deterministic per selector, so the
/// cross-class generic unification (one generic per shared selector) is
/// preserved.
fn surface_selector(class_name: &str, proc_name: &str) -> String {
    let prefix = format!("{}-", class_name_to_lowercase(class_name));
    let bare = proc_name.strip_prefix(&prefix).unwrap_or(proc_name);
    if is_reserved_surface_name(bare) {
        format!("{bare}*")
    } else {
        bare.to_string()
    }
}

/// Gerbil/Gambit syntactic keywords a generic surface name must not shadow: a
/// shadow breaks any emitted module that uses the form at head position. Only
/// `declare` bites today (the emitted `(declare (inline))`), but the set guards
/// the whole class so a future framework selector spelling `define`, `lambda`,
/// etc. cannot silently break emission. Procedures (`values`, `not`) are *not*
/// listed — shadowing a procedure binding is harmless unless called, and the
/// emitter never calls them by bare name in a class module.
fn is_reserved_surface_name(name: &str) -> bool {
    matches!(
        name,
        "declare"
            | "define"
            | "define-values"
            | "define-syntax"
            | "lambda"
            | "let"
            | "let*"
            | "letrec"
            | "letrec*"
            | "if"
            | "cond"
            | "case"
            | "when"
            | "unless"
            | "and"
            | "or"
            | "begin"
            | "do"
            | "quote"
            | "quasiquote"
            | "set!"
            | "delay"
            | "else"
            | "import"
            | "export"
            | "defclass"
            | "defmethod"
            | "defgeneric"
    )
}

fn emit_property(
    w: &mut CodeWriter,
    class_name: &str,
    prop: &Property,
    mapper: &dyn FfiTypeMapper,
) {
    if is_unsupported_struct_property(&prop.property_type, mapper)
        || matches!(prop.property_type.kind, TypeRefKind::Block { .. })
    {
        return;
    }
    let getter_name = if prop.class_property {
        make_class_property_getter_name(class_name, &prop.name, false)
    } else {
        make_property_getter_name(class_name, &prop.name)
    };
    let getter_binding = signature_binding_name(&[], &mapper.map_type(&prop.property_type, true));
    let getter_sel = make_selector_binding_name(class_name, &prop.name);
    let receiver = if prop.class_property {
        format!("(objc_getClass \"{class_name}\")")
    } else {
        root_ptr_accessor("self")
    };

    let arglist = if prop.class_property { "" } else { " self" };
    write_line!(w, "(define ({getter_name}{arglist})");
    let call = format!("({getter_binding} {receiver} {getter_sel})");
    let wrapped = if mapper.is_object_type(&prop.property_type) {
        format!("(wrap {call})")
    } else {
        call
    };
    write_line!(w, "  {})", wrapped);
    // Both surfaces over an instance-property getter (a 0-arg method).
    if !prop.class_property {
        emit_instance_surfaces(w, class_name, &getter_name, &[]);
    } else {
        w.blank_line();
    }

    if !prop.readonly {
        let setter_name = if prop.class_property {
            make_class_property_setter_name(class_name, &prop.name, false)
        } else {
            make_property_setter_name(class_name, &prop.name)
        };
        let value_tok = mapper.map_type(&prop.property_type, false);
        let setter_binding = signature_binding_name(&[value_tok], "void");
        let setter_sel = make_selector_binding_name(class_name, &setter_selector_for(&prop.name));
        let arglist = if prop.class_property {
            "value"
        } else {
            "self value"
        };
        write_line!(w, "(define ({setter_name} {arglist})");
        let value_expr = setter_value_expr(&prop.property_type);
        write_line!(
            w,
            "  ({setter_binding} {receiver} {setter_sel} {value_expr}))"
        );
        // Both surfaces over an instance-property setter (a 1-arg method).
        if !prop.class_property {
            emit_instance_surfaces(w, class_name, &setter_name, &["value".to_string()]);
        } else {
            w.blank_line();
        }
    }
}

// --- per-arg / per-return coercion ----------------------------------------

fn coerce_arg_expr(param: &Param, var: &str) -> String {
    match &param.param_type.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            format!("(->ptr {var})")
        }
        TypeRefKind::Selector => format!("(sel_registerName {var})"),
        _ => var.to_string(),
    }
}

fn setter_value_expr(t: &TypeRef) -> String {
    match &t.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            "(->ptr value)".to_string()
        }
        TypeRefKind::Selector => "(sel_registerName value)".to_string(),
        _ => "value".to_string(),
    }
}

fn wrap_return(method: &Method, call: &str, mapper: &dyn FfiTypeMapper) -> String {
    if returns_void(method, mapper) {
        call.to_string()
    } else if returns_object_type(method, mapper) {
        if method_returns_retained(method) {
            format!("(wrap {call} #t)")
        } else {
            format!("(wrap {call})")
        }
    } else {
        call.to_string()
    }
}

fn param_var_names(params: &[Param]) -> Vec<String> {
    params
        .iter()
        .enumerate()
        .map(|(i, p)| {
            let base = camel_to_kebab(&p.name);
            if base.is_empty() {
                format!("arg{i}")
            } else {
                base
            }
        })
        .collect()
}

fn setter_selector_for(prop_name: &str) -> String {
    let first = prop_name.chars().next().unwrap_or('x');
    format!(
        "set{}{}:",
        first.to_uppercase(),
        &prop_name[first.len_utf8()..]
    )
}

fn method_returns_retained(method: &Method) -> bool {
    if let Some(r) = method.returns_retained {
        return r;
    }
    let sel = &method.selector;
    if !method.class_method && is_family_match(sel, "init") {
        return true;
    }
    if method.class_method && is_family_match(sel, "new") {
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
    use apianyware_macos_types::ir::{Method, Param};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    #[test]
    fn surface_selector_strips_class_prefix() {
        assert_eq!(surface_selector("NSString", "nsstring-length"), "length");
        assert_eq!(
            surface_selector("NSWindow", "nswindow-set-title!"),
            "set-title!"
        );
    }

    #[test]
    fn surface_selector_escapes_syntactic_keyword_collisions() {
        // WebKit's DOMHTMLObjectElement.declare property — the generic name would
        // shadow Gambit's `declare` special form and break every class module's
        // `(declare (inline))`. The proc core keeps its prefix; only the bare
        // veneer name is escaped, deterministically (so cross-class generic
        // unification is preserved).
        assert_eq!(
            surface_selector("DOMHTMLObjectElement", "domhtmlobjectelement-declare"),
            "declare*"
        );
        // A non-colliding name is untouched.
        assert_eq!(
            surface_selector(
                "DOMHTMLObjectElement",
                "domhtmlobjectelement-declare-types-owner"
            ),
            "declare-types-owner"
        );
        assert!(is_reserved_surface_name("set!"));
        assert!(!is_reserved_surface_name("set-title!"));
    }

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn make_method(sel: &str, class_method: bool, init: bool, ret: TypeRef) -> Method {
        Method {
            selector: sel.into(),
            class_method,
            init_method: init,
            params: vec![],
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

    fn cls_with(name: &str, methods: Vec<Method>, properties: Vec<Property>) -> Class {
        Class {
            name: name.into(),
            superclass: String::new(),
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

    #[test]
    fn renders_module_with_ffi_block_and_proc() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "length",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains(";;; Generated binding for NSString (Foundation)"));
        assert!(out.contains("(import :std/foreign"));
        assert!(out.contains(":gerbil-bindings/runtime/objc"));
        assert!(out.contains("(begin-ffi (objc_getClass sel_registerName"));
        // length is (id, SEL) -> NSUInteger → %msg-v->u64
        assert!(out.contains(
            "(define-c-lambda %msg-v->u64 ((pointer void) (pointer void)) unsigned-int64"
        ));
        assert!(out.contains("((uint64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2)"));
        // proc core over the typed defclass instance (root ptr slot read)
        assert!(out.contains("(define (nsstring-length self)"));
        assert!(out.contains("(%msg-v->u64 (NSObject-ptr self) %sel-nsstring-length)"));
        assert!(out.contains("(define %sel-nsstring-length (sel_registerName \"length\"))"));
        // dual consumption surfaces, shared identifier `length`, forward to proc
        assert!(out.contains("(declare (inline))"));
        // The generic is NOT declared per-module any more — it lives once in the
        // shared :gerbil-bindings/generics module, which this class imports and
        // extends via g:defmethod.
        assert!(!out.contains("(g:defgeneric length)"));
        assert!(out.contains(":gerbil-bindings/generics"));
        assert!(
            out.contains("(defmethod {length NSString} (lambda (self) (nsstring-length self)))")
        );
        assert!(out.contains("(g:defmethod (length (o NSString)) (nsstring-length o))"));
        // the renamed :std/generic import is in scope
        assert!(out.contains(
            "(rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))"
        ));
    }

    #[test]
    fn per_signature_dedup_collapses_same_shape() {
        // -length and -count are both (id, SEL) -> NSUInteger → one crossing.
        let cls = cls_with(
            "NSArray",
            vec![
                make_method(
                    "count",
                    false,
                    false,
                    ty(TypeRefKind::Primitive {
                        name: "uint64".into(),
                    }),
                ),
                make_method(
                    "length",
                    false,
                    false,
                    ty(TypeRefKind::Primitive {
                        name: "nsuinteger".into(),
                    }),
                ),
            ],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert_eq!(out.matches("(define-c-lambda %msg-v->u64").count(), 1);
        // but both procs exist, sharing the one crossing
        assert!(out.contains("(define (nsarray-count self)"));
        assert!(out.contains("(define (nsarray-length self)"));
    }

    /// Build a protocol-origin `all_methods` entry (what the resolve phase
    /// produces for a method declared on a conformed protocol).
    fn flattened(sel: &str, origin: &str, params: Vec<Param>, ret: TypeRef) -> Method {
        let mut m = make_method(sel, false, false, ret);
        m.params = params;
        m.origin = Some(origin.into());
        m
    }

    #[test]
    fn conformed_protocol_methods_flatten_onto_class() {
        // The SCNNode shape (leaf 120): `runAction:` is declared on the
        // SCNActionable protocol the class conforms to, not on the class — the
        // resolve phase lands it in `all_methods` with the protocol as origin.
        // The emitter must give it the full own-method treatment: proc core,
        // `{}` surface, export. Superclass-inherited entries (ancestor-class
        // origin) and methods from a protocol unknown to the registry (stub
        // metadata only) must both stay out.
        let mut cls = cls_with(
            "SCNNode",
            vec![make_method(
                "position",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
            )],
            vec![],
        );
        cls.protocols = vec!["SCNActionable".into(), "CALayerDelegate".into()];
        cls.all_methods = vec![
            flattened(
                "runAction:",
                "SCNActionable",
                vec![param("action", TypeRefKind::Id)],
                TypeRef::void(),
            ),
            // Superclass-inherited (class origin) — the manifest graph carries it.
            flattened("frame", "NSView", vec![], TypeRef::void()),
            // Unknown protocol (unloaded framework) — stub metadata, deferred.
            flattened("displayLayer:", "CALayerDelegate", vec![], TypeRef::void()),
        ];

        let mut registry = ProtocolRegistry::new();
        registry.insert("SCNActionable", vec!["NSObject".into()]);

        let (out, exports) = generate_class_file_with_parent(
            &cls,
            "SceneKit",
            &ParentRef::RuntimeRoot,
            &HashSet::new(),
            &registry,
        );

        // The protocol-provided method is a first-class citizen: proc core +
        // `{}` MOP surface + selector cache + export.
        assert!(out.contains("(define (scnnode-run-action self action)"));
        assert!(out.contains(
            "(defmethod {run-action SCNNode} (lambda (self action) (scnnode-run-action self action)))"
        ));
        assert!(out.contains("(define %sel-scnnode-run-action (sel_registerName \"runAction:\"))"));
        assert!(exports.contains(&"scnnode-run-action".to_string()));

        // Superclass-inherited stays structural (no re-emission)…
        assert!(!out.contains("scnnode-frame"));
        // …and the unknown protocol's stub method is deferred.
        assert!(!out.contains("display-layer"));
    }

    #[test]
    fn own_method_wins_over_protocol_duplicate() {
        // A class that re-declares a protocol method keeps its own (richer)
        // declaration; the flattened duplicate is dropped by selector dedup.
        let mut cls = cls_with(
            "SCNNode",
            vec![make_method(
                "hasActions",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "bool".into(),
                }),
            )],
            vec![],
        );
        cls.protocols = vec!["SCNActionable".into()];
        cls.all_methods = vec![flattened(
            "hasActions",
            "SCNActionable",
            vec![],
            TypeRef::void(),
        )];
        let mut registry = ProtocolRegistry::new();
        registry.insert("SCNActionable", vec![]);

        let (out, _) = generate_class_file_with_parent(
            &cls,
            "SceneKit",
            &ParentRef::RuntimeRoot,
            &HashSet::new(),
            &registry,
        );
        assert_eq!(out.matches("(define (scnnode-has-actions self)").count(), 1);
        // The own declaration's bool return survives (a void-returning proc
        // would have no `%msg-v->b` crossing).
        assert!(out.contains("%msg-v->b"));
    }

    #[test]
    fn struct_returning_method_uses_by_value_cgrect() {
        let cls = cls_with(
            "NSView",
            vec![make_method(
                "frame",
                false,
                false,
                ty(TypeRefKind::Alias {
                    name: "NSRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "AppKit");
        assert!(out.contains("(c-declare \"#include <CoreGraphics/CGGeometry.h>\")"));
        assert!(out.contains("(c-define-type CGRect (struct \"CGRect\"))"));
        // NSRect canonicalises to the CGRect by-value token
        assert!(
            out.contains("(define-c-lambda %msg-v->cgrect ((pointer void) (pointer void)) CGRect")
        );
        assert!(out.contains("((CGRect (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2)"));
        // a struct return is NOT object-wrapped
        assert!(out.contains("(define (nsview-frame self)"));
        assert!(out.contains("(%msg-v->cgrect (NSObject-ptr self) %sel-nsview-frame)"));
    }

    #[test]
    fn object_return_is_wrapped() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "description",
                false,
                false,
                ty(TypeRefKind::Id),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        // object return wrapped through the class-aware (registry) `wrap`
        assert!(out.contains("(wrap (%msg-v->p (NSObject-ptr self) %sel-nsstring-description))"));
    }

    #[test]
    fn default_constructor_allocs_and_inits_retained() {
        let cls = cls_with("NSObject", vec![], vec![]);
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains(";; --- Constructors ---"));
        assert!(out.contains("(define (make-nsobject)"));
        assert!(out.contains("(objc_getClass \"NSObject\")"));
        assert!(out.contains("(sel_registerName \"alloc\")"));
        assert!(out.contains("(sel_registerName \"init\")"));
        assert!(out.contains("#t))"));
        assert!(out.contains("make-nsobject"));
    }

    #[test]
    fn explicit_constructor_threads_args() {
        let mut init = make_method(
            "initWithUTF8String:",
            false,
            true,
            ty(TypeRefKind::Instancetype),
        );
        init.params = vec![param("utf8", TypeRefKind::CString)];
        let cls = cls_with("NSString", vec![init], vec![]);
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains("(define (make-nsstring-init-with-utf8-string utf8)"));
        // init shape (id, SEL, char-string) -> id → %msg-str->p; alloc → %msg-v->p
        assert!(out.contains("%msg-str->p"));
        // constructor returns a typed instance via the class-aware `wrap`
        assert!(out.contains("(wrap (%msg-str->p"));
        assert!(out.contains("#t))"));
        // the explicit init selector is cached at module load (not inlined)
        assert!(out
            .contains("(define %sel-nsstring-init-with-utf8-string (sel_registerName \"initWithUTF8String:\"))"));
        assert!(out.contains("%sel-nsstring-init-with-utf8-string utf8"));
        // no synthesized default ctor when an explicit initializer exists
        assert!(!out.contains("(define (make-nsstring)\n"));
    }

    #[test]
    fn property_getter_and_setter() {
        let cls = cls_with(
            "NSWindow",
            vec![],
            vec![prop("title", TypeRefKind::Id, false)],
        );
        let out = generate_class_file(&cls, "AppKit");
        assert!(out.contains(";; --- Properties ---"));
        assert!(out.contains("(define (nswindow-title self)"));
        assert!(out.contains("(wrap (%msg-v->p (NSObject-ptr self) %sel-nswindow-title))"));
        // The proc name keeps the mutating `!`; the selector cache var is keyed
        // on the raw selector `setTitle:` (no `!`).
        assert!(out.contains("(define (nswindow-set-title! self value)"));
        assert!(
            out.contains("(%msg-p->v (NSObject-ptr self) %sel-nswindow-set-title (->ptr value))")
        );
        assert!(out.contains("(define %sel-nswindow-set-title (sel_registerName \"setTitle:\"))"));
        // Both surfaces over the getter AND the setter, bare-kebab selectors. The
        // generics are declared once in the shared module (imported here), not
        // per-module.
        assert!(!out.contains("(g:defgeneric title)"));
        assert!(!out.contains("(g:defgeneric set-title!)"));
        assert!(out.contains(":gerbil-bindings/generics"));
        // Getter is receiver-only: both surfaces.
        assert!(out.contains("(defmethod {title NSWindow} (lambda (self) (nswindow-title self)))"));
        assert!(out.contains("(g:defmethod (title (o NSWindow)) (nswindow-title o))"));
        // Setter takes an arg: `{}` MOP only — `:std/generic` cannot express a
        // receiver-only method with a free extra arg (leaf 070/020).
        assert!(out.contains(
            "(defmethod {set-title! NSWindow} (lambda (self value) (nswindow-set-title! self value)))"
        ));
        assert!(!out.contains("(g:defmethod (set-title! "));
    }

    #[test]
    fn class_method_uses_get_class_receiver() {
        let cls = cls_with(
            "NSString",
            vec![make_method("string", true, false, ty(TypeRefKind::Id))],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains(";; --- Class methods ---"));
        assert!(out.contains("(define (nsstring-string)"));
        assert!(
            out.contains("(wrap (%msg-v->p (objc_getClass \"NSString\") %sel-nsstring-string))")
        );
        // Class methods are proc-only — no instance receiver to dispatch on, so
        // no `{}`/generic surface, no g:defmethod, and (no instance surface at all)
        // the class does not even import the shared generics module.
        assert!(!out.contains("(defmethod {string NSString}"));
        assert!(!out.contains("(g:defmethod (string "));
        assert!(!out.contains(":gerbil-bindings/generics"));
    }

    #[test]
    fn char_string_return_casts_off_const() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "UTF8String",
                false,
                false,
                ty(TypeRefKind::CString),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out
            .contains("(define-c-lambda %msg-v->str ((pointer void) (pointer void)) char-string"));
        assert!(out.contains("___CAST(char*, ((const char* (*)(id, SEL))objc_msgSend)"));
    }

    #[test]
    fn exports_are_sorted_and_complete() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "length",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
            )],
            vec![],
        );
        let exports = class_exports(&cls);
        assert!(exports.contains(&"make-nsstring".to_string()));
        assert!(exports.contains(&"nsstring-length".to_string()));
        // The Gerbil class identifier + subtype predicate are exported so
        // sibling/subclass modules (and user subclassing) see them.
        assert!(exports.contains(&"NSString".to_string()));
        assert!(exports.contains(&"NSString?".to_string()));
        // The bare-kebab surface selector (the `{}`/generic method name) is also
        // exported alongside the class-prefixed proc.
        assert!(exports.contains(&"length".to_string()));
        let mut sorted = exports.clone();
        sorted.sort();
        assert_eq!(exports, sorted);
    }

    // --- dual consumption surfaces (ADR-0020, leaf 040) ------------------

    #[test]
    fn arg_taking_method_surfaces_thread_args() {
        // setObject:forKey: shape — both surfaces forward every non-receiver arg,
        // and an `id` arg coerces through `->ptr` in the proc core.
        let mut m = make_method(
            "setObject:forKey:",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "void".into(),
            }),
        );
        m.params = vec![
            param("object", TypeRefKind::Id),
            param("key", TypeRefKind::Id),
        ];
        let cls = cls_with("NSMutableDictionary", vec![m], vec![]);
        let out = generate_class_file(&cls, "Foundation");
        // proc core coerces both id args via ->ptr
        assert!(out.contains("(define (nsmutabledictionary-set-object-for-key! self object key)"));
        assert!(out.contains("(->ptr object)"));
        assert!(out.contains("(->ptr key)"));
        // built-in {} surface forwards self + both args to the proc
        assert!(out.contains(
            "(defmethod {set-object-for-key! NSMutableDictionary} (lambda (self object key) (nsmutabledictionary-set-object-for-key! self object key)))"
        ));
        // No `:std/generic` surface for an arg-taking method (leaf 070/020):
        // the macro requires every formal typed, so a free extra arg is invalid.
        assert!(!out.contains("(g:defmethod (set-object-for-key! "));
        // The generic is declared once in the shared module, not here.
        assert!(!out.contains("(g:defgeneric set-object-for-key!)"));
        assert!(out.contains(":gerbil-bindings/generics"));
    }

    #[test]
    fn own_methods_only_so_inheritance_dispatches_to_ancestor() {
        // A subclass that declares NO own methods emits NO surface for an
        // inherited selector — a subclass instance dispatches to the ancestor's
        // `{}`/generic method through the defclass graph (ADR-0020). The flattened
        // `all_methods` chain is deliberately ignored for gerbil.
        let mut child = cls_with("NSMutableString", vec![], vec![]);
        child.superclass = "NSString".into();
        // The inherited `length` lives only in the (flattened) ancestor chain.
        child.all_methods = vec![make_method(
            "length",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "uint64".into(),
            }),
        )];
        let out = generate_class_file_with_parent(
            &child,
            "Foundation",
            &ParentRef::Local("NSString".into()),
            &HashSet::new(),
            &ProtocolRegistry::new(),
        )
        .0;
        // No own method ⇒ no proc, no surface, no g:defmethod for `length`, and
        // (no instance surface at all) no import of the shared generics module.
        assert!(!out.contains("(define (nsmutablestring-length"));
        assert!(!out.contains("(defmethod {length NSMutableString}"));
        assert!(!out.contains("(g:defmethod (length "));
        assert!(!out.contains(":gerbil-bindings/generics"));
        // ...but the defclass link to the ancestor IS present (inheritance path).
        assert!(out.contains("(defclass (NSMutableString NSString) () transparent: #t)"));
    }

    #[test]
    fn object_return_wrapped_to_exact_type_via_registry_wrap() {
        // An object-returning method wraps through the class-aware `wrap`, which
        // (030 registry) resolves the exact bound type — not a fixed handle type.
        let cls = cls_with(
            "NSArray",
            vec![make_method(
                "firstObject",
                false,
                false,
                ty(TypeRefKind::Id),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains("(wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-first-object))"));
        // surfaces present for the instance method
        assert!(out.contains("(defmethod {first-object NSArray}"));
        assert!(out.contains("(g:defmethod (first-object (o NSArray))"));
    }

    // --- error model (ADR-0006, leaf 050) --------------------------------

    fn error_selectors(sel: &str) -> HashSet<String> {
        let mut s = HashSet::new();
        s.insert(sel.to_string());
        s
    }

    /// `-writeToFile:error:` → `(values BOOL nserror)`: trailing `NSError**`
    /// param dropped from arity, the `-e` crossing, `call-with-nserror-out`.
    #[test]
    fn nserror_method_emits_values_result_error() {
        let mut m = make_method(
            "writeToFile:error:",
            false,
            false,
            ty(TypeRefKind::Primitive {
                name: "bool".into(),
            }),
        );
        m.params = vec![
            param("path", TypeRefKind::Id),
            param("error", TypeRefKind::Pointer),
        ];
        let cls = cls_with("NSData", vec![m], vec![]);
        let errs = error_selectors("writeToFile:error:");
        let out = generate_class_file_with_parent(
            &cls,
            "Foundation",
            &ParentRef::RuntimeRoot,
            &errs,
            &ProtocolRegistry::new(),
        )
        .0;

        // The `-e` crossing: visible (pointer void) arg + trailing NSError** cell.
        assert!(out.contains(
            "(define-c-lambda %msg-p-pp->b-e ((pointer void) (pointer void) (pointer void) (pointer (pointer void))) bool"
        ), "missing -e crossing decl:\n{out}");
        // The body casts the trailing actual to id* (NOT NSError**: ADR-0021
        // includes no Foundation header, so NSError is undeclared; id* is the
        // ABI-identical, always-in-scope spelling — leaf 100/050).
        assert!(out.contains(
            "((BOOL (*)(id, SEL, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, (id*)___arg4)"
        ), "missing id* cast body:\n{out}");
        // The proc drops the trailing error param (visible arity = self + path)
        // and returns two values via the runtime helper.
        assert!(
            out.contains("(define (nsdata-write-to-file-error self path)"),
            "proc arity:\n{out}"
        );
        assert!(
            out.contains("(call-with-nserror-out"),
            "no call-with-nserror-out:\n{out}"
        );
        assert!(
            out.contains("(lambda (%err-cell)"),
            "no err-cell thunk:\n{out}"
        );
        assert!(out.contains(
            "(%msg-p-pp->b-e (NSObject-ptr self) %sel-nsdata-write-to-file-error (->ptr path) %err-cell)"
        ), "crossing call site:\n{out}");
        // The selector is cached on the full, real selector.
        assert!(out.contains(
            "(define %sel-nsdata-write-to-file-error (sel_registerName \"writeToFile:error:\"))"
        ), "selector cache:\n{out}");
        // The `{}` MOP surface forwards the visible-arity proc (returns two
        // values too); the arg-taking method gets no `:std/generic` surface.
        assert!(out.contains(
            "(defmethod {write-to-file-error NSData} (lambda (self path) (nsdata-write-to-file-error self path)))"
        ), "{{}} surface:\n{out}");
        assert!(
            !out.contains("(g:defmethod (write-to-file-error "),
            "no generic surface for arg-taking method:\n{out}"
        );
    }

    /// The same trailing-pointer shape, but NOT an enrichment error method,
    /// still defers (raw pointers are unbindable) — no proc, no crossing.
    #[test]
    fn non_error_trailing_pointer_method_deferred() {
        let mut m = make_method("getBytes:error:", false, false, ty(TypeRefKind::Id));
        m.params = vec![
            param("buffer", TypeRefKind::Id),
            param("error", TypeRefKind::Pointer),
        ];
        let cls = cls_with("NSData", vec![m], vec![]);
        // Empty error set ⇒ not error-routed ⇒ deferred.
        let out = generate_class_file_with_parent(
            &cls,
            "Foundation",
            &ParentRef::RuntimeRoot,
            &HashSet::new(),
            &ProtocolRegistry::new(),
        )
        .0;
        assert!(
            !out.contains("nsdata-get-bytes-error"),
            "should be deferred:\n{out}"
        );
        assert!(!out.contains("-e ("), "no -e crossing:\n{out}");
    }

    /// An object-returning NSError method wraps the result inside the thunk; the
    /// error half comes from `call-with-nserror-out`.
    #[test]
    fn nserror_object_return_wraps_result_inside_thunk() {
        let mut m = make_method(
            "dataWithContentsOfURL:error:",
            false,
            false,
            ty(TypeRefKind::Id),
        );
        m.params = vec![
            param("url", TypeRefKind::Id),
            param("error", TypeRefKind::Pointer),
        ];
        let cls = cls_with("NSData", vec![m], vec![]);
        let errs = error_selectors("dataWithContentsOfURL:error:");
        let out = generate_class_file_with_parent(
            &cls,
            "Foundation",
            &ParentRef::RuntimeRoot,
            &errs,
            &ProtocolRegistry::new(),
        )
        .0;
        // Object return ⇒ the crossing call is wrapped; that wrapped value is the
        // thunk's single result, which call-with-nserror-out pairs with the error.
        assert!(out.contains(
            "(wrap (%msg-p-pp->p-e (NSObject-ptr self) %sel-nsdata-data-with-contents-of-url-error (->ptr url) %err-cell))"
        ), "wrapped object result inside thunk:\n{out}");
    }

    // --- manifest class graph (ADR-0020, leaf 030) -----------------------

    #[test]
    fn defclass_derives_from_runtime_root_and_registers() {
        // A class whose super is NSObject roots its defclass on the runtime root
        // and inherits the `ptr` slot from it (no own slots).
        let cls = cls_with("NSView", vec![], vec![]);
        let out = generate_class_file(&cls, "AppKit");
        assert!(out.contains(";; --- Class graph (ADR-0020) ---"));
        assert!(out.contains("(defclass (NSView NSObject) () transparent: #t)"));
        // Registration carries the ObjC name + ObjC super name (wrap boundary +
        // subclassing bridge). cls_with leaves superclass empty ⇒ "".
        assert!(out.contains(
            "(register-objc-class! (lambda (p) (make-NSView ptr: p)) NSView::t \"NSView\" \"\")"
        ));
        // The runtime root needs no extra import (it lives in the runtime module).
        assert!(!out.contains(":gerbil-bindings/appkit/nsobject"));
    }

    #[test]
    fn defclass_records_objc_superclass_name() {
        // The registration's third field is the real ObjC super name, taken
        // verbatim from the IR — even when the Gerbil parent resolves elsewhere.
        let mut cls = cls_with("NSButton", vec![], vec![]);
        cls.superclass = "NSControl".into();
        let out = generate_class_file_with_parent(
            &cls,
            "AppKit",
            &ParentRef::Local("NSControl".into()),
            &HashSet::new(),
            &ProtocolRegistry::new(),
        );
        assert!(out
            .0
            .contains("(defclass (NSButton NSControl) () transparent: #t)"));
        assert!(out.0.contains(
            "(register-objc-class! (lambda (p) (make-NSButton ptr: p)) NSButton::t \"NSButton\" \"NSControl\")"
        ));
        // A local parent imports its sibling module under the current framework.
        assert!(out.0.contains(":gerbil-bindings/appkit/nscontrol"));
    }

    #[test]
    fn cross_framework_parent_imports_owning_module() {
        let mut cls = cls_with("NSTextStorage", vec![], vec![]);
        cls.superclass = "NSMutableAttributedString".into();
        let parent = ParentRef::CrossFramework {
            name: "NSMutableAttributedString".into(),
            fw_low: "foundation".into(),
        };
        let out = generate_class_file_with_parent(
            &cls,
            "AppKit",
            &parent,
            &HashSet::new(),
            &ProtocolRegistry::new(),
        );
        assert!(out
            .0
            .contains("(defclass (NSTextStorage NSMutableAttributedString) () transparent: #t)"));
        // Imported from its OWNING framework, not AppKit.
        assert!(out
            .0
            .contains(":gerbil-bindings/foundation/nsmutableattributedstring"));
    }

    #[test]
    fn bare_module_is_defclass_only() {
        let (out, exports) = generate_bare_module("Mid", "Widgets");
        assert!(out.contains("synthesized bare class-graph node"));
        assert!(out.contains("(defclass (Mid NSObject) () transparent: #t)"));
        assert!(out
            .contains("(register-objc-class! (lambda (p) (make-Mid ptr: p)) Mid::t \"Mid\" \"\")"));
        // No proc surface, no FFI block.
        assert!(!out.contains("begin-ffi"));
        assert!(!out.contains("(define ("));
        assert_eq!(exports, vec!["Mid".to_string(), "Mid?".to_string()]);
    }

    #[test]
    fn nsobject_itself_emits_no_defclass() {
        // The runtime owns NSObject; the emitter never re-defines it even if it
        // appears in the IR's class list.
        let cls = cls_with("NSObject", vec![], vec![]);
        let out = generate_class_file(&cls, "Foundation");
        assert!(!out.contains("(defclass (NSObject"));
        assert!(!out.contains("register-objc-class! NSObject"));
        // ...and does not export the runtime-owned identifiers.
        let exports = class_exports(&cls);
        assert!(!exports.contains(&"NSObject".to_string()));
        assert!(!exports.contains(&"NSObject?".to_string()));
    }

    // --- Charter #4: Swift-native method routing (ADR-0030) ------------------

    use apianyware_macos_types::ir::SwiftFnInfo;

    /// A Swift-native (`objc_exposed == false`) instance method on a class.
    fn swift_method(sel: &str, ret: TypeRef) -> Method {
        let mut m = make_method(sel, false, false, ret);
        m.objc_exposed = false;
        m.swift_fn = Some(SwiftFnInfo::default());
        m
    }

    #[test]
    fn swift_native_method_routes_to_trampoline_not_msgsend() {
        // A class carrying one ObjC method + one Swift-native method: the ObjC one
        // binds via objc_msgSend (the %msg- crossing); the Swift-native one routes to
        // the receiver-handle trampoline section (the %swift- crossing against the
        // content-addressed libAPIAnywareGerbil entry), NEVER objc_msgSend (charter #4).
        let objc = make_method("title", false, false, ty(TypeRefKind::Id));
        let swiftm = swift_method("describe", ty(TypeRefKind::Primitive { name: "int64".into() }));
        let cls = cls_with("Widget", vec![objc, swiftm], vec![]);
        let out = generate_class_file(&cls, "TestKit");

        // The Swift-native method gets a %swift- crossing + a trampoline define, not a
        // msgSend crossing.
        assert!(
            out.contains("(define-c-lambda %swift-widget-describe ((pointer void)) int64 \"aw_gerbil_swift_m_TestKit_Widget_describe\")"),
            "{out}"
        );
        assert!(
            out.contains("(%swift-widget-describe (->ptr self))"),
            "{out}"
        );
        // It must NOT route through msgSend.
        assert!(
            !out.contains("%msg-widget-describe"),
            "Swift-native method must not bind via objc_msgSend:\n{out}"
        );
        // The ObjC method still routes through msgSend (its proc reads the cached SEL
        // and calls a shared-signature %msg- crossing over (NSObject-ptr self)).
        assert!(out.contains("(define (widget-title self)"), "{out}");
        assert!(out.contains("%sel-widget-title"), "{out}");
        // The section comment is present.
        assert!(out.contains("Swift-native methods (receiver-handle trampolines"), "{out}");
        // The trampoline binding name is exported.
        let (_, exports) = generate_class_file_with_parent(
            &cls,
            "TestKit",
            &ParentRef::RuntimeRoot,
            &HashSet::new(),
            &ProtocolRegistry::new(),
        );
        assert!(exports.contains(&"widget-describe".to_string()), "{exports:?}");
    }

    /// A population-B value struct (IndexSet-shaped) emits a struct module with an
    /// init producer (raw handle, no wrap) + a method, no defclass/msgSend substrate.
    #[test]
    fn population_b_struct_emits_init_producer_and_method() {
        let mut init = make_method("init(integer:)", false, true, ty(TypeRefKind::Class {
            name: "NSIndexSet".into(),
            framework: Some("Foundation".into()),
            params: vec![],
        }));
        init.objc_exposed = false;
        init.params = vec![param("integer", TypeRefKind::Primitive { name: "int64".into() })];
        init.swift_fn = Some(SwiftFnInfo::default());

        let mut contains = make_method("contains(_:)", false, false, ty(TypeRefKind::Primitive {
            name: "bool".into(),
        }));
        contains.objc_exposed = false;
        contains.params = vec![param("_", TypeRefKind::Primitive { name: "int64".into() })];
        contains.swift_fn = Some(SwiftFnInfo::default());

        let st = Struct {
            name: "IndexSet".into(),
            fields: vec![],
            methods: vec![init, contains],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
        };
        let (out, exports) = generate_struct_file(&st, "Foundation").expect("struct has bindings");
        // No class graph / msgSend substrate.
        assert!(!out.contains("defclass"), "{out}");
        assert!(!out.contains("objc_getClass"), "{out}");
        // Init producer: a value owner hands back the raw handle (no wrap).
        assert!(out.contains("(define-c-lambda %swift-make-indexset-integer (int64) (pointer void) \"aw_gerbil_swift_init_Foundation_IndexSet\")"), "{out}");
        assert!(out.contains("(%swift-make-indexset-integer integer)"), "{out}");
        assert!(!out.contains("(wrap (%swift-make-indexset-integer"), "value init must not wrap:\n{out}");
        // Method: receiver via (->ptr self), numericCast on the int arg.
        assert!(out.contains("(%swift-indexset-contains (->ptr self) arg0)"), "{out}");
        assert!(exports.contains(&"make-indexset-integer".to_string()), "{exports:?}");
        assert!(exports.contains(&"indexset-contains".to_string()), "{exports:?}");
    }
}
