//! Spec interchange format for the API model (ADR-0046, workstream 2).
//!
//! Three concerns live here, one per module:
//!
//! - [`apiw`] — the **authored** overlay. `annotations.apiw` is **KDL 2.0**: a
//!   human/LLM-pleasant surface that parses to the typed annotation model
//!   ([`apianyware_types::annotation`]) and writes back losslessly.
//! - [`machine`] — the **machine** interchange. `extracted.json` / `resolved.json`
//!   stay **JSON** (`serde_json` over [`apianyware_types::ir::Framework`]). The
//!   k17 spike measured the only production-grade KDL-2.0 library at ~80–100×
//!   slower to parse than `serde_json` on the real multi-MB IR, so ADR-0046 §5's
//!   JSON retreat was invoked: KDL stays only where humans write.
//! - [`convert`] — the one-time migration that folds today's committed
//!   `_llm-annotations/*.llm.json` into the authored `annotations.apiw` overlay.
//!
//! The schema-validation hookup (the KDL Schema for `.apiw`) lands in the next
//! leaf (`kdl-schema-k19`); this crate is the parser/writer it will validate
//! against. Pipeline rewiring to the per-family triad paths is `pipeline-cutover-k20`.

pub mod apiw;
pub mod convert;
pub mod error;
pub mod machine;

pub use error::{Result, SpecFormatError};
