# racket-docs-k57

**Kind:** work

## Goal

Author the **racket** target's prose documentation layer (the first per-target child of
`mapping-docs-k56`): the §18 target docs at `targets/racket/docs/` and the §22 binding mapping
docs at `targets/racket/bindings/macos/docs/`, grounded in racket's six authored `.apiw`
entities + the derived coverage. Racket is the reference target — this child **sets the doc
pattern** chez/gerbil/sbcl mirror. See the node BRIEF "Shared mandate" (inherited verbatim).

## Plan (the racket doc set — adjust if a doc has nothing to add)

**§18 target docs — `targets/racket/docs/`:**
- `overview.md` — what the racket target is, summarizing `target.apiw`'s seven facets
  (`scheme`/`racket`/`racket-cs`/`ffi2`/`interpreted-ffi`/`thin-direct`/`trampoline-and-bridges`);
  the doc map (deep dives = `developer-guide.md` + `reference.md`; idioms = `idioms/docs/idiom-map.md`).
- `language-characteristics.md` — Racket CS as a binding host (GC, dynamic typing, will-executor
  finalization, places concurrency, ffi2); points at `capability.apiw`'s semantic rungs.
- `ffi-model.md` — ffi2 + `ffi/unsafe/objc`, ADR-0013 generated typed dispatch, trampoline-elided
  direct ObjC, the APIAnywareRacket adapter; points at `adapters/macos/spec.apiw` +
  `policies/macos/projection.apiw` + `reference.md` §0/§1.
- `idiom-map.md` — thin pointer to the authoritative `../../idioms/docs/idiom-map.md` + catalogue.
- `representability.md` — the 7-rung ladder, the derivation (capability profile × platform §30
  weirdness floor; no-weirdness ⇒ `exact-static` = the trampoline-elision limit); points at
  `capability.apiw` + the `apianyware-conformance` coverage.

**§22 mapping docs — `targets/racket/bindings/macos/docs/`:**
- `user-guide.md` — binding entry point (require paths, the dylib, where `generated/` lands);
  defers depth to `docs/developer-guide.md`.
- `platform-docs-mapping.md` — Apple macOS docs → racket binding (selector→procedure naming,
  class→module, NSError→`exn:fail:objc`); points at `idioms/catalogue.apiw` + `reference.md` naming.
- `api-coverage.md` — **cite** `apianyware-conformance --target racket [--json]` for the derived
  representability histogram + app-impl status; trampoline-elision means the directly-reachable
  ObjC surface is fully represented, the Swift-native residual drops down the ladder. Points at
  `conformance/macos.apiw`. No hand-authored numbers.
- `unsafe-escape-hatches.md` — the raw `_cpointer` escape hatch (catalogue `unsafe-escape-hatch`
  idiom) + unsafe FFI accessors for unmodeled APIs; points at capability `buffers`.

## Done when

- `targets/racket/docs/{overview,language-characteristics,ffi-model,idiom-map,representability}.md`
  and `targets/racket/bindings/macos/docs/{user-guide,platform-docs-mapping,api-coverage,
  unsafe-escape-hatches}.md` exist, each grounded in / pointing at racket's authored `.apiw` +
  the conformance CLI; no recomputable facts hand-copied; no `.apiw`/code/golden changes.
- Genuine racket ws6 *doc* markers discharged; bundler/dylib README follow-ups re-pointed to
  child 7 (not pretended to be doc work).
- `git status` clean of build artifacts; workspace stays green (prose-only).

## Notes

- Commit handle: `racket-docs-k57`. On retire, grow `chez-docs` (the node's 2nd child).
- Cross-target richness is affordable because the LLM makes it so ([[maximize_target_idiom_and_perf]]).
