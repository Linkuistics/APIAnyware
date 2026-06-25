//! Structural validation of an `idioms/catalogue.apiw` against the language-neutral KDL
//! Schema contract (`schemas/spec-format/idioms.kdl-schema`).
//!
//! As with the sibling `descriptor` / `capability` submodules (ADR-0046 §3 / §4), the KDL
//! Schema — not the Rust types — is the authoritative contract. This module embeds that
//! contract via `include_str!` (so the validator and the contract can never drift) and
//! runs it through the *generic* KDL-Schema engine `apianyware-spec-format` exposes —
//! reuse, not duplication.
//!
//! This covers the **structural** layer: the `idiom-catalogue "<id>"` / `idiom` /
//! `construct` / `projects` / `emit` / `name` node shapes, occurrence cardinality, the
//! closed [`EmitConstruct`](crate::idioms::EmitConstruct) `emit` enum, and default-deny of
//! unknown nodes. The **semantic** layer the generic schema cannot state — the §21 idiom
//! *category* vocabulary, category uniqueness, and per-catalogue pattern-kind uniqueness —
//! is enforced by [`crate::idioms::apiw`], and identity (id = the target directory) by
//! [`crate::idioms::registry`].

use crate::error::Result;

/// The authoritative idiom-catalogue `.apiw` contract, embedded from the `schemas/` domain
/// so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../../../schemas/spec-format/idioms.kdl-schema");

/// Validate an `idioms/catalogue.apiw` (KDL 2.0) document against the embedded
/// `idioms.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())` when the
/// document conforms structurally; otherwise the first located violation, forwarded from
/// the generic engine as a [`crate::TargetModelError`].
pub fn validate_idioms(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_is_well_formed_kdl() {
        // The contract itself must parse as KDL — a malformed schema would make every
        // catalogue validation fail opaquely.
        kdl::KdlDocument::parse(SCHEMA_TEXT).expect("idioms.kdl-schema parses as KDL");
    }

    #[test]
    fn accepts_a_well_formed_catalogue() {
        let text = r#"
            idiom-catalogue "sbcl" {
                idiom "bracketed-use" {
                    construct "with-macro expanding to unwind-protect"
                    projects "bracket" {
                        emit "scoped-resource"
                        name "with-bracket"
                    }
                }
                idiom "owned-resource" {
                    construct "CLOS wrapper holding the foreign pointer + closed-state"
                }
            }
        "#;
        validate_idioms("sbcl/idioms/catalogue.apiw", text)
            .expect("a well-formed catalogue validates");
    }

    #[test]
    fn rejects_an_unknown_emit_construct() {
        let text = r#"
            idiom-catalogue "x" {
                idiom "bracketed-use" {
                    construct "with-macro"
                    projects "bracket" { emit "teleporter"; name "with-bracket" }
                }
            }
        "#;
        assert!(validate_idioms("bad/idioms/catalogue.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_idiom_missing_its_construct() {
        let text = r#"
            idiom-catalogue "x" {
                idiom "bracketed-use" { }
            }
        "#;
        assert!(validate_idioms("bad/idioms/catalogue.apiw", text).is_err());
    }

    #[test]
    fn rejects_a_projection_missing_its_emit() {
        let text = r#"
            idiom-catalogue "x" {
                idiom "bracketed-use" {
                    construct "with-macro"
                    projects "bracket" { name "with-bracket" }
                }
            }
        "#;
        assert!(validate_idioms("bad/idioms/catalogue.apiw", text).is_err());
    }

    #[test]
    fn rejects_an_unknown_node() {
        let text = r#"
            idiom-catalogue "x" {
                idiom "bracketed-use" { construct "with-macro" }
                rocket "launch"
            }
        "#;
        assert!(validate_idioms("bad/idioms/catalogue.apiw", text).is_err());
    }
}
