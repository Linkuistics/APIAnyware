# TypeScript object model: ObjC mirrored as real ES6 classes, statically emitted, with a generated `.d.ts` type surface

The `typescript` target's object model **mirrors ObjC's class graph as real ES6
classes** — `class NSString extends NSObject { … }` — each instance wrapping a
**branded, disposable native handle**. The emitter **statically generates the class
bodies** (one file per class, per-framework modules) and the **`.d.ts` type surface
from the same pass** (the one-artifact architecture), each method body a coercion-free
call into the Swift-native N-API addon's per-signature dispatch entry (ADR-0054). Selectors map to
method names by the **structure-preserving injective rule** (ADR-0039 in TS idiom);
protocols become **interfaces** classes explicitly `implements`; value types split into
**POD-aggregates-as-plain-objects** vs **Swift-native-value-structs-as-branded-handles**
(the ADR-0042 population split); enums are TS `enum`s, nullability rides ObjC/LLM
annotations into `T | null`.

This ADR fixes the object-model + type-surface layer (Q2). It is a **grilled design**
grounded in the settled substrate (ADR-0054, spike-verified) and prior art
(NativeScript's macOS surface, objc2's static class/protocol modelling, PyObjC's
selector rules) — **not** itself spike-verified; the type surface is a design choice,
not a runtime unknown. The lifetime/disposal contract that makes the handle "disposable"
(Q3, ADR-0057), the error surface (Q5, ADR-0058), the callback/delegate bridging (Q6, ADR-0059), and distribution (Q7)
are separate ADRs that build on this one; the threading/runloop layer (Q4) is
`libuv-runloop-primacy-research-k5`.

## Context — the second alien axis

TypeScript is the first target with a **static type system**, so the binding's `.d.ts`
type surface is a first-class deliverable no prior target has (root `BRIEF.md`). The
four Lisp targets split internally on object-model shape: the Scheme family
(`racket`/`chez`/`gerbil`) exposes a **single wrapper + namespaces of procedures**
(`objc-object`, deliberately *not* mirroring the graph), while the CL family **mirrors**
it (sbcl's MOP-projected CLOS graph ADR-0034; gerbil's manifest `defclass` graph
ADR-0020). TypeScript is the first target where mirroring the graph is unambiguously the
*idiomatic* choice — a macOS/TS developer expects `NSString.stringWithUTF8String_(s)`,
`foo instanceof NSView`, inheritance, and editor autocomplete.

**Settled upstream (carried in):** the substrate is generated typed native dispatch
through a single Swift-native N-API addon, engine-agnostic via N-API, trampoline-elided
(ADR-0054); ObjC handles cross to JS as opaque pointers (BigInt in the spike). The
research pre-judged the shape (D3): model the graph the objc2 way, generate the `.d.ts`
from the dispatch metadata, brand/dispose instances.

**Open here (grilled):** the concrete TS surface — class-vs-function, static-vs-synthesized
emission, the selector-name rule, protocol modelling, the struct split, and the
enum/constant/nullability/construction details.

## Decision

### 1. Real ES6 classes mirroring the ObjC hierarchy

`emit-typescript` generates a real `class` per bound ObjC class with true `extends`
chains (`class NSString extends NSObject`), static factory methods (`alloc`,
`stringWithUTF8String_`), and instance methods. Each instance is an ES6 class instance
whose single internal field is the **branded native handle** (the ObjC `id`); the
prototype chain gives `instanceof` and inheritance for free, and the class declarations
*are* the `.d.ts` type surface. This is the CL-family "mirror the graph" posture
(ADR-0034/0020) expressed in TS's native class idiom, not the Scheme family's
namespaces-of-procedures.

Rejected: branded-handle-plus-free-functions (the `objc-object` analogue — un-idiomatic
for TS, no method discovery/autocomplete); a single opaque wrapper with Proxy-based
dynamic dispatch (the NodObjC/deno_objc shape — throws away the generated typed dispatch
the substrate is built on).

### 1b. A class *reference* binds, degrades, or defers — the `TypeRefKind::Class` overload

*(added `swift-nominal-type-surface-k66`, 2026-07-11 — §1 fixed how a class is **declared**;
this is what a reference to one **means**.)*

The IR spells two unrelated things as `TypeRefKind::Class{name}`. An **ObjC-header** decl spells
a genuine object pointer that way (`CLLocation *`); a **`.swiftinterface`** decl spells *every
Swift nominal type* that way — `Tuple`, `KeyPath`, `OpaqueTypeArchetype`, `Binding`, `Hasher`,
`SIMD3`, `CGFloat`. Measured over the committed IR, **27 890** `Class{…}` references name
something the IR never declares as a class, **99.2 % of them from `.swiftinterface` decls**.
Reading them all as objects made the emitter type a Swift tuple as a wrappable handle, wrap it
(`__wrapRetained(Tuple, …)` — `objc_retain` on a tuple is undefined behaviour), and value-import
`Tuple` from a module nothing exports.

A `Class{name}` therefore resolves three ways, against the **whole-program declared-class set**
(every class the IR declares — exactly the set the emitter emits) and the decl's
`DeclarationSource`:

- **Bind** — the IR declares `name`: its own TS class type, imported from its owning module. The
  ordinary case.
- **Degrade** — undeclared, and the decl is **ObjC-sourced**: a real ObjC class this target does
  not emit (uncollected, or in a framework the run did not load). An ObjC header cannot write a
  non-object in a `Foo *` position, so the handle is a genuine object and the *whole surface* —
  declared type, wrap primitive, import — becomes the runtime root **`NSObject`**, in lockstep.
  This is the gerbil "nearest bound ancestor" precedent (ADR-0020, `CONTEXT.md`) and it keeps the
  API **round-trippable**: a `CLLocation` read from `-[CLLocationManager location]` still passes
  back into `-[CKLocationSortDescriptor initWithKey:relativeLocation:]`.
- **Defer** — undeclared, and the decl is **`.swiftinterface`-sourced**: the name may be any Swift
  nominal type with no ObjC identity, so the **whole member** defers (counted by name in the pass
  log, never silently dropped).

Nothing at the ABI moves: `AbiType::from_type_ref` already collapses every `Class{…}` to `Ptr`,
and a degraded class is still an object, so the retain axis (§ADR-0057 §4), the entry names, and
the generated tables are byte-identical. A deferred member simply leaves the one frontier both the
call sites and the table collection walk.

Rejected: **degrade everything** — it would wrap a Swift tuple as an object (UB). Rejected:
**defer everything** — sound, but it deletes 45 real, callable methods (`CLLocation` ×18,
`Protocol` ×9, the `MPS*` family) whose handles are genuine objects, buying nothing.

### 2. Static class bodies + generated `.d.ts`; per-framework modules

