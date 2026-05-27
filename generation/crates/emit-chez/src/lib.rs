//! Chez Scheme code generation.
//!
//! Produces idiomatic Chez bindings per framework: per-class `.sls`
//! libraries with `foreign-procedure` `objc_msgSend` call sites, plus
//! companion `enums.sls`, `constants.sls`, `functions.sls`,
//! `protocols/<proto>.sls`, and a `main.sls` re-export. Chez's
//! `library` forms need explicit export names, so the main file's
//! re-export list is materialised from each sub-file's emitter helper.

pub mod emit_class;
pub mod emit_constants;
pub mod emit_enums;
pub mod emit_framework;
pub mod emit_functions;
pub mod emit_protocol;
pub mod ffi_type_mapping;
pub mod method_filter;
pub mod naming;
pub mod shared_signatures;

pub use emit_framework::ChezEmitter;
