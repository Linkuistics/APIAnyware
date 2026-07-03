# Swift-Native Probe — Observable State

> **Porting guide.** What an implementation of Swift-Native Probe must make *observable* to
> the AppSpec runner's VM-side verbs (OCR, accessibility, process, input). Derived from spec
> §9 (Observable outcomes & accessibility) and §10 (behavioural exemplar); maps each observable
> to the runner verb that reads it. Unlike the [logging contract](logging-contract.md), nothing
> here is the impl's to *log* — these are states the **VM observes** of a correctly-built impl
> (driver-binds-environment, ADR-0008 C3). The porting obligation is "build the UI so these
> reads succeed," not "emit these."
>
> **Central design point.** This probe's coverage proof is **not** observable on-screen: the
> probed symbols and their values differ per target (spec §6), and small-text values are
> subject to the OCR run-mechanism class (k103). The proof lives in the
> [logging contract](logging-contract.md)'s `[probe] complete … all-ok=#t` event. The
> observables below are the **structural frame** only (the window exists, is titled correctly,
> shows the Swift-native heading, and terminates on Quit).

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `pgrep` by the descriptor's `#:bundle-id` (`com.linkuistics.swift-native-probe-<impl>`); the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | scenario `02`: the ⌘Q chord must reach `-[NSApplication terminate:]` (standard app menu) and end the process. |
| The app process **keeps running** after the close button | `expect-running-app <bundle-id>` (still true) | scenario `03`: no impl opts into close-to-quit (spec §3), so closing the window hides it and the process survives. The run records the *actual* behaviour (a failure would be a spec-quality finding, not a suite bug). |

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The title bar reads `Swift-Native API Coverage` | `expect-ocr "Swift-Native API Coverage"` | **exact and identical on all four impls** (spec §4) — directly assertable, unlike hello-window's per-impl title. |
| The heading identifies the Swift-native surface | `expect-ocr "Swift-native APIs"` | only the **stable substring** `Swift-native APIs` is asserted; the per-impl library name (`libAPIAnywareRacket`/…) is never asserted — projection-free. |

*Per-shape row values are **not** OCR-asserted:* they differ per target (spec §6) and are
11–15pt (the k103 small-text class). Their correctness is proven via the log, not OCR.

## Accessibility (AX tree)

| Observable | Verb | Notes |
|---|---|---|
| A window element exists | `expect-ax #:role 'AXWindow` | its AXTitle equals `Swift-Native API Coverage` (exact — assertable via `#:title` here, since projection-free). |
| At least one static-text element exists | `expect-ax #:role 'AXStaticText` | the labels are non-editable/non-selectable ⇒ exposed as **static text**, not text fields. (Coverage-row values fold to AXTitle where legible, but which are deterministic is per §6 — do not hard-assert a specific value.) |
| No editable text field is exposed | `expect-no-ax #:role 'AXTextField` | structural guard for "no interactive editing" — the labels must NOT surface as `AXTextField`. Scope to the app-window content (`#:scope 'app-content`, AppSpec `cb178f8`) so window title-bar chrome and foreign desktop widgets do not trip it (the drawing-canvas k140 finding — directly inherited). |
| The Quit menu item exists with Command-Q | `expect-ax` menu item | `Quit Swift-Native Probe` bound to ⌘Q. Key-equivalent matching depends on `expect-ax #:key` (portfolio gap 2); asserted structurally where possible, reported as a gap otherwise. |

## Deferred / gap observables (not acceptance preconditions)

- **Window size** → `expect-ax #:size` (gap 2). Also a **realization** (560×240 vs 640×300,
  spec §4) — even once the verb exists, assert loosely or not at all.
- **Window centred** → `expect-ax #:position` (gap 2). The impl calls `center`; the assertion
  is deferred.
- **Command-Q key-equivalent** → `expect-ax #:key` (gap 2; may reach into TestAnyware if
  `gv-ax-snapshot` lacks `AXMenuItemCmdChar`).

## Build obligation summary (per impl)

A conformant build must render a fixed-size titled window whose title bar reads
`Swift-Native API Coverage`, a centred heading beginning `Swift-native APIs`, one or more
static-text `name → value` coverage rows (values live, in system blue), a secondary-colour
footer, and a standard app menu whose **Quit** item carries ⌘Q wired to `terminate:` — and it
must **keep running when the window is closed**. Beyond these observables, it must satisfy the
[logging contract](logging-contract.md) (the coverage proof). The four existing sources
already construct all of the *visual* structure; instrumenting the log is the
`instrument-builds` child's work.
