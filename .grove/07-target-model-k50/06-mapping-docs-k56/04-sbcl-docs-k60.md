# sbcl-docs-k60

**Kind:** work

## Goal

Author the **sbcl** target's prose documentation layer (4th and **final** per-target child of
`mapping-docs-k56`), mirroring the racket/chez/gerbil pattern (`01-DONE-racket-docs-k57.md`,
`02-DONE-chez-docs-k58.md`, `03-DONE-gerbil-docs-k59.md`) — the §18 target docs at `targets/sbcl/docs/`
and the §22 binding mapping docs at `targets/sbcl/bindings/macos/docs/`, grounded in sbcl's authored
`.apiw` entities + the derived coverage. Inherit the node BRIEF "Shared mandate" verbatim.

## sbcl-specific notes (where sbcl differs from racket/chez/gerbil)

- **The object model is CLOS/MOP — a third paradigm (ADR-0033/0039).** Read the actual emitted
  bindings + `reference.md` + a sample app (`app-implementations/macos/hello-window/hello-window.lisp`)
  before writing the naming table. The surface is **not** racket/chez's flat free-procedures, **not**
  gerbil's manifest `defclass` + dual `{}`/`:std/generic` — it is **generic-function dispatch over an
  `objc-class` metaclass graph**, through the portable **`ns:`** package: `make-instance` with **typed
  init keywords** (`(make-instance 'ns:ns-window :init-with-content-rect … :style-mask … :backing …
  :defer …)`), **per-selector generic functions** (`ns:set-title_`, `ns:add-subview_`,
  `ns:content-view`), and class methods dispatched on the **class metaobject**
  (`(ns:shared-application (find-class 'ns:ns-application))`). Inherited methods resolve by CLOS
  (`setStringValue:` lives on `NSControl`, dispatches on an `NSTextField`); the init registry is
  **exact-class**. NSStrings via the **`@"…"` reader macro**; geometry via the `aw-with-rect`
  stack-allocating `with-` macro (not a `make-rect` constructor).
- **Naming is selector-structure-preserving (ADR-0039) — LIVE for sbcl, the [[preserve_selector_structure_cross_target]] rule.**
  colon→`_`, hump→`-`: `-[NSWindow setTitle:]` → `ns:set-title_`; `setObject:forKey:` →
  `ns:set-object_for-key_`. This keeps selector arg-structure and kills `foo`/`foo:` collisions. It
  is the **inverse** of the Schemes' `nsfoo-set-title!` kebab convention — do **not** copy the gerbil
  naming table; sbcl's trailing `_`-per-colon is the headline naming divergence.
- **adapter-strategy = `sole-native-unit` (ADR-0038) — UNIQUE to sbcl, a 4th descriptor value.**
  `libAPIAnywareSbcl` is the target's **sole** native compilation unit: it hosts the Swift-native
  trampolines **and** the main-thread bounce, subclass-IMP synthesis, and OpaqueHandle/Throws/Async
  marshalling. Contrast gerbil's `trampoline-only` (bridges in gsc Gerbil) and chez's
  `trampoline-and-bridges`. The §18 `ffi-model.md` + §22 mapping docs must reflect that the dylib is
  the *one* native home, not a thin trampoline residual. (`ffi-backend` = `sb-alien`, `runtime-model`
  = `compiled-ffi` per ADR-0015 — one typed alien signature per method ABI, like chez/gerbil.)
- **Concurrency: main-thread BOUNCE (ADR-0035) — like racket/gerbil, UNLIKE chez.** So
  representability sits a rung **below** chez (level with racket/gerbil) on `foreign-thread-callbacks`
  — state the contrast in `language-characteristics.md` / `representability.md` (same shape as the
  gerbil docs; confirm the rung in `capability.apiw`).
- **Build/lifetime: dumped-image `.app` (ADR-0041), lifetime ADR-0036.** The **dumped SBCL image IS
  the executable**, `@executable_path`-relocated + signed-around — *not* gerbil's `gxc -exe` static
  executable nor chez's open-world bundle. `native-runtime-embedding = research` (the dumped image is
  the executable; no host-process embedding path — a `known-issue`). The §36 app-form / §37
  conformance prose must reflect the dumped-image packaging.
- **CL-family interface contract (ADR-0033).** sbcl source is written against a **portable `ns:`
  contract surface** (so it ports to a future CL-family member, e.g. CCL); `apianyware-sbcl-impl` is
  the impl package (bare `make-instance`, `aw-with-rect`, `aw-make-nsstring`/`aw-wrap`, the menu
  helper). The §22 `user-guide.md` require/load model must reflect sbcl's **actual** load surface
  (ASDF system + the `:load-residual nil` harness for pure-ObjC apps that need no dylib) — read a
  `run.lisp` + the bindings layout (`bindings/macos/runtime/`; **no** `generated/` dir like
  racket/gerbil), don't assume a Scheme import model.
- **Swift-native *method* trampolines are a research GAP (conformance research item).**
  `swift-native-probe` (functions / constants / initializers) is VM-verified, but the receiver-handle
  Swift-native *method* trampolines shipped for racket/chez/gerbil are **not yet ported** to sbcl
  (no `swift-native-method-probe`). Surface this honestly in `api-coverage.md` as the §37 research
  item — don't overclaim method-level Swift-native coverage.
- **No `developer-guide.md`** (like chez/gerbil): sbcl has `docs/reference.md` + design/research only,
  so the §22 `user-guide.md` is the primary user-facing doc — write it fuller (mirror chez/gerbil).
  The §21 `idioms/docs/idiom-map.md` already exists — `docs/idiom-map.md` is a thin pointer.

## Done when

- `targets/sbcl/docs/{overview,language-characteristics,ffi-model,idiom-map,representability}.md`
  + `targets/sbcl/bindings/macos/docs/{user-guide,platform-docs-mapping,api-coverage,
  unsafe-escape-hatches}.md` exist, grounded in sbcl's `.apiw` + the conformance CLI
  (`apianyware-conformance --target sbcl`); no recomputable facts hand-copied; prose only.
- sbcl bindings README docs/ row added (if a README table exists — gerbil's had none); any
  bundler/dylib follow-up re-pointed to child 7 (`grep -rn "workstream 6\|ws6\|TODO" targets/sbcl/...`);
  don't pretend a bundler marker is doc work.
- All relative links verified to exist; workspace stays green (prose only).

## Notes

- Commit handle: `sbcl-docs-k60`. This is the node's **4th and final** child — on retire,
  `mapping-docs-k56` has no live leaf left → it is implicitly done: **confirm node-done with the
  user**, promote anything durable from the node brief upward, then the parent `target-model-k50`
  grows **ws6 child 7 — bundler reshape + guide resync** (the D6 bundler residuals +
  `targets/_shared/docs/adding-a-language-target.md` step-path resync), per the node + target-model
  briefs.
- Mirror `03-DONE-gerbil-docs-k59.md` for structure; keep sbcl idiomatic CLOS/MOP, not a Scheme
  clone ([[maximize_target_idiom_and_perf]], [[preserve_selector_structure_cross_target]]).
