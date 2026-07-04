//! machine-format-spike-k150 — re-measure the machine-IR→KDL decision with a
//! *machine-oriented* (non-format-preserving) codec.
//!
//! k17 (ADR-0046 Update) measured only the *format-preserving* `kdl` document-model
//! crate (~80–100× serde_json) and found no fast serde-KDL path existed. This spike
//! measures the path k17 never tested: a hand-written non-preserving JiK codec over
//! `serde_json::Value` — exactly what a production machine-KDL serde back-end would be.
//!
//! Legs, per fixture file (AppKit/Foundation × extracted/resolved):
//!   * serde_json    — parse (text→Value), emit pretty, emit compact  [the baseline]
//!   * jik (ours)    — emit (Value→KDL text), parse (KDL text→Value)   [the candidate]
//!   * docmodel      — k17's kdl-crate encode/emit/parse/decode        [anchor, --docmodel]
//!
//! Correctness oracle (per k17): `value == parse(emit(value))` — serde structural
//! (order-independent) equality on the whole Value tree. A cross-check parses our
//! emitted text with the *official* kdl crate to prove it is spec-valid KDL 2.0.

use std::time::Instant;

use serde_json::Value;

// ===========================================================================
// jik — hand-written, non-format-preserving JSON-in-KDL codec over Value.
//
// The JiK mapping (identical to k17's bijection, so the on-disk shape matches):
//   * top-level object → its members become top-level nodes
//   * scalar           → node with one positional arg (KDL value carries the type)
//   * array            → `(array)`-typed node; elements are `-`-named child nodes
//   * object           → `(object)`-typed node; members are key-named child nodes
// The type annotation disambiguates empty containers from scalars, so decode is
// unambiguous. We *always quote* object keys and string values (the machine-codec
// discipline that sidesteps k17's bare-keyword footgun by construction), and emit
// KDL-2.0 keyword syntax (`#null`/`#true`/`#false`) so the output is spec-valid.
// ===========================================================================
mod jik {
    use serde_json::Value;

    // ---- emit: Value → KDL text ----------------------------------------------

    pub fn emit(v: &Value) -> String {
        // Rough capacity hint: KDL is ~1.2× pretty-JSON (k17 size study).
        let mut out = String::with_capacity(4096);
        match v {
            Value::Object(map) => {
                for (k, val) in map {
                    emit_node(&mut out, Name::Key(k), val, 0);
                }
            }
            other => emit_node(&mut out, Name::Dash, other, 0),
        }
        out
    }

    enum Name<'a> {
        Key(&'a str),
        Dash,
    }

