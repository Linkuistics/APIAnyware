//! Integration tests: verify Datalog resolution rules against collected Foundation IR.

use std::collections::HashSet;
use std::path::PathBuf;

use apianyware_datalog::loading;
use apianyware_resolve::fact_loader;
use apianyware_resolve::program::ResolutionProgram;
use apianyware_types::Framework;

fn collected_ir_directory() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("..")
        .join("collection")
        .join("ir")
        .join("collected")
}

fn load_foundation() -> Option<Framework> {
    let path = collected_ir_directory().join("Foundation.json");
    if !path.exists() {
        return None;
    }
    Some(loading::load_framework_from_file(&path).unwrap())
}

fn foundation_resolved() -> Option<(ResolutionProgram, Framework)> {
    let fw = load_foundation()?;
    let mut prog = ResolutionProgram::default();
    fact_loader::load_framework_facts(&mut prog, &fw);
    prog.run();
    Some((prog, fw))
}

// ---------------------------------------------------------------------------
// Ancestor tests
// ---------------------------------------------------------------------------

#[test]
fn nsmutablestring_ancestors_include_nsstring_and_nsobject() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };
    let ancestors: HashSet<&str> = prog
        .ancestor
        .iter()
        .filter(|(child, _)| child == "NSMutableString")
        .map(|(_, anc)| anc.as_str())
        .collect();

    assert!(
        ancestors.contains("NSString"),
        "should have NSString as ancestor"
    );
    assert!(
        ancestors.contains("NSObject"),
        "should have NSObject as ancestor"
    );
}

#[test]
fn nsobject_has_no_ancestors() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };
    let ancestors: Vec<_> = prog
        .ancestor
        .iter()
        .filter(|(child, _)| child == "NSObject")
        .collect();

    assert!(
        ancestors.is_empty(),
        "NSObject should have no ancestors, got {ancestors:?}"
    );
}

// ---------------------------------------------------------------------------
// Effective method tests
// ---------------------------------------------------------------------------

