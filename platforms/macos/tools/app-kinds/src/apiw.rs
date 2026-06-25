//! The authored app-kind overlay: `kind.apiw` (KDL 2.0) → the typed [`AppKind`]
//! model, plus the **semantic** checks the language-neutral KDL Schema cannot
//! state.
//!
//! Parsing runs in two layers, mirroring `apianyware-patterns`:
//!
//! 1. **Structural** — [`crate::schema::validate_app_kind`] checks the document
//!    against `app-kind.kdl-schema` (node shapes, the controlled enums,
//!    cardinality). Run by the loader *before* [`parse_kind`].
//! 2. **Semantic** — this module, after a clean parse: a `bundle "none"` carries
//!    no bundle metadata; an `extension-point` implies a hosted bundle
//!    (mdimporter / appex); `require` keys and `test-obligation` refs are unique.
//!    These are the cross-field coherence rules the generic schema cannot express.
//!
//! The kind's identity (name = containing directory) is a registry-level check
//! ([`crate::registry`]) — the parse layer is path-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! app-kind "gui-app" {
//!     doc "A bundled, windowed Cocoa application driven by NSApplication."
//!     process {
//!         entry "ns-application-main"
//!         run-loop "ns-application"
//!         termination "ns-application-terminate"
//!     }
//!     activation "regular"
//!     bundle "app" {
//!         package-type "APPL"
//!         principal-class-key "NSPrincipalClass"
//!         info-plist {
//!             require "CFBundleName"
//!             require "CFBundleIdentifier"
//!         }
//!     }
//!     test-obligation "lifecycle"
//!     test-obligation "bundle-structure"
//! }
//! ```
//!
//! Enum string values (`ns-application-main`, `regular`, `app`, …) are the *serde*
//! vocabulary — the single source of truth — so a value's `.apiw` spelling always
//! matches the typed model.

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::error::{AppKindError, Result};
use crate::kind::{
    ActivationPolicy, AppKind, BundleModel, BundleType, EntryModel, ProcessModel, RunLoopModel,
    TerminationModel,
};

/// Parse an app-kind `kind.apiw` (KDL 2.0) document into the typed model and run
/// the semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the
/// document has already passed [`crate::schema::validate_app_kind`]; it still
/// guards every access so a direct call without structural validation yields a
/// located error rather than a panic. Syntactic KDL errors forward the `kdl`
/// crate's diagnostic; semantic violations carry the offending node's span.
pub fn parse_kind(source_name: &str, text: &str) -> Result<AppKind> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "app-kind")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `app-kind \"<name>\"` node",
            )
        })?;

    let kind = ctx.parse_app_kind(node)?;
    ctx.check_semantics(&kind, node)?;
    Ok(kind)
}

/// Parsing context — carries what located errors need.
struct Ctx<'a> {
    source_name: &'a str,
    text: &'a str,
}

