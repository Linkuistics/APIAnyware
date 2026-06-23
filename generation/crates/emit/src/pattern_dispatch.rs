//! API pattern stereotype → idiomatic language construct dispatch.
//!
//! Each API pattern stereotype maps to a language-specific idiomatic construct.
//! This module defines the dispatch interface that per-language emitters implement.
//!
//! For example, a `ResourceLifecycle` pattern maps to:
//! - Scheme/Lisp: `(with-path body ...)` macro
//! - Haskell: `bracket openPath closePath (\path -> ...)`
//! - Zig: `defer path.close();` or errdefer pattern
//! - Smalltalk: `path ensure: [path close]`

use apianyware_types::annotation::{ApiPattern, PatternStereotype};

/// Describes what idiomatic construct a pattern should generate.
///
/// Each language emitter maps stereotypes to its own [`IdiomaticConstruct`] variants.
/// The shared `emit` crate provides the dispatch logic; per-language emitters
/// supply the rendering.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum IdiomaticConstruct {
    /// `(with-resource body ...)` — scoped resource management.
    /// Languages: Scheme `call-with-*`, Haskell `bracket`, Zig `defer`,
    /// Smalltalk `ensure:`, CL `unwind-protect`.
    ScopedResource {
        /// Name for the generated wrapper (e.g., "with-cgpath").
        wrapper_name: String,
    },

    /// Builder DSL — method chaining or `let`-pipeline.
    /// Languages: Racket `let`-chain, Haskell `do`-notation, OCaml pipe.
    BuilderDsl {
        /// Name for the generated builder (e.g., "url-request-builder").
        builder_name: String,
    },

    /// Auto-unregistering observer — scoped observer that cleans up.
    /// Languages: Scheme `call-with-observer`, Haskell `withObserver`,
    /// Zig scoped deinit.
    ScopedObserver {
        /// Name for the generated wrapper.
        wrapper_name: String,
    },

    /// Transaction bracket — `atomically` / `with-transaction`.
    TransactionBracket {
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

    /// No special idiomatic construct — emit as-is.
    PassThrough,
}

/// Classify what kind of idiomatic construct a pattern should generate.
///
/// This is the shared dispatch that all emitters use. Each emitter then
/// renders the construct in its own syntax.
pub fn classify_pattern(pattern: &ApiPattern) -> IdiomaticConstruct {
    match pattern.stereotype {
        PatternStereotype::ResourceLifecycle => IdiomaticConstruct::ScopedResource {
            wrapper_name: format!("with-{}", pattern_name_to_kebab(&pattern.name)),
        },
        PatternStereotype::BuilderSequence => IdiomaticConstruct::BuilderDsl {
            builder_name: format!("{}-builder", pattern_name_to_kebab(&pattern.name)),
        },
        PatternStereotype::ObserverPair => IdiomaticConstruct::ScopedObserver {
            wrapper_name: format!("with-{}", pattern_name_to_kebab(&pattern.name)),
        },
        PatternStereotype::TransactionBracket => IdiomaticConstruct::TransactionBracket {
            wrapper_name: format!("with-{}", pattern_name_to_kebab(&pattern.name)),
        },
        PatternStereotype::Enumeration => IdiomaticConstruct::IterationAdapter {
            sequence_name: format!("{}-sequence", pattern_name_to_kebab(&pattern.name)),
        },
        PatternStereotype::ErrorOut => IdiomaticConstruct::ResultWrapper {
            result_function_name: pattern_name_to_kebab(&pattern.name),
        },
        PatternStereotype::FactoryCluster => IdiomaticConstruct::SmartConstructor {
            constructor_name: format!("make-{}", pattern_name_to_kebab(&pattern.name)),
        },
        PatternStereotype::PairedState => IdiomaticConstruct::ScopedGuard {
            wrapper_name: format!("with-{}", pattern_name_to_kebab(&pattern.name)),
        },
        PatternStereotype::DelegateProtocol | PatternStereotype::TargetAction => {
            // Delegates and target-action are handled by the per-language emitter
            // as part of class generation, not as separate constructs.
            IdiomaticConstruct::PassThrough
        }
    }
}

