//! SBCL (Steel Bank Common Lisp) code generation — a CLOS binding.
//!
//! The fourth APIAnyware target after `racket`, `chez`, and `gerbil`, and the
//! first member of the **CL family** (the spec-level CLOS interface contract,
//! ADR-0033 / `docs/specs/2026-06-20-cl-family-interface-contract.md`).
//!
//! SBCL projects the macOS ObjC API into idiomatic CLOS, reaching ObjC
//! **directly** through an `sb-alien` `objc_msgSend` seam (the trampoline elided,
//! ADR-0026) and the Swift-native residual through one native dylib
//! (`libAPIAnywareSbcl`, ADR-0038). The object model is a MOP projection — an
//! `objc-class` metaclass backs every bound ObjC class, with per-selector
//! receiver-specialized generics (ADR-0034). The emitter statically bakes the
//! CLOS class graph, selector strings, and slot specs; the MOP machinery and the
//! startup re-resolution pass live in the runtime (leaf 050).
//!
//! See the SBCL target design spec
//! (`generation/targets/sbcl/docs/design/2026-06-20-sbcl-target-design.md`) for
//! the buildable design this crate implements.
//!
//! ## Module layout (grown per `040-build-emitter` child leaf)
//!
//! - `ffi_type_mapping` / `naming` / `method_filter` / `emit_framework`
//!   (leaf 010 — scaffold + foundations).
//! - `class_graph` / `emit_class` / `emit_generics` (leaf 020 — object model).
//! - `emit_protocol` / `protocol_registry` (leaf 030).
//! - `emit_enums` / `emit_constants` / `emit_functions` (leaf 040).
//! - `trampoline` / `shared_signatures` (leaf 050).

pub mod class_graph;
pub mod emit_class;
pub mod emit_generics;
pub mod ffi_type_mapping;
pub mod method_filter;
pub mod naming;

mod emit_framework;

pub use emit_framework::{SbclEmitter, SBCL_TARGET_INFO};
