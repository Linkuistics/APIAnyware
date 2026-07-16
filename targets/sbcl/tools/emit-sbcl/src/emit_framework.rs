//! Top-level SBCL framework emission — the orchestrator (leaf 040/060).
//!
//! Wires the construct emitters ([`crate::class_graph`] / [`crate::emit_class`] /
//! [`crate::emit_generics`] / [`crate::emit_protocol`] / [`crate::emit_enums`] /
//! [`crate::emit_constants`] / [`crate::emit_functions`]) into a complete
//! per-framework binding tree, plus the **facade** that makes it loadable.
//!
//! ## On-disk layout (the gerbil on-disk symmetry, CL-idiomatic)
//!
//! Under `generated_subdir = "generated"`, one **facade** file per framework next
//! to a per-framework directory of construct files — the SBCL analogue of gerbil's
//! `<fw>.ss` facade next to `<fw>/`:
//!
//! ```text
//! generated/
//!   foundation.lisp            ← facade: (in-package …) + the ns: export surface
//!   foundation/
//!     generics.lisp            ← one (defgeneric ns:<sel> …) per selector
//!     nsstring.lisp            ← NSString: defclass + dispatch + register-*
//!     nsarray.lisp             ← one file per class (gerbil per-class symmetry)
//!     …                        ← (+ a file per synthesized bare intermediate node)
//!     protocols.lisp           ← protocol conformance surfaces (contract §3.5)
//!     enums.lisp               ← (defconstant ns:… …) per enum value
//!     constants.lisp           ← direct reads + the Swift-native constant residual
//!     functions.lisp           ← direct (defun ns:…) + the Swift-native fn residual
//! ```
//!
//! A construct file is written only when the framework has that construct family;
//! the facade is always written (it carries the package surface even for an empty
//! framework). One `generics.lisp` per framework (not per class) holds the
//! `defgeneric` set — a CL package unifies one generic per selector across the
//! class files, so each `<class>.lisp` carries only `defclass` + `defmethod` (no
//! redundant generic re-declaration, no sharding; ADR-0034 §3).
//!
//! ## The facade IS the per-framework re-export (the CL form of gerbil's facade)
//!
//! Gerbil's facade re-exports per-class submodule bindings so an app can import a
//! whole framework. CL has **one** `ns:` package (the contract surface, §3.1), so
//! there is nothing per-framework to *re-export* — the analogue is the package's
//! **export list**. The facade interns + exports every bound `ns:` symbol this
//! framework contributes (classes, generics, enum/constant/function bindings, the
//! residual bindings). This is load-bearing, not cosmetic: the construct files
//! spell bound names with a **single** colon (`ns:object-at-index`, the contract's
//! named surface), which the reader accepts only for symbols already **external**
//! in `ns`. So the facade — listing them as `ns::…` (double colon interns without
//! requiring export) — must load **before** its sibling construct files
//! (the framework's ASDF system, runtime leaf 050, sequences this). The
//! `eval-when` makes the exports visible at compile time too, so a sibling
//! compiled in the same session sees them external.
//!
//! Gerbil's class/protocol **collision-rename** has no SBCL analogue: there are no
//! per-construct constructors to collide (the delegate pattern is the CLOS subclass
//! macros, not a `make-<proto>`, [`crate::emit_protocol`]), and two contributions
//! of one name in the single `ns:` package are the *same symbol* — `export` is
//! idempotent. The one residue is a post-kebab **arity** clash between two
//! selectors ([`crate::emit_generics::generic_arity_conflicts`]): the conflicting
//! residual `defmethod` is **dropped** so every `defmethod` stays congruent with its
//! `defgeneric` (ADR-0042), and the clash is surfaced (a `WARN`) for review.
//!
//! ## The 040 → 050 seam fixed here
//!
//! - **`apianyware-sbcl-impl`** ([`IMPL_PACKAGE`]) — the runtime/impl package every
//!   generated file is read in (`(:use :cl sb-mop)` + the `aw-*` helpers + the
//!   `ns` package). Runtime-owned (leaf 050); the emitter writes the
//!   `(in-package …)` header referencing it.
//! - The **load order** (facade before construct files; superclass `defclass`
//!   before subclass) the framework's ASDF system must honour — the facade header
//!   states it.
//!
//! ## The method/init Swift-native residual (leaf `045`)
//!
//! A **class** owner's Swift-native method/init residual (part of the §6d `576 init +
//! 554 method`) is wired here, after the direct ObjC dispatch, by
//! [`crate::emit_generics::emit_swift_native_residual`]: each bindable instance method
//! becomes a receiver-specialized `(defmethod ns:<base-labels> ((self ns:<owner>) …) …)`
//! whose generic [`collect_generics`] folds into `generics.lisp` (the defgeneric
//! lockstep), and each bindable initializer becomes a `(defun ns:make-<owner>… )`
//! constructor (a class owner `aw-wrap`s the returned id; not §3.3's `make-instance`
//! path — a Swift-native init calls `Owner(labels:)` through the trampoline, not ObjC
//! `alloc`/`init`). The **fn/const** residual is bound alongside (its `render_binding`
//! returns complete drop-in forms).
//!
//! ## The value-struct (population-B) residual (ADR-0042, leaf 090)
//!
//! A **value struct** with bindable residual is projected to a plain CLOS class on the
//! runtime `ns:value-struct` root, emitted into a per-framework `structs.lisp`
//! ([`crate::emit_struct`]): a `defclass` + its `defmethod`s (receiver via the same
//! `(aw-ptr self)` as a class owner — the box rides the `ptr` slot) + box-wrapping
//! `make-<struct>` constructors. Its method generics fold into `generics.lisp` like a
//! class owner's; the class + constructor symbols export through the facade.

