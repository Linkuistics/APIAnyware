# gerbil-docs-k59

**Kind:** work

## Goal

Author the **gerbil** target's prose documentation layer (3rd per-target child of
`mapping-docs-k56`), mirroring the racket/chez pattern (`01-DONE-racket-docs-k57.md`,
`02-DONE-chez-docs-k58.md`) — the §18 target docs at `targets/gerbil/docs/` and the §22 binding
mapping docs at `targets/gerbil/bindings/macos/docs/`, grounded in gerbil's authored `.apiw`
entities + the derived coverage. Inherit the node BRIEF "Shared mandate" verbatim.

## Gerbil-specific notes (where gerbil differs from racket/chez)

- **The object model is the big divergence (ADR-0020).** Gerbil is the **one** target with a
  genuine **manifest `defclass` class graph** mirroring the ObjC hierarchy + **dual dispatch**
  (brace-syntax `{method obj …}` *and* `:std/generic` generics) + **transparent subclassing** —
  *not* racket/chez's flat free-procedures-over-one-`objc-object`. The §22 `platform-docs-mapping.md`
  and `user-guide.md` must reflect method calls through the class graph / generics, not a
  `nsfoo-bar` free-procedure convention. Read the actual emitted bindings + `reference.md` for the
  real surface before writing the naming table.
- **Concurrency: main-thread BOUNCE (ADR-0022), like racket — UNLIKE chez.** `capability.apiw` rates
  `foreign-thread-callbacks = idiomatic-conventional` (the native IMP is a bounce shim), so gerbil's
  representability sits where racket does on that dimension — a rung **below** chez's
  `exact-runtime` activation. State this contrast explicitly in `language-characteristics.md` /
  `representability.md` (it is the inverse of chez's headline).
- **Descriptor facets** (`target.apiw`): gerbil is `scheme` / *(no `dialect` — dialect ≡
  implementation)* / `gerbil` / `std-foreign` (`:std/foreign define-c-lambda`) / `compiled-ffi`
  (gxc → Gambit → C → native, ADR-0015/0017) / `thin-direct` / **`trampoline-only`** (NOT
  `trampoline-and-bridges` — the dylib is *strictly* trampoline-only; the ObjC/callback bridges live
  in gsc-compiled Gerbil, not the native unit). Don't copy chez's `-and-bridges` adapter prose.
- **Build/lifetime model:** self-contained **STATIC executable** (ADR-0021, BOTTLE toolchain,
  sharded generics ADR-0023) — *not* chez's open-world dynamic bundle (ADR-0009). Lifetime is
  ADR-0019 (read it), not chez's guardian (ADR-0007). The §36 app-form / §37 conformance prose must
  reflect the static-exe packaging.
- **Binding layout is racket-like, not chez-like:** gerbil keeps a **separate `generated/`** dir
  under `bindings/macos/` (the chez `apianyware/` namespace-tree shape is chez-only). The §22
  `user-guide.md` require model must reflect gerbil's actual import surface — read
  `bindings/macos/README.md` + a sample app, don't assume chez's `(import (apianyware fw cls))`.
- **emit-gerbil gotcha** ([[gerbil_values_coerce_shadow]]): a bare `values` token in generated
  bindings is shadowed by the wholesale `(g:defgeneric values)` generics import — relevant if the
  error/idiom docs show multiple-values returns.
- **No `developer-guide.md`** (like chez): gerbil has `docs/reference.md` + design/research only, so
  the §22 `user-guide.md` is the primary user-facing doc — write it fuller (mirror chez's choice).
  The §21 `idioms/docs/idiom-map.md` already exists — `docs/idiom-map.md` is a thin pointer.

## Done when

- `targets/gerbil/docs/{overview,language-characteristics,ffi-model,idiom-map,representability}.md`
  + `targets/gerbil/bindings/macos/docs/{user-guide,platform-docs-mapping,api-coverage,
  unsafe-escape-hatches}.md` exist, grounded in gerbil's `.apiw` + the conformance CLI; no
  recomputable facts hand-copied; prose only.
- Gerbil bindings README docs/ row added (if a README table exists); any bundler/dylib follow-up
  re-pointed to child 7 (`grep -rn "workstream 6\|ws6\|TODO" targets/gerbil/...`); don't pretend a
  bundler marker is doc work.

## Notes

- Commit handle: `gerbil-docs-k59`. On retire, grow `sbcl-docs` (the node's 4th and final child).
- Mirror `02-DONE-chez-docs-k58.md` for structure; keep gerbil idiomatic, not a chez/racket clone
  ([[maximize_target_idiom_and_perf]]).
