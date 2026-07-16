//! The cross-framework **protocol** ownership registry + the protocol→module resolver —
//! the protocol analogue of [`crate::class_graph`]'s `ClassRegistry`/`ClassModuleResolver`
//! and [`crate::enum_graph`]'s `EnumRegistry`/`EnumModuleResolver` (now the **third** copy
//! of the ownership-registry family), realising the conforming-class half of ADR-0055 §4.
//!
//! Two protocol *use* sites need to place a protocol interface by name — and the
//! per-framework emitter only sees one framework, so neither can be resolved locally:
//!
//! 1. **A class `implements` clause** — `class NSTableView extends NSView implements
//!    NSTableViewDelegate` ([`crate::class_surface`]). The conformed protocol names live in
//!    `Class.protocols`; each emittable one imports its interface **type-only** from its
//!    owning module.
//! 2. **A cross-framework protocol `extends`** — a protocol inheriting one owned by another
//!    framework (the near-universal `<NSObject>` / `<NSCopying>` case), which
//!    [`crate::emit_protocol`] dropped from `extends` until this registry landed.
//!
//! Both mirror the enum machinery exactly, and both facts are **pure and IR-only**:
//!
//! - **Recognition** — is a given name an *emittable* protocol at all?
//!   [`ProtocolModuleResolver::is_known`] answers it against the recognition set (the
//!   registry's owned protocols ∪ the framework-being-emitted's own *emittable* protocols); a
//!   name not in the set contributes no `implements` and no cross-framework `extends` (the
//!   blessed degradation — a marker/unresolvable protocol is silently omitted, exactly as the
//!   enum resolver degrades an unproven alias to `number`).
//! - **Module resolution** — where is that interface imported from? A same-framework
//!   protocol re-exports through the framework's own barrel (`@apianyware/<fw>`), a
//!   cross-framework one through its owner's ([`ProtocolModuleResolver::module_for`]). Like
//!   an enum (and unlike a class), a protocol has **no runtime-owned root** — there is no
//!   `NSObject`-in-the-runtime analogue for an interface — so the resolver has no
//!   `RUNTIME_MODULE` special case; every protocol lives in some framework's `protocols.ts`.
//!
//! The registry owns only **emittable** protocols
//! ([`crate::emit_protocol::transitively_emittable_protocols`]: a valid TS-identifier name with a
//! bindable interface surface, own or transitively inherited via `inherits` — ADR-0055 §4b), so a
//! name in the registry is always a real TS `interface`. Empty by default
//! ([`ProtocolRegistry::new`]) — a
//! same-framework protocol still recognises from the framework's own protocol set and falls
//! back to the current framework — so an unconfigured, single-framework emitter still emits
//! its own conformances and produces self-consistent imports. The Step-5 generate CLI
//! pre-pass builds the global registry over every loaded framework and threads it in (the
//! whole-program shape shared with [`crate::class_graph::ClassRegistry`] and
//! [`crate::enum_graph::EnumRegistry`]).
//!
//! ## Conformed-protocol required-method flattening (`protocol-required-method-flattening-k102`)
//!
//! The registry also backs [`crate::class_surface::bound_methods`]'s protocol-conformance
//! flattening — the TS analogue of gerbil's `ProtocolRegistry` method flattening
//! (`CONTEXT.md` "Conformed-protocol method flattening"). ObjC lets a class declare
//! `<Protocol>` conformance without redeclaring the protocol's required members in its own
//! header (`NSURL <NSCoding>` never restates `encodeWithCoder:`) — real, working methods the
//! resolve phase already flattens onto `Class::all_methods` (origin = the declaring
//! protocol), which `bound_methods` was not reading.
//!
//! [`Self::conformance_closure`] carries each owned protocol's `inherits` edges (so
//! conforming to `NSSecureCoding` pulls in `NSCoding`'s methods too) and
//! [`Self::is_required_method`] carries each owned protocol's `required_methods` selector
//! set — flattening reads **only** `required_methods` (never `optional_methods`: an optional
//! member is not guaranteed implemented by every conformer, so promising it as an
//! always-present, always-safe-to-call member would be dishonest, a real "does not respond
//! to selector" risk at runtime).
//!
//! The closure is keyed on **this class's own** direct `Class.protocols` list (not the whole
//! ancestor chain's): a subclass whose own header does not restate a protocol its ancestor
//! conforms to gets an empty closure for it, so it correctly defers to whichever ancestor
//! *does* restate it — the ancestor flattens once, the subclass inherits via `extends`,
//! exactly the mechanism that lets `bound_methods` stay a per-class, non-accumulating
//! frontier (k57's "own methods ride `extends`" discipline, `crate::subclass_surface`).