use std::collections::BTreeSet;
use std::io;
use std::path::Path;

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::enrichment::class_error_selectors;
use apianyware_emit::target_emitter::{EmitResult, TargetEmitter, TargetInfo};
use apianyware_emit::write_line;
use apianyware_types::ir::{Class, Framework};

use crate::class_graph::{build_class_graph, ClassGraph, ClassRegistry, ParentRef};
use crate::emit_class::{emit_bare_node, emit_class_forms};
use crate::emit_constants::{constant_symbols, generate_constants_file};
use crate::emit_enums::{defined_enum_symbols, generate_enums_file};
use crate::emit_functions::{function_symbols, generate_functions_file};
use crate::emit_generics::{
    collect_generics, emit_class_dispatch, emit_swift_native_residual, generic_arity_conflicts,
    generic_arity_index, render_generics, GenericDecl,
};
use crate::emit_protocol::{has_surface, protocol_generic_decls, render_protocol};
use crate::emit_struct::generate_struct_file;
use crate::naming::{class_name, PACKAGE};
use crate::protocol_registry::ProtocolRegistry;
use crate::trampoline::{
    class_residual_inits, classify_constant, classify_function, value_struct_names, FnDisposition,
};

/// The runtime/impl Common Lisp package every generated binding file is read in:
/// it `(:use :cl sb-mop)`, owns the `aw-*` helpers ([`crate::emit_generics`]) and
/// the `register-objc-*` forms, and has the `ns` package available so bound names
/// resolve. Runtime-owned (leaf 050); the emitter only references it in the
/// per-file `(in-package …)` header.
pub const IMPL_PACKAGE: &str = "apianyware-sbcl-impl";

pub const SBCL_TARGET_INFO: TargetInfo = TargetInfo {
    id: "sbcl",
    display_name: "SBCL",
    // SBCL imposes no on-disk path constraint on the binding's package (unlike
    // chez, whose `(apianyware <fw> <cls>)` library name resolves to a libdir
    // path, hence its `apianyware` subdir). The `ns:` package is loaded by the
    // runtime/ASDF system (leaf 050) pointing at this directory explicitly, so
    // the conventional `generated` subdir is used.
    generated_subdir: "generated",
};

