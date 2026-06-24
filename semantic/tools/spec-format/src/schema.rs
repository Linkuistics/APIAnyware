//! Schema validation of the authored `.apiw` overlay against the **language-neutral
//! KDL Schema contract** (`schemas/spec-format/annotations.kdl-schema`).
//!
//! ADR-0046 §3 makes the KDL Schema — not the Rust types — the authoritative
//! contract: any KDL tool in any language can validate an `.apiw` file. This
//! module is *one conforming validator* of that contract. The schema document is
//! [embedded][SCHEMA_TEXT] (`include_str!` from the `schemas/` domain) so the
//! validator and the contract can never drift; a unit test guards that the
//! embedded text parses.
//!
//! ## Why an in-crate validator
//!
//! The grilling (running-log F) chose the KDL Schema Language expecting
//! off-the-shelf tooling. There is none for KDL **2.0**: the language is frozen
//! at SCHEMA-SPEC 1.0 (2021, "not finalized" for 2.0) and its only Rust
//! validator (`kdl-schema-check`, 2022) targets the KDL-1.0 `kdl`/`knuffel`
//! stack — incompatible with our KDL-2.0 `kdl = 6.3.4`. So the crate ships a
//! focused validator that interprets the **subset** of the KDL Schema Language
//! the `.apiw` contract uses: `node` / `value` / `prop` / `children`, occurrence
//! and value-cardinality `min`/`max`, scalar `type`, `enum`, and the
//! default-deny `other-nodes-allowed` / `other-props-allowed`. Adopting (or
//! authoring) a general KDL-2.0 schema validator is left to **ws8**, which owns
//! the validation tooling/CI; this module is the §29 "validator step" until then.
//!
//! ## Errors
//!
//! Each violation is a located [`SpecFormatError::Apiw`] carrying the offending
//! node/entry span — the same diagnostic shape as the hand-written
//! [`crate::apiw`] parser. Validation fails on the first violation found (the
//! parser does likewise); collecting all violations is a possible ws8 refinement.

use std::sync::OnceLock;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;

use crate::error::{Result, SpecFormatError};

/// The authoritative `.apiw` contract, embedded from the `schemas/` domain so the
/// validator and the contract are one source of truth.
const SCHEMA_TEXT: &str = include_str!("../../../../schemas/spec-format/annotations.kdl-schema");

/// Validate `.apiw` (KDL 2.0) text against the embedded KDL Schema contract.
///
/// `source_name` labels diagnostics (typically the file name). Returns `Ok(())`
/// when the document conforms; otherwise the first located violation. Syntactic
/// KDL errors (a malformed document) forward the `kdl` crate's rich diagnostic.
pub fn validate_apiw(source_name: &str, text: &str) -> Result<()> {
    let model = schema_model();
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };
    ctx.check_children(
        doc.nodes(),
        &model.roots,
        model.other_nodes_allowed,
        doc.span(),
    )
}

/// The parsed contract, built once. Parsing our own embedded constant cannot
/// legitimately fail; a malformed schema is a crate bug, caught by
/// `embedded_schema_parses`.
fn schema_model() -> &'static SchemaModel {
    static MODEL: OnceLock<SchemaModel> = OnceLock::new();
    MODEL.get_or_init(|| {
        SchemaModel::parse(SCHEMA_TEXT)
            .expect("embedded annotations.kdl-schema must be a valid KDL Schema")
    })
}

// ===========================================================================
// Schema model — the subset of the KDL Schema Language the `.apiw` contract uses
// ===========================================================================

/// The top level of a parsed KDL Schema `document`.
#[derive(Debug)]
struct SchemaModel {
    /// Top-level node definitions (the document's direct `node` children).
    roots: Vec<NodeDef>,
    /// Whether top-level nodes outside `roots` are permitted (default: no).
    other_nodes_allowed: bool,
}

