//! The shared, target-independent **capability vocabulary** (REFACTOR §20/§36;
//! node-brief D2, child `capability-k52`): the controlled set of capability
//! *dimensions* an authored profile rates, partitioned into the two faces, plus the
//! `weirdness → capability` map that bridges platform §30 source-weirdness to the
//! capability a difficulty demands.
//!
//! Two controlled vocabularies live here, both **target-independent** (the same set
//! across racket / chez / gerbil / sbcl — only the authored *rung* a profile assigns
//! differs):
//!
//! - The **capability dimensions** ([`SEMANTIC`] + [`APP_FORM`]) — REFACTOR §20's
//!   "example capabilities" + §36's app-form feasibilities. Like the §30 weirdness
//!   vocabulary in `apianyware-platform-tests`' `api_semantics::vocab`, this is a
//!   controlled vocab the focused validator enforces — **not** a schema `enum` —
//!   because it is *face-conditional*: a `semantic { … }` body may only name
//!   [`SEMANTIC`] dimensions and an `app-form { … }` body only [`APP_FORM`] ones, and
//!   the KDL Schema Language cannot state a vocabulary that depends on the enclosing
//!   node (exactly the reason §30 weirdness is a side table, not a schema enum).
//!
//! - The **`weirdness → capability` map** ([`capability_for`]) — which *semantic*
//!   capability dimension a given §30 source-weirdness tag *demands* (the canonical
//!   example `may-reenter → foreign-thread-callbacks`). Target-independent because the
//!   demand is intrinsic to the difficulty, not to any target. It is the bridge the
//!   [`crate::derive`] representability floor walks: `needs(w)` in
//!   `status(api) = floor over { profile[needs(w)] : w ∈ platform.weirdness(api) }`.
//!
//! The §30 token keys are a deliberate, in-lockstep copy of REFACTOR §30 (the same
//! discipline `apianyware-platform-tests` follows for the *same* tokens) — the
//! target-model crate (targets domain) does **not** depend on the platform-tests crate
//! (platforms domain; the domain rule). A weirdness tag that demands no special
//! capability (the *reassuring* tags — `thread-safe`, `owned`, `static-lifetime`, …)
//! maps to [`None`]: it places no floor on representability. Keep both this map's keys
//! and [`SEMANTIC`]/[`APP_FORM`] in lockstep with REFACTOR.md §20/§30/§36.

/// REFACTOR §20 per-API **semantic** capability dimensions — the face that feeds the
/// representability derivation. A profile's `semantic { … }` body rates each dimension
/// it has an opinion on with a [`crate::derive::Representability`] rung.
pub const SEMANTIC: &[&str] = &[
    "deterministic-cleanup",
    "finalization",
    "ownership",
    "borrowing",
    "lifetime-tracking",
    "callback-support",
    "escaping-callbacks",
    "callback-rooting",
    "foreign-thread-callbacks",
    "thread-affinity",
    "main-thread-dispatch",
    "typestate",
    "async-event-integration",
    "struct-by-value",
    "strings",
    "arrays",
    "buffers",
    "platform-errors",
];

/// REFACTOR §20/§36 **app-form** capability dimensions — the face that feeds
/// per-app-kind feasibility (the child-5 conformance `app-kind support` call), **not**
/// per-API representability. A profile's `app-form { … }` body rates each.
pub const APP_FORM: &[&str] = &[
    "packaging",
    "app-bundle",
    "plugin",
    "sandboxing",
    "native-runtime-embedding",
];

