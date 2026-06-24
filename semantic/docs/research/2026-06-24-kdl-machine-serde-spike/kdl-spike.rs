//! kdl-serde-spike-k17 — gate the KDL-everywhere machine-IR decision (ADR-0046 §5).
//!
//! Proves (or disproves) that the large machine IR can be serialized/deserialized
//! as KDL with acceptable performance, on one real framework.
//!
//! Path B (decision-grade): a generic, bijective `serde_json::Value <-> kdl::KdlDocument`
//! bridge using the *official* `kdl` crate (the one ADR-0046 commits to). This is the
//! canonical "JSON-in-KDL" (JiK) mapping: objects/arrays carry an `(object)`/`(array)`
//! type annotation; array elements are `-`-named child nodes; scalars are a single
//! positional argument whose KDL value type carries string/int/float/bool/null.
//!
//! It sidesteps the one real serde landmine in the IR — `TypeRef` is `#[serde(flatten)]`
//! over an internally-tagged enum — because `Framework -> serde_json::Value` already works
//! (it's the production format) and the bridge operates on `Value`. This is also exactly
//! the `json->kdl` converter the spec-format crate (k18) will ship.

use std::time::Instant;

use kdl::{KdlDocument, KdlEntry, KdlEntryFormat, KdlNode, KdlValue};
use serde_json::Value;

/// Strings that `kdl`'s `is_plain_ident` accepts for bare emission but the
/// parser then rejects as keywords — the official crate's round-trip-safety gap.
/// (`selector "null"`, `name "true"`, `name "nan"` all occur in the real IR.)
fn is_kdl_keyword(s: &str) -> bool {
    matches!(s, "true" | "false" | "null" | "inf" | "-inf" | "nan")
}

/// Build a String-valued positional entry, force-quoting keyword strings the
/// crate would otherwise emit bare-and-unparseable.
fn string_entry(s: &str) -> KdlEntry {
    let mut e = KdlEntry::new(s.to_string());
    if is_kdl_keyword(s) {
        // None of the keyword strings contain escapes, so `"s"` is valid KDL.
        let fmt = KdlEntryFormat {
            value_repr: format!("\"{s}\""),
            leading: " ".to_string(),
            autoformat_keep: true,
            ..Default::default()
        };
        e.set_format(fmt);
    }
    e
}

// ---------------------------------------------------------------------------
// Encode: serde_json::Value -> kdl::KdlDocument  (JiK)
// ---------------------------------------------------------------------------

/// Encode a JSON value as a KDL node with the given node name.
fn encode_node(name: &str, v: &Value) -> KdlNode {
    let mut node = KdlNode::new(name);
    match v {
        Value::Null => node.push(KdlEntry::new(KdlValue::Null)),
        Value::Bool(b) => node.push(KdlEntry::new(*b)),
        Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                node.push(KdlEntry::new(i as i128));
            } else if let Some(u) = n.as_u64() {
                node.push(KdlEntry::new(u as i128));
            } else {
                node.push(KdlEntry::new(n.as_f64().expect("json number is f64")));
            }
        }
        Value::String(s) => node.push(string_entry(s)),
        Value::Array(items) => {
            node.set_ty("array");
            let mut doc = KdlDocument::new();
            for item in items {
                doc.nodes_mut().push(encode_node("-", item));
            }
            node.set_children(doc);
        }
        Value::Object(map) => {
            node.set_ty("object");
            let mut doc = KdlDocument::new();
            for (k, val) in map {
                doc.nodes_mut().push(encode_node(k, val));
            }
            node.set_children(doc);
        }
    }
    node
}

/// Encode a top-level JSON object as a KDL document (its members become top-level nodes).
fn value_to_kdl(v: &Value) -> KdlDocument {
    let mut doc = KdlDocument::new();
    match v {
        Value::Object(map) => {
            for (k, val) in map {
                doc.nodes_mut().push(encode_node(k, val));
            }
        }
        // The IR's top level is always an object; wrap anything else under a sentinel.
        other => doc.nodes_mut().push(encode_node("-", other)),
    }
    doc
}

// ---------------------------------------------------------------------------
// Decode: kdl::KdlDocument -> serde_json::Value
// ---------------------------------------------------------------------------

