//! Chez Scheme code generation.
//!
//! 070 scaffold: produces one `.sls` per ObjC class, each a Chez `library`
//! that imports the chez runtime (`(apianyware runtime ffi)`,
//! `(apianyware runtime objc)`, `(apianyware runtime types)`) and exposes
//! a Scheme procedure per supported selector. Enums, constants, C
//! functions, protocols, and the per-framework `main.sls` re-export are
//! deferred to leaf 080.

pub mod emit_class;
pub mod emit_framework;
pub mod ffi_type_mapping;
pub mod method_filter;
pub mod naming;

pub use emit_framework::ChezEmitter;
