//! The typed api-semantics model (node-brief D3/D4): the authored, projection-free
//! **declaration half** of one convention facet's API-semantic tests.
//!
//! An [`ApiSemantics`] names the [`Facet`] it covers and carries its [`Api`]
//! declarations; each declaration names a concrete `(receiver, selector)` macOS API
//! shape, the §30 source-semantic [`weirdness`](Api::weirdness) it exhibits (a
//! controlled vocabulary — facet-conditional, enforced by [`super::apiw`]; see
//! [`super::vocab`]), and its projection-free [`Expectation`]s (what a binding must
//! preserve, as prose the testing architecture executes).
//!
//! This is platform TRUTH only — what the API *means*, including its hard §30
//! properties, never how any target binding satisfies it (`targets/`, workstream 6)
//! and never how it is run (the runner + TestAnyware integration are workstream 9 —
//! the domain rule). It is also **never** a representability status
//! (`fully-`/`lossily-represented` are per target×platform, workstream 6/§20;
//! node-brief D4): the §30 weirdness here is the *input* ws6 consumes to compute a
//! status, not the status itself.

/// The convention facet an api-semantics file covers — the four facet maps the
/// `apianyware-conventions` datalog computes (and `annotate` consumes by `(receiver,
/// selector)`). The file stem is the facet's identity. The kebab-case spelling
/// ([`Facet::as_str`]) IS the `.apiw` token, the single source of truth.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Facet {
    /// Parameter and return ownership / lifetime (↔ `ParamOwnership`). Draws on §30
    /// ownership *and* lifetime weirdness.
    Ownership,
    /// Block / callback invocation semantics (↔ `BlockParamAnnotation`). Draws on §30
    /// callback weirdness.
    Callbacks,
    /// Threading and run-loop constraints. Draws on §30 threading weirdness.
    Threading,
    /// Error-reporting conventions. Draws on §30 error weirdness.
    Errors,
}

impl Facet {
    /// The facet's `.apiw` / file-stem spelling (`"ownership"`, `"callbacks"`,
    /// `"threading"`, `"errors"`).
    pub fn as_str(self) -> &'static str {
        match self {
            Facet::Ownership => "ownership",
            Facet::Callbacks => "callbacks",
            Facet::Threading => "threading",
            Facet::Errors => "errors",
        }
    }

    /// Parse a facet from its `.apiw` / file-stem spelling, or `None` if unknown.
    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "ownership" => Some(Facet::Ownership),
            "callbacks" => Some(Facet::Callbacks),
            "threading" => Some(Facet::Threading),
            "errors" => Some(Facet::Errors),
            _ => None,
        }
    }
}

/// One convention facet's api-semantic declarations
/// (`tests/api-semantics/<facet>.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ApiSemantics {
    /// The covered facet; matches the file stem.
    pub facet: Facet,
    /// Optional one-line human description of the file.
    pub doc: Option<String>,
    /// The per-shape declarations, in declared order. `(receiver, selector)` pairs
    /// are unique within the file.
    pub apis: Vec<Api>,
}

impl ApiSemantics {
    /// The `(receiver, selector)` shapes this file declares, in declared order — the
    /// set the guard asserts is unique and non-empty.
    pub fn shapes(&self) -> impl Iterator<Item = (&str, &str)> {
        self.apis
            .iter()
            .map(|a| (a.receiver.as_str(), a.selector.as_str()))
    }
}

/// One concrete API shape's facet semantics — the §30 weirdness it exhibits plus the
/// expectations a binding must preserve.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Api {
    /// The receiver — a class or protocol name (e.g. `"NSString"`).
    pub receiver: String,
    /// The selector (e.g. `"stringWithString:"`).
    pub selector: String,
    /// Optional one-line description of this shape's facet behaviour.
    pub doc: Option<String>,
    /// The §30 source-semantic weirdness tags this shape exhibits, in declared order
    /// (at least one; each from the file facet's controlled vocabulary; de-duplicated
    /// — both enforced by [`super::apiw`]). This is the platform truth workstream 6
    /// consumes to compute a representability status.
    pub weirdness: Vec<String>,
    /// The projection-free expectations, in declared order (at least one; ids unique
    /// within the shape).
    pub expectations: Vec<Expectation>,
}

/// A single projection-free, target-independent expectation — the unit workstream 9
/// executes against a running target binding.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Expectation {
    /// A stable id, unique within its [`Api`] shape (the handle ws9 resolves against).
    pub id: String,
    /// What must hold, as prose. Carries the assertion's meaning until the testing
    /// architecture gives it an executable form.
    pub doc: Option<String>,
}