fn kdl_value_to_json(v: &KdlValue) -> Value {
    match v {
        KdlValue::Null => Value::Null,
        KdlValue::Bool(b) => Value::Bool(*b),
        KdlValue::String(s) => Value::String(s.clone()),
        KdlValue::Integer(i) => {
            // Match serde_json's canonicalization: non-negative -> u64 (PosInt),
            // negative -> i64 (NegInt). Our IR ints all fit; guard anyway.
            if *i >= 0 {
                Value::Number((*i as u64).into())
            } else {
                Value::Number((*i as i64).into())
            }
        }
        KdlValue::Float(f) => serde_json::Number::from_f64(*f)
            .map(Value::Number)
            .unwrap_or(Value::Null),
    }
}

/// Decode one KDL node into a JSON value (ignoring its name; the caller keys it).
fn decode_node(node: &KdlNode) -> Value {
    match node.ty().map(|t| t.value()) {
        Some("array") => {
            let items = node
                .children()
                .map(|d| d.nodes().iter().map(decode_node).collect())
                .unwrap_or_default();
            Value::Array(items)
        }
        Some("object") => {
            let mut map = serde_json::Map::new();
            if let Some(d) = node.children() {
                for child in d.nodes() {
                    map.insert(child.name().value().to_string(), decode_node(child));
                }
            }
            Value::Object(map)
        }
        _ => {
            // Scalar: single positional argument.
            let entry = node
                .entries()
                .iter()
                .find(|e| e.name().is_none())
                .expect("scalar node must have a positional argument");
            kdl_value_to_json(entry.value())
        }
    }
}

