//! The typed adapter-spec model (REFACTOR §24–§26; node-brief D1, child
//! `policy-adapter-k54`): the authored description of one target's *existing* native adapter
//! library.
//!
//! An adapter spec states the [`AdapterOutput`] (the dylib/product), the §26 [`AdapterRole`]s
//! the library provides, the §26 [`RuntimeService`]s it offers (each with a
//! [`ServiceStatus`]), and the §26 [`DirectCallPolicy`] (which API categories may bypass the
//! adapter vs must route through it). It *documents* the library the target grove built — it
//! does not redesign the §25 ABI.
//!
//! The `role` and `service` tokens are the §26 controlled vocabularies
//! ([`crate::vocab::ADAPTER_ROLES`] / [`crate::vocab::RUNTIME_SERVICES`]) — open `.apiw`
//! strings the focused validator checks for membership + uniqueness (REFACTOR §26 calls them
//! "*suggested*" extensible lists, so they are vocab not schema enums). [`ServiceStatus`] is
//! the one closed, code-bound taxonomy here — a serde enum whose `kebab-case` spelling IS its
//! `.apiw` token.

use serde::{Deserialize, Serialize};

/// One authored adapter spec (`targets/<id>/adapters/<platform>/spec.apiw`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AdapterSpec {
    /// The target's stable id — the **target** directory name (`racket`, …); the spec file
    /// lives two levels deeper at `<id>/adapters/<platform>/spec.apiw`, so the registry
    /// checks `adapter-spec "<id>"` against the *great-grandparent* directory.
    pub id: String,
    /// The platform this adapter targets (`macos`, …); the registry checks it matches the
    /// file's parent directory.
    pub platform: String,
    /// Optional one-line human description.
    pub doc: Option<String>,
    /// The library this adapter compiles to (§24 output).
    pub output: AdapterOutput,
    /// The §26 adapter roles the library provides, in authored order.
    pub roles: Vec<AdapterRole>,
    /// The §26 runtime services the library offers, in authored order.
    pub services: Vec<RuntimeService>,
    /// The §26 direct-call policy (which categories bypass the adapter vs route through it).
    /// Optional — a spec may omit it.
    pub direct_call_policy: Option<DirectCallPolicy>,
}

impl AdapterSpec {
    /// Whether the library provides the §26 `role`.
    pub fn has_role(&self, role: &str) -> bool {
        self.roles.iter().any(|r| r.role == role)
    }

    /// The [`RuntimeService`] entry for a §26 `service`, if the library offers it.
    pub fn service(&self, service: &str) -> Option<&RuntimeService> {
        self.services.iter().find(|s| s.service == service)
    }
}

/// The library an adapter compiles to (REFACTOR §24 output).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AdapterOutput {
    /// The product/library name (`APIAnywareRacket`, …).
    pub library: String,
    /// The library kind (`dynamic-library`, …) — an open token (a future target may ship a
    /// static library or embed into an executable).
    pub kind: String,
    /// The exported-symbol prefix the runtime resolves against (`aw_racket_`, …; ADR-0011
    /// hermetic naming). Optional.
    pub symbol_prefix: Option<String>,
}

/// One §26 adapter role the library provides.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AdapterRole {
    /// The §26 role token — a member of [`crate::vocab::ADAPTER_ROLES`] (the focused
    /// validator enforces membership and per-spec uniqueness).
    pub role: String,
    /// What the role covers in this library (typically naming the source files). Optional.
    pub doc: Option<String>,
}

/// One §26 runtime service the library offers, with its status.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RuntimeService {
    /// The §26 service token — a member of [`crate::vocab::RUNTIME_SERVICES`] (validator
    /// enforces membership + per-spec uniqueness).
    pub service: String,
    /// How the service relates to the target's runtime.
    pub status: ServiceStatus,
    /// What the service does in this library. Optional.
    pub doc: Option<String>,
}

/// How a §26 runtime service relates to the target's runtime (node-brief D1). The one
/// closed, code-bound taxonomy in the adapter spec — a schema `enum` in
/// `adapter-spec.kdl-schema`, decoded here; the serde `kebab-case` spelling of a variant IS
/// its `.apiw` token.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum ServiceStatus {
    /// Load-bearing — the target's runtime links and relies on it.
    Required,
    /// Exported for cross-target parity, but this target's runtime does not link it (it
    /// satisfies the need another way — e.g. chez's Scheme-side `lock-object` instead of the
    /// callback-registry exports).
    Parity,
    /// Provided, opt-in — neither load-bearing nor parity-only.
    Optional,
}

/// The §26 direct-call policy — which API categories may bypass the adapter vs must route
/// through it.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct DirectCallPolicy {
    /// Categories safe to call directly (the adapter need not mediate them).
    pub allow: Vec<DirectCallRule>,
    /// Categories that must route through the adapter.
    pub deny: Vec<DirectCallRule>,
}

/// One direct-call rule — an API category with an optional rationale.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DirectCallRule {
    /// The API category — an open token (no fixed vocabulary; the validator only checks a
    /// category is not both allowed and denied).
    pub category: String,
    /// Optional one-line rationale.
    pub doc: Option<String>,
}
