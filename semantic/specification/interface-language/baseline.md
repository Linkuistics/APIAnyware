# Mapping the existing APIAnyware model

This is a bounded disposition inventory, not an assertion that the whole frontend
was exhaustively audited. The source is the seven files below in
`../APIAnyware.add-ocaml-target`, compared with the corresponding current workspace
files on 22 September 2026. The OCaml workspace matters: main alone lacks several
contract distinctions required here.

| Source | Scope |
|---|---|
| `APIAnyware.add-ocaml-target/semantic/tools/types/src/ir.rs` | Framework and declaration records, Swift attributes and ownership facts. |
| `APIAnyware.add-ocaml-target/semantic/tools/types/src/type_ref.rs` | Type expressions and nullability. |
| `APIAnyware.add-ocaml-target/semantic/tools/types/src/annotation.rs` | Analysed memory, threading, callbacks and errors; evidence and overrides. |
| `APIAnyware.add-ocaml-target/semantic/tools/types/src/provenance.rs` | Availability, source location and documentation references. |
| `APIAnyware.add-ocaml-target/semantic/tools/types/src/pattern_instance.rs` | Pattern identity and participants. |
| `APIAnyware.add-ocaml-target/semantic/tools/patterns/src/kind.rs` | Authored role/law model, including types without serde derives. |
| `APIAnyware.add-ocaml-target/semantic/tools/types/src/enrichment.rs` | Derived convenience indices and verification results. |

Graph coverage: OCaml generation `2026-09-08T08:04:02Z` excludes all seven files,
so all were read directly. Main generation `2026-09-22T11:21:03Z` reported current
metadata with no recorded gaps for the comparison paths; direct differences were
also inspected. These are best-effort coverage facts, not proof that extraction
semantics outside the bounded corpus have been captured.

Disposition codes: **R** represented by the named draft rule; **U** upstream
analysis/evidence; **D** derived view; **P** consumer or producer policy;
**B** publication blocked until an additional authoritative fact or fully specified
profile is available. A field may split across dispositions. “Profile needed” is
an explicit representability gap in this draft, not permission to invent a profile
name or serialize uninterpreted payloads.

## Framework and declarations

