# instrument-builds-k142 — brief

**Kind:** node (was a work leaf; decomposed per-impl on entry 2026-07-04)

## Goal

Instrument all four swift-native-probe impls to the k141 logging contract, rebuild each,
and CLI-smoke that the contract vocabulary emits correctly — so `forward-gen-live-run-k144`
(grown last) has runner-verifiable impls. The per-impl builds mirror hello-window k68–k71
and drawing-canvas k133–k137.

## Decomposed per-impl on entry (2026-07-04) — WHY the one-session hypothesis broke

The parent leaf hypothesized one session for all four "given no corpus regen." **That
premise is false in this worktree** — the decisive entry-time discovery:

- **CreateML is absent from this worktree's corpus, bindings, AND adapter dylibs** for
  racket/chez/gerbil. The locally-regenerated bindings cover appkit/coregraphics/foundation/
  pdfkit/scenekit/webkit; there is **no `generated/createml/`**. `platforms/macos/api/CreateML/`
  has only `annotations.apiw` (no `resolved.json` — it is gitignored + never resolved here).
  `nm` confirms: racket's dylib carries 440 `aw_racket_swift_*` trampolines, **zero** for
  CreateML/`timestampSeed`/`MLCreateErrorDomain`; chez/gerbil dylibs likewise zero.
- So the trio's 2-shape probe (`CreateML.timestampSeed` + `MLCreateErrorDomain`) is **not
  buildable** without bringing CreateML through the whole pipeline: **collect+resolve CreateML
  into the corpus → regenerate the target bindings (emit `createml/`) → regenerate+relink the
  adapter dylib (so the `@_cdecl` CreateML trampolines exist)**, per target. This is real,
  premise-contradicting work — NOT the "pure log-emission + relink" the parent assumed.
- **sbcl is the exception.** Its five shapes are CoreGraphics.hypot + Foundation
  (NSNotFound / NSNumber / Scanner / IndexSet) — **all present**, dylib fresh (3 Jul), build
  harness (`build.sh`/`run.lisp`/`dump.lisp`) already exists with a CLI-smoke path
  (`AW_PROBE_SMOKE`). sbcl needs **no CreateML** and is buildable now.

**⚠ Open decision for the trio (surface to the user before those children run):** the parent
leaf said explicitly *"Do not regenerate the corpus."* That instruction was premised on
CreateML already being present — a false premise. Bringing CreateML in for the trio means a
**targeted** `apianyware-collect --only CreateML` + `apianyware-analyze` (load deps together,
[[resolved_regen_load_deps_together]]) + `apianyware-generate --target <t>` + `swift build
--product` (relink, [[swift_build_product_vs_target]]) — a per-framework bring-in, not a
153-framework regen. Confirm this is acceptable (vs. some lighter path) when growing the first
trio child. It does **not** move emit goldens (createml is additive, no existing golden covers
it), so goldens-as-truth holds.

## Per-impl child plan (materialized lazily — only live children exist on disk)

1. **`sbcl-impl-k143`** — the self-contained impl (5-shape; no CreateML). Instrument
   `swift-native-probe.lisp` to the k141 contract (events package + startup + per-shape
   probe with ok-checks + complete summary + bare launch line + `applicationWillTerminate:`
   shutdown delegate), author the descriptor, move `build.sh` onto the production bundler
   (ADR-0041; per-impl suffixed id + re-sign + `CFBundleInfoDictionaryVersion` — the k132
   plist-alignment the parent flagged), rebuild, CLI-smoke (host + revive). Proves the
   k141 contract end-to-end. **[this session — skeleton-first]**
2. **trio: racket / chez / gerbil** *(grown on k143 retirement; right-size then — one
   CreateML-trio leaf sharing the corpus bring-in, or three per-impl leaves; the corpus is
   gitignored + persists in this worktree, so a first trio-child brings CreateML in and the
   rest inherit it)*. Each: the 2-shape probe instrumentation (events module for racket per
   the drawing-canvas pattern, inline for chez/gerbil), descriptor, **new `build.sh`** (none
   exists), CreateML pipeline bring-in + relink, rebuild, CLI-smoke.