/// REFACTOR §21 **idiom categories** — the controlled set of source-concept slots an
/// authored idiom catalogue (`targets/<t>/idioms/catalogue.apiw`; child `idioms-k53`)
/// answers "*when the platform docs say X, how does that appear in this target?*" for.
///
/// Like the capability dimensions above (and unlike the closed `Representability` /
/// [`EmitConstruct`](crate::idioms::EmitConstruct) ladders, which are code-bound serde
/// enums), this is a domain **vocabulary** the focused validator enforces — kept in
/// lockstep with REFACTOR.md §21, not frozen into the KDL Schema, so a §21 revision is a
/// one-line vocab edit rather than a schema-and-enum change. A catalogue's `idiom "<c>"`
/// entries draw `<c>` from this set; [`is_valid_idiom_category`] is the membership check.
///
/// The categories are a *source-concept* axis — coarser than, and orthogonal to, the
/// ws3 pattern-**kind** axis a catalogue's `projects` children dispatch on (one category
/// may project several kinds — `bracketed-use` covers both `bracket` and `paired-state`).
pub const IDIOM_CATEGORIES: &[&str] = &[
    "owned-resource",
    "borrowed-value",
    "shared-resource",
    "explicit-release",
    "bracketed-use",
    "builder",
    "typestate",
    "nullable-result",
    "error-side-channel",
    "exception-like-failure",
    "callback",
    "escaping-callback",
    "subscription",
    "delegate",
    "async-completion",
    "thread-affinity",
    "main-thread-requirement",
    "buffer-fill",
    "two-call-sizing",
    "array-slice-view",
    "string-encoding",
    "foreign-struct",
    "foreign-enum-flags",
    "global-singleton",
    "unsafe-escape-hatch",
];

/// REFACTOR §26 **adapter roles** — the controlled set of roles an authored adapter
/// spec (`targets/<t>/adapters/<platform>/spec.apiw`; child `policy-adapter-k54`)
/// classifies each native-adapter function by.
///
/// Like the §21 idiom categories and §20 capability dimensions above (and unlike the
/// closed, code-bound [`Representability`](crate::derive::Representability) /
/// [`EmitConstruct`](crate::idioms::EmitConstruct) ladders), this is a domain
/// **vocabulary** the focused validator enforces — REFACTOR §26 calls them "*suggested*
/// roles", an explicitly extensible list that grows with each platform/target pair, so a
/// closed schema `enum` would fight every new adapter. Kept in lockstep with REFACTOR.md
/// §26; [`is_valid_adapter_role`] is the membership check. The spec spells them with
/// underscores (`callback_adapter`); the `.apiw` token convention is kebab-case (the same
/// normalization §30 weirdness / §21 categories apply to their spec spellings).
pub const ADAPTER_ROLES: &[&str] = &[
    "direct-forwarder",
    "semantic-adapter",
    "utility-adapter",
    "lifetime-adapter",
    "callback-adapter",
    "thread-adapter",
    "error-adapter",
    "buffer-adapter",
    "collection-adapter",
    "generic-erasure-adapter",
    "reflection-adapter",
    "test-probe",
];

/// REFACTOR §26 **runtime services** — the controlled set of services an authored adapter
/// spec declares its native library provides (`service "<name>" { status … }`), each rated
/// by a [`ServiceStatus`](crate::adapter_spec::ServiceStatus).
///
/// A §26 "*suggested*" extensible list, enforced as a validator vocabulary in lockstep with
/// REFACTOR.md §26 (the same reasoning as [`ADAPTER_ROLES`]); [`is_valid_runtime_service`]
/// is the membership check. Kebab-cased from the spec's underscore spelling
/// (`object_registry` → `object-registry`).
pub const RUNTIME_SERVICES: &[&str] = &[
    "object-registry",
    "callback-registry",
    "subscription-registry",
    "main-thread-dispatch",
    "autorelease-pool-management",
    "error-registry",
    "test-instrumentation",
];

/// The seven macOS **app-kinds** (REFACTOR §36; `platforms/macos/app-kinds/`) — the
/// controlled set of process-model categories a conformance report's §37 `app-support` call
/// rates (`targets/<t>/conformance/<platform>.apiw`; child `conformance-k55`).
///
/// A deliberate lockstep copy of the platform app-kind registry slugs (the same discipline
/// the §30 weirdness keys and §26 [`ADAPTER_ROLES`]/[`RUNTIME_SERVICES`] follow): the
/// target-model crate (targets domain) does **not** depend on `apianyware-app-kinds`
/// (platforms domain; the domain rule), so the conformance validator checks membership
/// against this copy rather than the platform registry. Unlike the §26 "suggested" lists, the
/// seven app-kinds are a genuinely *closed* platform set — the lockstep copy is chosen over a
/// schema `enum` only to keep the domain dependency out, and the count is asserted in
/// lockstep (`app_kinds_are_the_seven_macos_kinds`). Kept in step with
/// `platforms/macos/app-kinds/`; [`is_valid_app_kind`] is the membership check.
pub const APP_KINDS: &[&str] = &[
    "cli-tool",
    "gui-app",
    "menu-bar-daemon",
    "launch-agent",
    "spotlight-importer",
    "quicklook-extension",
    "finder-sync-extension",
];

