//! The authored adapter spec: `adapters/<platform>/spec.apiw` (KDL 2.0) → the typed
//! [`AdapterSpec`], plus the **semantic** checks the language-neutral KDL Schema cannot
//! state.
//!
//! Parsing runs in two layers, mirroring the sibling `policy` / `idioms` / `capability`
//! submodules:
//!
//! 1. **Structural** — [`crate::adapter_spec::schema::validate_adapter_spec`] checks the
//!    document against `adapter-spec.kdl-schema` (node shapes, the `status` enum, occurrence
//!    cardinality, default-deny of unknown nodes). Run by the loader *before*
//!    [`parse_adapter_spec`].
//! 2. **Semantic** — this module, after a clean parse: every `role` is a member of the §26
//!    [`crate::vocab::ADAPTER_ROLES`] vocabulary and unique within the spec; every `service`
//!    is a member of [`crate::vocab::RUNTIME_SERVICES`] and unique; and no API category is
//!    both `allow`-ed and `deny`-ed in the direct-call policy.
//!
//! The spec's identity (id = the target directory, platform = the parent directory) is a
//! registry-level check ([`crate::adapter_spec::registry`]) — the parse layer is path-unaware.
//!
//! ## Grammar
//!
//! ```kdl
//! adapter-spec "racket" {
//!     platform "macos"
//!     doc "The APIAnywareRacket native adapter library on macOS."
//!     output {
//!         library "APIAnywareRacket"
//!         kind "dynamic-library"
//!         symbol-prefix "aw_racket_"
//!     }
//!     role "callback-adapter" { doc "BlockBridge + DelegateBridge + ObservationBridge" }
//!     service "callback-registry" { status "required"; doc "GCPrevention roots callbacks" }
//!     direct-call-policy {
//!         allow "directly-reachable-objc" { doc "trampoline-elided objc_msgSend" }
//!         deny "swift-native-async" { doc "needs the AsyncBridge trampoline" }
//!     }
//! }
//! ```
//!
//! The `status` value is the *serde* vocabulary of [`ServiceStatus`] — the single source of
//! truth — so its `.apiw` spelling always matches the typed model. The `role` / `service`
//! tokens are checked against the §26 vocabularies by this module.

use std::collections::BTreeSet;

