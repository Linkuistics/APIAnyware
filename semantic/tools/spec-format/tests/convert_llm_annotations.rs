//! The migration converter folds `_llm-annotations/*.llm.json` into the authored
//! `annotations.apiw` overlay, losslessly.

use std::path::PathBuf;

use apianyware_spec_format::{apiw, convert, validate_apiw};
use apianyware_types::annotation::FrameworkAnnotations;

/// Repo-root `platforms/macos/api/_llm-annotations`, located from this crate.
fn llm_annotations_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../../platforms/macos/api/_llm-annotations")
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
fn every_committed_llm_annotation_round_trips_through_apiw() {
    let dir = llm_annotations_dir();
    if !dir.is_dir() {
        // Defensive: if the tree moved, don't fail the unit run — the deterministic
        // test above still pins behaviour. (These files are committed, so this
        // skip should not trigger in practice.)
        eprintln!("skip: {} not found", dir.display());
        return;
    }

    let mut checked = 0usize;
    for entry in std::fs::read_dir(&dir).unwrap() {
        let path = entry.unwrap().path();
        if path.extension().and_then(|e| e.to_str()) != Some("json") {
            continue;
        }
        let json = std::fs::read_to_string(&path).unwrap();
        let original: FrameworkAnnotations =
            serde_json::from_str(&json).unwrap_or_else(|e| panic!("parse {}: {e}", path.display()));

        let apiw_text = convert::llm_annotations_to_apiw(&json)
            .unwrap_or_else(|e| panic!("convert {}: {e}", path.display()));
        let reparsed = apiw::parse_apiw(&path.to_string_lossy(), &apiw_text)
            .unwrap_or_else(|e| panic!("reparse {}: {e:?}", path.display()));

        assert!(
            same(&original, &reparsed),
            "{} did not round-trip through .apiw",
            path.display()
        );

        // Real-data evidence for `kdl-schema-k19`: every committed annotation,
        // once folded into `.apiw`, must conform to the KDL Schema contract.
        validate_apiw(&path.to_string_lossy(), &apiw_text)
            .unwrap_or_else(|e| panic!("{} fails the .apiw schema: {e:?}", path.display()));
        checked += 1;
    }
    assert!(checked > 0, "expected at least one .llm.json fixture");
    eprintln!("round-tripped + schema-validated {checked} committed .llm.json files through .apiw");
}
