//! The authored app-kind test-obligation overlay: `<kind>.apiw` (KDL 2.0) → the
//! typed [`AppKindTests`] model, plus the **semantic** checks the language-neutral
//! KDL Schema cannot state.
//!
//! Parsing runs in two layers, mirroring `apianyware-app-kinds`:
//!
//! 1. **Structural** — [`super::schema::validate_app_kind_tests`] checks the
//!    document against `app-kind-tests.kdl-schema` (node shapes, cardinality). Run
//!    by the loader *before* [`parse_app_kind_tests`].
//! 2. **Semantic** — this module, after a clean parse: `obligation` names are unique
//!    within the file; `expect` ids are unique within an obligation. These are the
//!    coherence rules the generic schema cannot express.
//!
//! The cross-entity rules (name = file stem; obligations resolve the kind's
//! `test-obligation` refs) are registry-/guard-level checks — the parse layer is
//! path- and registry-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! app-kind-tests "gui-app" {
//!     doc "The lifecycle and bundle-structure obligations of a gui-app."
//!     obligation "lifecycle" {
//!         doc "Drives the entry → run-loop → termination model end-to-end."
//!         expect "reaches-did-finish-launching" {
//!             doc "Launching reaches applicationDidFinishLaunching:."
//!         }
//!     }
//! }
//! ```

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;

use crate::error::{PlatformTestError, Result};

use super::model::{AppKindTests, Expectation, Obligation};

/// Parse an app-kind test-obligation `<kind>.apiw` (KDL 2.0) document into the typed
/// model and run the semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document
/// has already passed [`super::schema::validate_app_kind_tests`]; it still guards
/// every access so a direct call without structural validation yields a located
/// error rather than a panic. Syntactic KDL errors forward the `kdl` crate's
/// diagnostic; semantic violations carry the offending node's span.
pub fn parse_app_kind_tests(source_name: &str, text: &str) -> Result<AppKindTests> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "app-kind-tests")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `app-kind-tests \"<name>\"` node",
            )
        })?;

    let tests = ctx.parse_tests(node)?;
    ctx.check_semantics(&tests, node)?;
    Ok(tests)
}

/// Parsing context — carries what located errors need.
struct Ctx<'a> {
    source_name: &'a str,
    text: &'a str,
}

impl Ctx<'_> {
    fn err(&self, span: SourceSpan, message: impl Into<String>) -> PlatformTestError {
        PlatformTestError::apiw(self.source_name, self.text, span, message)
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

    fn parse_tests(&self, node: &KdlNode) -> Result<AppKindTests> {
        let kind = self.required_string_arg(node, "app-kind-tests")?;
        let doc = self.optional_doc(node)?;
        let mut obligations = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "obligation" => obligations.push(self.parse_obligation(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in app-kind-tests"),
                    ))
                }
            }
        }

        Ok(AppKindTests {
            kind,
            doc,
            obligations,
        })
    }

    fn parse_obligation(&self, node: &KdlNode) -> Result<Obligation> {
        let name = self.required_string_arg(node, "obligation")?;
        let doc = self.optional_doc(node)?;
        let mut fixtures = Vec::new();
        let mut expectations = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "fixture" => fixtures.push(self.required_string_arg(child, "fixture")?),
                "expect" => expectations.push(self.parse_expectation(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in obligation `{name}`"),
                    ))
                }
            }
        }

        Ok(Obligation {
            name,
            doc,
            fixtures,
            expectations,
        })
    }

    fn parse_expectation(&self, node: &KdlNode) -> Result<Expectation> {
        Ok(Expectation {
            id: self.required_string_arg(node, "expect")?,
            doc: self.optional_doc(node)?,
        })
    }

    /// The cross-field coherence rules the language-neutral schema cannot state.
    /// `node` is the `app-kind-tests` node, used to locate errors.
    fn check_semantics(&self, tests: &AppKindTests, node: &KdlNode) -> Result<()> {
        // Obligation names are unique — a duplicate body is an authoring slip (and
        // would make the kind's ref ambiguous).
        let mut names = BTreeSet::new();
        for obligation in &tests.obligations {
            if !names.insert(obligation.name.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "app-kind-tests `{}` declares obligation `{}` more than once",
                        tests.kind, obligation.name
                    ),
                ));
            }

            // Expectation ids are unique within their obligation, for the same
            // reason — ws9 resolves an expectation by (obligation, id).
            let mut ids = BTreeSet::new();
            for expect in &obligation.expectations {
                if !ids.insert(expect.id.as_str()) {
                    return Err(self.err(
                        node.span(),
                        format!(
                            "obligation `{}` (kind `{}`) names expectation `{}` more than once",
                            obligation.name, tests.kind, expect.id
                        ),
                    ));
                }
            }
        }

        Ok(())
    }
}

