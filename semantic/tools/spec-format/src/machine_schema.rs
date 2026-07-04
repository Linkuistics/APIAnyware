//! Schema validation of the **machine** interchange IR (`extracted.kdl` /
//! `resolved.kdl`) against the language-neutral KDL Schema contract
//! (`schemas/spec-format/machine-ir.kdl-schema`, ADR-0046 §5).
//!
//! This is the ws8 payoff of flipping the machine IR to KDL: the machine artifact
//! is validated by the **same** generic engine the authored `.apiw` overlay uses
//! ([`crate::schema::validate_against_schema`]) — one schema language over every
//! artifact, the machine-JSON-Schema seam every prior workstream deferred here
//! dissolved. This module is a thin wrapper: it embeds the contract (so validator
//! and contract can never drift — a unit test guards the embedded text parses)
//! and delegates to the shared engine. It layers **no** extra semantic checks:
//! unlike the twelve authored-`.apiw` schemas, the machine IR is generated (serde
//! controls its keys) rather than hand-authored, so there is no facet-conditional
//! vocabulary or cross-field rule the KDL Schema Language cannot already express.
//!
//! ## Why the contract is an *open* content model
//!
//! The machine IR is **derived**, gitignored, and evolves as the pipeline grows;
//! the schema is a corruption / language-neutral-contract check, not a
//! re-derivation of serde's guarantee. So `machine-ir.kdl-schema` tolerates
//! additive IR evolution (`other-nodes-allowed #true` throughout) while pinning
//! the document spine, entity identity, scalar types, and the `checkpoint` enum.
//! The schema header documents the altitude in full (the JiK on-disk shape, the
//! no-`$ref` / no-recursion limits, the accept-any recursion boundary).

use crate::error::Result;
use crate::schema::validate_against_schema;

/// The authoritative machine-IR contract, embedded from the `schemas/` domain so
/// the validator and the contract are one source of truth.
const MACHINE_SCHEMA_TEXT: &str =
    include_str!("../../../../schemas/spec-format/machine-ir.kdl-schema");