The class bodies are **statically generated** — concrete `.ts`/`.js`, one file per class
in per-framework directories (the sbcl `nsstring.lisp` / gerbil per-class-file on-disk
convention), each method body a **coercion-free call into the addon's per-signature
dispatch entry**. The `.d.ts` is emitted from the same pass (one artifact drives both
runtime and types, NativeScript's proven invariant), so runtime and types cannot drift.
The runtime stays **dumb** — nothing is consulted at call time — preserving the
substrate's "pay codegen at build time, runtime is static+fast" property.

Artifact size (the complete AppKit+Foundation graph is thousands of classes) is bounded
by **per-framework module boundaries** (`import { NSString } from '@apianyware/foundation'`):
an app loads and `tsc`-checks only the frameworks it imports — JS's native
lazy-import/tree-shaking, not a runtime metadata blob. Cross-framework inheritance rides
a superclass-before-subclass load order (the sbcl ADR-0034 precedent).

Rejected: **runtime synthesis** from a metadata table with a `.d.ts`-only type surface
(NativeScript's one-artifact model) — it reintroduces the per-call runtime dynamism the
generated-typed-dispatch substrate was chosen to avoid, and its documented startup/app-size
tax (research B1) is the pathology this target designed around; it also risks
`.d.ts`/runtime drift.

#### 2b. The class → file-stem map is injective, because the filesystem is not case-sensitive

The per-class file's stem is the **lowercased** ObjC name (`NSString` → `nsstring`, the
CL-target convention). Lowercasing is **not injective**: Matter declares 17 ALL-CAPS acronym
classes alongside their Swift-friendly aliases (`MTRBaseClusterWakeOnLAN` /
`MTRBaseClusterWakeOnLan`), each pair lowering to one stem — so the emitter wrote one file and
the second class silently clobbered the first, while sibling modules went on importing the
vanished name.

Spelling the ObjC name **verbatim is no fix**: macOS (APFS) and Windows filesystems are
case-**insensitive**, so `…WakeOnLAN.ts` and `…WakeOnLan.ts` still name one file on the
developer's own disk. **A disambiguator must differ in more than case.**

So a class whose lowercased stem is **shared** — with another class, or with one of the
directory's reserved module stems (`index`, `enums`, `protocols`, `constants`, `functions`,
`delegates`) — takes a **case tag** suffix, `<lower>-<tag>`, where the tag is the hex of the name's
ASCII-uppercase bitmap. The tag is precisely the information the lowercasing discarded, so
within a collision group (whose members share a lowercase form by definition) it determines
the name exactly: the map is injective **by construction**, not by a digest's collision odds.
Every member of a group is tagged, and the tag depends on the **name alone** — so a stem never
moves when the IR is reordered or an unrelated class is added (a moving stem is a whole-corpus
diff). The stem is computed **once per directory** and read by both the file writer and the
barrel (the "one decision, N readers" rule — a barrel that re-derives the stem is how the same
file came to be re-exported twice).

Backstopping it: the orchestrator **refuses to write one filename twice**, and reports the
count of *distinct* files actually written rather than an arithmetic total. This is the
write-side dual of §1b's import-honesty invariant — the artifact set must *contain* a file for
every class the IR declares, exactly as it may only *import* a class the IR declares — and it
is what makes a future stem rule unable to lose a class silently: it can only fail loudly.

Rejected: a **content digest** of the name — equally opaque, but injective only by probability
and needing a collision check the case tag makes unnecessary. Rejected: a **sequence number**
within the collision group (`…wakeonlan-1` / `-2`) — it is not name-local, so a new colliding
sibling renumbers its neighbours.

### 3. Selector → method name: the structure-preserving injective rule

A selector maps to a method name by **each `:` → `_`, camelCase humps preserved**:
`setObject:forKey:` → `setObject_forKey_`, `initWithFrame:` → `initWithFrame_`,
`length` → `length`. This is **injective** — the colon boundary is never lost — so
distinct selectors never collide and **no rename table, no collision-disambiguation
logic, and no emitter-side collision detector are ever needed** *for method names* (macOS's
surface is collision-free under a structure-preserving map; integrity is an analysis-phase
invariant). The scope of that claim is the **selector → member name** map, which is
structure-preserving. It does **not** extend to the class → **file stem** map (§2b), which
*is* lossy — it discards case, and the filesystem cannot recover it — and therefore does need
exactly the disambiguation this paragraph says method names never will. Injectivity is earned
map by map, not inherited. This is the TS realization of **ADR-0039** (which established the rule for
sbcl as `:`→`_` + hump→`-`; TS keeps camelCase humps as-is because camelCase is
TS-native — the `:`→`_` + injectivity is the shared invariant), and PyObjC's
long-proven `doX:withY:`→`doX_withY_` idiom.

**A `SEL` as a *value* crosses as that same string** (added `sel-classref-surface-k72`,
2026-07-11). §3 fixed selector → *method name*; a selector also appears as an ordinary
**argument and return** (`-[NSControl setAction:]`, `-[NSInvocation selector]`), and the TS
surface for it is the selector name — the same `string` a developer already writes. The
runtime interns it in (`__sel`, which also maps `null` → the nil `SEL`) and names it back out
(`__selName`, over a `sel_getName` primitive; the nil `SEL` → `null`, since `-[NSControl
action]` legitimately has none). Note `''` is **not** nil: `sel_registerName("")` interns a
real, empty selector, so only `null` is the nil sentinel.

**Parameter names are a separate map from method names — total, not injective** (added
`reserved-identifier-surface-k91`, 2026-07-13). §3's injectivity claim above is scoped to
*selector → member name*; it says nothing about a method's own **parameter** names, which are
ordinary ObjC argument labels, not selector components, and render in a **binding** position
(`(name: Type)`), not a member position — so the "reserved words are fine, `obj.class` parses"
argument member names get away with does not apply. A parameter named `arguments`, `function`,
or `interface` is a hard syntax error in a binding position under strict mode (every emitted
module is strict), so `param_identifier` (`naming.rs`) escapes a reserved name with a trailing
`_` (`arguments` → `arguments_`) — no rename table needed, since the ECMAScript reserved-word
alphabet is small and fixed, and no reserved word itself ends in `_`. Applied once and read
identically at the declared signature and every body expression referencing the same parameter
(`class_surface::render_params`, `emit_class::emit_body`), and shared verbatim by the free-function
formal-name computation (`emit_functions::unique_param_names`) — one predicate, both readers, so
declaration and use can never drift apart (the k57 "one decision, N readers" discipline).

