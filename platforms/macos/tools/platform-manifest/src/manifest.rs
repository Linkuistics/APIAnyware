//! The authored platform manifest: `platform.apiw` (KDL 2.0) → the typed
//! [`PlatformManifest`] model, plus the **semantic** checks the language-neutral
//! KDL Schema cannot state.
//!
//! Parsing runs in two layers, mirroring `apianyware-patterns`:
//!
//! 1. **Structural** — [`crate::schema::validate_platform_manifest`] checks the
//!    document against `platform.kdl-schema` (node shapes, the `discover` enum,
//!    the mandatory `ignore` `reason`, cardinality). Run by [`crate::load_str`]
//!    *before* [`parse_manifest`].
//! 2. **Semantic** — this module, after a clean parse: `ignore` framework names
//!    are unique. (The roster itself is discovered, not enumerated, so there is no
//!    per-family invariant to check here.)
//!
//! ## Grammar
//!
//! ```kdl
//! platform "macos" {
//!     doc "The macOS source platform …"
//!     sdk "macosx"
//!     deployment-target "14.0"
//!     frameworks {
//!         discover "sdk-umbrella-headers"
//!         discover "synthetic-frameworks"
//!         subframework-allow "ApplicationServices"
//!         ignore "DriverKit" reason="C++ headers, not ObjC"
//!         ignore "Tk" reason="Tcl/Tk toolkit, not a native macOS framework"
//!     }
//! }
//! ```
//!
//! Enum string values (`sdk-umbrella-headers`, …) are the *serde* vocabulary — the
//! single source of truth — so a value's `.apiw` spelling always matches the typed
//! model.

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};

use crate::error::{PlatformManifestError, Result};

/// A parsed, validated macOS platform manifest (`platform.apiw`).
///
/// Policy only — it carries no resolved roster, no dependency graph, and no
/// per-family API facts (those are derived / live in the `api/<F>/` triad).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct PlatformManifest {
    /// The platform name (matches `platforms/<name>/`, e.g. `"macos"`).
    pub name: String,
    /// Optional one-line description.
    pub doc: Option<String>,
    /// SDK name passed to `xcrun` (e.g. `"macosx"`). The version is derived.
    pub sdk: String,
    /// Source-availability floor (e.g. `"14.0"`) — the digester's target macOS
    /// version. Distinct from any target's native build floor (workstream 6).
    pub deployment_target: String,
    /// The framework roster policy.
    pub frameworks: FrameworkPolicy,
}

/// The authored framework-roster policy. The resolved roster is *discovered* from
/// these sources, not enumerated here.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct FrameworkPolicy {
    /// Discovery sources, in declared order.
    pub discover: Vec<DiscoverSource>,
    /// Subframeworks promoted to top-level families (the extractor allowlist).
    pub subframework_allow: Vec<String>,
    /// Frameworks excluded from discovery, each with a mandatory reason.
    pub ignore: Vec<IgnoredFramework>,
}

/// A source the framework scanner draws from.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum DiscoverSource {
    /// Scan `{SDK}/System/Library/Frameworks` for `*.framework`s with an umbrella
    /// header.
    SdkUmbrellaHeaders,
    /// The synthetic pseudo-framework overlay (libdispatch, …).
    SyntheticFrameworks,
}

/// A framework excluded from discovery, with the reason it is incompatible.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct IgnoredFramework {
    /// The framework name (e.g. `"DriverKit"`).
    pub name: String,
    /// Why it is excluded (mandatory — no silent caps).
    pub reason: String,
}

/// Parse a `platform.apiw` (KDL 2.0) document into the typed model and run the
/// semantic checks.
///
/// `source_name` labels diagnostics (typically the file name). Assumes the
/// document has already passed [`crate::schema::validate_platform_manifest`]; it
/// still guards every access so a direct call without structural validation yields
/// a located error rather than a panic.
pub fn parse_manifest(source_name: &str, text: &str) -> Result<PlatformManifest> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "platform")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `platform \"<name>\"` node",
            )
        })?;

    let manifest = ctx.parse_platform(node)?;
    ctx.check_semantics(&manifest, node)?;
    Ok(manifest)
}

/// Parsing context — carries what located errors need.
struct Ctx<'a> {
    source_name: &'a str,
    text: &'a str,
}

