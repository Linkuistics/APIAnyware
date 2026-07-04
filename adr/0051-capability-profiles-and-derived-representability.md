# Capability profiles and derived representability

**Relates to:** ADR-0046 (spec format / `.apiw` KDL overlays / generic KDL-Schema
validation — capability profiles reuse it), ADR-0049 (app-kinds as a distinct
platform entity — the *distinct-entity / shared-mechanism* precedent, and the
consumer of the app-form face), ADR-0048 (first-class semantic pattern-kinds — the
other target-model *input*), ADR-0043/0044 (toolchain crates distributed into domains; the
shared `targets/_shared` home), ADR-0015 (the interpreted-vs-compiled FFI model the
sibling target descriptor turns on), ADR-0014/0016/0022/0035 (the per-target
foreign-thread concurrency models the profiles are grounded in).

## Context

REFACTOR §20 requires each target implementation to carry a formal **capability
profile** — what it can express "statically, dynamically, conventionally, unsafely,
or not at all" — and §7.7 requires every target/platform combination to **report**
per-API representability (`fully represented` … `unsupported` / `research`). These
read as two separate artifacts: a profile of *capabilities* and a status of *APIs*.

Three questions are not obvious and a reviewer will ask them. **(1)** Are §20's
capability "levels" and §7.7's per-API "statuses" two vocabularies, or one? **(2)**
Is the per-API representability status **authored** (a third committed `.apiw` face)
or **derived**? **(3)** What does the profile key on — the macOS source-weirdness an
API exhibits (so it directly yields a status), or something platform-independent? The
project already has the inputs a derivation would need: the platform model authored the §30
**source-weirdness** a concrete `(receiver, selector)` exhibits
(`platforms/macos/tests/api-semantics/<facet>.apiw`), and ruled the §7.7
status **wholly the target's** — `platforms/` carries only the weirdness vocabulary, never
a status.

## Decision

**One ladder; an authored, platform-independent profile; a derived per-API status —
the status falls out of a pure floor over the profile and the platform's weirdness.**

