//! AST traversal to extract ObjC/C declarations from a parsed translation unit.
//!
//! Walks the libclang AST and populates IR types for classes, protocols,
//! enums, structs, functions, and constants. Also captures provenance
//! (source location, availability) and documentation references.

use std::collections::{HashMap, HashSet};
use std::path::Path;

use clang::{Entity, EntityKind, EntityVisitResult, Linkage, TypeKind};

use apianyware_macos_types::ir;
use apianyware_macos_types::provenance::{
    Availability, DeclarationSource, DocRefs, SourceProvenance,
};
use apianyware_macos_types::skipped_symbol_reason;
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::type_mapping::map_type;

/// State accumulated during AST traversal for a single framework.
#[derive(Debug, Default)]
pub struct ExtractionResult {
    pub classes: Vec<ir::Class>,
    pub protocols: Vec<ir::Protocol>,
    pub enums: Vec<ir::Enum>,
    pub structs: Vec<ir::Struct>,
    pub functions: Vec<ir::Function>,
    pub constants: Vec<ir::Constant>,
    pub skipped_symbols: Vec<ir::SkippedSymbol>,
}

/// Extract all declarations from a translation unit's AST.
///
/// Only includes declarations from the specified framework (filters by
/// header path). Captures provenance and documentation for each declaration.
pub fn extract_from_translation_unit(
    translation_unit_entity: &Entity<'_>,
    framework_name: &str,
    sdk_path: &Path,
) -> ExtractionResult {
    let mut result = ExtractionResult::default();
    let mut seen_classes: HashSet<String> = HashSet::new();
    let mut seen_protocols: HashSet<String> = HashSet::new();
    let mut seen_enums: HashSet<String> = HashSet::new();
    let mut seen_structs: HashSet<String> = HashSet::new();
    let mut seen_functions: HashSet<String> = HashSet::new();
    let mut seen_constants: HashSet<String> = HashSet::new();
    // Collect category methods and properties to merge into classes later
    let mut category_methods: HashMap<String, Vec<ir::CategoryGroup>> = HashMap::new();
    let mut category_properties: HashMap<String, Vec<ir::Property>> = HashMap::new();

    translation_unit_entity.visit_children(|entity, _parent| {
        // Filter to only declarations from this framework
        if !is_from_framework(&entity, framework_name, sdk_path) {
            return EntityVisitResult::Continue;
        }

        match entity.get_kind() {
            EntityKind::ObjCInterfaceDecl => {
                // Note: is_definition() cannot be used here — in Clang's AST,
                // @interface is a declaration (not a definition; @implementation
                // is the definition, but it lives in .m files absent from SDK
                // headers). Forward @class declarations produce ObjCClassRef
                // cursors, not ObjCInterfaceDecl, so no forward-decl shadowing
                // is possible for this entity kind.
                if let Some(name) = entity.get_name() {
                    if seen_classes.insert(name.clone()) {
                        if let Some(class) =
                            extract_class(&entity, sdk_path, &mut result.skipped_symbols)
                        {
                            result.classes.push(class);
                        }
                    }
                }
            }
            EntityKind::ObjCProtocolDecl => {
                // @protocol Foo; forward declarations must be skipped so the
                // seen_protocols guard doesn't shadow the full @protocol definition.
                if entity.is_definition() {
                    if let Some(name) = entity.get_name() {
                        if seen_protocols.insert(name.clone()) {
                            if let Some(protocol) =
                                extract_protocol(&entity, sdk_path, &mut result.skipped_symbols)
                            {
                                result.protocols.push(protocol);
                            }
                        }
                    }
                }
            }
            EntityKind::ObjCCategoryDecl => {
                extract_category(
                    &entity,
                    sdk_path,
                    framework_name,
                    &mut category_methods,
                    &mut category_properties,
                    &mut result.skipped_symbols,
                );
            }
            EntityKind::EnumDecl => {
                // CF_ENUM/NS_ENUM macros expand to a forward declaration
                // followed by the actual definition (two EnumDecl entities
                // sharing one name). Skip the forward declaration so the
                // seen_enums guard doesn't shadow the populated definition.
                if entity.is_definition() {
                    if let Some(name) = entity.get_name() {
                        if !name.is_empty() && seen_enums.insert(name.clone()) {
                            if let Some(en) = extract_enum(&entity, sdk_path) {
                                result.enums.push(en);
                            }
                        }
                    }
                }
            }
            EntityKind::StructDecl => {
                // struct Foo; forward declarations must be skipped so the
                // seen_structs guard doesn't shadow the full struct definition.
                if entity.is_definition() {
                    if let Some(name) = entity.get_name() {
                        if !name.is_empty() && seen_structs.insert(name.clone()) {
                            if let Some(st) = extract_struct(&entity, sdk_path) {
                                result.structs.push(st);
                            }
                        }
                    }
                }
            }
            EntityKind::FunctionDecl => {
                if let Some(name) = entity.get_name() {
                    if seen_functions.insert(name.clone()) {
                        if let Some(func) =
                            extract_function(&entity, sdk_path, &mut result.skipped_symbols)
                        {
                            result.functions.push(func);
                        }
                    }
                }
            }
            EntityKind::VarDecl => {
                if let Some(name) = entity.get_name() {
                    if seen_constants.insert(name.clone()) {
                        if let Some(constant) =
                            extract_constant(&entity, sdk_path, &mut result.skipped_symbols)
                        {
                            result.constants.push(constant);
                        }
                    }
                }
            }
            EntityKind::MacroDefinition => {
                if let Some(name) = entity.get_name() {
                    if seen_constants.insert(name.clone()) {
                        if let Some(constant) = extract_cfstr_macro_constant(&entity, sdk_path) {
                            result.constants.push(constant);
                        } else {
                            // Not a CFSTR macro — remove from seen set so a
                            // VarDecl with the same name can still be extracted.
                            seen_constants.remove(&name);
                        }
                    }
                }
            }
            _ => {}
        }

        EntityVisitResult::Continue
    });

    // Merge category methods and properties into their classes
    for class in &mut result.classes {
        if let Some(categories) = category_methods.remove(&class.name) {
            class.category_methods = categories;
        }
        if let Some(props) = category_properties.remove(&class.name) {
            let existing_names: HashSet<String> =
                class.properties.iter().map(|p| p.name.clone()).collect();
            class.properties.extend(
                props
                    .into_iter()
                    .filter(|p| !existing_names.contains(&p.name)),
            );
        }
    }

    // Sort all declarations by name for deterministic output
    result.classes.sort_by(|a, b| a.name.cmp(&b.name));
    result.protocols.sort_by(|a, b| a.name.cmp(&b.name));
    result.enums.sort_by(|a, b| a.name.cmp(&b.name));
    result.structs.sort_by(|a, b| a.name.cmp(&b.name));
    result.functions.sort_by(|a, b| a.name.cmp(&b.name));
    result.constants.sort_by(|a, b| a.name.cmp(&b.name));

    result
}

