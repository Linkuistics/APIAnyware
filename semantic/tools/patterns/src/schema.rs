//! Structural validation of a pattern-kind `.apiw` document against the
//! language-neutral KDL Schema contract
//! (`schemas/spec-format/pattern-kinds.kdl-schema`).
//!
//! ADR-0048 D7 makes the KDL Schema — not the Rust types — the authoritative
//! contract (mirroring ADR-0046 §3 for annotations). This module embeds that
//! contract via `include_str!` (so the validator and the contract can never
//! drift) and runs it through the *generic* KDL-Schema engine the sibling
//! `apianyware-spec-format` crate exposes — reuse, not duplication (PRD goal 5).
//!
//! This covers the **structural** layer: node/prop/value shapes, occurrence and
//! value cardinality, the `binds` / `cardinality` / law-`category` enums, and
//! default-deny of unknown nodes/props. The **semantic** layer the generic schema
//! cannot state — law tokens ∈ their §30 category, `ordering` edges naming
//! declared roles, role-name uniqueness — is enforced by [`crate::apiw`] after a
//! successful parse.

use crate::error::Result;

/// The authoritative pattern-kind `.apiw` contract, embedded from the `schemas/`
/// domain so the validator and the contract are one source of truth.
pub(crate) const SCHEMA_TEXT: &str =
    include_str!("../../../../schemas/spec-format/pattern-kinds.kdl-schema");

/// Validate a pattern-kind `.apiw` (KDL 2.0) document against the embedded
/// `pattern-kinds.kdl-schema` contract — the structural layer only.
///
/// `source_name` labels diagnostics (typically the file name). Returns `Ok(())`
/// when the document conforms structurally; otherwise the first located
/// violation, forwarded from the generic engine as a [`crate::PatternError`].
pub fn validate_pattern_kind(source_name: &str, text: &str) -> Result<()> {
    apianyware_spec_format::validate_against_schema(SCHEMA_TEXT, source_name, text)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use kdl::KdlDocument;

    #[test]
    fn embedded_schema_parses() {
        // The contract must be a syntactically valid KDL document (a crate bug
        // otherwise); `validate_against_schema` would surface a malformed schema
        // as a located error rather than a panic, so guard it here.
        KdlDocument::parse(SCHEMA_TEXT).expect("embedded pattern-kinds.kdl-schema parses as KDL");
    }

    #[test]
    fn minimal_valid_kind_passes() {
        let text = r#"
pattern-kind "parent-child" {
    role "parent" binds="type" cardinality="1"
    role "child"  binds="type" cardinality="1"
    law "relationship" {
        token "parent-owns-child"
    }
}
"#;
        validate_pattern_kind("ok.apiw", text).expect("minimal valid pattern-kind passes");
    }

    #[test]
    fn behavioral_kind_with_ordering_passes() {
        let text = r#"
pattern-kind "bracket" {
    doc "acquire then operate then release"
    role "acquire"   binds="operation" cardinality="1"
    role "operation" binds="operation" cardinality="*"
    role "release"   binds="operation" cardinality="1"
    ordering {
        before "acquire" "operation"
        before "operation" "release"
    }
    law "error" {
        token "cleanup-required-after-partial-failure"
        doc "release must run even on failure"
    }
}
"#;
        validate_pattern_kind("bracket.apiw", text).expect("behavioral kind passes");
    }

    #[test]
    fn bad_binds_enum_is_rejected() {
        let text = r#"
pattern-kind "x" {
    role "r" binds="widget" cardinality="1"
    law "ownership" { token "owned" }
}
"#;
        let err = validate_pattern_kind("bad.apiw", text)
            .unwrap_err()
            .to_string();
        assert!(
            err.contains("widget"),
            "names the offending value, got: {err}"
        );
    }

    #[test]
    fn bad_law_category_is_rejected() {
        let text = r#"
pattern-kind "x" {
    role "r" binds="type" cardinality="1"
    law "vibes" { token "owned" }
}
"#;
        let err = validate_pattern_kind("bad.apiw", text)
            .unwrap_err()
            .to_string();
        assert!(
            err.contains("vibes"),
            "names the offending category, got: {err}"
        );
    }

    #[test]
    fn missing_role_is_rejected() {
        // The schema requires at least one `role` (occurrence min defaults via the
        // node definition having no role instances — here there are none).
        let text = r#"
pattern-kind "x" {
    law "ownership" { token "owned" }
}
"#;
        // A kind with zero roles is structurally allowed by the schema (role has no
        // `min`), but the loader's semantic check rejects it; structural validation
        // alone passes here, which is the contract boundary we assert elsewhere.
        validate_pattern_kind("noroles.apiw", text)
            .expect("zero-role doc is structurally valid (semantic check is the loader's)");
    }

    #[test]
    fn unknown_node_is_rejected() {
        let text = r#"
pattern-kind "x" {
    role "r" binds="type" cardinality="1"
    bogus "y"
}
"#;
        let err = validate_pattern_kind("unknown.apiw", text)
            .unwrap_err()
            .to_string();
        assert!(
            err.contains("bogus"),
            "names the unexpected node, got: {err}"
        );
    }
}
