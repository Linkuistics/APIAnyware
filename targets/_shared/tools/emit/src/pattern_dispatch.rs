//! Pattern-kind → idiomatic language construct dispatch.
//!
//! Each authored pattern-kind maps to a language-specific idiomatic construct.
//! This module defines the dispatch interface that per-language emitters
//! implement. It is the **projection seam** owned by the target layer (ws6); this
//! crate provides the shared classification, per-language emitters supply the
//! rendering.
//!
//! For example, a `bracket` pattern maps to:
//! - Scheme/Lisp: `(with-path body ...)` macro / `dynamic-wind`
//! - Haskell: `bracket openPath closePath (\path -> ...)`
//! - Zig: `defer path.close();`
//! - Smalltalk: `path ensure: [path close]`
//!
//! Classification keys on the **kind name** (the authored registry identity —
//! ADR-0048), not a closed Rust enum; an instance carries its `kind`, the kind's
//! roles/laws, and a provenance stamp.

use apianyware_types::pattern_instance::PatternInstance;

/// Describes what idiomatic construct a pattern should generate.
///
/// Each language emitter maps kinds to its own [`IdiomaticConstruct`] variants.
/// The shared `emit` crate provides the dispatch logic; per-language emitters
/// supply the rendering.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum IdiomaticConstruct {
    /// `(with-resource body ...)` — scoped resource management.
    /// Languages: Scheme `call-with-*`, Haskell `bracket`, Zig `defer`,
    /// Smalltalk `ensure:`, CL `unwind-protect`.
    ScopedResource {
        /// Name for the generated wrapper (e.g., "with-bracket").
        wrapper_name: String,
    },

    /// Builder DSL — method chaining or `let`-pipeline.
    /// Languages: Racket `let`-chain, Haskell `do`-notation, OCaml pipe.
    BuilderDsl {
        /// Name for the generated builder (e.g., "builder").
        builder_name: String,
    },

    /// Auto-unregistering observer — scoped observer that cleans up.
    /// Languages: Scheme `call-with-observer`, Haskell `withObserver`,
    /// Zig scoped deinit.
    ScopedObserver {
        /// Name for the generated wrapper.
        wrapper_name: String,
    },

    /// Iteration adapter — `for`/`map`/`fold` over a collection.
    IterationAdapter {
        /// Name for the generated sequence/stream.
        sequence_name: String,
    },

    /// Result wrapper — transforms error-out-param into `Result`/`Either`.
    ResultWrapper {
        /// Name for the generated result-returning function.
        result_function_name: String,
    },

    /// Smart constructor — factory cluster as typed constructors.
    SmartConstructor {
        /// Name for the generated constructor.
        constructor_name: String,
    },

    /// Scoped guard — `with-lock` / `with-editing` bracket.
    ScopedGuard {
        /// Name for the generated wrapper.
        wrapper_name: String,
    },

    /// No special idiomatic construct — emit as-is. Structural relationships
    /// (`parent-child`, `callback-destroy-notifier`, …) and class-level idioms
    /// (`delegate`, `target-action`) are handled by the per-language emitter as
    /// part of class generation, not as separate constructs.
    PassThrough,
}

/// Classify what kind of idiomatic construct a pattern-instance should generate.
///
/// This is the shared dispatch that all emitters use. Each emitter then renders
/// the construct in its own syntax. The mapping keys on the instance's authored
/// `kind`; unrecognised or structural kinds fall through to [`PassThrough`].
///
/// [`PassThrough`]: IdiomaticConstruct::PassThrough
pub fn classify_pattern(instance: &PatternInstance) -> IdiomaticConstruct {
    let base = kebab(&instance.kind);
    match instance.kind.as_str() {
        "bracket" => IdiomaticConstruct::ScopedResource {
            wrapper_name: format!("with-{base}"),
        },
        "builder" => IdiomaticConstruct::BuilderDsl {
            builder_name: format!("{base}-builder"),
        },
        "observer" | "subscription" => IdiomaticConstruct::ScopedObserver {
            wrapper_name: format!("with-{base}"),
        },
        "enumeration" => IdiomaticConstruct::IterationAdapter {
            sequence_name: format!("{base}-sequence"),
        },
        "error-out" => IdiomaticConstruct::ResultWrapper {
            result_function_name: base,
        },
        "factory-cluster" => IdiomaticConstruct::SmartConstructor {
            constructor_name: format!("make-{base}"),
        },
        "paired-state" => IdiomaticConstruct::ScopedGuard {
            wrapper_name: format!("with-{base}"),
        },
        // `delegate`/`target-action` are emitted as part of class generation;
        // structural relationships project structurally — both pass through.
        _ => IdiomaticConstruct::PassThrough,
    }
}