/// Append an audit-trail entry into a framework's `skipped_symbols` list.
///
/// The string form of `reason` comes from [`skipped_symbol_reason`] and
/// carries both a machine-readable tag prefix and a human description.
/// Downstream audit tooling can match on the tag via `reason.contains(...)`.
fn record_skip(
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
    name: impl Into<String>,
    kind: &'static str,
    reason: &'static str,
) {
    skipped_symbols.push(ir::SkippedSymbol {
        name: name.into(),
        kind: kind.to_string(),
        reason: reason.to_string(),
    });
}

// ---------------------------------------------------------------------------
// Class extraction
// ---------------------------------------------------------------------------

fn extract_class(
    entity: &Entity<'_>,
    sdk_path: &Path,
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
) -> Option<ir::Class> {
    let name = entity.get_name()?;

    // Wholesale-drop classes marked unavailable on macOS. The ObjC
    // runtime cannot instantiate these classes on macOS, and any
    // selector dispatch against them crashes at first call. Dropping
    // the whole class (with its methods and properties) mirrors the
    // shape visible from the macOS dylib — iOS-family classes are
    // simply absent. See `filter_platform_unavailable.rs`.
    if is_unavailable_on_macos(entity) {
        record_skip(
            skipped_symbols,
            name,
            "class",
            skipped_symbol_reason::PLATFORM_UNAVAILABLE_MACOS,
        );
        return None;
    }

    let superclass = entity
        .get_children()
        .iter()
        .find(|c| c.get_kind() == EntityKind::ObjCSuperClassRef)
        .and_then(|c| c.get_name())
        .unwrap_or_default();

    let protocols: Vec<String> = entity
        .get_children()
        .iter()
        .filter(|c| c.get_kind() == EntityKind::ObjCProtocolRef)
        .filter_map(|c| c.get_name())
        .collect();

    let mut methods = Vec::new();
    let mut properties = Vec::new();
    let swift_attributes = detect_class_swift_attributes(entity);

    entity.visit_children(|child, _parent| {
        match child.get_kind() {
            EntityKind::ObjCInstanceMethodDecl | EntityKind::ObjCClassMethodDecl => {
                if let Some(method) = extract_method(&child, sdk_path, &name, skipped_symbols) {
                    methods.push(method);
                }
            }
            EntityKind::ObjCPropertyDecl => {
                if let Some(prop) = extract_property(&child, sdk_path, &name, skipped_symbols) {
                    properties.push(prop);
                }
            }
            _ => {}
        }
        EntityVisitResult::Continue
    });

    Some(ir::Class {
        name,
        superclass,
        protocols,
        properties,
        methods,
        category_methods: Vec::new(),
        swift_attributes,
        ancestors: Vec::new(),
        all_methods: Vec::new(),
        all_properties: Vec::new(),
    })
}

