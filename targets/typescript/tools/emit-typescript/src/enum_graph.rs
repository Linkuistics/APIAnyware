//! The cross-framework **enum** ownership registry + the enum→module resolver — the
//! enum analogue of [`crate::class_graph`]'s `ClassRegistry`/`ClassModuleResolver`
//! (ADR-0055 §6, the second half: an enum *at its use site*).
//!
//! An `NS_ENUM`/`NS_OPTIONS` alias in a method/property signature (`NSComparisonResult`,
//! `TKAlignment`) must render as the **TS `enum` type name**, not the safe fallback
//! `number` ([`crate::ffi_type_mapping`]). Two facts drive that, both **pure and
//! IR-only**, and both mirror the class machinery:
//!
//! 1. **Recognition** — is a given `Alias` name a known enum at all? The context-free
//!    mapper cannot tell an enum typedef from a scalar typedef, so it is handed a
//!    **known-enum set** ([`EnumModuleResolver::known_enums`]): the union of every enum
//!    the cross-framework [`EnumRegistry`] owns and the framework-being-emitted's own
//!    *emittable* enums (so an unconfigured, single-framework emitter still recognises
//!    its own enums — the same-framework seeding [`crate::class_graph::build_class_graph`]
//!    gets from `local`). Only names it can **prove** are enums are upgraded; every other
//!    alias still falls through to `number`.
//! 2. **Module resolution** — where is that enum imported from? A same-framework enum
//!    re-exports through the framework's own barrel (`@apianyware/<fw>`); a
//!    cross-framework enum through its owner's ([`EnumModuleResolver::module_for`], via
//!    the [`EnumRegistry`]). Unlike a class, an enum has **no runtime-owned root**
//!    (there is no enum analogue of `NSObject`), so the resolver has no `RUNTIME_MODULE`
//!    special case — every enum lives in some framework's `enums.ts`.
//!
//! The registry is empty by default ([`EnumRegistry::new`]) — same-framework enums still
//! resolve from the framework's own enum set (recognition) and fall back to the current
//! framework (module) — so an unconfigured emitter still upgrades its own enums and
//! produces self-consistent imports. The Step-5 generate CLI pre-pass builds the global
//! registry over every loaded framework and threads it in (the whole-program shape the
//! [`EnumRegistry`] shares with [`crate::class_graph::ClassRegistry`]).

use std::collections::{BTreeSet, HashMap};
use std::sync::Arc;

use apianyware_types::ir::Framework;

use crate::emit_enums::is_emittable_enum;
use crate::naming::module_specifier;

/// Maps an ObjC enum tag name to the lowercase directory of the framework that **owns**
/// (declares) it, for resolving cross-framework enum references and their import paths.
///
/// The per-framework emitter only sees one framework, so it cannot place an enum type
/// that lives elsewhere. This registry is the seam: the Step-5 CLI pre-pass builds it
/// once over every loaded framework and threads it in (the sbcl / gerbil whole-program
/// shape, mirroring [`ClassRegistry`](crate::class_graph::ClassRegistry)). Only
/// **emittable** enums (valid TS-identifier names — anonymous synthetic-named enums are
/// skipped, [`crate::emit_enums`]) are owned, so a name in the registry is always a real
/// TS `enum` type. Empty by default — same-framework enums still resolve from the
/// framework's own enum set — so an unconfigured emitter still produces a self-consistent
/// tree.
#[derive(Debug, Clone, Default)]
pub struct EnumRegistry {
    owners: HashMap<String, String>,
}

