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
//! Classification is **data-driven** (ws6 `idioms-k53`, node-brief D3): it reads the
//! per-target **idiom catalogue** (`targets/<t>/idioms/catalogue.apiw`, parsed by
//! `apianyware-target-model`) rather than a hardcoded match. The catalogue maps a ws3
//! pattern-**kind** to an [`apianyware_target_model::EmitConstruct`] + a generated
//! identifier; this module maps that authored taxonomy to its [`IdiomaticConstruct`]
//! rendering interface. The per-target `.apiw` supplies the construct + naming; the shared
//! `emit` crate keeps the plumbing. A kind no idiom projects passes through.
//!
//! Relocating the mapping from Rust into authored data is **golden-neutral**:
//! `classify_pattern` has zero callers and every emitter is pattern-blind today, so no
//! generated output moves. *Applying* projection — emitters consuming pattern-instances to
//! emit `with-bracket`/`make-foo` wrappers — is the deferred, golden-INTENTIONAL follow-on.

use apianyware_target_model::{EmitConstruct, IdiomCatalogue};
use apianyware_types::pattern_instance::PatternInstance;

/// Describes what idiomatic construct a pattern should generate.
///
/// Each language emitter maps kinds to its own [`IdiomaticConstruct`] variants.
/// The shared `emit` crate provides the dispatch logic; per-language emitters
/// supply the rendering. This is the rendering interface; the authored taxonomy it
/// renders is [`apianyware_target_model::EmitConstruct`].
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

/// Classify what kind of idiomatic construct a pattern-instance should generate, by reading
/// the target's authored idiom `catalogue`.
///
/// This is the shared dispatch all emitters use. Each emitter then renders the construct in
/// its own syntax. The mapping keys on the instance's authored `kind`: a kind the catalogue
/// projects yields the authored construct + name; an unprojected kind (a structural
/// relationship, or a class-level idiom emitted as part of class generation) falls through
/// to [`PassThrough`].
///
/// [`PassThrough`]: IdiomaticConstruct::PassThrough
pub fn classify_pattern(
    catalogue: &IdiomCatalogue,
    instance: &PatternInstance,
) -> IdiomaticConstruct {
    match catalogue.projection_for(&instance.kind) {
        Some(projection) => render(projection.emit, projection.name.clone()),
        None => IdiomaticConstruct::PassThrough,
    }
}

/// Map an authored [`EmitConstruct`] taxonomy token + its generated identifier to the
/// [`IdiomaticConstruct`] rendering interface. Exhaustive over the closed taxonomy.
fn render(emit: EmitConstruct, name: String) -> IdiomaticConstruct {
    match emit {
        EmitConstruct::ScopedResource => IdiomaticConstruct::ScopedResource { wrapper_name: name },
        EmitConstruct::BuilderDsl => IdiomaticConstruct::BuilderDsl { builder_name: name },
        EmitConstruct::ScopedObserver => IdiomaticConstruct::ScopedObserver { wrapper_name: name },
        EmitConstruct::IterationAdapter => IdiomaticConstruct::IterationAdapter {
            sequence_name: name,
        },
        EmitConstruct::ResultWrapper => IdiomaticConstruct::ResultWrapper {
            result_function_name: name,
        },
        EmitConstruct::SmartConstructor => IdiomaticConstruct::SmartConstructor {
            constructor_name: name,
        },
        EmitConstruct::ScopedGuard => IdiomaticConstruct::ScopedGuard { wrapper_name: name },
    }
}

#[cfg(test)]
mod tests {
    use std::collections::BTreeMap;

    use apianyware_target_model::{Idiom, IdiomCatalogue, Projection};
    use apianyware_types::pattern_instance::{InstanceSource, PatternInstance};

    use super::*;

