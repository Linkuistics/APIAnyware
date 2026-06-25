//! The authored idiom catalogue: `idioms/catalogue.apiw` (KDL 2.0) → the typed
//! [`IdiomCatalogue`], plus the **semantic** checks the language-neutral KDL Schema cannot
//! state.
//!
//! Parsing runs in two layers, mirroring the sibling `descriptor` / `capability`
//! submodules:
//!
//! 1. **Structural** — [`crate::idioms::schema::validate_idioms`] checks the document
//!    against `idioms.kdl-schema` (node shapes, the `emit` enum, occurrence cardinality,
//!    default-deny of unknown nodes). Run by the loader *before* [`parse_idioms`].
//! 2. **Semantic** — this module, after a clean parse: every `idiom` category is a member
//!    of the §21 [`crate::vocab::IDIOM_CATEGORIES`] vocabulary, categories are unique
//!    within the catalogue, and each pattern-`kind` is projected by at most one idiom
//!    across the whole catalogue (so the kind → projection index is unambiguous).
//!
//! The catalogue's identity (id = the target directory) is a registry-level check
//! ([`crate::idioms::registry`]) — the parse layer is path-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! idiom-catalogue "sbcl" {
//!     doc "How source concepts appear in the SBCL/CLOS binding."
//!     idiom "bracketed-use" {
//!         construct "with-macro expanding to unwind-protect"
//!         doc "Bracketed resource use is a with-NAME macro; cleanup runs on unwind."
//!         projects "bracket"      { emit "scoped-resource"; name "with-bracket" }
//!         projects "paired-state" { emit "scoped-guard";    name "with-paired-state" }
//!     }
//!     idiom "owned-resource" {
//!         construct "CLOS wrapper holding the foreign pointer + closed-state metadata"
//!     }
//! }
//! ```
//!
//! The `emit` value (`scoped-resource` / …) is the *serde* vocabulary of [`EmitConstruct`]
//! — the single source of truth — so its `.apiw` spelling always matches the typed model.
//! The `idiom` category token is checked against the §21 vocabulary by this module.

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::error::{Result, TargetModelError};
use crate::idioms::model::{EmitConstruct, Idiom, IdiomCatalogue, Projection};
use crate::vocab;

