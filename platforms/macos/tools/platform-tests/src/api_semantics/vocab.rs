//! The controlled `weirdness` vocabularies — REFACTOR §30's enumerated "source
//! semantic weirdness" token sets, partitioned by [`Facet`].
//!
//! A `weirdness` tag is non-vacuous precisely because its value is drawn from a fixed
//! §30 set, not free prose — this is the platform truth workstream 6 consumes to
//! compute a representability status (node-brief D4). The KDL Schema Language cannot
//! state a *conditional* enum (a vocabulary that depends on the file's `api-semantics
//! "<facet>"` value), so `api-semantics.kdl-schema` types `weirdness` as a plain
//! string and this module is where the focused validator enforces per-facet
//! membership — exactly as `apianyware-patterns`' `vocab` enforces its
//! category-conditional law `token` vocabulary, and as ws2's `spec-format` validator
//! interprets a richer subset than the generic schema can.
//!
//! These tables are a deliberate, in-lockstep copy of the §30 phrases (normalized to
//! kebab-case identifiers, e.g. §30 "main-thread-only" → `main-thread-only`,
//! "NSError\*\*" → `nserror-out-param`) — NOT a reuse of `apianyware-patterns`'
//! `vocab`: an api-semantics file's `facet` is a DISTINCT entity from a pattern-kind
//! law's `category` (ADR-0049), the four facets do not line up one-to-one with the
//! seven law categories (the ownership facet unions §30 ownership + lifetime), and the
//! platform-tests crate (platforms domain) does not depend on the patterns crate
//! (semantic domain — the domain rule). Keep both copies in lockstep with REFACTOR.md
//! §30.

use super::model::Facet;

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

/// §30 *lifetime* weirdness — folded into the **ownership** facet (ownership and
/// lifetime are the two halves of a shape's memory semantics).
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

/// §30 *callback* weirdness — the **callbacks** facet.
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

/// §30 *threading* weirdness — the **threading** facet.
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

/// §30 *error* weirdness — the **errors** facet.
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

/// The controlled `weirdness` vocabulary for a facet — the §30 token set(s) it draws
/// on. The ownership facet unions §30 ownership + lifetime; the others map 1:1.
///
/// (§30 *buffer* and *relationship* weirdness map to no convention facet, so they are
/// deliberately out of scope for these four files; a future facet could carry them.)
pub fn tokens_for(facet: Facet) -> &'static [&'static [&'static str]] {
    match facet {
        Facet::Ownership => &[OWNERSHIP, LIFETIME],
        Facet::Callbacks => &[CALLBACK],
        Facet::Threading => &[THREADING],
        Facet::Errors => &[ERROR],
    }
}

/// Whether `tag` is a member of `facet`'s controlled `weirdness` vocabulary.
pub fn is_valid_weirdness(facet: Facet, tag: &str) -> bool {
    tokens_for(facet).iter().any(|set| set.contains(&tag))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ownership_unions_ownership_and_lifetime() {
        assert!(is_valid_weirdness(Facet::Ownership, "autoreleased")); // §30 ownership
        assert!(is_valid_weirdness(
            Facet::Ownership,
            "autorelease-pool-lifetime"
        )); // §30 lifetime
    }

    #[test]
    fn facets_are_disjoint_from_other_facets_tokens() {
        // A threading tag is not valid in the errors facet, and vice versa — the
        // facet-conditional check is the point.
        assert!(is_valid_weirdness(Facet::Threading, "main-thread-only"));
        assert!(!is_valid_weirdness(Facet::Errors, "main-thread-only"));
        assert!(is_valid_weirdness(Facet::Errors, "nserror-out-param"));
        assert!(!is_valid_weirdness(Facet::Threading, "nserror-out-param"));
    }

    #[test]
    fn rejects_a_non_vocabulary_tag() {
        assert!(!is_valid_weirdness(
            Facet::Ownership,
            "definitely-not-a-30-tag"
        ));
    }
}
