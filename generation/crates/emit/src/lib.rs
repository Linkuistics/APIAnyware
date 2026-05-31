//! Shared emitter framework — naming utilities, FFI type mapping, code writer,
//! framework ordering, doc rendering, the target-emitter abstraction, and
//! pattern dispatch.
//!
//! This crate provides the common infrastructure used by all target-specific
//! emitter crates (`emit-racket`, `emit-chez`). It has no dependency on any
//! specific target target.

pub mod target_emitter;
pub mod code_writer;
pub mod doc_rendering;
pub mod ffi_type_mapping;
pub mod framework_ordering;
pub mod naming;
pub mod pattern_dispatch;
pub mod snapshot_testing;
pub mod test_fixtures;