/// Detect Swift declaration attributes on a class entity (currently only
/// `MainActor`, sourced from `__attribute__((swift_attr("@MainActor")))` —
/// the expansion of `NS_SWIFT_UI_ACTOR` / `NS_SWIFT_MAIN_ACTOR`).
///
/// libclang surfaces `swift_attr` as `EntityKind::UnexposedAttr` children of
/// the class entity. We probe the attribute cursor via accessors that do not
/// invoke `clang_tokenize` — its display name reliably contains the Swift
/// attribute spelling (`@MainActor`) for `swift_attr`-derived cursors.
///
/// `clang_tokenize` is avoided here because some macro-expansion-internal
/// `UnexposedAttr` cursors return source ranges whose backing token buffer
/// is null, and the resulting `slice::from_raw_parts` aborts the process
/// across the visitor's `extern "C"` boundary. `get_display_name`,
/// `get_name`, and `get_pretty_printer` do not have this hazard.
/// Detect Swift declaration attributes on a class entity by scanning the
/// header source for macros that precede the `@interface` line. Currently
/// detects `MainActor` (sourced from `NS_SWIFT_UI_ACTOR`,
/// `NS_SWIFT_MAIN_ACTOR`, or a raw `__attribute__((swift_attr("@MainActor")))`).
///
/// Why scan source text rather than libclang attribute children:
/// `clang_tokenize` aborts the process when called on `UnexposedAttr`
/// cursors whose backing token buffer is null (a libclang shape that occurs
/// for some macro-expansion-internal attribute cursors). The class entity's
/// own extent starts at the `@interface` keyword and does not include the
/// preceding macro line. Reading the header file and looking at the lines
/// immediately above the class declaration is the only library-supported
/// route that is both safe and reliable.
///
/// The scan walks upward from the `@interface` line and stops at the first
/// line that ends a previous declaration (`;`, `}`, `@end`) or starts a
/// preprocessor / declaration boundary (`#import`, `#include`, `#endif`,
/// `@interface`, `@class`, `@protocol`). This bounds the scan to the
/// attribute stack that decorates the current class — usually 1-5 lines.
fn detect_class_swift_attributes(class_entity: &Entity<'_>) -> Vec<String> {
    let Some(location) = class_entity.get_location() else {
        return Vec::new();
    };
    let file_loc = location.get_file_location();
    let Some(file) = file_loc.file else {
        return Vec::new();
    };
    let class_line = file_loc.line as usize;
    if class_line == 0 {
        return Vec::new();
    }
    let path = file.get_path();
    let Ok(source) = std::fs::read_to_string(&path) else {
        return Vec::new();
    };
    let lines: Vec<&str> = source.lines().collect();
    let class_idx = class_line.saturating_sub(1);
    if class_idx == 0 || class_idx >= lines.len() {
        return Vec::new();
    }
    // `class_idx` is the 0-based index of the `@interface` line. Walk upward
    // through the immediately preceding lines, which (per macOS SDK style)
    // hold any attribute macros decorating the class. Bound the scan to 15
    // lines so a malformed header cannot cause unbounded scanning.
    let mut found_main_actor = false;
    let scan_floor = class_idx.saturating_sub(15);
    for i in (scan_floor..class_idx).rev() {
        let line = lines[i];
        let trimmed = line.trim();
        if line_carries_main_actor(trimmed) {
            found_main_actor = true;
        }
        if line_is_decl_boundary(trimmed) {
            break;
        }
    }
    if found_main_actor {
        vec!["MainActor".to_string()]
    } else {
        Vec::new()
    }
}

/// Match the macro spellings that resolve to `swift_attr("@MainActor")` on
/// macOS SDK headers, plus a raw `__attribute__((swift_attr("@MainActor")))`
/// in case a header inlines the attribute.
///
/// Frameworks alias the underlying `swift_attr("@MainActor")` macro under
/// per-framework prefixes — Foundation uses `NS_SWIFT_UI_ACTOR` /
/// `NS_SWIFT_MAIN_ACTOR`, CoreFoundation uses `CF_SWIFT_MAIN_ACTOR`,
/// MediaPlayer uses `MP_SWIFT_MAIN_ACTOR`, WebKit uses `WK_SWIFT_UI_ACTOR`,
/// and future frameworks may add their own. Match any token whose suffix is
/// `_SWIFT_UI_ACTOR` or `_SWIFT_MAIN_ACTOR` so new aliases are picked up
/// without code changes. Reject macros being **defined** (`#define X …`)
/// rather than used so the umbrella headers that introduce the alias
/// don't self-trigger.
fn line_carries_main_actor(trimmed_line: &str) -> bool {
    if trimmed_line.starts_with("//") || trimmed_line.starts_with("#define") {
        return false;
    }
    if trimmed_line.contains("swift_attr") && trimmed_line.contains("@MainActor") {
        return true;
    }
    line_contains_main_actor_alias(trimmed_line)
}

fn line_contains_main_actor_alias(trimmed_line: &str) -> bool {
    for suffix in ["_SWIFT_UI_ACTOR", "_SWIFT_MAIN_ACTOR"] {
        for (start, _) in trimmed_line.match_indices(suffix) {
            // Require an identifier prefix to ensure we're matching a token
            // boundary (e.g. `NS_SWIFT_UI_ACTOR`) rather than a substring of
            // some larger token. The prefix must be at least one identifier
            // character (`[A-Za-z0-9_]`) and must not start mid-identifier
            // beyond what an identifier prefix permits.
            if start == 0 {
                continue;
            }
            let prefix_byte = trimmed_line.as_bytes()[start - 1];
            if !prefix_byte.is_ascii_alphanumeric() && prefix_byte != b'_' {
                continue;
            }
            // Ensure the suffix isn't itself followed by identifier chars
            // (otherwise `_SWIFT_UI_ACTOR_FOO` would match).
            let after = start + suffix.len();
            if after < trimmed_line.len() {
                let next_byte = trimmed_line.as_bytes()[after];
                if next_byte.is_ascii_alphanumeric() || next_byte == b'_' {
                    continue;
                }
            }
            return true;
        }
    }
    false
}

/// Return true if the line ends a previous declaration or starts a new one,
/// bounding the upward attribute-stack scan above an `@interface` line.
fn line_is_decl_boundary(trimmed_line: &str) -> bool {
    if trimmed_line.is_empty() || trimmed_line.starts_with("//") {
        return false;
    }
    let stripped = trimmed_line.trim_end_matches(|c: char| c == '/' || c.is_whitespace());
    stripped.ends_with(';')
        || stripped.ends_with('}')
        || stripped == "@end"
        || trimmed_line.starts_with("@interface")
        || trimmed_line.starts_with("@class")
        || trimmed_line.starts_with("@protocol")
        || trimmed_line.starts_with("#import")
        || trimmed_line.starts_with("#include")
        || trimmed_line.starts_with("#endif")
}

// ---------------------------------------------------------------------------
// Method extraction
// ---------------------------------------------------------------------------

