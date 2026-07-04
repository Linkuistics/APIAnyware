//! One-shot migration driver: fold the flat `_llm-annotations/*.llm.json`
//! side-channel into the per-family authored overlay `api/<Framework>/annotations.apiw`
//! (ADR-0046, `pipeline-cutover-k20`).
//!
//! The transform itself is the tested library function
//! [`apianyware_spec_format::convert::llm_annotations_to_apiw`]; this example is
//! just the directory walk that places each result under its API family. It is
//! kept in-tree as the reproducible record of the migration — re-runnable against
//! any directory of `*.llm.json` files, not only the now-retired staging dir.
//!
//! Usage:
//!   cargo run -p apianyware-spec-format --example convert-llm-annotations -- \
//!     <src-llm-dir> <api-root>
//!
//! e.g. `… platforms/macos/api/_llm-annotations platforms/macos/api`, which writes
//! `platforms/macos/api/<Framework>/annotations.apiw` for every `<Framework>.llm.json`.

use std::path::PathBuf;
use std::process::ExitCode;

use apianyware_spec_format::{apiw, convert, validate_apiw};
use apianyware_types::annotation::FrameworkAnnotations;

fn main() -> ExitCode {
    let mut args = std::env::args().skip(1);
    let (Some(src_dir), Some(api_root)) = (args.next(), args.next()) else {
        eprintln!("usage: convert-llm-annotations <src-llm-dir> <api-root>");
        return ExitCode::FAILURE;
    };
    let src_dir = PathBuf::from(src_dir);
    let api_root = PathBuf::from(api_root);

    let mut converted = 0usize;
    let entries = match std::fs::read_dir(&src_dir) {
        Ok(e) => e,
        Err(e) => {
            eprintln!("error: cannot read {}: {e}", src_dir.display());
            return ExitCode::FAILURE;
        }
    };

    for entry in entries {
        let path = entry.expect("read dir entry").path();
        // Only `<Framework>.llm.json` files (skip README, dotfiles, the like).
        if path.extension().and_then(|e| e.to_str()) != Some("json") {
            continue;
        }
        let stem = path
            .file_name()
            .and_then(|n| n.to_str())
            .and_then(|n| n.strip_suffix(".llm.json"));
        let Some(stem) = stem else { continue };

        let json = std::fs::read_to_string(&path).expect("read .llm.json");

        // The API family is the overlay's own `framework` field (authoritative —
        // it is what the pipeline keys `extracted.kdl` by); the file name is a
        // convenience that should agree.
        let parsed: FrameworkAnnotations =
            serde_json::from_str(&json).unwrap_or_else(|e| panic!("parse {}: {e}", path.display()));
        let family = parsed.framework.clone();
        assert_eq!(
            family,
            stem,
            "file name stem and `framework` field disagree for {}",
            path.display()
        );

        let apiw_text = convert::llm_annotations_to_apiw(&json)
            .unwrap_or_else(|e| panic!("convert {}: {e}", path.display()));

        // Belt-and-braces: the written overlay must re-parse to the same model
        // and conform to the schema before we commit it.
        let reparsed = apiw::parse_apiw(&format!("{family}/annotations.apiw"), &apiw_text)
            .unwrap_or_else(|e| panic!("reparse {family}: {e:?}"));
        assert_eq!(
            serde_json::to_value(&parsed).unwrap(),
            serde_json::to_value(&reparsed).unwrap(),
            "{family}: converted .apiw did not round-trip the source annotations"
        );
        validate_apiw(&format!("{family}/annotations.apiw"), &apiw_text)
            .unwrap_or_else(|e| panic!("{family}: converted .apiw fails the schema: {e:?}"));

        let dst_dir = api_root.join(&family);
        std::fs::create_dir_all(&dst_dir).expect("create family dir");
        let dst = dst_dir.join("annotations.apiw");
        std::fs::write(&dst, apiw_text).expect("write annotations.apiw");
        converted += 1;
    }

    eprintln!(
        "converted {converted} `_llm-annotations` file(s) into per-family annotations.apiw under {}",
        api_root.display()
    );
    ExitCode::SUCCESS
}
