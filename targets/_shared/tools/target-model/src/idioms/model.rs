//! The typed idiom-catalogue model (REFACTOR §21; node-brief D3, child `idioms-k53`):
//! the authored, per-target answer to "*when the platform docs say X, how does that
//! appear in this target?*" — a source-concept → target-construct map, plus the
//! per-pattern-kind **emit projection** the shared `emit/pattern_dispatch` classifier
//! data-drives onto.
//!
//! The catalogue is keyed by a §21 idiom **category** ([`crate::vocab::IDIOM_CATEGORIES`]),
//! a *source-concept* axis. A minority of categories also carry one or more
//! [`Projection`]s, which map a ws3 pattern-**kind** (the `emit` projection axis — a
//! *different*, finer axis: one category can project several kinds, e.g. `bracketed-use`
//! covers both `bracket` and `paired-state`) to the [`EmitConstruct`] the emitter renders
//! and the generated identifier it uses. `classify_pattern` (in the `emit` crate, which
//! consumes this model) builds a kind → [`Projection`] index over the whole catalogue;
//! the per-catalogue uniqueness of a kind across all projections (enforced by the focused
//! validator) is what makes that index unambiguous.
//!
//! The model describes *one implementation's* idioms — per-target richness is the point
//! (each target authors its own; the maximize-idiom rule). The `construct`/`doc` prose is
//! genuinely per-target (grounded in the target's shipped idiom + ADRs); the `emit`
//! variant + `name` of a projection are the (currently scheme-family-shared) dispatch the
//! deferred *apply-projection* follow-on will consume.

use serde::{Deserialize, Serialize};

/// One authored idiom catalogue (`targets/<id>/idioms/catalogue.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct IdiomCatalogue {
    /// The target's stable id — the **target** directory name (`racket`, `chez`, …); the
    /// catalogue file lives one level deeper at `<id>/idioms/catalogue.apiw`, so the
    /// registry checks `idiom-catalogue "<id>"` against the *grandparent* directory.
    pub id: String,
    /// Optional one-line human description.
    pub doc: Option<String>,
    /// The authored idioms, one per §21 category the catalogue covers, in authored order.
    pub idioms: Vec<Idiom>,
}

impl IdiomCatalogue {
    /// The idiom for a §21 `category`, if the catalogue covers it.
    pub fn idiom(&self, category: &str) -> Option<&Idiom> {
        self.idioms.iter().find(|i| i.category == category)
    }

    /// Every authored [`Projection`] across all idioms, in authored order. The kind→emit
    /// dispatch source the `emit` crate's `classify_pattern` indexes.
    pub fn projections(&self) -> impl Iterator<Item = &Projection> {
        self.idioms.iter().flat_map(|i| i.projects.iter())
    }

    /// The [`Projection`] for a ws3 pattern-`kind`, or [`None`] if no idiom projects it
    /// (the `classify_pattern` *pass-through* case). Unambiguous because a kind appears in
    /// at most one projection across the catalogue (the focused validator enforces this).
    pub fn projection_for(&self, kind: &str) -> Option<&Projection> {
        self.projections().find(|p| p.kind == kind)
    }
}

/// One authored idiom — a §21 source-concept category mapped to this target's construct,
/// optionally carrying the pattern-kinds it projects for emit dispatch.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Idiom {
    /// The §21 idiom category — a member of [`crate::vocab::IDIOM_CATEGORIES`] (the
    /// focused validator enforces membership and per-catalogue uniqueness).
    pub category: String,
    /// How the concept appears in this target — the open authored construct description
    /// (e.g. `"with-macro expanding to unwind-protect"`). The human-facing §21 answer.
    pub construct: String,
    /// Optional one-line elaboration (typically citing the grounding ADR / CONTEXT fact).
    pub doc: Option<String>,
    /// The ws3 pattern-kinds this idiom projects, with their emit dispatch. Empty for the
    /// many categories that are documentation-only (no `emit/pattern_dispatch` construct).
    pub projects: Vec<Projection>,
}

/// One pattern-kind → emit-dispatch mapping within an idiom — the data the shared
/// `emit/pattern_dispatch::classify_pattern` reads in place of its former hardcoded match.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Projection {
    /// The ws3 pattern-kind name this projection dispatches (e.g. `"bracket"`). An open
    /// token — the targets-domain crate does not depend on the semantic-domain pattern
    /// registry; an instance whose kind matches no projection passes through.
    pub kind: String,
    /// The idiomatic construct the emitter renders for this kind.
    pub emit: EmitConstruct,
    /// The generated identifier the construct uses (e.g. `"with-bracket"`).
    pub name: String,
}

/// The closed taxonomy of idiomatic constructs the per-language emitters render — the
/// authored vocabulary side of the `emit/pattern_dispatch` seam (REFACTOR §21; node-brief
/// D3). One variant per named `emit` construct.
///
/// This is the authored *taxonomy*; the `emit` crate's `IdiomaticConstruct` is the
/// *rendering* interface (the same variants carrying their generated identifier). Keeping
/// them separate is deliberate: the catalogue (targets-domain data) names the construct,
/// the emitter (rendering) supplies the syntax — and it avoids a crate cycle (`emit`
/// depends on this crate, never the reverse). The serde `kebab-case` spelling of a variant
/// IS its `.apiw` token (the single source of truth, exactly like `Representability`); the
/// taxonomy is a closed `enum` in `idioms.kdl-schema`, decoded here. There is no
/// pass-through variant — a kind with no projection *is* the pass-through case.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum EmitConstruct {
    /// `(with-resource body …)` — scoped resource management (a `bracket` idiom).
    ScopedResource,
    /// Builder DSL — method chaining / `let`-pipeline (a `builder` idiom).
    BuilderDsl,
    /// Auto-unregistering observer — a scoped observer that cleans up (`observer` /
    /// `subscription`).
    ScopedObserver,
    /// Iteration adapter — `for`/`map`/`fold` over a collection (`enumeration`).
    IterationAdapter,
    /// Result wrapper — transforms an error-out-param into a `Result`/condition
    /// (`error-out`).
    ResultWrapper,
    /// Smart constructor — a factory cluster as typed constructors (`factory-cluster`).
    SmartConstructor,
    /// Scoped guard — a `with-lock` / `with-editing` bracket (`paired-state`).
    ScopedGuard,
}
