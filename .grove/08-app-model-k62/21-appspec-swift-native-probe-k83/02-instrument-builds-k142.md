# instrument-builds-k142

**Kind:** work

## Goal

Instrument all four swift-native-probe impls to the k141 logging contract, rebuild each,
and CLI-smoke that the contract vocabulary emits correctly — so the `forward-gen-live-run`
child (grown next) has runner-verifiable impls. The per-impl builds mirror hello-window
k68–k71 and drawing-canvas k133, but **lighter** (see "No corpus regen" below).

## Context / handoffs from `spec-and-contracts-k141`

- **The contract to implement** is `apps/macos/swift-native-probe/docs/logging-contract.md`
  (read it — it is the porting checklist). Per impl, add events-log emission of:
  - `[lifecycle] startup` (after init, **before** `-run` / the run loop).
  - one `[probe] result shape=<function|constant|init|method|value-box> name="<sym>"
    ok=<#t|#f> value=<v>` per probed shape — each `ok` from an explicit check vs the
    known-good expected (structural check for the non-deterministic `timestampSeed`).
  - `[probe] complete count=<n> ok=<n> all-ok=<#t|#f>` — the summary the suite asserts.
  - the bare line `Swift-Native Probe opened.` (window key+front) — keep the existing
    stdout line too.
  - `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path, flush+close.
- **Known-good expecteds** (turn the already-displayed values into explicit `ok` checks):
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
- **No corpus regen (the key right-sizing dividend).** Unlike drawing-canvas (which added
  CoreGraphics → 175→221 trampolines), this probe adds **no new framework** — every
  trampoline it exercises (CreateML for racket/chez/gerbil; CoreGraphics + Foundation
  Swift-native for sbcl) already exists in the shipped bindings. Instrumentation is pure
  log-emission + the per-shape checks + a relink/rebuild. Do **not** regenerate the corpus.
- **sbcl specifics:** it is the first ladder app to dump+revive WITH the dylib (ADR-0038 §5);
  the events-log emission is plain toplevel I/O so it survives `save-lisp-and-die`, but
  CLI-smoke it before the VM round-trip. Its build path is the production bundler (ADR-0041,
  travels alone, no /tmp staging — the drawing-canvas k133 finding). Watch the `build.sh`
  plist alignment the drawing-canvas k132 flagged (unsuffixed id / missing
  `CFBundleInfoDictionaryVersion`) — verify swift-native-probe's is correct.
- **Goldens-as-truth unmoved** throughout (this is app-impl + descriptor work, not an emit
  change).

## Done when

- All four impls emit the full k141 contract vocabulary, CLI-smoked: exact `[lifecycle]
  startup` → per-shape `[probe] result` (each `ok=#t`) → `[probe] complete all-ok=#t` →
  `Swift-Native Probe opened.` → `[lifecycle] shutdown reason=menu` on a menu-quit.
- Four descriptors authored; four bundles rebuilt (relink the dylib per the
  [[swift_build_product_vs_target]] rule so smokes don't hit a stale dylib).
- Handoffs for `forward-gen-live-run` recorded on retirement (bundle sizes, any per-impl
  divergence in the launch line, the events-log path, whether the shared-layout three are
  byte-identical in emission).
- Commits name `instrument-builds-k142` (or per-impl child handles if decomposed).

## Notes

- **May decompose per-impl on entry** (the drawing-canvas k133 / hello-window k68–k71
  mirror) — but the three shared-layout impls (racket/chez/gerbil, identical 2-shape) plus
  sbcl (5-shape) may well fit **one** session given no corpus regen; right-size on entry.
- Data homes **here** (ADR-0052): instrumentation under
  `targets/<t>/app-implementations/macos/swift-native-probe/`; no AppSpec-repo edits.
- **Never run the GUI from the CLI** ([[use_testanyware]]); CLI-smoke means driving the
  build's headless/pre-flight path (sbcl has a `:run nil` pre-flight; the Scheme impls emit
  to the log then can be killed) to confirm the log lines — the live GUI verify is
  `forward-gen-live-run`'s ([[vm_verify_every_app]]).
