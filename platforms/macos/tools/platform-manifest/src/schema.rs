//! Structural validation of a `platform.apiw` manifest against the
//! language-neutral KDL Schema contract
//! (`schemas/spec-format/platform.kdl-schema`).
//!
//! As with `apianyware-patterns` (ADR-0048 D7) and `annotations` (ADR-0046 §3),
//! the KDL Schema — not the Rust types — is the authoritative contract. This
//! module embeds that contract via `include_str!` (so the validator and the
//! contract can never drift) and runs it through the *generic* KDL-Schema engine
//! the `apianyware-spec-format` crate exposes — reuse, not duplication.
//!
//! This covers the **structural** layer: node/prop/value shapes, occurrence and
//! value cardinality, the `discover` enum, the mandatory `ignore` `reason`, and
//! default-deny of unknown nodes/props. The **semantic** layer the generic schema
//! cannot state — `ignore`-name uniqueness — is enforced by [`crate::manifest`]
//! after a successful parse.

use crate::error::Result;

/// The authoritative platform-manifest `.apiw` contract, embedded from the
/// `schemas/` domain so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../schemas/spec-format/platform.kdl-schema");

/// Validate a `platform.apiw` (KDL 2.0) document against the embedded
/// `platform.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file name). Returns `Ok(())`
/// when the document conforms structurally; otherwise the first located
/// violation, forwarded from the generic engine as a
/// [`crate::PlatformManifestError`].
pub fn validate_platform_manifest(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        // The contract itself must parse as KDL — a malformed schema would make
        // every manifest validation fail opaquely.
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("platform.kdl-schema parses as KDL");
    }

    #[test]
    fn rejects_an_ignore_without_a_reason() {
        // The `reason` prop is mandatory (no silent caps). A structural violation
        // the generic engine catches.
        let text = r#"
            platform "macos" {
                sdk "macosx"
                deployment-target "14.0"
                frameworks {
                    discover "sdk-umbrella-headers"
                    ignore "DriverKit"
                }
            }
        "#;
        assert!(validate_platform_manifest("bad.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_discover_source() {
        let text = r#"
            platform "macos" {
                sdk "macosx"
                deployment-target "14.0"
                frameworks {
                    discover "carrier-pigeon"
                }
            }
        "#;
        assert!(validate_platform_manifest("bad.apiw", text).is_err());
    }

    #[test]
    fn rejects_frameworks_with_no_discover_source() {
        // `discover` is `min 1` — a roster policy with no discovery source would
        // resolve to an empty roster, which is never intended.
        let text = r#"
            platform "macos" {
                sdk "macosx"
                deployment-target "14.0"
                frameworks {
                    ignore "DriverKit" reason="C++"
                }
            }
        "#;
        assert!(validate_platform_manifest("bad.apiw", text).is_err());
    }
}