/// Convert a kind name to kebab-case for use in generated identifiers.
fn kebab(name: &str) -> String {
    name.to_ascii_lowercase().replace([' ', '_'], "-")
}

#[cfg(test)]
mod tests {
    use std::collections::BTreeMap;

    use apianyware_types::pattern_instance::{InstanceSource, PatternInstance};

    use super::*;

    fn instance(kind: &str) -> PatternInstance {
        let roles = BTreeMap::new();
        PatternInstance {
            id: PatternInstance::compute_id(kind, &roles),
            kind: kind.to_string(),
            home: "TestKit".to_string(),
            roles,
            source: InstanceSource::Convention,
            confidence: None,
            provenance: None,
        }
    }

    #[test]
    fn classify_bracket_is_scoped_resource() {
        match classify_pattern(&instance("bracket")) {
            IdiomaticConstruct::ScopedResource { wrapper_name } => {
                assert_eq!(wrapper_name, "with-bracket");
            }
            other => panic!("Expected ScopedResource, got {other:?}"),
        }
    }

    #[test]
    fn classify_observer_is_scoped_observer() {
        match classify_pattern(&instance("observer")) {
            IdiomaticConstruct::ScopedObserver { wrapper_name } => {
                assert_eq!(wrapper_name, "with-observer");
            }
            other => panic!("Expected ScopedObserver, got {other:?}"),
        }
    }

    #[test]
    fn classify_factory_cluster_is_smart_constructor() {
        match classify_pattern(&instance("factory-cluster")) {
            IdiomaticConstruct::SmartConstructor { constructor_name } => {
                assert_eq!(constructor_name, "make-factory-cluster");
            }
            other => panic!("Expected SmartConstructor, got {other:?}"),
        }
    }

    #[test]
    fn classify_paired_state_is_scoped_guard() {
        match classify_pattern(&instance("paired-state")) {
            IdiomaticConstruct::ScopedGuard { wrapper_name } => {
                assert_eq!(wrapper_name, "with-paired-state");
            }
            other => panic!("Expected ScopedGuard, got {other:?}"),
        }
    }

    #[test]
    fn classify_error_out_is_result_wrapper() {
        match classify_pattern(&instance("error-out")) {
            IdiomaticConstruct::ResultWrapper {
                result_function_name,
            } => assert_eq!(result_function_name, "error-out"),
            other => panic!("Expected ResultWrapper, got {other:?}"),
        }
    }

    #[test]
    fn classify_enumeration_is_iteration_adapter() {
        match classify_pattern(&instance("enumeration")) {
            IdiomaticConstruct::IterationAdapter { sequence_name } => {
                assert_eq!(sequence_name, "enumeration-sequence");
            }
            other => panic!("Expected IterationAdapter, got {other:?}"),
        }
    }

    #[test]
    fn classify_builder_is_builder_dsl() {
        match classify_pattern(&instance("builder")) {
            IdiomaticConstruct::BuilderDsl { builder_name } => {
                assert_eq!(builder_name, "builder-builder");
            }
            other => panic!("Expected BuilderDsl, got {other:?}"),
        }
    }

    #[test]
    fn classify_delegate_is_passthrough() {
        assert_eq!(
            classify_pattern(&instance("delegate")),
            IdiomaticConstruct::PassThrough
        );
    }

    #[test]
    fn classify_structural_relationship_is_passthrough() {
        assert_eq!(
            classify_pattern(&instance("parent-child")),
            IdiomaticConstruct::PassThrough
        );
    }
}
