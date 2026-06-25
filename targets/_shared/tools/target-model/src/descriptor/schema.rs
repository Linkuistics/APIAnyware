//! Structural validation of a `target.apiw` against the language-neutral KDL Schema
//! contract (`schemas/spec-format/target.kdl-schema`).
//!
//! As with `apianyware-app-kinds` (ADR-0046 §3 / §4), the KDL Schema — not the Rust
//! types — is the authoritative contract. This module embeds that contract via
//! `include_str!` (so the validator and the contract can never drift) and runs it
//! through the *generic* KDL-Schema engine `apianyware-spec-format` exposes — reuse,
//! not duplication.
//!
//! This covers the **structural** layer: node/value shapes, occurrence cardinality,
//! the `runtime-model` enum, and default-deny of unknown nodes. The **semantic**
//! layer the generic schema cannot state — non-blank facet tokens — is enforced by
//! [`crate::descriptor::apiw`], and identity (id = containing directory) by
//! [`crate::descriptor::registry`].

use crate::error::Result;

/// The authoritative target-descriptor `.apiw` contract, embedded from the
/// `schemas/` domain so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/target.kdl-schema");

/// Validate a `target.apiw` (KDL 2.0) document against the embedded
/// `target.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())` when
/// the document conforms structurally; otherwise the first located violation,
/// forwarded from the generic engine as a [`crate::TargetModelError`].
pub fn validate_target(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        // The contract itself must parse as KDL — a malformed schema would make every
        // target validation fail opaquely.
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("target.kdl-schema parses as KDL");
    }

    #[test]
    fn accepts_a_well_formed_descriptor() {
        let text = r#"
            target "sbcl" {
                family "common-lisp"
                dialect "ansi-cl"
                implementation "sbcl"
                ffi-backend "sb-alien"
                runtime-model "compiled-ffi"
                projection-policy "thin-direct"
                adapter-strategy "sole-native-unit"
            }
        "#;
        validate_target("sbcl/target.apiw", text).expect("a well-formed descriptor validates");
    }

    #[test]
    fn rejects_an_unknown_runtime_model() {
        let text = r#"
            target "x" {
                family "scheme"
                implementation "x-impl"
                ffi-backend "magic"
                runtime-model "quantum-ffi"
                projection-policy "thin-direct"
                adapter-strategy "trampoline-only"
            }
        "#;
        assert!(validate_target("bad/target.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_missing_required_facet() {
        // `implementation` is `min 1` — a descriptor without it is structurally
        // incomplete.
        let text = r#"
            target "x" {
                family "scheme"
                ffi-backend "magic"
                runtime-model "compiled-ffi"
                projection-policy "thin-direct"
                adapter-strategy "trampoline-only"
            }
        "#;
        assert!(validate_target("bad/target.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        let text = r#"
            target "x" {
                family "scheme"
                implementation "x-impl"
                ffi-backend "magic"
                runtime-model "compiled-ffi"
                projection-policy "thin-direct"
                adapter-strategy "trampoline-only"
                rocket "launch"
            }
        "#;
        assert!(validate_target("bad/target.apiw", text).is_err());
    }
}