fn extract_method(
    entity: &Entity<'_>,
    sdk_path: &Path,
    owner_name: &str,
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
) -> Option<ir::Method> {
    let selector = entity.get_name()?;

    // Per-selector availability: a class can be available on macOS
    // while individual selectors are not (shared headers with
    // platform-conditional `API_UNAVAILABLE(macos)` attributes are
    // common in CoreMIDI / category extensions). These selectors have
    // no implementation in the macOS variant of the class, so
    // `objc_msgSend` crashes at first call with "unrecognized
    // selector sent to instance". Drop them during extraction.
    if is_unavailable_on_macos(entity) {
        record_skip(
            skipped_symbols,
            format!("{owner_name}.{selector}"),
            "method",
            skipped_symbol_reason::PLATFORM_UNAVAILABLE_MACOS,
        );
        return None;
    }

    let class_method = entity.get_kind() == EntityKind::ObjCClassMethodDecl;

    let init_method = !class_method && (selector == "init" || selector.starts_with("initWith"));

    let result_type = entity.get_result_type()?;
    let return_type = map_type(&result_type);

    let params = extract_params(entity);

    let deprecated = matches!(entity.get_availability(), clang::Availability::Deprecated);

    let variadic = entity.is_variadic();

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Method {
        selector,
        class_method,
        init_method,
        params,
        return_type,
        deprecated,
        variadic,
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
        origin: None,
        category: None,
        overrides: None,
        returns_retained: None,
        satisfies_protocol: None,
    })
}

fn extract_params(entity: &Entity<'_>) -> Vec<ir::Param> {
    entity
        .get_children()
        .iter()
        .filter(|c| c.get_kind() == EntityKind::ParmDecl)
        .filter_map(|c| {
            let name = c.get_name().unwrap_or_default();
            let param_type_clang = c.get_type()?;
            let param_type = map_type(&param_type_clang);
            Some(ir::Param { name, param_type })
        })
        .collect()
}

// ---------------------------------------------------------------------------
// Property extraction
// ---------------------------------------------------------------------------

fn extract_property(
    entity: &Entity<'_>,
    sdk_path: &Path,
    owner_name: &str,
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
) -> Option<ir::Property> {
    let name = entity.get_name()?;

    // Per-property availability: a class can be available on macOS
    // while individual properties are not. Dropped properties'
    // synthesized getter/setter selectors have no implementation in
    // the macOS variant of the dylib, so `objc_msgSend` crashes at
    // first call with "unrecognized selector". Symmetric to the
    // per-selector gate in `extract_method`.
    if is_unavailable_on_macos(entity) {
        record_skip(
            skipped_symbols,
            format!("{owner_name}.{name}"),
            "property",
            skipped_symbol_reason::PLATFORM_UNAVAILABLE_MACOS,
        );
        return None;
    }

    let property_type_clang = entity.get_type()?;
    let property_type = map_type(&property_type_clang);

    let objc_attrs = entity.get_objc_attributes();
    let readonly = objc_attrs.is_some_and(|a| a.readonly);
    let class_property = objc_attrs.is_some_and(|a| a.class);
    let is_copy = objc_attrs.is_some_and(|a| a.copy);

    let deprecated = matches!(entity.get_availability(), clang::Availability::Deprecated);

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Property {
        name,
        property_type,
        readonly,
        class_property,
        is_copy,
        deprecated,
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
        origin: None,
    })
}

// ---------------------------------------------------------------------------
// Protocol extraction
// ---------------------------------------------------------------------------

fn extract_protocol(
    entity: &Entity<'_>,
    sdk_path: &Path,
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
) -> Option<ir::Protocol> {
    let name = entity.get_name()?;

    // Wholesale-drop protocols marked unavailable on macOS. Same
    // reasoning as `extract_class`: the protocol conformance table
    // does not exist in the macOS variant of the framework, and any
    // attempt to use the protocol fails at runtime.
    if is_unavailable_on_macos(entity) {
        record_skip(
            skipped_symbols,
            name,
            "protocol",
            skipped_symbol_reason::PLATFORM_UNAVAILABLE_MACOS,
        );
        return None;
    }

    let inherits: Vec<String> = entity
        .get_children()
        .iter()
        .filter(|c| c.get_kind() == EntityKind::ObjCProtocolRef)
        .filter_map(|c| c.get_name())
        .collect();

    let mut required_methods = Vec::new();
    let mut optional_methods = Vec::new();
    let mut properties = Vec::new();

    entity.visit_children(|child, _parent| {
        match child.get_kind() {
            EntityKind::ObjCInstanceMethodDecl | EntityKind::ObjCClassMethodDecl => {
                if let Some(method) = extract_method(&child, sdk_path, &name, skipped_symbols) {
                    if child.is_objc_optional() {
                        optional_methods.push(method);
                    } else {
                        required_methods.push(method);
                    }
                }
            }
            EntityKind::ObjCPropertyDecl => {
                if let Some(prop) = extract_property(&child, sdk_path, &name, skipped_symbols) {
                    properties.push(prop);
                }
            }
            _ => {}
        }
        EntityVisitResult::Continue
    });

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Protocol {
        name,
        inherits,
        required_methods,
        optional_methods,
        properties,
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
    })
}

// ---------------------------------------------------------------------------
// Category extraction
// ---------------------------------------------------------------------------

