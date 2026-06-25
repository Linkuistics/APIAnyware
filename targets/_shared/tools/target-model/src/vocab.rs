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
