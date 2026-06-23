//! Shared vocabulary for [`crate::ir::SkippedSymbol::reason`] strings.
//!
//! Both `extract-objc` and `extract-swift` record filter decisions into a
//! framework's `skipped_symbols` list. This module pins the reason strings
//! they use so that downstream audit tooling has a single place to match on.
//!
//! Each reason is formatted as `"<tag>: <human description>"`. The leading
//! tag (`internal_linkage`, `platform_unavailable_macos`, `swift_native`,
//! `preprocessor_macro`, `anonymous_enum_member`) is a stable machine-readable
//! identifier that callers can grep, switch on, or match via `contains(tag)`.
//! The human description explains why the symbol was dropped and what the
//! symptom would be downstream if the filter were ever relaxed.

/// Applied by `extract-objc` to `static const` / `static inline` declarations
/// whose `clang::Linkage::Internal` means the C compiler inlines them at use
/// sites and emits no dylib symbol.
pub const INTERNAL_LINKAGE: &str =
    "internal_linkage: static const / static inline declaration; inlined at use site, \
     no dylib export";

/// Applied by `extract-objc` to any declaration explicitly marked unavailable
/// on macOS via a clang availability attribute (`API_UNAVAILABLE(macos)`).
/// Covers constants, functions, classes, protocols, methods, and properties.
pub const PLATFORM_UNAVAILABLE_MACOS: &str =
    "platform_unavailable_macos: API_UNAVAILABLE(macos); no dylib export or \
     objc runtime implementation in the macOS framework variant";

/// **Retired from the drop path (ADR-0026).** Formerly applied by
/// `extract-swift` to top-level declarations whose USR starts with `s:`. Such
/// Swift-native declarations are now *retained* carrying `objc_exposed: false`
/// (trampoline residual) rather than dropped, so this reason is no longer
/// emitted. Kept defined for one release for changelog/audit clarity.
pub const SWIFT_NATIVE: &str =
    "swift_native: swift-native top-level declaration (not c-linkable; only \
     reachable via Swift ABI)";

/// Applied by `extract-swift` to top-level declarations whose USR starts with
/// `c:@macro@` — preprocessor macro cursors. The C compiler inlines `#define`
/// values at use sites and emits no dylib symbol.
pub const PREPROCESSOR_MACRO: &str =
    "preprocessor_macro: preprocessor macro cursor (c:@macro@ USR; not a \
     dylib export)";

/// Applied by `extract-swift` to top-level declarations whose USR starts with
/// `c:@Ea@` or `c:@EA@` — members of an anonymous C enum. Integer values are
/// inlined by the C compiler and never receive a dylib symbol.
pub const ANONYMOUS_ENUM_MEMBER: &str =
    "anonymous_enum_member: anonymous enum member (c:@Ea@ / c:@EA@ USR; \
     integer value inlined by the C compiler, no dylib export)";

/// Applied by `extract-swift` to ABI nodes of kind `Macro` / `TypeAlias` /
/// `AssociatedType` that are not yet walked. Recovery is deferred to a later
/// frontier leaf (ADR-0025/ADR-0026, D2); recording them here makes the drop
/// auditable instead of silent rather than the former silent `_ => {}` drop.
pub const DEFERRED_ABI_KIND: &str =
    "deferred_abi_kind: Macro/TypeAlias/AssociatedType ABI node not yet walked \
     (recovery deferred to a later frontier leaf)";
