//! The authored capability profile: `capability.apiw` (KDL 2.0) → the typed
//! [`CapabilityProfile`], plus the **semantic** checks the language-neutral KDL Schema
//! cannot state.
//!
//! Parsing runs in two layers, mirroring the sibling `descriptor` submodule:
//!
//! 1. **Structural** — [`crate::capability::schema::validate_capability`] checks the
//!    document against `capability.kdl-schema` (node shapes, the `rung` enum,
//!    occurrence cardinality, default-deny of unknown nodes). Run by the loader
//!    *before* [`parse_capability`].
//! 2. **Semantic** — this module, after a clean parse: every `dimension` token is a
//!    member of its **face's** controlled vocabulary ([`crate::vocab`]) — the
//!    face-conditional check the generic schema cannot state — and dimensions are
//!    unique within a face.
//!
//! The profile's identity (id = containing directory) is a registry-level check
//! ([`crate::capability::registry`]) — the parse layer is path-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! capability "sbcl" {
//!     doc "What the SBCL/CLOS binding can express."
//!     semantic {
//!         dimension "foreign-thread-callbacks" {
//!             rung "idiomatic-conventional"
//!             doc "Foreign-thread callbacks bounce to the main thread (ADR-0035)."
//!         }
//!     }
//!     app-form {
//!         dimension "packaging" {
//!             rung "exact-runtime"
//!         }
//!     }
//! }
//! ```
//!
//! The `rung` value (`exact-static` / … / `research`) is the *serde* vocabulary of
//! [`Representability`] — the single source of truth — so its `.apiw` spelling always
//! matches the typed model. The `dimension` token is an open string the validator
//! checks against the face vocabulary.

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::capability::model::{CapabilityEntry, CapabilityProfile};
use crate::derive::Representability;
use crate::error::{Result, TargetModelError};
use crate::vocab::{self, Face};