#[test]
fn nsmutablestring_inherits_nsstring_methods() {
    let Some((prog, fw)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    // NSString has a "characterAtIndex:" method; NSMutableString should inherit it
    let nsstring_has_method = fw
        .classes
        .iter()
        .find(|c| c.name == "NSString")
        .unwrap()
        .methods
        .iter()
        .any(|m| m.selector == "characterAtIndex:");
    assert!(
        nsstring_has_method,
        "NSString should have characterAtIndex:"
    );

    let has_inherited = prog
        .effective_method
        .iter()
        .any(|(class, sel, is_cm, _, _, _, origin)| {
            class == "NSMutableString"
                && sel == "characterAtIndex:"
                && !is_cm
                && origin == "NSString"
        });
    assert!(
        has_inherited,
        "NSMutableString should inherit characterAtIndex: from NSString"
    );
}

#[test]
fn effective_method_count_for_nsstring() {
    let Some((prog, fw)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let datalog_count = prog
        .effective_method
        .iter()
        .filter(|(class, _, _, _, _, _, _)| class == "NSString")
        .count();

    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    let own_method_count = nsstring.methods.len();

    assert!(
        datalog_count >= own_method_count,
        "NSString effective methods ({datalog_count}) should be >= own methods ({own_method_count})"
    );
}

#[test]
fn own_methods_appear_in_effective_methods() {
    let Some((prog, fw)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let nsstring = fw.classes.iter().find(|c| c.name == "NSString").unwrap();
    let effective_selectors: HashSet<(&str, bool)> = prog
        .effective_method
        .iter()
        .filter(|(class, _, _, _, _, _, _)| class == "NSString")
        .map(|(_, sel, is_cm, _, _, _, _)| (sel.as_str(), *is_cm))
        .collect();

    for method in &nsstring.methods {
        assert!(
            effective_selectors.contains(&(method.selector.as_str(), method.class_method)),
            "NSString own method '{}' (class={}) not in effective methods",
            method.selector,
            method.class_method
        );
    }
}

#[test]
fn overridden_method_uses_child_version() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let nsms_own: HashSet<(&str, bool)> = prog
        .method_decl
        .iter()
        .filter(|(class, _, _, _, _, _)| class == "NSMutableString")
        .map(|(_, sel, is_cm, _, _, _)| (sel.as_str(), *is_cm))
        .collect();

    for (class, sel, is_cm, _, _, _, origin) in &prog.effective_method {
        if class == "NSMutableString" && nsms_own.contains(&(sel.as_str(), *is_cm)) {
            assert_eq!(
                origin, "NSMutableString",
                "NSMutableString's own method '{sel}' should have origin=NSMutableString, got {origin}"
            );
        }
    }
}

// ---------------------------------------------------------------------------
// Effective property tests
// ---------------------------------------------------------------------------

#[test]
fn nsmutablestring_inherits_nsstring_properties() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let nsstring_props: HashSet<&str> = prog
        .property_decl
        .iter()
        .filter(|(class, _, _, _, _)| class == "NSString")
        .map(|(_, name, _, _, _)| name.as_str())
        .collect();

    let nsms_effective_props: HashSet<&str> = prog
        .effective_property
        .iter()
        .filter(|(class, _, _, _, _, _)| class == "NSMutableString")
        .map(|(_, name, _, _, _, _)| name.as_str())
        .collect();

    for prop in &nsstring_props {
        assert!(
            nsms_effective_props.contains(prop),
            "NSMutableString should inherit property '{prop}' from NSString"
        );
    }
}

// ---------------------------------------------------------------------------
// Returns retained tests
// ---------------------------------------------------------------------------

#[test]
fn init_methods_return_retained() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let init_methods: Vec<_> = prog
        .effective_method
        .iter()
        .filter(|(_, _sel, is_cm, is_init, _, _, _)| *is_init && !is_cm)
        .map(|(class, sel, _, _, _, _, _)| (class.as_str(), sel.as_str()))
        .collect();

    assert!(!init_methods.is_empty(), "should have init methods");

    for (class, sel) in &init_methods {
        let is_retained = prog
            .returns_retained_method
            .iter()
            .any(|(c, s, _)| c == *class && s == *sel);
        assert!(
            is_retained,
            "{class}.{sel} is an init method but not in returns_retained"
        );
    }
}

#[test]
fn new_class_methods_return_retained() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let has_new_retained = prog
        .returns_retained_method
        .iter()
        .any(|(_, sel, is_cm)| sel == "new" && *is_cm);
    assert!(
        has_new_retained,
        "class method 'new' should be in returns_retained"
    );
}

#[test]
fn regular_methods_not_retained() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let compare_retained = prog
        .returns_retained_method
        .iter()
        .any(|(_, sel, _)| sel == "compare:");
    assert!(
        !compare_retained,
        "'compare:' should NOT be returns_retained"
    );
}

// ---------------------------------------------------------------------------
// Protocol conformance tests
// ---------------------------------------------------------------------------

#[test]
fn nscoding_methods_matched() {
    let Some((prog, _)) = foundation_resolved() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let nscoding_conformers: HashSet<&str> = prog
        .conforms_to
        .iter()
        .filter(|(_, proto)| proto == "NSCoding")
        .map(|(class, _)| class.as_str())
        .collect();

    if nscoding_conformers.is_empty() {
        return;
    }

    let nscoding_selectors: HashSet<&str> = prog
        .protocol_method
        .iter()
        .filter(|(proto, _, _, _, _, _, _)| proto == "NSCoding")
        .map(|(_, sel, _, _, _, _, _)| sel.as_str())
        .collect();

    if nscoding_selectors.is_empty() {
        return;
    }

    let any_satisfied = prog
        .satisfies_protocol_method
        .iter()
        .any(|(_, _, _, proto)| proto == "NSCoding");
    assert!(
        any_satisfied,
        "at least one NSCoding conformer should satisfy a protocol method"
    );
}

// ---------------------------------------------------------------------------
// Checkpoint building tests
// ---------------------------------------------------------------------------

