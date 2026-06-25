//! The authored target descriptor: `target.apiw` (KDL 2.0) → the typed
//! [`TargetDescriptor`], plus the **semantic** checks the language-neutral KDL Schema
//! cannot state.
//!
//! Parsing runs in two layers, mirroring `apianyware-app-kinds`:
//!
//! 1. **Structural** — [`crate::descriptor::schema::validate_target`] checks the document
//!    against `target.kdl-schema` (node shapes, the `runtime-model` enum, occurrence
//!    cardinality, default-deny of unknown nodes). Run by the loader *before*
//!    [`parse_target`].
//! 2. **Semantic** — this module, after a clean parse: every facet token is
//!    non-blank (a structurally-present-but-empty token is an authoring slip the
//!    generic schema's `min 1` value-count does not catch for whitespace).
//!
//! The descriptor's identity (id = containing directory) is a registry-level check
//! ([`crate::descriptor::registry`]) — the parse layer is path-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! target "sbcl" {
//!     doc "Steel Bank Common Lisp with a CLOS/MOP binding style."
//!     family "common-lisp"
//!     dialect "ansi-cl"
//!     implementation "sbcl"
//!     ffi-backend "sb-alien"
//!     runtime-model "compiled-ffi"
//!     projection-policy "thin-direct"
//!     adapter-strategy "sole-native-unit"
//! }
//! ```
//!
//! The `runtime-model` value (`interpreted-ffi` / `compiled-ffi`) is the *serde*
//! vocabulary of [`RuntimeModel`] — the single source of truth — so its `.apiw`
//! spelling always matches the typed model. The other facets are open token strings.

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::error::{Result, TargetModelError};
use crate::descriptor::model::{RuntimeModel, TargetDescriptor};

/// Parse a `target.apiw` (KDL 2.0) document into the typed model and run the
/// semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document
/// has already passed [`crate::descriptor::schema::validate_target`]; it still guards
/// every access so a direct call without structural validation yields a located error
/// rather than a panic. Syntactic KDL errors forward the `kdl` crate's diagnostic;
/// semantic violations carry the offending node's span.
pub fn parse_target(source_name: &str, text: &str) -> Result<TargetDescriptor> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "target")
        .ok_or_else(|| ctx.err(doc.span(), "expected a top-level `target \"<id>\"` node"))?;

    let descriptor = ctx.parse_descriptor(node)?;
    ctx.check_semantics(&descriptor, node)?;
    Ok(descriptor)
}

/// Parsing context — carries what located errors need.
struct Ctx<'a> {
    source_name: &'a str,
    text: &'a str,
}

