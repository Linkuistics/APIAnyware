# CL-Cocoa bridges across the CL family — prior art for the `sbcl` target

**Status:** research finding (commissioned by grove `add-sbcl-clos-target`, leaf
`020-research-cl-cocoa-bridges`). Feeds `030-design`: the SBCL MOP object model
and the CL-family interface contract.
**Date:** 2026-06-15.
**Method:** fan-out web search → source fetch → 3-vote adversarial verification
(a claim is killed only on ≥2/3 refutes) → synthesis. 5 angles, 22 sources
fetched, 104 claims extracted, 25 verified, 23 confirmed, 2 killed. Evidence is
**strongly CCL-centric** (15 of 23 confirmed claims describe CCL) — see
[§6 Gaps](#6-gaps-absences-are-findings).

> **How to read this doc.** Every load-bearing claim carries a primary-source
> citation. Where the verification stage *refuted* a tempting claim, that is
> recorded as a finding (§5), because a refuted-but-plausible claim is exactly
> what would otherwise mislead the 030 grilling. Where the corpus was *silent*,
> that silence is recorded as a gap (§6), not glossed. The doc closes with
> **[§7 Synthesis for 030](#7-synthesis-for-030)** pre-judging what the evidence
> settles, and a **family-roster recommendation**.

---

## Headline

**Clozure CL (CCL) is the only production-grade, currently-maintained CL/Cocoa
bridge, and it already implements almost exactly the metaclass-projection object
model the SBCL target proposes.** ObjC classes become CLOS classes whose
metaclass is an instance of `OBJC:OBJC-METACLASS`; ObjC ivars become foreign
CLOS slots reachable through `SLOT-VALUE`; multi-component selectors map to
keyword lists; `MAKE-INSTANCE` is wired to `alloc`/`init`; and the class graph is
synthesized **dynamically from the live ObjC runtime**. LispWorks ships a second
production bridge that deliberately takes a **weaker, non-metaclass** route. The
dormant **Objective-CL** library is direct prior art that *one portable contract
can span the whole family* — it targeted six CL systems and borrowed CCL's
conventions — and its per-impl breakage notes are the best evidence of what
MOP/FFI divergence *costs* a portable contract.

**Two structural facts dominate the design:**

1. **Every mature bridge is `libobjc`/`objc_msgSend`-based, hence ObjC-only.**
   None reach Swift-only APIs. This is the gap APIAnyware's per-target **Swift
   library** is meant to close (see the 030 design-input on coverage +
   convergence) — and it means the prior art, however deep, stops at the ObjC
   ceiling. Borrow CCL's *surface*, not its *reach*.
2. **No mature bridge has a truly static class graph.** CCL even *reconstructs*
   classes at image startup (`revive-objc-classes`). A static-emit model must
   bake in class identity, ivar offsets, and selector strings at generation
   time, then re-resolve live `Class`/`SEL` pointers at process startup. This is
   the central static-vs-dynamic tension for `040`/`050`.

---

## Part A — Landscape & family membership

### A1. macOS/arm64 availability + bridge maturity

| Impl | macOS arm64 | ObjC/Cocoa bridge maturity | Evidence |
|---|---|---|---|
| **SBCL** | Yes (native arm64) | **None first-party** — `sb-alien` FFI only; third-party `objc-lisp-bridge` exists but is not a CLOS-projection bridge | Corpus silent on a first-party SBCL ObjC bridge (a finding); `objc-lisp-bridge` listed as a source ([fiddlerwoaroof/objc-lisp-bridge](https://github.com/fiddlerwoaroof/objc-lisp-bridge)) |
| **CCL** | Yes | **Production-grade**, ~20 yr, the deepest prior art | CCL manual ch.14–15; `objc-runtime.lisp`, `objc-clos.lisp` |
| **LispWorks** | Yes | **Production-grade but non-metaclass** (CAPI runs over Cocoa; `define-objc-class` makes a plain `standard-class`) | [LW 8.1 ObjC ref-7](https://www.lispworks.com/documentation/lw81/objc/objc-objective-c-ref-7.htm) |
| **AllegroCL** | **Qualified** — native arm64 only from Allegro **11.0**; in 2021 it was Rosetta-only (x86_64) | **Bridge maturity not established by this corpus** (platform availability only) | [Franz Apple-Silicon page](https://franz.com/support/apple_silicon.lhtml), [Allegro 11.0 notes](https://franz.com/support/documentation/11.0) |

> **Finding (absence).** The corpus gives **no** primary evidence on AllegroCL's
> *ObjC/Cocoa bridge* maturity — only that the platform exists natively from
> v11. Treat AllegroCL's Cocoa story as **unverified** going into 030.

### A2. Usage survey & other impls (ECL / ABCL / Clasp)

- **Who actually does macOS Cocoa work in CL today:** CCL (the reference case —
  its IDE *is* a Cocoa app) and LispWorks (CAPI-over-Cocoa). Commercial Cocoa-CL
  product evidence is thin in this corpus; Opusmodus (a LispWorks-based macOS
  music app) surfaced as a secondary data point
  ([Wikipedia: Opusmodus](https://en.wikipedia.org/wiki/Opusmodus)).
- **ECL / ABCL / Clasp:** **no supporting evidence either way** in this corpus.
  This is an absence, **not** a positive exclusion. Recommendation (§7): keep
  them out of the *confirmed* roster for lack of a production Cocoa bridge, but
  do not claim they *cannot* be added — the door stays open if the contract is
  abstract enough.

### A3. AMOP conformance per impl

- **The portability cost is real and documented.** Objective-CL's own notes are
  the post-mortem: CMUCL's MOP **lacked funcallable-instance-function closures**;
  LispWorks' FFI was **incompatible with the GNU ObjC runtime**; CCL **hung** in
  `collect-classes` during its port ([Objective-CL](https://matthias.benkard.de/objective-cl/)).
  These are MOP/FFI-divergence failures — exactly what a portable MOP contract
  pays for.
- **`closer-mop` is the portability shim of record** across SBCL/CCL/Allegro/
  LispWorks/etc. ([pcostanza/closer-mop](https://github.com/pcostanza/closer-mop)),
  evidence that AMOP divergence is normally *papered over by a compatibility
  layer*, not assumed away.
- **SBCL's own AMOP conformance for the specific hooks the contract needs**
  (`validate-superclass`, `allocate-instance`, `compute-effective-slot-definition`,
  `slot-value-using-class`, `ensure-class`) is **not** addressed by any confirmed
  claim — a gap (§6) that 030 must close first-hand against `sb-mop`.
- **LispWorks diverges structurally** (non-metaclass; ivars declared separately —
  see B1). So the contract cannot assume a uniform metaclass/MOP mechanism across
  all four; it must either mandate the MOP projection and treat LispWorks as a
  documented fallback, or define the contract abstractly enough that LispWorks'
  `standard-class` + `:objc-instance-vars` satisfies it (open question, §7).

---

## Part B — Deep bridge prior art

### B1. ObjC class → CLOS class representation

**CCL (confirmed, 3-0).** Each ObjC class is a CLOS class whose **metaclass is an
instance of `OBJC:OBJC-METACLASS`**. The metaclass tower is rooted at
`objc:objc-class-object` (a subclass of `foreign-class` and `objc:objc-object`),
with concrete metaclasses `objc:objc-class` and `objc:objc-metaclass`. Per-class
state lives in slots `foreign` (the ObjC `Class` macptr) and `peer`.

> Manual ch.14.2 verbatim: *"the metaclass is an instance of the class
> `OBJC:OBJC-METACLASS` and the class is an instance of the metaclass."*
> `objc-clos.lisp` r6898 defines `(defclass objc:objc-class-object (foreign-class
> objc:objc-object) ((foreign …) (peer …)))`.

Sources: [manual ch.14.2](https://ccl.clozure.com/manual/chapter14.2.html),
[objc-clos.lisp r6898](https://trac.clozure.com/ccl/browser/trunk/ccl/objc-bridge/objc-clos.lisp?rev=6898),
[objc-runtime.lisp r7340](https://trac.clozure.com/ccl/browser/branches/ia32/objc-bridge/objc-runtime.lisp?rev=7340).
**This metaclass tower is the contract's object-model centerpiece and is
borrowable directly** for SBCL.

**Class identity is dynamic, not baked (confirmed, 3-0).** `Class` pointers are
`macptr` foreign pointers registered into a runtime map (`register-objc-class` /
`objc-class-map`) assigning small integer IDs via splay trees keyed on pointer
identity. *(Version note: later CCL master migrated this map from splay trees to
hash tables — cite as version-pinned behaviour, not "CCL always.")*
→ **Static-emit implication:** the emitter must assign and bake class IDs/identity
at *generation* time rather than at registration time.

**LispWorks (confirmed, 3-0): the divergent shape.** `define-objc-class` makes a
plain **`standard-class`** (no special metaclass, no `:metaclass`, no
`foreign-class`) that must have **`standard-objc-object`** in its class
precedence list (the default superclass). Native ObjC ivars are declared
**separately** via the `:objc-instance-vars` option as `(ivar-name ivar-type)`
FLI-typed pairs, with ivar inheritance kept separate from Lisp-slot inheritance.
Source: [LW 8.1 ObjC ref-7](https://www.lispworks.com/documentation/lw81/objc/objc-objective-c-ref-7.htm).
→ **Contract implication:** the metaclass/MOP approach is **not universal**; the
contract's metaclass section needs a documented LispWorks-style fallback (or must
accept that LispWorks satisfies it via a different mechanism).

### B2. ObjC instance & ivar representation

**CCL (confirmed, 3-0).** ObjC ivars are projected as CLOS **direct slots**
(`foreign-direct-slot-definition`) carrying a `foreign-type` and an explicit
**bit-offset**, `:allocation :instance`, mirroring the ObjC ivar layout from
foreign type info. They are read and (with care) **set through `SLOT-VALUE`**.

> Manual ch.14.2: *"`SLOT-VALUE` can be used to access (and, with care, set)
> instance variables in Objective-C instances."* `objc-runtime.lisp` r7340's
> `compute-objc-direct-slots-from-info` iterates the class's ivars and builds
> `(make-instance 'foreign-direct-slot-definition … :foreign-type type
> :bit-offset offset :allocation :instance)`.

Sources: [ch.14.2](https://ccl.clozure.com/manual/chapter14.2.html),
[ch.14.5](https://ccl.clozure.com/manual/chapter14.5.html),
[objc-runtime.lisp r7340](https://trac.clozure.com/ccl/browser/branches/ia32/objc-bridge/objc-runtime.lisp?rev=7340).

> **⚠ Mechanism unconfirmed — refuted claim (§5).** The stronger claim that CCL
> implements this via **`slot-value-using-class` + `compute-foreign-slot-accessors`**
> (the exact MOP hook the SBCL contract names) was **refuted (1-2)**. The
> `SLOT-VALUE` → ivar *mapping* is confirmed; the *mechanism* (whether it routes
> through `slot-value-using-class` or through computed accessor functions) is
> **not** established and must be re-derived first-hand for SBCL — do not assume.

### B3. Method exposure & dispatch

**CCL (confirmed, 3-0).** Method dispatch **lowers to ObjC runtime message
sends** — foreign calls to `_objc_msgSend`, with selectors cached in
`*objc-selectors*` (a hash table of `objc-selector` structs holding a name + a
cached `%sel` pointer). Dispatch is **single-receiver ObjC dispatch, not CLOS
multiple dispatch.**

> r7340: the `objc-message-send` macro expands to `(%ff-call (%reference-external-entry-point
> (load-time-value (external "_objc_msgSend"))) …)`; `%get-SELECTOR` lazily
> resolves and caches the `%sel` pointer.

Source: [objc-runtime.lisp r7340](https://trac.clozure.com/ccl/browser/branches/ia32/objc-bridge/objc-runtime.lisp?rev=7340).
→ **Contract implication:** selectors are resolved **at runtime**; a static
emitter can pre-register selector *strings* but the `%sel` pointer is still
runtime-bound (re-resolved at startup).
→ **Naming convention (confirmed, 3-0):** multi-component selectors map to a
**sequence of keyword symbols**, one per component
(`nextEventMatchingMask:untilDate:inMode:dequeue:` →
`(:next-event-matching-mask :until-date :in-mode :dequeue)`). See C1.

**For the SBCL target's "generics" framing:** note the prior art does **not**
expose one `defgeneric` per selector with CLOS dispatch — CCL keeps ObjC's
single-receiver dispatch and only *wraps* it. The SBCL target's CONTEXT.md
glossary currently proposes `defgeneric`/`defmethod` with native CLOS multiple
dispatch; **that is a divergence from CCL, not a borrow**, and 030 must decide
whether multiple-dispatch generics buy enough idiom to justify departing from the
proven single-dispatch-veneer model (cf. gerbil's "vacuous receiver-only
dispatch" rationale, ADR-0020).

### B4. `make-instance` → alloc/init; subclassing; method definition

**CCL (confirmed, 3-0).**

- **Instantiation:** standard CLOS `MAKE-INSTANCE` (class + initargs), with
  `OBJC:MAKE-OBJC-INSTANCE` as a string-classname alternative. Internally:
  `make-instance` → `allocate-instance` (→ `allocate-objc-object`) →
  `initialize-instance`, and init-keyword initargs become the ObjC `init`
  message via `send-objc-init-message`. *Nuance:* with **no** init initargs the
  object is only `alloc`'d.
- **Subclassing:** `validate-superclass` returns `t` (any ObjC superclass
  allowed); `allocate-instance` on a metaclass enforces **exactly one**
  `objc:objc-class` in the direct-superclasses, then `%allocate-objc-class`; on
  ObjC 2.0 the class is registered with the live runtime via `%add-objc-class`.
- **Methods:** `define-objc-method` (lower-level) and `objc:defmethod`
  (CLOS-`defmethod`-style, supports `CALL-NEXT-METHOD` but "not quite as
  general"). **All parameter types must be explicitly declared.** Keyword method
  names join with colons into a selector. **Methods can only be defined for
  Lisp-created classes**, and every method belongs to a particular class — there
  is **no category-on-foreign-class mechanism**; you subclass and implement on the
  Lisp subclass.

Sources: [ch.14.8](https://ccl.clozure.com/manual/chapter14.8.html),
[ch.14.6](https://ccl.clozure.com/manual/chapter14.6.html),
[objc-clos.lisp r6898](https://trac.clozure.com/ccl/browser/trunk/ccl/objc-bridge/objc-clos.lisp?rev=6898).

**LispWorks (confirmed, 3-0): a static-emit-friendly constraint.** On macOS 10.5+
it is **impossible to define entirely new ObjC formal protocols in Lisp**;
`define-objc-protocol` can only *declare pre-existing* protocols.
Source: [LW 8.1 ObjC ref-10](https://www.lispworks.com/documentation/lw81/objc/objc-objective-c-ref-10.htm).
→ A static emitter that *declares conformance* to existing protocols is **aligned
with**, not fighting, this constraint.

### B5. Static vs dynamic — the central tension

**CCL's class graph is never truly static (confirmed, 3-0).** `revive-objc-classes`
runs at **image startup**, resolving foreign classes that survive into the new
image and **destructively updating** class/metaclass pointer addresses so the
subclass/superclass/metaclass relationships are maintained (registered via
`*lisp-system-pointer-functions*`).

> Manual ch.15.4: on relaunch *"all preexisting classes have their addresses
> updated destructively."*

Sources: [objc-runtime.lisp r7340](https://trac.clozure.com/ccl/browser/branches/ia32/objc-bridge/objc-runtime.lisp?rev=7340),
[manual ch.15.4](https://ccl.clozure.com/manual/chapter15.4.html).

**What a static emit model (D3) must bake in, and what stays runtime:**

| Concern | CCL does (dynamically) | Static emitter must |
|---|---|---|
| Class identity / IDs | assigned at `register-objc-class` time | **bake** IDs + identity at generation time |
| Ivar offsets / slot layout | computed from live foreign type info | **bake** offsets at generation (risk: SDK drift) |
| `Class` pointers | resolved live (`object_getClass`, revive at startup) | **re-resolve at process startup** (cannot bake an address) |
| `%sel` pointers | resolved + cached lazily at runtime | pre-register selector **strings**; resolve `%sel` at startup |
| Class graph | synthesized from the running runtime | emit the graph; still relive pointers on launch |

→ **The takeaway for `save-lisp-and-die` (070):** a dumped SBCL image carries
*baked* class metadata but **stale foreign pointers**. The runtime needs a
CCL-`revive-objc-classes`-equivalent startup pass that re-resolves every
`Class`/`SEL` from its baked string identity. This is a load-bearing `050`
requirement, directly precedented by CCL.

→ **Where the Swift library changes the calculus:** because APIAnyware reaches
Cocoa through an **emitted Swift library** (not in-image `objc_msgSend`
open-coding), much of the "relive every pointer" burden can move into the Swift
library's own load-time setup, and Swift-only APIs (invisible to all message-send
bridges above) come into reach. The prior art does not cover this — it is
genuinely new ground for the family, and the reason the borrowed surface (CCL's)
outlives the borrowed *mechanism* (CCL's runtime message-send core).

---

## Part C — Contract surface & cross-impl portability

### C1. User-facing surface (adopt CCL's conventions vs define our own)

**CCL's documented surface (confirmed, 3-0)** — the concrete candidate to adopt:

- **`ns:` package**, NS prefix **retained**, the rest **kebab-cased**:
  `NSOpenGLView` → `ns:ns-opengl-view`; `NSURLHandleClient` →
  `ns:ns-url-handle-client`.
- **Multi-letter acronyms are whole words**, not split per capital — this
  matters (see §5: the naive "hyphen-before-each-capital" rule was **refuted**).
  The contract's name mapper must special-case acronym prefixes (`NS`, `URL`, …).
- **Selectors** → keyword-list (B3). CCL additionally provides the **`#/`** and
  **`@`** reader macros for selector / NSString literals; Objective-CL
  deliberately adopted CCL's `#/`.

Source: [manual ch.14.8](https://ccl.clozure.com/manual/chapter14.8.html).

**Recommendation pre-judged (see §7):** **adopt CCL's `ns:` package + naming +
`#/`/`@` reader-macro conventions** as the contract surface. They are documented,
production-proven, and already the de-facto multi-impl standard (Objective-CL
borrowed them). Defining our own would forfeit de-facto portability with existing
CL-Cocoa code for no idiom gain.

### C2. Error handling / `NSError**` condition hierarchy

> **Finding (absence).** **Zero confirmed claims** in this corpus address how any
> impl maps `NSError**` (or ObjC exceptions) to CL conditions / restarts /
> multiple values. The contract's condition hierarchy — a *named* contract
> element in the SBCL glossary — is **un-evidenced prior art** and must be
> designed in 030 largely first-principles (informed by reading CCL's
> `error`/condition handling in source, not by this survey).

### C3. Existing cross-impl contract to borrow

**Objective-CL is the direct precedent (confirmed, 3-0).** An explicitly
multi-implementation CL/ObjC bridge targeting **six** CL systems (Allegro CL,
Clozure CL, CMUCL, GNU CLISP, LispWorks, SBCL), mapping ObjC classes **and
metaclasses** onto CLOS classes, and **deliberately adopting CCL's `#/`** selector
reader macro.

> Project page: *"Objective-C classes are mapped to CLOS classes. The same is
> true for metaclasses"*; 0.2.0 (2008): *"Clozure-CL-like method call syntax via
> the `#/` reader macro is supported."*

Sources: [Objective-CL](https://matthias.benkard.de/objective-cl/),
[mac_define-objective-c-method](https://matthias.benkard.de/objective-cl/documentation/mac_define-objective-c-method.html),
[GNUstep wiki](https://mediawiki.gnustep.org/index.php/Objective-CL).

**Caveats (these are the post-mortem value):** Objective-CL is **dormant** (last
release 0.2.2, 2008; Mac OS X/PowerPC + Linux/GNUstep only; **no arm64**). Its
"six implementations" is **partly aspirational** — the project page documents
real per-impl breakage (CCL hung in `collect-classes`; CMUCL's MOP lacked
funcallable-instance-function closures; LispWorks' FFI was incompatible with the
GNU ObjC runtime). Its **primary** native syntax is Smalltalk-style
`[recv msg:]`; `#/` is an *optional additional* form.

→ **What this proves for D5:** a single portable contract spanning the family is
**established practice, not novel** — but the failure mode is concrete: **MOP/FFI
divergence breaks per-impl**, and the only sustainable cross-impl surface is the
*spec-level* one (package, names, reader macros), never shared binding code.
This is direct, primary-source corroboration of the CL-family-contract thesis
(spec shared, implementation hermetic) — and of why the **Swift-library C-ABI**,
not a shared Lisp core, is the right convergence substrate.

---

## Part D — Lifetime / threading / callbacks

> **Finding (absence).** Both D-questions are **under-evidenced** — no confirmed
> claim in this corpus directly establishes:
>
> - **D1** — per-impl ObjC retain/release vs CL GC, finalizers, weak refs,
>   autorelease-pool conventions. (CCL manual ch.7/ch.15 were *fetched* as
>   sources but produced no *verified* lifetime claim.)
> - **D2** — callbacks on foreign (AppKit) threads, main-thread affinity, and
>   `sb-thread`/Bordeaux-Threads activation.
>
> These must be resolved in 030 by **reading CCL's `ccl::with-autorelease-pool`,
> `terminate-when-unreachable`, and the event-loop / `#/performSelectorOnMainThread`
> machinery first-hand**, plus the APIAnyware precedents already in-repo: racket
> ADR-0014 + gerbil ADR-0022 (main-thread bounce) vs chez ADR-0016. The prior-art
> survey does **not** de-risk these; the in-repo ADRs do more here than this doc.

---

## 5. Refuted claims (recorded as findings)

The verification stage killed two plausible-but-wrong claims. Both matter because
each would have mis-steered 030:

1. **"CCL maps ivar `slot-value` via `slot-value-using-class` +
   `compute-foreign-slot-accessors`"** — **refuted (1-2)**. The mapping exists;
   the *mechanism* (the named MOP hook) is **not** confirmed. → 030 must
   re-derive the SBCL slot mechanism first-hand, not assume `slot-value-using-class`.
2. **"Class names map by inserting a hyphen before each embedded capital +
   lowercasing"** — **refuted (1-2)**, because `NS` (and other multi-letter
   acronyms) are treated as **whole words**. → the contract's name mapper must
   special-case acronym prefixes.

## 6. Gaps (absences are findings)

Recorded so a future reader does not re-run the same fruitless search:

1. **SBCL's own AMOP conformance** for the contract's hooks
   (`validate-superclass`, `allocate-instance`,
   `compute-effective-slot-definition`, `slot-value-using-class`, `ensure-class`)
   — no confirmed claim; verify first-hand against `sb-mop` in 030.
2. **CCL's precise ivar mechanism** (§5.1) — re-verify against *current* source
   (the cited revs are old; `objc-class-map` has since changed splay→hash).
3. **Error handling / `NSError**` → conditions** (C2) — no evidence; design
   first-principles in 030.
4. **Lifetime + threading/callbacks** (D1/D2) — no evidence; rely on in-repo ADRs
   + first-hand CCL source reading.
5. **AllegroCL bridge maturity** (A1) — platform-only evidence; Cocoa story
   unverified.
6. **ECL / ABCL / Clasp** (A2) — no evidence either way; absence ≠ exclusion.

## 7. Synthesis for 030

What the evidence **settles** (pre-judged; 030 may still overturn with new
evidence, but the burden is now on the counter-argument):

1. **Object model — borrow CCL's metaclass tower.** Project each ObjC class as a
   CLOS class of an `objc-class`/`objc-metaclass` metaclass holding the `Class`
   macptr; project ivars as foreign direct slots with baked bit-offsets reachable
   via `SLOT-VALUE`. This is CCL's proven shape and the SBCL glossary's proposal
   converge — **adopt it.** *(But re-derive the slot *mechanism*, §5.1.)*
2. **Contract surface — adopt CCL's conventions wholesale.** `ns:` package, NS
   prefix retained + kebab-case with **acronym-aware** word breaking, keyword-list
   selectors, `#/`/`@` reader macros. De-facto standard (Objective-CL borrowed
   them); inventing our own buys nothing.
3. **Dispatch — decide deliberately, do not default.** All prior art keeps ObjC
   **single-receiver** dispatch and only veneers CLOS over it. The SBCL glossary
   proposes **multiple-dispatch generics** — a *divergence*. 030 must justify it
   against the gerbil "vacuous receiver-only dispatch" precedent (ADR-0020)
   or fall back to the proven single-dispatch veneer.
4. **Static-vs-dynamic — bake metadata, relive pointers at startup.** No bridge
   has a static graph; emit baked class IDs + ivar offsets + selector strings,
   and add a CCL-`revive-objc-classes`-equivalent **startup re-resolution pass**
   (load-bearing for `save-lisp-and-die`, 050/070).
5. **CL-family contract is spec-level only — corroborated by Objective-CL's
   failures.** A shared *spec* (package/names/macros/conditions) is established
   practice; shared *binding code* breaks on MOP/FFI divergence. This is primary-
   source support for D5 and for the **Swift-library C-ABI as the convergence
   substrate** (the only cross-impl thing that can also reach Swift-only APIs).
   → The new family-axis ADR should cite Objective-CL's per-impl breakage as its
   rationale.
6. **LispWorks is the divergence to design around.** Its non-metaclass
   `standard-class` + `:objc-instance-vars` model means the contract's metaclass
   section needs either a documented fallback or an abstraction both satisfy. **Open
   question for 030** — the evidence shows the divergence but does not resolve which
   shape the contract should privilege.
7. **Three whole question-areas are un-de-risked by this survey** — C2 (conditions),
   D1 (lifetime), D2 (threading/callbacks), plus SBCL's own AMOP conformance.
   030 cannot lean on prior-art here; budget first-hand CCL source reading +
   in-repo ADR precedent for them.

### Family-roster recommendation

| Impl | Verdict | Why |
|---|---|---|
| **SBCL** | **IN — built in this grove** | the target; native arm64; `sb-alien` |
| **CCL** | **IN (confirmed)** | production bridge, arm64, the deep prior art the contract is shaped on |
| **LispWorks** | **IN (confirmed, qualified)** | production Cocoa bridge, arm64 — but **non-metaclass**; the contract must tolerate its shape |
| **AllegroCL** | **IN (qualified — verify in 030)** | native arm64 from v11, but its **ObjC/Cocoa bridge maturity is unverified** by this survey — confirm before relying on it as a contract conformance target |
| **ECL / ABCL / Clasp** | **OUT for now (absence, not exclusion)** | no evidence of a production Cocoa bridge; keep the contract abstract enough not to *forbid* them |

The four-member roster (SBCL, CCL, AllegroCL, LispWorks) stands, with the
**caveat** that only CCL is deeply evidenced; LispWorks' divergence and
AllegroCL's unverified bridge are the two roster risks 030 must carry forward.

---

## Walk-away checks (per bridge)

- **CCL uninstalled:** the *conventions* remain fully legible and borrowable — the
  `ns:` package scheme, kebab+acronym naming, keyword-list selectors, `#/`/`@`
  macros, the metaclass-tower shape, and the `revive-objc-classes` startup-pass
  pattern are documented in the manual and source independent of any running CCL.
  The *mechanism* (runtime `objc_msgSend` core, dynamic class synthesis) does
  **not** carry over to a static-emit + Swift-library target — and is the part we
  deliberately do not borrow.
- **LispWorks uninstalled:** the *lesson* survives — that a production bridge chose
  a **non-metaclass** model, and that new ObjC protocols can't be defined in Lisp
  on 10.5+. Both are constraints a static emitter should respect; neither needs LW
  present to apply.
- **AllegroCL uninstalled:** little is borrowable — no bridge detail was
  established; only the platform-timeline caveat survives.
- **Objective-CL uninstalled:** the highest-value walk-away — its **per-impl
  breakage post-mortem** (MOP/FFI divergence breaks shared binding code) is the
  evidentiary backbone of the spec-only contract decision, and remains legible
  from the dormant project page alone.

---

### Sources (primary unless noted)

CCL manual: [ch.14](https://ccl.clozure.com/manual/chapter14.html),
[14.2](https://ccl.clozure.com/manual/chapter14.2.html),
[14.5](https://ccl.clozure.com/manual/chapter14.5.html),
[14.6](https://ccl.clozure.com/manual/chapter14.6.html),
[14.8](https://ccl.clozure.com/manual/chapter14.8.html),
[15.3](https://ccl.clozure.com/manual/chapter15.3.html),
[15.4](https://ccl.clozure.com/manual/chapter15.4.html),
[7.1](https://ccl.clozure.com/manual/chapter7.1.html),
[CocoaBridge wiki](https://trac.clozure.com/ccl/wiki/CocoaBridge).
CCL source: [objc-clos.lisp r6898](https://trac.clozure.com/ccl/browser/trunk/ccl/objc-bridge/objc-clos.lisp?rev=6898),
[objc-runtime.lisp ia32 r7340](https://trac.clozure.com/ccl/browser/branches/ia32/objc-bridge/objc-runtime.lisp?rev=7340),
[objc-clos.lisp trunk](https://trac.clozure.com/ccl/browser/trunk/ccl/objc-bridge/objc-clos.lisp),
CCL issue [#330](https://github.com/Clozure/ccl/issues/330).
LispWorks: [ObjC ref-7](https://www.lispworks.com/documentation/lw81/objc/objc-objective-c-ref-7.htm),
[ref-10](https://www.lispworks.com/documentation/lw81/objc/objc-objective-c-ref-10.htm),
[lw80 cocoa](https://www.lispworks.com/documentation/lw80/objc/objc-cocoa.htm),
[lw60 objc](https://www.lispworks.com/documentation/lw60/OBJC/html/objc.htm).
AllegroCL: [Franz Apple Silicon](https://franz.com/support/apple_silicon.lhtml),
[Allegro 11.0](https://franz.com/support/documentation/11.0).
Objective-CL: [project](https://matthias.benkard.de/objective-cl/),
[define-objc-method](https://matthias.benkard.de/objective-cl/documentation/mac_define-objective-c-method.html),
[GNUstep wiki](https://mediawiki.gnustep.org/index.php/Objective-CL).
AMOP: [closer-mop](https://github.com/pcostanza/closer-mop),
[bugs-in-common-lisp (blog)](https://john.freml.in/bugs-in-common-lisp).
Other: [objc-lisp-bridge](https://github.com/fiddlerwoaroof/objc-lisp-bridge),
[sbcl-help thread](https://groups.google.com/g/sbcl-help-archive/c/RMNP5Lxdqfk),
[Opusmodus (secondary)](https://en.wikipedia.org/wiki/Opusmodus).