/// The two faces of a capability profile (REFACTOR §20 — D2's "two profile faces"):
/// the per-API *semantic* face that feeds representability, and the *app-form* face
/// that feeds per-app-kind feasibility. The face fixes which controlled vocabulary a
/// dimension token is drawn from.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Face {
    /// Per-API semantic capabilities — feed the representability floor.
    Semantic,
    /// App-form / packaging feasibilities — feed per-app-kind support.
    AppForm,
}

impl Face {
    /// The face's `.apiw` / section spelling (`"semantic"` / `"app-form"`).
    pub fn as_str(self) -> &'static str {
        match self {
            Face::Semantic => "semantic",
            Face::AppForm => "app-form",
        }
    }

    /// The controlled dimension vocabulary this face draws on.
    pub fn dimensions(self) -> &'static [&'static str] {
        match self {
            Face::Semantic => SEMANTIC,
            Face::AppForm => APP_FORM,
        }
    }
}

/// Whether `dimension` is a member of `face`'s controlled capability vocabulary — the
/// face-conditional check the focused validator runs (the KDL Schema cannot state it).
pub fn is_valid_dimension(face: Face, dimension: &str) -> bool {
    face.dimensions().contains(&dimension)
}

/// Whether `category` is a member of the REFACTOR §21 [`IDIOM_CATEGORIES`] vocabulary —
/// the membership check the idiom-catalogue validator runs on each `idiom "<category>"`.
pub fn is_valid_idiom_category(category: &str) -> bool {
    IDIOM_CATEGORIES.contains(&category)
}

/// Whether `role` is a member of the REFACTOR §26 [`ADAPTER_ROLES`] vocabulary — the
/// membership check the adapter-spec validator runs on each `role "<role>"`.
pub fn is_valid_adapter_role(role: &str) -> bool {
    ADAPTER_ROLES.contains(&role)
}

/// Whether `service` is a member of the REFACTOR §26 [`RUNTIME_SERVICES`] vocabulary — the
/// membership check the adapter-spec validator runs on each `service "<service>"`.
pub fn is_valid_runtime_service(service: &str) -> bool {
    RUNTIME_SERVICES.contains(&service)
}

/// Whether `app_kind` is a member of the seven macOS [`APP_KINDS`] — the membership check the
/// conformance validator runs on each `app-support "<app-kind>"`.
pub fn is_valid_app_kind(app_kind: &str) -> bool {
    APP_KINDS.contains(&app_kind)
}