/// A `node "<name>" { … }` definition.
#[derive(Debug)]
struct NodeDef {
    /// The node name this definition matches.
    name: String,
    /// Minimum occurrences among siblings of the same name (default 0).
    min: usize,
    /// Maximum occurrences (default: unbounded).
    max: Option<usize>,
    /// The positional-value spec, if the node carries values.
    value: Option<ValueDef>,
    /// Property specs.
    props: Vec<PropDef>,
    /// Child node definitions.
    children: Vec<NodeDef>,
    /// Whether child nodes outside `children` are permitted (default: no).
    other_nodes_allowed: bool,
    /// Whether props outside `props` are permitted (default: no).
    other_props_allowed: bool,
}

/// A `value { … }` spec: the node's positional arguments.
#[derive(Debug)]
struct ValueDef {
    ty: Option<ScalarType>,
    /// Minimum number of positional values (default 0).
    min: usize,
    /// Maximum number of positional values (default: unbounded).
    max: Option<usize>,
    /// Allowed string values; empty means unconstrained.
    enum_values: Vec<String>,
}

/// A `prop "<key>" { … }` spec.
#[derive(Debug)]
struct PropDef {
    key: String,
    ty: Option<ScalarType>,
    required: bool,
    enum_values: Vec<String>,
}

/// The scalar KDL value types the contract distinguishes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ScalarType {
    String,
    Number,
    Boolean,
}

impl ScalarType {
    fn parse(s: &str) -> Option<Self> {
        match s {
            "string" => Some(Self::String),
            "number" => Some(Self::Number),
            "boolean" => Some(Self::Boolean),
            _ => None,
        }
    }

    fn matches(self, value: &KdlValue) -> bool {
        match self {
            Self::String => value.as_string().is_some(),
            Self::Number => value.as_integer().is_some() || value.as_float().is_some(),
            Self::Boolean => value.as_bool().is_some(),
        }
    }

    fn label(self) -> &'static str {
        match self {
            Self::String => "string",
            Self::Number => "number",
            Self::Boolean => "boolean",
        }
    }
}

// ---------------------------------------------------------------------------
// Schema parsing (over our own embedded constant — lenient, panics via expect)
// ---------------------------------------------------------------------------

impl SchemaModel {
    fn parse(text: &str) -> std::result::Result<Self, String> {
        let doc = KdlDocument::parse(text).map_err(|e| e.to_string())?;
        let document = doc
            .nodes()
            .iter()
            .find(|n| n.name().value() == "document")
            .ok_or_else(|| "schema is missing the top-level `document` node".to_string())?;

        let body = children_of(document);
        Ok(SchemaModel {
            roots: node_defs(body),
            other_nodes_allowed: flag(body, "other-nodes-allowed"),
        })
    }
}

/// Parse every `node "<name>" { … }` definition in a definition body.
fn node_defs(body: &[KdlNode]) -> Vec<NodeDef> {
    body.iter()
        .filter(|n| n.name().value() == "node")
        .filter_map(parse_node_def)
        .collect()
}

fn parse_node_def(node: &KdlNode) -> Option<NodeDef> {
    let name = node.get(0)?.as_string()?.to_string();
    let body = children_of(node);

    let mut def = NodeDef {
        name,
        min: 0,
        max: None,
        value: None,
        props: Vec::new(),
        children: Vec::new(),
        other_nodes_allowed: false,
        other_props_allowed: false,
    };

    for child in body {
        match child.name().value() {
            "min" => def.min = usize_arg(child).unwrap_or(0),
            "max" => def.max = usize_arg(child),
            "value" => def.value = Some(parse_value_def(child)),
            "prop" => {
                if let Some(prop) = parse_prop_def(child) {
                    def.props.push(prop);
                }
            }
            "children" => def.children = node_defs(children_of(child)),
            "other-nodes-allowed" => def.other_nodes_allowed = bool_arg(child),
            "other-props-allowed" => def.other_props_allowed = bool_arg(child),
            _ => {}
        }
    }
    Some(def)
}

