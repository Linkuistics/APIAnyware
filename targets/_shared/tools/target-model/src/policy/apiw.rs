//! The authored projection policy: `policies/<platform>/projection.apiw` (KDL 2.0) → the
//! typed [`ProjectionPolicy`], plus the **semantic** checks the language-neutral KDL Schema
//! cannot state.
//!
//! Parsing runs in two layers, mirroring the sibling `idioms` / `capability` submodules:
//!
//! 1. **Structural** — [`crate::policy::schema::validate_policy`] checks the document
//!    against `policy.kdl-schema` (node shapes, the `spectrum` enum, occurrence
//!    cardinality, default-deny of unknown nodes). Run by the loader *before*
//!    [`parse_policy`].
//! 2. **Semantic** — this module, after a clean parse: each `choice` concern is unique
//!    within the policy (so the concern → choice lookup is unambiguous).
//!
//! The policy's identity (id = the target directory, platform = the parent directory) is a
//! registry-level check ([`crate::policy::registry`]) — the parse layer is path-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! projection-policy "racket" {
//!     platform "macos"
//!     doc "Racket's macOS projection posture."
//!     posture "thin-direct"
//!     choice "directly-reachable-objc" {
//!         spectrum "direct-call"
//!         doc "trampoline-elided objc_msgSend dispatch via ffi/unsafe/objc"
//!     }
//!     choice "swift-native-async" { spectrum "adapter-call-plus-wrapper" }
//! }
//! ```
//!
//! The `spectrum` value is the *serde* vocabulary of [`SpectrumPoint`] — the single source
//! of truth — so its `.apiw` spelling always matches the typed model.

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::error::{Result, TargetModelError};
use crate::policy::model::{ProjectionChoice, ProjectionPolicy, SpectrumPoint};

/// Parse a `policies/<platform>/projection.apiw` (KDL 2.0) document into the typed model and
/// run the semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document has
/// already passed [`crate::policy::schema::validate_policy`]; it still guards every access
/// so a direct call without structural validation yields a located error rather than a
/// panic.
pub fn parse_policy(source_name: &str, text: &str) -> Result<ProjectionPolicy> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "projection-policy")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `projection-policy \"<id>\"` node",
            )
        })?;

    let policy = ctx.parse_policy(node)?;
    ctx.check_semantics(&policy, node)?;
    Ok(policy)
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

    /// The optional `doc "<text>"` child of `node`, if present.
    fn optional_doc(&self, node: &KdlNode) -> Result<Option<String>> {
        match children_of(node).iter().find(|c| c.name().value() == "doc") {
            Some(d) => Ok(Some(self.required_string_arg(d, "doc")?)),
            None => Ok(None),
        }
    }

    fn parse_policy(&self, node: &KdlNode) -> Result<ProjectionPolicy> {
        let id = self.required_string_arg(node, "projection-policy")?;
        let doc = self.optional_doc(node)?;
        let mut platform = None;
        let mut posture = None;
        let mut choices = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "platform" => platform = Some(self.required_string_arg(child, "platform")?),
                "posture" => posture = Some(self.required_string_arg(child, "posture")?),
                "choice" => choices.push(self.parse_choice(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in projection-policy"),
                    ))
                }
            }
        }

        let platform = platform
            .ok_or_else(|| self.err(node.span(), "projection-policy is missing `platform`"))?;

        Ok(ProjectionPolicy {
            id,
            platform,
            doc,
            posture,
            choices,
        })
    }

    fn parse_choice(&self, node: &KdlNode) -> Result<ProjectionChoice> {
        let concern = self.required_string_arg(node, "choice")?;
        let mut spectrum = None;
        let mut doc = None;
        for child in children_of(node) {
            match child.name().value() {
                "spectrum" => {
                    spectrum = Some(self.enum_arg::<SpectrumPoint>(child, "spectrum point")?)
                }
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in choice `{concern}`"),
                    ))
                }
            }
        }
        Ok(ProjectionChoice {
            spectrum: spectrum.ok_or_else(|| {
                self.err(
                    node.span(),
                    format!("choice `{concern}` is missing `spectrum`"),
                )
            })?,
            concern,
            doc,
        })
    }

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    /// The cross-field coherence the language-neutral schema cannot state: each concern
    /// appears at most once (so [`ProjectionPolicy::choice`] is unambiguous). `node` locates
    /// errors.
    fn check_semantics(&self, policy: &ProjectionPolicy, node: &KdlNode) -> Result<()> {
        let mut seen = BTreeSet::new();
        for choice in &policy.choices {
            if !seen.insert(choice.concern.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "the policy maps concern `{}` more than once",
                        choice.concern
                    ),
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

    const RACKET: &str = r#"
        projection-policy "racket" {
            platform "macos"
            doc "Racket's macOS projection posture."
            posture "thin-direct"
            choice "directly-reachable-objc" {
                spectrum "direct-call"
                doc "trampoline-elided objc_msgSend dispatch"
            }
            choice "swift-native-async" {
                spectrum "adapter-call-plus-wrapper"
            }
            choice "swift-native-value-return" {
                spectrum "adapter-call"
            }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let p = parse_policy("racket/policies/macos/projection.apiw", RACKET).expect("parses");
        assert_eq!(p.id, "racket");
        assert_eq!(p.platform, "macos");
        assert_eq!(p.posture.as_deref(), Some("thin-direct"));
        assert_eq!(p.choices.len(), 3);
        let direct = p.choice("directly-reachable-objc").expect("present");
        assert_eq!(direct.spectrum, SpectrumPoint::DirectCall);
        assert_eq!(
            p.choice("swift-native-async").map(|c| c.spectrum),
            Some(SpectrumPoint::AdapterCallPlusWrapper)
        );
        assert!(p.choice("nonexistent").is_none());
    }

    #[test]
    fn rejects_a_duplicate_concern() {
        let text = r#"
            projection-policy "x" {
                platform "macos"
                choice "directly-reachable-objc" { spectrum "direct-call" }
                choice "directly-reachable-objc" { spectrum "adapter-call" }
            }
        "#;
        let err = parse_policy("x/policies/macos/projection.apiw", text)
            .expect_err("duplicate concern rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_an_unknown_spectrum_point() {
        let text = r#"
            projection-policy "x" {
                platform "macos"
                choice "c" { spectrum "teleport-call" }
            }
        "#;
        let err = parse_policy("x/policies/macos/projection.apiw", text)
            .expect_err("bad spectrum rejected");
        assert!(format!("{err}").contains("not a valid spectrum point"));
    }
}
