# sbcl-impl-k143

**Kind:** work

## Goal

Instrument the **sbcl** swift-native-probe impl to the k141 logging contract, author its
descriptor, move its `build.sh` onto the production bundler, rebuild, and CLI-smoke that the
full contract vocabulary emits. The first + self-contained impl (5-shape; needs **no**
CreateML — CoreGraphics.hypot + Foundation are all present, dylib fresh). Proves the k141
contract end-to-end before the CreateML-dependent trio.

## The five shapes + known-good `ok`-checks (from the contract)

Turn the already-displayed values into explicit `ok` checks (contract "Known-good expecteds"):

| shape | name | check | value |
|---|---|---|---|
| `function` | `CoreGraphics.hypot` | `= 5.0d0` | `hypot(3,4)` |
| `constant` | `Foundation.NSNotFound` | `= NSIntegerMax` (`most-positive-fixnum`? — use the ObjC/Swift `NSIntegerMax` = `(1- (expt 2 63))`) | `ns-not-found` |
| `init` | `NSNumber.integerLiteral` | `intValue = 42` | `42` |
| `method` | `Scanner.scanUpToString` | `string= "APIAnyware"` | scan result |
| `value-box` | `Foundation.IndexSet` | round-trip boolean `= t` | round-trip string |

`[probe] complete count=5 ok=5 all-ok=#t` is the summary scenario 01 asserts.

## Instrumentation (mirror the drawing-canvas sbcl pattern — k137)

- **New `events.lisp`** (pure CL, a `snp-events` package, nickname): `events-init!`,
  `emit-startup`, `emit-launch-line` (bare `Swift-Native Probe opened.`), `emit-shutdown`
  (lowercase reason via `~(~a~)`), plus probe emitters `emit-probe-result` (shape/name/ok/
  value; quote the string values per the line format) and `emit-probe-complete`
  (count/ok/all-ok). Resolve `SWIFT_NATIVE_PROBE_EVENTS_LOG` → default
  `/tmp/swift-native-probe/events.log`; `:supersede` truncate; `finish-output` per line.
  Reference: `targets/sbcl/app-implementations/macos/drawing-canvas/events.lisp`.
- **Wire `swift-native-probe.lisp`:** call `events-init!` + `emit-startup` **before** probing
  (gated on the real run, like drawing-canvas), do each shape's check → `emit-probe-result`,
  then `emit-probe-complete`, keep the existing stdout `format t` echo, emit the bare launch
  line after key+front (dual with stdout), and add the `applicationWillTerminate:` delegate
  (a controller class via `define-objc-method`, `set-delegate_`) emitting
  `[lifecycle] shutdown reason=menu` — the k137 pattern. Do **not** abort on a failed probe
  (window stays diagnostic).
- **`run.lisp` + `dump.lisp`:** load `events.lisp` first (before `swift-native-probe.lisp`).
  The `AW_PROBE_SMOKE` pre-flight/revive should exercise the emission (events-init! + the
  probe lines) so the CLI-smoke sees the log.
- **Descriptor** `swift-native-probe-impl.rkt`: `#:name "Swift-Native Probe (SBCL)"`,
  `#:binary "/Applications/SwiftNativeProbe-sbcl.app"`, `#:bundle-id
  "com.linkuistics.swift-native-probe-sbcl"`, `#:log-env "SWIFT_NATIVE_PROBE_EVENTS_LOG"`,
  `#:config-env "SWIFT_NATIVE_PROBE_TEST_CONFIG"`, `#:launch-via 'open`, `#:events-path
  "/tmp/swift-native-probe/events.log"`, `#:test-config-path
  "/tmp/swift-native-probe/test-config.scm"`.
- **`build.sh`:** replace the old hand-rolled /tmp-staged variant with the production bundler
  (`apianyware-bundle-sbcl`, ADR-0041) mirroring drawing-canvas's — per-impl suffixed id +
  `.app` rename + PlistBuddy + re-sign, and verify `CFBundleInfoDictionaryVersion` is present
  (the k132 finding). Confirm the bundler recognizes `swift-native-probe` (spec H1 →
  display name). If the production bundler cannot take this app cleanly, note it and keep a
  working build path (surface, don't silently diverge).

## Done when

- `AW_PROBE_SMOKE` CLI-smoke (host pre-flight + revive) shows in `events.log`: `[lifecycle]
  startup` → five `[probe] result … ok=#t` → `[probe] complete count=5 ok=5 all-ok=#t` →
  `Swift-Native Probe opened.` (shutdown line exercised where drivable via the smoke path;
  the menu-quit shutdown is a live-VM concern for k144, but the delegate must be wired).
- Descriptor authored; `build.sh` on the production bundler; a `SwiftNativeProbe-sbcl.app`
  built with `CFBundleIdentifier = com.linkuistics.swift-native-probe-sbcl` +
  `CFBundleInfoDictionaryVersion` present.
- Commit names `sbcl-impl-k143`. Handoffs (bundle size, launch-line wording, any deviation)
  recorded for `forward-gen-live-run-k144`.

## Notes

- sbcl is the **first ladder app to dump+revive WITH the dylib** (ADR-0038 §5) — the events
  emission is plain toplevel I/O so it survives `save-lisp-and-die`, but CLI-smoke it before
  any VM round-trip (this leaf does the host smoke; VM is k144's).
- Never run the GUI from the CLI ([[use_testanyware]]); the smoke path is `:run nil`.
- The sbcl impl **merges** the method/init slice the other three keep in the separate
  `swift-native-method-probe` app — that relationship is `portfolio-coverage-tie-in-k85`'s
  call, not this leaf's.
