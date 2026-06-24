//! The authored overlay: `annotations.apiw` (KDL 2.0) ⇄ the typed annotation model.
//!
//! `annotations.apiw` is the **one** human/LLM-authored semantic overlay
//! (ADR-0046): manual + accepted-LLM facts over a framework's methods, carrying
//! the §4 provenance stamp (`source` / `confidence` / `provenance`). It parses
//! to [`apianyware_types::annotation::FrameworkAnnotations`] and writes back
//! losslessly.
//!
//! ## Grammar
//!
//! ```kdl
//! framework "Foundation" {
//!     class "NSArray" {
//!         method "writeToURL:error:" is-instance=#true {
//!             param-ownership 0 ownership="copy"
//!             block-param 0 invocation="synchronous"
//!             threading "any_thread"
//!             error-pattern "error_out_param"
//!             source "llm"
//!             confidence "high"
//!             provenance "Foundation Release Notes"
//!         }
//!     }
//!     subagent-report {
//!         block-async-copied 15
//!     }
//! }
//! ```
//!
//! Enum string values (`copy`, `synchronous`, `error_out_param`, `llm`, `high`,
//! …) are the *serde* `snake_case` vocabulary — the single source of truth — so
//! a value's `.apiw` spelling always matches its `extracted.json`/`resolved.json`
//! spelling. The writer force-quotes any string that spells a KDL keyword
//! (`null`/`true`/`false`/`nan`/`inf`/`-inf`), working around the `kdl` crate's
//! round-trip-safety gap (k17 spike).

use apianyware_types::annotation::{
    AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ClassAnnotations, Confidence,
    ErrorPattern, FrameworkAnnotations, MethodAnnotation, OwnershipKind, ParamOwnership,
    SubagentReport, ThreadingConstraint,
};
use kdl::{KdlDocument, KdlEntry, KdlEntryFormat, KdlNode, KdlValue};
use miette::SourceSpan;
use serde::{de::DeserializeOwned, Serialize};

use crate::error::{Result, SpecFormatError};

// ===========================================================================
// Write: FrameworkAnnotations -> .apiw (KDL)
// ===========================================================================

/// Serialize an annotation overlay to `.apiw` (KDL 2.0) text.
pub fn write_apiw(annotations: &FrameworkAnnotations) -> String {
    let mut framework = KdlNode::new("framework");
    framework.push(string_arg(&annotations.framework));

    let mut body = KdlDocument::new();
    for class in &annotations.classes {
        body.nodes_mut().push(class_node(class));
    }
    if let Some(report) = &annotations.subagent_report {
        body.nodes_mut().push(subagent_report_node(report));
    }
    framework.set_children(body);

    let mut doc = KdlDocument::new();
    doc.nodes_mut().push(framework);
    doc.autoformat();
    doc.to_string()
}

fn class_node(class: &ClassAnnotations) -> KdlNode {
    let mut node = KdlNode::new("class");
    node.push(string_arg(&class.class_name));
    let mut methods = KdlDocument::new();
    for method in &class.methods {
        methods.nodes_mut().push(method_node(method));
    }
    node.set_children(methods);
    node
}

fn method_node(method: &MethodAnnotation) -> KdlNode {
    let mut node = KdlNode::new("method");
    node.push(string_arg(&method.selector));
    node.push(KdlEntry::new_prop("is-instance", method.is_instance));

    let mut body = KdlDocument::new();
    for po in &method.parameter_ownership {
        let mut n = KdlNode::new("param-ownership");
        n.push(KdlEntry::new(po.param_index as i128));
        n.push(KdlEntry::new_prop("ownership", enum_str(&po.ownership)));
        body.nodes_mut().push(n);
    }
    for bp in &method.block_parameters {
        let mut n = KdlNode::new("block-param");
        n.push(KdlEntry::new(bp.param_index as i128));
        n.push(KdlEntry::new_prop("invocation", enum_str(&bp.invocation)));
        body.nodes_mut().push(n);
    }
    if let Some(threading) = &method.threading {
        body.nodes_mut()
            .push(scalar_node("threading", enum_str(threading)));
    }
    if let Some(error) = &method.error_pattern {
        body.nodes_mut()
            .push(scalar_node("error-pattern", enum_str(error)));
    }
    body.nodes_mut()
        .push(scalar_node("source", enum_str(&method.source)));
    if let Some(confidence) = &method.confidence {
        body.nodes_mut()
            .push(scalar_node("confidence", enum_str(confidence)));
    }
    if let Some(provenance) = &method.provenance {
        body.nodes_mut()
            .push(scalar_node("provenance", provenance.clone()));
    }
    node.set_children(body);
    node
}