| Source record and fields | Disposition |
|---|---|
| `Framework.format_version` | R: L1 language version replaces the serialized schema marker; values are not interchangeable. |
| `Framework.checkpoint, sdk_version, collected_at, skipped_symbols` | U: pipeline stage, collection context and omission report. An SDK collection version is neither API version nor availability. Relevant SDK/compiler requirements must separately become A1/A4 environment/build facts. |
| `Framework.name, depends_on` | R: L2 package identity/import closure; version/digest pins require new facts. |
| `Framework.classes, protocols, enums, structs, functions, constants` | R: declarations in L4–L5; missing applicable contracts are B, never defaulted. |
| `Framework.class_annotations, patterns` | R/U: effective C-rules/L6 contracts survive; merge evidence stays upstream. |
| `Framework.enrichment, verification` | D: convenience views and diagnostic results; not language authority. |
| `SkippedSymbol.name, kind, reason` | U: extraction omissions. L3 surface may deliberately exclude an API, but cannot omit a referenced declaration or known behaviour. |
| `Class.name, swift_name` | R: distinct canonical identity, `source` identity and A2 runtime/source access identity. Nested Swift spelling need not equal runtime class name. |
| `Class.superclass` (serialized `super`), `protocols` | R: `base`, `implements`. No superclass is `base(none)`. |
| `Class.properties, methods, category_methods` | R: separate declarations, `member`, `extension`; one authoritative declaration each. |
| `Class.deprecated, provenance` | R/U: L3 availability and L5 deprecation; source location is optional navigation. |
| `Class.swift_attributes` | U/B: raw attributes are analysis input. Their full semantic consequences must become core/profile facts; a raw string bag is insufficient. |
| `Class.sendability, global_actor` | R/B: C2 sharing/isolation plus exact source conformance/actor profile; the fixture illustrates distinctions but is not a production Swift profile. |
| `Class.ancestors, all_methods, all_properties` | D: derive inheritance and member lookup from declared relations. |
| `Class.objc_exposed` | R/B: existence or absence of a complete Objective-C access path. A Boolean alone does not establish its selector, runtime identity, ABI or availability. |
| `CategoryGroup.category, origin_framework, methods` | R: `extension`, declaring package/import and explicit member identities; receiver ownership differs from extension ownership. |
| `Method.selector, class_method, init_method` | R: A2 selector path and L5 `member` kind. Class and instance methods sharing a selector require distinct declaration IDs. Initializer semantics do not imply ownership by spelling. |
| `Method.params, return_type` | R/B: full signature, L4 types and C1–C5 slot contracts. |
| `Method.deprecated, provenance, doc_refs` | R/U: availability/deprecation and documentation/navigation; see provenance table. |
| `Method.variadic, swift_fn` | R/B: `variadic`, execution/completions/mutation and a source profile. Core alone cannot express variadic schemas or full generic families. |
| `Method.source` | U: origin of extraction, not an access mechanism. |
| `Method.origin, category, overrides, satisfies_protocol` | R/D: canonical declaring package, extension and explicit override/satisfaction relations; inherited lookup origin is derived. |
| `Method.returns_retained, ownership_attr` | R/U: effective output `give`, receiver `input(consume)`; explicit attributes/naming precedence are upstream once resolved. |
| `Method.objc_exposed` | R/B: A2 access alternatives; no implicit message path. |
| `OwnershipAttr.returns_retained, consumes_self` | R: C3/C5 transfer at entry and owned/borrowed return. Receiver consumption is independent of mutation. |
| `Param.name, param_type` (serialized `type`), `consumed` | R: named typed slot, C3 `input`. Transferring an existing owned reference differs from retaining a borrow. |
| `Property.name, property_type` (`type`), `readonly, class_property` | R: property declaration, explicit `accessors(..., none)` and `member` kind. |
| `Property.getter_override` (`getter`), `setter_override` (`setter`) | R: full accessor functions with exact source/access identity. Missing override does not prove setter existence. |
| `Property.ownership` | R/B: `storage` checked against accessor contracts; storage facts do not establish complete accessor signatures. |
| `Property.deprecated, provenance, doc_refs, source, origin, objc_exposed` | R/U/D/B: same availability, navigation, extraction, canonical ownership and access-path dispositions as methods. |
| `Protocol.name, inherits, required_methods, optional_methods, properties` | R/B: interface/`extends`, member requirement and accessors. Protocol-property optionality is absent from this IR and needs new authority. Optional call capability testing needs a production profile. |
| `Protocol.source, provenance, doc_refs, sendability, global_actor, objc_exposed` | Same U/R/B dispositions as classes and methods. |
| `Enum.name, enum_type` (`type`), `values` | R/B: nominal enum/flags with explicit integer representation and open/closed value domain. The latter distinction is not supplied here. |
| `Enum.source, provenance, doc_refs, sendability, global_actor, objc_exposed` | Same U/R/B dispositions as above. |
| `EnumValue.name, value: i64` | R/B: named arbitrary-precision literal checked against underlying type; source IR cannot represent unsigned cases above `i64::MAX`. |
| `Struct.name, fields, methods` | R/B: ordered record fields plus member functions; native layout/packing and complete value receiver effects require A3/profile facts. |
| `Struct.source, provenance, doc_refs, sendability, global_actor, objc_exposed` | Same U/R/B dispositions as above. |
| `StructField.name, field_type` (`type`) | R/B: named typed field; reference leaves need contracts where values cross boundaries. |
| `Function.name, params, return_type` | R/B: explicit identity/signature/contracts. |
| `Function.returns_retained` | R/U: resolve +1 versus +0 according to pipeline stage, then publish `give`. Resolved absence means ordinary borrowed ObjC return in this implementation; extraction-stage absence only means no explicit attribute. Neither establishes non-ObjC handle release protocol. |
| `Function.inline, macro_expansion` | R/B: source-only/profile access as appropriate. Absent macro, nonempty expansion and empty erasing macro differ; they cannot all become symbol calls. |
| `Function.variadic, deprecated, source, provenance, doc_refs, objc_exposed, swift_fn` | Same R/U/B dispositions as methods. |
| `SwiftFnInfo.throwing, is_async, is_generic, self_kind` | R/B: throws/completions, execution, complete generic family profile, receiver transfer/mutation. A generic Boolean lacks parameters, constraints and instantiation rules. Open `self_kind` strings require interpretation before publication. |
| `Constant.name, constant_type` (`type`) | R/B: value declaration/type and output contract. |
| `Constant.array_element` | R/B: A3 address-of-array mechanism, element type and authoritative extent. Must not load a pointer variable accidentally. |
| `Constant.macro_value` | R/B: literal when truly constant; otherwise explicit source construction/evaluation profile with effects and ownership. |
| `Constant.source, provenance, doc_refs, objc_exposed` | Same U/R/B dispositions as above. |