fn kdl_to_value(doc: &KdlDocument) -> Value {
    let mut map = serde_json::Map::new();
    for node in doc.nodes() {
        map.insert(node.name().value().to_string(), decode_node(node));
    }
    Value::Object(map)
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

fn ms(d: std::time::Duration) -> f64 {
    d.as_secs_f64() * 1000.0
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let path = args.get(1).expect("usage: kdl-spike <collected.json> [out-dir]");
    let out_dir = args.get(2).cloned().unwrap_or_else(|| ".".to_string());

    let json_text = std::fs::read_to_string(path).expect("read input json");
    let name = std::path::Path::new(path)
        .file_stem()
        .map(|s| s.to_string_lossy().to_string())
        .unwrap_or_default();

    println!("== {name} ==");
    println!("input json (pretty, on-disk): {} bytes", json_text.len());

    // 0. Confirm the *real* IR serde types accept this data (not just generic Value).
    let t = Instant::now();
    let fw: apianyware_types::ir::Framework =
        serde_json::from_str(&json_text).expect("Framework deserialize");
    let t_fw_parse = t.elapsed();
    println!(
        "Framework (real types) parse: {:.1} ms  [classes={} protocols={} enums={} structs={} functions={} constants={}]",
        ms(t_fw_parse),
        fw.classes.len(),
        fw.protocols.len(),
        fw.enums.len(),
        fw.structs.len(),
        fw.functions.len(),
        fw.constants.len()
    );

    // 1. JSON: parse text -> Value.
    let t = Instant::now();
    let value: Value = serde_json::from_str(&json_text).expect("json -> Value");
    let t_json_parse = t.elapsed();

    // 2. JSON: emit Value -> pretty + compact.
    let t = Instant::now();
    let json_pretty = serde_json::to_string_pretty(&value).unwrap();
    let t_json_emit_pretty = t.elapsed();
    let t = Instant::now();
    let json_compact = serde_json::to_string(&value).unwrap();
    let t_json_emit_compact = t.elapsed();

    // 3. KDL: build doc from Value.
    let t = Instant::now();
    let mut doc = value_to_kdl(&value);
    let t_kdl_build = t.elapsed();

    // 4. KDL: autoformat + emit to text.
    let t = Instant::now();
    doc.autoformat();
    let kdl_text = doc.to_string();
    let t_kdl_emit = t.elapsed();

    // 5. KDL: parse text -> doc.
    // Persist the emitted KDL *before* parsing so a parse failure is inspectable.
    let kdl_path = format!("{out_dir}/{name}.kdl");
    std::fs::write(&kdl_path, &kdl_text).unwrap();
    let t = Instant::now();
    let reparsed = match KdlDocument::parse(&kdl_text) {
        Ok(d) => d,
        Err(e) => {
            eprintln!("\n❌ KDL PARSE FAILED on emitted text ({name}) — {} diagnostic(s):", e.diagnostics.len());
            for (i, d) in e.diagnostics.iter().take(5).enumerate() {
                let off = d.span.offset();
                let lo = off.saturating_sub(60);
                let hi = (off + 60).min(kdl_text.len());
                eprintln!(
                    "  [{i}] msg={:?} label={:?} help={:?} @byte {}",
                    d.message, d.label, d.help, off
                );
                eprintln!("       …{}…", &kdl_text[lo..hi].replace('\n', "⏎"));
            }
            std::process::exit(2);
        }
    };
    let t_kdl_parse = t.elapsed();

    // 6. KDL: decode doc -> Value.
    let t = Instant::now();
    let roundtripped = kdl_to_value(&reparsed);
    let t_kdl_decode = t.elapsed();

    // 7. Correctness: structural (serde) equality.
    let ok = value == roundtripped;

    // Persist artifacts for on-disk + gzip comparison (kdl already written above).
    let jc_path = format!("{out_dir}/{name}.compact.json");
    std::fs::write(&jc_path, &json_compact).unwrap();
    std::fs::write(format!("{out_dir}/{name}.pretty.json"), &json_pretty).unwrap();

    println!();
    println!("--- correctness ---");
    println!(
        "JSON<->KDL round-trip structural equality: {}",
        if ok { "PASS ✅" } else { "FAIL ❌" }
    );
    if !ok {
        // Localize the first divergence for debugging.
        report_first_diff(&value, &roundtripped, "$");
    }

    println!();
    println!("--- timings (ms) ---");
    println!("json parse  (text->Value)   : {:>8.1}", ms(t_json_parse));
    println!("json emit   (Value->pretty) : {:>8.1}", ms(t_json_emit_pretty));
    println!("json emit   (Value->compact): {:>8.1}", ms(t_json_emit_compact));
    println!("kdl  build  (Value->doc)    : {:>8.1}", ms(t_kdl_build));
    println!("kdl  emit   (doc->text)     : {:>8.1}", ms(t_kdl_emit));
    println!("kdl  parse  (text->doc)     : {:>8.1}", ms(t_kdl_parse));
    println!("kdl  decode (doc->Value)    : {:>8.1}", ms(t_kdl_decode));
    println!(
        "kdl  full ser  (Value->text)  = build+emit : {:>8.1}",
        ms(t_kdl_build + t_kdl_emit)
    );
    println!(
        "kdl  full de   (text->Value)  = parse+decode: {:>8.1}",
        ms(t_kdl_parse + t_kdl_decode)
    );

    println!();
    println!("--- on-disk sizes (bytes) ---");
    println!("json pretty : {:>12}", json_pretty.len());
    println!("json compact: {:>12}", json_compact.len());
    println!("kdl  (autofmt): {:>10}", kdl_text.len());
    println!(
        "kdl / json-pretty  = {:.2}x ; kdl / json-compact = {:.2}x",
        kdl_text.len() as f64 / json_pretty.len() as f64,
        kdl_text.len() as f64 / json_compact.len() as f64
    );
    println!("(gzip comparison done by the harness)");
}

/// Walk both values and print the first structural divergence (path + kinds).
fn report_first_diff(a: &Value, b: &Value, path: &str) {
    match (a, b) {
        (Value::Object(ma), Value::Object(mb)) => {
            for (k, va) in ma {
                match mb.get(k) {
                    Some(vb) => {
                        if va != vb {
                            report_first_diff(va, vb, &format!("{path}.{k}"));
                            return;
                        }
                    }
                    None => {
                        println!("DIFF at {path}.{k}: present in original, missing in round-trip");
                        return;
                    }
                }
            }
            for k in mb.keys() {
                if !ma.contains_key(k) {
                    println!("DIFF at {path}.{k}: extra key in round-trip");
                    return;
                }
            }
        }
        (Value::Array(aa), Value::Array(ab)) => {
            if aa.len() != ab.len() {
                println!(
                    "DIFF at {path}: array len {} != {}",
                    aa.len(),
                    ab.len()
                );
                return;
            }
            for (i, (va, vb)) in aa.iter().zip(ab).enumerate() {
                if va != vb {
                    report_first_diff(va, vb, &format!("{path}[{i}]"));
                    return;
                }
            }
        }
        _ => {
            let ta = format!("{a:?}");
            let tb = format!("{b:?}");
            println!(
                "DIFF at {path}: {} != {}",
                &ta[..ta.len().min(120)],
                &tb[..tb.len().min(120)]
            );
        }
    }
}