#[test]
fn resolved_framework_has_ancestors() {
    let Some(fw) = load_foundation() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let resolved = apianyware_resolve::resolve_loaded_frameworks(&[fw]).unwrap();
    let foundation = &resolved[0];

    assert_eq!(foundation.checkpoint, "linked");

    let nsms = foundation
        .classes
        .iter()
        .find(|c| c.name == "NSMutableString")
        .unwrap();
    assert!(
        nsms.ancestors.contains(&"NSString".to_string()),
        "NSMutableString ancestors should include NSString"
    );
    assert!(
        nsms.ancestors.contains(&"NSObject".to_string()),
        "NSMutableString ancestors should include NSObject"
    );
}

#[test]
fn resolved_framework_has_effective_methods() {
    let Some(fw) = load_foundation() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let resolved = apianyware_resolve::resolve_loaded_frameworks(&[fw]).unwrap();
    let foundation = &resolved[0];

    let nsstring = foundation
        .classes
        .iter()
        .find(|c| c.name == "NSString")
        .unwrap();

    // all_methods should be >= own methods (includes inherited)
    assert!(
        nsstring.all_methods.len() >= nsstring.methods.len(),
        "all_methods ({}) should be >= own methods ({})",
        nsstring.all_methods.len(),
        nsstring.methods.len()
    );

    // Every own method selector should appear in all_methods
    for method in &nsstring.methods {
        assert!(
            nsstring
                .all_methods
                .iter()
                .any(|m| m.selector == method.selector && m.class_method == method.class_method),
            "own method '{}' not in all_methods",
            method.selector
        );
    }
}

#[test]
fn resolved_framework_has_returns_retained() {
    let Some(fw) = load_foundation() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let resolved = apianyware_resolve::resolve_loaded_frameworks(&[fw]).unwrap();
    let foundation = &resolved[0];

    let nsstring = foundation
        .classes
        .iter()
        .find(|c| c.name == "NSString")
        .unwrap();

    // init methods should have returns_retained = true
    let init = nsstring
        .all_methods
        .iter()
        .find(|m| m.selector == "init" && !m.class_method);
    assert!(init.is_some(), "should have init in all_methods");
    assert_eq!(
        init.unwrap().returns_retained,
        Some(true),
        "init should be returns_retained"
    );

    // compare: should not be returns_retained
    let compare = nsstring
        .all_methods
        .iter()
        .find(|m| m.selector == "compare:" && !m.class_method);
    if let Some(compare) = compare {
        assert_eq!(
            compare.returns_retained,
            Some(false),
            "compare: should not be returns_retained"
        );
    }
}

#[test]
fn resolved_framework_has_effective_properties() {
    let Some(fw) = load_foundation() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let resolved = apianyware_resolve::resolve_loaded_frameworks(&[fw]).unwrap();
    let foundation = &resolved[0];

    let nsms = foundation
        .classes
        .iter()
        .find(|c| c.name == "NSMutableString")
        .unwrap();

    // NSMutableString should inherit NSString's properties
    let nsstring = foundation
        .classes
        .iter()
        .find(|c| c.name == "NSString")
        .unwrap();

    for prop in &nsstring.properties {
        assert!(
            nsms.all_properties.iter().any(|p| p.name == prop.name),
            "NSMutableString should inherit property '{}'",
            prop.name
        );
    }
}

#[test]
fn resolved_checkpoint_roundtrips_as_json() {
    let Some(fw) = load_foundation() else {
        eprintln!("skipping: no Foundation.json");
        return;
    };

    let resolved = apianyware_resolve::resolve_loaded_frameworks(&[fw]).unwrap();
    let json = serde_json::to_string(&resolved[0]).unwrap();
    let roundtripped: Framework = serde_json::from_str(&json).unwrap();

    assert_eq!(roundtripped.name, "Foundation");
    assert_eq!(roundtripped.checkpoint, "linked");
    assert!(!roundtripped.classes.is_empty());
}