`Sendability::{Available, Unavailable, Nonconforming}` are three distinct source
conformance facts; they do not collapse into a thread-safety Boolean.
`Sendability::Unknown` is B. `GlobalActor::None` and `Named(String)` become known
absence or profile-defined named isolation; `Unknown` is B.

## Type references

| Variant and every payload field | Disposition |
|---|---|
| `TypeRef.nullability, kind` | R/B: nullable wrapper and concrete type expression. `Nullability::{Nullable, NonNull}` resolve to explicit types; `Unknown` blocks publication. Nullable-on-error has lost its condition here; C5 needs the authoritative outcome condition separately. |
| `Alias { name, framework, underlying_primitive }` | R/B: alias/import identity; resolve underlying type and enum width/signedness. A name without a definition/import is incomplete. |
| `Block { params, return_type }` | R/B: named callback with complete nested slot contracts and a block representation profile. Bare types cannot supply callback ownership/schedule. |
| `Class { name, framework, params }` | R/B: object/import identity; generic application requires a specified source type/constraint profile. |
| `ClassRef` | B: source metatype profile and precise represented class constraints. |
| `Id { protocols }` | B: dynamic object/existential profile preserving all protocol bounds and dispatch/lifetime rules. |
| `Instancetype` | B: receiver-dependent type profile; cannot silently replace with a fixed class. |
| `FunctionPointer { name, params, return_type }` | R/B: callback declaration/source alias, nested contracts and explicit calling convention/representation. |
| `CString` | R/B: `ptr` plus encoding/termination/extent; source says `const char *`, not an arbitrary mutable buffer. Scanned extents need a profile. |
| `Complex { element }` | R: `complex<f32\|f64>` plus A3 representation; never a pointer fallback. |
| `Pointer { name, pointee, const_pointee, pointee_incomplete }` | R/B: source alias, recursive `ptr`/`mutptr`, explicit opaque handle when authoritative. Absent `pointee` is missing information; incomplete definition is intentional opacity. The distinction must survive. |
| `Primitive { name }` | R/B: resolve fixed semantic type and provider representation; platform-dependent native primitive names require profile/environment interpretation. |
| `Selector` | B: explicit selector source/runtime profile. |
| `Struct { name }` | R/B: reference to a complete record declaration/representation. |

The legacy `nullable()` convenience accessor treats only `Nullable` as true;
its false result cannot distinguish non-null from unknown. Placeholder `void()`
types inserted for missing signatures are U/B, never an authoritative unit return.

## Annotations, evidence and overrides