    fn emit_name(out: &mut String, name: &Name) {
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

    fn emit_node(out: &mut String, name: Name, v: &Value, depth: usize) {
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
                    let f = n.as_f64().expect("json number is f64");
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
            _ => unreachable!("container in scalar position"),
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

    // ---- parse: KDL text → Value ---------------------------------------------

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

    impl<'a> Parser<'a> {
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

        // Parse the members of an object (or the whole document) into `map`,
        // stopping at `}` or EOF.
        fn parse_object_body(&mut self, map: &mut serde_json::Map<String, Value>) -> Result<(), String> {
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
                other => Err(format!("unknown type annotation ({})", String::from_utf8_lossy(other))),
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
                other => Err(format!("unknown keyword {}", String::from_utf8_lossy(other))),
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
                                let hex = std::str::from_utf8(&self.b[hs..self.i]).map_err(|e| e.to_string())?;
                                let cp = u32::from_str_radix(hex, 16).map_err(|_| format!("bad \\u{{{hex}}}"))?;
                                let ch = char::from_u32(cp).ok_or_else(|| format!("bad codepoint {cp}"))?;
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
}

// ===========================================================================
// docmodel — k17's format-preserving path over the official `kdl` crate.
// Used only as the reconfirmation anchor (behind --docmodel). Verbatim k17 logic.
// ===========================================================================
mod docmodel {
    use kdl::{KdlDocument, KdlEntry, KdlEntryFormat, KdlNode, KdlValue};
    use serde_json::Value;

    fn is_kdl_keyword(s: &str) -> bool {
        matches!(s, "true" | "false" | "null" | "inf" | "-inf" | "nan")
    }

    fn string_entry(s: &str) -> KdlEntry {
        let mut e = KdlEntry::new(s.to_string());
        if is_kdl_keyword(s) {
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

    pub fn encode(v: &Value) -> KdlDocument {
        let mut doc = KdlDocument::new();
        match v {
            Value::Object(map) => {
                for (k, val) in map {
                    doc.nodes_mut().push(encode_node(k, val));
                }
            }
            other => doc.nodes_mut().push(encode_node("-", other)),
        }
        doc
    }

    fn kdl_value_to_json(v: &KdlValue) -> Value {
        match v {
            KdlValue::Null => Value::Null,
            KdlValue::Bool(b) => Value::Bool(*b),
            KdlValue::String(s) => Value::String(s.clone()),
            KdlValue::Integer(i) => {
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
                let entry = node
                    .entries()
                    .iter()
                    .find(|e| e.name().is_none())
                    .expect("scalar node must have a positional argument");
                kdl_value_to_json(entry.value())
            }
        }
    }

    pub fn decode(doc: &KdlDocument) -> Value {
        let mut map = serde_json::Map::new();
        for node in doc.nodes() {
            map.insert(node.name().value().to_string(), decode_node(node));
        }
        Value::Object(map)
    }
}

// ===========================================================================
// Harness
// ===========================================================================

/// Time `f` `iters` times after a warm-up; return (median_ms, min_ms, last_result).
fn bench<T>(iters: usize, mut f: impl FnMut() -> T) -> (f64, f64, T) {
    let mut last = f(); // warm-up (not timed)
    let mut times = Vec::with_capacity(iters);
    for _ in 0..iters {
        let t = Instant::now();
        last = f();
        times.push(t.elapsed().as_secs_f64() * 1000.0);
    }
    times.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let median = times[times.len() / 2];
    let min = times[0];
    (median, min, last)
}

fn main() {
    let mut args: Vec<String> = std::env::args().skip(1).collect();
    let docmodel = if let Some(p) = args.iter().position(|a| a == "--docmodel") {
        args.remove(p);
        true
    } else {
        false
    };
    let typed = if let Some(p) = args.iter().position(|a| a == "--typed") {
        args.remove(p);
        true
    } else {
        false
    };
    if args.is_empty() {
        eprintln!("usage: kdl-machine-codec [--docmodel] <file.json>...");
        std::process::exit(2);
    }

    // Machine-readable header for later table assembly.
    println!("# file\tbytes\tshape\tleg\tmedian_ms\tmin_ms");

    for path in &args {
        let text = match std::fs::read_to_string(path) {
            Ok(t) => t,
            Err(e) => {
                eprintln!("skip {path}: {e}");
                continue;
            }
        };
        let bytes = text.len();
        let name = std::path::Path::new(path)
            .parent()
            .and_then(|p| p.file_name())
            .map(|s| s.to_string_lossy().to_string())
            .unwrap_or_default();
        let shape = std::path::Path::new(path)
            .file_stem()
            .map(|s| s.to_string_lossy().to_string())
            .unwrap_or_default();
        let label = format!("{name}/{shape}");

        // Fewer iterations for very large files.
        let iters = if bytes > 40_000_000 {
            3
        } else if bytes > 15_000_000 {
            5
        } else {
            7
        };

        eprintln!("\n=== {label} ({bytes} bytes, {iters} iters) ===");

        // Source-of-truth Value (also the json-parse timing).
        let (json_parse_med, json_parse_min, value) =
            bench(iters, || serde_json::from_str::<Value>(&text).expect("json parse"));
        let value: Value = value;

        let (jp_med, jp_min, json_pretty) =
            bench(iters, || serde_json::to_string_pretty(&value).unwrap());
        let (jc_med, jc_min, json_compact) =
            bench(iters, || serde_json::to_string(&value).unwrap());

        // jik (candidate).
        let (jik_emit_med, jik_emit_min, kdl_text) = bench(iters, || jik::emit(&value));
        let kdl_text: String = kdl_text;
        let (jik_parse_med, jik_parse_min, reparsed) =
            bench(iters, || jik::parse(&kdl_text).expect("jik parse"));
        let jik_ok = value == reparsed;

        // Report rows.
        let row = |leg: &str, med: f64, min: f64| {
            println!("{label}\t{bytes}\t{shape}\t{leg}\t{med:.2}\t{min:.2}");
        };
        row("json_parse", json_parse_med, json_parse_min);
        row("json_emit_pretty", jp_med, jp_min);
        row("json_emit_compact", jc_med, jc_min);
        row("jik_emit", jik_emit_med, jik_emit_min);
        row("jik_parse", jik_parse_med, jik_parse_min);

        // Typed legs — bound the Value-bridge overhead vs serde_json's direct
        // typed<->text path. Both extracted and resolved are `Framework`.
        if typed {
            match serde_json::from_str::<apianyware_types::ir::Framework>(&text) {
                Ok(_) => {
                    let (fs_med, fs_min, fw) = bench(iters, || {
                        serde_json::from_str::<apianyware_types::ir::Framework>(&text).expect("Framework from_str")
                    });
                    let fw: apianyware_types::ir::Framework = fw;
                    let (tp_med, tp_min, _) =
                        bench(iters, || serde_json::to_string_pretty(&fw).unwrap());
                    // Value-bridge extra passes. from_value consumes the Value, so a
                    // fresh clone is needed per iter; measure the clone alone and
                    // subtract to get the *net* from_value cost (honesty fix).
                    let (clone_med, clone_min, _) = bench(iters, || value.clone());
                    let (fvc_med, fvc_min, _) = bench(iters, || {
                        serde_json::from_value::<apianyware_types::ir::Framework>(value.clone())
                            .expect("Framework from_value")
                    });
                    let fv_med = (fvc_med - clone_med).max(0.0); // net from_value
                    let fv_min = (fvc_min - clone_min).max(0.0);
                    let (tv_med, tv_min, _) = bench(iters, || serde_json::to_value(&fw).unwrap());
                    row("json_from_str_TYPED", fs_med, fs_min);
                    row("json_to_pretty_TYPED", tp_med, tp_min);
                    row("bridge_clone", clone_med, clone_min);
                    row("bridge_from_value_net", fv_med, fv_min);
                    row("bridge_to_value", tv_med, tv_min);
                    eprintln!(
                        "  TYPED read: json_direct={:.1}ms | kdl_bridge(jik_parse {:.1} + from_value_net {:.1} [clone {:.1}])={:.1}ms  ({:.2}x)",
                        fs_med, jik_parse_med, fv_med, clone_med, jik_parse_med + fv_med,
                        (jik_parse_med + fv_med) / fs_med
                    );
                    eprintln!(
                        "  TYPED write: json_direct={:.1}ms | kdl_bridge(to_value {:.1} + jik_emit {:.1})={:.1}ms  ({:.2}x)",
                        tp_med, tv_med, jik_emit_med, tv_med + jik_emit_med,
                        (tv_med + jik_emit_med) / tp_med
                    );
                }
                Err(e) => eprintln!("  (typed: {shape} did not deserialize as Framework: {e})"),
            }
        }

        eprintln!(
            "  jik round-trip: {}   sizes: json_pretty={} json_compact={} kdl={} ({:.2}x pretty, {:.2}x compact)",
            if jik_ok { "PASS ✅" } else { "FAIL ❌" },
            json_pretty.len(),
            json_compact.len(),
            kdl_text.len(),
            kdl_text.len() as f64 / json_pretty.len() as f64,
            kdl_text.len() as f64 / json_compact.len() as f64,
        );
        // Emit the KDL for on-disk + gzip comparison (only the smaller shapes to save disk).
        if bytes < 40_000_000 {
            let out = format!("/private/tmp/claude-501/-Users-antony-Development-APIAnyware-MacOS--grove-worktrees-structural-refactoring/8b398c10-9f35-4999-8f95-e02c858652e2/scratchpad/out/{name}.{shape}.kdl");
            let _ = std::fs::create_dir_all(std::path::Path::new(&out).parent().unwrap());
            let _ = std::fs::write(&out, &kdl_text);
        }
        if !jik_ok {
            eprintln!("  ❌ FIRST DIFF:");
            report_first_diff(&value, &reparsed, "$");
        }

        // Machine-readable size row.
        println!("{label}\t{bytes}\t{shape}\tsize_json_pretty\t{}\t0", json_pretty.len());
        println!("{label}\t{bytes}\t{shape}\tsize_json_compact\t{}\t0", json_compact.len());
        println!("{label}\t{bytes}\t{shape}\tsize_kdl\t{}\t0", kdl_text.len());

        // docmodel (k17 anchor) — heavy; skip on the 92 MB file to bound memory.
        if docmodel && bytes < 40_000_000 {
            let (dm_build_med, dm_build_min, doc) = bench(iters.min(3), || docmodel::encode(&value));
            let mut doc = doc;
            let (dm_emit_med, dm_emit_min, dm_text) = bench(iters.min(3), || {
                let mut d = docmodel::encode(&value);
                d.autoformat();
                d.to_string()
            });
            let dm_text: String = dm_text;
            let (dm_parse_med, dm_parse_min, parsed_doc) = bench(iters.min(3), || {
                kdl::KdlDocument::parse(&dm_text).expect("kdl parse")
            });
            let (dm_decode_med, dm_decode_min, dm_value) =
                bench(iters.min(3), || docmodel::decode(&parsed_doc));
            let dm_ok = value == dm_value;
            let _ = &mut doc;
            row("dm_build", dm_build_med, dm_build_min);
            row("dm_emit", dm_emit_med, dm_emit_min);
            row("dm_parse", dm_parse_med, dm_parse_min);
            row("dm_decode", dm_decode_med, dm_decode_min);
            eprintln!(
                "  docmodel round-trip: {}   dm_kdl_size={}",
                if dm_ok { "PASS ✅" } else { "FAIL ❌" },
                dm_text.len()
            );

            // Cross-check: does the OFFICIAL kdl crate accept OUR emitted text?
            match kdl::KdlDocument::parse(&kdl_text) {
                Ok(d) => {
                    let cross = docmodel::decode(&d);
                    eprintln!(
                        "  cross-check (official kdl parses our JiK text): {}",
                        if cross == value { "PASS ✅ (spec-valid KDL 2.0)" } else { "DECODE-DIFF ⚠" }
                    );
                }
                Err(e) => eprintln!(
                    "  cross-check: official kdl REJECTED our text ({} diag)",
                    e.diagnostics.len()
                ),
            }
        }
    }
}

/// Walk both values, print the first structural divergence (path + kinds).
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
                        println!("    DIFF at {path}.{k}: missing in round-trip");
                        return;
                    }
                }
            }
            for k in mb.keys() {
                if !ma.contains_key(k) {
                    println!("    DIFF at {path}.{k}: extra key in round-trip");
                    return;
                }
            }
        }
        (Value::Array(aa), Value::Array(ab)) => {
            if aa.len() != ab.len() {
                println!("    DIFF at {path}: array len {} != {}", aa.len(), ab.len());
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
                "    DIFF at {path}: {} != {}",
                &ta[..ta.len().min(120)],
                &tb[..tb.len().min(120)]
            );
        }
    }
}