use std::collections::{BTreeSet, HashMap, HashSet};
use std::sync::Arc;

use apianyware_types::ir::Framework;

use crate::class_graph::{declared_classes, RUNTIME_ROOT};
use crate::emit_protocol::transitively_emittable_protocols;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::naming::module_specifier;

/// Maps an ObjC protocol name to the lowercase directory of the framework that **owns**
/// (declares) it, for resolving a conformed / inherited protocol's owning module and its
/// import path.
///
/// The per-framework emitter only sees one framework, so it cannot place a protocol
/// interface that lives elsewhere. This registry is the seam: the Step-5 CLI pre-pass builds
/// it once over every loaded framework and threads it in (the sbcl / gerbil whole-program
/// shape, mirroring [`ClassRegistry`](crate::class_graph::ClassRegistry) and
/// [`EnumRegistry`](crate::enum_graph::EnumRegistry)). Only **emittable** protocols (a valid
/// TS-identifier name with a bindable surface — empty markers and non-identifier names are
/// skipped, [`crate::emit_protocol`]) are owned, so a name in the registry is always a real
/// TS `interface`. Empty by default — same-framework protocols still resolve from the
/// framework's own protocol set — so an unconfigured emitter still produces a self-consistent
/// tree.
#[derive(Debug, Clone, Default)]
pub struct ProtocolRegistry {
    owners: HashMap<String, String>,
    /// Protocol → the protocols it `inherits` from (its own emittable ones), for
    /// [`Self::conformance_closure`].
    inherits: HashMap<String, Vec<String>>,
    /// Protocol → the `(selector, is_class_method)` keys of its `required_methods` (never
    /// `optional_methods`), for [`Self::is_required_method`].
    required: HashMap<String, HashSet<(String, bool)>>,
}

