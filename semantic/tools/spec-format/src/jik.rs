//! JiK — a hand-written, non-format-preserving **JSON-in-KDL** codec over
//! [`serde_json::Value`].
//!
//! This is the machine-IR codec: [`machine`](crate::machine) bridges the typed
//! [`Framework`](apianyware_types::ir::Framework) through `serde_json::Value`
//! (`to_value` / `from_value`) and encodes/decodes the `Value` here. It is the
//! production form of the `machine-format-spike-k150` prototype
//! (`semantic/docs/research/2026-07-04-kdl-machine-codec-spike/`), whose numbers
//! cleared the D2 bar (~1.24–1.29× `serde_json` on the raw codec; ~2.4–3.2× on
//! the full typed path) and let ADR-0046 un-retreat the machine IR to KDL.
//!
//! # Why hand-written, not a crate
//!
//! The format-preserving document-model `kdl` crate (which this crate *does* use
//! for the authored `.apiw` overlay) parses the multi-MB machine IR ~84× slower
//! than `serde_json` — it keeps owned source spans and per-node whitespace to
//! round-trip comments and layout, none of which a write-once/read-mechanically
//! machine artifact needs. The k17 spike rejected that path; no ecosystem
//! serde-KDL crate avoids the document model. So the machine codec is this
//! streaming emitter + a hand-rolled tokenizer over the restricted JiK subset.
//!
//! # The JiK mapping (a total bijection with JSON)
//!
//! - a top-level object → its members become the document's top-level nodes;
//! - a scalar → a node with **one positional argument** (the KDL value carries
//!   the JSON type: `#null` / `#true` / `#false` / number / quoted string);
//! - an array → an `(array)`-typed node whose elements are `-`-named children;
//! - an object → an `(object)`-typed node whose members are key-named children.
//!
//! The `(array)` / `(object)` type annotation is what disambiguates an *empty*
//! container from a scalar, so decode is unambiguous. Keys and string values are
//! **always quoted**, and keywords use KDL-2.0 syntax (`#null`/`#true`/`#false`) —
//! which sidesteps k17's bare-keyword footgun (a string `"null"` vs the keyword
//! `null`) by construction. The emitted text is spec-valid KDL 2.0 (guarded by a
//! cross-check against the official `kdl` crate in this module's tests).

use serde_json::Value;

// ===========================================================================
// emit: Value → KDL text
// ===========================================================================

/// Encode a JSON value as JiK KDL text. The result is spec-valid KDL 2.0 and
/// ends with a trailing newline.
///
/// The round-trip guarantee (`value == parse(emit(value))`) holds for
/// **object-rooted** documents — the only shape the machine IR takes (it is
/// always a [`Framework`](apianyware_types::ir::Framework), a JSON object). A
/// KDL document is a node list, so a bare scalar/array root has no faithful
/// representation; it is emitted defensively as a single `-`-named node but does
/// not round-trip back to a bare root. Callers pass object-rooted values.
pub fn emit(v: &Value) -> String {
    // Rough capacity hint: JiK text is ~pretty-JSON-sized (k17/k150 size study).
    let mut out = String::with_capacity(4096);
    match v {
        Value::Object(map) => {
            for (k, val) in map {
                emit_node(&mut out, Name::Key(k), val, 0);
            }
        }
        // A non-object document root has no member names; emit it as a single
        // `-`-named node so a bare scalar/array round-trips too.
        other => emit_node(&mut out, Name::Dash, other, 0),
    }
    out
}

enum Name<'a> {
    Key(&'a str),
    Dash,
}

fn emit_name(out: &mut String, name: &Name<'_>) {
    match name {
        Name::Dash => out.push('-'),
        Name::Key(k) => emit_quoted(out, k),
    }
}

fn indent(out: &mut String, depth: usize) {
    for _ in 0..depth {
        out.push_str("  ");
    }
}