fn parse_value_def(node: &KdlNode) -> ValueDef {
    let mut def = ValueDef {
        ty: None,
        min: 0,
        max: None,
        enum_values: Vec::new(),
    };
    for child in children_of(node) {
        match child.name().value() {
            "type" => {
                def.ty = child
                    .get(0)
                    .and_then(KdlValue::as_string)
                    .and_then(ScalarType::parse)
            }
            "min" => def.min = usize_arg(child).unwrap_or(0),
            "max" => def.max = usize_arg(child),
            "enum" => def.enum_values = string_args(child),
            _ => {}
        }
    }
    def
}

fn parse_prop_def(node: &KdlNode) -> Option<PropDef> {
    let key = node.get(0)?.as_string()?.to_string();
    let mut def = PropDef {
        key,
        ty: None,
        required: false,
        enum_values: Vec::new(),
    };
    for child in children_of(node) {
        match child.name().value() {
            "type" => {
                def.ty = child
                    .get(0)
                    .and_then(KdlValue::as_string)
                    .and_then(ScalarType::parse)
            }
            "required" => def.required = bool_arg(child),
            "enum" => def.enum_values = string_args(child),
            _ => {}
        }
    }
    Some(def)
}

// ---------------------------------------------------------------------------
// Validation (over a target `.apiw` document — produces located errors)
// ---------------------------------------------------------------------------

/// Validation context — what located errors need.
struct Ctx<'a> {
    source_name: &'a str,
    text: &'a str,
}