/// The **semantic** capability dimension a §30 source-weirdness `tag` demands, or
/// [`None`] when the tag is *reassuring* (places no demand → no floor on
/// representability).
///
/// This is `needs(w)` in the representability floor. The keys are REFACTOR §30 tokens
/// (the four convention facets' weirdness, kept in lockstep with
/// `apianyware-platform-tests`' `api_semantics::vocab`); every non-`None` value is a
/// member of [`SEMANTIC`] (the `every_demand_is_a_semantic_dimension` test guards this
/// invariant).
pub fn capability_for(tag: &str) -> Option<&'static str> {
    let dimension = match tag {
        // ── §30 ownership ─────────────────────────────────────────────────────────
        // The plain owned/borrowed/shared tags name an ownership/borrowing concern the
        // wrapper must model; the *conditional* and *transfer* tags stress the same
        // ownership modelling. The reassuring `interned-static` (a process-lifetime
        // singleton) and the genuinely-unknowable `ownership-unknown` demand nothing.
        "owned"
        | "retained"
        | "shared"
        | "container-owned"
        | "element-owned"
        | "transfer-container-only"
        | "conditional-transfer"
        | "ownership-depends-on-parameter"
        | "ownership-depends-on-return-code" => "ownership",
        "borrowed" => "borrowing",
        "weak" => "lifetime-tracking",
        "autoreleased" => "deterministic-cleanup",
        "borrowed-until-next-call"
        | "borrowed-until-owner-mutated"
        | "borrowed-until-callback-returns"
        | "borrowed-until-runloop-drains" => "lifetime-tracking",
        "caller-allocated" => "buffers",
        "callee-allocated-caller-frees" => "deterministic-cleanup",

        // ── §30 lifetime (folded into the ownership facet) ────────────────────────
        "call-lifetime"
        | "owner-lifetime"
        | "scope-lifetime"
        | "transaction-lifetime"
        | "arena-lifetime"
        | "until-next-api-call"
        | "until-object-invalidation"
        | "unknown-lifetime" => "lifetime-tracking",
        "manual-release-lifetime" | "autorelease-pool-lifetime" => "deterministic-cleanup",
        "callback-lifetime" | "event-subscription-lifetime" => "callback-rooting",
        "thread-lifetime" => "thread-affinity",
        "run-loop-lifetime" => "async-event-integration",
        "until-buffer-mutation" => "buffers",
        // `static-lifetime` is reassuring (process lifetime) → None.

        // ── §30 callback ──────────────────────────────────────────────────────────
        "synchronous-callback"
        | "callback-with-user-data-pointer"
        | "callback-must-not-call-back-into-api"
        | "callback-may-be-reentrant"
        | "callback-called-exactly-once"
        | "callback-called-zero-or-more-times"
        | "callback-owns-data"
        | "callback-borrows-data" => "callback-support",
        "escaping-callback" => "escaping-callbacks",
        "callback-with-destroy-notifier"
        | "callback-may-be-called-after-unregister-returns"
        | "callback-captures-must-be-rooted"
        | "callback-lifetime-tied-to-subscription-token"
        | "callback-lifetime-tied-to-object-lifetime" => "callback-rooting",
        "callback-called-from-foreign-thread" => "foreign-thread-callbacks",

        // ── §30 threading ─────────────────────────────────────────────────────────
        // `may-reenter` → foreign-thread-callbacks is the canonical map example
        // (CONTEXT.md "Representability status"): a reentrant callback re-enters the
        // runtime the same hard way a foreign-thread callback does.
        "may-reenter" | "callback-on-private-thread" | "callback-thread-unspecified" => {
            "foreign-thread-callbacks"
        }
        "thread-compatible"
        | "thread-confined"
        | "owning-thread-only"
        | "callback-on-registering-thread" => "thread-affinity",
        "main-thread-only" | "callback-on-main-thread" => "main-thread-dispatch",
        "requires-run-loop" | "requires-message-pump" => "async-event-integration",
        // `thread-safe`, `not-reentrant`, `may-block`, `must-not-block`,
        // `async-signal-safe`, `fork-safe`, `fork-unsafe` are reassuring or
        // caller-honoured constraints → None.

        // ── §30 error ─────────────────────────────────────────────────────────────
        "errno-meaningful-only-on-failure"
        | "errno-may-be-stale"
        | "return-null-means-failure"
        | "return-null-may-be-legitimate"
        | "negative-return-means-failure"
        | "zero-return-means-success"
        | "hresult"
        | "nserror-out-param"
        | "get-last-error"
        | "exception"
        | "out-error-valid-only-when-failure"
        | "out-value-valid-only-when-success"
        | "partial-initialization-on-failure"
        | "failure-consumes-input"
        | "failure-leaves-input-valid" => "platform-errors",
        "cleanup-required-after-partial-failure" => "deterministic-cleanup",

        _ => return None,
    };
    Some(dimension)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The faces are disjoint — a semantic dimension is not an app-form one, and vice
    /// versa. The face-conditional check is the point.
    #[test]
    fn faces_partition_the_vocabulary() {
        for d in SEMANTIC {
            assert!(is_valid_dimension(Face::Semantic, d));
            assert!(
                !is_valid_dimension(Face::AppForm, d),
                "semantic dimension `{d}` must not be an app-form dimension"
            );
        }
        for d in APP_FORM {
            assert!(is_valid_dimension(Face::AppForm, d));
            assert!(
                !is_valid_dimension(Face::Semantic, d),
                "app-form dimension `{d}` must not be a semantic dimension"
            );
        }
    }

    #[test]
    fn rejects_a_non_vocabulary_dimension() {
        assert!(!is_valid_dimension(
            Face::Semantic,
            "definitely-not-a-20-dimension"
        ));
        assert!(!is_valid_dimension(
            Face::AppForm,
            "definitely-not-a-36-dimension"
        ));
    }

    /// The §21 idiom-category vocabulary is the 25 REFACTOR §21 categories, and a token
    /// outside it is rejected. (Lockstep guard: the count is asserted so a §21 revision
    /// that edits the list without updating REFACTOR — or vice versa — trips here.)
    #[test]
    fn idiom_categories_are_the_25_section_21_slots() {
        assert_eq!(
            IDIOM_CATEGORIES.len(),
            25,
            "REFACTOR §21 lists 25 idiom categories"
        );
        for c in ["bracketed-use", "error-side-channel", "unsafe-escape-hatch"] {
            assert!(is_valid_idiom_category(c), "`{c}` is a §21 category");
        }
        assert!(!is_valid_idiom_category("definitely-not-a-21-category"));
    }

    /// The §26 adapter-role vocabulary is the 12 REFACTOR §26 roles, and a token outside
    /// it is rejected. (Lockstep guard: the count is asserted so a §26 revision that edits
    /// the list without updating REFACTOR — or vice versa — trips here.)
    #[test]
    fn adapter_roles_are_the_12_section_26_roles() {
        assert_eq!(
            ADAPTER_ROLES.len(),
            12,
            "REFACTOR §26 lists 12 adapter roles"
        );
        for r in ["direct-forwarder", "callback-adapter", "test-probe"] {
            assert!(is_valid_adapter_role(r), "`{r}` is a §26 adapter role");
        }
        assert!(!is_valid_adapter_role("teleport-adapter"));
    }

    /// The §26 runtime-service vocabulary is the 7 REFACTOR §26 services, and a token
    /// outside it is rejected.
    #[test]
    fn runtime_services_are_the_7_section_26_services() {
        assert_eq!(
            RUNTIME_SERVICES.len(),
            7,
            "REFACTOR §26 lists 7 runtime services"
        );
        for s in [
            "object-registry",
            "main-thread-dispatch",
            "test-instrumentation",
        ] {
            assert!(
                is_valid_runtime_service(s),
                "`{s}` is a §26 runtime service"
            );
        }
        assert!(!is_valid_runtime_service("teleport-registry"));
    }

    /// The macOS app-kind vocabulary is the seven `platforms/macos/app-kinds/` slugs, and a
    /// token outside it is rejected. (Lockstep guard: the count is asserted so a platform
    /// app-kind registry change that does not update this copy — or vice versa — trips here.)
    #[test]
    fn app_kinds_are_the_seven_macos_kinds() {
        assert_eq!(
            APP_KINDS.len(),
            7,
            "platforms/macos/app-kinds/ has seven kinds"
        );
        for k in ["cli-tool", "gui-app", "spotlight-importer"] {
            assert!(is_valid_app_kind(k), "`{k}` is a macOS app-kind");
        }
        assert!(!is_valid_app_kind("teleport-app"));
    }

    /// The canonical map entry from the design (CONTEXT.md / node-brief D2).
    #[test]
    fn may_reenter_demands_foreign_thread_callbacks() {
        assert_eq!(
            capability_for("may-reenter"),
            Some("foreign-thread-callbacks")
        );
    }

    /// A reassuring tag (one that *reduces* the capability needed) demands nothing — it
    /// never lowers the representability floor.
    #[test]
    fn reassuring_tags_demand_nothing() {
        for tag in [
            "thread-safe",
            "static-lifetime",
            "not-reentrant",
            "fork-safe",
        ] {
            assert_eq!(
                capability_for(tag),
                None,
                "`{tag}` should demand no capability"
            );
        }
    }

    /// A sampling across the four facets demands a sensible dimension.
    #[test]
    fn representative_demands() {
        assert_eq!(
            capability_for("autoreleased"),
            Some("deterministic-cleanup")
        );
        assert_eq!(capability_for("nserror-out-param"), Some("platform-errors"));
        assert_eq!(
            capability_for("escaping-callback"),
            Some("escaping-callbacks")
        );
        assert_eq!(
            capability_for("main-thread-only"),
            Some("main-thread-dispatch")
        );
        assert_eq!(
            capability_for("callback-called-from-foreign-thread"),
            Some("foreign-thread-callbacks")
        );
    }

    /// Lockstep guard: every REFACTOR §30 token (a deliberate copy, mirroring
    /// `apianyware-platform-tests`' own copy) maps either to [`None`] or to a member of
    /// the [`SEMANTIC`] vocabulary — never to a typo'd dimension the profiles cannot
    /// rate. This is what keeps the map's RHS and the dimension vocabulary in sync.
    #[test]
    fn every_demand_is_a_semantic_dimension() {
        // REFACTOR §30, kept in lockstep (ownership + lifetime + callback + threading +
        // error). A copy, not a cross-domain dependency on platforms.
        const SECTION_30: &[&str] = &[
            // ownership
            "owned",
            "borrowed",
            "shared",
            "weak",
            "retained",
            "autoreleased",
            "interned-static",
            "borrowed-until-next-call",
            "borrowed-until-owner-mutated",
            "borrowed-until-callback-returns",
            "borrowed-until-runloop-drains",
            "caller-allocated",
            "callee-allocated-caller-frees",
            "container-owned",
            "element-owned",
            "transfer-container-only",
            "conditional-transfer",
            "ownership-depends-on-parameter",
            "ownership-depends-on-return-code",
            "ownership-unknown",
            // lifetime
            "call-lifetime",
            "owner-lifetime",
            "scope-lifetime",
            "manual-release-lifetime",
            "callback-lifetime",
            "event-subscription-lifetime",
            "thread-lifetime",
            "run-loop-lifetime",
            "autorelease-pool-lifetime",
            "transaction-lifetime",
            "arena-lifetime",
            "static-lifetime",
            "until-next-api-call",
            "until-buffer-mutation",
            "until-object-invalidation",
            "unknown-lifetime",
            // callback
            "synchronous-callback",
            "escaping-callback",
            "callback-with-user-data-pointer",
            "callback-with-destroy-notifier",
            "callback-must-not-call-back-into-api",
            "callback-may-be-reentrant",
            "callback-may-be-called-after-unregister-returns",
            "callback-called-exactly-once",
            "callback-called-zero-or-more-times",
            "callback-called-from-foreign-thread",
            "callback-owns-data",
            "callback-borrows-data",
            "callback-captures-must-be-rooted",
            "callback-lifetime-tied-to-subscription-token",
            "callback-lifetime-tied-to-object-lifetime",
            // threading
            "thread-safe",
            "thread-compatible",
            "thread-confined",
            "main-thread-only",
            "owning-thread-only",
            "callback-thread-unspecified",
            "callback-on-registering-thread",
            "callback-on-main-thread",
            "callback-on-private-thread",
            "requires-run-loop",
            "requires-message-pump",
            "may-reenter",
            "not-reentrant",
            "may-block",
            "must-not-block",
            "async-signal-safe",
            "fork-safe",
            "fork-unsafe",
            // error
            "errno-meaningful-only-on-failure",
            "errno-may-be-stale",
            "return-null-means-failure",
            "return-null-may-be-legitimate",
            "negative-return-means-failure",
            "zero-return-means-success",
            "hresult",
            "nserror-out-param",
            "get-last-error",
            "exception",
            "out-error-valid-only-when-failure",
            "out-value-valid-only-when-success",
            "partial-initialization-on-failure",
            "failure-consumes-input",
            "failure-leaves-input-valid",
            "cleanup-required-after-partial-failure",
        ];
        for tag in SECTION_30 {
            if let Some(dimension) = capability_for(tag) {
                assert!(
                    SEMANTIC.contains(&dimension),
                    "weirdness `{tag}` maps to `{dimension}`, which is not a §20 semantic dimension"
                );
            }
        }
    }
}
