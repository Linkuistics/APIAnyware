//! Naming-convention heuristics for classifying ObjC API semantics.
//!
//! These heuristics derive annotations from selector names and type signatures.
//! They serve as a validation cross-check against LLM-derived annotations:
//! agreement = high confidence, disagreement = flag for human review.

use apianyware_macos_types::annotation::{
    AnnotationSource, BlockInvocationStyle, BlockParamAnnotation, ErrorPattern, MethodAnnotation,
    OwnershipKind, ParamOwnership, ThreadingConstraint,
};
use apianyware_macos_types::ir::{Class, Method, Property};
use apianyware_macos_types::type_ref::TypeRefKind;

/// Derive heuristic annotations for a single method, given its owning class.
///
/// The class context provides class-level Swift attributes (used for
/// `@MainActor` threading propagation) and the property list (used to
/// classify block-typed setters of `@property (copy)` properties as
/// `stored`). Methods on synthetic classes that lack richer context can
/// pass an empty `Class { name, .. }` shell — only `name`, `properties`,
/// and `swift_attributes` are consulted here.
pub fn annotate_method_heuristic(class: &Class, method: &Method) -> MethodAnnotation {
    let selector = &method.selector;
    let is_instance = !method.class_method;

    let parameter_ownership = derive_parameter_ownership(&class.name, selector, method);
    let block_parameters = derive_block_parameters(selector, method, &class.properties);
    let threading = derive_threading(&class.name, selector, &class.swift_attributes);
    let error_pattern = derive_error_pattern(method);

    MethodAnnotation {
        selector: selector.clone(),
        is_instance,
        parameter_ownership,
        block_parameters,
        threading,
        error_pattern,
        source: AnnotationSource::Heuristic,
    }
}

/// Derive parameter ownership from selector naming conventions.
///
/// - "delegate" or "dataSource" params are weak
/// - Block params are copied
/// - Everything else is strong (default, not emitted)
fn derive_parameter_ownership(
    _class_name: &str,
    selector: &str,
    method: &Method,
) -> Vec<ParamOwnership> {
    let mut result = Vec::new();

    let selector_parts: Vec<&str> = selector.split(':').collect();

    for (i, param) in method.params.iter().enumerate() {
        let ownership = if is_delegate_param(selector, &selector_parts, i, &param.name)
            || is_observer_param(selector, i, &param.name)
        {
            OwnershipKind::Weak
        } else if matches!(param.param_type.kind, TypeRefKind::Block { .. }) {
            OwnershipKind::Copy
        } else {
            // Strong is the default — only emit non-default annotations
            continue;
        };

        result.push(ParamOwnership {
            param_index: i,
            ownership,
        });
    }

    result
}

/// Check if a parameter is likely a delegate or data source (weak reference).
fn is_delegate_param(
    selector: &str,
    selector_parts: &[&str],
    param_index: usize,
    param_name: &str,
) -> bool {
    let name_lower = param_name.to_lowercase();
    let sel_lower = selector.to_lowercase();

    // Direct name matching
    if name_lower.contains("delegate") || name_lower.contains("datasource") {
        return true;
    }

    // Selector part matching (e.g., "setDelegate:" -> first param is delegate)
    if let Some(part) = selector_parts.get(param_index) {
        let part_lower = part.to_lowercase();
        if part_lower.contains("delegate") || part_lower.contains("datasource") {
            return true;
        }
    }

    // Known setter patterns
    if sel_lower == "setdelegate:" || sel_lower == "setdatasource:" {
        return param_index == 0;
    }

    false
}

/// Check if a parameter is the observer in an `add…Observer:` family selector.
///
/// Covers KVO `addObserver:forKeyPath:options:context:`, NSNotificationCenter
/// `addObserver:selector:name:object:`, and KVO bulk variants like
/// `addSharedObserver:forKey:options:context:`. All store the observer as a
/// weak reference — the same ownership semantics as a delegate, but the selector
/// segment isn't `setDelegate:` so the existing delegate heuristic doesn't catch
/// them. The block-form `addObserverForName:object:queue:usingBlock:` is correctly
/// excluded because its first segment ends in `Name`, not `Observer`.
fn is_observer_param(selector: &str, param_index: usize, param_name: &str) -> bool {
    if param_index != 0 || !param_name.to_lowercase().contains("observer") {
        return false;
    }
    let first_segment = selector.split(':').next().unwrap_or("");
    first_segment.starts_with("add") && first_segment.ends_with("Observer")
}