fn subagent_report_node(report: &SubagentReport) -> KdlNode {
    let mut node = KdlNode::new("subagent-report");
    let mut body = KdlDocument::new();
    let fields: [(&str, Option<usize>); 7] = [
        ("block-synchronous", report.block_synchronous),
        ("block-async-copied", report.block_async_copied),
        ("block-stored", report.block_stored),
        ("parameter-ownership", report.parameter_ownership),
        (
            "threading-main-thread-only",
            report.threading_main_thread_only,
        ),
        ("threading-any-thread", report.threading_any_thread),
        ("error-pattern", report.error_pattern),
    ];
    for (name, value) in fields {
        if let Some(count) = value {
            let mut n = KdlNode::new(name);
            n.push(KdlEntry::new(count as i128));
            body.nodes_mut().push(n);
        }
    }
    node.set_children(body);
    node
}

/// A node with a single string positional argument (`name "<value>"`).
fn scalar_node(name: &str, value: String) -> KdlNode {
    let mut node = KdlNode::new(name);
    node.push(string_arg(&value));
    node
}

/// Build a string positional entry, force-quoting strings that spell a KDL
/// keyword. The `kdl` crate would otherwise emit them bare (`null`, `true`, …)
/// and then reject them on re-parse — the round-trip-safety gap found by the
/// k17 spike. None of the keyword strings contain escapes, so `"s"` is valid.
fn string_arg(s: &str) -> KdlEntry {
    let mut entry = KdlEntry::new(s.to_string());
    if is_kdl_keyword(s) {
        entry.set_format(KdlEntryFormat {
            value_repr: format!("\"{s}\""),
            leading: " ".to_string(),
            autoformat_keep: true,
            ..Default::default()
        });
    }
    entry
}

fn is_kdl_keyword(s: &str) -> bool {
    matches!(s, "true" | "false" | "null" | "inf" | "-inf" | "nan")
}

/// The serde `snake_case` spelling of an annotation enum — the single shared
/// vocabulary with the machine JSON.
fn enum_str<T: Serialize>(value: &T) -> String {
    match serde_json::to_value(value) {
        Ok(serde_json::Value::String(s)) => s,
        // Every annotation enum serializes to a JSON string; unreachable in
        // practice, but degrade to a debug-ish token rather than panic.
        other => other.map(|v| v.to_string()).unwrap_or_default(),
    }
}

// ===========================================================================
// Parse: .apiw (KDL) -> FrameworkAnnotations
// ===========================================================================

/// Parse `.apiw` (KDL 2.0) text into the typed annotation overlay.
///
/// `source_name` labels diagnostics (typically the file name). Syntactic errors
/// forward the `kdl` crate's rich diagnostic; schema violations (missing
/// required node, unknown enum value) carry the offending node's span.
pub fn parse_apiw(source_name: &str, text: &str) -> Result<FrameworkAnnotations> {
    let doc = KdlDocument::parse(text)?;
    let ctx = Ctx { source_name, text };

    let framework = doc
        .nodes()
        .iter()
        .find(|n| n.name().value() == "framework")
        .ok_or_else(|| {
            ctx.err(
                doc.span(),
                "expected a top-level `framework \"<name>\"` node",
            )
        })?;

    let name = ctx.required_string_arg(framework, "framework")?;
    let mut classes = Vec::new();
    let mut subagent_report = None;

    for child in children_of(framework) {
        match child.name().value() {
            "class" => classes.push(ctx.parse_class(child)?),
            "subagent-report" => subagent_report = Some(ctx.parse_subagent_report(child)?),
            other => {
                return Err(ctx.err(
                    child.span(),
                    format!(
                    "unexpected node `{other}` in framework (want `class` or `subagent-report`)"
                ),
                ))
            }
        }
    }

    Ok(FrameworkAnnotations {
        framework: name,
        classes,
        subagent_report,
    })
}

/// Parsing context — carries what located errors need.
struct Ctx<'a> {
    source_name: &'a str,
    text: &'a str,
}