/// The SBCL emitter.
///
/// Carries the cross-framework [`ClassRegistry`] (resolving metaclass-graph parents
/// owned by another framework, ADR-0034 §1) and [`ProtocolRegistry`] (the
/// conformance closures backing conformed-protocol method flattening,
/// [`crate::emit_generics`]). Both are empty in [`SbclEmitter::new`] — same-framework
/// parents still resolve from each framework's own class set and flattening degrades
/// to own-methods-only — so the registry instance backing `--list-targets`/lookups
/// works unconfigured. The `generate` pre-pass builds the global registries over all
/// loaded frameworks and swaps in a configured emitter via
/// [`SbclEmitter::with_registries`] (the gerbil whole-program shape; SBCL needs no
/// `write_global_generics_module` — a CL package unifies generics for free).
#[derive(Default)]
pub struct SbclEmitter {
    class_registry: ClassRegistry,
    protocol_registry: ProtocolRegistry,
}

impl SbclEmitter {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn with_registries(
        class_registry: ClassRegistry,
        protocol_registry: ProtocolRegistry,
    ) -> Self {
        Self {
            class_registry,
            protocol_registry,
        }
    }
}

impl TargetEmitter for SbclEmitter {
    fn target_info(&self) -> &TargetInfo {
        &SBCL_TARGET_INFO
    }

    fn emit_framework(&self, framework: &Framework, output_dir: &Path) -> io::Result<EmitResult> {
        emit_framework(
            framework,
            output_dir,
            &self.class_registry,
            &self.protocol_registry,
        )
    }
}

/// Accumulates the bound `ns:` symbols a framework contributes — the facade's
/// export surface (the CL form of gerbil's `SubModule` re-export collection). Names
/// are stored **unqualified** (`object-at-index`, not `ns:object-at-index`);
/// [`Self::render_export_form`] writes them as `ns::…`.
#[derive(Default)]
struct ExportSurface {
    names: BTreeSet<String>,
}

impl ExportSurface {
    /// Add one already-unqualified `ns:` symbol name.
    fn add(&mut self, unqualified: impl Into<String>) {
        self.names.insert(unqualified.into());
    }

    /// Add a possibly-`ns:`-qualified symbol, stripping the package prefix.
    fn add_qualified(&mut self, sym: &str) {
        self.add(unqualify(sym));
    }

    /// Render the facade's export form: an `eval-when` so the symbols are external
    /// at compile time too (a sibling construct file compiled in the same session
    /// reads its single-colon `ns:` references against them), interning each via the
    /// double-colon `ns::` spelling and exporting it from the `ns` package.
    fn render_export_form(&self, w: &mut CodeWriter) {
        w.line("(eval-when (:compile-toplevel :load-toplevel :execute)");
        if self.names.is_empty() {
            write_line!(w, "  (export '() (find-package '#:{PACKAGE})))");
            return;
        }
        w.line("  (export");
        w.line("   '(");
        for n in &self.names {
            write_line!(w, "     {PACKAGE}::{n}");
        }
        write_line!(w, "     )");
        write_line!(w, "   (find-package '#:{PACKAGE})))");
    }
}

/// Strip the `ns:` package prefix from a qualified symbol (`ns:object-at-index` →
/// `object-at-index`); a name already unqualified is returned unchanged.
fn unqualify(sym: &str) -> &str {
    sym.strip_prefix(&format!("{PACKAGE}:")).unwrap_or(sym)
}

