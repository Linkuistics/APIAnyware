//! The authored pattern-kind overlay: `<kind>.apiw` (KDL 2.0) → the typed
//! [`PatternKind`] model, plus the **semantic** checks the language-neutral KDL
//! Schema cannot state.
//!
//! Parsing runs in two layers, mirroring `apianyware-spec-format`:
//!
//! 1. **Structural** — [`crate::schema::validate_pattern_kind`] checks the
//!    document against `pattern-kinds.kdl-schema` (node shapes, enums, cardinality).
//!    Run by the loader *before* [`parse_kind`].
//! 2. **Semantic** — this module, after a clean parse: every `law` token is a
//!    member of its category's §30 vocabulary ([`crate::vocab`]); every `ordering`
//!    edge names a declared role; role names are unique. These are the DP1/DP2
//!    invariants that make the registry non-vacuous and internally coherent.
//!
//! ## Grammar
//!
//! ```kdl
//! pattern-kind "bracket" {
//!     doc "acquire → operation* → release; release runs even on failure."
//!     role "acquire"   binds="operation" cardinality="1"
//!     role "operation" binds="operation" cardinality="*"
//!     role "release"   binds="operation" cardinality="1"
//!     ordering {
//!         before "acquire" "operation"
//!         before "operation" "release"
//!     }
//!     law "error" {
//!         token "cleanup-required-after-partial-failure"
//!         doc "release must run even when an operation fails"
//!     }
//! }
//! ```
//!
//! Enum string values (`operation`, `1`/`?`/`*`/`+`, `error`, …) are the *serde*
//! vocabulary — the single source of truth — so a value's `.apiw` spelling always
//! matches the typed model.

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::error::{PatternError, Result};
use crate::kind::{
    BeforeEdge, Cardinality, Law, LawCategory, Ordering, PatternKind, Role, RoleBinds,
};
use crate::vocab;

/// Parse a pattern-kind `.apiw` (KDL 2.0) document into the typed model and run
/// the semantic checks.
///
/// `source_name` labels diagnostics (typically the file name). Assumes the
/// document has already passed [`crate::schema::validate_pattern_kind`]; it still
/// guards every access so a direct call without structural validation yields a
/// located error rather than a panic. Syntactic KDL errors forward the `kdl`
/// crate's diagnostic; semantic violations carry the offending node's span.
pub fn parse_kind(source_name: &str, text: &str) -> Result<PatternKind> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "pattern-kind")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `pattern-kind \"<name>\"` node",
            )
        })?;

    let kind = ctx.parse_pattern_kind(node)?;
    ctx.check_semantics(&kind, node)?;
    Ok(kind)
}

/// Parsing context — carries what located errors need.
struct Ctx<'a> {
    source_name: &'a str,
    text: &'a str,
}