/// The child nodes of `node`, or an empty slice if it has no `{ … }` block.
fn children_of(node: &KdlNode) -> &[KdlNode] {
    node.children().map(KdlDocument::nodes).unwrap_or(&[])
}

#[cfg(test)]
mod tests {
    use super::*;

    const GUI_APP: &str = r#"
        app-kind-tests "gui-app" {
            doc "The lifecycle and bundle-structure obligations of a gui-app."
            obligation "lifecycle" {
                doc "Drives the entry → run-loop → termination model end-to-end."
                expect "reaches-did-finish-launching" {
                    doc "Launching reaches applicationDidFinishLaunching:."
                }
                expect "foreground-session" {
                    doc "The app presents a foreground UI session (regular activation)."
                }
            }
            obligation "bundle-structure" {
                expect "bundle-skeleton" {
                    doc "The bundle has Contents/Info.plist and Contents/MacOS/<exe>."
                }
            }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let t = parse_app_kind_tests("gui-app.apiw", GUI_APP).expect("parses");
        assert_eq!(t.kind, "gui-app");
        assert_eq!(
            t.doc.as_deref(),
            Some("The lifecycle and bundle-structure obligations of a gui-app.")
        );
        assert_eq!(t.obligations.len(), 2);

        let lifecycle = &t.obligations[0];
        assert_eq!(lifecycle.name, "lifecycle");
        assert_eq!(lifecycle.expectations.len(), 2);
        assert_eq!(lifecycle.expectations[0].id, "reaches-did-finish-launching");
        assert!(lifecycle.fixtures.is_empty());

        assert_eq!(
            t.obligation_names().collect::<Vec<_>>(),
            vec!["lifecycle", "bundle-structure"]
        );
    }

    #[test]
    fn parses_an_obligation_with_fixtures() {
        // The fixture grammar branch — exercised here even though the gui-app
        // exemplar reads no fixture, so child 2 (the fixture-reading kinds:
        // spotlight-importer, quicklook-extension, finder-sync-extension) is pure
        // content, not grammar work.
        let text = r#"
            app-kind-tests "spotlight-importer" {
                obligation "indexing" {
                    doc "The importer extracts indexable text from a sample document."
                    fixture "fixtures/sample-documents/note.txt"
                    fixture "fixtures/spotlight/expected-attributes.json"
                    expect "extracts-text-content" {
                        doc "kMDItemTextContent matches the document's body."
                    }
                }
            }
        "#;
        let t = parse_app_kind_tests("spotlight-importer.apiw", text).expect("parses");
        let indexing = &t.obligations[0];
        assert_eq!(
            indexing.fixtures,
            vec![
                "fixtures/sample-documents/note.txt",
                "fixtures/spotlight/expected-attributes.json",
            ]
        );
        assert_eq!(indexing.expectations.len(), 1);
    }

    #[test]
    fn rejects_duplicate_obligation_name() {
        let text = r#"
            app-kind-tests "x" {
                obligation "lifecycle" { expect "a" { doc "ok" } }
                obligation "lifecycle" { expect "b" { doc "ok" } }
            }
        "#;
        let err = parse_app_kind_tests("x.apiw", text).expect_err("duplicate obligation rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_duplicate_expectation_id() {
        let text = r#"
            app-kind-tests "x" {
                obligation "lifecycle" {
                    expect "boots" { doc "first" }
                    expect "boots" { doc "second" }
                }
            }
        "#;
        let err = parse_app_kind_tests("x.apiw", text).expect_err("duplicate expect id rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn parses_obligation_and_expect_without_doc() {
        // `doc` is optional everywhere — a terse expectation is just an id.
        let text = r#"
            app-kind-tests "cli-tool" {
                obligation "lifecycle" {
                    expect "runs-to-completion"
                }
            }
        "#;
        let t = parse_app_kind_tests("cli-tool.apiw", text).expect("parses");
        assert_eq!(t.obligations[0].doc, None);
        assert_eq!(t.obligations[0].expectations[0].doc, None);
        assert_eq!(t.obligations[0].expectations[0].id, "runs-to-completion");
    }
}