/// Validate machine IR (`extracted.kdl` or `resolved.kdl`) KDL 2.0 text against
/// the embedded machine-IR KDL Schema contract
/// (`schemas/spec-format/machine-ir.kdl-schema`).
///
/// `source_name` labels diagnostics (typically the file path). Returns `Ok(())`
/// when the document conforms; otherwise the first located violation. The same
/// generic engine as [`crate::validate_apiw`]; only the embedded contract differs.
pub fn validate_machine_kdl(source_name: &str, text: &str) -> Result<()> {
    validate_against_schema(MACHINE_SCHEMA_TEXT, source_name, text)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::jik;
    use apianyware_types::ir::Framework;
    use serde_json::json;

    /// The embedded contract must itself be a valid KDL Schema — otherwise every
    /// call would fail with "the supplied KDL Schema is invalid". Guards the
    /// validator and the contract against drift (the `schema.rs` equivalent test).
    #[test]
    fn embedded_machine_schema_is_a_valid_contract() {
        // A trivially-valid machine doc round-trips through the validator; if the
        // embedded schema were malformed, this surfaces it as a schema error.
        validate_machine_kdl(
            "probe.kdl",
            "\"name\" \"X\"\n\"checkpoint\" \"extracted\"\n",
        )
        .expect("the embedded machine-ir.kdl-schema must be a valid KDL Schema");
    }

    /// A minimal well-formed machine document conforms.
    #[test]
    fn minimal_valid_machine_doc_passes() {
        let text = "\"checkpoint\" \"extracted\"\n\"name\" \"Foundation\"\n";
        validate_machine_kdl("ok.kdl", text).expect("minimal valid machine IR passes");
    }

    /// A real `Framework` serialized through the production JiK codec conforms —
    /// the two conforming implementations (the codec's emitter and this schema)
    /// agree, exactly as `written_overlay_validates_against_the_schema` pins the
    /// authored side. Exercises every declaration array + the resolved-only
    /// document nodes + the TypeRef recursion boundary.
    #[test]
    fn jik_emitted_framework_validates() {
        let value = json!({
            "format_version": "1.0",
            "checkpoint": "resolved",
            "name": "Foundation",
            "sdk_version": "15.4",
            "collected_at": "2026-06-24T11:05:39+00:00",
            "depends_on": ["CoreFoundation"],
            "skipped_symbols": [ { "name": "NSFoo", "kind": "class", "reason": "unsupported" } ],
            "classes": [ {
                "name": "NSString", "super": "NSObject",
                "protocols": ["NSCopying"],
                "objc_exposed": true,
                "properties": [ { "name": "length", "type": { "kind": "primitive", "name": "NSUInteger" }, "readonly": true } ],
                "methods": [ {
                    "selector": "initWithBytes:length:encoding:",
                    "class_method": false, "init_method": true,
                    "params": [ { "name": "bytes", "type": { "kind": "pointer" } } ],
                    "return_type": { "kind": "instancetype", "nullable": false },
                    "provenance": { "header": "NSString.h", "line": 42 },
                    "doc_refs": { "usr": "c:objc(cs)NSString" }
                } ],
                "all_methods": [ { "selector": "self", "return_type": { "kind": "id" }, "origin": "NSObject" } ],
                "ancestors": ["NSObject"]
            } ],
            "protocols": [ { "name": "NSCopying", "required_methods": [ { "selector": "copyWithZone:", "return_type": { "kind": "id" } } ] } ],
            "enums": [ { "name": "NSComparisonResult", "type": { "kind": "primitive", "name": "long" }, "values": [ { "name": "NSOrderedAscending", "value": -1 } ] } ],
            "structs": [ { "name": "NSRange", "fields": [ { "name": "location", "type": { "kind": "primitive", "name": "NSUInteger" } } ] } ],
            "functions": [ { "name": "NSStringFromRange", "params": [ { "name": "range", "type": { "kind": "struct", "name": "NSRange" } } ], "return_type": { "kind": "class", "name": "NSString" }, "inline": false } ],
            "constants": [ { "name": "NSUTF8StringEncoding", "type": { "kind": "alias", "name": "NSStringEncoding" } } ],
            "class_annotations": [ { "class_name": "NSString", "methods": [] } ],
            "patterns": [],
            "enrichment": {},
            "verification": { "passed": true }
        });
        // Emit through the *production* codec so this exercises the real on-disk shape.
        let text = jik::emit(&value);
        validate_machine_kdl("emitted.kdl", &text).unwrap_or_else(|e| {
            panic!("JiK-emitted Framework must validate against the machine schema:\n{text}\n{e}")
        });

        // And the shape decodes back to a Framework (belt-and-braces: the doc the
        // schema accepted is a real, deserializable IR, not just schema-shaped).
        let _fw: Framework =
            serde_json::from_value(value).expect("fixture is a deserializable Framework");
    }

    /// A wrong-typed scalar is rejected with a located error naming the offender.
    #[test]
    fn wrong_scalar_type_is_rejected() {
        // `checkpoint` must be a string; a number violates the `value` type.
        let text = "\"name\" \"X\"\n\"checkpoint\" 7\n";
        let err = validate_machine_kdl("bad.kdl", text)
            .unwrap_err()
            .to_string();
        assert!(
            err.contains("checkpoint") && err.contains("string"),
            "should name the mistyped node + expected type, got: {err}"
        );
    }

    /// The `checkpoint` enum is the schema's sharpest semantic check.
    #[test]
    fn out_of_phase_checkpoint_is_rejected() {
        let text = "\"name\" \"X\"\n\"checkpoint\" \"annotated\"\n";
        let err = validate_machine_kdl("phase.kdl", text)
            .unwrap_err()
            .to_string();
        assert!(
            err.contains("annotated"),
            "should name the offending checkpoint value, got: {err}"
        );
    }

    /// A truncated declaration entity (a class with no `name`) is caught by the
    /// identity min-bound even under the open content model.
    #[test]
    fn class_without_identity_is_rejected() {
        // `(array)"classes" { (object)- { "super" "NSObject" } }` — a class element
        // missing its required `name`.
        let text = "\"name\" \"X\"\n\"checkpoint\" \"extracted\"\n\
                    (array)\"classes\" {\n  (object)- {\n    \"super\" \"NSObject\"\n  }\n}\n";
        let err = validate_machine_kdl("noname.kdl", text)
            .unwrap_err()
            .to_string();
        assert!(
            err.contains("name"),
            "should report the missing identity node, got: {err}"
        );
    }
}
