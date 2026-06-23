//! Shared IR types, annotation schema, and checkpoint file format.
//!
//! This crate defines the data structures that flow through the entire pipeline:
//! Collection → Analysis → Generation. All checkpoint JSON files serialize
//! and deserialize using these types.

pub mod annotation;
pub mod enrichment;
pub mod ir;
pub mod provenance;
pub mod serde_helpers;
pub mod skipped_symbol_reason;
pub mod type_ref;

// Re-export the most commonly used types at crate root for convenience.
pub use ir::Framework;
pub use type_ref::{TypeRef, TypeRefKind};
