# chez-docs-k58

**Kind:** work

## Goal

Author the **chez** target's prose documentation layer (2nd per-target child of
`mapping-docs-k56`), mirroring the racket pattern (`01-DONE-racket-docs-k57.md`) — the §18 target
docs at `targets/chez/docs/` and the §22 binding mapping docs at
`targets/chez/bindings/macos/docs/`, grounded in chez's six authored `.apiw` entities + the
derived coverage. Inherit the node BRIEF "Shared mandate" verbatim.

## Chez-specific notes (where chez differs from racket)

- **Reuse landscape:** chez has `docs/reference.md` + design docs but **no `developer-guide.md`**
  (racket's was unique). So chez's §22 `user-guide.md` is the primary user-facing doc — write it
  fuller than racket's (which deferred to its developer-guide), or note the gap. The §21
  `idioms/docs/idiom-map.md` already exists (child 3) — `docs/idiom-map.md` is a thin pointer.
- **Descriptor facets** (`target.apiw`): chez is `scheme`/`chez`/`chez-scheme`/`foreign-procedure`
  /compiled-FFI (ADR-0015, *not* interpreted like racket) / its own projection + adapter strategy
  — read the actual file. Concurrency model differs sharply from racket: chez **activates the
  foreign thread** (ADR-0016 `Sactivate_thread`), it does **not** main-thread-bounce except for UI
  (CONTEXT.md *Foreign-thread activation*). Lifetime is a **guardian** + entry-point
  autoreleasepool (ADR-0007), not racket's will-executor.
- **Binding layout is unlike racket** (chez README already documents this): the emitted package
  root is the `apianyware/` namespace tree (library-name → on-disk-path), not a `generated/`
  sibling; runtime is `apianyware/runtime/`. `--libdirs` is `bindings/macos/` itself. The §22
  `user-guide.md` require model must reflect `(import (apianyware fw cls))`, not racket's relative
  `require`.
- **README markers:** the chez bindings README "Open follow-ups" carry a **bundler** marker —
  "teach the bundler the apps-root / bindings-root split natively (kill the symlink fixture)" —
  which is **ws6 child 7's D6 bundler reshape**, plus a `generated_subdir`/`shared-seam-k15` item
  already resolved. Re-point the bundler one to child 7; add a `docs/` row; don't pretend the
  bundler marker is doc work.

## Done when

- `targets/chez/docs/{overview,language-characteristics,ffi-model,idiom-map,representability}.md`
  + `targets/chez/bindings/macos/docs/{user-guide,platform-docs-mapping,api-coverage,
  unsafe-escape-hatches}.md` exist, grounded in chez's `.apiw` + the conformance CLI; no
  recomputable facts hand-copied; prose only.
- Chez bindings README docs/ row added; bundler follow-up re-pointed to child 7.

## Notes

- Commit handle: `chez-docs-k58`. On retire, grow `gerbil-docs` (the node's 3rd child).
- Mirror `01-DONE-racket-docs-k57.md` for structure; keep chez idiomatic, not a racket clone
  ([[chez_target_idiomatic_not_portable]]).
