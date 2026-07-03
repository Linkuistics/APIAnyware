# Hello Window — Observable State

> **Porting guide.** What an implementation of Hello Window must make *observable* to the AppSpec
> runner's VM-side verbs (OCR, accessibility, process, input). Derived from spec §9 (Observable outcomes
> & accessibility) and §10 (behavioural exemplar); maps each observable to the runner verb that reads it.
> Unlike the [logging contract](logging-contract.md), nothing here is the impl's to *log* — these are
> states the **VM observes** of a correctly-built impl (driver-binds-environment, ADR-0008 C3). The
> porting obligation is "build the UI so these reads succeed," not "emit these."

## Process

| Observable | Verb | Notes |
|---|---|---|
| The app process is running after launch | `expect-running-app <bundle-id>` | `pgrep` by the descriptor's `#:bundle-id` (`com.linkuistics.hello-window-<impl>`); the impl must build to a `.app` whose `CFBundleIdentifier` matches. |
| The app process is gone after Command-Q | `expect-running-app <bundle-id> #:running? #f` | scenario `03`: the Cmd-Q chord must reach `-[NSApplication terminate:]` (standard app menu) and end the process. |

## On-screen (OCR)

| Observable | Verb | Notes |
|---|---|---|
| The greeting `Hello, macOS!` is readable | `wait-for-ocr "Hello, macOS!"` / `expect-ocr` | the 24pt centred label; literal substring match. |
| The title bar shows `Hello from <impl>` | `expect-ocr "Hello from"` | only the **stable substring** `Hello from` is asserted (the per-impl identity — `Hello from Racket` etc. — is never asserted; projection-free). |

## Accessibility (AX tree)

| Observable | Verb | Notes |
|---|---|---|
| A window element exists | `expect-ax #:role 'AXWindow` | the per-impl AXTitle (`Hello from <impl>`) is not asserted via `expect-ax` (its `#:title` is exact-match, so impl-specific) — title is covered by the OCR substring above. |
| A static-text element exists | `expect-ax #:role 'AXStaticText` | the label is non-editable/non-selectable ⇒ exposed as **static text**, not a text field. Its value `Hello, macOS!` is asserted via OCR (`expect-ax` has no `#:value`). |
| No editable text field is exposed | `expect-no-ax #:role 'AXTextField` | structural guard for "no interactive editing" (§10) — the label must NOT surface as an `AXTextField`. |
| The Quit menu item exists with Command-Q | `expect-ax` menu item (gap-2) | `Quit Hello Window` bound to ⌘Q. **Deferred:** key-equivalent matching needs `expect-ax #:key` (gap 2, node `07-acceptance-test-k21` brief); asserted structurally where possible, reported as a gap otherwise. |

## Deferred / gap observables (not acceptance preconditions)

Per the node brief and `AppSpec/capabilities/forward-gen/validation.md` §6, these §10 behaviours map to
verbs that do not yet exist; the suite asserts the runnable subset and **reports** these as gaps rather
than hard-asserting before the verb exists (the forward-gen "mutant-D" failure):

- **Window size ≈ 400×200** → `expect-ax #:size` (gap 2). The impl builds the 400×200 content rect (all
  four sources already do); the *assertion* is deferred.
- **Window centred** → `expect-ax #:position` (gap 2). The impl calls `center`; the assertion is deferred.
- **Command-Q key-equivalent** → `expect-ax #:key` (gap 2; may reach upstream into TestAnyware if
  `gv-ax-snapshot` lacks `AXMenuItemCmdChar`).
- **Close-button behaviour** (`recording` scenario `03`) → `click-at` close button + `expect-running-app` true.
  These impls do **not** opt into close-to-quit (spec §3.8), so the window hides and the process
  **keeps running** — confirmed in-VM on all four implementations. A failure would now be a regression
  / spec-quality finding, not a suite bug (ADR-0010 D4).

## Build obligation summary (per impl)

A conformant build must, with no extra logging: render the 400×200 centred titled window
(`Hello from <impl>`), a centred 24pt **static-text** label `Hello, macOS!` (not editable/selectable,
so not an `AXTextField`), and a standard app menu whose **Quit** item carries ⌘Q wired to
`terminate:`. The four existing sources already construct all of this; this doc is the porting
checklist for a *future* impl.