impl ProtocolRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    /// Build the global protocol→owning-framework map across every loaded framework. First
    /// framework to declare an emittable protocol owns it (matches the dependency-ordered
    /// load: a base framework is seen before its dependents).
    pub fn from_frameworks(frameworks: &[Framework]) -> Self {
        let refs: Vec<&Framework> = frameworks.iter().collect();
        Self::from_framework_refs(&refs)
    }

    /// Like [`Self::from_frameworks`] but over borrowed frameworks — the shape the generate
    /// pipeline already holds (`ordered_frameworks: Vec<&Framework>`), so the CLI pre-pass
    /// builds the registry without cloning every framework.
    pub fn from_framework_refs(frameworks: &[&Framework]) -> Self {
        // Emittability runs the member frontier, which since k66 defers a member naming a Swift
        // nominal type — so it needs the whole-program class set, built here from the same
        // frameworks the CLI hands the emitters and the table collectors ([`declared_classes`]).
        // A protocol whose *only* members name Swift nominal types therefore owns nothing, and no
        // class `implements` it — the same interface set `render_protocol_bodies` emits.
        let mapper =
            TsFfiTypeMapper::with_known_classes(declared_classes(frameworks.iter().copied()));
        // The transitive fixed point (ADR-0055 §4b, `transitive-protocol-emittability-k106`)
        // needs every declared protocol's `inherits` edges **whole-program**, including ones
        // that fail their own `has_surface` on their own: `inherits` can cross framework
        // boundaries, so a protocol's bindable ancestor may be owned by a different framework
        // than the one that declares it — invisible to a per-framework-only computation.
        let emittable = transitively_emittable_protocols(
            frameworks.iter().flat_map(|fw| fw.protocols.iter()),
            &mapper,
        );
        let mut owners = HashMap::new();
        let mut inherits = HashMap::new();
        let mut required = HashMap::new();
        for fw in frameworks {
            let fw_low = fw.name.to_ascii_lowercase();
            for proto in fw.protocols.iter().filter(|p| emittable.contains(&p.name)) {
                owners
                    .entry(proto.name.clone())
                    .or_insert_with(|| fw_low.clone());
                inherits
                    .entry(proto.name.clone())
                    .or_insert_with(|| proto.inherits.clone());
                required.entry(proto.name.clone()).or_insert_with(|| {
                    proto
                        .required_methods
                        .iter()
                        .map(|m| (m.selector.clone(), m.class_method))
                        .collect::<HashSet<_>>()
                });
            }
        }
        Self {
            owners,
            inherits,
            required,
        }
    }

    /// Register one protocol→framework ownership (test helper / incremental build).
    pub fn insert(&mut self, protocol_name: impl Into<String>, framework_low: impl Into<String>) {
        self.owners
            .insert(protocol_name.into(), framework_low.into());
    }

    /// Register one protocol's `inherits` edges + required-method selector set (test helper /
    /// incremental build) — the flattening-relevant fields [`insert`](Self::insert) leaves out.
    pub fn insert_conformance(
        &mut self,
        protocol_name: impl Into<String>,
        inherits: Vec<String>,
        required: impl IntoIterator<Item = (String, bool)>,
    ) {
        let name = protocol_name.into();
        self.inherits.insert(name.clone(), inherits);
        self.required.insert(name, required.into_iter().collect());
    }

    /// The lowercase framework dir that owns `protocol_name`, if known.
    pub fn owner(&self, protocol_name: &str) -> Option<&str> {
        self.owners.get(protocol_name).map(String::as_str)
    }

    /// Every owned protocol name (deterministically sorted), for seeding the resolver's
    /// recognition set alongside the current framework's own emittable protocols.
    pub fn names(&self) -> BTreeSet<String> {
        self.owners.keys().cloned().collect()
    }

    /// The set of protocols whose **required** methods a class with direct conformance list
    /// `direct` (its own `Class.protocols`, never the ancestor chain's) should flatten: the
    /// closure of `direct` over `inherits` edges, restricted to registry-known (emittable)
    /// protocols, excluding the `NSObject` protocol (name-collides with the runtime-owned
    /// root class, which already owns that surface on every class via `extends` — mirrors
    /// gerbil's `ProtocolRegistry::conformance_closure`). Sorted for determinism.
    pub fn conformance_closure(&self, direct: &[String]) -> BTreeSet<String> {
        let mut out = BTreeSet::new();
        let mut stack: Vec<&str> = direct.iter().map(String::as_str).collect();
        while let Some(p) = stack.pop() {
            if p == RUNTIME_ROOT || out.contains(p) {
                continue;
            }
            let Some(parents) = self.inherits.get(p) else {
                continue; // unknown/unemittable protocol: no flattenable data — defer it
            };
            out.insert(p.to_string());
            stack.extend(parents.iter().map(String::as_str));
        }
        out
    }

    /// Whether `protocol_name` (an emittable, registry-known protocol) declares
    /// `(selector, is_class_method)` as a **required** member — never `optional_methods`
    /// (module doc). `false` for an unknown protocol name (no required-method data), which is
    /// also the correct answer for a class-name origin (an ancestor-inherited `all_methods`
    /// entry) that happens not to collide with a real protocol name.
    pub fn is_required_method(
        &self,
        protocol_name: &str,
        selector: &str,
        is_class_method: bool,
    ) -> bool {
        self.required
            .get(protocol_name)
            .is_some_and(|set| set.contains(&(selector.to_string(), is_class_method)))
    }
}

