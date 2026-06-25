//! Structural validation of a `conformance/<platform>.apiw` against the language-neutral KDL
//! Schema contract (`schemas/spec-format/conformance.kdl-schema`).
//!
//! As with the sibling `policy` / `adapter_spec` / `capability` submodules (ADR-0046 §3), the
//! KDL Schema — not the Rust types — is the authoritative contract. This module embeds that
//! contract via `include_str!` (so the validator and the contract can never drift) and runs
//! it through the *generic* KDL-Schema engine `apianyware-spec-format` exposes — reuse, not
//! duplication.
//!
//! This covers the **structural** layer: the `conformance "<id>"` / `platform` /
//! `app-support` / `status` / `exemplar` / `unsupported` / `research` / `known-issue` node
//! shapes, occurrence cardinality, the closed [`ConformanceStatus`](crate::derive::ConformanceStatus)
//! `status` enum, and default-deny of unknown nodes. The **semantic** layer the generic schema
//! cannot state — the §37 app-kind vocabulary, per-report / per-entry uniqueness — is enforced
//! by [`crate::conformance::apiw`], and identity (id = the grandparent directory, platform =
//! the file stem) by [`crate::conformance::registry`].

use crate::error::Result;

/// The authoritative conformance-report `.apiw` contract, embedded from the `schemas/` domain
/// so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/conformance.kdl-schema");

/// Validate a `conformance/<platform>.apiw` (KDL 2.0) document against the embedded
/// `conformance.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())` when the
/// document conforms structurally; otherwise the first located violation, forwarded from the
/// generic engine as a [`crate::TargetModelError`].
pub fn validate_conformance(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("conformance.kdl-schema parses as KDL");
    }

    #[test]
    fn accepts_a_well_formed_report() {
        let text = r#"
            conformance "racket" {
                platform "macos"
                doc "Racket's macOS conformance."
                app-support "gui-app" {
                    status "pass"
                    doc "all GUI sample apps VM-verified"
                    exemplar "hello-window"
                    exemplar "note-editor"
                }
                app-support "spotlight-importer" { status "research" }
                unsupported "swift-actor-isolation" { doc "no actor model" }
                research "app-sandbox" { doc "entitlements not exercised" }
                known-issue "menu-bar-name" { doc "stub-launcher process name" }
            }
        "#;
        validate_conformance("racket/conformance/macos.apiw", text)
            .expect("a well-formed report validates");
    }

    #[test]
    fn rejects_an_unknown_status() {
        let text = r#"
            conformance "x" {
                platform "macos"
                app-support "gui-app" { status "teleported" }
            }
        "#;
        assert!(validate_conformance("bad/conformance/macos.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_report_missing_its_platform() {
        let text = r#"
            conformance "x" {
                app-support "gui-app" { status "pass" }
            }
        "#;
        assert!(validate_conformance("bad/conformance/macos.apiw", text).is_err());
    }

    #[test]
    fn rejects_app_support_missing_its_status() {
        let text = r#"
            conformance "x" {
                platform "macos"
                app-support "gui-app" { doc "no status" }
            }
        "#;
        assert!(validate_conformance("bad/conformance/macos.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        let text = r#"
            conformance "x" {
                platform "macos"
                rocket "launch"
            }
        "#;
        assert!(validate_conformance("bad/conformance/macos.apiw", text).is_err());
    }
}
