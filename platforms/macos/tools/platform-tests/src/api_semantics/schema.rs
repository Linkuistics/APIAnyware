//! Structural validation of an api-semantics `<facet>.apiw` against the
//! language-neutral KDL Schema contract
//! (`schemas/spec-format/api-semantics.kdl-schema`).
//!
//! As with the sibling [`super::super::app_kind_tests`] family, `apianyware-app-kinds`,
//! `apianyware-patterns`, and `annotations` (ADR-0046 §3), the KDL Schema — not the
//! Rust types — is the authoritative contract. This module embeds that contract via
//! `include_str!` (so the validator and the contract can never drift) and runs it
//! through the *generic* KDL-Schema engine the `apianyware-spec-format` crate exposes
//! — reuse, not duplication.
//!
//! This covers the **structural** layer: node/value shapes, occurrence and value
//! cardinality (`api` min 1, `weirdness` min 1 and `expect` min 1 per `api`), the
//! flat `facet` `enum`, and default-deny of unknown nodes/props. The **semantic**
//! layer the generic schema cannot state — the facet-conditional `weirdness`
//! vocabulary, `(receiver, selector)` uniqueness, `expect` id uniqueness, per-shape
//! `weirdness` de-duplication — is enforced by [`super::apiw`]; the cross-file layer
//! (facet = file stem) by [`super::registry`] and the standing guard.

use crate::error::Result;

/// The authoritative api-semantics `.apiw` contract, embedded from the `schemas/`
/// domain so the validator and the contract are one source of truth. Six levels up
/// from this submodule file: `api_semantics/` → `src/` → `platform-tests/` →
/// `tools/` → `macos/` → `platforms/` → repo root.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/api-semantics.kdl-schema");

/// Validate an api-semantics `<facet>.apiw` (KDL 2.0) document against the embedded
/// `api-semantics.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())` when
/// the document conforms structurally; otherwise the first located violation,
/// forwarded from the generic engine as a [`crate::PlatformTestError`].
pub fn validate_api_semantics(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        // The contract itself must parse as KDL — a malformed schema would make every
        // validation fail opaquely.
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("api-semantics.kdl-schema parses as KDL");
    }

    #[test]
    fn rejects_an_unknown_facet() {
        // `facet` is a flat schema `enum` — a fifth facet is structurally invalid.
        let text = r#"
            api-semantics "buffers" {
                api "NSData" "bytes" {
                    weirdness "borrowed"
                    expect "x" { doc "ok" }
                }
            }
        "#;
        assert!(validate_api_semantics("buffers.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_api_with_no_weirdness() {
        // `weirdness` is `min 1` — a shape is declared because it has a §30 property.
        let text = r#"
            api-semantics "ownership" {
                api "NSString" "stringWithString:" {
                    expect "x" { doc "ok" }
                }
            }
        "#;
        assert!(validate_api_semantics("ownership.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_api_with_no_expectation() {
        // `expect` is `min 1` — a shape that asserts nothing is structurally
        // incomplete.
        let text = r#"
            api-semantics "ownership" {
                api "NSString" "stringWithString:" {
                    weirdness "autoreleased"
                }
            }
        "#;
        assert!(validate_api_semantics("ownership.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_api_without_both_receiver_and_selector() {
        // `api` takes exactly two positional values (receiver, selector).
        let text = r#"
            api-semantics "ownership" {
                api "NSString" {
                    weirdness "autoreleased"
                    expect "x" { doc "ok" }
                }
            }
        "#;
        assert!(validate_api_semantics("ownership.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_file_with_no_api() {
        // `api` is `min 1` — a facet file declaring nothing is structurally empty.
        let text = r#"api-semantics "ownership" { doc "empty" }"#;
        assert!(validate_api_semantics("ownership.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        // default-deny: a node the schema does not list is rejected.
        let text = r#"
            api-semantics "ownership" {
                api "NSString" "stringWithString:" {
                    weirdness "autoreleased"
                    expect "x" { doc "ok" }
                }
                surprise "node"
            }
        "#;
        assert!(validate_api_semantics("ownership.apiw", text).is_err());
    }
}