impl EnumRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    /// Build the global enum→owning-framework map across every loaded framework. First
    /// framework to declare an emittable enum owns it (matches the dependency-ordered
    /// load: a base framework is seen before its dependents).
    pub fn from_frameworks(frameworks: &[Framework]) -> Self {
        let refs: Vec<&Framework> = frameworks.iter().collect();
        Self::from_framework_refs(&refs)
    }

    /// Like [`Self::from_frameworks`] but over borrowed frameworks — the shape the
    /// generate pipeline already holds (`ordered_frameworks: Vec<&Framework>`), so the
    /// CLI pre-pass builds the registry without cloning every framework.
    pub fn from_framework_refs(frameworks: &[&Framework]) -> Self {
        let mut owners = HashMap::new();
        for fw in frameworks {
            let fw_low = fw.name.to_ascii_lowercase();
            for en in fw.enums.iter().filter(|en| is_emittable_enum(en)) {
                owners
                    .entry(en.name.clone())
                    .or_insert_with(|| fw_low.clone());
            }
        }
        Self { owners }
    }

    /// Register one enum→framework ownership (test helper / incremental build).
    pub fn insert(&mut self, enum_name: impl Into<String>, framework_low: impl Into<String>) {
        self.owners.insert(enum_name.into(), framework_low.into());
    }

    /// The lowercase framework dir that owns `enum_name`, if known.
    pub fn owner(&self, enum_name: &str) -> Option<&str> {
        self.owners.get(enum_name).map(String::as_str)
    }

    /// Every owned enum name (deterministically sorted), for seeding the mapper's
    /// recognition set alongside the current framework's own enums.
    pub fn names(&self) -> BTreeSet<String> {
        self.owners.keys().cloned().collect()
    }
}

/// Resolves the **module specifier** a referenced enum type is imported from, and
/// carries the **known-enum recognition set** the type mapper is built against — the
/// enum counterpart of [`crate::class_graph::ClassModuleResolver`] (ADR-0055 §6).
///
/// - a same-framework enum → the **current framework's** module (`@apianyware/<fw>`,
///   its barrel re-exports `./enums`), the same-framework fallback;
/// - an enum the [`EnumRegistry`] owns → its owning `@apianyware/<fw>` package
///   ([`module_specifier`]).
///
/// There is no runtime-root special case (an enum has no `NSObject` analogue); an
/// unresolvable name degrades to the current framework, exactly like the class resolver.
#[derive(Debug, Clone)]
pub struct EnumModuleResolver<'a> {
    framework: String,
    registry: &'a EnumRegistry,
    /// The union of the registry's owned enums and the current framework's own emittable
    /// enums — the names the mapper upgrades `Alias` → enum type. Shared cheaply
    /// (`Arc`) so the per-class/per-protocol mappers are built without cloning the set.
    known: Arc<BTreeSet<String>>,
}

impl<'a> EnumModuleResolver<'a> {
    /// A resolver for the framework currently being emitted, backed by the cross-framework
    /// ownership registry and the pre-computed recognition set (registry names ∪ the
    /// current framework's own emittable enums — [`crate::emit_framework`] builds it).
    pub fn new(framework: &str, registry: &'a EnumRegistry, known: Arc<BTreeSet<String>>) -> Self {
        Self {
            framework: framework.to_string(),
            registry,
            known,
        }
    }

    /// The display name of the framework being emitted — the same-framework fallback
    /// module ([`Self::module_for`]).
    pub fn framework(&self) -> &str {
        &self.framework
    }

    /// The module specifier `enum_name` is imported from (module doc): its owning
    /// `@apianyware/<fw>` package when the registry knows it, else the current framework's
    /// package (a same-framework enum re-exports through its own barrel).
    pub fn module_for(&self, enum_name: &str) -> String {
        match self.registry.owner(enum_name) {
            Some(fw_low) => module_specifier(fw_low),
            None => module_specifier(&self.framework),
        }
    }