pub fn emit_framework(
    fw: &Framework,
    output_dir: &Path,
    registry: &ClassRegistry,
    protocols: &ProtocolRegistry,
) -> io::Result<EmitResult> {
    let fw_low = fw.name.to_ascii_lowercase();
    let mut exports = ExportSurface::default();
    let mut files_written = 0usize;

    std::fs::create_dir_all(output_dir)?;
    let fw_dir = output_dir.join(&fw_low);

    // The reified metaclass graph (ADR-0034 §1): each class's resolved parent + any
    // synthesized bare intermediate nodes.
    let graph = build_class_graph(fw, registry);

    // The framework's global generic set (one defgeneric per selector across its
    // classes, conformed-protocol flattening folded in). Shared by: the classes
    // file's defgeneric block, the protocol files' dedup, and the export surface.
    let generics = collect_generics(&[fw], protocols);
    let global_generic_names: BTreeSet<String> = generics.iter().map(|d| d.name.clone()).collect();
    // The canonical (generic → arity) map: emission drops any residual `defmethod` whose
    // arity disagrees (a post-kebab selector clash) so every defmethod stays congruent
    // with its defgeneric (ADR-0042).
    let generic_arity = generic_arity_index(&generics);

    // A post-kebab arity clash is a CL congruence conflict: the conflicting residual
    // `defmethod` is dropped from emission (the trampoline + §6d count stay), surfaced
    // here (not silenced) so a future framework that trips it is reviewed.
    let conflicts = generic_arity_conflicts(&[fw], protocols);
    if !conflicts.is_empty() {
        eprintln!(
            "WARN sbcl[{}]: generic arity conflicts (post-kebab), conflicting defmethod dropped — review: {}",
            fw.name,
            conflicts.join(", ")
        );
    }

    // --- generics.lisp + one file per class (the gerbil per-class on-disk shape) --
    // generics.lisp holds one `defgeneric` per selector across the framework's classes
    // AND value structs (a CL package unifies them, so it loads once before any class /
    // struct file's `defmethod` extends it — ADR-0034 §2/§3); each `<class>.lisp` then
    // carries only that class's `defclass` + dispatch. Written whenever the framework
    // contributes any generic — a struct-only framework (no classes) still needs it
    // (ADR-0042).
    let ordered = ordered_classes(fw, &graph);
    if !generics.is_empty() {
        std::fs::create_dir_all(&fw_dir)?;
        std::fs::write(
            fw_dir.join("generics.lisp"),
            render_generics_file(&fw.name, &generics),
        )?;
        files_written += 1;
    }
    if !fw.classes.is_empty() || !graph.synthesized.is_empty() {
        std::fs::create_dir_all(&fw_dir)?;

        // Synthesized bare intermediate nodes (root on ns:ns-object) and collected
        // classes, each its own file. Superclass-before-subclass ordering is the
        // ASDF system's job (the facade states it); within a file the class is
        // defined before its own dispatch.
        for name in &graph.synthesized {
            std::fs::write(
                fw_dir.join(format!("{}.lisp", class_file_stem(name))),
                render_bare_node_file(&fw.name, name),
            )?;
            files_written += 1;
        }
        for cls in &ordered {
            let parent = graph
                .parents
                .get(&cls.name)
                .unwrap_or(&ParentRef::RuntimeRoot);
            std::fs::write(
                fw_dir.join(format!("{}.lisp", class_file_stem(&cls.name))),
                render_class_file(fw, cls, parent, protocols, &generic_arity),
            )?;
            files_written += 1;
        }
    }
    // Export surface: every class symbol (collected + synthesized) and every generic.
    for cls in &fw.classes {
        exports.add(class_name(&cls.name));
    }
    for name in &graph.synthesized {
        exports.add(class_name(name));
    }
    for d in &generics {
        exports.add_qualified(&d.name);
    }
    // 045: the Swift-native residual method generics ride the `generics` set above; the
    // init constructors (`ns:make-<owner>`) are not generics, so export them explicitly.
    for cls in &fw.classes {
        for t in class_residual_inits(&fw.name, &cls.name, &cls.methods) {
            exports.add_qualified(&t.binding_symbol());
        }
    }

    // --- protocols.lisp: conformance surfaces ------------------------------------
    let surface_protocols: Vec<_> = fw.protocols.iter().filter(|p| has_surface(p)).collect();
    if !surface_protocols.is_empty() {
        let mut w = CodeWriter::new();
        emit_file_header(
            &mut w,
            &fw.name,
            "protocol conformance surfaces (contract §3.5)",
        );
        for proto in &surface_protocols {
            // Protocol-contributed generics that are NOT already on the class graph
            // (the delegate-only selectors) must also enter the package surface.
            for d in protocol_generic_decls(proto, &global_generic_names) {
                exports.add_qualified(&d.name);
            }
            let body = render_protocol(proto, &fw.name, &global_generic_names);
            w.line(body.trim_end());
        }
        std::fs::create_dir_all(&fw_dir)?;
        std::fs::write(fw_dir.join("protocols.lisp"), with_in_package(w.finish()))?;
        files_written += 1;
    }

    // --- enums.lisp --------------------------------------------------------------
    let enums_emitted = !fw.enums.is_empty();
    if enums_emitted {
        let body = generate_enums_file(&fw.enums, &fw.name);
        std::fs::create_dir_all(&fw_dir)?;
        std::fs::write(fw_dir.join("enums.lisp"), with_in_package(body))?;
        files_written += 1;
        for sym in defined_enum_symbols(&fw.enums) {
            exports.add(sym);
        }
    }

    // --- constants.lisp: direct reads + the Swift-native constant residual --------
    if !fw.constants.is_empty() {
        let mut body = generate_constants_file(&fw.constants, &fw.name);
        let residual = render_constant_residual(fw, &mut exports);
        if !residual.is_empty() {
            body.push_str("\n;; --- Swift-native constants (trampoline residual, ADR-0038) ---\n");
            body.push_str(&residual);
        }
        std::fs::create_dir_all(&fw_dir)?;
        std::fs::write(fw_dir.join("constants.lisp"), with_in_package(body))?;
        files_written += 1;
        for sym in constant_symbols(&fw.constants) {
            exports.add(sym);
        }
    }

    // --- functions.lisp: direct (defun …) + the Swift-native function residual ----
    if !fw.functions.is_empty() {
        let mut body = generate_functions_file(&fw.functions, &fw.name);
        let residual = render_function_residual(fw, &mut exports);
        if !residual.is_empty() {
            body.push_str("\n;; --- Swift-native functions (trampoline residual, ADR-0038) ---\n");
            body.push_str(&residual);
        }
        std::fs::create_dir_all(&fw_dir)?;
        std::fs::write(fw_dir.join("functions.lisp"), with_in_package(body))?;
        files_written += 1;
        for sym in function_symbols(&fw.functions, &fw.name) {
            exports.add(sym);
        }
    }

    // --- structs.lisp: the population-B value-struct residual (ADR-0042) ----------
    // One file per framework (gerbil's per-struct modules collapsed to one), holding a
    // plain CLOS class per bindable value struct + its `defmethod`s + box-wrapping
    // constructors. Residual-gated by the loader (loaded like functions.lisp): a value
    // struct is entirely Swift-native. The method generics already rode `generics.lisp`
    // (collect_generics folds them in); only the class + constructor symbols export here.
    {
        let mut w = CodeWriter::new();
        emit_file_header(
            &mut w,
            &fw.name,
            "Swift-native value-struct residual (ADR-0042)",
        );
        w.blank_line();
        let mut any = false;
        for st in &fw.structs {
            if let Some((forms, syms)) = generate_struct_file(st, &fw.name, &generic_arity) {
                any = true;
                w.line(forms.trim_end());
                for s in syms {
                    exports.add_qualified(&s);
                }
            }
        }
        if any {
            std::fs::create_dir_all(&fw_dir)?;
            std::fs::write(fw_dir.join("structs.lisp"), with_in_package(w.finish()))?;
            files_written += 1;
        }
    }

    // --- the facade: <fw_low>.lisp -----------------------------------------------
    let facade = render_facade(&fw.name, &fw_low, &exports, files_written);
    std::fs::write(output_dir.join(format!("{fw_low}.lisp")), facade)?;
    files_written += 1;

    let constants_direct = fw.constants.iter().filter(|c| c.objc_exposed).count();
    let functions_direct = fw.functions.iter().filter(|f| f.objc_exposed).count();
    Ok(EmitResult {
        files_written,
        classes_emitted: fw.classes.len(),
        protocols_emitted: surface_protocols.len(),
        enums_emitted: if enums_emitted { fw.enums.len() } else { 0 },
        functions_emitted: functions_direct,
        constants_emitted: constants_direct,
    })
}

