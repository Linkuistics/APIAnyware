//! Structural validation of an app-kind test-obligation `<kind>.apiw` against the
//! language-neutral KDL Schema contract
//! (`schemas/spec-format/app-kind-tests.kdl-schema`).
//!
//! As with `apianyware-app-kinds`, `apianyware-patterns`, and `annotations`
//! (ADR-0046 §3), the KDL Schema — not the Rust types — is the authoritative
//! contract. This module embeds that contract via `include_str!` (so the validator
//! and the contract can never drift) and runs it through the *generic* KDL-Schema
//! engine the `apianyware-spec-format` crate exposes — reuse, not duplication.
//!
//! This covers the **structural** layer: node/value shapes, occurrence and value
//! cardinality (`obligation` min 1, `expect` min 1 per obligation), and default-deny
//! of unknown nodes/props. The **semantic** layer the generic schema cannot state —
//! `obligation` names unique, `expect` ids unique within an obligation — is enforced
//! by [`super::apiw`]; the cross-entity layer (name = file stem, obligations resolve
//! the kind's refs) by [`super::registry`] and the standing guard.

use crate::error::Result;

/// The authoritative app-kind-tests `.apiw` contract, embedded from the `schemas/`
/// domain so the validator and the contract are one source of truth. Six levels up
/// from this submodule file: `app_kind_tests/` → `src/` → `platform-tests/` →
/// `tools/` → `macos/` → `platforms/` → repo root.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/app-kind-tests.kdl-schema");

/// Validate an app-kind test-obligation `<kind>.apiw` (KDL 2.0) document against the
/// embedded `app-kind-tests.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())`
/// when the document conforms structurally; otherwise the first located violation,
/// forwarded from the generic engine as a [`crate::PlatformTestError`].
pub fn validate_app_kind_tests(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        // The contract itself must parse as KDL — a malformed schema would make
        // every validation fail opaquely.
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("app-kind-tests.kdl-schema parses as KDL");
    }

    #[test]
    fn rejects_an_obligation_with_no_expectation() {
        // `expect` is `min 1` — an obligation that asserts nothing is structurally
        // incomplete.
        let text = r#"
            app-kind-tests "x" {
                obligation "lifecycle" {
                    doc "asserts nothing"
                }
            }
        "#;
        assert!(validate_app_kind_tests("x.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_file_with_no_obligation() {
        // `obligation` is `min 1` — a file that resolves nothing is structurally
        // incomplete.
        let text = r#"app-kind-tests "x" { doc "empty" }"#;
        assert!(validate_app_kind_tests("x.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        // default-deny: a node the schema does not list is rejected.
        let text = r#"
            app-kind-tests "x" {
                obligation "lifecycle" {
                    expect "boots" { doc "ok" }
                }
                surprise "node"
            }
        "#;
        assert!(validate_app_kind_tests("x.apiw", text).is_err());
    }
}
