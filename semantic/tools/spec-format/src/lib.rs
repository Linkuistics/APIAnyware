//! Spec interchange format for the API model (ADR-0046, workstream 2).
//!
//! Three concerns live here, one per module:
//!
//! - [`apiw`] — the **authored** overlay. `annotations.apiw` is **KDL 2.0**: a
//!   human/LLM-pleasant surface that parses to the typed annotation model
//!   ([`apianyware_types::annotation`]) and writes back losslessly.
//! - [`machine`] — the **machine** interchange. `extracted.kdl` / `resolved.kdl`
//!   are **KDL 2.0** ([`apianyware_types::ir::Framework`] bridged through
//!   `serde_json::Value` and encoded by the [`jik`] codec). The format-preserving
//!   `kdl` document model parses the multi-MB IR ~84× slower than `serde_json`,
//!   so ADR-0046 §5 routes the machine IR through a hand-written non-preserving
//!   codec (~2.4–3.2× the typed serde path) instead: KDL everywhere, fast.
//! - [`jik`] — the **JSON-in-KDL** machine codec ([`serde_json::Value`] ↔ KDL
//!   text) that `machine` bridges through.
//! - [`convert`] — the one-time migration that folds today's committed
//!   `_llm-annotations/*.llm.json` into the authored `annotations.apiw` overlay.
//!
//! - [`schema`] — the **validator step**. Validates an authored `.apiw` document
//!   against the language-neutral KDL Schema contract
//!   (`schemas/spec-format/annotations.kdl-schema`, ADR-0046 §3), embedded so the
//!   validator and the contract never drift.
//! - [`machine_schema`] — the **machine** validator step (ws8). Validates a
//!   machine IR (`extracted.kdl` / `resolved.kdl`) against
//!   `schemas/spec-format/machine-ir.kdl-schema` (ADR-0046 §5) using the *same*
//!   generic engine — one schema language over every artifact.
//!
//! Pipeline rewiring to the per-family triad paths is `pipeline-cutover-k20`.

pub mod apiw;
pub mod convert;
pub mod error;
pub mod jik;
pub mod machine;
pub mod machine_schema;
pub mod schema;

pub use error::{Result, SpecFormatError};
pub use machine_schema::validate_machine_kdl;
pub use schema::{validate_against_schema, validate_apiw};