/// The `generics.lisp` body: one `(defgeneric ns:<sel> …)` per selector across the
/// framework's classes (conformed-protocol flattening folded in). Loads once,
/// before any class file's `defmethod` extends it.
fn render_generics_file(framework: &str, generics: &[GenericDecl]) -> String {
    let mut w = CodeWriter::new();
    emit_file_header(
        &mut w,
        framework,
        "generics — one defgeneric per selector (ADR-0034 §2)",
    );
    write_line!(w, "(in-package #:{IMPL_PACKAGE})");
    w.blank_line();
    w.line(render_generics(generics).trim_end());
    w.finish()
}

/// One collected class's file: its `defclass` (deriving from the resolved parent) +
/// baked `register-objc-class`, then its dispatch (`defmethod`s specialized on the
/// receiver + `register-objc-init`). The class is defined before its own dispatch;
/// the parent's file and the generics file load first (the facade's load order).
fn render_class_file(
    fw: &Framework,
    cls: &Class,
    parent: &ParentRef,
    protocols: &ProtocolRegistry,
    generic_arity: &std::collections::BTreeMap<String, usize>,
) -> String {
    let mut w = CodeWriter::new();
    emit_file_header(
        &mut w,
        &fw.name,
        &format!("{} — class + dispatch (ADR-0034)", cls.name),
    );
    write_line!(w, "(in-package #:{IMPL_PACKAGE})");
    w.blank_line();
    emit_class_forms(&mut w, cls, &fw.name, parent, &[]);
    let error_selectors = class_error_selectors(fw.enrichment.as_ref(), &cls.name);
    emit_class_dispatch(&mut w, cls, &fw.name, &error_selectors, protocols);
    // The Swift-native method/init residual (leaf 045), after the direct ObjC dispatch.
    emit_swift_native_residual(
        &mut w,
        cls,
        &fw.name,
        &error_selectors,
        protocols,
        generic_arity,
    );
    w.finish()
}