Rejected: **camelCase colon-elision** (Apple's `JSExport` / NativeScript:
`setObject:forKey:`→`setObjectForKey`). More conventionally "JS-idiomatic" and the
initial recommendation, but **not injective** — a zero-arg `foo` and one-arg `foo:`
collapse to the same name (ADR-0039's `cancel`/`cancel:`), forcing gen-time collision
detection + a disambiguation rule. The injective rule's cross-target consistency and
zero-machinery property won over local JS fashion.

### 4. Protocols → interfaces with explicit `implements`

Each ObjC protocol → a generated TS **`interface`** (the objc2 "separate interface"
model): `@required` methods → members, `@optional` → **optional members** (`method_?()`)
— a fidelity TS expresses cleanly and the CL/Scheme targets cannot. A conforming class
emits an explicit **`implements`** clause, so conformance is compiler-checked and
documented and a class that fails to fully conform is flagged. Protocol-typed parameters
(delegates, data sources) are typed by the interface (`setDelegate_(d: NSTableViewDelegate)`);
a plain JS object conforming to the interface is accepted as a delegate, with the
**object→ObjC-delegate bridging settled by ADR-0059** (`ts-callbacks-design-k9`: a per-protocol
memoized forwarding class with a per-instance native `respondsToSelector:` snapshot).

Rejected: structural-only interfaces (no `implements` clause) — loses the explicit,
documented conformance signal.

#### 4b. A protocol qualifier binds or degrades — and the bind arm is guarded by conformance

*(settled `delegate-slot-typing-k80`, 2026-07-11; landed `protocol-qualifier-ir-k81`, 2026-07-11.)*
§4 promises `setDelegate_(d: NSTableViewDelegate)`. It was not true, and could not be:
**`extract-objc` dropped the protocol qualifier**, lowering `id<NSApplicationDelegate>` to a bare
`TypeRefKind::Id`, so every protocol-typed slot in the corpus flattened to `NSObject` and the emitted
interfaces were **declared but unreferenced**. The IR now carries it
(`Id { protocols: Vec<String> }`, serde-default and skip-if-empty, so an unqualified `id` serialises
byte-identically and no target's goldens move), populated from libclang's
`get_objc_protocol_declarations()`.

**Read the qualifier off the *pointee*, not the pointer.** k80 called the protocol accessor "the
sibling of the generic-type-args accessor the extractor already calls two lines above"; measuring it
showed the two are not siblings at all. libclang reports an `ObjCObjectPointer` whose **pointee** is
an `ObjCObject` the moment a type carries any refinement, and both the protocol list and the generic
arguments hang off that pointee — the accessors return empty when handed the pointer. (The extractor's
pre-existing `get_objc_type_arguments()` call *is* on the pointer, and is therefore dead code: no ObjC
`Class{…}` in the corpus has ever carried a generic param.)

The qualifier is a refinement **of `id`**. Counting *positions* (method params + returns) across
AppKit / Foundation / CoreData / WebKit / AVFoundation: `id<P>` **1163**, `Class<P>` **22**,
`NSFoo<P> *` **21**. The last two are a **counted deferral** — named with owner and selector and
totalled in the extraction pass log (ADR-0011 keeps the loss loud, never silent).

Deferral means *keeps today's lowering*, and today's lowering is worse than k80 assumed: a `Class<P>`
or `NSFoo<P> *` does not degrade to `ClassRef` / `Class{name}` — it erases to a bare `id`, as does
every generic class pointer (`NSArray<NSString *> *`, 5542 positions) and every `__kindof`. That
erasure is `objc-object-type-lowering-k85`'s to repair, deliberately not k81's: `ClassRef` is *not* an
object type to the shared FFI mapper while `Id` is, so repairing it changes how all five targets wrap
the parameter, and it must be taken with the golden churn in hand.

**One predicate — `protocol_binding` — with N readers** (the type surface, the import set, the
`DelegateSpec` derivation), in the same shape as §1b's `Class{…}` overload:

- **Bind** — the slot is typed by the interface `P` (an **intersection `P1 & P2`** for `id<P1,P2>`).
- **Degrade** — the qualifier is dropped and the slot stays `NSObject`. There is **no defer arm**
  (unlike §1b): degrading is exactly the prior behaviour, so it is always safe.

The predicate is **per name, not per slot**. `id<NSCopying, NSTableViewDelegate>` binds
`NSTableViewDelegate` and drops `NSCopying` (a marker protocol with no emittable surface) — because a
conforming class emits exactly `implements NSTableViewDelegate`, so any wider type would reject that
very class, and degrading the whole slot would throw away a bind the clause honours. One predicate,
read by both, is what makes them agree.

**A bound slot is a *yield* position too — the variance fact** *(measured `protocol-binding-surface-k89`,
2026-07-12).* The paragraph above argued the bind arm from what a slot **accepts**. It never asked what
a slot **yields**, and 253 corpus returns are `id<P>`. The two positions are not the same type:

| position | token | why |
|---|---|---|
| **param** (contravariant — what we accept) | `P`, or `P1 & P2` | the widest thing that satisfies the API. TS structural typing then admits *both* a JS object literal implementing `P` and a wrapped ObjC object whose class `implements P` — the property §4's delegate story rests on |
| **return** (covariant — what we promise) | `P & NSObject` | what the value **is**: ADR-0057's dynamic wrap mints it into its real ObjC class, so it carries `P`'s members *and* the object root's |

The intersection is forced, not decorative. A return typed bare `P` would be **narrower than the
value**, and `arr.addObject_(app.delegate())` — a legal ObjC call whose `addObject:(id)` param renders
`NSObject` — would stop compiling, an interface not being assignable to a class. And it is honest only
because of the dynamic wrap: before it, `__wrapRetained(NSObject, id)` minted a bare root object with
none of `P`'s members, and *any* bound return would have been a fresh lie. The wrap carries the
declared conformance as an explicit type argument (`__wrapRetained<P & NSObject>(__ret)`), rendered
from the **same** predicate as the signature — the ObjC header states the conformance, and it is a fact
`tsc` cannot derive for itself.

**The bind arm's precondition is a guard, not a rule** (2b's lesson):

**Conformance honesty** — the dual of §1b's import honesty. A protocol may be bound only if its
interface is emitted **and every class the IR declares as conforming to it carries its `implements`
clause**. Without it a *legal* call — a wrapped `NSString` into an `id<NSCopying>` slot — would fail
`tsc`, because an unrecognised protocol base is dropped from the `implements` clause "safely".
Conformance is therefore **whole-program and built ONE way** — the same registry that drives the
clause itself (§4). Because the clause filters on exactly that recognition set, the guard *collapses
into* it: one set, so the two cannot admit different calls.

Every degradation is **counted** in the generate pass log (no silent narrowing): as of the transitive
widening below, **303 qualifier positions bind and 32 degrade across 8 names** — all not-emittable
(`NSObject`, `NSCopying` and six real delegate protocols whose members all defer). Superseded the prior
293/42/11 measurement (`NSMachPortDelegate`, `NSMatrixDelegate` and `NSSecureCoding` moved from degraded
to bound — see below).

**Emittability is transitive over `inherits`** *(settled `protocol-inherited-surface-gap-k104`,
2026-07-14; landed `transitive-protocol-emittability-k106`, 2026-07-14)*. A protocol with no bindable
members of its own but a bindable **ancestor** still binds — rendered as an interface with an empty body
that `extends` the ancestor (`interface NSMachPortDelegate extends NSPortDelegate {}`) — instead of every
qualifier naming it degrading to `NSObject`. Surfaced by `NSMachPort.setDelegate_(id<NSMachPortDelegate>)`:
`NSMachPortDelegate`'s sole member (`handleMachMessage:`) takes an unsupported raw-pointer param, so
it fails `has_surface` on its own, but it `inherits: [NSPortDelegate]`, a fully-bindable protocol — a
real capability the qualifier should not throw away. `transitively_emittable_protocols` (widening the
old, own-surface-only `is_emittable_protocol`) computes *has a surface, own or (transitively, via
`inherits`) inherited* as a fixed point over the **whole** protocol set handed in, not the
already-filtered-emittable one `ProtocolRegistry::from_framework_refs` built before, since an `inherits`
edge can point at a protocol that fails on its own surface alone. Every call site gated on the old
predicate now agrees on the widened one (one predicate, N readers, again):
`ProtocolRegistry::from_framework_refs` runs it **whole-program** (`inherits` can cross framework
boundaries — verified live in the corpus: `NSMachPortDelegate`/`NSPortDelegate` are same-framework, but
the registry does not assume that); `emit_framework.rs`'s per-framework `known_protocols` fallback,
`emit_protocol.rs`'s `emitted_protocol_count`/`render_protocol_bodies`, and
`delegate_spec.rs`'s `spec_protocols` each run it over their own framework's protocol slice.

**The per-framework scope limit occurs live in the corpus** (`typecheck-gate-post-k86-residuals-k110`,
2026-07-15 — closing what the paragraph above left unverified): `CNKeyDescriptor` (Contacts) has zero
own members and its only bindable ancestor, `NSSecureCoding`, is owned by Foundation — invisible to a
per-framework `by_name` walk holding only Contacts's own protocols, so `contacts/protocols.ts` never
declared the interface even though the whole-program registry (and every importer reading it) already
recognised the name, a TS2305 (`has no exported member`) at every `id<CNKeyDescriptor>` call site.
Fixed **without duplicating the whole-program walk at each call site**: `reaches_bindable_surface`
(`emit_protocol.rs`) falls back to the mapper's own `known_protocols` — already whole-program-aware by
the time any per-framework caller renders, since `emit_framework.rs` seeds it from
`ProtocolRegistry::names()` before building it — exactly where the local `by_name` walk would otherwise
go blind on an ancestor outside its own framework's slice. Sound, not circular: the registry's own
whole-program call already carries every framework's protocols in `by_name`, so its own fallback there
is moot. Corpus-wide: 3 TS2305s → 0.

Regenerating the full 252-framework/11,856-file corpus after landing surfaced two more corpus members
of the exact same shape, not anticipated when the decision was scoped to `NSMachPortDelegate` alone:
**`NSMatrixDelegate`** (→ `NSControlTextEditingDelegate`) and **`NSSecureCoding`** (→ `NSCoding` — the
`conformance_closure` flattening precedent this ADR's §4 already cites turns out to be the exact same
shape as the qualifier-binding question §4b answers). `NSSecureCoding` becoming bound also flattens its
required `supportsSecureCoding` static onto every conforming class (§4's mechanism, unaffected by this
leaf) — `NSString`, `NSMutableString`, `NSArray` and `NSValue` in the curated golden subset each gained
that method. Corpus-wide: TS2416 160 → 7 (`override-signature-mismatch-k100`) → 6 (this leaf, closing
the `NSMachPort.setDelegate_` occurrence `residual-override-incompatibility-k103` tracked as (B)) → 4
(the override-union rule below, closing (C)'s two genuine SDK-authored occurrences; the remaining 4 are
the `objc-object-type-lowering-k85` erasure trio plus the already-tracked `accessibilityRows`
upstream-IR-gap residual).

Rejected (for this widening): substituting the **nearest bound ancestor** at each degraded qualifier's
own use site, leaving `NSMachPortDelegate` itself unemitted — smaller in one sense, but it discards the
protocol's own name/identity everywhere it's referenced and reaches the same call sites for a narrower
result.

**An SDK-authored incompatible override renders the param union** *(settled
`sdk-override-incompatibility-policy-k105`, 2026-07-15)*. ObjC does not enforce override covariance, and
Apple's own headers exploit that: `NSOutlineView` redeclares `setDataSource:` as
`id<NSOutlineViewDataSource>` over `NSTableView`'s `id<NSTableViewDataSource>`, and `NSSavePanel`
redeclares `setDelegate:` as `id<NSOpenSavePanelDelegate>` over `NSWindow`'s `id<NSWindowDelegate>` — in
both pairs the two protocols are verified unrelated (`inherits: [NSObject]` only, raw `.h` checked).
TypeScript's override check (TS2416) compares method params **bivariantly**, and two unrelated
all-`@optional` interfaces fail both directions (the weak-type overlap rule), so the emitted class did
not compile. Within a real `extends` chain the only expressible-compatible rendering **admits** the
ancestor's type, so a redeclared param whose type is not — over the protocol-`inherits` closure, either
direction — an expressible override of the nearest declaring ancestor's renders the **union,
SDK-intended type first**: `setDataSource_(dataSource: NSOutlineViewDataSource | NSTableViewDataSource)`.
This admits nothing inheritance did not already admit (`(ov as NSTableView).setDataSource_(x)` accepts
the ancestor's type today, exactly as ObjC's receiver upcast does); the union just spells the inherited
contract on the member itself. The body is untouched — a wrapped object unwraps identically, and a JS
literal still bridges through the override's **own** `SPEC_<P>`. One computation
(`override_widening::override_param_widenings`), read by the `.ts` signature, the `.d.ts` signature, and
both import walkers, so the union token and its type-only import cannot drift. The compatibility
predicate is nominal and **conservative-to-no-change** — identical rendered tokens, an
`inherits`-related qualifier pair (the `NSMachPortDelegate` shape stays unwidened), or any shape with no
measured incompatibility all render untouched; the corpus gate is the guard for what it cannot prove.
Scope limits, documented in the module: the ancestor walk is same-framework (both occurrences are
AppKit-internal) and consults the ancestor's own declared methods, not its protocol-flattened frontier
(a flattened-vs-flattened conflict — `accessibilityRows` — is the upstream
`protocol-optionality-mis-extraction-k99` residual, not a rendering case).

There is deliberately **no return-position arm**: a return cannot widen compatibly (returns are
covariant), and the measured population of genuine SDK-authored return incompatibilities is **zero** —
of the five occurrences `residual-override-incompatibility-k103` tracked as (C), the three
return-position ones (`NSCustomTouchBarItem.view`/`viewController`, `NSSliderTouchBarItem.view`) turned
out to be the `objc-object-type-lowering-k85` erasure, not SDK-authored: the raw headers declare
`__kindof NSView *` / `NSView<NSUserInterfaceCompression> *`, which extraction erases to bare `id` —
once k85 restores the base class they render `NSView`, a legal narrowing of the ancestor's declaration.
Design a return arm when a real instance exists, not before.

**A real instance since appeared, and it is a different species — this section's premise still
holds** (`typecheck-gate-post-k86-residuals-k110`, 2026-07-15). `NSAccessibility` (a wide informal
protocol declaring `accessibilityValue` as a bare `id`) and an unrelated specific sibling like
`NSAccessibilityProgressIndicator` (narrowing it to `NSNumber`) are both conformed by the same class,
both non-deprecated, and — unlike `NSSecureCoding`/`NSCoding` above — carry **no** `protocol_inherits`
edge between them (five occurrences: `NSProgressIndicator`/`NSSwitch`/`NSTextField`(×2)/`NSTextView`).
This is **not** an SDK-authored override of a class's own declared method — no class declares
`accessibilityValue` itself, incompatibly or otherwise — it is two **conformed protocols'** declarations
colliding at the inheritance-flattening step, the general shape `corpus-reproducibility-k86` already
fixed for the deprecated-vs-non-deprecated axis (`resolve`'s `has_nondeprecated_protocol_method`,
`program.rs`) and left as a documented residual, content-tie-broken deterministically, for the
matching-deprecation-status axis (`checkpoint.rs`). Fixed at that **same** layer, not here: when
exactly one colliding declaration is a bare, unqualified `id` return and the other is not, the typed
declaration wins — an untyped `id` is never a *better* fact, only a less specific one — otherwise the
existing alphabetically-first tiebreak stands. Shared across all five targets (`resolve` is IR-only, not
TS-specific), and racket's golden shows why that is right even for a dynamically-typed target:
`nstextfield.rkt`/`nstextview.rkt`'s `accessibility-value` contract narrowed from `any/c` to
`(or/c nsstring? objc-nil?)`. Corpus-wide: TS2420 9 → 4 (the remaining four are a distinct,
not-yet-root-caused missing-member shape, `typecheck-gate-post-k86-residuals-k110`'s own tracked
residual). `override_widening.rs`'s own premise — zero measured **SDK-authored override** return
incompatibilities — is not falsified by this: the two are different mechanisms, and this one has no
"widen to a union" analogue (an untyped `id` and a typed return are not both correct, so there is
nothing to admit both of).

**A second real instance appeared, and this one is a genuine SDK-authored return incompatibility —
the return arm this section deferred is now designed** (`text-undo-surface-gap-k121`, 2026-07-16).
Merging category methods into `Class::methods` at extraction (the same leaf, a separate,
cross-target fix — category-declared methods were invisible to every target's method surface,
`resolve` included, until this leaf) newly surfaces `NSControl.selectedCell` (`__kindof NSCell *`,
declared in the `NSDeprecated` category — not itself deprecated) as `NSTextView`'s own subclass
`NSBrowser` already redeclares it as a bare `id` (own `@interface`, not a category). Unlike
`accessibilityValue` above, this **is** the shape this section named: one class's own declared
method overriding an ancestor's own declared method, incompatibly, in a real `extends` chain. A
return is covariant, so the union policy (widen to admit both) is the **wrong direction** here — a
union is a supertype, not a subtype, of the ancestor's return. The sound fix is the opposite:
**narrow** — render the ancestor's own (strictly more informative) return in place of the class's
own uninformative bare `id` (`OverrideWidenings::narrowed_return`, gated on the same
`is_bare_id_return` shape-test `resolve`'s `checkpoint::is_bare_id_return` already uses one layer
down, for a different decision). Sound because a bare `id` carries no information a typed ancestor
return doesn't already provide, and the native dispatch entry is unchanged (same selector, same
ABI shape) — only the declared TS type gets more precise, never wrong. Corpus-wide population:
**exactly one** (`NSBrowser.selectedCell`), measured via a full corpus regeneration plus the gate
re-run, not assumed rare from the single occurrence. `override_widening.rs`'s own premise about
**SDK-authored param** incompatibilities is untouched — this is the return-position sibling the
module doc said would get "designed when an instance exists."