fn extract_category(
    entity: &Entity<'_>,
    sdk_path: &Path,
    framework_name: &str,
    category_methods: &mut HashMap<String, Vec<ir::CategoryGroup>>,
    category_properties: &mut HashMap<String, Vec<ir::Property>>,
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
) {
    // Get the class this category extends
    let class_name = entity
        .get_children()
        .iter()
        .find(|c| c.get_kind() == EntityKind::ObjCClassRef)
        .and_then(|c| c.get_name());

    let class_name = match class_name {
        Some(name) => name,
        None => return,
    };

    let category_name = entity.get_name().unwrap_or_default();

    let mut methods = Vec::new();
    let mut properties = Vec::new();
    entity.visit_children(|child, _parent| {
        match child.get_kind() {
            EntityKind::ObjCInstanceMethodDecl | EntityKind::ObjCClassMethodDecl => {
                if let Some(method) = extract_method(&child, sdk_path, &class_name, skipped_symbols)
                {
                    methods.push(method);
                }
            }
            EntityKind::ObjCPropertyDecl => {
                if let Some(prop) = extract_property(&child, sdk_path, &class_name, skipped_symbols)
                {
                    properties.push(prop);
                }
            }
            _ => {}
        }
        EntityVisitResult::Continue
    });

    if !methods.is_empty() {
        let group = ir::CategoryGroup {
            category: category_name,
            origin_framework: framework_name.to_string(),
            methods,
        };
        category_methods
            .entry(class_name.clone())
            .or_default()
            .push(group);
    }

    if !properties.is_empty() {
        category_properties
            .entry(class_name)
            .or_default()
            .extend(properties);
    }
}

// ---------------------------------------------------------------------------
// Enum extraction
// ---------------------------------------------------------------------------

fn extract_enum(entity: &Entity<'_>, sdk_path: &Path) -> Option<ir::Enum> {
    let name = entity.get_name()?;

    let enum_clang_type = entity.get_enum_underlying_type()?;
    let enum_type = map_type(&enum_clang_type);

    // Pick signed vs unsigned interpretation per the underlying type.
    // libclang sign-extends top-bit-set values into the i64 component, so
    // for unsigned-backed enums (CF_ENUM(uint32_t, ...) etc.) the signed
    // component reports e.g. -2 for the bit pattern 0xFFFFFFFE. Reading
    // the u64 component instead and casting recovers the intended value.
    // The underlying type may be a typedef (NSUInteger → unsigned long),
    // so canonicalise before inspecting the kind.
    let underlying_kind = enum_clang_type.get_canonical_type().get_kind();
    let is_unsigned = is_unsigned_int_kind(underlying_kind);

    let mut values = Vec::new();
    entity.visit_children(|child, _parent| {
        if child.get_kind() == EntityKind::EnumConstantDecl {
            if let Some(val_name) = child.get_name() {
                if let Some((signed_val, unsigned_val)) = child.get_enum_constant_value() {
                    let value_opt = if is_unsigned {
                        if unsigned_val > i64::MAX as u64 {
                            // Top-bit-set u64 value — does not fit in i64.
                            // Skip rather than wrap silently; the IR schema
                            // stores i64 and we don't want a silent flip.
                            tracing::warn!(
                                enum_name = %name,
                                value_name = %val_name,
                                value = unsigned_val,
                                "enum constant exceeds i64 range; skipping"
                            );
                            None
                        } else {
                            Some(unsigned_val as i64)
                        }
                    } else {
                        Some(signed_val)
                    };
                    if let Some(value) = value_opt {
                        values.push(ir::EnumValue {
                            name: val_name,
                            value,
                        });
                    }
                }
            }
        }
        EntityVisitResult::Continue
    });

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Enum {
        name,
        enum_type,
        values,
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
    })
}

/// Returns true if a clang TypeKind is one of the unsigned integer kinds.
/// `CharU` covers platforms where plain `char` is unsigned; `UInt128` is
/// included for completeness even though no SDK enum uses it as an
/// underlying type.
fn is_unsigned_int_kind(kind: TypeKind) -> bool {
    matches!(
        kind,
        TypeKind::CharU
            | TypeKind::UChar
            | TypeKind::UShort
            | TypeKind::UInt
            | TypeKind::ULong
            | TypeKind::ULongLong
            | TypeKind::UInt128
    )
}

// ---------------------------------------------------------------------------
// Struct extraction
// ---------------------------------------------------------------------------

fn extract_struct(entity: &Entity<'_>, sdk_path: &Path) -> Option<ir::Struct> {
    let name = entity.get_name()?;

    let mut fields = Vec::new();
    entity.visit_children(|child, _parent| {
        if child.get_kind() == EntityKind::FieldDecl {
            if let Some(field_name) = child.get_name() {
                if let Some(field_clang_type) = child.get_type() {
                    fields.push(ir::StructField {
                        name: field_name,
                        field_type: map_type(&field_clang_type),
                    });
                }
            }
        }
        EntityVisitResult::Continue
    });

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Struct {
        name,
        fields,
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
    })
}

// ---------------------------------------------------------------------------
// Function extraction
// ---------------------------------------------------------------------------

fn extract_function(
    entity: &Entity<'_>,
    sdk_path: &Path,
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
) -> Option<ir::Function> {
    let name = entity.get_name()?;

    // Skip compiler intrinsics and internal functions. These names are
    // reserved by the toolchain and are not part of the public API
    // surface; they never warrant an audit entry.
    if name.starts_with("__") || name.starts_with("_Block_") {
        return None;
    }

    // Skip declarations with non-external linkage (`static`, `static inline`).
    // They have no dylib symbol, so downstream `dlsym`-based bindings
    // would fail at runtime with `could not find export from foreign library`.
    if matches!(entity.get_linkage(), Some(Linkage::Internal)) {
        record_skip(
            skipped_symbols,
            name,
            "function",
            skipped_symbol_reason::INTERNAL_LINKAGE,
        );
        return None;
    }

    // Skip declarations explicitly marked unavailable on macOS — e.g.
    // `API_UNAVAILABLE(macos)` or visionOS-only symbols. These have
    // `Linkage::External` (so the check above does not catch them) but
    // no export in the macOS variant of the framework dylib, so `dlsym`
    // fails at runtime. See `filter_platform_unavailable.rs`.
    if is_unavailable_on_macos(entity) {
        record_skip(
            skipped_symbols,
            name,
            "function",
            skipped_symbol_reason::PLATFORM_UNAVAILABLE_MACOS,
        );
        return None;
    }

    let result_type = entity.get_result_type()?;
    let return_type = map_type(&result_type);

    let params = extract_params(entity);
    let variadic = entity.is_variadic();

    // Check if the function is declared as inline
    let inline = entity.is_inline_function();

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Function {
        name,
        params,
        return_type,
        inline,
        variadic,
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
    })
}