/// Resolves the **module specifier** a conformed / inherited protocol interface is imported
/// from, and carries the **known-protocol recognition set** the emitters gate `implements`
/// and cross-framework `extends` on — the protocol counterpart of
/// [`crate::enum_graph::EnumModuleResolver`] (ADR-0055 §4).
///
/// - a same-framework protocol → the **current framework's** module (`@apianyware/<fw>`,
///   its barrel re-exports `./protocols`), the same-framework fallback;
/// - a protocol the [`ProtocolRegistry`] owns → its owning `@apianyware/<fw>` package
///   ([`module_specifier`]).
///
/// There is no runtime-root special case (a protocol has no `NSObject` analogue); an
/// unresolvable name degrades to the current framework, exactly like the enum resolver.
#[derive(Debug, Clone)]
pub struct ProtocolModuleResolver<'a> {
    framework: String,
    registry: &'a ProtocolRegistry,
    /// The union of the registry's owned protocols and the current framework's own emittable
    /// protocols — the names the emitters treat as real interfaces (`implements` a class,
    /// join a cross-framework `extends`). Shared cheaply (`Arc`) so the per-class /
    /// per-framework use sites read it without cloning the set.
    known: Arc<BTreeSet<String>>,
}

impl<'a> ProtocolModuleResolver<'a> {
    /// A resolver for the framework currently being emitted, backed by the cross-framework
    /// ownership registry and the pre-computed recognition set (registry names ∪ the current
    /// framework's own emittable protocols — [`crate::emit_framework`] builds it).
    pub fn new(
        framework: &str,
        registry: &'a ProtocolRegistry,
        known: Arc<BTreeSet<String>>,
    ) -> Self {
        Self {
            framework: framework.to_string(),
            registry,
            known,
        }
    }

    /// The display name of the framework being emitted — the same-framework fallback module
    /// ([`Self::module_for`]).
    pub fn framework(&self) -> &str {
        &self.framework
    }