/// Derive block parameter invocation style from selector naming.
fn derive_block_parameters(
    selector: &str,
    method: &Method,
    class_properties: &[Property],
) -> Vec<BlockParamAnnotation> {
    let mut result = Vec::new();

    for (i, param) in method.params.iter().enumerate() {
        if !matches!(param.param_type.kind, TypeRefKind::Block { .. }) {
            continue;
        }

        let invocation = if is_copy_block_property_setter(selector, i, class_properties) {
            // ObjC `@property (copy)` of block type: the synthesised setter
            // `Block_copy`-es and stores the block on the instance, holding
            // it across many invocations until reassignment / dealloc. This
            // is the textbook `stored` lifecycle.
            BlockInvocationStyle::Stored
        } else {
            classify_block_invocation(selector, i, method.params.len())
        };
        result.push(BlockParamAnnotation {
            param_index: i,
            invocation,
        });
    }

    result
}

/// Return true when `selector` is the synthesised ObjC setter for an
/// `@property (copy)` whose declared type is a block, and `param_index` is
/// the setter's only argument (index 0).
///
/// Recognises the canonical synthesised form `set<Cap><Rest>:` for a
/// property named `<lower><Rest>`. Custom `setter=` annotations are not
/// covered (rare on block properties; would require resolving the override
/// at extraction time).
fn is_copy_block_property_setter(
    selector: &str,
    param_index: usize,
    class_properties: &[Property],
) -> bool {
    if param_index != 0 {
        return false;
    }
    let Some(property_name) = setter_target_property_name(selector) else {
        return false;
    };
    class_properties.iter().any(|p| {
        p.is_copy
            && !p.class_property
            && matches!(p.property_type.kind, TypeRefKind::Block { .. })
            && p.name == property_name
    })
}

/// Map a synthesised setter selector `set<Cap><Rest>:` to the property
/// name `<lower><Rest>`. Returns `None` for selectors that are not
/// single-argument synthesised setters.
fn setter_target_property_name(selector: &str) -> Option<String> {
    let stripped = selector.strip_prefix("set")?.strip_suffix(':')?;
    if stripped.split(':').count() != 1 {
        return None;
    }
    let mut chars = stripped.chars();
    let first = chars.next()?;
    if !first.is_ascii_uppercase() {
        return None;
    }
    let mut name = String::with_capacity(stripped.len());
    name.push(first.to_ascii_lowercase());
    name.extend(chars);
    Some(name)
}

/// Classify a block parameter as synchronous, async-copied, or stored based on naming.
fn classify_block_invocation(
    selector: &str,
    param_index: usize,
    total_params: usize,
) -> BlockInvocationStyle {
    let sel_lower = selector.to_lowercase();

    // Synchronous patterns: enumerate, sort, compare, predicate, filter
    let sync_patterns = [
        "enumerate",
        "sortedarray",
        "sortusing",
        "comparator",
        "predicate",
        "filteredarray",
        "filtered",
        "indexofobject",
        "indexesofobjects",
        "passingtest",
    ];
    for pattern in &sync_patterns {
        if sel_lower.contains(pattern) {
            return BlockInvocationStyle::Synchronous;
        }
    }

    // Async patterns: completion, handler, callback, reply
    let async_patterns = ["completion", "handler", "callback", "reply", "withresponse"];
    for pattern in &async_patterns {
        if sel_lower.contains(pattern) {
            return BlockInvocationStyle::AsyncCopied;
        }
    }

    // If the block is the last param and the method name suggests async operation
    if param_index == total_params - 1 {
        let async_method_patterns = [
            "datatask", "download", "upload", "fetch", "load", "perform", "animate",
        ];
        for pattern in &async_method_patterns {
            if sel_lower.contains(pattern) {
                return BlockInvocationStyle::AsyncCopied;
            }
        }
    }

    // Stored patterns: observer, notification, handler registration
    let stored_patterns = ["addobserver", "observe", "notification", "addoperation"];
    for pattern in &stored_patterns {
        if sel_lower.contains(pattern) {
            return BlockInvocationStyle::Stored;
        }
    }

    // Default: async-copied (safer assumption — explicit free is only needed for sync)
    BlockInvocationStyle::AsyncCopied
}

