//! Structural validation of a `policies/<platform>/projection.apiw` against the
//! language-neutral KDL Schema contract (`schemas/spec-format/policy.kdl-schema`).
//!
//! As with the sibling `idioms` / `capability` / `descriptor` submodules (ADR-0046 §3), the
//! KDL Schema — not the Rust types — is the authoritative contract. This module embeds that
//! contract via `include_str!` (so the validator and the contract can never drift) and runs
//! it through the *generic* KDL-Schema engine `apianyware-spec-format` exposes — reuse, not
//! duplication.
//!
//! This covers the **structural** layer: the `projection-policy "<id>"` / `platform` /
//! `posture` / `choice` / `spectrum` node shapes, occurrence cardinality, the closed
//! [`SpectrumPoint`](crate::policy::SpectrumPoint) `spectrum` enum, and default-deny of
//! unknown nodes. The **semantic** layer the generic schema cannot state — per-policy
//! concern uniqueness — is enforced by [`crate::policy::apiw`], and identity (id = the
//! target directory, platform = the parent directory) by [`crate::policy::registry`].

use crate::error::Result;

/// The authoritative projection-policy `.apiw` contract, embedded from the `schemas/`
/// domain so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/policy.kdl-schema");

/// Validate a `policies/<platform>/projection.apiw` (KDL 2.0) document against the embedded
/// `policy.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())` when the
/// document conforms structurally; otherwise the first located violation, forwarded from
/// the generic engine as a [`crate::TargetModelError`].
pub fn validate_policy(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("policy.kdl-schema parses as KDL");
    }

    #[test]
    fn accepts_a_well_formed_policy() {
        let text = r#"
            projection-policy "racket" {
                platform "macos"
                posture "thin-direct"
                choice "directly-reachable-objc" {
                    spectrum "direct-call"
                    doc "trampoline-elided objc_msgSend dispatch"
                }
                choice "swift-native-async" {
                    spectrum "adapter-call-plus-wrapper"
                }
            }
        "#;
        validate_policy("racket/policies/macos/projection.apiw", text)
            .expect("a well-formed policy validates");
    }

    #[test]
    fn rejects_an_unknown_spectrum_point() {
        let text = r#"
            projection-policy "x" {
                platform "macos"
                choice "directly-reachable-objc" { spectrum "teleport-call" }
            }
        "#;
        assert!(validate_policy("bad/policies/macos/projection.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_policy_missing_its_platform() {
        let text = r#"
            projection-policy "x" {
                choice "directly-reachable-objc" { spectrum "direct-call" }
            }
        "#;
        assert!(validate_policy("bad/policies/macos/projection.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_choice_missing_its_spectrum() {
        let text = r#"
            projection-policy "x" {
                platform "macos"
                choice "directly-reachable-objc" { doc "no spectrum" }
            }
        "#;
        assert!(validate_policy("bad/policies/macos/projection.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        let text = r#"
            projection-policy "x" {
                platform "macos"
                choice "directly-reachable-objc" { spectrum "direct-call" }
                rocket "launch"
            }
        "#;
        assert!(validate_policy("bad/policies/macos/projection.apiw", text).is_err());
    }
}