    /// The backing whole-program registry — so a caller already threading a resolver (the
    /// common case: [`crate::emit_class::render_class`], [`crate::emit_dts::render_dts`]) can
    /// reach [`ProtocolRegistry::conformance_closure`]/[`ProtocolRegistry::is_required_method`]
    /// for [`crate::class_surface::bound_methods`]'s protocol flattening without a second,
    /// independently-threaded parameter.
    pub fn registry(&self) -> &'a ProtocolRegistry {
        self.registry
    }

    /// Whether `protocol_name` is a proven emittable protocol — in the recognition set the
    /// resolver was built with. The single gate the class `implements` clause and the
    /// cross-framework `extends` read: a name not known is silently omitted (a marker /
    /// unresolvable protocol contributes nothing).
    pub fn is_known(&self, protocol_name: &str) -> bool {
        self.known.contains(protocol_name)
    }

    /// The recognition set itself, for building the protocol-aware [`TsFfiTypeMapper`] the
    /// emitters render from ([`TsFfiTypeMapper::with_known`]). Shared (`Arc`), so the per-class
    /// mappers do not clone it. It is the **same** set [`Self::is_known`] gates the `implements`
    /// clause on — which is precisely what makes the bind arm and the conformance clause admit the
    /// same calls (`protocol-binding-surface-k89`, [`crate::protocol_binding`]).
    pub fn known_protocols(&self) -> Arc<BTreeSet<String>> {
        Arc::clone(&self.known)
    }

    /// The lowercase framework dir that owns `protocol_name`, if the registry knows it — the
    /// cross-framework signal (a same-framework protocol is known via [`Self::is_known`] but
    /// not necessarily registry-owned in an unconfigured emitter).
    pub fn owner(&self, protocol_name: &str) -> Option<&str> {
        self.registry.owner(protocol_name)
    }

    /// The module specifier `protocol_name` is imported from (module doc): its owning
    /// `@apianyware/<fw>` package when the registry knows it, else the current framework's
    /// package (a same-framework protocol re-exports through its own barrel).
    pub fn module_for(&self, protocol_name: &str) -> String {
        match self.registry.owner(protocol_name) {
            Some(fw_low) => module_specifier(fw_low),
            None => module_specifier(&self.framework),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_types::ir::{Method, Protocol};
    use apianyware_types::type_ref::TypeRef;

    fn m(sel: &str) -> Method {
        Method {
            selector: sel.into(),
            class_method: false,
            init_method: false,
            params: vec![],
            return_type: TypeRef::void(),
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
            objc_exposed: true,
            swift_fn: None,
        }
    }

    /// An emittable protocol — a valid identifier name with one required member (a surface).
    fn proto(name: &str) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: vec![],
            required_methods: vec![m("go")],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    /// A pure marker protocol — no bindable surface, so not emittable and not owned.
    fn marker(name: &str) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    fn fw(name: &str, protocols: Vec<Protocol>) -> Framework {
        Framework {
            format_version: "1.0".into(),
            checkpoint: "resolved".into(),
            name: name.into(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols,
            enums: vec![],
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
    fn from_frameworks_first_owner_wins_and_skips_markers() {
        // A pure marker protocol has no surface → not emittable → not owned. First
        // framework to declare an emittable protocol owns it.
        let foundation = fw("Foundation", vec![proto("NSCopying"), marker("NSObject")]);
        let appkit = fw(
            "AppKit",
            vec![proto("NSTableViewDelegate"), proto("NSCopying")],
        );
        let reg = ProtocolRegistry::from_frameworks(&[foundation, appkit]);
        assert_eq!(reg.owner("NSCopying"), Some("foundation"));
        assert_eq!(reg.owner("NSTableViewDelegate"), Some("appkit"));
        assert_eq!(reg.owner("NSObject"), None, "marker protocol not owned");
        assert_eq!(reg.owner("DoesNotExist"), None);
    }

    #[test]
    fn from_framework_refs_matches_owned_variant_and_exposes_names() {
        let foundation = fw("Foundation", vec![proto("NSCopying")]);
        let appkit = fw("AppKit", vec![proto("NSTableViewDelegate")]);
        let reg = ProtocolRegistry::from_framework_refs(&[&foundation, &appkit]);
        assert_eq!(reg.owner("NSCopying"), Some("foundation"));
        assert_eq!(reg.owner("NSTableViewDelegate"), Some("appkit"));
        // `names` returns the owned set, deterministically sorted.
        let names: Vec<String> = reg.names().into_iter().collect();
        assert_eq!(names, vec!["NSCopying", "NSTableViewDelegate"]);
    }

    /// A pure-inheritance shell — no bindable surface of its own — `inherits`-ing `ancestor`.
    fn shell(name: &str, ancestor: &str) -> Protocol {
        Protocol {
            inherits: vec![ancestor.to_string()],
            ..marker(name)
        }
    }

    #[test]
    fn from_framework_refs_owns_a_protocol_transitively_emittable_via_a_same_framework_ancestor() {
        // transitive-protocol-emittability-k106 / ADR-0055 §4b — the real-corpus shape:
        // `NSMachPortDelegate` has no bindable surface of its own but inherits the
        // fully-bindable `NSPortDelegate`, both owned by Foundation.
        let foundation = fw(
            "Foundation",
            vec![
                shell("NSMachPortDelegate", "NSPortDelegate"),
                proto("NSPortDelegate"),
            ],
        );
        let reg = ProtocolRegistry::from_framework_refs(&[&foundation]);
        assert_eq!(
            reg.owner("NSMachPortDelegate"),
            Some("foundation"),
            "owned via its ancestor's surface, not a marker"
        );
    }

    #[test]
    fn from_framework_refs_owns_a_protocol_transitively_emittable_via_a_cross_framework_ancestor() {
        // `inherits` can cross framework boundaries (module doc) — the whole-program registry
        // must see past a per-framework-only view to resolve it, unlike the per-framework
        // same-framework fallback ([`crate::emit_protocol::transitively_emittable_protocols`]'s
        // own known scope limit).
        let shell_fw = fw("TestKit", vec![shell("TKCrossDelegate", "NSPortDelegate")]);
        let foundation = fw("Foundation", vec![proto("NSPortDelegate")]);
        let reg = ProtocolRegistry::from_framework_refs(&[&foundation, &shell_fw]);
        assert_eq!(reg.owner("TKCrossDelegate"), Some("testkit"));
    }

    #[test]
    fn from_framework_refs_leaves_a_pure_marker_chain_unowned() {
        // The negative control: an `inherits` edge alone proves nothing without a real surface
        // reachable through it.
        let foundation = fw(
            "Foundation",
            vec![
                shell("TKMarkerLeaf", "TKMarkerRoot"),
                marker("TKMarkerRoot"),
            ],
        );
        let reg = ProtocolRegistry::from_framework_refs(&[&foundation]);
        assert_eq!(reg.owner("TKMarkerLeaf"), None);
        assert_eq!(reg.owner("TKMarkerRoot"), None);
    }

    // --- conformance-closure / required-method flattening data ------------------------

    /// An emittable protocol carrying `inherits` + explicit required/optional members —
    /// the flattening-relevant fixture (`proto` above hard-codes a single required "go").
    fn proto_full(name: &str, inherits: &[&str], required: &[&str], optional: &[&str]) -> Protocol {
        Protocol {
            name: name.into(),
            inherits: inherits.iter().map(|s| s.to_string()).collect(),
            required_methods: required.iter().map(|s| m(s)).collect(),
            optional_methods: optional.iter().map(|s| m(s)).collect(),
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        }
    }

    #[test]
    fn conformance_closure_follows_protocol_inheritance() {
        // NSSecureCoding -> NSCoding: conforming to the child pulls in the parent, mirroring
        // gerbil's ProtocolRegistry::conformance_closure precedent.
        let foundation = fw(
            "Foundation",
            vec![
                proto_full(
                    "NSSecureCoding",
                    &["NSCoding"],
                    &["supportsSecureCoding"],
                    &[],
                ),
                proto_full(
                    "NSCoding",
                    &[],
                    &["encodeWithCoder:", "initWithCoder:"],
                    &[],
                ),
            ],
        );
        let reg = ProtocolRegistry::from_frameworks(&[foundation]);
        let closure = reg.conformance_closure(&["NSSecureCoding".to_string()]);
        assert!(closure.contains("NSSecureCoding"));
        assert!(closure.contains("NSCoding"));
        assert_eq!(closure.len(), 2);
    }

    #[test]
    fn conformance_closure_excludes_the_nsobject_protocol() {
        // Nearly every protocol inherits <NSObject>; it must never enter the closure — the
        // runtime-owned root class already owns that surface via `extends`.
        let foundation = fw(
            "Foundation",
            vec![proto_full(
                "SCNActionable",
                &["NSObject"],
                &["runAction:"],
                &[],
            )],
        );
        let reg = ProtocolRegistry::from_frameworks(&[foundation]);
        let closure = reg.conformance_closure(&["SCNActionable".to_string()]);
        assert!(closure.contains("SCNActionable"));
        assert!(!closure.contains("NSObject"));
    }

    #[test]
    fn conformance_closure_excludes_an_unknown_protocol() {
        // A protocol from an unloaded/non-emittable framework has no inherits/required data —
        // must not contribute (wrong-arity flattening risk).
        let foundation = fw("Foundation", vec![proto_full("Known", &[], &["go"], &[])]);
        let reg = ProtocolRegistry::from_frameworks(&[foundation]);
        let closure =
            reg.conformance_closure(&["Known".to_string(), "CALayerDelegate".to_string()]);
        assert!(closure.contains("Known"));
        assert!(!closure.contains("CALayerDelegate"));
        assert_eq!(closure.len(), 1);
    }

    #[test]
    fn conformance_closure_is_keyed_on_the_direct_list_only() {
        // A class that does not itself restate a protocol in `direct` gets an empty closure
        // for it, even though the registry knows the protocol globally — this is what makes a
        // subclass correctly defer to whichever ancestor's own header conforms (module doc).
        let foundation = fw(
            "Foundation",
            vec![proto_full("NSCoding", &[], &["go"], &[])],
        );
        let reg = ProtocolRegistry::from_frameworks(&[foundation]);
        assert!(reg.conformance_closure(&[]).is_empty());
        assert!(reg
            .conformance_closure(&["SomethingElse".to_string()])
            .is_empty());
    }

    #[test]
    fn empty_registry_yields_empty_closure() {
        let reg = ProtocolRegistry::new();
        assert!(reg
            .conformance_closure(&["Anything".to_string()])
            .is_empty());
    }

    #[test]
    fn is_required_method_distinguishes_required_from_optional() {
        let foundation = fw(
            "Foundation",
            vec![proto_full(
                "NSCoding",
                &[],
                &["encodeWithCoder:", "initWithCoder:"],
                &["someOptionalHook:"],
            )],
        );
        let reg = ProtocolRegistry::from_frameworks(&[foundation]);
        assert!(reg.is_required_method("NSCoding", "encodeWithCoder:", false));
        assert!(reg.is_required_method("NSCoding", "initWithCoder:", false));
        assert!(
            !reg.is_required_method("NSCoding", "someOptionalHook:", false),
            "optional members must never flatten as required (module doc)"
        );
        assert!(!reg.is_required_method("NSCoding", "encodeWithCoder:", true));
        assert!(!reg.is_required_method("DoesNotExist", "encodeWithCoder:", false));
    }

    #[test]
    fn insert_conformance_seeds_closure_and_required_data_directly() {
        // The test-helper dual of `insert` for the ownership map.
        let mut reg = ProtocolRegistry::new();
        reg.insert_conformance(
            "NSSecureCoding",
            vec!["NSCoding".to_string()],
            [("supportsSecureCoding".to_string(), false)],
        );
        reg.insert_conformance("NSCoding", vec![], [("initWithCoder:".to_string(), false)]);
        let closure = reg.conformance_closure(&["NSSecureCoding".to_string()]);
        assert_eq!(closure.len(), 2);
        assert!(reg.is_required_method("NSCoding", "initWithCoder:", false));
    }

    // --- the protocol→module resolver ------------------------------------------------

    #[test]
    fn resolver_routes_a_same_framework_protocol_to_its_own_module() {
        // Empty registry (unconfigured emitter): a same-framework protocol falls back to the
        // current framework's package barrel (which re-exports ./protocols).
        let reg = ProtocolRegistry::new();
        let r = ProtocolModuleResolver::new("TestKit", &reg, set(&["TKRefreshing"]));
        assert!(r.is_known("TKRefreshing"));
        assert_eq!(r.module_for("TKRefreshing"), "@apianyware/testkit");
        assert_eq!(r.owner("TKRefreshing"), None, "same-fw not registry-owned");
    }

    #[test]
    fn resolver_routes_a_cross_framework_protocol_via_the_registry() {
        // A populated registry (the CLI pre-pass shape): a protocol owned elsewhere routes to
        // that framework's module, even while emitting AppKit.
        let mut reg = ProtocolRegistry::new();
        reg.insert("NSCopying", "foundation");
        let r = ProtocolModuleResolver::new("AppKit", &reg, set(&["NSCopying"]));
        assert!(r.is_known("NSCopying"));
        assert_eq!(r.owner("NSCopying"), Some("foundation"));
        assert_eq!(r.module_for("NSCopying"), "@apianyware/foundation");
    }

    #[test]
    fn resolver_falls_back_to_current_framework_for_an_unknown_protocol() {
        // A protocol not registry-owned degrades to the current framework — the resolver
        // analogue of the class same-framework-gap rule.
        let mut reg = ProtocolRegistry::new();
        reg.insert("NSCopying", "foundation");
        let r = ProtocolModuleResolver::new("AppKit", &reg, set(&["TKLocal"]));
        assert_eq!(r.module_for("TKLocal"), "@apianyware/appkit");
    }

    #[test]
    fn resolver_gates_recognition_on_the_known_set() {
        // A name absent from the recognition set is not `is_known` — it contributes no
        // `implements` / cross-framework `extends` (the blessed degradation).
        let reg = ProtocolRegistry::new();
        let r = ProtocolModuleResolver::new("TestKit", &reg, set(&["TKRefreshing"]));
        assert!(r.is_known("TKRefreshing"));
        assert!(!r.is_known("NSObject"), "unknown name is not recognised");
        assert_eq!(r.framework(), "TestKit");
    }
}