/// Convert a pattern name to kebab-case for use in generated identifiers.
///
/// "NSLock locking" → "nslock-locking"
/// "CGPath construction" → "cgpath-construction"
fn pattern_name_to_kebab(name: &str) -> String {
    name.to_ascii_lowercase().replace(' ', "-")
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::annotation::AnnotationSource;

    fn make_pattern(stereotype: PatternStereotype, name: &str) -> ApiPattern {
        ApiPattern {
            stereotype,
            name: name.to_string(),
            participants: serde_json::Value::Null,
            constraints: vec![],
            source: AnnotationSource::Heuristic,
            doc_ref: None,
        }
    }

    #[test]
    fn test_classify_resource_lifecycle() {
        let pattern = make_pattern(PatternStereotype::ResourceLifecycle, "CGPath construction");
        match classify_pattern(&pattern) {
            IdiomaticConstruct::ScopedResource { wrapper_name } => {
                assert_eq!(wrapper_name, "with-cgpath-construction");
            }
            other => panic!("Expected ScopedResource, got {other:?}"),
        }
    }

    #[test]
    fn test_classify_observer_pair() {
        let pattern = make_pattern(
            PatternStereotype::ObserverPair,
            "NSNotificationCenter observation",
        );
        match classify_pattern(&pattern) {
            IdiomaticConstruct::ScopedObserver { wrapper_name } => {
                assert_eq!(wrapper_name, "with-nsnotificationcenter-observation");
            }
            other => panic!("Expected ScopedObserver, got {other:?}"),
        }
    }

    #[test]
    fn test_classify_factory_cluster() {
        let pattern = make_pattern(
            PatternStereotype::FactoryCluster,
            "NSNumber NSMutableNumber",
        );
        match classify_pattern(&pattern) {
            IdiomaticConstruct::SmartConstructor { constructor_name } => {
                assert_eq!(constructor_name, "make-nsnumber-nsmutablenumber");
            }
            other => panic!("Expected SmartConstructor, got {other:?}"),
        }
    }

    #[test]
    fn test_classify_paired_state() {
        let pattern = make_pattern(PatternStereotype::PairedState, "NSLock locking");
        match classify_pattern(&pattern) {
            IdiomaticConstruct::ScopedGuard { wrapper_name } => {
                assert_eq!(wrapper_name, "with-nslock-locking");
            }
            other => panic!("Expected ScopedGuard, got {other:?}"),
        }
    }

    #[test]
    fn test_classify_delegate_is_passthrough() {
        let pattern = make_pattern(PatternStereotype::DelegateProtocol, "NSWindowDelegate");
        assert_eq!(classify_pattern(&pattern), IdiomaticConstruct::PassThrough);
    }

    #[test]
    fn test_classify_target_action_is_passthrough() {
        let pattern = make_pattern(PatternStereotype::TargetAction, "NSControl targeting");
        assert_eq!(classify_pattern(&pattern), IdiomaticConstruct::PassThrough);
    }

    #[test]
    fn test_classify_transaction_bracket() {
        let pattern = make_pattern(
            PatternStereotype::TransactionBracket,
            "CATransaction commit",
        );
        match classify_pattern(&pattern) {
            IdiomaticConstruct::TransactionBracket { wrapper_name } => {
                assert_eq!(wrapper_name, "with-catransaction-commit");
            }
            other => panic!("Expected TransactionBracket, got {other:?}"),
        }
    }

    #[test]
    fn test_classify_error_out() {
        let pattern = make_pattern(PatternStereotype::ErrorOut, "file read");
        match classify_pattern(&pattern) {
            IdiomaticConstruct::ResultWrapper {
                result_function_name,
            } => {
                assert_eq!(result_function_name, "file-read");
            }
            other => panic!("Expected ResultWrapper, got {other:?}"),
        }
    }

    #[test]
    fn test_classify_builder_sequence() {
        let pattern = make_pattern(PatternStereotype::BuilderSequence, "URLRequest building");
        match classify_pattern(&pattern) {
            IdiomaticConstruct::BuilderDsl { builder_name } => {
                assert_eq!(builder_name, "urlrequest-building-builder");
            }
            other => panic!("Expected BuilderDsl, got {other:?}"),
        }
    }

    #[test]
    fn test_classify_enumeration() {
        let pattern = make_pattern(PatternStereotype::Enumeration, "NSArray iteration");
        match classify_pattern(&pattern) {
            IdiomaticConstruct::IterationAdapter { sequence_name } => {
                assert_eq!(sequence_name, "nsarray-iteration-sequence");
            }
            other => panic!("Expected IterationAdapter, got {other:?}"),
        }
    }
}
