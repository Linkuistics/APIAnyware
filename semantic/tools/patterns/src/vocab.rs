//! The controlled law vocabularies — REFACTOR §30's enumerated "source semantic
//! weirdness" token sets, partitioned by [`LawCategory`].
//!
//! This is the heart of the doubt-pass finding **DP1**: a pattern-kind's laws are
//! non-vacuous precisely because their `token` values are drawn from these fixed
//! sets, not free prose. The KDL Schema Language cannot state a *conditional*
//! enum (a token vocabulary that depends on the sibling `category` value), so
//! `pattern-kinds.kdl-schema` types `token` as a plain string and this module is
//! where the focused validator enforces per-category membership — exactly as ws2's
//! `spec-format` validator interprets a richer subset than the generic schema can.
//!
//! Tokens are the §30 phrases normalized to kebab-case identifiers (so they are
//! valid, legible KDL string values), e.g. §30 "two-call sizing pattern" →
//! `two-call-sizing-pattern`, "NSError\*\*" → `nserror-out-param`. Keep these
//! tables in lockstep with REFACTOR.md §30.

use crate::kind::LawCategory;

/// §30 *ownership* weirdness.
const OWNERSHIP: &[&str] = &[
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
];

/// §30 *lifetime* weirdness.
const LIFETIME: &[&str] = &[
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
];

/// §30 *threading* weirdness.
const THREADING: &[&str] = &[
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
];

/// §30 *error* weirdness.
const ERROR: &[&str] = &[
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

/// §30 *callback* weirdness.
const CALLBACK: &[&str] = &[
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
];

/// §30 *buffer* weirdness.
const BUFFER: &[&str] = &[
    "caller-provides-buffer",
    "callee-fills-buffer",
    "callee-writes-required-size",
    "two-call-sizing-pattern",
    "buffer-may-be-partially-written-on-failure",
    "buffer-length-in-bytes",
    "buffer-length-in-elements",
    "output-not-null-terminated",
    "output-null-terminated-if-space",
    "callee-allocates-buffer",
    "caller-frees-with-specific-function",
    "alignment-requirements",
    "pinned-memory-required",
];

/// §30 *relationship* weirdness.
const RELATIONSHIP: &[&str] = &[
    "parent-owns-child",
    "child-borrows-parent",
    "child-keeps-parent-alive",
    "parent-weakly-references-child",
    "delegate-weakly-held",
    "observer-strongly-retained",
    "subscription-token-controls-lifetime",
    "collection-owns-elements",
    "collection-borrows-elements",
    "element-lifetime-tied-to-collection",
    "view-invalidated-by-mutation",
    "iterator-invalidated-by-mutation",
];

/// The controlled token set for a law category (its §30 vocabulary).
pub fn tokens_for(category: LawCategory) -> &'static [&'static str] {
    match category {
        LawCategory::Ownership => OWNERSHIP,
        LawCategory::Lifetime => LIFETIME,
        LawCategory::Threading => THREADING,
        LawCategory::Error => ERROR,
        LawCategory::Callback => CALLBACK,
        LawCategory::Buffer => BUFFER,
        LawCategory::Relationship => RELATIONSHIP,
    }
}

/// Whether `token` is a member of `category`'s controlled vocabulary.
pub fn is_valid_token(category: LawCategory, token: &str) -> bool {
    tokens_for(category).contains(&token)
}