/// Parse an `idioms/catalogue.apiw` (KDL 2.0) document into the typed model and run the
/// semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document has
/// already passed [`crate::idioms::schema::validate_idioms`]; it still guards every access
/// so a direct call without structural validation yields a located error rather than a
/// panic. Syntactic KDL errors forward the `kdl` crate's diagnostic; semantic violations
/// carry the offending node's span.
pub fn parse_idioms(source_name: &str, text: &str) -> Result<IdiomCatalogue> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "idiom-catalogue")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `idiom-catalogue \"<id>\"` node",
            )
        })?;

    let catalogue = ctx.parse_catalogue(node)?;
    ctx.check_semantics(&catalogue, node)?;
    Ok(catalogue)
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

    fn parse_catalogue(&self, node: &KdlNode) -> Result<IdiomCatalogue> {
        let id = self.required_string_arg(node, "idiom-catalogue")?;
        let doc = self.optional_doc(node)?;
        let mut idioms = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "idiom" => idioms.push(self.parse_idiom(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in idiom-catalogue"),
                    ))
                }
            }
        }

        Ok(IdiomCatalogue { id, doc, idioms })
    }

    fn parse_idiom(&self, node: &KdlNode) -> Result<Idiom> {
        let category = self.required_string_arg(node, "idiom")?;
        let mut construct = None;
        let mut doc = None;
        let mut projects = Vec::new();
        for child in children_of(node) {
            match child.name().value() {
                "construct" => construct = Some(self.required_string_arg(child, "construct")?),
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                "projects" => projects.push(self.parse_projection(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in idiom `{category}`"),
                    ))
                }
            }
        }
        let construct = construct.ok_or_else(|| {
            self.err(
                node.span(),
                format!("idiom `{category}` is missing `construct`"),
            )
        })?;
        // The §21 category vocabulary — the membership check the generic schema cannot
        // state (kept a validator vocab, not a schema enum, for §21 lockstep).
        if !vocab::is_valid_idiom_category(&category) {
            return Err(self.err(
                node.span(),
                format!("`{category}` is not a REFACTOR §21 idiom category"),
            ));
        }
        Ok(Idiom {
            category,
            construct,
            doc,
            projects,
        })
    }

    fn parse_projection(&self, node: &KdlNode) -> Result<Projection> {
        let kind = self.required_string_arg(node, "projects")?;
        let mut emit = None;
        let mut name = None;
        for child in children_of(node) {
            match child.name().value() {
                "emit" => emit = Some(self.enum_arg::<EmitConstruct>(child, "emit construct")?),
                "name" => name = Some(self.required_string_arg(child, "name")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in projection of `{kind}`"),
                    ))
                }
            }
        }
        Ok(Projection {
            kind: kind.clone(),
            emit: emit.ok_or_else(|| {
                self.err(
                    node.span(),
                    format!("projection of `{kind}` is missing `emit`"),
                )
            })?,
            name: name.ok_or_else(|| {
                self.err(
                    node.span(),
                    format!("projection of `{kind}` is missing `name`"),
                )
            })?,
        })
    }

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    /// The cross-field coherence the language-neutral schema cannot state: each §21
    /// category appears at most once (a catalogue rating one category twice is ambiguous),
    /// and each pattern-kind is projected by at most one idiom across the whole catalogue
    /// (so [`IdiomCatalogue::projection_for`] is unambiguous). `node` locates errors.
    fn check_semantics(&self, catalogue: &IdiomCatalogue, node: &KdlNode) -> Result<()> {
        let mut seen_category = BTreeSet::new();
        for idiom in &catalogue.idioms {
            if !seen_category.insert(idiom.category.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "the catalogue covers category `{}` more than once",
                        idiom.category
                    ),
                ));
            }
        }
        let mut seen_kind = BTreeSet::new();
        for projection in catalogue.projections() {
            if !seen_kind.insert(projection.kind.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "pattern-kind `{}` is projected by more than one idiom",
                        projection.kind
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

    const SBCL: &str = r#"
        idiom-catalogue "sbcl" {
            doc "How source concepts appear in the SBCL/CLOS binding."
            idiom "bracketed-use" {
                construct "with-macro expanding to unwind-protect"
                doc "Bracketed resource use is a with-NAME macro; cleanup runs on unwind."
                projects "bracket"      { emit "scoped-resource"; name "with-bracket" }
                projects "paired-state" { emit "scoped-guard";    name "with-paired-state" }
            }
            idiom "error-side-channel" {
                construct "condition + multiple-values"
                projects "error-out" { emit "result-wrapper"; name "error-out" }
            }
            idiom "owned-resource" {
                construct "CLOS wrapper holding the foreign pointer + closed-state metadata"
            }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let c = parse_idioms("sbcl/idioms/catalogue.apiw", SBCL).expect("parses");
        assert_eq!(c.id, "sbcl");
        assert_eq!(
            c.doc.as_deref(),
            Some("How source concepts appear in the SBCL/CLOS binding.")
        );
        assert_eq!(c.idioms.len(), 3);
        let bracketed = c.idiom("bracketed-use").expect("bracketed-use present");
        assert_eq!(
            bracketed.construct,
            "with-macro expanding to unwind-protect"
        );
        assert_eq!(bracketed.projects.len(), 2);
        // The kind → projection index spans the whole catalogue.
        let p = c.projection_for("bracket").expect("bracket projects");
        assert_eq!(p.emit, EmitConstruct::ScopedResource);
        assert_eq!(p.name, "with-bracket");
        assert_eq!(
            c.projection_for("error-out").map(|p| p.emit),
            Some(EmitConstruct::ResultWrapper)
        );
        // A documentation-only idiom has no projection; an unprojected kind is None.
        assert!(c.idiom("owned-resource").unwrap().projects.is_empty());
        assert!(c.projection_for("delegate").is_none());
    }

    #[test]
    fn rejects_a_category_outside_the_section_21_vocabulary() {
        let text = r#"
            idiom-catalogue "x" {
                idiom "teleportation" { construct "beam me up" }
            }
        "#;
        let err = parse_idioms("x/idioms/catalogue.apiw", text).expect_err("bad category rejected");
        assert!(format!("{err}").contains("not a REFACTOR §21 idiom category"));
    }

    #[test]
    fn rejects_a_duplicate_category() {
        let text = r#"
            idiom-catalogue "x" {
                idiom "bracketed-use" { construct "with-macro" }
                idiom "bracketed-use" { construct "another with-macro" }
            }
        "#;
        let err =
            parse_idioms("x/idioms/catalogue.apiw", text).expect_err("duplicate category rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_a_kind_projected_by_two_idioms() {
        // `bracket` projected under both bracketed-use and (nonsensically) builder — the
        // kind → projection index would be ambiguous.
        let text = r#"
            idiom-catalogue "x" {
                idiom "bracketed-use" {
                    construct "with-macro"
                    projects "bracket" { emit "scoped-resource"; name "with-bracket" }
                }
                idiom "builder" {
                    construct "let-pipeline"
                    projects "bracket" { emit "builder-dsl"; name "bracket-builder" }
                }
            }
        "#;
        let err =
            parse_idioms("x/idioms/catalogue.apiw", text).expect_err("duplicate kind rejected");
        assert!(format!("{err}").contains("projected by more than one idiom"));
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
        let err = parse_idioms("x/idioms/catalogue.apiw", text).expect_err("bad emit rejected");
        assert!(format!("{err}").contains("not a valid emit construct"));
    }

    #[test]
    fn parses_a_documentation_only_catalogue() {
        let text = r#"
            idiom-catalogue "x" {
                idiom "string-encoding" { construct "NSString ↔ native string conversion" }
            }
        "#;
        let c = parse_idioms("x/idioms/catalogue.apiw", text).expect("parses");
        assert_eq!(c.idioms.len(), 1);
        assert!(c.projections().next().is_none());
    }
}
