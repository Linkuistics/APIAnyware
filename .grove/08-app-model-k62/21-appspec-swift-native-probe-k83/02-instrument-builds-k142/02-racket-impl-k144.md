# racket-impl-k144

**Kind:** work

## ⚠ CONFIRM FIRST — the CreateML "no corpus regen" contradiction (surface before the bring-in)

**Before any build work, surface this to the user and confirm the approach** (it contradicts
an explicit instruction — do not silently proceed). The parent `instrument-builds-k142` leaf
said *"Do not regenerate the corpus."* That was premised on CreateML already being present —
**a false premise** (see the node BRIEF's "Decomposed per-impl" section, established by
`sbcl-impl-k143`): this worktree has **no `generated/createml/`** for racket/chez/gerbil, only
`annotations.apiw` in the CreateML corpus (no `resolved.json`), and the dylibs carry **zero**
CreateML trampolines. So racket's 2-shape probe (`CreateML.timestampSeed` + `MLCreateErrorDomain`)
**cannot build** without bringing CreateML through the pipeline.

The proposed bring-in is **targeted, additive, and golden-neutral** — NOT the 153-framework
regen the instruction warns against:
1. `SDKROOT=macosx apianyware-collect --only CreateML` (load its deps together if it pulls any —
   [[resolved_regen_load_deps_together]]).
2. `SDKROOT=macosx apianyware-analyze --only <CreateML + its deps>` → CreateML `resolved.json`.
3. `apianyware-generate --target racket` → emits `generated/createml/{functions,constants}.rkt`
   **and** the CreateML `@_cdecl` adapter trampolines.
4. `swift build --product APIAnywareRacket` (NOT `--target` — only the product relinks the
   dylib; [[swift_build_product_vs_target]]) so the CreateML trampolines land in the dylib.

No existing emit golden covers CreateML (it is additive), so goldens-as-truth holds. Confirm
this is acceptable (vs. some lighter path the user prefers) — then proceed. The corpus + bindings
are gitignored and **persist in this worktree**, so once racket brings CreateML in, `chez-impl`
and `gerbil-impl` (grown on this leaf's retirement) inherit the corpus and only re-run
generate + `swift build` for their own target.

## Goal

Instrument the **racket** swift-native-probe impl to the k141 logging contract, author its
descriptor + a **new** `build.sh` (none exists for the Scheme impls), bring CreateML in (above),
rebuild, and CLI-smoke that the full contract vocabulary emits. The reference template the
chez/gerbil `.sls`/`.ss` "mirror one control at a time".

## The two shapes + known-good `ok`-checks (from the contract)

| shape | name | check | value |
|---|---|---|---|
| `function` | `CreateML.timestampSeed` | **structural** — returns an `Int` (time-derived, never value-equality) | the seed |
| `constant` | `CreateML.MLCreateErrorDomain` | `string=? "com.apple.CreateML"` | the domain |

`[probe] complete count=2 ok=2 all-ok=#t` is the summary scenario 01 asserts.

## Instrumentation (mirror the drawing-canvas racket pattern — k134, and the sbcl k143 emitter)

- **New `events.rkt`** (a `racket/base` module) modelled on drawing-canvas's `events.rkt` + the
  sbcl k143 `events.lisp`: `events-init!`, `emit-startup`, `emit-launch-line` (bare
  `Swift-Native Probe opened.`), `emit-shutdown`, plus `emit-probe-result` (shape/name/ok/value —
  booleans as `#t`/`#f`, name + string values double-quoted) and `emit-probe-complete`
  (count/ok/all-ok). Resolve `SWIFT_NATIVE_PROBE_EVENTS_LOG` → default
  `/tmp/swift-native-probe/events.log`; `#:exists 'truncate/replace`; line-buffered.
- **Wire `swift-native-probe.rkt`:** the current impl is a **top-level script** (no `main`) — add
  `events-init!` + `emit-startup` before probing, the two ok-checks → `emit-probe-result`, then
  `emit-probe-complete`, keep the existing stdout echo, emit the bare launch line after
  key+front (dual with stdout), and add the shutdown wiring: an `applicationWillTerminate:`
  delegate via `make-delegate` (the drawing-canvas racket pattern) emitting
  `[lifecycle] shutdown reason=menu`, plus an `uncaught-exception-handler` for signal/error (the
  drawing-canvas racket `emit-shutdown 'signal|'error` pattern). Do **not** abort on a failed
  probe. NB racket has no `:run nil` smoke — CLI-smoke = run it, let it emit, kill it (the
  emission happens before the run loop, so a short-lived launch + read of the log suffices —
  never a full GUI run, [[use_testanyware]]).
- **Descriptor** `swift-native-probe-impl.rkt`: `#:name "Swift-Native Probe (Racket)"`,
  `#:binary "/Applications/SwiftNativeProbe-racket.app"`, `#:bundle-id
  "com.linkuistics.swift-native-probe-racket"`, the two env vars + mirrored default paths (copy
  the sbcl k143 descriptor, swap the impl name/id/binary).
- **New `build.sh`:** mirror the drawing-canvas **racket** `build.sh` (self-contained mode:
  `raco exe` + `raco distribute` + Swift stub + per-impl id rename + re-sign). Its CreateML
  prereq check keys on `generated/createml/functions.rkt` (absent → the bring-in above). App
  name `SwiftNativeProbe-racket`; the bundler's default id derives from the spec H1
  ("Swift-Native Probe"), overridden to the suffixed id via PlistBuddy.

## Done when

- CLI-smoke shows in `events.log`: `[lifecycle] startup` → two `[probe] result … ok=#t` (the
  timestampSeed structural check + the MLCreateErrorDomain string check) → `[probe] complete
  count=2 ok=2 all-ok=#t` → `Swift-Native Probe opened.` (shutdown delegate wired; menu-quit
  shutdown is `forward-gen-live-run`'s live-VM concern).
- Descriptor + new `build.sh` authored; a `SwiftNativeProbe-racket.app` built with the suffixed id.
- CreateML in the corpus + racket bindings + racket dylib (so chez/gerbil inherit the corpus).
- Commit names `racket-impl-k144`. Handoffs (whether the shared-layout three will be
  byte-identical in emission, bundle size, launch-line wording) recorded for chez/gerbil.

## Notes

- The three Scheme impls (racket/chez/gerbil) are near-identical 2-shape probes with the same
  layout — chez/gerbil emit events **inline** (no separate module, per drawing-canvas's chez/
  gerbil), racket uses `events.rkt`. Right-size chez/gerbil as their own leaves on retirement.
- Data homes here (ADR-0052); goldens-as-truth unmoved (CreateML is additive).