## Shared contract context (from `spec-and-contracts-k141` — applies to every child)

- **The contract to implement** is `apps/macos/swift-native-probe/docs/logging-contract.md`
  (the porting checklist). Per impl, add events-log emission of:
  - `[lifecycle] startup` (after init, **before** the run loop / `-run`).
  - one `[probe] result shape=<function|constant|init|method|value-box> name="<sym>"
    ok=<#t|#f> value=<v>` per probed shape — each `ok` an explicit check vs the known-good
    expected (structural check for the non-deterministic `timestampSeed`).
  - `[probe] complete count=<n> ok=<n> all-ok=<#t|#f>` — the summary scenario `01` asserts.
  - the bare line `Swift-Native Probe opened.` (window key+front) — keep the existing stdout
    line too.
  - `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path, flush+close.
- **Known-good expecteds** (turn already-displayed values into explicit `ok` checks):
  - racket/chez/gerbil (2 shapes): `MLCreateErrorDomain == "com.apple.CreateML"`;
    `timestampSeed` returns an `Int` (**structural** — time-derived, never value-equality).
  - sbcl (5 shapes): `hypot(3,4) == 5.0`; `NSNotFound == NSIntegerMax`;
    `NSNumber(42).intValue == 42`; `Scanner.scanUpToString(":") == "APIAnyware"`;
    IndexSet round-trip boolean `== #t`.
- **Path / config env** (drawing-canvas `DRAWING_CANVAS_*` convention): resolve
  `SWIFT_NATIVE_PROBE_EVENTS_LOG` → default `/tmp/swift-native-probe/events.log`;
  `SWIFT_NATIVE_PROBE_TEST_CONFIG` → default `/tmp/swift-native-probe/test-config.scm`
  (honoured-gracefully, no config needed). Descriptor `#:events-path` mirrors the default.
- **Descriptors** (like drawing-canvas's `drawing-canvas-impl.rkt`): author
  `targets/<t>/app-implementations/macos/swift-native-probe/swift-native-probe-impl.rkt`
  with `#:bundle-id "com.linkuistics.swift-native-probe-<impl>"` at
  `/Applications/SwiftNativeProbe-<impl>.app`, the two env vars, and the mirrored defaults.
  (Bundle IDs use `com.linkuistics.*` — never `com.apianyware.*`; [[bundle_domain]].)
- **Goldens-as-truth unmoved** throughout (app-impl + descriptor work, not an emit change).
- **Never run the GUI from the CLI** ([[use_testanyware]]); CLI-smoke means driving the
  build's headless/pre-flight path (sbcl's `AW_PROBE_SMOKE` `:run nil`; the Scheme impls emit
  to the log then can be killed) to confirm the log lines — the live GUI verify is
  `forward-gen-live-run-k144`'s ([[vm_verify_every_app]]).
- Data homes **here** (ADR-0052): instrumentation under
  `targets/<t>/app-implementations/macos/swift-native-probe/`; no AppSpec-repo edits.

## Node done when

- All four impls emit the full k141 contract vocabulary, CLI-smoked: `[lifecycle] startup` →
  per-shape `[probe] result` (each `ok=#t`) → `[probe] complete all-ok=#t` → `Swift-Native
  Probe opened.` → `[lifecycle] shutdown reason=menu` on a menu-quit.
- Four descriptors authored; four bundles rebuilt (relink the dylib per
  [[swift_build_product_vs_target]] so smokes don't hit a stale dylib).
- Handoffs for `forward-gen-live-run-k144` recorded on each child's retirement (bundle sizes,
  any per-impl launch-line divergence, events-log path, whether the shared-layout three are
  byte-identical in emission).
- Commits name the per-impl child handles (`sbcl-impl-k143`, …).
