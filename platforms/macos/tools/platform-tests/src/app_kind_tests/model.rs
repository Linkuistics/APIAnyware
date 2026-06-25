//! The typed app-kind test-obligation model (node-brief D3): the authored,
//! projection-free **declaration half** of one app-kind's platform-level tests.
//!
//! An [`AppKindTests`] names the kind it resolves and carries its [`Obligation`]
//! bodies; each obligation is a set of [`Expectation`]s (what must hold, as prose
//! the testing architecture executes) plus the fixtures it reads. There are **no
//! controlled vocabularies** here — unlike an app-kind's flat process-model enums,
//! an obligation body is open prose (obligation names, expectation ids, fixture
//! paths are all free strings), because the unit of meaning is "what a program of
//! this kind must satisfy," resolved to executable assertions only in workstream 9.
//!
//! This is platform TRUTH only — what must hold, never how any target binding
//! satisfies it (`targets/`, workstream 6) and never how it is run (the runner +
//! TestAnyware integration are workstream 9 — the domain rule).

/// The test obligations of one app-kind (`tests/app-kinds/<kind>.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AppKindTests {
    /// The resolved kind's stable identity (matches the file stem, e.g. `"gui-app"`).
    pub kind: String,
    /// Optional one-line human description of the file.
    pub doc: Option<String>,
    /// The obligation bodies, in declared order. Each resolves one
    /// `test-obligation` ref the kind declares; names are unique.
    pub obligations: Vec<Obligation>,
}

impl AppKindTests {
    /// The obligation names this file declares, in declared order — the set the
    /// guard cross-resolves against the kind's `test-obligation` refs.
    pub fn obligation_names(&self) -> impl Iterator<Item = &str> {
        self.obligations.iter().map(|o| o.name.as_str())
    }
}

/// One obligation body — what a program of the kind must satisfy for this
/// obligation, as a set of expectations plus the fixtures they read.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Obligation {
    /// The obligation name; matches a `test-obligation "<name>"` the kind declares.
    pub name: String,
    /// Optional one-line description of what this obligation drives.
    pub doc: Option<String>,
    /// Raw inputs this obligation reads, by path relative to
    /// `platforms/macos/tests/` (e.g. `"fixtures/sample-documents/note.txt"`). Empty
    /// for obligations that read no fixture (lifecycle, bundle-structure); the
    /// fixtures themselves are populated in workstream 4 child 4.
    pub fixtures: Vec<String>,
    /// The projection-free expectations, in declared order (at least one; ids
    /// unique within the obligation).
    pub expectations: Vec<Expectation>,
}

/// A single projection-free, target-independent expectation — the unit workstream 9
/// executes against a running target binding.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Expectation {
    /// A stable id, unique within its obligation (the handle ws9 resolves against).
    pub id: String,
    /// What must hold, as prose. Carries the assertion's meaning until the testing
    /// architecture gives it an executable form.
    pub doc: Option<String>,
}
