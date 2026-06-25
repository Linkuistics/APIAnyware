//! The authored conformance report: `conformance/<platform>.apiw` (KDL 2.0) → the typed
//! [`ConformanceReport`], plus the **semantic** checks the language-neutral KDL Schema cannot
//! state.
//!
//! Parsing runs in two layers, mirroring the sibling `policy` / `adapter_spec` / `capability`
//! submodules:
//!
//! 1. **Structural** — [`crate::conformance::schema::validate_conformance`] checks the
//!    document against `conformance.kdl-schema` (node shapes, the `status` enum, occurrence
//!    cardinality, default-deny of unknown nodes). Run by the loader *before*
//!    [`parse_conformance`].
//! 2. **Semantic** — this module, after a clean parse: every `app-support` app-kind is a
//!    member of the seven macOS [`crate::vocab::APP_KINDS`] and unique within the report; each
//!    entry's `exemplar`s are unique; and the `unsupported` / `research` / `known-issue`
//!    tokens are unique within their respective §37 list.
//!
//! The report's identity (id = the grandparent directory, platform = the file stem) is a
//! registry-level check ([`crate::conformance::registry`]) — the parse layer is path-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! conformance "racket" {
//!     platform "macos"
//!     doc "Racket's macOS conformance report."
//!     app-support "gui-app" {
//!         status "pass"
//!         doc "all seven GUI sample apps VM-verified"
//!         exemplar "hello-window"
//!         exemplar "note-editor"
//!     }
//!     app-support "spotlight-importer" { status "research"; doc "plugin hosting unestablished" }
//!     unsupported "swift-actor-isolation" { doc "no actor model in the dynamic runtime" }
//!     research "app-sandbox" { doc "entitlements not yet exercised" }
//!     known-issue "menu-bar-name" { doc "see the standalone-bundle fix" }
//! }
//! ```
//!
//! The `status` value is the *serde* vocabulary of [`ConformanceStatus`] — the single source
//! of truth — so its `.apiw` spelling always matches the typed model. The `app-support`
//! app-kind tokens are checked against the §36 macOS app-kinds by this module.

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::conformance::model::{AppSupport, ConformanceReport, JudgmentItem};
use crate::derive::ConformanceStatus;
use crate::error::{Result, TargetModelError};
use crate::vocab;