/// A synthesized bare intermediate node's file (a `defclass` referenced as a
/// superclass but not itself collected; roots on `ns:ns-object`).
fn render_bare_node_file(framework: &str, name: &str) -> String {
    let mut w = CodeWriter::new();
    emit_file_header(
        &mut w,
        framework,
        &format!("{name} — synthesized bare class-graph node"),
    );
    write_line!(w, "(in-package #:{IMPL_PACKAGE})");
    w.blank_line();
    emit_bare_node(&mut w, name, framework);
    w.finish()
}

/// The on-disk file stem for a class (gerbil-symmetric: the lowercased ObjC name,
/// `NSString` → `nsstring`), distinct from the hyphenated CLOS symbol
/// (`ns:ns-string`). Class names are unique within a framework, so the lowercased
/// stem is too.
fn class_file_stem(class_name: &str) -> String {
    class_name.to_ascii_lowercase()
}

/// Render the Swift-native **function** residual bindings (`objc_exposed == false`),
/// adding each bound symbol to the export surface. Deferred (unbindable) functions
/// are skipped — the global trampoline pass records + counts them.
fn render_function_residual(fw: &Framework, exports: &mut ExportSurface) -> String {
    let residual: Vec<_> = fw
        .functions
        .iter()
        .filter(|f| !f.objc_exposed)
        .cloned()
        .collect();
    if residual.is_empty() {
        return String::new();
    }
    let value_structs = value_struct_names(&fw.structs);
    let mut out = String::new();
    for f in &residual {
        if let FnDisposition::Trampoline(t) =
            classify_function(&fw.name, f, &residual, &value_structs)
        {
            exports.add_qualified(&t.binding_symbol);
            out.push_str(&t.render_binding());
            out.push('\n');
        }
    }
    out
}

/// Render the Swift-native **constant** residual bindings (`objc_exposed == false`),
/// adding each bound symbol to the export surface. Constants never defer.
fn render_constant_residual(fw: &Framework, exports: &mut ExportSurface) -> String {
    let mut out = String::new();
    for c in fw.constants.iter().filter(|c| !c.objc_exposed) {
        let t = classify_constant(&fw.name, c);
        exports.add_qualified(&t.binding_symbol);
        out.push_str(&t.render_binding());
        out.push('\n');
    }
    out
}