// ---------------------------------------------------------------------------
// Constant extraction
// ---------------------------------------------------------------------------

fn extract_constant(
    entity: &Entity<'_>,
    sdk_path: &Path,
    skipped_symbols: &mut Vec<ir::SkippedSymbol>,
) -> Option<ir::Constant> {
    let name = entity.get_name()?;

    // Skip internal/private constants — toolchain-reserved names, never
    // part of the public API surface.
    if name.starts_with("__") {
        return None;
    }

    // Skip declarations with non-external linkage (`static const`). They
    // are inlined at use sites and have no dylib symbol, so downstream
    // `dlsym`-based bindings would fail at runtime with
    // `could not find export from foreign library`.
    //
    // Note: preprocessor `#define` macros arrive as `EntityKind::MacroDefinition`
    // cursors, not `VarDecl`, so they never reach this function. They are
    // filtered in `extract-swift/src/declaration_mapping.rs` instead, where
    // `swift-api-digester` surfaces clang-imported macros as `Var` nodes with
    // `c:@macro@…` USRs — see `non_c_linkable_skip_reason`.
    if matches!(entity.get_linkage(), Some(Linkage::Internal)) {
        record_skip(
            skipped_symbols,
            name,
            "constant",
            skipped_symbol_reason::INTERNAL_LINKAGE,
        );
        return None;
    }

    // Skip declarations explicitly marked unavailable on macOS — e.g.
    // `API_UNAVAILABLE(macos)` on a visionOS-only `extern const`. These
    // have `Linkage::External` but no export in the macOS variant of
    // the framework dylib. See `filter_platform_unavailable.rs` and the
    // AudioToolbox `kAudioServicesDetailIntendedSpatialExperience` case.
    if is_unavailable_on_macos(entity) {
        record_skip(
            skipped_symbols,
            name,
            "constant",
            skipped_symbol_reason::PLATFORM_UNAVAILABLE_MACOS,
        );
        return None;
    }

    let constant_clang_type = entity.get_type()?;
    let constant_type = map_type(&constant_clang_type);

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Constant {
        name,
        constant_type,
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
        macro_value: None,
    })
}

// ---------------------------------------------------------------------------
// CFSTR macro constant extraction
// ---------------------------------------------------------------------------

/// Extract a CFSTR macro constant from a `MacroDefinition` entity.
///
/// Matches the pattern `#define kFoo CFSTR("literal")` by tokenizing the
/// macro's source range and looking for the `CFSTR ( "..." )` token sequence.
/// Returns `None` for non-CFSTR macros (function-like macros, non-matching
/// expansions, etc.).
fn extract_cfstr_macro_constant(entity: &Entity<'_>, sdk_path: &Path) -> Option<ir::Constant> {
    let name = entity.get_name()?;

    // Skip private/reserved names
    if name.starts_with("__") {
        return None;
    }

    // Only object-like macros — CFSTR("...") is not a function-like macro
    if entity.is_function_like_macro() {
        return None;
    }

    let range = entity.get_range()?;
    let tokens = range.tokenize();
    let string_value = extract_cfstr_value_from_tokens(&tokens)?;

    let provenance = extract_provenance(entity, sdk_path);
    let doc_refs = extract_doc_refs(entity);

    Some(ir::Constant {
        name,
        // CFSTR returns CFStringRef (toll-free bridged with NSString).
        // Marked nullable because CFStringCreateWithCString can technically
        // return NULL, though it won't for valid UTF-8 literals.
        constant_type: TypeRef {
            nullable: true,
            kind: TypeRefKind::Id,
        },
        source: Some(DeclarationSource::ObjcHeader),
        provenance: Some(provenance),
        doc_refs: Some(doc_refs),
        macro_value: Some(string_value),
    })
}

