//! Load annotated IR frameworks into the enrichment Datalog program.
//!
//! Iterates over a [`Framework`]'s declarations and annotations, pushing
//! tuples into the [`EnrichmentProgram`]'s base relations. This loads both
//! type-level facts (classes, methods, protocols) and annotation facts
//! (block classifications, threading, error patterns, ownership).

use apianyware_macos_types::annotation::{
    BlockInvocationStyle, ErrorPattern, OwnershipKind, ThreadingConstraint,
};
use apianyware_macos_types::ir::Method;
use apianyware_macos_types::type_ref::TypeRefKind;
use apianyware_macos_types::Framework;

use crate::program::EnrichmentProgram;

/// Populate all base relations from an annotated framework.
///
/// Loads type-level facts (classes, methods, properties, protocols, inheritance)
/// and annotation facts (block classifications, threading, error, ownership)
/// from the framework's `class_annotations`.
pub fn load_framework_facts(prog: &mut EnrichmentProgram, framework: &Framework) {
    let framework_name = &framework.name;

    load_type_facts(prog, framework, framework_name);
    load_annotation_facts(prog, framework);
}

/// Load type-level facts from the framework IR into base relations.
fn load_type_facts(prog: &mut EnrichmentProgram, framework: &Framework, framework_name: &str) {
    for class in &framework.classes {
        prog.class_decl.push((
            class.name.clone(),
            class.superclass.clone(),
            framework_name.to_string(),
        ));

        if !class.superclass.is_empty() {
            prog.inherits_from
                .push((class.name.clone(), class.superclass.clone()));
        }

        for protocol in &class.protocols {
            prog.conforms_to
                .push((class.name.clone(), protocol.clone()));
        }

        // Load methods — prefer all_methods (inheritance-flattened) if available
        let methods = if class.all_methods.is_empty() {
            &class.methods
        } else {
            &class.all_methods
        };

        for method in methods {
            load_method_type_facts(prog, &class.name, method);
        }

        // Also load category methods
        for category_group in &class.category_methods {
            for method in &category_group.methods {
                load_method_type_facts(prog, &class.name, method);
            }
        }

        for prop in &class.properties {
            prog.property_decl.push((
                class.name.clone(),
                prop.name.clone(),
                prop.readonly,
                prop.class_property,
            ));
        }
    }

    for proto in &framework.protocols {
        prog.protocol_decl.push((proto.name.clone(),));

        for method in &proto.required_methods {
            prog.protocol_method.push((
                proto.name.clone(),
                method.selector.clone(),
                true,
                method.class_method,
            ));
        }

        for method in &proto.optional_methods {
            prog.protocol_method.push((
                proto.name.clone(),
                method.selector.clone(),
                false,
                method.class_method,
            ));
        }
    }
}

/// Load type facts for a single method: method_decl, has_block_param,
/// method_returns_object, and returns_retained_from_resolve.
fn load_method_type_facts(prog: &mut EnrichmentProgram, class_name: &str, method: &Method) {
    prog.method_decl.push((
        class_name.to_string(),
        method.selector.clone(),
        method.class_method,
        method.init_method,
    ));

    // Detect block-typed parameters from TypeRef
    for (i, param) in method.params.iter().enumerate() {
        if matches!(param.param_type.kind, TypeRefKind::Block { .. }) {
            prog.has_block_param
                .push((class_name.to_string(), method.selector.clone(), i as u32));
        }
    }

    // Detect object-returning methods from return type
    if method_returns_object_type(&method.return_type.kind) {
        prog.method_returns_object.push((
            class_name.to_string(),
            method.selector.clone(),
            method.class_method,
        ));
    }

    // Carry forward returns_retained from resolve step
    if let Some(retained) = method.returns_retained {
        prog.resolve_processed_method.push((
            class_name.to_string(),
            method.selector.clone(),
            method.class_method,
        ));
        if retained {
            prog.returns_retained_from_resolve.push((
                class_name.to_string(),
                method.selector.clone(),
                method.class_method,
            ));
        }
    }
}