use kdl::{KdlDocument, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::de::DeserializeOwned;

use crate::adapter_spec::model::{
    AdapterOutput, AdapterRole, AdapterSpec, DirectCallPolicy, DirectCallRule, RuntimeService,
    ServiceStatus,
};
use crate::error::{Result, TargetModelError};
use crate::vocab;

/// Parse an `adapters/<platform>/spec.apiw` (KDL 2.0) document into the typed model and run
/// the semantic checks.
///
/// `source_name` labels diagnostics (typically the file path). Assumes the document has
/// already passed [`crate::adapter_spec::schema::validate_adapter_spec`]; it still guards
/// every access so a direct call without structural validation yields a located error rather
/// than a panic.
pub fn parse_adapter_spec(source_name: &str, text: &str) -> Result<AdapterSpec> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let node = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "adapter-spec")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `adapter-spec \"<id>\"` node",
            )
        })?;

    let spec = ctx.parse_spec(node)?;
    ctx.check_semantics(&spec, node)?;
    Ok(spec)
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

    fn parse_spec(&self, node: &KdlNode) -> Result<AdapterSpec> {
        let id = self.required_string_arg(node, "adapter-spec")?;
        let doc = self.optional_doc(node)?;
        let mut platform = None;
        let mut output = None;
        let mut roles = Vec::new();
        let mut services = Vec::new();
        let mut direct_call_policy = None;

        for child in children_of(node) {
            match child.name().value() {
                "doc" => {} // handled by `optional_doc`
                "platform" => platform = Some(self.required_string_arg(child, "platform")?),
                "output" => output = Some(self.parse_output(child)?),
                "role" => roles.push(self.parse_role(child)?),
                "service" => services.push(self.parse_service(child)?),
                "direct-call-policy" => {
                    direct_call_policy = Some(self.parse_direct_call_policy(child)?)
                }
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in adapter-spec"),
                    ))
                }
            }
        }

        let platform =
            platform.ok_or_else(|| self.err(node.span(), "adapter-spec is missing `platform`"))?;
        let output =
            output.ok_or_else(|| self.err(node.span(), "adapter-spec is missing `output`"))?;

        Ok(AdapterSpec {
            id,
            platform,
            doc,
            output,
            roles,
            services,
            direct_call_policy,
        })
    }

    fn parse_output(&self, node: &KdlNode) -> Result<AdapterOutput> {
        let mut library = None;
        let mut kind = None;
        let mut symbol_prefix = None;
        for child in children_of(node) {
            match child.name().value() {
                "library" => library = Some(self.required_string_arg(child, "library")?),
                "kind" => kind = Some(self.required_string_arg(child, "kind")?),
                "symbol-prefix" => {
                    symbol_prefix = Some(self.required_string_arg(child, "symbol-prefix")?)
                }
                other => {
                    return Err(
                        self.err(child.span(), format!("unexpected node `{other}` in output"))
                    )
                }
            }
        }
        Ok(AdapterOutput {
            library: library.ok_or_else(|| self.err(node.span(), "output is missing `library`"))?,
            kind: kind.ok_or_else(|| self.err(node.span(), "output is missing `kind`"))?,
            symbol_prefix,
        })
    }

    fn parse_role(&self, node: &KdlNode) -> Result<AdapterRole> {
        let role = self.required_string_arg(node, "role")?;
        if !vocab::is_valid_adapter_role(&role) {
            return Err(self.err(
                node.span(),
                format!("`{role}` is not a REFACTOR §26 adapter role"),
            ));
        }
        let doc = self.optional_doc(node)?;
        // Reject any non-`doc` child (the schema default-denies, but guard the direct path).
        for child in children_of(node) {
            if child.name().value() != "doc" {
                return Err(self.err(
                    child.span(),
                    format!(
                        "unexpected node `{}` in role `{role}`",
                        child.name().value()
                    ),
                ));
            }
        }
        Ok(AdapterRole { role, doc })
    }

    fn parse_service(&self, node: &KdlNode) -> Result<RuntimeService> {
        let service = self.required_string_arg(node, "service")?;
        if !vocab::is_valid_runtime_service(&service) {
            return Err(self.err(
                node.span(),
                format!("`{service}` is not a REFACTOR §26 runtime service"),
            ));
        }
        let mut status = None;
        let mut doc = None;
        for child in children_of(node) {
            match child.name().value() {
                "status" => status = Some(self.enum_arg::<ServiceStatus>(child, "service status")?),
                "doc" => doc = Some(self.required_string_arg(child, "doc")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in service `{service}`"),
                    ))
                }
            }
        }
        Ok(RuntimeService {
            status: status.ok_or_else(|| {
                self.err(
                    node.span(),
                    format!("service `{service}` is missing `status`"),
                )
            })?,
            service,
            doc,
        })
    }

    fn parse_direct_call_policy(&self, node: &KdlNode) -> Result<DirectCallPolicy> {
        let mut allow = Vec::new();
        let mut deny = Vec::new();
        for child in children_of(node) {
            match child.name().value() {
                "allow" => allow.push(self.parse_rule(child, "allow")?),
                "deny" => deny.push(self.parse_rule(child, "deny")?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in direct-call-policy"),
                    ))
                }
            }
        }
        Ok(DirectCallPolicy { allow, deny })
    }

    fn parse_rule(&self, node: &KdlNode, what: &str) -> Result<DirectCallRule> {
        let category = self.required_string_arg(node, what)?;
        let doc = self.optional_doc(node)?;
        for child in children_of(node) {
            if child.name().value() != "doc" {
                return Err(self.err(
                    child.span(),
                    format!(
                        "unexpected node `{}` in {what} `{category}`",
                        child.name().value()
                    ),
                ));
            }
        }
        Ok(DirectCallRule { category, doc })
    }

    /// Decode a serde enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    /// The cross-field coherence the language-neutral schema cannot state: §26 role + service
    /// per-spec uniqueness, and allow∩deny disjointness (a category cannot be both directly
    /// callable and adapter-mediated). `node` locates errors.
    fn check_semantics(&self, spec: &AdapterSpec, node: &KdlNode) -> Result<()> {
        let mut seen_role = BTreeSet::new();
        for role in &spec.roles {
            if !seen_role.insert(role.role.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!("the spec declares role `{}` more than once", role.role),
                ));
            }
        }
        let mut seen_service = BTreeSet::new();
        for service in &spec.services {
            if !seen_service.insert(service.service.as_str()) {
                return Err(self.err(
                    node.span(),
                    format!(
                        "the spec declares service `{}` more than once",
                        service.service
                    ),
                ));
            }
        }
        if let Some(policy) = &spec.direct_call_policy {
            let allowed: BTreeSet<&str> =
                policy.allow.iter().map(|r| r.category.as_str()).collect();
            for rule in &policy.deny {
                if allowed.contains(rule.category.as_str()) {
                    return Err(self.err(
                        node.span(),
                        format!(
                            "category `{}` is both allowed and denied in the direct-call policy",
                            rule.category
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

    const RACKET: &str = r#"
        adapter-spec "racket" {
            platform "macos"
            doc "The APIAnywareRacket native adapter library on macOS."
            output {
                library "APIAnywareRacket"
                kind "dynamic-library"
                symbol-prefix "aw_racket_"
            }
            role "callback-adapter" { doc "BlockBridge + DelegateBridge + ObservationBridge" }
            role "error-adapter" { doc "ThrowsBridge" }
            service "callback-registry" {
                status "required"
                doc "GCPrevention roots Scheme callbacks against GC"
            }
            service "main-thread-dispatch" { status "required" }
            direct-call-policy {
                allow "directly-reachable-objc" { doc "trampoline-elided objc_msgSend" }
                deny "swift-native-async" { doc "needs the AsyncBridge trampoline" }
            }
        }
    "#;

    #[test]
    fn parses_the_typed_model() {
        let s = parse_adapter_spec("racket/adapters/macos/spec.apiw", RACKET).expect("parses");
        assert_eq!(s.id, "racket");
        assert_eq!(s.platform, "macos");
        assert_eq!(s.output.library, "APIAnywareRacket");
        assert_eq!(s.output.kind, "dynamic-library");
        assert_eq!(s.output.symbol_prefix.as_deref(), Some("aw_racket_"));
        assert!(s.has_role("callback-adapter"));
        assert!(s.has_role("error-adapter"));
        assert!(!s.has_role("collection-adapter"));
        assert_eq!(
            s.service("callback-registry").map(|s| s.status),
            Some(ServiceStatus::Required)
        );
        let policy = s.direct_call_policy.as_ref().expect("has a policy");
        assert_eq!(policy.allow.len(), 1);
        assert_eq!(policy.deny.len(), 1);
    }

    #[test]
    fn rejects_a_role_outside_the_section_26_vocabulary() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                output { library "X"; kind "dynamic-library" }
                role "teleport-adapter"
            }
        "#;
        let err =
            parse_adapter_spec("x/adapters/macos/spec.apiw", text).expect_err("bad role rejected");
        assert!(format!("{err}").contains("not a REFACTOR §26 adapter role"));
    }

    #[test]
    fn rejects_a_service_outside_the_section_26_vocabulary() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                output { library "X"; kind "dynamic-library" }
                service "teleport-registry" { status "required" }
            }
        "#;
        let err = parse_adapter_spec("x/adapters/macos/spec.apiw", text)
            .expect_err("bad service rejected");
        assert!(format!("{err}").contains("not a REFACTOR §26 runtime service"));
    }

    #[test]
    fn rejects_a_duplicate_role() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                output { library "X"; kind "dynamic-library" }
                role "error-adapter"
                role "error-adapter"
            }
        "#;
        let err = parse_adapter_spec("x/adapters/macos/spec.apiw", text)
            .expect_err("duplicate role rejected");
        assert!(format!("{err}").contains("more than once"));
    }

    #[test]
    fn rejects_a_category_both_allowed_and_denied() {
        let text = r#"
            adapter-spec "x" {
                platform "macos"
                output { library "X"; kind "dynamic-library" }
                direct-call-policy {
                    allow "swift-native-async"
                    deny "swift-native-async"
                }
            }
        "#;
        let err = parse_adapter_spec("x/adapters/macos/spec.apiw", text)
            .expect_err("allow∩deny rejected");
        assert!(format!("{err}").contains("both allowed and denied"));
    }
}
