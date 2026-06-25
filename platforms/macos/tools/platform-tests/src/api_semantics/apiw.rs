//! The authored api-semantics overlay: `<facet>.apiw` (KDL 2.0) → the typed
//! [`ApiSemantics`] model, plus the **semantic** checks the language-neutral KDL
//! Schema cannot state.
//!
//! Parsing runs in two layers, mirroring the sibling [`super::super::app_kind_tests`]
//! family:
//!
//! 1. **Structural** — [`super::schema::validate_api_semantics`] checks the document
//!    against `api-semantics.kdl-schema` (node shapes, cardinality, the flat `facet`
//!    enum). Run by the loader *before* [`parse_api_semantics`].
//! 2. **Semantic** — this module, after a clean parse: every `weirdness` tag is a
//!    member of the file facet's controlled §30 vocabulary ([`super::vocab`]);
//!    `weirdness` tags are de-duplicated within a shape; `(receiver, selector)` pairs
//!    are unique within the file; `expect` ids are unique within a shape. These are
//!    the coherence rules the generic schema cannot express.
//!
//! The cross-file rule (facet = file stem) is a registry-/guard-level check — the
//! parse layer is path- and registry-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! api-semantics "ownership" {
//!     doc "Ownership and lifetime semantics of macOS Foundation/AppKit shapes."
//!     api "NSString" "stringWithString:" {
//!         doc "A class factory that vends an autoreleased instance."
//!         weirdness "autoreleased"
//!         expect "result-not-owned" {
//!             doc "The result is autoreleased; a binding must not insert an extra release."
//!         }
//!     }
//! }
//! ```

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;

use crate::error::{PlatformTestError, Result};

use super::model::{Api, ApiSemantics, Expectation, Facet};
use super::vocab;

