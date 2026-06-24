use std::io::Read;
fn walk(d: &kdl::KdlDocument, out: &mut Vec<String>) {
    for n in d.nodes() {
        if n.name().value() == "method" {
            if let Some(e) = n.entries().iter().find(|e| e.name().is_none()) {
                // decode the actual string content (not the KDL source representation)
                match e.value().as_string() {
                    Some(s) => out.push(s.to_string()),
                    None => out.push(format!("<non-string:{}>", e.value())),
                }
            }
        }
        if let Some(c) = n.children() { walk(c, out); }
    }
}
fn main() {
    let mut s = String::new();
    std::io::stdin().read_to_string(&mut s).unwrap();
    match s.parse::<kdl::KdlDocument>() {
        Ok(doc) => {
            let mut sels = vec![];
            walk(&doc, &mut sels);
            println!("OK methods={}", sels.len());
            for x in sels { println!("SEL {x}"); }
        }
        Err(e) => { eprintln!("PARSE_ERROR:\n{e}"); std::process::exit(1); }
    }
}