/// Check if a return type is an ObjC object type (id, instancetype, class reference).
fn method_returns_object_type(kind: &TypeRefKind) -> bool {
    matches!(
        kind,
        TypeRefKind::Id | TypeRefKind::Instancetype | TypeRefKind::Class { .. }
    )
}

/// Load annotation facts from the framework's `class_annotations` into
/// the enrichment program's annotation base relations.
fn load_annotation_facts(prog: &mut EnrichmentProgram, framework: &Framework) {
    for class_ann in &framework.class_annotations {
        for method_ann in &class_ann.methods {
            // Only load LLM or human-reviewed annotations, plus heuristics
            // (all sources are valid for enrichment)

            // Block invocation style
            for block in &method_ann.block_parameters {
                match block.invocation {
                    BlockInvocationStyle::Synchronous => {
                        prog.block_is_synchronous.push((
                            class_ann.class_name.clone(),
                            method_ann.selector.clone(),
                            block.param_index as u32,
                        ));
                    }
                    BlockInvocationStyle::AsyncCopied => {
                        prog.block_is_async_copied.push((
                            class_ann.class_name.clone(),
                            method_ann.selector.clone(),
                            block.param_index as u32,
                        ));
                    }
                    BlockInvocationStyle::Stored => {
                        prog.block_is_stored.push((
                            class_ann.class_name.clone(),
                            method_ann.selector.clone(),
                            block.param_index as u32,
                        ));
                    }
                }
            }

            // Threading constraints
            if let Some(ThreadingConstraint::MainThreadOnly) = method_ann.threading {
                prog.main_thread_only
                    .push((class_ann.class_name.clone(), method_ann.selector.clone()));
            }

            // Error pattern
            if let Some(ErrorPattern::ErrorOutParam) = method_ann.error_pattern {
                prog.method_has_error_outparam
                    .push((class_ann.class_name.clone(), method_ann.selector.clone()));
            }

            // Weak parameter ownership
            for param in &method_ann.parameter_ownership {
                if param.ownership == OwnershipKind::Weak {
                    prog.weak_param.push((
                        class_ann.class_name.clone(),
                        method_ann.selector.clone(),
                        param.param_index as u32,
                    ));
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::annotation::{
        AnnotationSource, BlockParamAnnotation, ClassAnnotations, MethodAnnotation, ParamOwnership,
    };
    use apianyware_macos_types::ir::{Class, Param};
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn make_method(selector: &str, params: Vec<Param>, return_kind: TypeRefKind) -> Method {
        Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params,
            return_type: TypeRef {
                nullable: false,
                kind: return_kind,
            },
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
        }
    }

    fn make_framework_with_class(
        class_name: &str,
        methods: Vec<Method>,
        annotations: Vec<ClassAnnotations>,
    ) -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "annotated".to_string(),
            name: "TestKit".to_string(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![Class {
                name: class_name.to_string(),
                superclass: String::new(),
                protocols: vec![],
                properties: vec![],
                methods,
                category_methods: vec![],
                swift_attributes: vec![],
                ancestors: vec![],
                all_methods: vec![],
                all_properties: vec![],
            }],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: annotations,
            api_patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    #[test]
    fn loads_block_param_from_type_ref() {
        let block_type = TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(TypeRef::void()),
            },
        };
        let method = make_method(
            "doWork:",
            vec![Param {
                name: "handler".to_string(),
                param_type: block_type,
            }],
            TypeRefKind::Primitive {
                name: "void".to_string(),
            },
        );

        let fw = make_framework_with_class("MyClass", vec![method], vec![]);
        let mut prog = EnrichmentProgram::default();
        load_framework_facts(&mut prog, &fw);

        assert_eq!(prog.has_block_param.len(), 1);
        assert_eq!(prog.has_block_param[0].0, "MyClass");
        assert_eq!(prog.has_block_param[0].1, "doWork:");
        assert_eq!(prog.has_block_param[0].2, 0);
    }

    #[test]
    fn loads_object_returning_method() {
        let method = make_method("copy", vec![], TypeRefKind::Id);
        let fw = make_framework_with_class("NSString", vec![method], vec![]);
        let mut prog = EnrichmentProgram::default();
        load_framework_facts(&mut prog, &fw);

        assert_eq!(prog.method_returns_object.len(), 1);
        assert_eq!(prog.method_returns_object[0].0, "NSString");
    }

    #[test]
    fn loads_annotation_block_classifications() {
        let fw = make_framework_with_class(
            "NSArray",
            vec![],
            vec![ClassAnnotations {
                class_name: "NSArray".to_string(),
                methods: vec![
                    MethodAnnotation {
                        selector: "enumerateObjectsUsingBlock:".to_string(),
                        is_instance: true,
                        parameter_ownership: vec![],
                        block_parameters: vec![BlockParamAnnotation {
                            param_index: 0,
                            invocation: BlockInvocationStyle::Synchronous,
                        }],
                        threading: None,
                        error_pattern: None,
                        source: AnnotationSource::Heuristic,
                    },
                    MethodAnnotation {
                        selector: "performBlock:".to_string(),
                        is_instance: true,
                        parameter_ownership: vec![],
                        block_parameters: vec![BlockParamAnnotation {
                            param_index: 0,
                            invocation: BlockInvocationStyle::AsyncCopied,
                        }],
                        threading: None,
                        error_pattern: None,
                        source: AnnotationSource::Heuristic,
                    },
                ],
            }],
        );
        let mut prog = EnrichmentProgram::default();
        load_framework_facts(&mut prog, &fw);

        assert_eq!(prog.block_is_synchronous.len(), 1);
        assert_eq!(prog.block_is_async_copied.len(), 1);
    }

    #[test]
    fn loads_threading_and_error_annotations() {
        let fw = make_framework_with_class(
            "NSView",
            vec![],
            vec![ClassAnnotations {
                class_name: "NSView".to_string(),
                methods: vec![
                    MethodAnnotation {
                        selector: "setNeedsDisplay:".to_string(),
                        is_instance: true,
                        parameter_ownership: vec![],
                        block_parameters: vec![],
                        threading: Some(ThreadingConstraint::MainThreadOnly),
                        error_pattern: None,
                        source: AnnotationSource::Heuristic,
                    },
                    MethodAnnotation {
                        selector: "saveToURL:error:".to_string(),
                        is_instance: true,
                        parameter_ownership: vec![],
                        block_parameters: vec![],
                        threading: None,
                        error_pattern: Some(ErrorPattern::ErrorOutParam),
                        source: AnnotationSource::Heuristic,
                    },
                ],
            }],
        );
        let mut prog = EnrichmentProgram::default();
        load_framework_facts(&mut prog, &fw);

        assert_eq!(prog.main_thread_only.len(), 1);
        assert_eq!(prog.method_has_error_outparam.len(), 1);
    }

    #[test]
    fn loads_weak_param_ownership() {
        let fw = make_framework_with_class(
            "NSWindow",
            vec![],
            vec![ClassAnnotations {
                class_name: "NSWindow".to_string(),
                methods: vec![MethodAnnotation {
                    selector: "setDelegate:".to_string(),
                    is_instance: true,
                    parameter_ownership: vec![ParamOwnership {
                        param_index: 0,
                        ownership: OwnershipKind::Weak,
                    }],
                    block_parameters: vec![],
                    threading: None,
                    error_pattern: None,
                    source: AnnotationSource::Heuristic,
                }],
            }],
        );
        let mut prog = EnrichmentProgram::default();
        load_framework_facts(&mut prog, &fw);

        assert_eq!(prog.weak_param.len(), 1);
        assert_eq!(prog.weak_param[0].2, 0);
    }
}
