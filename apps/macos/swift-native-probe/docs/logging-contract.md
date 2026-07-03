# Swift-Native Probe — Logging Contract

> **Porting guide.** Every implementation of Swift-Native Probe MUST satisfy this contract to
> be verifiable by the AppSpec scenario runner. It extends the hello-window lifecycle triad
> (`apps/macos/hello-window/docs/logging-contract.md`) with the **probe events** that carry
> this app's actual coverage proof. It is the `instrument-builds` child's implementation
> target; the current impls emit **only** to stdout and satisfy **none** of it yet.

## Why a log file (not stdout)

Identical to hello-window: the runner launches a GUI impl with `open` (LaunchServices), under
which the app's **stdout is discarded** — unreadable by the runner. So every log assertion
(`wait-ready`, `wait-for-log`, `expect-log`) reads a structured **`events.log`** the impl
writes itself (`AppSpec/runner/log-tail.rkt`; `AppSpec/testanyware-sdk/macos-helpers.rkt`
`wait-ready`), never stdout.

This matters acutely here: every impl already prints its Swift-native results to stdout
(`printf`/`displayln`/`format t`), and that echo is worth keeping for humans running the app
unbundled — **but it is not the contract.** The runner-observable coverage proof is the
`[probe] complete … all-ok` event in `events.log`.

## The events.log file

- **Path resolution** (the impl, on startup): the value of the `<log-env>` env var
  (`SWIFT_NATIVE_PROBE_EVENTS_LOG`) if set and non-empty; otherwise the **fixed default**
  `/tmp/swift-native-probe/events.log`. The descriptor's `#:events-path` **mirrors the same
  default**, so the runner tails the right file whether or not the env var propagates through
  LaunchServices (the hello-window safety-net convention).
- **Lifecycle:** truncated on impl startup (`#:exists 'truncate/replace`); parent dir created
  if missing. The runner also truncates it between scenarios; the two truncates compose
  cleanly.
- **Buffering:** line-buffered, flushed after every record.
- **Single writer:** the probe computes on the main thread before the run loop, and the only
  later writes are the launch line and the shutdown line (also main thread) — one port with
  post-write flush suffices, no lock.

## Test-config compatibility

The descriptor's `#:test-config-path` is REQUIRED by the schema and passed as
`<config-env>=<test-config-path>` (`SWIFT_NATIVE_PROBE_TEST_CONFIG`). The probe reads **no**
runtime config — its coverage set is fixed per impl — so the contract is: **honour the env
var if a future variant needs it, treat absent/empty as "no config"**. The fixed default
mirrored by the descriptor is `/tmp/swift-native-probe/test-config.scm`; a missing file is
not an error.

## Line format

```
[<module>] <event-name> <key>=<value> <key>=<value>\n
```

Strings are double-quoted with `\\`/`\"`/newline escaped; numbers, booleans (`#t`/`#f`), and
symbols emit bare. Modules used: **`lifecycle`** and **`probe`**. The `Swift-Native Probe
opened.` launch line is the one **bare (unbracketed)** line, so an `#rx"Swift-Native Probe
opened\\."` substring matches.

## Emission order (deterministic, all before the run loop)

1. Resolve events-path, truncate-open line-buffered, `make-directory*` the parent.
2. Emit `[lifecycle] startup` (the readiness probe — must precede everything downstream).
3. **Probe each shape in the target's coverage set**: call the trampolined symbol, compare
   the result to its known-good expected, and emit one `[probe] result …` line per shape.
4. Emit the `[probe] complete …` summary.
5. Build the UI (app, menu, window, coverage-row labels — the window may show a failed
   value; **do not abort on a failed probe**, so the window itself is diagnostic).
6. Make the window key + front, activate; emit the bare line `Swift-Native Probe opened.`.
7. Enter the AppKit run loop.
8. On the Quit / terminate path: emit `[lifecycle] shutdown reason=<menu|signal|error>`,
   then flush + close.

`startup` must land **before** the impl blocks in `-run`, or `wait-ready` times out.

## Events (the runner's consumers, with exact matchers)