impl Ctx<'_> {
    fn err(&self, span: SourceSpan, message: impl Into<String>) -> PatternError {
        PatternError::apiw(self.source_name, self.text, span, message)
    }

    /// First positional argument of `node`, as a string.
    fn required_string_arg(&self, node: &KdlNode, what: &str) -> Result<String> {
        match node.get(0).and_then(KdlValue::as_string) {
            Some(s) => Ok(s.to_string()),
            None => Err(self.err(node.span(), format!("`{what}` needs a string argument"))),
        }
    }

    /// A required string property on `node`.
    fn required_string_prop(&self, node: &KdlNode, key: &str) -> Result<String> {
        match node.get(key).and_then(KdlValue::as_string) {
            Some(s) => Ok(s.to_string()),
            None => Err(self.err(
                node.span(),
                format!("`{}` needs a `{key}=\"…\"` property", node.name().value()),
            )),
        }
    }

    /// Decode a serde enum token from a node's string property.
    fn enum_prop<T: DeserializeOwned>(&self, node: &KdlNode, key: &str, kind: &str) -> Result<T> {
        let token = self.required_string_prop(node, key)?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    fn parse_pattern_kind(&self, node: &KdlNode) -> Result<PatternKind> {
        let name = self.required_string_arg(node, "pattern-kind")?;
        let mut doc = None;
        let mut roles = Vec::new();
        let mut ordering = None;
        let mut laws = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                "role" => roles.push(self.parse_role(child)?),
                "ordering" => ordering = Some(self.parse_ordering(child)?),
                "law" => laws.push(self.parse_law(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in pattern-kind"),
                    ))
                }
            }
        }

        Ok(PatternKind {
            name,
            doc,
            roles,
            ordering,
            laws,
        })
    }

    fn parse_role(&self, node: &KdlNode) -> Result<Role> {
        let name = self.required_string_arg(node, "role")?;
        let binds = self.enum_prop::<RoleBinds>(node, "binds", "role binding")?;
        // `cardinality` is optional; absent means exactly one.
        let cardinality = match node.get("cardinality") {
            Some(_) => self.enum_prop::<Cardinality>(node, "cardinality", "cardinality")?,
            None => Cardinality::One,
        };
        // `primary` is an optional boolean; absent means not primary (DP3).
        let primary = match node.get("primary") {
            Some(value) => value.as_bool().ok_or_else(|| {
                self.err(
                    node.span(),
                    "`role` property `primary` must be a boolean (#true/#false)",
                )
            })?,
            None => false,
        };
        Ok(Role {
            name,
            binds,
            cardinality,
            primary,
        })
    }

    fn parse_ordering(&self, node: &KdlNode) -> Result<Ordering> {
        let mut before = Vec::new();
        for child in children_of(node) {
            match child.name().value() {
                "before" => {
                    let earlier = self.positional_string(child, 0, "before")?;
                    let later = self.positional_string(child, 1, "before")?;
                    before.push(BeforeEdge { earlier, later });
                }
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in ordering (want `before`)"),
                    ))
                }
            }
        }
        Ok(Ordering { before })
    }

    fn parse_law(&self, node: &KdlNode) -> Result<Law> {
        let category = self.enum_arg::<LawCategory>(node, "law category")?;
        let mut tokens = Vec::new();
        let mut doc = None;
        for child in children_of(node) {
            match child.name().value() {
                "token" => tokens.push(self.required_string_arg(child, "token")?),
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in law (want `token` or `doc`)"),
                    ))
                }
            }
        }
        Ok(Law {
            category,
            tokens,
            doc,
        })
    }

    /// The nth positional string argument of `node`.
    fn positional_string(&self, node: &KdlNode, index: usize, what: &str) -> Result<String> {
        match node.get(index).and_then(KdlValue::as_string) {
            Some(s) => Ok(s.to_string()),
            None => Err(self.err(
                node.span(),
                format!("`{what}` needs a string argument at position {index}"),
            )),
        }
    }

    /// The DP1/DP2 invariants the language-neutral schema cannot state: every law
    /// token ∈ its category's §30 vocabulary; every `ordering` edge names a
    /// declared role; role names are unique. `node` is the `pattern-kind` node,
    /// used to locate errors.
    fn check_semantics(&self, kind: &PatternKind, node: &KdlNode) -> Result<()> {
        // At least one role (the schema cannot require ≥1 cleanly).
        if kind.roles.is_empty() {
            return Err(self.err(
                node.span(),
                format!("pattern-kind `{}` declares no roles", kind.name),
            ));
        }

        // Role names unique.
        let mut seen = std::collections::BTreeSet::new();
        for role in &kind.roles {
            if !seen.insert(role.name.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "pattern-kind `{}` declares role `{}` more than once",
                        kind.name, role.name
                    ),
                ));
            }
        }

        // At most one role is the designated primary (DP3 home anchor).
        let primary_count = kind.roles.iter().filter(|r| r.primary).count();
        if primary_count > 1 {
            return Err(self.err(
                node.span(),
                format!(
                    "pattern-kind `{}` marks {primary_count} roles `primary`; at most one is allowed",
                    kind.name
                ),
            ));
        }

        // Every law token belongs to its category's §30 vocabulary (DP1).
        for law in &kind.laws {
            for token in &law.tokens {
                if !vocab::is_valid_token(law.category, token) {
                    return Err(self.err(
                        node.span(),
                        format!(
                            "law token `{token}` is not in the `{}` vocabulary (REFACTOR §30); \
                             a law's tokens must come from its category's controlled set",
                            category_label(law.category)
                        ),
                    ));
                }
            }
        }

        // Every ordering edge names declared roles.
        if let Some(ordering) = &kind.ordering {
            for edge in &ordering.before {
                for role_name in [&edge.earlier, &edge.later] {
                    if kind.role(role_name).is_none() {
                        return Err(self.err(
                            node.span(),
                            format!(
                                "ordering edge names role `{role_name}`, which is not declared in \
                                 pattern-kind `{}`",
                                kind.name
                            ),
                        ));
                    }
                }
            }
        }

        Ok(())
    }
}

/// The serde `snake_case` label of a law category — for error messages.
fn category_label(category: LawCategory) -> String {
    match serde_json::to_value(category) {
        Ok(serde_json::Value::String(s)) => s,
        other => other.map(|v| v.to_string()).unwrap_or_default(),
    }
}

/// Decode a token into a serde enum. Returns `None` on an unknown token.
fn decode_enum<T: DeserializeOwned>(token: &str) -> Option<T> {
    serde_json::from_value(serde_json::Value::String(token.to_string())).ok()
}