impl Ctx<'_> {
    fn err(&self, span: SourceSpan, message: impl Into<String>) -> SpecFormatError {
        SpecFormatError::apiw(self.source_name, self.text, span, message)
    }

    /// Validate a set of sibling node instances against the node definitions that
    /// govern them (occurrence bounds + unknown-node rejection + per-node checks).
    fn check_children(
        &self,
        instances: &[KdlNode],
        defs: &[NodeDef],
        other_nodes_allowed: bool,
        parent_span: SourceSpan,
    ) -> Result<()> {
        // Each instance must match a definition (or be allowed as an extra).
        for instance in instances {
            let name = instance.name().value();
            match defs.iter().find(|d| d.name == name) {
                Some(def) => self.check_node(instance, def)?,
                None if other_nodes_allowed => {}
                None => {
                    return Err(self.err(
                        instance.span(),
                        format!("unexpected node `{name}` (not allowed by the schema here)"),
                    ))
                }
            }
        }
        // Each definition's occurrence bounds must hold.
        for def in defs {
            let matches: Vec<&KdlNode> = instances
                .iter()
                .filter(|n| n.name().value() == def.name)
                .collect();
            if matches.len() < def.min {
                let what = if def.min == 1 {
                    format!("a required `{}` node is missing", def.name)
                } else {
                    format!(
                        "expected at least {} `{}` nodes, found {}",
                        def.min,
                        def.name,
                        matches.len()
                    )
                };
                return Err(self.err(parent_span, what));
            }
            if let Some(max) = def.max {
                if matches.len() > max {
                    // Point at the first offending (max+1)th instance.
                    let span = matches[max].span();
                    return Err(self.err(
                        span,
                        format!(
                            "at most {} `{}` node(s) allowed, found {}",
                            max,
                            def.name,
                            matches.len()
                        ),
                    ));
                }
            }
        }
        Ok(())
    }

    /// Validate one node instance against its definition: values, props, children.
    fn check_node(&self, instance: &KdlNode, def: &NodeDef) -> Result<()> {
        self.check_values(instance, def)?;
        self.check_props(instance, def)?;
        let kids = instance.children().map(KdlDocument::nodes).unwrap_or(&[]);
        self.check_children(
            kids,
            &def.children,
            def.other_nodes_allowed,
            instance.span(),
        )
    }

    /// Validate the node's positional arguments against its `value` spec.
    fn check_values(&self, instance: &KdlNode, def: &NodeDef) -> Result<()> {
        let args: Vec<&kdl::KdlEntry> = instance
            .entries()
            .iter()
            .filter(|e| e.name().is_none())
            .collect();

        let Some(vdef) = &def.value else {
            if args.is_empty() {
                return Ok(());
            }
            return Err(self.err(
                instance.span(),
                format!("node `{}` takes no positional value", def.name),
            ));
        };

        if args.len() < vdef.min || vdef.max.is_some_and(|m| args.len() > m) {
            return Err(self.err(
                instance.span(),
                format!(
                    "node `{}` expects {} positional value(s), found {}",
                    def.name,
                    cardinality(vdef.min, vdef.max),
                    args.len()
                ),
            ));
        }

        for arg in args {
            self.check_scalar(
                arg.value(),
                arg.span(),
                vdef.ty,
                &vdef.enum_values,
                &format!("value of `{}`", def.name),
            )?;
        }
        Ok(())
    }

    /// Validate the node's properties against its `prop` specs.
    fn check_props(&self, instance: &KdlNode, def: &NodeDef) -> Result<()> {
        // Required props must be present; present props must type/enum-check.
        for pdef in &def.props {
            match instance
                .entries()
                .iter()
                .find(|e| e.name().map(|n| n.value()) == Some(pdef.key.as_str()))
            {
                Some(entry) => self.check_scalar(
                    entry.value(),
                    entry.span(),
                    pdef.ty,
                    &pdef.enum_values,
                    &format!("prop `{}` of `{}`", pdef.key, def.name),
                )?,
                None if pdef.required => {
                    return Err(self.err(
                        instance.span(),
                        format!(
                            "node `{}` is missing the required `{}` property",
                            def.name, pdef.key
                        ),
                    ))
                }
                None => {}
            }
        }
        // Reject unknown props unless the node opts into extras.
        if !def.other_props_allowed {
            for entry in instance.entries() {
                if let Some(key) = entry.name().map(|n| n.value()) {
                    if !def.props.iter().any(|p| p.key == key) {
                        return Err(self.err(
                            entry.span(),
                            format!("unexpected property `{key}` on node `{}`", def.name),
                        ));
                    }
                }
            }
        }
        Ok(())
    }

    /// Type- and enum-check a single scalar value (a positional value or a prop).
    fn check_scalar(
        &self,
        value: &KdlValue,
        span: SourceSpan,
        ty: Option<ScalarType>,
        enum_values: &[String],
        what: &str,
    ) -> Result<()> {
        if let Some(ty) = ty {
            if !ty.matches(value) {
                return Err(self.err(span, format!("{what} must be a {}", ty.label())));
            }
        }
        if !enum_values.is_empty() {
            match value.as_string() {
                Some(s) if enum_values.iter().any(|v| v == s) => {}
                Some(s) => {
                    return Err(self.err(
                        span,
                        format!(
                            "`{s}` is not a valid {what} (expected one of: {})",
                            enum_values.join(", ")
                        ),
                    ))
                }
                None => {
                    return Err(self.err(
                        span,
                        format!("{what} must be one of: {}", enum_values.join(", ")),
                    ))
                }
            }
        }
        Ok(())
    }
}

// ---------------------------------------------------------------------------
// Small KDL helpers
// ---------------------------------------------------------------------------

/// A node's child nodes, or an empty slice if it has no `{ … }` block.
fn children_of(node: &KdlNode) -> &[KdlNode] {
    node.children().map(KdlDocument::nodes).unwrap_or(&[])
}

/// First positional argument of `node` as a non-negative integer.
fn usize_arg(node: &KdlNode) -> Option<usize> {
    node.get(0)
        .and_then(KdlValue::as_integer)
        .and_then(|i| usize::try_from(i).ok())
}

/// First positional argument of `node` as a boolean (absent ⇒ false).
fn bool_arg(node: &KdlNode) -> bool {
    node.get(0).and_then(KdlValue::as_bool).unwrap_or(false)
}