/// Parse a `conformance/<platform>.apiw` (KDL 2.0) document into the typed model and run the
/// semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document has
/// already passed [`crate::conformance::schema::validate_conformance`]; it still guards every
/// access so a direct call without structural validation yields a located error rather than a
/// panic.
pub fn parse_conformance(source_name: &str, text: &str) -> Result<ConformanceReport> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "conformance")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `conformance \"<id>\"` node",
            )
        })?;

    let report = ctx.parse_report(node)?;
    ctx.check_semantics(&report, node)?;
    Ok(report)
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

    fn parse_report(&self, node: &KdlNode) -> Result<ConformanceReport> {
        let id = self.required_string_arg(node, "conformance")?;
        let doc = self.optional_doc(node)?;
        let mut platform = None;
        let mut app_support = Vec::new();
        let mut unsupported = Vec::new();
        let mut research = Vec::new();
        let mut known_issues = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "platform" => platform = Some(self.required_string_arg(child, "platform")?),
                "app-support" => app_support.push(self.parse_app_support(child)?),
                "unsupported" => unsupported.push(self.parse_item(child, "unsupported")?),
                "research" => research.push(self.parse_item(child, "research")?),
                "known-issue" => known_issues.push(self.parse_item(child, "known-issue")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in conformance"),
                    ))
                }
            }
        }

        let platform =
            platform.ok_or_else(|| self.err(node.span(), "conformance is missing `platform`"))?;

        Ok(ConformanceReport {
            id,
            platform,
            doc,
            app_support,
            unsupported,
            research,
            known_issues,
        })
    }

    fn parse_app_support(&self, node: &KdlNode) -> Result<AppSupport> {
        let app_kind = self.required_string_arg(node, "app-support")?;
        if !vocab::is_valid_app_kind(&app_kind) {
            return Err(self.err(
                node.span(),
                format!("`{app_kind}` is not one of the seven macOS app-kinds"),
            ));
        }
        let mut status = None;
        let mut doc = None;
        let mut exemplars = Vec::new();
        for child in children_of(node) {
            match child.name().value() {
                "status" => {
                    status = Some(self.enum_arg::<ConformanceStatus>(child, "conformance status")?)
                }
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                "exemplar" => exemplars.push(self.required_string_arg(child, "exemplar")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in app-support `{app_kind}`"),
                    ))
                }
            }
        }
        // Per-entry exemplar uniqueness (so the cross-check visits each app once).
        let mut seen = BTreeSet::new();
        for exemplar in &exemplars {
            if !seen.insert(exemplar.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!("app-support `{app_kind}` lists exemplar `{exemplar}` more than once"),
                ));
            }
        }
        Ok(AppSupport {
            status: status.ok_or_else(|| {
                self.err(
                    node.span(),
                    format!("app-support `{app_kind}` is missing `status`"),
                )
            })?,
            app_kind,
            doc,
            exemplars,
        })
    }

    fn parse_item(&self, node: &KdlNode, kind: &str) -> Result<JudgmentItem> {
        let name = self.required_string_arg(node, kind)?;
        let doc = self.optional_doc(node)?;
        // Reject any non-`doc` child (the schema default-denies, but guard the direct path).
        for child in children_of(node) {
            if child.name().value() != "doc" {
                return Err(self.err(
                    child.span(),
                    format!(
                        "unexpected node `{}` in {kind} `{name}`",
                        child.name().value()
                    ),
                ));
            }
        }
        Ok(JudgmentItem { name, doc })
    }

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    /// The cross-field coherence the language-neutral schema cannot state: §37 app-kind
    /// vocabulary membership (checked in [`Self::parse_app_support`]) plus per-report
    /// uniqueness — each app-kind supported at most once, and each §37 list's tokens unique
    /// (so a lookup is unambiguous and the report has no accidental duplicates). `node` locates
    /// errors.
    fn check_semantics(&self, report: &ConformanceReport, node: &KdlNode) -> Result<()> {
        let mut seen_kind = BTreeSet::new();
        for support in &report.app_support {
            if !seen_kind.insert(support.app_kind.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "the report makes an app-support call for `{}` more than once",
                        support.app_kind
                    ),
                ));
            }
        }
        for (list, label) in [
            (&report.unsupported, "unsupported"),
            (&report.research, "research"),
            (&report.known_issues, "known-issue"),
        ] {
            let mut seen = BTreeSet::new();
            for item in list {
                if !seen.insert(item.name.as_str()) {
                    return Err(self.err(
                        node.span(),
                        format!("the report lists {label} `{}` more than once", item.name),
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

    const RACKET: &str = r#"
        conformance "racket" {
            platform "macos"
            doc "Racket's macOS conformance report."
            app-support "gui-app" {
                status "pass"
                doc "all seven GUI sample apps VM-verified"
                exemplar "hello-window"
                exemplar "note-editor"
            }
            app-support "cli-tool" { status "pass" }
            app-support "spotlight-importer" { status "research" }
            unsupported "swift-actor-isolation" { doc "no actor model" }
            research "app-sandbox" { doc "entitlements not exercised" }
            known-issue "menu-bar-name" { doc "stub-launcher process name" }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let r = parse_conformance("racket/conformance/macos.apiw", RACKET).expect("parses");
        assert_eq!(r.id, "racket");
        assert_eq!(r.platform, "macos");
        assert_eq!(r.app_support.len(), 3);
        let gui = r.support("gui-app").expect("present");
        assert_eq!(gui.status, ConformanceStatus::Pass);
        assert_eq!(gui.exemplars, vec!["hello-window", "note-editor"]);
        assert_eq!(
            r.support("spotlight-importer").map(|s| s.status),
            Some(ConformanceStatus::Research)
        );
        assert!(r.support("menu-bar-daemon").is_none());
        assert_eq!(r.unsupported.len(), 1);
        assert_eq!(r.research[0].name, "app-sandbox");
        assert_eq!(r.known_issues[0].name, "menu-bar-name");
    }

    #[test]
    fn rejects_an_app_kind_outside_the_macos_vocabulary() {
        let text = r#"
            conformance "x" {
                platform "macos"
                app-support "teleport-app" { status "pass" }
            }
        "#;
        let err =
            parse_conformance("x/conformance/macos.apiw", text).expect_err("bad app-kind rejected");
        assert!(format!("{err}").contains("not one of the seven macOS app-kinds"));
    }

    #[test]
    fn rejects_a_duplicate_app_kind() {
        let text = r#"
            conformance "x" {
                platform "macos"
                app-support "gui-app" { status "pass" }
                app-support "gui-app" { status "partial" }
            }
        "#;
        let err = parse_conformance("x/conformance/macos.apiw", text)
            .expect_err("duplicate app-kind rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_a_duplicate_exemplar() {
        let text = r#"
            conformance "x" {
                platform "macos"
                app-support "gui-app" {
                    status "pass"
                    exemplar "hello-window"
                    exemplar "hello-window"
                }
            }
        "#;
        let err = parse_conformance("x/conformance/macos.apiw", text)
            .expect_err("duplicate exemplar rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_a_duplicate_research_item() {
        let text = r#"
            conformance "x" {
                platform "macos"
                research "app-sandbox"
                research "app-sandbox"
            }
        "#;
        let err = parse_conformance("x/conformance/macos.apiw", text)
            .expect_err("duplicate research item rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_an_unknown_status() {
        let text = r#"
            conformance "x" {
                platform "macos"
                app-support "gui-app" { status "teleported" }
            }
        "#;
        let err =
            parse_conformance("x/conformance/macos.apiw", text).expect_err("bad status rejected");
        assert!(format!("{err}").contains("not a valid conformance status"));
    }
}
