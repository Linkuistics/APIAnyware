# typescript (Node) macOS binding — API coverage (§22)

What the typescript binding covers, and how faithfully. **There is no `apianyware-conformance
--target typescript`** — the authored `.apiw`/`conformance/` layer (`target.apiw`, `capability.apiw`,
`conformance/`) has not been extended to this target (`apianyware-conformance`'s `LIVE_TARGETS`
list is still `["racket", "chez", "gerbil", "sbcl"]`; see [`../../../docs/overview.md`](../../../docs/overview.md)'s
facet table). Where racket/chez/gerbil/sbcl get a derived §37 report from that CLI, this page points
at the mechanism this target uses instead, and never snapshots a count here (constraint 4 — a
hand-copied number rots against SDK and binding drift).

## Get the coverage

The standing, whole-corpus measurement is the **corpus-typecheck gate**: emit Foundation + AppKit
plus their transitive import closure fresh from the committed IR, and run the runtime package's
`tsc --noEmit --strict` over the result.

```sh
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-emit-typescript --test runtime_load_test -- --nocapture
```

A clean run means the emitted type surface for that framework set actually typechecks end-to-end —
not just that the emitter ran without panicking. Re-run it for the current residual; see
[`../../../docs/representability.md`](../../../docs/representability.md) for what the gate has found and
who owns each remaining bucket.

## How to read the coverage

- **The directly-reachable ObjC surface is `exact-static`.** Trampoline elision (ADR-0025) means the
  vast majority of the corpus dispatches with no special handling and a checked `.d.ts` type — the
  same reasoning the four Lisp targets' `representability.md` gives for their own `exact-static`
  rung, now backed by a compiler check rather than only a runtime contract.
- **The Swift-native residual is `exact-runtime`** — free functions, Swift-native method/init
  returns, and `throws` route through a by-name trampoline table or the `Result<T>` channel
  (ADR-0061, ADR-0058) rather than direct `objc_msgSend`, but exactly.
- **A handful of shapes are counted-deferred, each with an owner, not silently dropped** — see
  [`../../../docs/representability.md`](../../../docs/representability.md) for the current list (as of the
  last full-portfolio measurement: the blocks call-site frontier, non-curated by-value structs
  outside the closed POD family, one vacuous-but-legal protocol conformance, a protocol qualifier on
  a non-`Id` base, and the array-typed-global constant case).
- **Generic free functions and Swift operator declarations are genuinely unbindable** — no TS
  identifier exists for an operator, and this is recorded, not silently skipped
  (`../../../docs/representability.md`).

## App-kind coverage at a glance

There is no authored §37 per-app-kind call for this target (the same gap the facet table names).
What is demonstrated, first-hand:

| app-kind | status | note |
|---|---|---|
| `gui-app` | pass | self-contained `.app`; **seven** GUI sample apps built and TestAnyware VM-verified (`../../../docs/reference.md` §10) |
| `cli-tool` | unexercised | nothing about the pump/distribution model rules it out, but no sample demonstrates a headless Node TS binding app |
| `menu-bar-daemon` / `launch-agent` | unexercised | same — not ruled out, not demonstrated |
| `spotlight-importer` / `quicklook-extension` / `finder-sync-extension` | unexercised | loading the N-API addon + pump into an app-extension host is unestablished, the same open question the four Lisp targets record for their own extension-hosting rows |

## See also

- [`../../../docs/representability.md`](../../../docs/representability.md) — the ladder, the gate, and the
  current residual census with owners.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching what the binding doesn't (yet)
  model.
- The gate's own source of truth: `tools/emit-typescript/tests/runtime_load_test.rs`.
