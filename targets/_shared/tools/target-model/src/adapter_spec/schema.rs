//! Structural validation of an `adapters/<platform>/spec.apiw` against the language-neutral
//! KDL Schema contract (`schemas/spec-format/adapter-spec.kdl-schema`).
//!
//! As with the sibling `policy` / `idioms` / `capability` submodules (ADR-0046 §3), the KDL
//! Schema — not the Rust types — is the authoritative contract. This module embeds that
//! contract via `include_str!` (so the validator and the contract can never drift) and runs
//! it through the *generic* KDL-Schema engine `apianyware-spec-format` exposes.
//!
//! This covers the **structural** layer: the `adapter-spec "<id>"` / `platform` / `output` /
//! `role` / `service` / `direct-call-policy` node shapes, occurrence cardinality, the closed
//! [`ServiceStatus`](crate::adapter_spec::ServiceStatus) `status` enum, and default-deny of
//! unknown nodes. The **semantic** layer the generic schema cannot state — the §26 role +
//! service vocabularies, their per-spec uniqueness, and the allow∩deny disjointness — is
//! enforced by [`crate::adapter_spec::apiw`], and identity by
//! [`crate::adapter_spec::registry`].

use crate::error::Result;

/// The authoritative adapter-spec `.apiw` contract, embedded from the `schemas/` domain so
/// the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/adapter-spec.kdl-schema");

/// Validate an `adapters/<platform>/spec.apiw` (KDL 2.0) document against the embedded
/// `adapter-spec.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())` when the
/// document conforms structurally; otherwise the first located violation, forwarded from the
/// generic engine as a [`crate::TargetModelError`].
pub fn validate_adapter_spec(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const WELL_FORMED: &str = r#"
        adapter-spec "racket" {
            platform "macos"
            doc "The APIAnywareRacket native adapter library on macOS."
            output {
                library "APIAnywareRacket"
                kind "dynamic-library"
                symbol-prefix "aw_racket_"
            }
            role "callback-adapter" { doc "BlockBridge + DelegateBridge" }
            role "error-adapter"
            service "callback-registry" {
                status "required"
                doc "GCPrevention roots Scheme callbacks against GC"
            }
            direct-call-policy {
                allow "directly-reachable-objc" { doc "trampoline-elided objc_msgSend" }
                deny "swift-native-async" { doc "needs the AsyncBridge trampoline" }
            }
        }
    "#;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("adapter-spec.kdl-schema parses as KDL");
    }

    #[test]
    fn accepts_a_well_formed_spec() {
        validate_adapter_spec("racket/adapters/macos/spec.apiw", WELL_FORMED)
            .expect("a well-formed adapter spec validates");
    }

    #[test]
    fn rejects_an_unknown_service_status() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                output { library "X"; kind "dynamic-library" }
                service "callback-registry" { status "sometimes" }
            }
        "#;
        assert!(validate_adapter_spec("bad/adapters/macos/spec.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_spec_missing_its_output() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                role "error-adapter"
            }
        "#;
        assert!(validate_adapter_spec("bad/adapters/macos/spec.apiw", text).is_err());
    }

    #[test]
    fn rejects_output_missing_its_library() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                output { kind "dynamic-library" }
            }
        "#;
        assert!(validate_adapter_spec("bad/adapters/macos/spec.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                output { library "X"; kind "dynamic-library" }
                rocket "launch"
            }
        "#;
        assert!(validate_adapter_spec("bad/adapters/macos/spec.apiw", text).is_err());
    }
}