/// The child nodes of `node`, or an empty slice if it has no `{ … }` block.
fn children_of(node: &KdlNode) -> &[KdlNode] {
    node.children().map(KdlDocument::nodes).unwrap_or(&[])
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_behavioral_kind() {
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
        let kind = parse_kind("bracket.apiw", text).expect("parses");
        assert_eq!(kind.name, "bracket");
        assert_eq!(
            kind.doc.as_deref(),
            Some("acquire then operate then release")
        );
        assert_eq!(kind.roles.len(), 3);
        assert_eq!(
            kind.role("operation").unwrap().cardinality,
            Cardinality::Many
        );
        assert!(kind.is_behavioral());
        let ordering = kind.ordering.as_ref().unwrap();
        assert_eq!(ordering.before.len(), 2);
        assert_eq!(kind.laws[0].category, LawCategory::Error);
    }

    #[test]
    fn parses_primary_role_marker() {
        // DP3: a role may be marked the designated primary (home anchor).
        let text = r#"
pattern-kind "parent-child" {
    role "parent" binds="type" primary=#true
    role "child"  binds="type"
    law "relationship" { token "parent-owns-child" }
}
"#;
        let kind = parse_kind("parent-child.apiw", text).expect("parses");
        assert!(kind.role("parent").unwrap().primary, "parent is primary");
        assert!(
            !kind.role("child").unwrap().primary,
            "an unmarked role is not primary"
        );
    }

    #[test]
    fn rejects_two_primary_roles() {
        let text = r#"
pattern-kind "x" {
    role "a" binds="type" primary=#true
    role "b" binds="type" primary=#true
}
"#;
        let err = parse_kind("x.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("primary"),
            "explains the duplicate primary, got: {err}"
        );
    }

    #[test]
    fn parses_structural_kind_default_cardinality() {
        let text = r#"
pattern-kind "parent-child" {
    role "parent" binds="type"
    role "child"  binds="type"
    law "relationship" {
        token "parent-owns-child"
        token "child-borrows-parent"
    }
}
"#;
        let kind = parse_kind("parent-child.apiw", text).expect("parses");
        // Absent cardinality defaults to exactly one.
        assert_eq!(kind.role("parent").unwrap().cardinality, Cardinality::One);
        assert!(!kind.is_behavioral());
        assert_eq!(kind.laws[0].tokens.len(), 2);
    }

    #[test]
    fn parameter_bound_roles_for_single_operation_relationship() {
        // DP2: callback-destroy-notifier's roles all bind to one operation's params.
        let text = r#"
pattern-kind "callback-destroy-notifier" {
    role "callback"  binds="parameter"
    role "user-data" binds="parameter"
    role "destroy"   binds="parameter"
    law "callback" { token "callback-with-destroy-notifier" }
}
"#;
        let kind = parse_kind("cdn.apiw", text).expect("parses");
        assert!(kind.roles.iter().all(|r| r.binds == RoleBinds::Parameter));
    }

    #[test]
    fn pattern_bound_role_for_composition() {
        // DP5: a subscription's destroy role binds to another pattern-instance.
        let text = r#"
pattern-kind "subscription" {
    role "register" binds="operation"
    role "destroy"  binds="pattern" cardinality="?"
    law "relationship" { token "subscription-token-controls-lifetime" }
}
"#;
        let kind = parse_kind("subscription.apiw", text).expect("parses");
        assert_eq!(kind.role("destroy").unwrap().binds, RoleBinds::Pattern);
    }

    #[test]
    fn rejects_token_outside_category_vocabulary() {
        let text = r#"
pattern-kind "x" {
    role "r" binds="type"
    law "ownership" { token "main-thread-only" }
}
"#;
        let err = parse_kind("x.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("main-thread-only") && err.contains("ownership"),
            "explains the category mismatch, got: {err}"
        );
    }

    #[test]
    fn rejects_ordering_edge_naming_undeclared_role() {
        let text = r#"
pattern-kind "x" {
    role "acquire" binds="operation"
    role "release" binds="operation"
    ordering {
        before "acquire" "operate"
    }
}
"#;
        let err = parse_kind("x.apiw", text).unwrap_err().to_string();
        assert!(
            err.contains("operate"),
            "names the dangling role, got: {err}"
        );
    }

    #[test]
    fn rejects_duplicate_role_name() {
        let text = r#"
pattern-kind "x" {
    role "r" binds="type"
    role "r" binds="operation"
}
"#;
        let err = parse_kind("x.apiw", text).unwrap_err().to_string();
        assert!(err.contains("more than once"), "got: {err}");
    }

    #[test]
    fn rejects_zero_role_kind() {
        let text = r#"
pattern-kind "x" {
    law "ownership" { token "owned" }
}
"#;
        let err = parse_kind("x.apiw", text).unwrap_err().to_string();
        assert!(err.contains("no roles"), "got: {err}");
    }
}