fn emit_node(out: &mut String, name: Name<'_>, v: &Value, depth: usize) {
    indent(out, depth);
    match v {
        Value::Array(items) => {
            out.push_str("(array)");
            emit_name(out, &name);
            if items.is_empty() {
                out.push('\n');
            } else {
                out.push_str(" {\n");
                for it in items {
                    emit_node(out, Name::Dash, it, depth + 1);
                }
                indent(out, depth);
                out.push_str("}\n");
            }
        }
        Value::Object(map) => {
            out.push_str("(object)");
            emit_name(out, &name);
            if map.is_empty() {
                out.push('\n');
            } else {
                out.push_str(" {\n");
                for (k, val) in map {
                    emit_node(out, Name::Key(k), val, depth + 1);
                }
                indent(out, depth);
                out.push_str("}\n");
            }
        }
        scalar => {
            emit_name(out, &name);
            out.push(' ');
            emit_scalar(out, scalar);
            out.push('\n');
        }
    }
}

fn emit_scalar(out: &mut String, v: &Value) {
    use std::fmt::Write;
    match v {
        Value::Null => out.push_str("#null"),
        Value::Bool(true) => out.push_str("#true"),
        Value::Bool(false) => out.push_str("#false"),
        Value::Number(n) => {
            if let Some(u) = n.as_u64() {
                let _ = write!(out, "{u}");
            } else if let Some(i) = n.as_i64() {
                let _ = write!(out, "{i}");
            } else {
                let f = n.as_f64().expect("json number is u64, i64, or f64");
                let s = format!("{f}");
                out.push_str(&s);
                // Force KDL float syntax for whole-valued floats so decode keeps
                // them f64 (a bare `2` would re-parse as an integer).
                if !s.bytes().any(|b| b == b'.' || b == b'e' || b == b'E') {
                    out.push_str(".0");
                }
            }
        }
        Value::String(s) => emit_quoted(out, s),
        // Arrays/objects are handled in emit_node, never reach here.
        Value::Array(_) | Value::Object(_) => unreachable!("container in scalar position"),
    }
}

fn emit_quoted(out: &mut String, s: &str) {
    use std::fmt::Write;
    out.push('"');
    for c in s.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\t' => out.push_str("\\t"),
            '\r' => out.push_str("\\r"),
            c if (c as u32) < 0x20 => {
                let _ = write!(out, "\\u{{{:x}}}", c as u32);
            }
            c => out.push(c),
        }
    }
    out.push('"');
}

// ===========================================================================
// parse: KDL text → Value
// ===========================================================================

/// Decode JiK KDL text back to a JSON value. Accepts only the restricted subset
/// [`emit`] produces; a syntactically-general KDL document is not the concern
/// here (that is the authored-`.apiw` document model's job). Returns a
/// human-readable message on malformed input.
pub fn parse(text: &str) -> Result<Value, String> {
    let mut p = Parser {
        b: text.as_bytes(),
        i: 0,
    };
    let mut map = serde_json::Map::new();
    p.parse_object_body(&mut map)?;
    p.skip_ws();
    if p.i != p.b.len() {
        return Err(format!("trailing input at byte {}", p.i));
    }
    Ok(Value::Object(map))
}

struct Parser<'a> {
    b: &'a [u8],
    i: usize,
}

enum Ty {
    Array,
    Object,
    None,
}