/// The per-framework facade: the package surface + the load-order contract.
fn render_facade(
    framework: &str,
    fw_low: &str,
    exports: &ExportSurface,
    sibling_count: usize,
) -> String {
    let mut w = CodeWriter::new();
    write_line!(
        w,
        ";;; Generated {} bindings — facade / package surface — do not edit",
        framework
    );
    w.line(";;;");
    w.line(";;; The framework's ASDF system (runtime leaf 050) loads this facade FIRST —");
    w.line(";;; it interns + exports every bound ns: symbol so the construct files'");
    w.line(";;; single-colon references read — then generics.lisp, then the per-class");
    write_line!(
        w,
        ";;; files superclass-before-subclass, then protocols/enums/constants/functions"
    );
    write_line!(w, ";;; ({sibling_count} sibling file(s) under {fw_low}/).");
    write_line!(w, "(in-package #:{IMPL_PACKAGE})");
    w.blank_line();
    exports.render_export_form(&mut w);
    w.finish()
}

/// Prepend the impl-package `(in-package …)` header to a construct emitter's body
/// (the per-module emitters produce package-agnostic forms; the orchestrator owns
/// the header, per the 040 module docs).
fn with_in_package(body: String) -> String {
    format!("(in-package #:{IMPL_PACKAGE})\n\n{body}")
}

/// A two-line `;;;` header for a construct file.
fn emit_file_header(w: &mut CodeWriter, framework: &str, what: &str) {
    write_line!(
        w,
        ";;; Generated {} bindings — {} — do not edit",
        framework,
        what
    );
}

/// Order a framework's collected classes superclass-before-subclass (a stable DFS
/// post-order over the same-framework `Local` parent edges). Cross-framework and
/// runtime-root parents impose no local ordering; a `Local` parent that is a
/// synthesized bare node (not itself collected) is emitted ahead of all collected
/// classes, so it needs no edge here. Ties break by IR order (the DFS visits in IR
/// order), keeping goldens deterministic.
fn ordered_classes<'a>(fw: &'a Framework, graph: &ClassGraph) -> Vec<&'a Class> {
    use std::collections::HashMap;
    let index: HashMap<&str, usize> = fw
        .classes
        .iter()
        .enumerate()
        .map(|(i, c)| (c.name.as_str(), i))
        .collect();
    let mut visited = vec![false; fw.classes.len()];
    let mut order: Vec<&Class> = Vec::with_capacity(fw.classes.len());
    for i in 0..fw.classes.len() {
        visit_class(i, fw, graph, &index, &mut visited, &mut order);
    }
    order
}

