//! Structural validation of a `capability.apiw` against the language-neutral KDL
//! Schema contract (`schemas/spec-format/capability.kdl-schema`).
//!
//! As with the sibling `descriptor` submodule (ADR-0046 §3 / §4), the KDL Schema — not
//! the Rust types — is the authoritative contract. This module embeds that contract
//! via `include_str!` (so the validator and the contract can never drift) and runs it
//! through the *generic* KDL-Schema engine `apianyware-spec-format` exposes — reuse,
//! not duplication.
//!
//! This covers the **structural** layer: the `capability "<id>"` / `semantic` /
//! `app-form` / `dimension` / `rung` node shapes, occurrence cardinality, the 7-rung
//! `rung` enum, and default-deny of unknown nodes. The **semantic** layer the generic
//! schema cannot state — the face-conditional capability-dimension vocabulary and
//! per-face dimension uniqueness — is enforced by [`crate::capability::apiw`], and
//! identity (id = containing directory) by [`crate::capability::registry`].

use crate::error::Result;

/// The authoritative capability-profile `.apiw` contract, embedded from the `schemas/`
/// domain so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/capability.kdl-schema");

/// Validate a `capability.apiw` (KDL 2.0) document against the embedded
/// `capability.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())` when
/// the document conforms structurally; otherwise the first located violation,
/// forwarded from the generic engine as a [`crate::TargetModelError`].
pub fn validate_capability(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        // The contract itself must parse as KDL — a malformed schema would make every
        // capability validation fail opaquely.
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("capability.kdl-schema parses as KDL");
    }

    #[test]
    fn accepts_a_well_formed_profile() {
        let text = r#"
            capability "sbcl" {
                semantic {
                    dimension "foreign-thread-callbacks" {
                        rung "idiomatic-conventional"
                    }
                }
                app-form {
                    dimension "packaging" {
                        rung "exact-runtime"
                    }
                }
            }
        "#;
        validate_capability("sbcl/capability.apiw", text).expect("a well-formed profile validates");
    }

    #[test]
    fn rejects_an_unknown_rung() {
        let text = r#"
            capability "x" {
                semantic {
                    dimension "ownership" { rung "perfectly-fine" }
                }
                app-form {
                    dimension "packaging" { rung "exact-runtime" }
                }
            }
        "#;
        assert!(validate_capability("bad/capability.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_missing_face() {
        // `app-form` is `min 1` — a profile without it is structurally incomplete.
        let text = r#"
            capability "x" {
                semantic {
                    dimension "ownership" { rung "idiomatic-conventional" }
                }
            }
        "#;
        assert!(validate_capability("bad/capability.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_dimension_missing_its_rung() {
        let text = r#"
            capability "x" {
                semantic {
                    dimension "ownership" { }
                }
                app-form {
                    dimension "packaging" { rung "exact-runtime" }
                }
            }
        "#;
        assert!(validate_capability("bad/capability.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        let text = r#"
            capability "x" {
                semantic {
                    dimension "ownership" { rung "idiomatic-conventional" }
                }
                app-form {
                    dimension "packaging" { rung "exact-runtime" }
                }
                rocket "launch"
            }
        "#;
        assert!(validate_capability("bad/capability.apiw", text).is_err());
    }
}