/// Derive threading constraints from class-level Swift attributes,
/// hardcoded UI classes, or UI-related selector names.
fn derive_threading(
    class_name: &str,
    selector: &str,
    class_swift_attributes: &[String],
) -> Option<ThreadingConstraint> {
    // Class-level `@MainActor` (or `@_Concurrency.MainActor`) propagates to
    // every instance method on the class. swift-api-digester emits the bare
    // attribute names without the `@` prefix and sometimes with the
    // `_Concurrency.` module qualifier — accept all observed variants. The
    // ObjC-side `NS_SWIFT_UI_ACTOR` / `NS_SWIFT_MAIN_ACTOR` macros are also
    // captured by extract-objc's class header scan (see
    // `detect_class_swift_attributes`) and contribute to `swift_attributes`
    // before the merge with the Swift-side digester output, so a class that
    // is annotated only via the ObjC macro reaches this branch too. The
    // hardcoded UI list below remains as a fallback for any class whose
    // header omits both the macro and a Swift digester `@MainActor`.
    if class_swift_attributes
        .iter()
        .any(|a| is_main_actor_attribute(a))
    {
        return Some(ThreadingConstraint::MainThreadOnly);
    }

    // UI classes are main-thread-only
    let main_thread_classes = [
        "NSView",
        "NSWindow",
        "NSButton",
        "NSTextField",
        "NSTextView",
        "NSTableView",
        "NSOutlineView",
        "NSCollectionView",
        "NSStackView",
        "NSScrollView",
        "NSClipView",
        "NSSplitView",
        "NSTabView",
        "NSMenuItem",
        "NSMenu",
        "NSToolbar",
        "NSToolbarItem",
        "NSAlert",
        "NSPanel",
        "NSSavePanel",
        "NSOpenPanel",
        "NSColorPanel",
        "NSFontPanel",
        "NSApplication",
        "NSWorkspace",
        "NSImage",
        "NSBitmapImageRep",
        // UIKit equivalents (future-proofing)
        "UIView",
        "UIWindow",
        "UIButton",
        "UILabel",
        "UITextField",
        "UITableView",
        "UICollectionView",
        "UIViewController",
    ];

    if main_thread_classes.contains(&class_name) {
        return Some(ThreadingConstraint::MainThreadOnly);
    }

    // UI-related selectors on any class
    let main_thread_selectors = [
        "display",
        "setNeedsDisplay",
        "setNeedsLayout",
        "layout",
        "drawRect:",
        "updateLayer",
    ];
    if main_thread_selectors.contains(&selector) {
        return Some(ThreadingConstraint::MainThreadOnly);
    }

    // No heuristic available for most methods
    None
}

/// Recognise the swift-api-digester representations of `@MainActor`.
///
/// Observed variants (across the 154 annotated frameworks in the workspace):
/// `MainActor`, `_Concurrency.MainActor`. Match conservatively: equality
/// after stripping a leading module qualifier, so future-added qualifiers
/// (e.g. a fully-qualified `Swift._Concurrency.MainActor`) still match
/// without code changes — and unrelated attributes like `Available`,
/// `HasStorage`, `MacroRole` do not.
fn is_main_actor_attribute(attr: &str) -> bool {
    let unqualified = attr.rsplit('.').next().unwrap_or(attr);
    unqualified == "MainActor"
}