/// Read a boolean flag node (e.g. `other-nodes-allowed #true`) from a definition
/// body; absent ⇒ false (the KDL Schema default).
fn flag(body: &[KdlNode], name: &str) -> bool {
    body.iter()
        .find(|n| n.name().value() == name)
        .map(bool_arg)
        .unwrap_or(false)
}

/// Every positional string argument of `node` (e.g. an `enum "a" "b" "c"` list).
fn string_args(node: &KdlNode) -> Vec<String> {
    node.entries()
        .iter()
        .filter(|e| e.name().is_none())
        .filter_map(|e| e.value().as_string().map(str::to_string))
        .collect()
}

/// Render a `[min, max]` cardinality for an error message.
fn cardinality(min: usize, max: Option<usize>) -> String {
    match max {
        Some(max) if max == min => format!("exactly {min}"),
        Some(max) => format!("{min}..{max}"),
        None => format!("at least {min}"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_schema_parses() {
        let model = SchemaModel::parse(SCHEMA_TEXT).expect("embedded schema parses");
        // The contract's spine: exactly one top-level `framework` node.
        let framework = model
            .roots
            .iter()
            .find(|d| d.name == "framework")
            .expect("framework def");
        assert_eq!(framework.min, 1);
        assert_eq!(framework.max, Some(1));
    }

    #[test]
    fn minimal_valid_document_passes() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" is-instance=#true {
            source "llm"
        }
    }
}
"#;
        validate_apiw("ok.apiw", text).expect("minimal valid .apiw passes");
    }

    #[test]
    fn rich_valid_document_passes() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "enumerateObjectsUsingBlock:" is-instance=#true {
            param-ownership 0 ownership="copy"
            block-param 0 invocation="synchronous"
            threading "any_thread"
            source "heuristic"
        }
        method "writeToURL:error:" is-instance=#true {
            error-pattern "error_out_param"
            source "llm"
            confidence "high"
            provenance "Foundation Release Notes"
        }
    }
    subagent-report {
        block-synchronous 1
        threading-any-thread 1
    }
}
"#;
        validate_apiw("rich.apiw", text).expect("rich valid .apiw passes");
    }

    #[test]
    fn bad_enum_value_is_rejected() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" is-instance=#true {
            source "wizardry"
        }
    }
}
"#;
        let err = validate_apiw("bad.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("wizardry"),
            "names the offending value, got: {err}"
        );
    }

    #[test]
    fn missing_required_source_is_rejected() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" is-instance=#true {
            confidence "high"
        }
    }
}
"#;
        let err = validate_apiw("nosrc.apiw", text).unwrap_err().to_string();
        assert!(err.contains("source"), "names the missing node, got: {err}");
    }

    #[test]
    fn unknown_node_is_rejected() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" is-instance=#true {
            source "llm"
            bogus-node "x"
        }
    }
}
"#;
        let err = validate_apiw("unknown.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("bogus-node"),
            "names the unexpected node, got: {err}"
        );
    }

    #[test]
    fn missing_required_prop_is_rejected() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" {
            source "llm"
        }
    }
}
"#;
        let err = validate_apiw("noprop.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("is-instance"),
            "names the missing prop, got: {err}"
        );
    }

    #[test]
    fn wrong_prop_type_is_rejected() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" is-instance="yes" {
            source "llm"
        }
    }
}
"#;
        let err = validate_apiw("badtype.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("is-instance") && err.contains("boolean"),
            "got: {err}"
        );
    }

    #[test]
    fn too_many_singleton_nodes_is_rejected() {
        let text = r#"
framework "Foundation" {
    class "NSArray" {
        method "count" is-instance=#true {
            source "llm"
            source "manual"
        }
    }
}
"#;
        let err = validate_apiw("dupsrc.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("source"),
            "names the over-occurring node, got: {err}"
        );
    }
}