impl Ctx<'_> {
    fn err(&self, span: SourceSpan, message: impl Into<String>) -> AppKindError {
        AppKindError::apiw(self.source_name, self.text, span, message)
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

    fn parse_app_kind(&self, node: &KdlNode) -> Result<AppKind> {
        let name = self.required_string_arg(node, "app-kind")?;
        let mut doc = None;
        let mut process = None;
        let mut activation = None;
        let mut bundle = None;
        let mut test_obligations = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                "process" => process = Some(self.parse_process(child)?),
                "activation" => {
                    activation =
                        Some(self.enum_arg::<ActivationPolicy>(child, "activation policy")?)
                }
                "bundle" => bundle = Some(self.parse_bundle(child)?),
                "test-obligation" => {
                    test_obligations.push(self.required_string_arg(child, "test-obligation")?)
                }
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in app-kind"),
                    ))
                }
            }
        }

        Ok(AppKind {
            name,
            doc,
            process: process
                .ok_or_else(|| self.err(node.span(), "app-kind is missing `process`"))?,
            activation: activation
                .ok_or_else(|| self.err(node.span(), "app-kind is missing `activation`"))?,
            bundle: bundle.ok_or_else(|| self.err(node.span(), "app-kind is missing `bundle`"))?,
            test_obligations,
        })
    }

    fn parse_process(&self, node: &KdlNode) -> Result<ProcessModel> {
        let mut entry = None;
        let mut run_loop = None;
        let mut termination = None;

        for child in children_of(node) {
            match child.name().value() {
                "entry" => entry = Some(self.enum_arg::<EntryModel>(child, "entry model")?),
                "run-loop" => {
                    run_loop = Some(self.enum_arg::<RunLoopModel>(child, "run-loop model")?)
                }
                "termination" => {
                    termination =
                        Some(self.enum_arg::<TerminationModel>(child, "termination model")?)
                }
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in process"),
                    ))
                }
            }
        }

        Ok(ProcessModel {
            entry: entry.ok_or_else(|| self.err(node.span(), "process is missing `entry`"))?,
            run_loop: run_loop
                .ok_or_else(|| self.err(node.span(), "process is missing `run-loop`"))?,
            termination: termination
                .ok_or_else(|| self.err(node.span(), "process is missing `termination`"))?,
        })
    }

    fn parse_bundle(&self, node: &KdlNode) -> Result<BundleModel> {
        let bundle_type = self.enum_arg::<BundleType>(node, "bundle type")?;
        let mut package_type = None;
        let mut principal_class_key = None;
        let mut extension_point = None;
        let mut required_plist_keys = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "package-type" => {
                    package_type = Some(self.required_string_arg(child, "package-type")?)
                }
                "principal-class-key" => {
                    principal_class_key =
                        Some(self.required_string_arg(child, "principal-class-key")?)
                }
                "extension-point" => {
                    extension_point = Some(self.required_string_arg(child, "extension-point")?)
                }
                "info-plist" => required_plist_keys = self.parse_info_plist(child)?,
                other => {
                    return Err(
                        self.err(child.span(), format!("unexpected node `{other}` in bundle"))
                    )
                }
            }
        }

        Ok(BundleModel {
            bundle_type,
            package_type,
            principal_class_key,
            extension_point,
            required_plist_keys,
        })
    }

    fn parse_info_plist(&self, node: &KdlNode) -> Result<Vec<String>> {
        let mut keys = Vec::new();
        for child in children_of(node) {
            match child.name().value() {
                "require" => keys.push(self.required_string_arg(child, "require")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in info-plist (want `require`)"),
                    ))
                }
            }
        }
        Ok(keys)
    }

    /// The cross-field coherence rules the language-neutral schema cannot state.
    /// `node` is the `app-kind` node, used to locate errors.
    fn check_semantics(&self, kind: &AppKind, node: &KdlNode) -> Result<()> {
        let bundle = &kind.bundle;

        // A bare executable (`bundle "none"`) has no bundle metadata — no
        // package-type, principal class, extension point, or Info.plist (it has no
        // bundle to carry them).
        if bundle.bundle_type == BundleType::None {
            let stray = bundle.package_type.is_some()
                || bundle.principal_class_key.is_some()
                || bundle.extension_point.is_some()
                || !bundle.required_plist_keys.is_empty();
            if stray {
                return Err(self.err(
                    node.span(),
                    format!(
                        "app-kind `{}` declares `bundle \"none\"` but carries bundle metadata; a \
                         bare Mach-O executable has no bundle, package-type, principal class, or \
                         Info.plist",
                        kind.name
                    ),
                ));
            }
        }

        // An `extension-point` is only meaningful for a hosted bundle (mdimporter /
        // appex) — a standalone app or tool has no extension point to plug into.
        if bundle.extension_point.is_some()
            && !matches!(
                bundle.bundle_type,
                BundleType::Mdimporter | BundleType::Appex
            )
        {
            return Err(self.err(
                node.span(),
                format!(
                    "app-kind `{}` declares an `extension-point` but its bundle type is not a \
                     hosted extension (`mdimporter` / `appex`)",
                    kind.name
                ),
            ));
        }

        // Required Info.plist keys are unique — a duplicate is an authoring slip.
        let mut keys = BTreeSet::new();
        for key in &bundle.required_plist_keys {
            if !keys.insert(key.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "app-kind `{}` requires Info.plist key `{key}` more than once",
                        kind.name
                    ),
                ));
            }
        }

        // Test-obligation references are unique, for the same reason.
        let mut obligations = BTreeSet::new();
        for obligation in &kind.test_obligations {
            if !obligations.insert(obligation.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "app-kind `{}` names test-obligation `{obligation}` more than once",
                        kind.name
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

    const GUI_APP: &str = r#"
        app-kind "gui-app" {
            doc "A bundled, windowed Cocoa application."
            process {
                entry "ns-application-main"
                run-loop "ns-application"
                termination "ns-application-terminate"
            }
            activation "regular"
            bundle "app" {
                package-type "APPL"
                principal-class-key "NSPrincipalClass"
                info-plist {
                    require "CFBundleName"
                    require "CFBundleIdentifier"
                }
            }
            test-obligation "lifecycle"
            test-obligation "bundle-structure"
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let k = parse_kind("gui-app/kind.apiw", GUI_APP).expect("parses");
        assert_eq!(k.name, "gui-app");
        assert_eq!(k.process.entry, EntryModel::NsApplicationMain);
        assert_eq!(k.process.run_loop, RunLoopModel::NsApplication);
        assert_eq!(
            k.process.termination,
            TerminationModel::NsApplicationTerminate
        );
        assert_eq!(k.activation, ActivationPolicy::Regular);
        assert_eq!(k.bundle.bundle_type, BundleType::App);
        assert_eq!(k.bundle.package_type.as_deref(), Some("APPL"));
        assert_eq!(
            k.bundle.principal_class_key.as_deref(),
            Some("NSPrincipalClass")
        );
        assert_eq!(k.bundle.extension_point, None);
        assert_eq!(
            k.bundle.required_plist_keys,
            vec!["CFBundleName", "CFBundleIdentifier"]
        );
        assert_eq!(k.test_obligations, vec!["lifecycle", "bundle-structure"]);
        assert!(!k.is_hosted());
    }

    #[test]
    fn parses_bare_executable_with_no_bundle_metadata() {
        // A `cli-tool`-shaped kind: bare executable, no Info.plist.
        let text = r#"
            app-kind "cli-tool" {
                process {
                    entry "c-main"
                    run-loop "none"
                    termination "return"
                }
                activation "background"
                bundle "none"
            }
        "#;
        let k = parse_kind("cli-tool/kind.apiw", text).expect("parses");
        assert_eq!(k.bundle.bundle_type, BundleType::None);
        assert!(k.bundle.required_plist_keys.is_empty());
        assert_eq!(k.process.entry, EntryModel::CMain);
    }

    #[test]
    fn parses_hosted_extension_with_extension_point() {
        let text = r#"
            app-kind "finder-sync-extension" {
                process {
                    entry "host-loaded"
                    run-loop "host-driven"
                    termination "host-controlled"
                }
                activation "hosted"
                bundle "appex" {
                    extension-point "com.apple.FinderSync"
                    info-plist { require "NSExtensionPointIdentifier" }
                }
            }
        "#;
        let k = parse_kind("fse/kind.apiw", text).expect("parses");
        assert_eq!(k.bundle.bundle_type, BundleType::Appex);
        assert_eq!(
            k.bundle.extension_point.as_deref(),
            Some("com.apple.FinderSync")
        );
        assert!(k.is_hosted());
    }

    #[test]
    fn rejects_bundle_none_with_metadata() {
        let text = r#"
            app-kind "x" {
                process { entry "c-main"; run-loop "none"; termination "return" }
                activation "background"
                bundle "none" {
                    info-plist { require "CFBundleName" }
                }
            }
        "#;
        let err = parse_kind("x/kind.apiw", text).expect_err("none-with-metadata rejected");
        assert!(format!("{err}").contains("bare Mach-O executable"));
    }

    #[test]
    fn rejects_extension_point_on_non_hosted_bundle() {
        let text = r#"
            app-kind "x" {
                process { entry "ns-application-main"; run-loop "ns-application"; termination "ns-application-terminate" }
                activation "regular"
                bundle "app" {
                    extension-point "com.apple.FinderSync"
                }
            }
        "#;
        let err = parse_kind("x/kind.apiw", text).expect_err("extension-point on .app rejected");
        assert!(format!("{err}").contains("hosted extension"));
    }

    #[test]
    fn rejects_duplicate_required_plist_key() {
        let text = r#"
            app-kind "x" {
                process { entry "ns-application-main"; run-loop "ns-application"; termination "ns-application-terminate" }
                activation "regular"
                bundle "app" {
                    info-plist {
                        require "CFBundleName"
                        require "CFBundleName"
                    }
                }
            }
        "#;
        let err = parse_kind("x/kind.apiw", text).expect_err("duplicate require rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_duplicate_test_obligation() {
        let text = r#"
            app-kind "x" {
                process { entry "c-main"; run-loop "none"; termination "return" }
                activation "background"
                bundle "none"
                test-obligation "lifecycle"
                test-obligation "lifecycle"
            }
        "#;
        let err = parse_kind("x/kind.apiw", text).expect_err("duplicate obligation rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_unknown_enum_token() {
        let text = r#"
            app-kind "x" {
                process { entry "rocket-launch"; run-loop "none"; termination "return" }
                activation "background"
                bundle "none"
            }
        "#;
        let err = parse_kind("x/kind.apiw", text).expect_err("unknown entry token rejected");
        assert!(format!("{err}").contains("not a valid entry model"));
    }
}
