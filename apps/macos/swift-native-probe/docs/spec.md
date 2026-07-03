# Swift-Native Probe

*Reverse-generated (LLM) on 2026-07-04 from the four VM-verified implementations
(racket, chez, gerbil, sbcl), then human-validated by git review under the
propose → review → accept-over-git model (ADR-0050, ADR-0052): this prose is the
target-independent source of truth; the four implementations are its projections.*

> **Right-sizing note (read first).** This app is a **coverage-verification probe**, not a
> GUI-richness sample. Its whole reason to exist is to prove, end-to-end in a real bundled
> GUI app, that each target's **complete-API Swift-native trampoline** path (ADR-0025…0032)
> is bound and correct — the project done-bar that in-process CLI smoke never satisfies
> ([[vm_verify_every_app]]). Its behavioural surface is therefore deliberately tiny: build a
> window, render a set of live Swift-native results as labelled rows, and quit. Because
> **the specific set of symbols each target probes differs** (see §6), the projection-free
> invariant is the *coverage-proof structure* and an **all-probes-pass** obligation — **not**
> a fixed symbol list. The verification suite is correspondingly lean and
> **logging-contract-centric**: it asserts the all-probes-pass summary event and the
> structural window facts, not per-symbol on-screen values. See the
> [logging contract](logging-contract.md) and [observable state](observable-state.md).

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** Swift-Native Probe  *(the bundlers read this from the first H1 above)*
- **complexity:** 1/7 (a probe — the simplest behavioural surface in the portfolio,
  alongside hello-window; its *value* is in the native binding it exercises, not its UI)
- **API frameworks (chrome):** AppKit (window, labels, menu, run loop), Foundation (strings,
  geometry value types) — identical to hello-window
- **API frameworks (the point — the probed Swift-native residual):** target-chosen; the
  realized sets are CreateML (racket/chez/gerbil) and CoreGraphics + Foundation (sbcl). See §6.
- **pattern-kinds exercised (chrome):** object-lifecycle · property-configuration ·
  class-method-factory · value-type-geometry · option-set bitmask · view-composition ·
  menu object-graph construction · run-loop entry (the hello-window set)
- **native units:** the target's **complete-API binding library** (`libAPIAnyware<Target>`)
  and its **Swift-native trampoline residual** (`@_cdecl` shims for decls carrying
  `objc_exposed: false`, unreachable by the FFI alone). Exercising this residual **is the
  probe's purpose** — no app-specific native code beyond it.

## 2. Purpose & intent

The complete-API binding model (ADR-0025) re-exports the **whole** platform API, including
the **Swift-native residual** the target's FFI cannot reach directly — free functions,
constants, initializers, methods, and value types that carry `objc_exposed: false` and have
**no C symbol** in their framework. Each is reachable only through the per-target
`@_cdecl` **trampolines** (ADR-0027 racket; ADR-0028 chez; ADR-0029 gerbil; ADR-0038 sbcl).

The in-process CLI smokes prove the trampolines resolve and run in isolation. This probe
closes the gap the smokes leave open: it proves the **same residual works end-to-end in a
real, bundled, VM-launched GUI app** — the standing project done-bar ([[vm_verify_every_app]]).
It computes a set of Swift-native results, checks each against a known-good expected value,
renders them as labelled rows in a window, and reports the aggregate pass/fail. A window that
shows correct live values is unambiguous evidence the Swift-native path is bound for that
target — none of the probed symbols has a C symbol; all are trampolined.

It is deliberately a **probe, not a portfolio sample app** (both a `1/7` behavioural surface
and self-described as such in every impl). There is no document, no persistence, and no
user-input handling beyond the standard window and menu chrome.

## 3. Application kind & lifecycle

A regular, dock-visible, single-window AppKit application (`gui-app`). Its lifecycle is
fully deterministic and identical on every launch:

1. **Probe first, before any UI.** Compute every Swift-native result the app will show —
   calling each trampolined symbol — **before** constructing a single view. Each result is
   checked against its known-good expected value. Probing first means a binding failure
   surfaces **loudly** (a diagnostic and/or a failed-probe report) rather than as a blank
   window. *(Realization detail: all four impls compute the values first and echo them to
   standard output; that echo is human-convenience, not the contract — see §9 and the
   [logging contract](logging-contract.md), which is the runner's actual read path.)*
2. **Acquire the application singleton** (`sharedApplication`).
3. **Become a regular app.** Activation policy *Regular* (`NSApplicationActivationPolicyRegular`
   = 0) — a Dock icon and menu bar. (The `gui-app` app-kind's `activation "regular"`.)
4. **Install the application menu** (see §7).
5. **Build the window** (§4) and the **coverage rows** (§5–§6), adding each label to the
   window's content view.
6. **Present and focus.** Make the window key and order it front; activate ignoring other apps.
7. **Announce.** Emit a one-line launch diagnostic (a line beginning `Swift-Native Probe
   opened.`; any trailing guidance text is implementation-specific and not part of the
   contract).
8. **Run.** Enter the AppKit run loop; the process blocks servicing window and menu events.
9. **Terminate via Quit.** Command-Q → `-[NSApplication terminate:]` — the `gui-app`
   app-kind's termination model (`termination "ns-application-terminate"`). See §7.

   **Termination is Quit-driven, not close-driven.** No implementation opts into "terminate
   after the last window closes" (no application delegate, no
   `applicationShouldTerminateAfterLastWindowClosed:` returning true), and the `gui-app`
   app-kind does not require it. On stock AppKit, closing the window therefore hides it but
   leaves the process running. *(This is the one lifecycle claim a live-VM scenario should
   confirm — see §10; the hello-window precedent confirmed it holds for all four targets.)*

No application delegate logic, timers, or background work is involved.

## 4. Window

A single top-level window, created through `initWithContentRect:styleMask:backing:defer:`:

- **Style mask:** the option-set OR of **Titled** (1) · **Closable** (2) · **Miniaturizable**
  (4). Resizable is deliberately omitted ⇒ the window is **fixed-size**.
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2). **Defer:** *false*.
- **Title:** the literal string `"Swift-Native API Coverage"` — **exact and identical on all
  four implementations** (unlike hello-window, whose title carries the per-impl identity, this
  probe's title is projection-free and directly assertable).
- **Position:** recentered via the window's standard `center` behaviour.
- **Background:** default system window material; no custom background colour.
- **Size:** a per-target **realization**, sized to fit the target's coverage rows — the
  realized values are 560 × 240 (the three 2-shape impls) and 640 × 300 (the 5-shape sbcl
  impl). The exact content size is therefore **not** a spec invariant; "fixed-size, large
  enough to show all coverage rows and the footer without scrolling" is.

## 5. Content layout (the coverage-proof structure)

The content view is a static arrangement of non-interactive **label** controls
(`NSTextField` configured as labels — see the hello-window spec §5 for the four-flag
static-label idiom: editable/selectable/bezeled/drawsBackground all false). Three regions,
top to bottom:

- **Heading** — a single centred label reading `Swift-native APIs via libAPIAnyware<Target>
  trampolines`, where `<Target>` is the implementation identity (`Racket`/`Chez`/`Gerbil`/
  `Sbcl`). The stable, projection-free substrings are `Swift-native APIs` … `trampolines`;
  the embedded library name is per-impl and **not** asserted.
- **Coverage rows** — one row per probed Swift-native symbol (§6). Each row is a **name→value
  pair**: a left-aligned label naming the symbol/shape, and a right-aligned label (drawn in
  the system blue colour) showing its **live** value prefixed with `→`. The number of rows
  is the target's coverage-set size (2 or 5).
- **Footer** — one or two centred, secondary-colour labels noting that the shown symbols are
  Swift-native (`objc_exposed: false`), have no C symbol in their framework, and are reached
  only via `@_cdecl` trampolines. The exact wording is a **realization** (racket/chez/gerbil:
  "Neither symbol exists as a C symbol…" / "both are Swift-native…"; sbcl: "Each symbol is
  Swift-native…" / "all reached only via …@_cdecl trampolines…"); the stable substrings are
  `Swift-native`, `objc_exposed`, and `@_cdecl trampolines`.

## 6. The coverage set (per-target realization; all-pass is the invariant)

**This is the section where the four implementations genuinely differ**, and the reverse-gen
rule "differences become realizations or rules" applies at its sharpest. The coverage set — the
list of Swift-native symbols a target probes — is a **per-target realization**, chosen to
exercise exactly the trampoline shapes that target has wired and proven. The **invariant** is:
*every symbol in the target's coverage set binds, is called live, and returns its known-good
value; the app reports the aggregate as all-pass.*

Realized coverage sets:

| Target | Shapes | Symbols (each: known-good expected) |
|---|---|---|
| racket, chez, gerbil | 2 | `CreateML.timestampSeed() -> Int` (time-derived; expected: a valid `Int`) · `CreateML.MLCreateErrorDomain: String` (expected: `"com.apple.CreateML"`) |
| sbcl | 5 | `CoreGraphics.hypot(3,4) -> 5.0` · `Foundation.NSNotFound -> NSIntegerMax` · `NSNumber(integerLiteral: 42).intValue -> 42` · `Scanner("APIAnyware:SBCL").scanUpToString(":") -> "APIAnyware"` · `IndexSet(5)` insert/contains round-trip `-> true` |

**Why they differ (a fact, not a defect).** racket/chez/gerbil scope this app to the
**function + constant** trampoline slice (the two known-good exemplars the mechanism was
first proven against); they carry the **method/init** slice in a *separate*
`swift-native-method-probe` app. sbcl **merges** function + constant + init + method +
value-opaque-box into this one probe (its 060 ladder defers the value-STRUCT-owner and
async-method shapes by design). So `swift-native-probe`'s spec must abstract over the
coverage set; the `swift-native-method-probe` sibling's own-spec question is deferred to
`portfolio-coverage-tie-in-k85` (noted here, not resolved).

**Value determinism.** Some probed values are deterministic and directly assertable
(`"com.apple.CreateML"`, `5.0`, `42`, `"APIAnyware"`, the IndexSet round-trip boolean); one is
**non-deterministic** (`timestampSeed()` is time-derived — assert *that an Int was returned*,
never a specific value). Because determinism varies per symbol and the whole set varies per
target, **on-screen value assertions are not the spec's coverage channel** — the
[logging contract](logging-contract.md)'s per-shape `ok` flags and all-pass summary are.

## 7. Application menu

Identical to hello-window §6. The mandated invariant is a **Quit** command:

- **Title:** `"Quit " + <display name>` (i.e. `Quit Swift-Native Probe`).
- **Key equivalent:** **Command-Q**.
- **Action:** `-[NSApplication terminate:]`.

Other conventional first-menu items (About, Hide, …) are optional and not asserted.

## 8. API surface exercised

**Chrome** — identical to the hello-window spec §7 (NSApplication singleton/policy/menu/run/
terminate; NSWindow designated init/title/center/contentView/makeKeyAndOrderFront;
NSTextField-as-label with the four static-label flags; NSFont `systemFontOfSize:`;
NSColor `systemBlueColor` / `secondaryLabelColor`; NSView `addSubview:`; NSMenu/NSMenuItem
graph; NSRect value types). Not re-tabulated here — see hello-window §7.

**The probed Swift-native residual** — the point of the app. These are decls carrying
`objc_exposed: false`, reached through the per-target `@_cdecl` trampoline entries
(`aw_<target>_swift_*`), never a C symbol:

| Shape | Example realized decl | Trampoline nature |
|---|---|---|
| free function (scalar) | `CreateML.timestampSeed() -> Int`; `CoreGraphics.hypot(_:_:) -> Double` | scalar in / scalar out |
| constant (pointer / scalar) | `CreateML.MLCreateErrorDomain: String`; `Foundation.NSNotFound: Int` | `id` (NSString) or scalar global |
| class-owner initializer | `NSNumber(integerLiteral:)` | Swift-native init → a real wrapped ObjC object |
| class-owner method | `Scanner.scanUpToString(_:)` | receiver-handle method on a real class |
| value-opaque box | `IndexSet` init / `contains` / `insert` | a non-class Swift value crossing as an opaque box handle |

Which of these a given target exercises is its coverage set (§6). The *mechanism* — a
`@_cdecl` trampoline for an `objc_exposed:false` decl — is the projection-free truth.

## 9. Observable outcomes & accessibility

**Visual outcomes:**
- A fixed-size titled window appears, centred, with the title bar reading
  `Swift-Native API Coverage` (exact, all four).
- The window shows close and minimize buttons but **no** resize/zoom affordance.
- A centred heading, one or more `name → value` rows (values in system blue), and a
  secondary-colour footer are displayed as static labels.

**Accessibility expectations:**
- The window is exposed as an accessibility window element whose AXTitle equals
  `Swift-Native API Coverage`.
- The labels are exposed as **static-text** elements (non-editable/non-selectable ⇒ not
  text-input elements); their values fold to AXTitle (the value→AXTitle behaviour observed
  across the portfolio). *(Which row values are assertable is per §6 — deterministic strings
  only; the coverage proof channel is the log, not AX/OCR.)*
- The application menu and its **Quit** item (Command-Q) are reachable in the AX tree.

**The launch/probe diagnostic is a log obligation, not stdout.** Every impl echoes its probe
results to standard output for human convenience, but under `open` (LaunchServices) stdout is
discarded and unreadable by the runner. The runner-observable contract is the
[logging contract](logging-contract.md): a tailed `events.log` carrying the lifecycle triad,
the per-shape `[probe]` events, and the `[probe] complete … all-ok` summary.

## 10. Behavioural exemplar (acceptance / forward-generation input)

Each behaviour is an *observable* assertion against a live-VM instance, annotated with the
scenario-runner verb it maps to. This section is the enumeration; the `#lang app-spec` suite
is forward-generated from it (child `forward-gen-live-run`). Kept deliberately lean — the
probe's proof is the all-pass event, not a broad behavioural surface.

- **Process is running after launch.** → `expect-running-app`
- **Readiness / launch diagnostic.** The event log carries `[lifecycle] startup` and a line
  beginning `Swift-Native Probe opened.`. → `wait-ready` / `wait-for-log` / `expect-log`
- **All probes passed (the coverage proof — target-agnostic).** The event log carries a
  `[probe] complete` summary with `all-ok=#t` (and `ok` == `count`). → `expect-log` /
  `wait-for-log "[probe] complete"` matching `all-ok=#t`.
- **Window title is correct.** The title bar / AXWindow shows `Swift-Native API Coverage`
  (exact). → `expect-ocr "Swift-Native API Coverage"` and/or `expect-ax` window AXTitle.
- **The heading identifies the Swift-native surface.** The substring `Swift-native APIs` is
  readable. → `expect-ocr "Swift-native APIs"` *(stable substring; the library name is not
  asserted)*.
- **At least one coverage row is present as static text.** → `expect-ax` static-text element.
- **Quit menu exists.** `Quit Swift-Native Probe` bound to Command-Q. → `expect-ax` menu item.
- **Command-Q terminates the app.** The chord ends the process and the log records
  `[lifecycle] shutdown reason=menu`. → `chord cmd q`, then `expect-running-app` false /
  `expect-log "shutdown reason=menu"`.
- **(To confirm in-VM) Close-button keeps the process running.** Activating the window's
  close control hides it; per §3 the process is expected to **keep running** (no impl opts
  into close-to-quit). A scenario records the *actual* behaviour. → `click-at` close button,
  then `expect-running-app` (expected true).

## 11. Gaps / to confirm in-VM

- Per-shape on-screen value legibility at 11–15pt is subject to the portfolio's OCR
  small-text run-mechanism class (k103); the log channel, not OCR, is the coverage proof.
- The `all-ok` summary depends on each impl adding a per-shape correctness check + event
  emission (it does **not** exist in the current impls, which only *display* the values) —
  that is the `instrument-builds` child's work, specified by the
  [logging contract](logging-contract.md).
- Window size and footer wording are realizations (§4, §5); never asserted exactly.