/// Derive error handling pattern from method signature.
fn derive_error_pattern(method: &Method) -> Option<ErrorPattern> {
    // Check for NSError** out-param (last parameter is pointer to NSError class)
    if let Some(last_param) = method.params.last() {
        // NSError** appears as Pointer type with name containing "error"
        let name_lower = last_param.name.to_lowercase();
        if (name_lower == "error" || name_lower.ends_with("error"))
            && matches!(last_param.param_type.kind, TypeRefKind::Pointer)
        {
            return Some(ErrorPattern::ErrorOutParam);
        }
    }

    None
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::Param;
    use apianyware_macos_types::type_ref::TypeRef;

    fn make_type_id() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        }
    }

    fn make_type_block() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "void".to_string(),
                    },
                }),
            },
        }
    }

    fn make_type_pointer() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Pointer,
        }
    }

    /// Build a minimal `Class` shell carrying only the fields the heuristic
    /// inspects: `name`, `properties`, and `swift_attributes`.
    fn make_class(name: &str) -> Class {
        Class {
            name: name.to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        }
    }

    fn make_property(name: &str, property_type: TypeRef, is_copy: bool) -> Property {
        Property {
            name: name.to_string(),
            property_type,
            readonly: false,
            class_property: false,
            is_copy,
            deprecated: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
        }
    }

    fn make_method(
        selector: &str,
        class_method: bool,
        params: Vec<Param>,
        return_type: TypeRef,
    ) -> Method {
        Method {
            selector: selector.to_string(),
            class_method,
            init_method: false,
            params,
            return_type,
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

    #[test]
    fn test_delegate_param_detection() {
        let method = make_method(
            "setDelegate:",
            false,
            vec![Param {
                name: "delegate".to_string(),
                param_type: make_type_id(),
            }],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSWindow"), &method);
        assert_eq!(ann.parameter_ownership.len(), 1);
        assert_eq!(ann.parameter_ownership[0].ownership, OwnershipKind::Weak);
    }

    #[test]
    fn test_block_sync_detection() {
        let method = make_method(
            "enumerateObjectsUsingBlock:",
            false,
            vec![Param {
                name: "block".to_string(),
                param_type: make_type_block(),
            }],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSArray"), &method);
        assert_eq!(ann.block_parameters.len(), 1);
        assert_eq!(
            ann.block_parameters[0].invocation,
            BlockInvocationStyle::Synchronous
        );
    }

    #[test]
    fn test_block_async_detection() {
        let method = make_method(
            "dataTaskWithURL:completionHandler:",
            false,
            vec![
                Param {
                    name: "url".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "completionHandler".to_string(),
                    param_type: make_type_block(),
                },
            ],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSURLSession"), &method);
        assert_eq!(ann.block_parameters.len(), 1);
        assert_eq!(
            ann.block_parameters[0].invocation,
            BlockInvocationStyle::AsyncCopied
        );
    }

    #[test]
    fn test_block_stored_detection() {
        let method = make_method(
            "addObserverForName:object:queue:usingBlock:",
            false,
            vec![
                Param {
                    name: "name".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "obj".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "queue".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "block".to_string(),
                    param_type: make_type_block(),
                },
            ],
            make_type_id(),
        );

        let ann = annotate_method_heuristic(&make_class("NSNotificationCenter"), &method);
        assert_eq!(ann.block_parameters.len(), 1);
        assert_eq!(
            ann.block_parameters[0].invocation,
            BlockInvocationStyle::Stored
        );
    }

    #[test]
    fn test_error_outparam_detection() {
        let method = make_method(
            "contentsOfDirectoryAtPath:error:",
            false,
            vec![
                Param {
                    name: "path".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "error".to_string(),
                    param_type: make_type_pointer(),
                },
            ],
            make_type_id(),
        );

        let ann = annotate_method_heuristic(&make_class("NSFileManager"), &method);
        assert_eq!(ann.error_pattern, Some(ErrorPattern::ErrorOutParam));
    }

    #[test]
    fn test_threading_ui_class() {
        let method = make_method(
            "setTitle:",
            false,
            vec![Param {
                name: "title".to_string(),
                param_type: make_type_id(),
            }],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSWindow"), &method);
        assert_eq!(ann.threading, Some(ThreadingConstraint::MainThreadOnly));
    }

    #[test]
    fn test_no_threading_foundation_class() {
        let method = make_method(
            "length",
            false,
            vec![],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "NSUInteger".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSString"), &method);
        assert_eq!(ann.threading, None);
    }

    #[test]
    fn test_threading_ui_selector_on_any_class() {
        let method = make_method(
            "drawRect:",
            false,
            vec![Param {
                name: "rect".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Struct {
                        name: "CGRect".to_string(),
                    },
                },
            }],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("MyCustomView"), &method);
        assert_eq!(ann.threading, Some(ThreadingConstraint::MainThreadOnly));
    }

    #[test]
    fn test_datasource_param_detection() {
        let method = make_method(
            "setDataSource:",
            false,
            vec![Param {
                name: "dataSource".to_string(),
                param_type: make_type_id(),
            }],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSTableView"), &method);
        assert_eq!(ann.parameter_ownership.len(), 1);
        assert_eq!(ann.parameter_ownership[0].ownership, OwnershipKind::Weak);
    }

    #[test]
    fn test_addobserver_kvo_observer_param_is_weak() {
        // KVO addObserver:forKeyPath:options:context: passes a generic id observer
        // that the framework holds weakly. The selector segment isn't setDelegate:
        // so the existing delegate heuristic doesn't fire — this is the gap the
        // observer heuristic closes.
        let method = make_method(
            "addObserver:forKeyPath:options:context:",
            false,
            vec![
                Param {
                    name: "observer".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "keyPath".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "options".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "NSKeyValueObservingOptions".to_string(),
                        },
                    },
                },
                Param {
                    name: "context".to_string(),
                    param_type: make_type_pointer(),
                },
            ],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSArray"), &method);
        let observer = ann
            .parameter_ownership
            .iter()
            .find(|p| p.param_index == 0)
            .expect("observer ownership entry missing");
        assert_eq!(observer.ownership, OwnershipKind::Weak);
    }

    #[test]
    fn test_addobserver_notification_observer_param_is_weak() {
        let method = make_method(
            "addObserver:selector:name:object:",
            false,
            vec![
                Param {
                    name: "observer".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "aSelector".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "SEL".to_string(),
                        },
                    },
                },
                Param {
                    name: "aName".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "anObject".to_string(),
                    param_type: make_type_id(),
                },
            ],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSNotificationCenter"), &method);
        let observer = ann
            .parameter_ownership
            .iter()
            .find(|p| p.param_index == 0)
            .expect("observer ownership entry missing");
        assert_eq!(observer.ownership, OwnershipKind::Weak);
    }

    #[test]
    fn test_add_shared_observer_kvo_variant_is_weak() {
        // NSKeyValueSharedObservers.addSharedObserver:forKey:options:context: —
        // first selector segment is `addSharedObserver`, not `addObserver`, but
        // the observer ownership semantics are identical (KVO holds the observer
        // weakly). The structural form `add<Qualifier>Observer:` should match.
        let method = make_method(
            "addSharedObserver:forKey:options:context:",
            false,
            vec![
                Param {
                    name: "observer".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "key".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "options".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "NSKeyValueObservingOptions".to_string(),
                        },
                    },
                },
                Param {
                    name: "context".to_string(),
                    param_type: make_type_pointer(),
                },
            ],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSKeyValueSharedObservers"), &method);
        let observer = ann
            .parameter_ownership
            .iter()
            .find(|p| p.param_index == 0)
            .expect("observer ownership entry missing");
        assert_eq!(observer.ownership, OwnershipKind::Weak);
    }

    #[test]
    fn test_addobserver_does_not_misfire_on_block_form() {
        // addObserverForName: returns a system-generated observer; it doesn't take
        // an observer param, so the heuristic must not classify the first param
        // (a name string) as weak.
        let method = make_method(
            "addObserverForName:object:queue:usingBlock:",
            false,
            vec![
                Param {
                    name: "name".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "obj".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "queue".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "block".to_string(),
                    param_type: make_type_block(),
                },
            ],
            make_type_id(),
        );

        let ann = annotate_method_heuristic(&make_class("NSNotificationCenter"), &method);
        // Param 0 (name) must not be marked weak.
        assert!(
            !ann.parameter_ownership
                .iter()
                .any(|p| p.param_index == 0 && p.ownership == OwnershipKind::Weak),
            "first param of addObserverForName:... is a name string, not an observer; \
             must not be weak: {:?}",
            ann.parameter_ownership
        );
    }

    #[test]
    fn test_addobserver_only_fires_on_first_param() {
        // A hypothetical method with `addObserver:` substring but the observer at
        // a non-zero index (or a non-observer-named first param) must not fire.
        let method = make_method(
            "addObserver:forKeyPath:options:context:",
            false,
            vec![
                Param {
                    // Non-observer name — must not match.
                    name: "target".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "keyPath".to_string(),
                    param_type: make_type_id(),
                },
                Param {
                    name: "options".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "NSUInteger".to_string(),
                        },
                    },
                },
                Param {
                    name: "context".to_string(),
                    param_type: make_type_pointer(),
                },
            ],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&make_class("NSArray"), &method);
        // No weak entry for param 0 — name doesn't say "observer".
        assert!(
            !ann.parameter_ownership
                .iter()
                .any(|p| p.param_index == 0 && p.ownership == OwnershipKind::Weak),
            "first param is named 'target', not an observer: {:?}",
            ann.parameter_ownership
        );
    }

    #[test]
    fn test_block_param_copy_ownership() {
        let method = make_method(
            "sortedArrayUsingComparator:",
            false,
            vec![Param {
                name: "cmptr".to_string(),
                param_type: make_type_block(),
            }],
            make_type_id(),
        );

        let ann = annotate_method_heuristic(&make_class("NSArray"), &method);
        // Block params should be Copy ownership AND synchronous invocation
        assert_eq!(ann.parameter_ownership.len(), 1);
        assert_eq!(ann.parameter_ownership[0].ownership, OwnershipKind::Copy);
        assert_eq!(ann.block_parameters.len(), 1);
        assert_eq!(
            ann.block_parameters[0].invocation,
            BlockInvocationStyle::Synchronous
        );
    }

    // -----------------------------------------------------------------
    // MainActor threading propagation
    // -----------------------------------------------------------------

    fn make_void_method(selector: &str) -> Method {
        make_method(
            selector,
            false,
            vec![],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        )
    }

    #[test]
    fn class_main_actor_attribute_propagates_to_all_instance_methods() {
        // Canonical Swift digester form: bare `MainActor` attribute on a
        // Swift-only class. `someMethod` doesn't match any selector
        // heuristic and the class isn't in the hardcoded UI list — so the
        // class-level attribute is the only signal that fires.
        let mut class = make_class("ImageRenderer");
        class.swift_attributes = vec!["MainActor".to_string()];

        let ann = annotate_method_heuristic(&class, &make_void_method("render"));
        assert_eq!(ann.threading, Some(ThreadingConstraint::MainThreadOnly));
    }

    #[test]
    fn class_concurrency_qualified_main_actor_propagates() {
        // Module-qualified form observed on Swift-only frameworks
        // (RealityKit, SwiftUICore, ClassKitUI).
        let mut class = make_class("Entity");
        class.swift_attributes = vec!["_Concurrency.MainActor".to_string()];

        let ann = annotate_method_heuristic(&class, &make_void_method("update"));
        assert_eq!(ann.threading, Some(ThreadingConstraint::MainThreadOnly));
    }

    #[test]
    fn unrelated_swift_attributes_do_not_trigger_main_thread() {
        // `Available`, `HasStorage`, `MacroRole` are common attributes that
        // must not trigger main-thread propagation.
        let mut class = make_class("PlainModel");
        class.swift_attributes = vec![
            "Available".to_string(),
            "HasStorage".to_string(),
            "MacroRole".to_string(),
        ];

        let ann = annotate_method_heuristic(&class, &make_void_method("describe"));
        assert_eq!(ann.threading, None);
    }

    #[test]
    fn main_actor_propagation_also_applies_to_class_methods() {
        // Class-level `@MainActor` covers class methods too. The hardcoded
        // UI-class list behaves the same way (selector check is independent
        // of `class_method`), and `effective_method` resolution treats both
        // alike — so we mirror that here.
        let mut class = make_class("ImageRenderer");
        class.swift_attributes = vec!["MainActor".to_string()];
        let class_method = make_method(
            "shared",
            true,
            vec![],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
        );

        let ann = annotate_method_heuristic(&class, &class_method);
        assert_eq!(ann.threading, Some(ThreadingConstraint::MainThreadOnly));
    }

    // -----------------------------------------------------------------
    // @property (copy) block-setter -> stored
    // -----------------------------------------------------------------

    fn make_block_property_setter_method(prop_name: &str) -> Method {
        let cap = {
            let mut c = prop_name.chars();
            let first = c.next().unwrap().to_ascii_uppercase();
            let mut s = String::with_capacity(prop_name.len());
            s.push(first);
            s.extend(c);
            s
        };
        make_method(
            &format!("set{cap}:"),
            false,
            vec![Param {
                name: prop_name.to_string(),
                param_type: make_type_block(),
            }],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        )
    }

    #[test]
    fn copy_block_property_setter_is_stored() {
        // The canonical pattern: `@property (copy) MyHandler completionBlock;`
        // synthesises `setCompletionBlock:`, which Block_copy-es and stores
        // the block on the instance until reassignment.
        let mut class = make_class("NSOperation");
        class
            .properties
            .push(make_property("completionBlock", make_type_block(), true));

        let ann = annotate_method_heuristic(
            &class,
            &make_block_property_setter_method("completionBlock"),
        );
        assert_eq!(ann.block_parameters.len(), 1);
        assert_eq!(
            ann.block_parameters[0].invocation,
            BlockInvocationStyle::Stored,
            "@property (copy) block setter must classify as stored, not async_copied",
        );
    }

    #[test]
    fn non_copy_block_property_setter_uses_default_classification() {
        // Without the `copy` attribute we cannot statically conclude the
        // setter stores the block — fall back to the selector heuristic
        // (which here finds no `Handler`/`Completion` token and defaults
        // to `async_copied`).
        let mut class = make_class("MyClass");
        class
            .properties
            .push(make_property("callback", make_type_block(), false));

        let ann = annotate_method_heuristic(
            &class,
            &make_block_property_setter_method("callback"),
        );
        assert_eq!(ann.block_parameters.len(), 1);
        assert_ne!(
            ann.block_parameters[0].invocation,
            BlockInvocationStyle::Stored,
        );
    }

    #[test]
    fn copy_attribute_on_non_block_property_does_not_make_block_setter_stored() {
        // The class has a copy NSString property, but the setter we're
        // annotating targets `block` (a different name). The string
        // property's `copy` must not pull the unrelated block setter into
        // the `stored` category.
        let mut class = make_class("MyClass");
        let id_type = make_type_id();
        class
            .properties
            .push(make_property("title", id_type, true));

        let ann = annotate_method_heuristic(
            &class,
            &make_block_property_setter_method("block"),
        );
        // setBlock: doesn't match a `(copy) block` property → falls through
        // to the selector heuristic (default async_copied).
        assert_ne!(
            ann.block_parameters[0].invocation,
            BlockInvocationStyle::Stored,
        );
    }

    #[test]
    fn unrelated_setter_for_copy_block_property_does_not_match() {
        // A method whose selector resembles a setter for property X but
        // doesn't actually correspond — e.g., extra selector segment —
        // must not be misclassified.
        let mut class = make_class("MyClass");
        class
            .properties
            .push(make_property("handler", make_type_block(), true));

        // Two-arg "setter" — not a synthesised setter shape.
        let two_arg_setter = make_method(
            "setHandler:withOptions:",
            false,
            vec![
                Param {
                    name: "handler".to_string(),
                    param_type: make_type_block(),
                },
                Param {
                    name: "options".to_string(),
                    param_type: make_type_id(),
                },
            ],
            TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "void".to_string(),
                },
            },
        );

        let ann = annotate_method_heuristic(&class, &two_arg_setter);
        // First param is the block; it must not be classified as stored
        // because the selector is not the synthesised single-arg setter.
        let first_block = ann
            .block_parameters
            .iter()
            .find(|b| b.param_index == 0)
            .expect("first param is a block");
        assert_ne!(first_block.invocation, BlockInvocationStyle::Stored);
    }
}
