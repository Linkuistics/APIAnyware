//! Racket-specific naming conventions, method filtering, and code generation.
//!
//! Produces idiomatic Racket bindings from enriched macOS API IR. Supports
//! both OO-style (tell macro, class wrappers) and functional-style (typed
//! objc_msgSend) dispatch strategies.

pub mod emit_class;
pub mod emit_constants;
pub mod emit_enums;
pub mod emit_framework;
pub mod emit_functions;
pub mod emit_protocol;
pub mod enrichment_comments;
pub mod method_filter;
pub mod naming;
pub mod shared_signatures;

pub use emit_framework::RacketEmitter;