| Record, fields or variants | Disposition |
|---|---|
| `FrameworkAnnotations.framework, classes` | R/D: identity and association with authoritative declarations; no second parallel contract graph. |
| `FrameworkAnnotations.subagent_report` | U. |
| `SubagentReport.block_synchronous, block_async_copied, block_stored, parameter_ownership, threading_main_thread_only, threading_any_thread, error_pattern` | U: aggregate analysis counts. |
| `ClassAnnotations.class_name, methods` | R/D: attachment identity; class_name can name a protocol. |
| `MethodAnnotation.selector, is_instance` | R: resolve an unambiguous canonical operation ID before publication. |
| `MethodAnnotation.parameter_ownership, block_parameters, threading, error_pattern` | R/B: effective C3–C6 contracts; several annotations leave required dimensions unspecified. |
| `MethodAnnotation.source, confidence, provenance, fact_provenance` | U/D: upstream evidence and resolved merge audit. |
| `MethodFactProvenance.parameter_ownership, block_parameters, threading, error_pattern` | U: per-fact evidence. |
| `SlotProvenance.param_index, source, rules, superseded_by` | U: resolution audit; `superseded_by` contains disagreeing losing claims despite its name. |
| `SupersededFact.source, value` | U. |
| `Confidence::{High, Medium, Low}` | U; confidence never authorizes an incomplete package. |
| `ParamOwnership.param_index, ownership` | R: canonical slot and storage/retention, not transfer inferred from position. |
| `OwnershipKind::{Strong, Weak, Copy, UnsafeUnretained}` | R/B: `retain` constructors with explicit regions. Weak is zeroing; unsafe unretained is not. Copy semantics need a profile. |
| `BlockParamAnnotation.param_index, invocation` | R/B: callback-use identity and schedule facts. |
| `BlockInvocationStyle::Synchronous` | R/B: during-call, non-copying callback; count/executor/concurrency still need authority. |
| `BlockInvocationStyle::{AsyncCopied, Stored}` | R/B: copied deferred/stored reference; count, teardown, owner, executor and overlap must be established. AsyncCopied does not mean exactly once. |
| `ThreadingConstraint::{MainThreadOnly, AnyThread}` | R/B: entry executor. Any-thread does not imply parallel-safe or reentrant. |
| `ErrorPattern::{ErrorOutParam, ThrowsException, NilOnFailure}` | R/B: complete signatures, completion partitions, output states and ownership; a pattern name does not supply them. |
| `AnnotationSource::{Manual, Extraction, Llm, Convention, Unknown}` | U: merge precedence stays outside the language; effective contracts have equal authority regardless of producer. |
| `AnnotationOverrides.framework, overrides` | U/P: authoring/merge interface. |
| `AnnotationOverride.class_name, selector, field, value, reason` | U/P: resolve changes before publication; no competing override layer inside an AIL package. |

## Provenance and availability

| Record/fields | Disposition |
|---|---|
| `SourceProvenance.header, line` | U or optional non-normative `link`/`doc` navigation; not proof of semantics. |
| `SourceProvenance.availability` | R/B: actual semantic availability must survive removal of evidence metadata. |
| `Availability.introduced, deprecated, deprecated_without_version, obsoleted` | R/B: derive valid exact L3 environment membership and L5 deprecation. Preserve unversioned deprecation. Draft 0.1 cannot publish open-ended version intervals as such; choose an explicitly bounded exact environment matrix or define a later range feature. |
| `DocRefs.header_comment, apple_doc_url, usr` | R/U: authored descriptions/navigation/source identity as appropriate. A URL or USR does not substitute for a contract or canonical declaration ID. |
| `DeclarationSource::{ObjcHeader, SwiftInterface}` | U: extraction origin; source access capability must be specified independently. |

## Patterns and derived views