fn visit_class<'a>(
    i: usize,
    fw: &'a Framework,
    graph: &ClassGraph,
    index: &std::collections::HashMap<&str, usize>,
    visited: &mut [bool],
    order: &mut Vec<&'a Class>,
) {
    if visited[i] {
        return;
    }
    visited[i] = true;
    if let Some(ParentRef::Local(parent)) = graph.parents.get(&fw.classes[i].name) {
        if let Some(&pi) = index.get(parent.as_str()) {
            visit_class(pi, fw, graph, index, visited, order);
        }
    }
    order.push(&fw.classes[i]);
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::Framework;

    fn make_minimal_framework(name: &str) -> Framework {
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
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    fn class_with(name: &str, superclass: &str) -> Class {
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

    fn emit(fw: &Framework) -> (tempfile::TempDir, EmitResult) {
        let tmp = tempfile::tempdir().unwrap();
        let res = emit_framework(
            fw,
            tmp.path(),
            &ClassRegistry::new(),
            &ProtocolRegistry::new(),
        )
        .unwrap();
        (tmp, res)
    }

    #[test]
    fn sbcl_target_info() {
        let e = SbclEmitter::new();
        assert_eq!(e.target_info().id, "sbcl");
        assert_eq!(e.target_info().display_name, "SBCL");
        assert_eq!(e.target_info().generated_subdir, "generated");
    }

    #[test]
    fn empty_framework_writes_just_the_facade() {
        let fw = make_minimal_framework("TestKit");
        let (tmp, res) = emit(&fw);
        assert_eq!(res.files_written, 1);
        let facade = tmp.path().join("testkit.lisp");
        assert!(facade.exists());
        let body = std::fs::read_to_string(&facade).unwrap();
        assert!(body.contains(";;; Generated TestKit bindings — facade"));
        assert!(body.contains("(in-package #:apianyware-sbcl-impl)"));
        // Empty surface → an empty export form, never a dangling `'(`.
        assert!(body.contains("(export '() (find-package '#:ns))"));
        // No construct directory for an empty framework.
        assert!(!tmp.path().join("testkit").exists());
    }

    #[test]
    fn per_class_files_are_written_and_topo_ordered() {
        // IR order deliberately reversed (subclass first) — `ordered_classes` must
        // still place NSResponder before NSView before NSControl (the ASDF load
        // order the facade documents), and each class gets its own file.
        let mut fw = make_minimal_framework("AppKit");
        fw.classes = vec![
            class_with("NSControl", "NSView"),
            class_with("NSView", "NSResponder"),
            class_with("NSResponder", "NSObject"),
        ];
        let graph = build_class_graph(&fw, &ClassRegistry::new());
        let order: Vec<&str> = ordered_classes(&fw, &graph)
            .iter()
            .map(|c| c.name.as_str())
            .collect();
        assert_eq!(order, vec!["NSResponder", "NSView", "NSControl"]);

        let (tmp, _) = emit(&fw);
        for stem in ["nsresponder", "nsview", "nscontrol"] {
            let f = tmp.path().join(format!("appkit/{stem}.lisp"));
            assert!(f.exists(), "missing {stem}.lisp");
        }
        let view = std::fs::read_to_string(tmp.path().join("appkit/nsview.lisp")).unwrap();
        assert!(
            view.contains("(defclass ns:ns-view (ns:ns-responder)"),
            "{view}"
        );
    }

    #[test]
    fn facade_exports_every_bound_symbol() {
        use apianyware_types::ir::{Method, Property};
        use apianyware_types::type_ref::{TypeRef, TypeRefKind};

        let mut fw = make_minimal_framework("Foundation");
        let mut nsarray = class_with("NSArray", "NSObject");
        nsarray.methods = vec![Method {
            selector: "objectAtIndex:".into(),
            class_method: false,
            init_method: false,
            params: vec![apianyware_types::ir::Param {
                name: "index".into(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "uint64".into(),
                    },
                },
            }],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id {
                    protocols: Vec::new(),
                },
            },
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
        }];
        nsarray.properties = vec![Property {
            name: "count".into(),
            property_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "uint64".into(),
                },
            },
            readonly: true,
            class_property: false,
            ownership: None,
            deprecated: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            objc_exposed: true,
        }];
        fw.classes = vec![nsarray];

        let (tmp, _) = emit(&fw);
        let facade = std::fs::read_to_string(tmp.path().join("foundation.lisp")).unwrap();
        // The class symbol, the property getter generic, and the method generic are
        // all in the package surface (interned via the double-colon spelling).
        assert!(facade.contains("ns::ns-array"), "{facade}");
        assert!(facade.contains("ns::count"), "{facade}");
        // ADR-0039: the arg-taking selector keeps its colon as a trailing `_`.
        assert!(facade.contains("ns::object-at-index_"), "{facade}");

        // generics.lisp declares the generic; the class file extends it with a
        // defmethod (the lockstep, now split across the two files the facade orders).
        let generics =
            std::fs::read_to_string(tmp.path().join("foundation/generics.lisp")).unwrap();
        assert!(
            generics.contains("(defgeneric ns:object-at-index_ (receiver arg0)"),
            "{generics}"
        );
        let nsarray = std::fs::read_to_string(tmp.path().join("foundation/nsarray.lisp")).unwrap();
        assert!(
            nsarray.contains("(defmethod ns:object-at-index_ ((self ns:ns-array)"),
            "{nsarray}"
        );
    }
}