    /// A tiny in-memory catalogue projecting the emit-relevant kinds, mirroring what the
    /// authored `targets/<t>/idioms/catalogue.apiw` files supply (the integration test
    /// `idiom_catalogues.rs` in `apianyware-target-model` guards the real ones).
    fn catalogue() -> IdiomCatalogue {
        fn idiom(category: &str, projects: Vec<Projection>) -> Idiom {
            Idiom {
                category: category.to_string(),
                construct: "test construct".to_string(),
                doc: None,
                projects,
            }
        }
        fn p(kind: &str, emit: EmitConstruct, name: &str) -> Projection {
            Projection {
                kind: kind.to_string(),
                emit,
                name: name.to_string(),
            }
        }
        IdiomCatalogue {
            id: "test".to_string(),
            doc: None,
            idioms: vec![
                idiom(
                    "bracketed-use",
                    vec![
                        p("bracket", EmitConstruct::ScopedResource, "with-bracket"),
                        p(
                            "paired-state",
                            EmitConstruct::ScopedGuard,
                            "with-paired-state",
                        ),
                    ],
                ),
                idiom(
                    "builder",
                    vec![
                        p("builder", EmitConstruct::BuilderDsl, "builder"),
                        p(
                            "factory-cluster",
                            EmitConstruct::SmartConstructor,
                            "make-factory-cluster",
                        ),
                    ],
                ),
                idiom(
                    "subscription",
                    vec![
                        p("observer", EmitConstruct::ScopedObserver, "with-observer"),
                        p(
                            "subscription",
                            EmitConstruct::ScopedObserver,
                            "with-subscription",
                        ),
                    ],
                ),
                idiom(
                    "array-slice-view",
                    vec![p(
                        "enumeration",
                        EmitConstruct::IterationAdapter,
                        "enumeration-sequence",
                    )],
                ),
                idiom(
                    "error-side-channel",
                    vec![p("error-out", EmitConstruct::ResultWrapper, "error-out")],
                ),
            ],
        }
    }

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
        match classify_pattern(&catalogue(), &instance("bracket")) {
            IdiomaticConstruct::ScopedResource { wrapper_name } => {
                assert_eq!(wrapper_name, "with-bracket");
            }
            other => panic!("Expected ScopedResource, got {other:?}"),
        }
    }

    #[test]
    fn classify_observer_is_scoped_observer() {
        match classify_pattern(&catalogue(), &instance("observer")) {
            IdiomaticConstruct::ScopedObserver { wrapper_name } => {
                assert_eq!(wrapper_name, "with-observer");
            }
            other => panic!("Expected ScopedObserver, got {other:?}"),
        }
    }

    #[test]
    fn classify_factory_cluster_is_smart_constructor() {
        match classify_pattern(&catalogue(), &instance("factory-cluster")) {
            IdiomaticConstruct::SmartConstructor { constructor_name } => {
                assert_eq!(constructor_name, "make-factory-cluster");
            }
            other => panic!("Expected SmartConstructor, got {other:?}"),
        }
    }

    #[test]
    fn classify_paired_state_is_scoped_guard() {
        match classify_pattern(&catalogue(), &instance("paired-state")) {
            IdiomaticConstruct::ScopedGuard { wrapper_name } => {
                assert_eq!(wrapper_name, "with-paired-state");
            }
            other => panic!("Expected ScopedGuard, got {other:?}"),
        }
    }

    #[test]
    fn classify_error_out_is_result_wrapper() {
        match classify_pattern(&catalogue(), &instance("error-out")) {
            IdiomaticConstruct::ResultWrapper {
                result_function_name,
            } => assert_eq!(result_function_name, "error-out"),
            other => panic!("Expected ResultWrapper, got {other:?}"),
        }
    }

    #[test]
    fn classify_enumeration_is_iteration_adapter() {
        match classify_pattern(&catalogue(), &instance("enumeration")) {
            IdiomaticConstruct::IterationAdapter { sequence_name } => {
                assert_eq!(sequence_name, "enumeration-sequence");
            }
            other => panic!("Expected IterationAdapter, got {other:?}"),
        }
    }

    #[test]
    fn classify_builder_is_builder_dsl() {
        match classify_pattern(&catalogue(), &instance("builder")) {
            IdiomaticConstruct::BuilderDsl { builder_name } => {
                assert_eq!(builder_name, "builder");
            }
            other => panic!("Expected BuilderDsl, got {other:?}"),
        }
    }

    #[test]
    fn classify_delegate_is_passthrough() {
        // `delegate` is a class-level idiom the catalogue does not project → pass-through.
        assert_eq!(
            classify_pattern(&catalogue(), &instance("delegate")),
            IdiomaticConstruct::PassThrough
        );
    }

    #[test]
    fn classify_structural_relationship_is_passthrough() {
        assert_eq!(
            classify_pattern(&catalogue(), &instance("parent-child")),
            IdiomaticConstruct::PassThrough
        );
    }
}