| Record/fields/variants | Disposition |
|---|---|
| `PatternInstance.id, kind, roles` | R: explicit stable declaration identity, pattern reference and typed complete bindings. Existing IDs are content-derived; preserving their hash algorithm is P. |
| `PatternInstance.home` | D/P: placement derived from primary participants in the implementation; declaring package is authoritative in AIL. |
| `PatternInstance.source, confidence, provenance` | U. |
| `Participant::Type { framework, name }` | R: fully resolved nominal reference. |
| `Participant::Operation { framework, class, selector }` | R/B: canonical operation reference; current form can omit instance/class distinction. Ambiguity must be resolved. |
| `Participant::Parameter { framework, selector, param }` | R/B: canonical operation-plus-slot reference; current form lacks owning class. |
| `Participant::Pattern { id }` | R: reference another instance; check acyclic composition. |
| `InstanceSource::{Extraction, Convention, Llm, Manual}` | U: existing precedence differs from annotation precedence, but neither enters the normative format. |
| `PatternKind.name, doc, roles, ordering, laws` | R/B: L6 declarations, descriptions, typed roles and operand-bearing laws. Only the specified core law forms are currently admissible without profiles. |
| `Role.name, binds, cardinality, primary` | R/P: explicit role/type/cardinality; primary is placement policy, not an independent semantic fact. |
| `RoleBinds::{Type, Operation, Parameter, Pattern}` | R: type, operation, slot, pattern instance. |
| `Cardinality::{One, Optional, Many, AtLeastOne}` (`1`, `?`, `*`, `+`) | R: one, optional, many, some. |
| `Ordering.before`; `BeforeEdge.earlier, later` | R/B: `law(before, ...)` plus shared resource subject and completion/entry semantics. Existing bare order edges need those facts; other meanings require a profile. |
| `Law.category, tokens, doc` | R/B: semantic law requires a typed form with operands; token/prose strings alone are insufficient. |
| `LawCategory::{Ownership, Lifetime, Threading, Error, Callback, Buffer, Relationship}` | R/P/B: map concrete laws into C-rules/L6/profile forms. Category headings may remain documentation taxonomy; they do not themselves impose obligations. |
| `EnrichmentData.sync_block_methods, async_block_methods, stored_block_methods, delegate_protocols, convenience_error_methods, collection_iterables, scoped_resources, main_thread_classes, weak_param_methods` | D: regenerate from authoritative contracts; target wrappers remain consumer policy. |
| `EnrichmentData.protocol_sync_block_methods, protocol_async_block_methods, protocol_stored_block_methods, protocol_convenience_error_methods, protocol_weak_param_methods, protocol_main_thread_protocols` | D: protocol equivalents. |
| `BlockMethodEntry.class, selector, param_index`; `WeakParamEntry.class, selector, param_index`; `ClassSelectorEntry.class, selector`; `ScopedResourceEntry.class, open_selector, close_selector` | D: index payloads. The `class` field can name a protocol; canonical references remove that ambiguity. |
| `VerificationReport.passed, violations`; `Violation.rule, class, selector, param_index, description` | D: diagnostic output. A saved passed flag is not evidence that a new package/provider closure validates. |

## Migration consequences

The two workspaces have identical `annotation.rs`, `pattern_instance.rs`,
`enrichment.rs` and `kind.rs`. Material OCaml changes in this corpus are in
`ir.rs`, `type_ref.rs` and `provenance.rs`: nominal sendability/actor facts,
class deprecation/provenance, consumed parameters/receiver and return attributes,
property selectors, function deprecation/macros/return ownership, richer pointers,
complex scalars, three-state nullability, unversioned deprecation and obsoletion.

Neither workspace currently provides complete generic signatures, union/bitfield
layout, all array extents, open/closed enum semantics, every unsigned enum value,
callback nested-slot contracts and teardown, full buffer relationships or
outcome-conditioned validity. These are publication blockers when relevant.
Migration cannot be a serialization rename: a producer must gather the missing
facts, resolve its evidence outside AIL, and validate the resulting package.

The first implementation should therefore start with a bounded surface for which
all contracts and a production access profile can be established. Later phases
should add real Apple/Swift profiles and richer pattern laws before claiming full
replacement of today's frontend output. Target-specific OCaml or other-language
convenience choices remain downstream and must not redefine the source API.