    /// The recognition set the [`crate::ffi_type_mapping::TsFfiTypeMapper`] is built from
    /// (a cheap `Arc` clone per emitter). Membership means a proven enum → the mapper
    /// upgrades the alias to its enum type name.
    pub fn known_enums(&self) -> Arc<BTreeSet<String>> {
        Arc::clone(&self.known)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Enum, EnumValue};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};

    fn en(name: &str) -> Enum {
        Enum {
            name: name.into(),
            enum_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".into(),
                },
            },
            values: vec![EnumValue {
                name: format!("{name}First"),
                value: 0,
            }],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    fn fw(name: &str, enums: Vec<Enum>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums,
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    fn set(names: &[&str]) -> Arc<BTreeSet<String>> {
        Arc::new(names.iter().map(|s| s.to_string()).collect())
    }

    // --- the registry ---------------------------------------------------------------

    #[test]
    fn from_frameworks_first_owner_wins_and_skips_anonymous() {
        // An anonymous (synthetic-named) enum is not a valid TS identifier, so it is not
        // owned — its values belong to the constants surface, not a garbage-named enum.
        let foundation = fw(
            "Foundation",
            vec![en("NSComparisonResult"), en("enum (unnamed at Foo.h:1:1)")],
        );
        let appkit = fw("AppKit", vec![en("NSCellType"), en("NSComparisonResult")]);
        let reg = EnumRegistry::from_frameworks(&[foundation, appkit]);
        assert_eq!(reg.owner("NSComparisonResult"), Some("foundation"));
        assert_eq!(reg.owner("NSCellType"), Some("appkit"));
        assert_eq!(reg.owner("enum (unnamed at Foo.h:1:1)"), None);
        assert_eq!(reg.owner("DoesNotExist"), None);
    }

    #[test]
    fn from_framework_refs_matches_owned_variant_and_exposes_names() {
        let foundation = fw("Foundation", vec![en("NSComparisonResult")]);
        let appkit = fw("AppKit", vec![en("NSCellType")]);
        let reg = EnumRegistry::from_framework_refs(&[&foundation, &appkit]);
        assert_eq!(reg.owner("NSComparisonResult"), Some("foundation"));
        assert_eq!(reg.owner("NSCellType"), Some("appkit"));
        // `names` returns the owned set, deterministically sorted.
        let names: Vec<String> = reg.names().into_iter().collect();
        assert_eq!(names, vec!["NSCellType", "NSComparisonResult"]);
    }

    // --- the enum→module resolver ----------------------------------------------------

    #[test]
    fn resolver_routes_a_same_framework_enum_to_its_own_module() {
        // Empty registry (unconfigured emitter): a same-framework enum falls back to the
        // current framework's package barrel (which re-exports ./enums).
        let reg = EnumRegistry::new();
        let r = EnumModuleResolver::new("Foundation", &reg, set(&["NSComparisonResult"]));
        assert_eq!(r.module_for("NSComparisonResult"), "@apianyware/foundation");
    }

    #[test]
    fn resolver_routes_a_cross_framework_enum_via_the_registry() {
        // A populated registry (the CLI pre-pass shape): an enum owned elsewhere routes to
        // that framework's module, even while emitting AppKit.
        let mut reg = EnumRegistry::new();
        reg.insert("NSComparisonResult", "foundation");
        let r = EnumModuleResolver::new("AppKit", &reg, set(&["NSComparisonResult"]));
        assert_eq!(r.module_for("NSComparisonResult"), "@apianyware/foundation");
    }

    #[test]
    fn resolver_falls_back_to_current_framework_for_an_unknown_enum() {
        // An enum not registry-owned degrades to the current framework — the resolver
        // analogue of the class same-framework-gap rule.
        let mut reg = EnumRegistry::new();
        reg.insert("NSComparisonResult", "foundation");
        let r = EnumModuleResolver::new("AppKit", &reg, set(&["NSCellType"]));
        assert_eq!(r.module_for("NSCellType"), "@apianyware/appkit");
    }

    #[test]
    fn resolver_carries_the_recognition_set() {
        let reg = EnumRegistry::new();
        let known = set(&["TKAlignment", "TKKeyMask"]);
        let r = EnumModuleResolver::new("TestKit", &reg, Arc::clone(&known));
        assert_eq!(r.framework(), "TestKit");
        assert_eq!(*r.known_enums(), *known);
    }
}
