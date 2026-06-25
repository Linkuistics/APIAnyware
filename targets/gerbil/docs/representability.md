# gerbil — representability (§18 / §7.7)

How faithfully a given macOS API can be expressed in the gerbil binding, and where that judgment
comes from. Representability is **derived, never authored** — this page explains the derivation;
the numbers for the live SDK come from the `apianyware-conformance` CLI (see
[`../bindings/macos/docs/api-coverage.md`](../bindings/macos/docs/api-coverage.md)).

## One ladder, two names

REFACTOR §20's capability *levels* and §7.7's per-API *statuses* are the **same 7-rung ladder**
(node-brief D2 — a single shared model, identical across all four targets). Best → worst (the `Ord`
in `apianyware-target-model`'s `derive.rs`):

| rung | §7.7 alias | meaning for gerbil |
|---|---|---|
| `exact-static` | fully-represented | reachable directly, no special handling needed (the elision limit) |
| `exact-runtime` | runtime-represented | exact via a runtime mechanism (the will, native callback trampolines, struct marshalling, main-thread dispatch) |
| `idiomatic-conventional` | conventionally-represented | upheld by a binding convention (e.g. deterministic cleanup via `unwind-protect`, **the foreign-thread bounce**) |
| `lossy-but-documented` | lossily-represented | representable with documented loss of fidelity |
| `unsafe-only` | — | only through an explicit unsafe escape hatch |
| `not-representable` | unsupported | cannot be expressed at all |
| `research` | — | unestablished — sorts **lowest**, so it dominates the floor |

## The derivation — a floor, not a snapshot

A per-API status is **computed on demand**, never committed (constraint 4 — committing it would
duplicate a derivable fact and rot against SDK/binding drift). The floor:

```
status(api) = the worst (lowest) rung over { profile[needs(w)] : w ∈ platform.weirdness(api) }
```

- `platform.weirdness(api)` is the API's authored §30 **source-weirdness** tags, from the
  platform domain ([`platforms/macos/tests/api-semantics/`](../../../platforms/macos/tests/api-semantics/)).
- `needs(w)` is the shared, target-independent `weirdness → capability` map (`vocab.rs`
  `capability_for`): which §20 capability a difficulty *demands* (e.g.
  `may-reenter → foreign-thread-callbacks`).
- `profile[…]` is gerbil's authored rung for that capability, from
  [`../capability.apiw`](../capability.apiw)'s `semantic { … }` face.

So gerbil's *intrinsic* capability profile is platform-independent (it describes the gerbil
implementation); the macOS representability status falls out of flooring that profile against the
platform's weirdness for each API.

## The two boundary behaviours that carry the model

- **No weirdness ⇒ `exact-static`.** An API with no §30 weirdness tag (or only *reassuring* tags
  that demand nothing) derives the top rung — the **trampoline-elision limit**: the vast
  directly-reachable ObjC surface is fully represented, and only the weird / Swift-native residual
  drops down the ladder. (The opposite of "undocumented = unsupported": absence of difficulty means
  full representability.)
- **A demand the profile hasn't rated ⇒ `research`.** A weirdness tag demanding a capability gerbil
  has authored no rung for derives `research` for that API; because `research` sorts lowest it
  dominates the floor (the conservative reading).

## Where gerbil lands

Gerbil's profile (see [`language-characteristics.md`](language-characteristics.md)) clusters at
`exact-runtime` and `idiomatic-conventional`, so the typical weird API is *exactly* or
*conventionally* represented rather than lost. The one dimension that separates the targets is
thread re-entrancy, and **gerbil sits a notch *below* chez and *level with* racket**:
`foreign-thread-callbacks = idiomatic-conventional` (the main-thread **bounce**, ADR-0022) rather
than chez's `exact-runtime` thread *activation* (ADR-0016). So an API whose only weirdness is
`may-reenter` floors to `idiomatic-conventional` for gerbil — the same as racket, one rung under
chez's `exact-runtime`. This is the inverse of chez's headline strength, and the only place the two
Schemes' representability histograms diverge.

The notable `not-representable` case is shared across all targets: **Swift actor-isolation** — the
digester emits no actor-isolation signal, so those members are `KNOWN_UNBINDABLE` (recorded as
`unsupported` in [`../conformance/macos.apiw`](../conformance/macos.apiw), not silently dropped).

## See it for the live SDK

The per-API histogram over the platform's weird-API surface is a `--check`-gated derivation:

```
apianyware-conformance --target gerbil           # text report incl. the representability coverage line
apianyware-conformance --target gerbil --json     # machine-readable
```

See [`../bindings/macos/docs/api-coverage.md`](../bindings/macos/docs/api-coverage.md) for the full
coverage workflow.