Rejected (for the override union): an **overload pair** (same admittance, a whole new rendering shape
for no behavioural difference); a **curated known-incompatible-pair list** (the §2b hand-list shape — a
rule only catches the axis its author foresaw, and the post-k85 re-measure may surface new pairs the
general rule already handles); **dropping the override member** (the subclass inherits the ancestor's
actively-wrong type — `NSOutlineView.setDataSource_` demanding a table-view data source);
**`@ts-expect-error` suppression** (greens the gate but leaves the published `.d.ts` failing for any
consumer compiling with `skipLibCheck: false`).

Protocol references are **`referenced_protocol_types`** — always `import type`, because the *interface*
is erased. The exact sibling of §5a's `referenced_pod_types`. One asymmetry: inside `protocols.ts` a
**same-framework** interface is declared in that very file, so a bound reference to it is named in-file
and **not** imported.

A bound slot carries a **second** reference, and this one is a **value**: the per-protocol `SPEC_<P>`
the body passes to `__protocolArg` (below). It is a distinct import set (`protocol_spec_imports`,
routed by the same module resolver) precisely *because* it is a runtime edge — and `delegates.ts` is
kept **import-free** so that edge cannot close a cycle back through the barrel (which would put the
`const SPEC_<P>` in its TDZ at class-definition time). The type reference and the value reference are
two facts about one qualifier; conflating them is what would reintroduce the cycle.