| Event line | Emitted when | Runner consumer | Matcher |
|---|---|---|---|
| `[lifecycle] startup` | after events-log open, before probing | `wait-ready` readiness probe | `#px"\\[lifecycle\\] startup"` |
| `[probe] result shape=<s> name="<sym>" ok=<#t\|#f> value=<v>` | once per probed shape, after its check | diagnostic (per-shape triage on failure) | `#px"\\[probe\\] result "` |
| `[probe] complete count=<n> ok=<n> all-ok=<#t\|#f>` | after all shapes probed | **the coverage assertion** (scenario `01`) | `#px"\\[probe\\] complete .*all-ok=#t"` |
| `Swift-Native Probe opened.` | window key+front, after the summary | scenario `01` `wait-for-log` | `#rx"Swift-Native Probe opened\\."` |
| `[lifecycle] shutdown reason=<r>` | on the Quit / terminate path | `quit-impl!` / scenario `02` (Command-Q) | reason ∈ {`menu`, `signal`, `error`} |

### `[probe] result` field semantics

- **`shape`** — the trampoline shape (bare symbol): one of `function`, `constant`, `init`,
  `method`, `value-box`.
- **`name`** — the probed symbol, double-quoted (e.g. `"CreateML.timestampSeed"`,
  `"CoreGraphics.hypot"`, `"NSNumber.integerLiteral"`).
- **`ok`** — `#t` iff the live value matched its known-good expected. For the **one
  non-deterministic** value (`timestampSeed`), the check is *structural* (an `Int` was
  returned), not value-equality — `ok=#t` means "bound and returned a well-typed result".
- **`value`** — the live value: numbers/booleans bare, strings double-quoted. For a value-box
  round-trip, a short human string (e.g. the IndexSet round-trip description) quoted.

### `[probe] complete` field semantics

- **`count`** — number of shapes probed (the target's coverage-set size: 2 for
  racket/chez/gerbil, 5 for sbcl).
- **`ok`** — number that passed their check.
- **`all-ok`** — `#t` iff `ok == count`. **This is the single target-agnostic coverage
  assertion the scenario suite consumes** — it is `#t` on a fully-bound Swift-native path
  regardless of *which* symbols the target probes.

## Conformance checklist (per impl — the `instrument-builds` child implements this)

- [ ] On startup: resolve events-path (`SWIFT_NATIVE_PROBE_EVENTS_LOG` → `/tmp/swift-native-probe/events.log`),
      truncate-open line-buffered, `make-directory*` the parent.
- [ ] Emit `[lifecycle] startup` after init, **before** probing.
- [ ] For each coverage-set shape: call the trampolined symbol, compare to the known-good
      expected (structural for `timestampSeed`), emit `[probe] result shape=… name="…"
      ok=… value=…`.
- [ ] Emit `[probe] complete count=<n> ok=<n> all-ok=<#t|#f>`.
- [ ] Keep the existing stdout echo of the values (human convenience; not the contract).
- [ ] Emit the bare line `Swift-Native Probe opened.` to events.log after the window is
      key+front (keep the existing stdout line too).
- [ ] Emit `[lifecycle] shutdown reason=<menu|signal|error>` on the terminate path, flush+close.
- [ ] Honour `<config-env>` gracefully (no config needed; absent ⇒ default).
- [ ] Build to a `.app` whose `CFBundleIdentifier` equals the descriptor's `#:bundle-id`
      (`com.linkuistics.swift-native-probe-<impl>`).

## Notes for instrument-builds

- **Known-good expecteds** (the check tables): racket/chez/gerbil — `MLCreateErrorDomain ==
  "com.apple.CreateML"`, `timestampSeed` returns an `Int` (structural). sbcl — `hypot(3,4) ==
  5.0`, `NSNotFound == NSIntegerMax`, `NSNumber(42).intValue == 42`, `Scanner.scanUpToString(":")
  == "APIAnyware"`, IndexSet round-trip boolean `== #t`. These already exist implicitly in the
  impls' displayed values; instrument-builds turns them into explicit `ok` checks.
- **No corpus regeneration.** Unlike drawing-canvas (which added CoreGraphics), this probe
  adds **no new framework** — every trampoline it exercises already exists in the shipped
  bindings. Instrumentation is pure log-emission + the per-shape checks + rebuild.
- **sbcl's dump path:** the probe is the first ladder app to dump+revive WITH the dylib
  (ADR-0038 §5); the events-log emission must survive `save-lisp-and-die` (it is plain I/O at
  toplevel run time, so it will — but CLI-smoke it before the VM round-trip).