/// Parse an api-semantics `<facet>.apiw` (KDL 2.0) document into the typed model and
/// run the semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document
/// has already passed [`super::schema::validate_api_semantics`]; it still guards every
/// access so a direct call without structural validation yields a located error rather
/// than a panic. Syntactic KDL errors forward the `kdl` crate's diagnostic; semantic
/// violations carry the offending node's span.
pub fn parse_api_semantics(source_name: &str, text: &str) -> Result<ApiSemantics> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "api-semantics")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `api-semantics \"<facet>\"` node",
            )
        })?;

    let semantics = ctx.parse_semantics(node)?;
    ctx.check_semantics(&semantics, node)?;
    Ok(semantics)
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

    /// The `idx`-th positional argument of `node`, as a string.
    fn required_string_arg(&self, node: &KdlNode, idx: usize, what: &str) -> Result<String> {
        match node.get(idx).and_then(KdlValue::as_string) {
            Some(s) => Ok(s.to_string()),
            None => Err(self.err(node.span(), format!("`{what}` needs a string argument"))),
        }
    }

    /// The optional `doc "<text>"` child of `node`, if present.
    fn optional_doc(&self, node: &KdlNode) -> Result<Option<String>> {
        match children_of(node).iter().find(|c| c.name().value() == "doc") {
            Some(d) => Ok(Some(self.required_string_arg(d, 0, "doc")?)),
            None => Ok(None),
        }
    }

    fn parse_semantics(&self, node: &KdlNode) -> Result<ApiSemantics> {
        let facet_str = self.required_string_arg(node, 0, "api-semantics")?;
        let facet = Facet::parse(&facet_str).ok_or_else(|| {
            self.err(
                node.span(),
                format!(
                    "unknown api-semantics facet `{facet_str}` \
                     (expected one of: ownership, callbacks, threading, errors)"
                ),
            )
        })?;
        let doc = self.optional_doc(node)?;
        let mut apis = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "api" => apis.push(self.parse_api(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in api-semantics"),
                    ))
                }
            }
        }

        Ok(ApiSemantics { facet, doc, apis })
    }

    fn parse_api(&self, node: &KdlNode) -> Result<Api> {
        let receiver = self.required_string_arg(node, 0, "api receiver")?;
        let selector = self.required_string_arg(node, 1, "api selector")?;
        let doc = self.optional_doc(node)?;
        let mut weirdness = Vec::new();
        let mut expectations = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "weirdness" => weirdness.push(self.required_string_arg(child, 0, "weirdness")?),
                "expect" => expectations.push(self.parse_expectation(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in api `{receiver} {selector}`"),
                    ))
                }
            }
        }

        Ok(Api {
            receiver,
            selector,
            doc,
            weirdness,
            expectations,
        })
    }

    fn parse_expectation(&self, node: &KdlNode) -> Result<Expectation> {
        Ok(Expectation {
            id: self.required_string_arg(node, 0, "expect")?,
            doc: self.optional_doc(node)?,
        })
    }

    /// The cross-field coherence rules the language-neutral schema cannot state.
    /// `node` is the `api-semantics` node, used to locate errors.
    fn check_semantics(&self, semantics: &ApiSemantics, node: &KdlNode) -> Result<()> {
        let mut shapes = BTreeSet::new();
        for api in &semantics.apis {
            // `(receiver, selector)` shapes are unique — a duplicate shape is an
            // authoring slip (and would make the declaration ambiguous to ws6/ws9).
            if !shapes.insert((api.receiver.as_str(), api.selector.as_str())) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "api-semantics `{}` declares shape `{} {}` more than once",
                        semantics.facet.as_str(),
                        api.receiver,
                        api.selector
                    ),
                ));
            }

            // Every `weirdness` tag is a member of the facet's controlled §30
            // vocabulary, and tags are unique within the shape. The vocabulary is
            // facet-conditional, so the generic schema cannot check it.
            let mut tags = BTreeSet::new();
            for tag in &api.weirdness {
                if !vocab::is_valid_weirdness(semantics.facet, tag) {
                    return Err(self.err(
                        node.span(),
                        format!(
                            "shape `{} {}` (facet `{}`) declares weirdness `{}`, \
                             which is not in the facet's §30 vocabulary",
                            api.receiver,
                            api.selector,
                            semantics.facet.as_str(),
                            tag
                        ),
                    ));
                }
                if !tags.insert(tag.as_str()) {
                    return Err(self.err(
                        node.span(),
                        format!(
                            "shape `{} {}` (facet `{}`) declares weirdness `{}` more than once",
                            api.receiver,
                            api.selector,
                            semantics.facet.as_str(),
                            tag
                        ),
                    ));
                }
            }

            // Expectation ids are unique within their shape — ws9 resolves an
            // expectation by (shape, id).
            let mut ids = BTreeSet::new();
            for expect in &api.expectations {
                if !ids.insert(expect.id.as_str()) {
                    return Err(self.err(
                        node.span(),
                        format!(
                            "shape `{} {}` (facet `{}`) names expectation `{}` more than once",
                            api.receiver,
                            api.selector,
                            semantics.facet.as_str(),
                            expect.id
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

    const OWNERSHIP: &str = r#"
        api-semantics "ownership" {
            doc "Ownership and lifetime semantics of macOS Foundation/AppKit shapes."
            api "NSString" "stringWithString:" {
                doc "A class factory that vends an autoreleased instance."
                weirdness "autoreleased"
                expect "result-not-owned" {
                    doc "The result is autoreleased; a binding must not insert an extra release."
                }
            }
            api "NSString" "UTF8String" {
                weirdness "borrowed-until-owner-mutated"
                weirdness "autorelease-pool-lifetime"
                expect "interior-pointer-transient" {
                    doc "The returned C string is valid only until the pool drains or the string mutates."
                }
            }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let s = parse_api_semantics("ownership.apiw", OWNERSHIP).expect("parses");
        assert_eq!(s.facet, Facet::Ownership);
        assert_eq!(
            s.doc.as_deref(),
            Some("Ownership and lifetime semantics of macOS Foundation/AppKit shapes.")
        );
        assert_eq!(s.apis.len(), 2);

        let first = &s.apis[0];
        assert_eq!(first.receiver, "NSString");
        assert_eq!(first.selector, "stringWithString:");
        assert_eq!(first.weirdness, vec!["autoreleased"]);
        assert_eq!(first.expectations.len(), 1);
        assert_eq!(first.expectations[0].id, "result-not-owned");

        // The ownership facet unions §30 ownership + lifetime tags.
        let second = &s.apis[1];
        assert_eq!(
            second.weirdness,
            vec!["borrowed-until-owner-mutated", "autorelease-pool-lifetime"]
        );

        assert_eq!(
            s.shapes().collect::<Vec<_>>(),
            vec![
                ("NSString", "stringWithString:"),
                ("NSString", "UTF8String")
            ]
        );
    }

    #[test]
    fn rejects_a_weirdness_tag_outside_the_facet_vocabulary() {
        // `main-thread-only` is a §30 threading tag — not valid in the ownership facet.
        let text = r#"
            api-semantics "ownership" {
                api "NSView" "setNeedsDisplay:" {
                    weirdness "main-thread-only"
                    expect "x" { doc "ok" }
                }
            }
        "#;
        let err = parse_api_semantics("ownership.apiw", text)
            .expect_err("cross-facet weirdness tag rejected");
        assert!(format!("{err}").contains("not in the facet's §30 vocabulary"));
    }

    #[test]
    fn rejects_duplicate_shape() {
        let text = r#"
            api-semantics "ownership" {
                api "NSString" "copy" { weirdness "owned" expect "a" { doc "ok" } }
                api "NSString" "copy" { weirdness "retained" expect "b" { doc "ok" } }
            }
        "#;
        let err =
            parse_api_semantics("ownership.apiw", text).expect_err("duplicate shape rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_duplicate_weirdness_tag() {
        let text = r#"
            api-semantics "ownership" {
                api "NSString" "copy" {
                    weirdness "owned"
                    weirdness "owned"
                    expect "a" { doc "ok" }
                }
            }
        "#;
        let err =
            parse_api_semantics("ownership.apiw", text).expect_err("duplicate weirdness rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_duplicate_expectation_id() {
        let text = r#"
            api-semantics "threading" {
                api "NSView" "setNeedsDisplay:" {
                    weirdness "main-thread-only"
                    expect "main" { doc "first" }
                    expect "main" { doc "second" }
                }
            }
        "#;
        let err =
            parse_api_semantics("threading.apiw", text).expect_err("duplicate expect id rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_an_unknown_facet() {
        let text = r#"
            api-semantics "buffers" {
                api "NSData" "bytes" { weirdness "borrowed" expect "x" { doc "ok" } }
            }
        "#;
        let err =
            parse_api_semantics("buffers.apiw", text).expect_err("unknown facet rejected at parse");
        assert!(format!("{err}").contains("unknown api-semantics facet"));
    }

    #[test]
    fn parses_an_expectation_without_doc() {
        // `doc` is optional everywhere — a terse expectation is just an id.
        let text = r#"
            api-semantics "errors" {
                api "NSException" "raise:format:" {
                    weirdness "exception"
                    expect "unwinds-stack"
                }
            }
        "#;
        let s = parse_api_semantics("errors.apiw", text).expect("parses");
        assert_eq!(s.apis[0].expectations[0].id, "unwinds-stack");
        assert_eq!(s.apis[0].expectations[0].doc, None);
    }
}