impl Ctx<'_> {
    fn err(&self, span: SourceSpan, message: impl Into<String>) -> PlatformManifestError {
        PlatformManifestError::apiw(self.source_name, self.text, span, message)
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

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    fn parse_platform(&self, node: &KdlNode) -> Result<PlatformManifest> {
        let name = self.required_string_arg(node, "platform")?;
        let mut doc = None;
        let mut sdk = None;
        let mut deployment_target = None;
        let mut frameworks = None;

        for child in children_of(node) {
            match child.name().value() {
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                "sdk" => sdk = Some(self.required_string_arg(child, "sdk")?),
                "deployment-target" => {
                    deployment_target = Some(self.required_string_arg(child, "deployment-target")?)
                }
                "frameworks" => frameworks = Some(self.parse_frameworks(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in platform"),
                    ))
                }
            }
        }

        Ok(PlatformManifest {
            name,
            doc,
            sdk: sdk.ok_or_else(|| self.err(node.span(), "platform is missing `sdk`"))?,
            deployment_target: deployment_target
                .ok_or_else(|| self.err(node.span(), "platform is missing `deployment-target`"))?,
            frameworks: frameworks
                .ok_or_else(|| self.err(node.span(), "platform is missing `frameworks`"))?,
        })
    }

    fn parse_frameworks(&self, node: &KdlNode) -> Result<FrameworkPolicy> {
        let mut discover = Vec::new();
        let mut subframework_allow = Vec::new();
        let mut ignore = Vec::new();

        for child in children_of(node) {
            match child.name().value() {
                "discover" => {
                    discover.push(self.enum_arg::<DiscoverSource>(child, "discover source")?)
                }
                "subframework-allow" => {
                    subframework_allow.push(self.required_string_arg(child, "subframework-allow")?)
                }
                "ignore" => {
                    let name = self.required_string_arg(child, "ignore")?;
                    let reason = self.required_string_prop(child, "reason")?;
                    ignore.push(IgnoredFramework { name, reason });
                }
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in frameworks"),
                    ))
                }
            }
        }

        Ok(FrameworkPolicy {
            discover,
            subframework_allow,
            ignore,
        })
    }

    /// Semantic checks the generic KDL Schema cannot state.
    fn check_semantics(&self, manifest: &PlatformManifest, node: &KdlNode) -> Result<()> {
        let fw = &manifest.frameworks;

        // `ignore` framework names are unique — a duplicate is an authoring slip
        // that would silently mask intent.
        let mut ignored = BTreeSet::new();
        for ig in &fw.ignore {
            if !ignored.insert(ig.name.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!("duplicate `ignore` framework `{}`", ig.name),
                ));
            }
        }

        // `subframework-allow` names are unique, for the same reason.
        let mut allowed = BTreeSet::new();
        for name in &fw.subframework_allow {
            if !allowed.insert(name.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!("duplicate `subframework-allow` `{name}`"),
                ));
            }
        }

        // A framework cannot be both excluded and promoted — that is a logical
        // contradiction in the roster policy.
        if let Some(both) = ignored.intersection(&allowed).next() {
            return Err(self.err(
                node.span(),
                format!("`{both}` is in both `ignore` and `subframework-allow`"),
            ));
        }

        Ok(())
    }
}

fn decode_enum<T: DeserializeOwned>(token: &str) -> Option<T> {
    serde_json::from_value(serde_json::Value::String(token.to_string())).ok()
}

fn children_of(node: &KdlNode) -> &[KdlNode] {
    node.children().map(KdlDocument::nodes).unwrap_or(&[])
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE: &str = r#"
        platform "macos" {
            doc "The macOS source platform."
            sdk "macosx"
            deployment-target "14.0"
            frameworks {
                discover "sdk-umbrella-headers"
                discover "synthetic-frameworks"
                subframework-allow "ApplicationServices"
                ignore "DriverKit" reason="C++ headers, not ObjC"
                ignore "Tk" reason="Tcl/Tk toolkit"
            }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let m = parse_manifest("sample.apiw", SAMPLE).expect("parses");
        assert_eq!(m.name, "macos");
        assert_eq!(m.sdk, "macosx");
        assert_eq!(m.deployment_target, "14.0");
        assert_eq!(
            m.frameworks.discover,
            vec![
                DiscoverSource::SdkUmbrellaHeaders,
                DiscoverSource::SyntheticFrameworks
            ]
        );
        assert_eq!(m.frameworks.subframework_allow, vec!["ApplicationServices"]);
        assert_eq!(
            m.frameworks
                .ignore
                .iter()
                .map(|i| i.name.as_str())
                .collect::<Vec<_>>(),
            vec!["DriverKit", "Tk"]
        );
    }

    #[test]
    fn rejects_duplicate_ignore() {
        let text = r#"
            platform "macos" {
                sdk "macosx"
                deployment-target "14.0"
                frameworks {
                    discover "sdk-umbrella-headers"
                    ignore "DriverKit" reason="one"
                    ignore "DriverKit" reason="two"
                }
            }
        "#;
        let err = parse_manifest("dup.apiw", text).expect_err("duplicate ignore rejected");
        assert!(format!("{err}").contains("duplicate `ignore`"));
    }

    #[test]
    fn rejects_duplicate_subframework_allow() {
        let text = r#"
            platform "macos" {
                sdk "macosx"
                deployment-target "14.0"
                frameworks {
                    discover "sdk-umbrella-headers"
                    subframework-allow "ApplicationServices"
                    subframework-allow "ApplicationServices"
                }
            }
        "#;
        let err = parse_manifest("dup.apiw", text).expect_err("duplicate allow rejected");
        assert!(format!("{err}").contains("duplicate `subframework-allow`"));
    }

    #[test]
    fn rejects_framework_both_ignored_and_promoted() {
        let text = r#"
            platform "macos" {
                sdk "macosx"
                deployment-target "14.0"
                frameworks {
                    discover "sdk-umbrella-headers"
                    subframework-allow "DriverKit"
                    ignore "DriverKit" reason="C++"
                }
            }
        "#;
        let err = parse_manifest("conflict.apiw", text).expect_err("contradiction rejected");
        assert!(format!("{err}").contains("both `ignore` and `subframework-allow`"));
    }
}