impl Ctx<'_> {
    fn err(&self, span: SourceSpan, message: impl Into<String>) -> TargetModelError {
        TargetModelError::apiw(self.source_name, self.text, span, message)
    }

    /// First positional argument of `node`, as a string.
    fn required_string_arg(&self, node: &KdlNode, what: &str) -> Result<String> {
        match node.get(0).and_then(KdlValue::as_string) {
            Some(s) => Ok(s.to_string()),
            None => Err(self.err(node.span(), format!("`{what}` needs a string argument"))),
        }
    }

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    fn parse_descriptor(&self, node: &KdlNode) -> Result<TargetDescriptor> {
        let id = self.required_string_arg(node, "target")?;
        let mut doc = None;
        let mut family = None;
        let mut dialect = None;
        let mut implementation = None;
        let mut ffi_backend = None;
        let mut runtime_model = None;
        let mut projection_policy = None;
        let mut adapter_strategy = None;

        for child in children_of(node) {
            match child.name().value() {
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                "family" => family = Some(self.required_string_arg(child, "family")?),
                "dialect" => dialect = Some(self.required_string_arg(child, "dialect")?),
                "implementation" => {
                    implementation = Some(self.required_string_arg(child, "implementation")?)
                }
                "ffi-backend" => {
                    ffi_backend = Some(self.required_string_arg(child, "ffi-backend")?)
                }
                "runtime-model" => {
                    runtime_model = Some(self.enum_arg::<RuntimeModel>(child, "runtime model")?)
                }
                "projection-policy" => {
                    projection_policy =
                        Some(self.required_string_arg(child, "projection-policy")?)
                }
                "adapter-strategy" => {
                    adapter_strategy =
                        Some(self.required_string_arg(child, "adapter-strategy")?)
                }
                other => {
                    return Err(
                        self.err(child.span(), format!("unexpected node `{other}` in target"))
                    )
                }
            }
        }

        Ok(TargetDescriptor {
            id,
            doc,
            family: family
                .ok_or_else(|| self.err(node.span(), "target is missing `family`"))?,
            dialect,
            implementation: implementation
                .ok_or_else(|| self.err(node.span(), "target is missing `implementation`"))?,
            ffi_backend: ffi_backend
                .ok_or_else(|| self.err(node.span(), "target is missing `ffi-backend`"))?,
            runtime_model: runtime_model
                .ok_or_else(|| self.err(node.span(), "target is missing `runtime-model`"))?,
            projection_policy: projection_policy
                .ok_or_else(|| self.err(node.span(), "target is missing `projection-policy`"))?,
            adapter_strategy: adapter_strategy
                .ok_or_else(|| self.err(node.span(), "target is missing `adapter-strategy`"))?,
        })
    }

    /// The coherence rules the language-neutral schema cannot state: every facet
    /// token is non-blank (the schema's `min 1` value-count accepts a `""` or
    /// whitespace token, which is an authoring slip). `node` locates errors.
    fn check_semantics(&self, d: &TargetDescriptor, node: &KdlNode) -> Result<()> {
        let mut tokens: Vec<(&str, &str)> = vec![
            ("target id", d.id.as_str()),
            ("family", d.family.as_str()),
            ("implementation", d.implementation.as_str()),
            ("ffi-backend", d.ffi_backend.as_str()),
            ("projection-policy", d.projection_policy.as_str()),
            ("adapter-strategy", d.adapter_strategy.as_str()),
        ];
        if let Some(dialect) = &d.dialect {
            tokens.push(("dialect", dialect.as_str()));
        }
        for (what, token) in tokens {
            if token.trim().is_empty() {
                return Err(self.err(
                    node.span(),
                    format!("target `{}` has a blank `{what}` token", d.id),
                ));
            }
        }
        Ok(())
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

    const SBCL: &str = r#"
        target "sbcl" {
            doc "Steel Bank Common Lisp with a CLOS/MOP binding style."
            family "common-lisp"
            dialect "ansi-cl"
            implementation "sbcl"
            ffi-backend "sb-alien"
            runtime-model "compiled-ffi"
            projection-policy "thin-direct"
            adapter-strategy "sole-native-unit"
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let d = parse_target("sbcl/target.apiw", SBCL).expect("parses");
        assert_eq!(d.id, "sbcl");
        assert_eq!(d.family, "common-lisp");
        assert_eq!(d.dialect.as_deref(), Some("ansi-cl"));
        assert_eq!(d.implementation, "sbcl");
        assert_eq!(d.ffi_backend, "sb-alien");
        assert_eq!(d.runtime_model, RuntimeModel::CompiledFfi);
        assert_eq!(d.projection_policy, "thin-direct");
        assert_eq!(d.adapter_strategy, "sole-native-unit");
    }

    #[test]
    fn parses_optional_dialect_omitted() {
        let text = r#"
            target "gerbil" {
                family "scheme"
                implementation "gerbil"
                ffi-backend "std-foreign"
                runtime-model "compiled-ffi"
                projection-policy "thin-direct"
                adapter-strategy "trampoline-only"
            }
        "#;
        let d = parse_target("gerbil/target.apiw", text).expect("parses");
        assert_eq!(d.dialect, None);
        assert_eq!(d.runtime_model, RuntimeModel::CompiledFfi);
    }

    #[test]
    fn parses_interpreted_ffi() {
        let text = r#"
            target "racket" {
                family "scheme"
                dialect "racket"
                implementation "racket-cs"
                ffi-backend "ffi2"
                runtime-model "interpreted-ffi"
                projection-policy "thin-direct"
                adapter-strategy "trampoline-and-bridges"
            }
        "#;
        let d = parse_target("racket/target.apiw", text).expect("parses");
        assert_eq!(d.runtime_model, RuntimeModel::InterpretedFfi);
    }

    #[test]
    fn rejects_missing_required_facet() {
        // No `ffi-backend`.
        let text = r#"
            target "x" {
                family "scheme"
                implementation "x-impl"
                runtime-model "compiled-ffi"
                projection-policy "thin-direct"
                adapter-strategy "trampoline-only"
            }
        "#;
        let err = parse_target("x/target.apiw", text).expect_err("missing ffi-backend rejected");
        assert!(format!("{err}").contains("missing `ffi-backend`"));
    }

    #[test]
    fn rejects_unknown_runtime_model() {
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
        let err = parse_target("x/target.apiw", text).expect_err("unknown runtime model rejected");
        assert!(format!("{err}").contains("not a valid runtime model"));
    }

    #[test]
    fn rejects_unexpected_node() {
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
        let err = parse_target("x/target.apiw", text).expect_err("unexpected node rejected");
        assert!(format!("{err}").contains("unexpected node `rocket`"));
    }

    #[test]
    fn rejects_blank_facet_token() {
        let text = r#"
            target "x" {
                family ""
                implementation "x-impl"
                ffi-backend "magic"
                runtime-model "compiled-ffi"
                projection-policy "thin-direct"
                adapter-strategy "trampoline-only"
            }
        "#;
        let err = parse_target("x/target.apiw", text).expect_err("blank family rejected");
        assert!(format!("{err}").contains("blank `family` token"));
    }
}
