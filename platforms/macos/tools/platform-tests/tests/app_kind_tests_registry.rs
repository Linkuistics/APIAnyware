//! The authored `platforms/macos/tests/app-kinds/<kind>.apiw` registry loads,
//! validates, and — the cross-entity invariant — exactly resolves the
//! `test-obligation` refs the corresponding app-kind declares.
//!
//! This is the standing guard that every authored obligation file conforms to
//! `app-kind-tests.kdl-schema`, passes the semantic checks (obligation/expect-id
//! uniqueness, name = file stem), AND that its obligations resolve the kind's refs
//! with no orphan body and no unresolved ref. `test-mechanism-k38` authored the
//! `gui-app` exemplar; child 2 authors the other six kinds, at which point the
//! "every committed file cross-resolves" loop below covers them automatically.

use std::collections::BTreeSet;
use std::path::PathBuf;

use apianyware_app_kinds::AppKindRegistry;
use apianyware_platform_tests::AppKindTestsRegistry;

/// The authored obligation directory, relative to this crate's manifest
/// (`platforms/macos/tools/platform-tests/` up to `platforms/macos/tests/app-kinds/`).
fn obligations_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../tests/app-kinds")
        .canonicalize()
        .expect("platforms/macos/tests/app-kinds/ resolves")
}

/// The authored app-kind directory (`platforms/macos/app-kinds/`), for the
/// cross-resolution check.
fn app_kinds_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../app-kinds")
        .canonicalize()
        .expect("platforms/macos/app-kinds/ resolves")
}

/// The authored tests root (`platforms/macos/tests/`), the base every obligation's
/// `fixture` path is relative to.
fn tests_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../tests")
        .canonicalize()
        .expect("platforms/macos/tests/ resolves")
}

fn obligations() -> AppKindTestsRegistry {
    AppKindTestsRegistry::load_dir(&obligations_dir())
        .expect("every authored app-kind-tests file loads, validates, and passes semantic checks")
}

fn app_kinds() -> AppKindRegistry {
    AppKindRegistry::load_dir(&app_kinds_dir()).expect("the app-kind registry loads")
}

/// The `gui-app` exemplar is authored, loads, and declares exactly its two
/// obligations (`lifecycle`, `bundle-structure`) — each with the expectations the
/// prose source records.
#[test]
fn gui_app_obligations_present() {
    let reg = obligations();
    let gui = reg.get("gui-app").expect("gui-app obligations present");

    assert_eq!(
        gui.obligation_names().collect::<BTreeSet<_>>(),
        BTreeSet::from(["lifecycle", "bundle-structure"]),
    );

    let lifecycle = gui
        .obligations
        .iter()
        .find(|o| o.name == "lifecycle")
        .expect("lifecycle obligation");
    assert!(
        lifecycle
            .expectations
            .iter()
            .any(|e| e.id == "reaches-did-finish-launching"),
        "lifecycle drives applicationDidFinishLaunching:"
    );
    assert!(
        lifecycle
            .expectations
            .iter()
            .any(|e| e.id == "cooperative-shutdown"),
        "lifecycle drives terminate: shutdown"
    );

    let bundle = gui
        .obligations
        .iter()
        .find(|o| o.name == "bundle-structure")
        .expect("bundle-structure obligation");
    assert!(
        bundle
            .expectations
            .iter()
            .any(|e| e.id == "required-plist-keys-present"),
        "bundle-structure checks the required Info.plist keys"
    );
}

/// The cross-entity invariant (ADR-0049 ws9 seam): for **every** authored obligation
/// file, the obligations it declares EXACTLY resolve the `test-obligation` refs the
/// corresponding app-kind declares — no orphan body, no unresolved ref. With only the
/// `gui-app` exemplar authored this covers gui-app; child 2's files are covered the
/// moment they land.
#[test]
fn every_obligation_file_resolves_its_kind_refs() {
    let obligations = obligations();
    let kinds = app_kinds();

    for tests in obligations.all() {
        let kind = kinds.get(&tests.kind).unwrap_or_else(|| {
            panic!(
                "obligation file `{}.apiw` names no such app-kind (its stem must be a real kind)",
                tests.kind
            )
        });

        let declared: BTreeSet<&str> = tests.obligation_names().collect();
        let referenced: BTreeSet<&str> = kind.test_obligations.iter().map(String::as_str).collect();

        assert_eq!(
            declared, referenced,
            "kind `{}`: the obligation bodies in tests/app-kinds/{}.apiw must exactly resolve the \
             kind's `test-obligation` refs (left = declared bodies, right = kind refs)",
            tests.kind, tests.kind,
        );
    }
}

/// The fixture-existence invariant (the `app-kind-tests.kdl-schema` flagged it —
/// "a conforming guard may check existence once fixtures land"): every `fixture` ref
/// any obligation declares resolves to a real file under `platforms/macos/tests/`.
/// Fixtures land in workstream 4 child 4 (`fixtures-readme-k41`); from here on the
/// declaration↔fixture link is a standing invariant — a committed `fixture` path with
/// no backing file fails the guard. The runner that *reads* a fixture's content is
/// workstream 9 (declare-now / execute-later); this only checks the file exists.
#[test]
fn every_fixture_ref_resolves() {
    let reg = obligations();
    let tests_root = tests_dir();

    let mut checked = 0usize;
    for tests in reg.all() {
        for obligation in &tests.obligations {
            for fixture in &obligation.fixtures {
                let path = tests_root.join(fixture);
                assert!(
                    path.is_file(),
                    "kind `{}` obligation `{}` references fixture `{}`, but no file exists at `{}` \
                     (fixture paths are relative to platforms/macos/tests/)",
                    tests.kind,
                    obligation.name,
                    fixture,
                    path.display(),
                );
                checked += 1;
            }
        }
    }

    // The committed corpus references fixtures today (spotlight indexing,
    // quicklook preview, finder-sync sync-badging); guard against a silent
    // regression to zero refs that would make this test vacuously pass.
    assert!(
        checked >= 3,
        "expected the committed obligations to reference at least the three fixture-reading \
         cases, found {checked}",
    );
}

/// Every loaded obligation file names a real kind, declares at least one obligation,
/// and every obligation carries at least one expectation (load_dir would have errored
/// otherwise — this re-asserts the invariant shape across all committed files).
#[test]
fn every_obligation_is_well_formed() {
    let reg = obligations();
    assert!(!reg.is_empty(), "at least the gui-app exemplar is authored");
    for tests in reg.all() {
        assert!(!tests.kind.is_empty(), "a file names its kind");
        assert!(
            !tests.obligations.is_empty(),
            "kind `{}` declares at least one obligation",
            tests.kind
        );
        for obligation in &tests.obligations {
            assert!(
                !obligation.expectations.is_empty(),
                "obligation `{}` (kind `{}`) carries at least one expectation",
                obligation.name,
                tests.kind
            );
        }
    }
}