**The literal path is live** *(realised `emitted-delegate-spec-k84`, 2026-07-12).* Binding the param
admits a JS object literal into the slot — that was always the point — and the emitted body now honours
it: every bound `id<P>` param is passed through `__protocolArg`, which **discriminates at the value**
(an `NSObject` unwraps; anything else is bridged through `SPEC_<P>`'s forwarding class, ADR-0059 §3/§6).
So the named `TypeError` k89 put in `__unwrap` — the legible failure it owed a reachable-but-unbuilt
path — is **gone**, and `__unwrap` is back to taking an `NSObject` and nothing else. A leaf that ends by
*deleting* the error it was handed is the sign the two leaves cut the seam in the right place.

Rejected: typing `id<P>` as `P` only in delegate-shaped positions (reintroduces the name-sniffing
special case ADR-0047 §4 exists to retire); binding unconditionally (a marker protocol or a dropped
conformer yields a reference to an interface that does not exist, and the corpus stops parsing);
**bind on supply, degrade on receive** (honest, but leaves the `id`→bare-`NSObject` degradation in place
forever — the user's call, 2026-07-12, was *bind everywhere and make the wrap honest*).

**Conformance honesty extends to members — the deprecated-member carve-out** *(settled
`deprecated-protocol-member-policy-k111`, 2026-07-15)*. The emitter's blanket deprecated-method
exclusion has exactly one exception: a class's **own** deprecated method that is the **sole source of a
member some conformed protocol requires** is emitted anyway, under a `/** @deprecated */` JSDoc tag in
both artifacts. `NSManagedObjectContext` and `NSPersistentStoreCoordinator` each `implements NSLocking`
and each declares `lock`/`unlock` **itself, deprecated** (Apple deprecated direct locking in 10.10 in
favour of `performBlock:`, but never removed the methods — the classes still genuinely conform at the
ObjC runtime); dropping the members left `implements NSLocking` promising members the class body never
carried (TS2420). Emitting them honours the promise; the tag keeps the deprecation fact visible
(editors strike the member through), so neither fact is erased. The carve-out lives **inside the shared
`bound_methods` frontier** (`class_surface::deprecated_conformance_carveout`), so the `.ts` call sites,
the `.d.ts`, and both native tables admit the same members by construction; its required-ness question
is the **same** `is_required_method`-over-`conformance_closure` predicate the required-method
flattening above reads. Narrowest scope, each condition load-bearing: an **own** declaration only (a
member deprecated *in the protocol* filters symmetrically out of the interface, so no promise exists);
**instance** only (an `implements` check reads no statics); deprecation the **sole blocker** (a
signature that also defers stays deferred — it would name a dispatch entry no table provides).
Population measured corpus-wide before landing (252 frameworks, full-surface `extends`-chain mirror of
what `tsc` sees): **exactly these 4 members**, and zero members missing from any promised conformance
for any other reason. Corpus gate: TS2420 2 → 0.

Rejected (for the carve-out): **degrading the conformance off the class** (violates this very
section's conformance-honesty guard — a legal `id<NSLocking>` call taking a wrapped
`NSManagedObjectContext` would fail `tsc`, the exact bug shape the guard exists to prevent, and a
caller who still wants the working `lock`/`unlock` loses both the members and the documented
conformance); **a named, counted gate exception** (the surface stays dishonest in both directions and
every future gate reader must carry the exception).

#### 4c. The class-name collapse resolves by rendering, not by dropping

*(settled `protocol-class-name-collapse-k90`, 2026-07-13.)* **ObjC has two namespaces, TypeScript has
one.** Five names in the corpus are declared as both a class and an emittable protocol (`CIFilter`,
`NSAccessibilityElement`, `NSTextAttachmentCell`, `AVVideoCompositionInstruction`, `FIFinderSync`,
measured over the whole 252-framework corpus, whole-program and stable across regeneration). Left alone,
the interface and the class each declare a top-level identifier of the same name in their own file, and
the framework barrel's `export * from` of both makes the name ambiguous (TS2308) — **AppKit's own
barrel did not compile.**

**Re-encode, not drop.** A protocol whose name a *declared class* also carries renders its own
interface declaration as `<Name>Protocol` — `NSTextAttachmentCellProtocol`, the same convention Swift's
own ObjC importer already uses for exactly this clash (`NSObject` protocol → `NSObjectProtocol`). One
predicate, `protocol_type_name` (`emit-typescript/src/protocol_binding.rs`), five readers: the interface
declaration itself, a protocol `extends` base, a class `implements` clause, a bound `id<P>` qualifier's
rendered token (§4b), and the type-only import set. Because the collision resolves by rendering, §4b's
class-name-collapse guard is gone: a colliding name **binds** like any other qualifier, just under its
re-encoded identifier — it was never actually necessary to lose the interface, only to spell it
differently. Every re-encoded name is counted at the **declaration** level in the generate pass log
(`renamed_protocols`), independent of how many `id<P>` positions ever reference it: the committed corpus
re-encodes exactly the 5 names above, all same-framework.

Rejected: **drop** — the colliding protocol is not emittable, the class wins the name (ADR-0055 §1's
mirror-the-graph makes it the primary surface). Simpler, but it is a **strictly worse API**: it loses 5
interfaces and every conformer's `implements` clause for no reason a re-encoding does not already avoid,
and — per k90's own measurement — the emittable subset of the colliding population can only grow as the
method frontier widens (blocks, raw pointers), making the lost surface larger over time, not smaller.

**The collision reaches further than rendering — into the shared IR's own origin-tracking**
(`typecheck-gate-post-k86-residuals-k110`, 2026-07-15). `NSTextAttachmentCell` (`@interface
NSTextAttachmentCell : NSCell <NSTextAttachmentCell>`) declares **zero** members of its own — every
required method the protocol demands must come from `resolve`'s protocol-flattening — but the class's
`implements NSTextAttachmentCellProtocol` rendered with 9 of its 9 required members **missing**.
Root cause, at `semantic/tools/resolve/src/checkpoint.rs`, not the TS emitter: a flattened
`effective_method` row's `origin` field is set only `if origin != class` — a **plain string
comparison** between the raw ObjC name that owns the row (here, the *protocol* `NSTextAttachmentCell`)
and the class currently being built (`NSTextAttachmentCell`), same string, different namespace. The
comparison can't tell "the class declared this itself" from "a same-named protocol's requirement
flattened onto it," so the flattened row's `origin` was silently left `None` — indistinguishable, to
every downstream reader (TS's `class_surface::bound_methods` treats `origin: None` as "the class's own
method, already covered"), from a genuine own declaration, even though `cls.methods` never held it at
all. **Fixed at the same layer the bug lives in**: `method_index` — the `(class, selector,
is_class_method)` index `method_decl` itself populates — already answers "did the class truly declare
this selector," so `checkpoint.rs` now asks that instead of comparing name strings. Cross-target (the
IR is target-blind, ADR-0011): confirmed no goldens moved for chez/gerbil/racket/sbcl on regeneration
(the same review discipline `objc-object-type-lowering-golden-review-k107` established), because none
of their own protocol-flattening paths happened to be exercising this exact same-named-class-and-owner
shape's 5 corpus members over the same rendering machinery.

**A second, independent gap in the same neighbourhood: required-ness must be asked of every conformed
protocol, not only the one `resolve`'s residual dedup happened to keep** (same leaf). `resolve` flattens
*both* required and optional protocol members alike (it has no concept of "required" at all — that
distinction lives only in each target's own registry, built from `Protocol.required_methods`/
`optional_methods`) and collapses a same-selector, same-deprecation-status collision **across multiple
conformed protocols** to exactly one surviving origin (`checkpoint.rs`'s residual dedup, this section's
neighbour above). `NSTextView` conforms directly to three protocols all declaring
`doCommandBySelector:` — `NSTextInputClient` (required), `NSTextInput` (deprecated, already excluded by
the precedence rule), `NSStandardKeyBindingResponding` (**optional**) — and the surviving origin
(alphabetically first among the non-deprecated pair) was the **optional** one, so `bound_methods`'s
`ProtocolRegistry::is_required_method(origin, …)` check — asked only of that one surviving origin —
answered `false` and silently dropped a member the `implements NSTextInputClient` clause promises.
Fixed by asking the question of **every** protocol in the class's own `conformance_closure`, not just
the surviving `origin`: "required by *some* conformed protocol" is the honest question, independent of
which declaration `resolve`'s dedup happened to keep. TS-only (`class_surface::bound_methods`) — the
required/optional distinction never reaches the shared IR, so no other target's rendering could be
affected by this gap in the first place.

The negative control — a fixture framework declaring a class `Foo` and a protocol `Foo`, asserting the
barrel's two files never export the same top-level identifier — lives in `emit_framework.rs`'s test
suite (there was none before k90; the collision shipped in silence for want of it).

### 5. Value types — the two-population split

Following the ADR-0042 population split, in TS idiom:

- **POD C/ObjC aggregates** (`CGRect`, `NSRange`, `NSPoint`, `NSSize`,
  `CGAffineTransform`) → **plain TS object types passed by value**, no handle, no
  disposal. This matches how the substrate marshals them (spike probe 1: `-[NSScreen frame]`
  arrives as a plain object, marshalled natively below the runtime's view — ADR-0054 §4).
- **Swift-native value structs** (`objc_exposed == false`, population B: `IndexSet`,
  `CharacterSet`, `URLComponents`, `Measurement`) → **branded disposable handle
  classes** — the sbcl `ns:value-struct` projection (ADR-0042) in TS idiom. They have no
  flat C-ABI form and carry Swift-native methods reachable only via trampolines, so they
  ride the same branded-handle path as objects, with disposal.

Rejected: one uniform "all structs are classes" representation — heavyweight for
by-value geometry and adds bogus disposal to lifetime-less values.

#### 5a. The JS object mirrors the C struct — so `CGRect` is nested

*(settled `pod-struct-types-k73`, 2026-07-11.)* The population-A set is **closed and fixed** — nine
aggregates: `CGRect`, `CGPoint`, `CGSize`, `NSRange`, `NSEdgeInsets`, `NSDirectionalEdgeInsets`,
`NSAffineTransformStruct`, `CGAffineTransform`, `CGVector` (the NS/CG typedef-equivalent spellings
canonicalise to one name per *memory layout*, not per framework). One rule fixes every member's
shape: **the JS object has the C struct's own field names, in the C struct's own nesting.** Eight are
flat because their C structs are; **`CGRect` is nested** — `{ origin: { x, y }, size: { width, height } }`
— because `struct CGRect { CGPoint origin; CGSize size; }` is.

The rule is not cosmetic fidelity. It is what makes the geometry **compose**: `r.origin` *is* the
very `CGPoint` that `-[NSView setFrameOrigin:]` takes, so a frame read from one method feeds another
with no hand-spreading. A flattened `{x,y,width,height}` would buy one fewer object per crossing and
cost the whole composition — and would make the family rule "mirror the C struct, *except* CGRect",
an exception every future reader must be told about.

They are **defined by the runtime** (`@apianyware/runtime`, `structs.ts`), beside `NSObject` and
`Result<T>` — the third thing an emitted framework may name without owning. Keyed by layout rather
than framework, one `CGRect` serves AppKit, Foundation and CoreGraphics alike; a per-framework
`structs.ts` would duplicate the nine and would have to answer an ownership question the IR cannot
(who owns `CGRect` when CoreGraphics is not in the emit set?). A POD carries no runtime value, so
every reference imports **type-only** — no resolver, no runtime edge, nothing to route.

One predicate decides POD membership (`ffi_type_mapping::pod_type_name`), and the **type surface
consults it**, so the token a signature renders and the name its import block spells are the same
string by construction — the §1b/§2b "a lossy or duplicated decision is the bug shape" discipline,
here made structural. All three emitters (`emit_class`/`emit_dts`, `emit_functions`, `emit_protocol`)
route through it; the geometry free functions (`NSContainsRect`, `NSInsetRect`, …) are the corpus's
densest POD population and the reason this is a whole-corpus compile blocker rather than a corner
case.

At the boundary a reader defaults a missing or non-numeric field to **0** — a JS-side typo surfaces
as zeroed geometry, never a crash (`napi_support.swift`; a failed property lookup clears the
exception V8 leaves pending, or the next field read would be undefined behaviour). The *real* guard
is therefore the type surface: `tsc` rejects a flat rect at every call site, which is what makes
these shapes checked rather than merely intended.

### 5b. A `Class` value is the bound constructor — a name-keyed registry

*(added `sel-classref-surface-k72`, 2026-07-11 — §1 fixed how a class is **declared**; this is
how a `Class` **value** crosses.)*

An ObjC `Class` metatype (`+[NSBundle bundleForClass:]`, `NSClassFromString`, `-[NSObject
class]`) surfaces as **`typeof NSObject`** — the bound TS constructor — in both directions:

- **In** (a `Class` argument): `__classArg(cls)` resolves the constructor to its `Class` handle.
- **Out** (a `Class` return): `__classCtor(id)` resolves the handle back to the constructor, so
  `x === NSView` holds and its statics compose — the §1 "mirror the graph" promise applied to a
  class *value*, not just a class *declaration*.

The mechanism is a **name-keyed registry**: each emitted class registers itself from an ES2022
**static block** in its own body (`static { __registerClass('NSScanner', NSScanner); }`) — the
gerbil `register-objc-class!` (ADR-0020) / sbcl `*objc-class-registry*` (ADR-0034) convention in
TS idiom. A static block is retained by any bundler that keeps the class and is absent from the
`.d.ts`, so the declaration surface stays free of dispatch internals (§2). Registration records a
**thunk**, so importing a framework barrel costs **zero** native crossings.

This does not breach §2's dumb-runtime rule, which bars the NativeScript tax — consulting a
*metadata table to discover a signature on every dispatch*. It does not bar name-keyed maps; the
runtime already requires one at the wrap boundary (`Map<id, WeakRef>`, ADR-0057 §3).

A handle whose class is **unregistered** — its module was never imported, or the class is private
and absent from the IR (`-[@"x" class]` is `NSTaggedPointerString`, which no binding declares —
the *common* case for `-[NSObject class]`, not an edge case) — resolves to a **stand-in**: a real
`NSObject` subclass carrying the true handle, with a stable identity, which upgrades to the
genuine constructor if its module is imported later. It therefore round-trips soundly rather than
degrading to `NSObject` (the *wrong* class, silently) or to `null` (losing a perfectly good one).

Neither a `Class` nor a `SEL` is ever **wrapped** in the ADR-0057 sense — no retain, no uniquing,
no disposal (retaining a `Class` leaks; `objc_retain` on a `SEL` is UB). Both stay on the
non-folding, non-wrapping `_n` dispatch entries (ADR-0057 §4); the conversion is purely
`.ts`-side, so the native tables are untouched.

**The registry also serves the *instance* wrap boundary** (added `dynamic-class-wrap-k88`, 2026-07-12).
§5b built it to resolve a `Class` **value**; the same map answers "what class is *this object*?" —
`object_getClass`, then climb to the nearest bound ancestor — which is what lets a slot the IR names no
class for (a bare `id`) wrap into something that actually carries the object's methods, rather than a bare
root. The rule, the class-cluster reason the climb is mandatory, and the cost are **ADR-0057 §3b**; the
stand-in for a wholly-unbound hierarchy is §5b's, unchanged. One registry, two boundaries — a type
reference (§1b) and a value (§3b/§5b) resolve class membership the same way, by construction.

Rejected: a **branded opaque `ClassHandle`** — honest about the type but inert: it composes with
nothing (`[[obj class] alloc] init]` becomes impossible), gives no `===` against a bound class,
and would add a third handle population §5 does not have.

### 6. Enums, constants, nullability, construction

- **Enums:** `NS_ENUM` / `NS_OPTIONS` → real TS **`enum`** (named members; NS_OPTIONS
  used with bitwise `|`). Best member discoverability and matches NativeScript's surface.
  `const enum` is avoided (breaks `isolatedModules`/bundlers).
- **Constants:** non-pointer constants → plain exported `const`; **pointer-valued**
  constants (`NSString * const NSFontAttributeName`) cannot be literals (ADR-0025), so
  they are fetched through the addon and exposed as module-load-initialized typed
  `const`s. A pointer-valued constant is further split by **ownership**, not just shape:
  an ObjC-**object** global (`Class`/`Id`/`Instancetype`) is wrapped and its addon read
  folds a `+1` retain; an **opaque** pointer global (a raw C pointer, a block singleton —
  never an object) is exposed as a bare `bigint` and its read never retains (ADR-0057 §4,
  third channel, `pointer-constant-ownership-k92`) — retaining a non-object dereferences a
  nonexistent `isa`.
- **Nullability:** ObjC `_Nullable`/`_Nonnull` + the LLM annotation overlay drive
  `T | null` / `T`; absent/unknown defaults to `T | null` (safe, tightened by the
  overlay). This turns on TS strict-null-checking across the whole surface — a headline
  correctness win no prior target gets.
- **Construction:** the faithful **`alloc`/`init`** surface
  (`NSView.alloc().initWithFrame_(rect)`, each `init…` a normal method returning the
  polymorphic **`this`**, identically in the `.ts` and the `.d.ts`, resolved through the
  same dynamic ctor-registry lookup §5b/ADR-0057 §3b give a class-less `id` return
  (`override-signature-mismatch-k100`, 2026-07-14) rather than the concrete declaring
  class — the faithful reading of `instancetype` itself ("whatever `self`'s real dynamic
  class is"), and what keeps an inherited `init…`'s return assignable to a `this`-typed
  ancestor/protocol member (TS2416 caught the concrete-class rendering a prior revision
  used for cast-free body typing); the class's TS `constructor` is **internal** (wraps a
  handle), not the public creation path (there is no single canonical init to map `new
  NSView(…)` onto). Convenience constructors are a deferred polish, not baseline.

### 7. The instance is a branded, disposable handle

An instance carries the ObjC `id` as an **opaque branded handle** — branded at the type
level so a `NSString` handle is not assignable to an `NSArray` parameter despite both
being pointers. The base `NSObject` class hosts the disposal hook. This ADR fixes the
*representation* (branded handle, disposal hook on the root class); the **lifetime
contract** — deterministic `Symbol.dispose`/`using` as the primary release, a best-effort
`FinalizationRegistry` backstop, the uniform-+1 JS↔ObjC retain/release seam with wrapper
uniquing, and the lean ambient autorelease-pool model — is **settled by ADR-0057**, which
the research (D4/C4) pre-judged and MacRuby's GC→ARC death red-lined.

## Considered options

- **Namespaces-of-procedures (the Scheme `objc-object` shape).** Rejected §1 —
  un-idiomatic for a statically-typed target, no autocomplete, and it forfeits the `.d.ts`
  class surface that is this target's headline deliverable.
- **Runtime-synthesized classes + `.d.ts`-only (NativeScript).** Rejected §2 — the
  per-call metadata-consult tax the substrate was chosen to avoid.
- **camelCase colon-elision selector names (JSExport/NativeScript).** Rejected §3 —
  non-injective; the structure-preserving rule needs zero collision machinery and stays
  consistent with ADR-0039.
- **Uniform struct-as-class.** Rejected §5 — heavyweight for POD geometry.

## Consequences

- **`emit-typescript`** generates: per-framework class-body modules (static, one file
  per class), the protocol interfaces, enums/constants, and the `.d.ts` for all of it — from
  the same IR pass that drives the ADR-0054 dispatch entries. It **references** the POD
  geometry types (§5a) but does not generate them: the closed nine are runtime-owned, and an
  emitted artifact imports them type-only.
- **The emitter carries a whole-program declared-class recognition set** (§1b), built by the
  generate CLI beside the class/enum/protocol ownership registries and rebuilt identically by
  every native-table collector — the two must agree, or they would admit different methods and
  break the collected==referenced mirror. **Import honesty** follows from it as a checkable
  property: an emitted artifact may only value-import a class the IR declares, the runtime root,
  or its (bare-node-backed) superclass.
- **The runtime library** owns: the branded-handle wrapper + `__wrap`/`__unwrap`, the nine
  **POD geometry types** (§5a, `structs.ts` — pure types, imported type-only), the
  `ValueStruct` base for population-B structs, the disposal hook shape (contract in Q3),
  and module wiring for per-framework imports.
- **Hard to reverse:** the ES6-class-mirror shape, static emission, the underscore
  selector rule, the interface/`implements` protocol model, the struct split, and the
  branded-handle instance are baked into the emitter, every generated module, every
  sample app's source, and the `.d.ts` consumers. The TS target design spec (assembled
  by the emitter build leaf) documents them.
- **Boundaries to sibling decisions.** The per-signature dispatch crossing is ADR-0054;
  lifetime/disposal is ADR-0057; errors ADR-0058; callbacks/delegates/subclassing ADR-0059; distribution
  Q7; threading/runloop ADR-0056. Applies ADR-0010
  (native library is the binding) and ADR-0025 (trampoline elision), target-local under
  ADR-0011.

See ADR-0054 (the substrate this surface sits on), ADR-0034 + ADR-0020 (the CL/gerbil
"mirror the graph" precedent), ADR-0042 (the value-struct population split), ADR-0039
(the selector-structure-preserving rule), ADR-0025 (elision + pointer constants),
ADR-0010/0011 (north star + isolation), `CONTEXT.md` (*TypeScript target toolchain*),
and `targets/typescript/docs/research/2026-07-05-js-objc-bridge-prior-art.md` (§Synthesis
D3, §C3 objc2, §B1 NativeScript, §B2 PyObjC) for the prior-art evidence.