impl Parser<'_> {
    #[inline]
    fn eof(&self) -> bool {
        self.i >= self.b.len()
    }
    #[inline]
    fn peek(&self) -> u8 {
        self.b[self.i]
    }
    #[inline]
    fn skip_ws(&mut self) {
        while self.i < self.b.len() {
            match self.b[self.i] {
                b' ' | b'\t' | b'\n' | b'\r' => self.i += 1,
                _ => break,
            }
        }
    }

    /// Parse the members of an object (or the whole document) into `map`,
    /// stopping at `}` or EOF.
    fn parse_object_body(
        &mut self,
        map: &mut serde_json::Map<String, Value>,
    ) -> Result<(), String> {
        loop {
            self.skip_ws();
            if self.eof() || self.peek() == b'}' {
                return Ok(());
            }
            let ty = self.parse_opt_type()?;
            let name = self.parse_name()?;
            let val = self.parse_value_for(ty)?;
            map.insert(name, val);
        }
    }

    fn parse_array_body(&mut self, vec: &mut Vec<Value>) -> Result<(), String> {
        loop {
            self.skip_ws();
            if self.eof() || self.peek() == b'}' {
                return Ok(());
            }
            let ty = self.parse_opt_type()?;
            let _name = self.parse_name()?; // `-`, ignored in array context
            let val = self.parse_value_for(ty)?;
            vec.push(val);
        }
    }

    fn parse_opt_type(&mut self) -> Result<Ty, String> {
        self.skip_ws();
        if self.eof() || self.peek() != b'(' {
            return Ok(Ty::None);
        }
        self.i += 1; // consume '('
        let start = self.i;
        while self.i < self.b.len() && self.b[self.i] != b')' {
            self.i += 1;
        }
        if self.eof() {
            return Err("unterminated type annotation".into());
        }
        let ty = &self.b[start..self.i];
        self.i += 1; // consume ')'
        match ty {
            b"array" => Ok(Ty::Array),
            b"object" => Ok(Ty::Object),
            other => Err(format!(
                "unknown type annotation ({})",
                String::from_utf8_lossy(other)
            )),
        }
    }

    fn parse_name(&mut self) -> Result<String, String> {
        self.skip_ws();
        if self.eof() {
            return Err("expected node name, got EOF".into());
        }
        if self.peek() == b'"' {
            self.parse_quoted()
        } else {
            // Bare name (only `-` in our emitter). Read until whitespace / `{` / `(`.
            let start = self.i;
            while self.i < self.b.len() {
                match self.b[self.i] {
                    b' ' | b'\t' | b'\n' | b'\r' | b'{' | b'(' => break,
                    _ => self.i += 1,
                }
            }
            Ok(String::from_utf8_lossy(&self.b[start..self.i]).into_owned())
        }
    }

    fn parse_value_for(&mut self, ty: Ty) -> Result<Value, String> {
        match ty {
            Ty::Array => {
                self.skip_ws();
                if !self.eof() && self.peek() == b'{' {
                    self.i += 1; // consume '{'
                    let mut vec = Vec::new();
                    self.parse_array_body(&mut vec)?;
                    self.expect(b'}')?;
                    Ok(Value::Array(vec))
                } else {
                    Ok(Value::Array(Vec::new()))
                }
            }
            Ty::Object => {
                self.skip_ws();
                if !self.eof() && self.peek() == b'{' {
                    self.i += 1; // consume '{'
                    let mut map = serde_json::Map::new();
                    self.parse_object_body(&mut map)?;
                    self.expect(b'}')?;
                    Ok(Value::Object(map))
                } else {
                    Ok(Value::Object(serde_json::Map::new()))
                }
            }
            Ty::None => {
                // Scalar: one positional argument.
                self.skip_ws();
                self.parse_arg()
            }
        }
    }

    fn expect(&mut self, c: u8) -> Result<(), String> {
        self.skip_ws();
        if self.eof() || self.peek() != c {
            return Err(format!("expected '{}' at byte {}", c as char, self.i));
        }
        self.i += 1;
        Ok(())
    }

    fn parse_arg(&mut self) -> Result<Value, String> {
        if self.eof() {
            return Err("expected scalar argument, got EOF".into());
        }
        match self.peek() {
            b'"' => Ok(Value::String(self.parse_quoted()?)),
            b'#' => self.parse_keyword(),
            _ => self.parse_number(),
        }
    }

    fn parse_keyword(&mut self) -> Result<Value, String> {
        // At '#'. Read the run of ident bytes.
        let start = self.i;
        self.i += 1; // '#'
        while self.i < self.b.len() {
            match self.b[self.i] {
                b'a'..=b'z' | b'A'..=b'Z' | b'-' => self.i += 1,
                _ => break,
            }
        }
        match &self.b[start..self.i] {
            b"#null" => Ok(Value::Null),
            b"#true" => Ok(Value::Bool(true)),
            b"#false" => Ok(Value::Bool(false)),
            other => Err(format!(
                "unknown keyword {}",
                String::from_utf8_lossy(other)
            )),
        }
    }

    fn parse_number(&mut self) -> Result<Value, String> {
        let start = self.i;
        let mut is_float = false;
        while self.i < self.b.len() {
            match self.b[self.i] {
                b'0'..=b'9' | b'-' | b'+' => self.i += 1,
                b'.' | b'e' | b'E' => {
                    is_float = true;
                    self.i += 1;
                }
                _ => break,
            }
        }
        let tok = std::str::from_utf8(&self.b[start..self.i]).map_err(|e| e.to_string())?;
        if is_float {
            let f: f64 = tok.parse().map_err(|_| format!("bad float {tok:?}"))?;
            serde_json::Number::from_f64(f)
                .map(Value::Number)
                .ok_or_else(|| format!("non-finite float {tok:?}"))
        } else if tok.starts_with('-') {
            let i: i64 = tok.parse().map_err(|_| format!("bad int {tok:?}"))?;
            Ok(Value::Number(i.into()))
        } else {
            let u: u64 = tok.parse().map_err(|_| format!("bad uint {tok:?}"))?;
            Ok(Value::Number(u.into()))
        }
    }

    fn parse_quoted(&mut self) -> Result<String, String> {
        debug_assert_eq!(self.peek(), b'"');
        self.i += 1; // opening quote
        let mut s = String::new();
        let mut run_start = self.i;
        loop {
            if self.eof() {
                return Err("unterminated string".into());
            }
            match self.b[self.i] {
                b'"' => {
                    s.push_str(&String::from_utf8_lossy(&self.b[run_start..self.i]));
                    self.i += 1; // closing quote
                    return Ok(s);
                }
                b'\\' => {
                    // Flush the literal run, then decode the escape.
                    s.push_str(&String::from_utf8_lossy(&self.b[run_start..self.i]));
                    self.i += 1; // backslash
                    if self.eof() {
                        return Err("dangling escape".into());
                    }
                    match self.b[self.i] {
                        b'"' => {
                            s.push('"');
                            self.i += 1;
                        }
                        b'\\' => {
                            s.push('\\');
                            self.i += 1;
                        }
                        b'/' => {
                            s.push('/');
                            self.i += 1;
                        }
                        b'n' => {
                            s.push('\n');
                            self.i += 1;
                        }
                        b't' => {
                            s.push('\t');
                            self.i += 1;
                        }
                        b'r' => {
                            s.push('\r');
                            self.i += 1;
                        }
                        b'b' => {
                            s.push('\u{08}');
                            self.i += 1;
                        }
                        b'f' => {
                            s.push('\u{0C}');
                            self.i += 1;
                        }
                        b'u' => {
                            self.i += 1;
                            if self.eof() || self.peek() != b'{' {
                                return Err("expected { after \\u".into());
                            }
                            self.i += 1; // '{'
                            let hs = self.i;
                            while self.i < self.b.len() && self.b[self.i] != b'}' {
                                self.i += 1;
                            }
                            let hex = std::str::from_utf8(&self.b[hs..self.i])
                                .map_err(|e| e.to_string())?;
                            let cp = u32::from_str_radix(hex, 16)
                                .map_err(|_| format!("bad \\u{{{hex}}}"))?;
                            let ch =
                                char::from_u32(cp).ok_or_else(|| format!("bad codepoint {cp}"))?;
                            s.push(ch);
                            self.expect(b'}')?;
                        }
                        other => return Err(format!("unknown escape \\{}", other as char)),
                    }
                    run_start = self.i;
                }
                _ => self.i += 1,
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    /// The codec's core correctness oracle (per k17/k150): for every value,
    /// `value == parse(emit(value))` under serde structural equality.
    fn assert_round_trips(v: &Value) {
        let text = emit(v);
        let back =
            parse(&text).unwrap_or_else(|e| panic!("parse failed: {e}\n--- text ---\n{text}"));
        assert_eq!(*v, back, "round-trip diverged\n--- text ---\n{text}");
    }

    #[test]
    fn round_trips_every_json_shape() {
        // Object-rooted values (the machine IR's only shape — always a Framework).
        // Every JSON kind appears as an object member or nested inside one:
        // scalars, empty and non-empty arrays/objects, and deep nesting.
        assert_round_trips(&json!({}));
        assert_round_trips(&json!({"a": 1, "b": "two", "c": true, "d": null, "e": false}));
        assert_round_trips(&json!({"nums": [1, -2, 3.5, 0, -0.0, 1e10, 1.5e-3]}));
        assert_round_trips(&json!({"empty_arr": [], "empty_obj": {}}));
        assert_round_trips(&json!({"top_array": [], "top_scalar": 5, "top_obj": {}}));
        assert_round_trips(&json!({
            "nested": {"deep": {"deeper": [ {"x": [1, 2, [3, {"y": "z"}]]} ]}},
            "list_of_objects": [{"k": 1}, {"k": 2}]
        }));
    }

    #[test]
    fn always_quoting_defuses_the_keyword_footgun() {
        // The k17 defect: a *string* whose text is a KDL keyword. Always-quoting
        // strings + `#`-keyword syntax for real keywords keeps them distinct.
        assert_round_trips(&json!({
            "s_null": "null", "s_true": "true", "s_false": "false",
            "b_true": true, "n_null": null,
            "kdl_ish": "inf", "neg_inf": "-inf", "nan": "nan"
        }));
    }

    #[test]
    fn round_trips_string_escapes_and_unicode() {
        assert_round_trips(&json!({
            "quote": "he said \"hi\"",
            "backslash": "a\\b",
            "controls": "tab\there\nnewline\rcr",
            "unicode": "café — 日本語 — 🦀",
            "nul_ish": "\u{0001}\u{001f}",
            "braces": "{not a child}", "parens": "(not a type)", "dash": "-leading"
        }));
    }

    #[test]
    fn emitted_text_is_spec_valid_kdl_2_0() {
        // Cross-check: the official `kdl` crate (KDL 2.0) parses our emitted text
        // AND decodes it back to the identical value — proving the JiK encoding
        // is real, spec-valid KDL, not just self-consistent with our own parser.
        let v = json!({
            "name": "Foundation",
            "count": 3,
            "flag": false,
            "maybe": null,
            "items": [ {"id": 1, "label": "a"}, {"id": 2, "label": "b\"quoted\""} ],
            "empty": [],
            "meta": {"nested": {"weird": "true"}}
        });
        let text = emit(&v);
        let doc = kdl::KdlDocument::parse(&text)
            .unwrap_or_else(|e| panic!("official kdl rejected our text: {e:?}\n{text}"));
        assert_eq!(
            decode_official(&doc),
            v,
            "official-kdl decode diverged from the source value\n{text}"
        );
    }

    #[test]
    fn emitted_text_ends_with_a_newline() {
        assert!(emit(&json!({"a": 1})).ends_with('\n'));
        assert!(emit(&json!({})).is_empty()); // empty doc: no nodes, no newline
    }

    // --- Decode the official `kdl` document model back to a JSON `Value`, using
    // the same `(array)`/`(object)` type discipline JiK emits. Test-only: proves
    // spec-validity against an independent parser.
    fn decode_official(doc: &kdl::KdlDocument) -> Value {
        let mut map = serde_json::Map::new();
        for node in doc.nodes() {
            map.insert(node.name().value().to_string(), decode_official_node(node));
        }
        Value::Object(map)
    }

    fn decode_official_node(node: &kdl::KdlNode) -> Value {
        match node.ty().map(|t| t.value()) {
            Some("array") => Value::Array(
                node.children()
                    .map(|d| d.nodes().iter().map(decode_official_node).collect())
                    .unwrap_or_default(),
            ),
            Some("object") => {
                let mut map = serde_json::Map::new();
                if let Some(d) = node.children() {
                    for child in d.nodes() {
                        map.insert(
                            child.name().value().to_string(),
                            decode_official_node(child),
                        );
                    }
                }
                Value::Object(map)
            }
            _ => {
                let entry = node
                    .entries()
                    .iter()
                    .find(|e| e.name().is_none())
                    .expect("scalar node must have a positional argument");
                match entry.value() {
                    kdl::KdlValue::Null => Value::Null,
                    kdl::KdlValue::Bool(b) => Value::Bool(*b),
                    kdl::KdlValue::String(s) => Value::String(s.clone()),
                    kdl::KdlValue::Integer(i) => {
                        if *i >= 0 {
                            Value::Number((*i as u64).into())
                        } else {
                            Value::Number((*i as i64).into())
                        }
                    }
                    kdl::KdlValue::Float(f) => serde_json::Number::from_f64(*f)
                        .map(Value::Number)
                        .unwrap_or(Value::Null),
                }
            }
        }
    }
}