1. **One unified 7-rung representability ladder** (`derive::Representability`)
   collapses §20's levels and §7.7's statuses — they are the same scale under two
   names, and always move together, so maintaining two enums + a translation table was
   rejected. Best → worst: `exact-static` (≡ fully-represented) > `exact-runtime` >
   `idiomatic-conventional` > `lossy-but-documented` > `unsafe-only` >
   `not-representable` (≡ unsupported) > `research`. It is a **controlled enum** (a
   schema `enum` in `capability.kdl-schema`, like the descriptor's `runtime-model`),
   not an open vocab — the rung set is genuinely bounded. **`research` sorts lowest**
   deliberately: an *unestablished* capability dominates the floor (if any demanded
   capability is unresearched, the API's representability is unestablished — the
   conservative reading).

2. **The capability profile is authored and platform-INDEPENDENT** — it describes the
   *implementation* (`targets/<t>/capability.apiw`: a map from a §20 capability
   **dimension** to a ladder rung), so it is reusable across platforms (a CL impl
   "supports finalization" regardless of macOS). Keying the profile directly on macOS
   §30 weirdness tags — tempting, because it would yield a status without a derivation —
   was **rejected**: it couples intrinsic capability to one platform and would have to
   be re-authored for Linux/.NET. The profile has **two faces** (the §20 list spans
   both): a **semantic** face (per-API capabilities — `ownership`,
   `foreign-thread-callbacks`, `struct-by-value`, …) feeding representability, and an
   **app-form** face (§36 `packaging` / `app-bundle` / `plugin` / `sandboxing` /
   `native-runtime-embedding`) feeding per-app-kind feasibility (the child-5 conformance
   `app-kind support` call), **not** per-API representability.

3. **Per-API representability is DERIVED, never authored** (the platform-model carriage
   discipline, again): committing a per-API status would duplicate a derivable fact and
   rot against SDK / binding drift, so it is computed on demand and stays uncommitted
   (constraint 4). The derivation is a **floor**:

   ```text
   status(api, target) = min over { profile[needs(w)] : w ∈ platform.weirdness(api) }
   ```

   - `needs` is a shared, **target-independent** `weirdness → capability` map
     (`vocab::capability_for` — e.g. `may-reenter → foreign-thread-callbacks`): which
     capability a §30 difficulty *demands*. Reassuring tags (`thread-safe`, `owned`, …)
     demand nothing and never lower the floor.
   - An API with **no** weirdness (or only reassuring tags) derives the top rung
     `exact-static` — the **trampoline-elision limit**: the vast directly-reachable
     ObjC surface is fully represented, and only the weird / Swift-native residual drops
     down the ladder per-target.
   - A demanded-but-**unauthored** capability derives `research` (and, being lowest,
     dominates the floor).

4. **The dimension vocabulary is a face-conditional controlled vocab, enforced by the
   focused validator** — *not* a schema enum. A `semantic { … }` body may only name §20
   semantic dimensions and an `app-form { … }` body only §20/§36 app-form dimensions,
   and the KDL Schema Language cannot state a vocabulary that depends on the enclosing
   node (the exact reason the platform §30 `weirdness` and the pattern-law `token` are side
   tables, not schema enums). The `rung`, by contrast, *is* a schema enum (§1).

5. **One shared crate, domain-pure derivation.** All of this lives in the single shared
   `targets/_shared/tools/target-model` crate (D5): the `capability/` submodule
   (parse + serde + focused validator + registry), `vocab` (dimensions + the
   weirdness→capability map), and `derive` (the ladder + the floor). The floor takes the
   API's weirdness **tags**, not the platform's `ApiSemanticsRegistry`, so the
   targets-domain crate never depends on the platforms-domain crate (the domain rule); a
   consumer (child 5) wires the two registries. The CLI / report surface is **not** built
   here (skeleton-first: a library + tests now, the report generator at child 5).

## Consequences

- **`fully represented` is the default, not a per-API annotation.** Because empty
  weirdness ⇒ `exact-static`, the enormous trampoline-elided surface needs no authoring
  at all; only the §30-weird residual is ever rated, and only once per implementation
  (the profile), never per API.
- **The profile reveals real per-target structure.** The same floor over the same
  platform weirdness yields different statuses because the *profiles* differ — e.g.
  `foreign-thread-callbacks` is `exact-runtime` for chez (it genuinely **activates** the
  foreign thread, ADR-0016) but `idiomatic-conventional` for racket / gerbil / sbcl
  (they **bounce** to the main thread, ADR-0014/0022/0035). A `may-reenter` API thus
  derives `exact-runtime` on chez and `idiomatic-conventional` on the others — the
  activation-vs-bounce distinction surfacing in the *derived* status.
- **Platforms stay status-free.** `platforms/` carries only the §30
  weirdness vocabulary; the status is computed in `targets/`. Adding Linux/.NET adds a
  weirdness source and reuses every profile unchanged.
- **Validation boundary:** the `capability.kdl-schema` contract + the focused in-crate
  validator live with the model, validated by the shared KDL-Schema engine like every
  authored artifact; there is no JSON Schema (ADR-0046 §5). The derived
  representability / conformance reports stay derived and uncommitted, so they are
  un-schema'd (constraint 4).
- **Consumers:** the app-form face and the derived semantic statuses are *inputs* to the
  `apianyware-conformance` report and the test model (`testing/`, ADR-0053); this decision is
  the model + library, not the report or a runner.
- **Why this clears the ADR bar:** hard-to-reverse (a 7-rung enum + a new schema + a
  weirdness→capability map + four authored profiles to follow), surprising (one ladder
  not two; the status *derived* not authored; the profile *platform-independent* not
  weirdness-keyed — each the non-obvious arm of a real fork), a genuine trade-off
  (author the status directly for a free lookup vs derive it to stay drift-proof and
  platform-neutral — the project chose derivation).
