//! The migration converter folds `_llm-annotations/*.llm.json` into the authored
//! `annotations.apiw` overlay, losslessly. The `_llm-annotations` side-channel was
//! retired by the pipeline cutover (k20); the committed `annotations.apiw` overlays
//! are now the source of truth, so the real-data arm below validates *those*.

use std::path::PathBuf;

use apianyware_spec_format::{apiw, convert, validate_apiw};
use apianyware_types::annotation::FrameworkAnnotations;

/// Repo-root `platforms/macos/api`, located from this crate.
fn api_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../../platforms/macos/api")
}

fn same(a: &FrameworkAnnotations, b: &FrameworkAnnotations) -> bool {
    serde_json::to_value(a).unwrap() == serde_json::to_value(b).unwrap()
}

const WIDGETKIT_JSON: &str = r#"{
  "framework": "WidgetKit",
  "classes": [
    {
      "class_name": "WidgetCenter",
      "methods": [
        {
          "selector": "getCurrentConfigurations(_:)",
          "is_instance": true,
          "block_parameters": [
            {"param_index": 0, "invocation": "async_copied"}
          ],
          "source": "llm"
        }
      ]
    }
  ],
  "subagent_report": {
    "block_synchronous": 0,
    "block_async_copied": 1,
    "block_stored": 0,
    "parameter_ownership": 0,
    "threading_main_thread_only": 0,
    "threading_any_thread": 0,
    "error_pattern": 0
  }
}"#;

#[test]
fn converts_llm_json_to_apiw_losslessly() {
    let original: FrameworkAnnotations = serde_json::from_str(WIDGETKIT_JSON).unwrap();

    let apiw_text = convert::llm_annotations_to_apiw(WIDGETKIT_JSON).expect("convert");
    let reparsed = apiw::parse_apiw("WidgetKit.apiw", &apiw_text).expect("reparse converted .apiw");

    assert!(
        same(&original, &reparsed),
        "converted .apiw must round-trip the source annotations"
    );
}

#[test]
fn every_committed_annotations_apiw_parses_and_validates() {
    let root = api_root();
    if !root.is_dir() {
        // Defensive: if the tree moved, don't fail the unit run — the deterministic
        // test above still pins converter behaviour.
        eprintln!("skip: {} not found", root.display());
        return;
    }

    let mut checked = 0usize;
    for entry in std::fs::read_dir(&root).unwrap() {
        let path = entry.unwrap().path().join("annotations.apiw");
        if !path.is_file() {
            continue;
        }
        let text = std::fs::read_to_string(&path).unwrap();

        // Every committed authored overlay must parse to the typed model and
        // conform to the KDL Schema contract — the post-cutover invariant
        // replacing the `_llm-annotations` round-trip arm (k19/k20).
        let parsed: FrameworkAnnotations = apiw::parse_apiw(&path.to_string_lossy(), &text)
            .unwrap_or_else(|e| panic!("parse {}: {e:?}", path.display()));
        // Re-emitting the parsed overlay and re-parsing must be idempotent.
        let reparsed = apiw::parse_apiw(&path.to_string_lossy(), &apiw::write_apiw(&parsed))
            .unwrap_or_else(|e| panic!("re-emit {}: {e:?}", path.display()));
        assert!(
            same(&parsed, &reparsed),
            "{} is not stable under write_apiw round-trip",
            path.display()
        );
        validate_apiw(&path.to_string_lossy(), &text)
            .unwrap_or_else(|e| panic!("{} fails the .apiw schema: {e:?}", path.display()));
        checked += 1;
    }
    assert!(
        checked > 0,
        "expected at least one committed annotations.apiw"
    );
    eprintln!("parsed + schema-validated {checked} committed annotations.apiw overlays");
}
