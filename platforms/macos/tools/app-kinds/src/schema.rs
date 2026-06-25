//! Structural validation of an app-kind `kind.apiw` against the language-neutral
//! KDL Schema contract (`schemas/spec-format/app-kind.kdl-schema`).
//!
//! As with `apianyware-patterns` (ADR-0048 D7), `apianyware-platform-manifest`,
//! and `annotations` (ADR-0046 §3), the KDL Schema — not the Rust types — is the
//! authoritative contract. This module embeds that contract via `include_str!` (so
//! the validator and the contract can never drift) and runs it through the
//! *generic* KDL-Schema engine the `apianyware-spec-format` crate exposes — reuse,
//! not duplication.
//!
//! This covers the **structural** layer: node/prop/value shapes, occurrence and
//! value cardinality, the `entry`/`run-loop`/`termination`/`activation`/`bundle`
//! enums, and default-deny of unknown nodes/props. The **semantic** layer the
//! generic schema cannot state — `bundle "none"` carries no metadata,
//! `extension-point` implies a hosted bundle, `require`/`test-obligation`
//! uniqueness, name = containing directory — is enforced by [`crate::apiw`] and
//! [`crate::registry`].

use crate::error::Result;

/// The authoritative app-kind `.apiw` contract, embedded from the `schemas/`
/// domain so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../schemas/spec-format/app-kind.kdl-schema");

/// Validate an app-kind `kind.apiw` (KDL 2.0) document against the embedded
/// `app-kind.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())`
/// when the document conforms structurally; otherwise the first located violation,
/// forwarded from the generic engine as a [`crate::AppKindError`].
pub fn validate_app_kind(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        // The contract itself must parse as KDL — a malformed schema would make
        // every app-kind validation fail opaquely.
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("app-kind.kdl-schema parses as KDL");
    }

    #[test]
    fn rejects_an_unknown_activation_policy() {
        let text = r#"
            app-kind "x" {
                process { entry "c-main"; run-loop "none"; termination "return" }
                activation "teleport"
                bundle "none"
            }
        "#;
        assert!(validate_app_kind("bad/kind.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_missing_process_block() {
        // `process` is `min 1` — a kind with no process model is structurally
        // incomplete.
        let text = r#"
            app-kind "x" {
                activation "regular"
                bundle "none"
            }
        "#;
        assert!(validate_app_kind("bad/kind.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_bundle_type() {
        let text = r#"
            app-kind "x" {
                process { entry "c-main"; run-loop "none"; termination "return" }
                activation "background"
                bundle "framework"
            }
        "#;
        assert!(validate_app_kind("bad/kind.apiw", text).is_err());
    }
}
