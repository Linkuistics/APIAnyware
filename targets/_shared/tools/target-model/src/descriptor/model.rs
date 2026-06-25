//! The typed target-descriptor model (node-brief D4): the §17 per-implementation
//! facets of one target.
//!
//! Six of the seven facets are **open token strings** — the universe of language
//! families / dialects / implementations / FFI backends / projection postures /
//! adapter strategies grows with every target in REFACTOR §19, so a closed enum
//! would fight each new target (the "maximize target idiom, don't force a portable
//! subset" rule). They are validated only for *presence* and *non-blankness*. The one
//! genuinely **bounded, load-bearing** taxonomy — does the target compile its FFI
//! call sites or interpret them — is [`RuntimeModel`], a controlled enum (the
//! distinction ADR-0015 turns on), expressed as an `enum` constraint in
//! `target.kdl-schema` and decoded here.
//!
//! This is the target model's authored knowledge — it states what a target *is*, not
//! how the macOS API behaves (that is `platforms/`) nor a reusable semantic shape
//! (that is `semantic/`). The serde `kebab-case` spelling of a [`RuntimeModel`]
//! variant IS its `.apiw` token, the single source of truth.

use serde::{Deserialize, Serialize};

/// One authored target descriptor (`targets/<id>/target.apiw`).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TargetDescriptor {
    /// The target's stable id — the directory name and the conventional short name
    /// (`racket`, `chez`, `gerbil`, `sbcl`). The registry checks it matches the
    /// containing directory.
    pub id: String,
    /// Optional one-line human description.
    pub doc: Option<String>,
    /// The language family this implementation belongs to (`scheme`, `common-lisp`,
    /// …). The grouping axis a family-level interface contract keys on.
    pub family: String,
    /// The language or dialect, when meaningfully distinct from the implementation
    /// (`racket`, `r6rs`, `ansi-cl`). Optional — some targets' dialect *is* their
    /// implementation name (so it adds nothing and is omitted).
    pub dialect: Option<String>,
    /// The concrete implementation identity (`racket-cs`, `chez-scheme`, `gerbil`,
    /// `sbcl`) — the per-implementation modelling §17 requires.
    pub implementation: String,
    /// The FFI library/mechanism the binding reaches the platform through (`ffi2`,
    /// `foreign-procedure`, `std-foreign`, `sb-alien`).
    pub ffi_backend: String,
    /// The ADR-0015 FFI execution model — the one bounded, controlled facet.
    pub runtime_model: RuntimeModel,
    /// The primary projection posture toward the platform (`thin-direct`: bind the
    /// directly-reachable surface natively, route only the irreducible residual
    /// through the adapter). The per-concern matrix is the child-4
    /// `policies/<platform>/*.apiw`.
    pub projection_policy: String,
    /// The native-adapter strategy (`trampoline-only`, `trampoline-and-bridges`,
    /// `sole-native-unit`, …). The formal adapter roles/services are the child-4
    /// `adapters/<platform>/spec.apiw`.
    pub adapter_strategy: String,
}

/// The ADR-0015 FFI **execution model** — the one bounded, load-bearing target facet.
///
/// Does the target *compile* its FFI call sites (open-coding one typed native call
/// per ABI shape, like `chez`'s `foreign-procedure`, `gerbil`'s `define-c-lambda`,
/// and `sbcl`'s `sb-alien`) or *interpret* them at runtime (like `racket`'s ffi2)?
/// This is the distinction "ADR-0015 turns on" and the only facet with a genuinely
/// closed value set, so it is the descriptor's sole controlled vocabulary.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum RuntimeModel {
    /// FFI call sites are interpreted at runtime (a generated typed-dispatch entry is
    /// reached dynamically) — `racket`.
    InterpretedFfi,
    /// FFI call sites are open-coded to native calls at compile time — `chez`,
    /// `gerbil`, `sbcl`.
    CompiledFfi,
}