impl Ctx<'_> {
    fn err(&self, span: SourceSpan, message: impl Into<String>) -> SpecFormatError {
        SpecFormatError::apiw(self.source_name, self.text, span, message)
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

    /// First positional argument of `node`, as a non-negative integer.
    fn required_index_arg(&self, node: &KdlNode) -> Result<usize> {
        match node.get(0).and_then(KdlValue::as_integer) {
            Some(i) if i >= 0 => Ok(i as usize),
            _ => Err(self.err(
                node.span(),
                format!(
                    "`{}` needs a non-negative integer index",
                    node.name().value()
                ),
            )),
        }
    }

    /// Decode a `snake_case` enum token from a node's string argument.
    fn enum_arg<T: DeserializeOwned>(&self, node: &KdlNode, kind: &str) -> Result<T> {
        let token = self.required_string_arg(node, node.name().value())?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    /// Decode a `snake_case` enum token from a node's string property.
    fn enum_prop<T: DeserializeOwned>(&self, node: &KdlNode, key: &str, kind: &str) -> Result<T> {
        let token = self.required_string_prop(node, key)?;
        decode_enum(&token)
            .ok_or_else(|| self.err(node.span(), format!("`{token}` is not a valid {kind}")))
    }

    fn parse_class(&self, node: &KdlNode) -> Result<ClassAnnotations> {
        let class_name = self.required_string_arg(node, "class")?;
        let mut methods = Vec::new();
        for child in children_of(node) {
            match child.name().value() {
                "method" => methods.push(self.parse_method(child)?),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in class (want `method`)"),
                    ))
                }
            }
        }
        Ok(ClassAnnotations {
            class_name,
            methods,
        })
    }

    fn parse_method(&self, node: &KdlNode) -> Result<MethodAnnotation> {
        let selector = self.required_string_arg(node, "method")?;
        let is_instance = match node.get("is-instance").and_then(KdlValue::as_bool) {
            Some(b) => b,
            None => {
                return Err(self.err(
                    node.span(),
                    "`method` needs an `is-instance=#true|#false` property",
                ))
            }
        };

        let mut parameter_ownership = Vec::new();
        let mut block_parameters = Vec::new();
        let mut threading = None;
        let mut error_pattern = None;
        let mut source = None;
        let mut confidence = None;
        let mut provenance = None;

        for child in children_of(node) {
            match child.name().value() {
                "param-ownership" => parameter_ownership.push(ParamOwnership {
                    param_index: self.required_index_arg(child)?,
                    ownership: self.enum_prop::<OwnershipKind>(
                        child,
                        "ownership",
                        "ownership kind",
                    )?,
                }),
                "block-param" => block_parameters.push(BlockParamAnnotation {
                    param_index: self.required_index_arg(child)?,
                    invocation: self.enum_prop::<BlockInvocationStyle>(
                        child,
                        "invocation",
                        "block invocation style",
                    )?,
                }),
                "threading" => {
                    threading =
                        Some(self.enum_arg::<ThreadingConstraint>(child, "threading constraint")?)
                }
                "error-pattern" => {
                    error_pattern = Some(self.enum_arg::<ErrorPattern>(child, "error pattern")?)
                }
                "source" => {
                    source = Some(self.enum_arg::<AnnotationSource>(child, "annotation source")?)
                }
                "confidence" => {
                    confidence = Some(self.enum_arg::<Confidence>(child, "confidence level")?)
                }
                "provenance" => provenance = Some(self.required_string_arg(child, "provenance")?),
                other => {
                    return Err(
                        self.err(child.span(), format!("unexpected node `{other}` in method"))
                    )
                }
            }
        }

        let source = source.ok_or_else(|| {
            self.err(
                node.span(),
                "`method` is missing the required `source` node",
            )
        })?;

        Ok(MethodAnnotation {
            selector,
            is_instance,
            parameter_ownership,
            block_parameters,
            threading,
            error_pattern,
            source,
            confidence,
            provenance,
        })
    }

    fn parse_subagent_report(&self, node: &KdlNode) -> Result<SubagentReport> {
        let mut report = SubagentReport::default();
        for child in children_of(node) {
            let count = self.required_index_arg(child)?;
            match child.name().value() {
                "block-synchronous" => report.block_synchronous = Some(count),
                "block-async-copied" => report.block_async_copied = Some(count),
                "block-stored" => report.block_stored = Some(count),
                "parameter-ownership" => report.parameter_ownership = Some(count),
                "threading-main-thread-only" => report.threading_main_thread_only = Some(count),
                "threading-any-thread" => report.threading_any_thread = Some(count),
                "error-pattern" => report.error_pattern = Some(count),
                other => {
                    return Err(self.err(
                        child.span(),
                        format!("unexpected node `{other}` in subagent-report"),
                    ))
                }
            }
        }
        Ok(report)
    }
}

/// Decode a `snake_case` token into an annotation enum via serde — the same
/// vocabulary the machine JSON uses. Returns `None` on an unknown token.
fn decode_enum<T: DeserializeOwned>(token: &str) -> Option<T> {
    serde_json::from_value(serde_json::Value::String(token.to_string())).ok()
}

/// The child nodes of `node`, or an empty slice if it has no `{ … }` block.
fn children_of(node: &KdlNode) -> &[KdlNode] {
    node.children().map(KdlDocument::nodes).unwrap_or(&[])
}