/// Parse a CFSTR("literal") pattern from macro definition tokens.
///
/// The token sequence for `#define kFoo CFSTR("Bar")` is typically:
/// `kFoo` `CFSTR` `(` `"Bar"` `)` — the `#define` keyword is not a token
/// in the entity's range, but the macro name is.
fn extract_cfstr_value_from_tokens(tokens: &[clang::token::Token<'_>]) -> Option<String> {
    for window in tokens.windows(4) {
        if window[0].get_spelling() == "CFSTR"
            && window[1].get_spelling() == "("
            && window[2].get_kind() == clang::token::TokenKind::Literal
            && window[3].get_spelling() == ")"
        {
            let literal = window[2].get_spelling();
            // Strip surrounding double quotes from the C string literal
            let trimmed = literal.strip_prefix('"')?.strip_suffix('"')?;
            return Some(trimmed.to_string());
        }
    }
    None
}

// ---------------------------------------------------------------------------
// Provenance and documentation
// ---------------------------------------------------------------------------

/// Extract source provenance from a libclang cursor.
fn extract_provenance(entity: &Entity<'_>, sdk_path: &Path) -> SourceProvenance {
    let location = entity.get_location();
    let (header, line) = match location {
        Some(loc) => {
            let file_loc = loc.get_file_location();
            let header = file_loc.file.map(|f| {
                let path = f.get_path();
                // Make header path relative to SDK
                path.strip_prefix(sdk_path)
                    .unwrap_or(&path)
                    .to_string_lossy()
                    .to_string()
            });
            let line = Some(file_loc.line);
            (header, line)
        }
        None => (None, None),
    };

    let availability = extract_availability(entity);

    SourceProvenance {
        header,
        line,
        availability,
    }
}

/// Return true if the declaration is explicitly marked unavailable on
/// macOS via a clang availability attribute (`API_UNAVAILABLE(macos)`
/// or `__attribute__((availability(macos, unavailable)))`).
///
/// Declarations in this state have `Linkage::External` — they look like
/// normal exported symbols — but the macOS variant of the framework
/// dylib does not actually export them. They live in a sibling platform
/// dylib (visionOS, iOS, etc.). Any `dlsym`-based FFI target that
/// references the symbol dies at load time with
/// `could not find export from foreign library`.
///
/// The authoritative source is libclang's `PlatformAvailability` table
/// (via `get_platform_availability()`); clang records both `"macos"`
/// and the legacy `"macosx"` platform spelling, so check both. Missing
/// availability metadata is treated as "available by default" — the
/// absence of an entry for macos is not evidence of unavailability.
fn is_unavailable_on_macos(entity: &Entity<'_>) -> bool {
    let Some(platforms) = entity.get_platform_availability() else {
        return false;
    };
    platforms
        .iter()
        .any(|p| (p.platform == "macos" || p.platform == "macosx") && p.unavailable)
}

/// Extract availability attributes from a declaration.
fn extract_availability(entity: &Entity<'_>) -> Option<Availability> {
    let platforms = entity.get_platform_availability()?;

    // Look for macOS platform availability
    for platform in &platforms {
        if platform.platform == "macos" || platform.platform == "macosx" {
            let format_version = |v: clang::Version| match v.y {
                Some(y) => format!("{}.{}", v.x, y),
                None => format!("{}", v.x),
            };
            return Some(Availability {
                introduced: platform.introduced.map(&format_version),
                deprecated: platform.deprecated.map(&format_version),
            });
        }
    }

    None
}

/// Extract documentation references from a declaration.
fn extract_doc_refs(entity: &Entity<'_>) -> DocRefs {
    let header_comment = safe_get_comment_brief(entity);
    let usr = entity.get_usr().map(|u| u.0);
    let apple_doc_url = usr.as_ref().and_then(|u| construct_apple_doc_url(u));

    DocRefs {
        header_comment,
        apple_doc_url,
        usr,
    }
}

/// `Entity::get_comment_brief` in clang-2.0.0 calls
/// `CStr::to_str().expect("invalid Rust string")` on whatever libclang
/// hands back for the brief comment. Some Quartz-subframework cursors
/// produce a ~22-byte prefix plus a non-UTF-8 tail byte (a stray byte
/// from a miscoded character in a doc comment) and abort the whole
/// walker, because the normal unwinding panic crosses an `extern "C"`
/// boundary one frame above and converts to a process abort. Catching
/// the panic here keeps the unwind inside Rust territory so the visitor
/// can continue with the next entity; the only loss is the doc comment
/// for the offending declaration, which is advisory rather than
/// load-bearing. Rejecting whole entities would be worse — we'd silently
/// drop API surface we are allowed to extract.
fn safe_get_comment_brief(entity: &Entity<'_>) -> Option<String> {
    let result = catch_clang_utf8_panic(|| entity.get_comment_brief());
    if result.is_none() {
        tracing::debug!(
            entity_kind = ?entity.get_kind(),
            name = ?entity.get_name(),
            "dropping doc comment: clang returned non-UTF-8 CXString from clang_Cursor_getBriefCommentText"
        );
    }
    result.flatten()
}

/// Run `f` with a catch for the `invalid Rust string` panic that
/// clang-2.0.0 raises on non-UTF-8 `CXString` values. Returns `None` if
/// the closure panicked. The outer `Option` distinguishes "panicked"
/// (`None`) from "returned None" (`Some(None)`); `safe_get_comment_brief`
/// flattens the nested option because both mean "no comment available".
///
/// Must be used inside the visitor callback. Any panic that reaches
/// clang_sys's `extern "C" fn visit` is converted to a process abort —
/// catching earlier keeps traversal alive.
fn catch_clang_utf8_panic<T, F: FnOnce() -> T>(f: F) -> Option<T> {
    std::panic::catch_unwind(std::panic::AssertUnwindSafe(f)).ok()
}

/// Construct an Apple developer documentation URL from a USR.
///
/// The USR format for ObjC is like: `c:objc(cs)NSString(im)initWithString:`
/// We map this to: `https://developer.apple.com/documentation/foundation/nsstring/1497402-initwithstring`
///
/// Note: We construct a best-effort URL. The actual URL may differ due to
/// Apple's documentation routing. The USR itself is the stable identifier.
fn construct_apple_doc_url(usr: &str) -> Option<String> {
    // For now, store USR as the primary identifier.
    // Apple doc URL construction requires knowledge of the documentation
    // slug mapping, which we can build incrementally.
    // A basic heuristic: class-level USRs like `c:objc(cs)NSString`
    let rest = usr.strip_prefix("c:objc(cs)")?;
    // Extract class name
    let class_name = match rest.find('(') {
        Some(paren_pos) => &rest[..paren_pos],
        None => rest,
    };
    Some(format!(
        "https://developer.apple.com/documentation/foundation/{}",
        class_name.to_lowercase()
    ))
}

// ---------------------------------------------------------------------------
// Framework filtering
// ---------------------------------------------------------------------------

/// Check if an entity originates from the target framework's headers.
fn is_from_framework(entity: &Entity<'_>, framework_name: &str, sdk_path: &Path) -> bool {
    let location = match entity.get_location() {
        Some(loc) => loc,
        None => return false,
    };

    let file_loc = location.get_file_location();
    let file = match file_loc.file {
        Some(f) => f,
        None => return false,
    };

    let path = file.get_path();
    let relative = path.strip_prefix(sdk_path).unwrap_or(&path);
    let path_str = relative.to_string_lossy();

    // Match declarations from this framework's headers.
    //
    // Primary pattern: System/Library/Frameworks/{Name}.framework/Headers/
    //
    // Umbrella frameworks on the allowlist also accept declarations from
    // their nested subframeworks, so that real subframeworks with no
    // top-level counterpart (e.g. HIServices inside ApplicationServices)
    // get extracted as part of the parent. libclang canonicalises paths
    // for symlinked subframeworks (CoreGraphics, CoreText inside
    // ApplicationServices) to their top-level locations, so they are
    // not double-counted.
    //
    // The allowlist is narrow because some umbrella subframeworks (e.g.
    // certain Quartz children) trip a UTF-8 panic in the external clang
    // crate's string handling. Only frameworks whose subframeworks are
    // needed downstream AND extract cleanly are listed here.
    let own_headers_prefix =
        format!("System/Library/Frameworks/{framework_name}.framework/Headers/");
    if path_str.starts_with(&own_headers_prefix) {
        return true;
    }
    const SUBFRAMEWORK_ALLOWLIST: &[&str] = &["ApplicationServices"];
    if SUBFRAMEWORK_ALLOWLIST.contains(&framework_name) {
        let framework_root = format!("System/Library/Frameworks/{framework_name}.framework/");
        if path_str.starts_with(&framework_root) && path_str.contains("/Headers/") {
            return true;
        }
    }
    // Synthetic pseudo-framework: libdispatch matches headers under
    // {SDK}/usr/include/dispatch/ and the pthread_*_np symbols under
    // {SDK}/usr/include/pthread.h and /pthread/*.h.
    if framework_name == "libdispatch"
        && (path_str.starts_with("usr/include/dispatch/")
            || path_str == "usr/include/pthread.h"
            || path_str.starts_with("usr/include/pthread/"))
    {
        return true;
    }
    false
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn catch_clang_utf8_panic_returns_none_when_closure_panics() {
        // Shape of the real panic: clang-2.0.0's `CStr::to_str().expect
        // ("invalid Rust string")` on a non-UTF-8 byte sequence. The
        // closure shape mirrors `safe_get_comment_brief`'s use — no
        // inputs, returns T, panics are converted to None by the helper.
        let got: Option<&str> = catch_clang_utf8_panic(|| {
            panic!("invalid Rust string");
        });
        assert!(got.is_none());
    }

    #[test]
    fn catch_clang_utf8_panic_passes_through_successful_return() {
        let got = catch_clang_utf8_panic(|| 42);
        assert_eq!(got, Some(42));
    }

    #[test]
    fn catch_clang_utf8_panic_preserves_option_returns() {
        let none_case: Option<Option<&str>> = catch_clang_utf8_panic(|| None);
        assert_eq!(none_case, Some(None));

        let some_case: Option<Option<&str>> = catch_clang_utf8_panic(|| Some("hi"));
        assert_eq!(some_case, Some(Some("hi")));
    }

    #[test]
    fn line_carries_main_actor_matches_macro_spellings() {
        assert!(line_carries_main_actor("NS_SWIFT_UI_ACTOR"));
        assert!(line_carries_main_actor("NS_SWIFT_MAIN_ACTOR"));
        // Framework-prefixed aliases that all expand to swift_attr("@MainActor")
        assert!(line_carries_main_actor("WK_SWIFT_UI_ACTOR"));
        assert!(line_carries_main_actor("CF_SWIFT_MAIN_ACTOR"));
        assert!(line_carries_main_actor("MP_SWIFT_MAIN_ACTOR"));
        assert!(line_carries_main_actor(
            "__attribute__((swift_attr(\"@MainActor\")))"
        ));
    }

    #[test]
    fn line_carries_main_actor_ignores_unrelated_swift_attrs() {
        // `swift_name` is a different attribute with similar spelling.
        assert!(!line_carries_main_actor("NS_SWIFT_NAME(UndoManager)"));
        // A doc comment that mentions `@MainActor` must not match.
        assert!(!line_carries_main_actor("/// Use on @MainActor only."));
        // `swift_attr` with a different value must not match.
        assert!(!line_carries_main_actor(
            "__attribute__((swift_attr(\"@objc\")))"
        ));
        // The umbrella header line that *defines* the alias must not match —
        // otherwise the macro definition self-triggers on the framework
        // header that introduces the alias.
        assert!(!line_carries_main_actor(
            "#define WK_SWIFT_UI_ACTOR NS_SWIFT_UI_ACTOR"
        ));
        assert!(!line_carries_main_actor("#define WK_SWIFT_UI_ACTOR"));
        // A different suffix that resembles the actor pattern must not match.
        assert!(!line_carries_main_actor("FOO_SWIFT_UI_ACTOR_HELPER"));
    }

    #[test]
    fn line_is_decl_boundary_recognises_decl_terminators() {
        assert!(line_is_decl_boundary("@end"));
        assert!(line_is_decl_boundary("};"));
        assert!(line_is_decl_boundary("static const NSUInteger Foo = 1;"));
        assert!(line_is_decl_boundary("#import <Foundation/Foundation.h>"));
        assert!(line_is_decl_boundary("#endif"));
        assert!(line_is_decl_boundary("@class NSDate;"));
    }

    #[test]
    fn line_is_decl_boundary_skips_attribute_lines() {
        assert!(!line_is_decl_boundary("NS_SWIFT_UI_ACTOR"));
        assert!(!line_is_decl_boundary(
            "API_AVAILABLE(macos(10.0), ios(3.0))"
        ));
        assert!(!line_is_decl_boundary(""));
        assert!(!line_is_decl_boundary("// trailing line comment"));
    }
}