/// Parse a `capability.apiw` (KDL 2.0) document into the typed model and run the
/// semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document
/// has already passed [`crate::capability::schema::validate_capability`]; it still
/// guards every access so a direct call without structural validation yields a located
/// error rather than a panic. Syntactic KDL errors forward the `kdl` crate's
/// diagnostic; semantic violations carry the offending node's span.
pub fn parse_capability(source_name: &str, text: &str) -> Result<CapabilityProfile> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "capability")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `capability \"<id>\"` node",
            )
        })?;

    let profile = ctx.parse_profile(node)?;
    ctx.check_semantics(&profile, node)?;
    Ok(profile)
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

    fn parse_profile(&self, node: &KdlNode) -> Result<CapabilityProfile> {
        let id = self.required_string_arg(node, "capability")?;
        let doc = self.optional_doc(node)?;
        let mut semantic = None;
        let mut app_form = None;

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "semantic" => semantic = Some(self.parse_face(child, Face::Semantic)?),
                "app-form" => app_form = Some(self.parse_face(child, Face::AppForm)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in capability"),
                    ))
                }
            }
        }

        Ok(CapabilityProfile {
            id,
            doc,
            semantic: semantic.ok_or_else(|| {
                self.err(node.span(), "capability is missing the `semantic` face")
            })?,
            app_form: app_form.ok_or_else(|| {
                self.err(node.span(), "capability is missing the `app-form` face")
            })?,
        })
    }

    /// Parse one face body (`semantic { … }` / `app-form { … }`) into its dimension
    /// entries.
    fn parse_face(&self, node: &KdlNode, face: Face) -> Result<Vec<CapabilityEntry>> {
        let mut entries = Vec::new();
        for child in children_of(node) {
            match child.name().value() {
                "dimension" => entries.push(self.parse_dimension(child, face)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in the `{}` face", face.as_str()),
                    ))
                }
            }
        }
        Ok(entries)
    }

    fn parse_dimension(&self, node: &KdlNode, face: Face) -> Result<CapabilityEntry> {
        let dimension = self.required_string_arg(node, "dimension")?;
        let mut rung = None;
        let mut doc = None;
        for child in children_of(node) {
            match child.name().value() {
                "rung" => {
                    rung = Some(self.enum_arg::<Representability>(child, "representability rung")?)
                }
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in dimension `{dimension}`"),
                    ))
                }
            }
        }
        let rung = rung.ok_or_else(|| {
            self.err(
                node.span(),
                format!("dimension `{dimension}` is missing `rung`"),
            )
        })?;
        // Face-conditional vocabulary — the dimension must belong to this face's §20
        // controlled set. The generic schema cannot state a node-conditional vocabulary.
        if !vocab::is_valid_dimension(face, &dimension) {
            return Err(self.err(
                node.span(),
                format!(
                    "dimension `{dimension}` is not in the `{}` face's §20 capability vocabulary",
                    face.as_str()
                ),
            ));
        }
        Ok(CapabilityEntry {
            dimension,
            rung,
            doc,
        })
    }

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    /// The cross-field coherence the language-neutral schema cannot state: dimensions
    /// are unique within each face (a face declaring `ownership` twice is an authoring
    /// slip that would make the rung ambiguous). `node` locates errors.
    fn check_semantics(&self, profile: &CapabilityProfile, node: &KdlNode) -> Result<()> {
        for (face, entries) in [
            (Face::Semantic, &profile.semantic),
            (Face::AppForm, &profile.app_form),
        ] {
            let mut seen = BTreeSet::new();
            for entry in entries {
                if !seen.insert(entry.dimension.as_str()) {
                    return Err(self.err(
                        node.span(),
                        format!(
                            "the `{}` face rates dimension `{}` more than once",
                            face.as_str(),
                            entry.dimension
                        ),
                    ));
                }
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
        capability "sbcl" {
            doc "What the SBCL/CLOS binding can express."
            semantic {
                dimension "foreign-thread-callbacks" {
                    rung "idiomatic-conventional"
                    doc "Foreign-thread callbacks bounce to the main thread (ADR-0035), not activated."
                }
                dimension "main-thread-dispatch" {
                    rung "exact-runtime"
                }
            }
            app-form {
                dimension "packaging" {
                    rung "exact-runtime"
                }
            }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let p = parse_capability("sbcl/capability.apiw", SBCL).expect("parses");
        assert_eq!(p.id, "sbcl");
        assert_eq!(
            p.doc.as_deref(),
            Some("What the SBCL/CLOS binding can express.")
        );
        assert_eq!(p.semantic.len(), 2);
        assert_eq!(p.app_form.len(), 1);
        assert_eq!(
            p.semantic_rung("foreign-thread-callbacks"),
            Some(Representability::IdiomaticConventional)
        );
        assert_eq!(
            p.semantic_rung("main-thread-dispatch"),
            Some(Representability::ExactRuntime)
        );
        assert_eq!(
            p.app_form_rung("packaging"),
            Some(Representability::ExactRuntime)
        );
        assert_eq!(p.semantic_rung("strings"), None);
    }

    #[test]
    fn rejects_a_dimension_outside_its_face_vocabulary() {
        // `packaging` is an app-form dimension — not valid in the semantic face.
        let text = r#"
            capability "x" {
                semantic { dimension "packaging" { rung "exact-static" } }
                app-form { dimension "packaging" { rung "exact-static" } }
            }
        "#;
        let err =
            parse_capability("x/capability.apiw", text).expect_err("cross-face dimension rejected");
        assert!(format!("{err}").contains("not in the `semantic` face's §20 capability vocabulary"));
    }

    #[test]
    fn rejects_an_app_form_dimension_in_app_form_that_is_semantic() {
        // `ownership` is a semantic dimension — not valid in the app-form face.
        let text = r#"
            capability "x" {
                semantic { dimension "ownership" { rung "idiomatic-conventional" } }
                app-form { dimension "ownership" { rung "exact-static" } }
            }
        "#;
        let err =
            parse_capability("x/capability.apiw", text).expect_err("cross-face dimension rejected");
        assert!(format!("{err}").contains("not in the `app-form` face's §20 capability vocabulary"));
    }

    #[test]
    fn rejects_a_duplicate_dimension_within_a_face() {
        let text = r#"
            capability "x" {
                semantic {
                    dimension "ownership" { rung "idiomatic-conventional" }
                    dimension "ownership" { rung "exact-runtime" }
                }
                app-form { dimension "packaging" { rung "exact-runtime" } }
            }
        "#;
        let err =
            parse_capability("x/capability.apiw", text).expect_err("duplicate dimension rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_an_unknown_rung() {
        let text = r#"
            capability "x" {
                semantic { dimension "ownership" { rung "perfectly-fine" } }
                app-form { dimension "packaging" { rung "exact-runtime" } }
            }
        "#;
        let err = parse_capability("x/capability.apiw", text).expect_err("unknown rung rejected");
        assert!(format!("{err}").contains("not a valid representability rung"));
    }

    #[test]
    fn rejects_a_missing_face() {
        let text = r#"
            capability "x" {
                semantic { dimension "ownership" { rung "idiomatic-conventional" } }
            }
        "#;
        let err =
            parse_capability("x/capability.apiw", text).expect_err("missing app-form rejected");
        assert!(format!("{err}").contains("missing the `app-form` face"));
    }

    #[test]
    fn parses_a_dimension_without_doc() {
        let text = r#"
            capability "x" {
                semantic { dimension "strings" { rung "exact-runtime" } }
                app-form { dimension "packaging" { rung "exact-runtime" } }
            }
        "#;
        let p = parse_capability("x/capability.apiw", text).expect("parses");
        assert_eq!(p.semantic[0].doc, None);
    }
}
