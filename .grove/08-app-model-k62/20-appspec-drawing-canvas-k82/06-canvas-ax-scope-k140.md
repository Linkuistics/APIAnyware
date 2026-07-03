# canvas-ax-scope-k140

**Kind:** work (carries a small verb-design decision — grill it if it proves contentious)

## Goal

Close the **live-run-k139 scenario-03 finding** so the drawing-canvas suite reaches a
genuine **17/17 on all four impls**. Scenario 03 (`recording: canvas exposes no content
elements`) is the sole red of the k139 live run — byte-identical on racket/chez/gerbil/sbcl —
and it is **not an impl defect**: the canvas is genuinely AX-absent (the §6/§12/§13 spec fact is
confirmed), but the scenario's assertion `(expect-no-ax #:role 'AXStaticText)` scans the
**whole-system** `agent snapshot` and trips on **platform chrome the canvas never produced** — the
app window's own **title-bar `AXStaticText "Drawing Canvas"`** (every titled AppKit window surfaces
its title this way in the TestAnyware agent) plus desktop **Notification Center** widget text.

Make the negative **discriminating**: give the AppSpec `expect-no-ax` negative a way to scope to the
app-under-test's **main-window content** (excluding window chrome + other apps' windows / desktop
widgets), regenerate scenario 03 to use the scoped negative, and **re-verify in a live VM** →
17/17 ×4. The user explicitly chose to chase the literal 17/17 (2026-07-03) rather than leave 03 as
an adjudicated recording-red.

## Context

- **The finding + evidence** are recorded in `apps/macos/drawing-canvas/docs/run-results.md`
  ("Adjudication → 03 (all four)"): the tripping `AXStaticText` nodes at steady state are the window
  title `"Drawing Canvas"` (title-bar chrome, present on every titled window) and the desktop
  widgets (e.g. "Photos will appear here…"). The canvas itself never appears as an element in **any**
  snapshot on **any** impl — that absence *is* the fact 03 is meant to assert.
- **The verb gap.** AppSpec's `expect-no-ax` (`AppSpec/runner/harness-observations.rkt` +
  `AppSpec/app-spec/main.rkt`; snapshot via `testanyware-sdk/agent.rkt gv-ax-snapshot`) takes
  `#:role` + optional exact `#:title` and walks the **whole** snapshot (all apps' windows +
  Menu Bar + Notification Center). There is no scope. `expect-ax` (the positive) has the same shape;
  a scope option likely wants to apply to both.
- **Design options — settle the verb shape first (WDYT, then implement):**
  1. **App-window scope** — restrict the walk to the app-under-test's window(s) (by `appName` /
     bundle). Removes the desktop-widget trips, but **not** the title-bar `AXStaticText`, which is a
     child of the app's own window — so this alone does **not** close 03.
  2. **App-window *content* scope** *(recommended)* — additionally exclude window chrome: walk only
     the window's content region (below the title bar / the toolbar band), or drop the title-bar
     `AXStaticText` whose text equals the window's `AXTitle`. This is what actually closes 03 (the
     canvas region has zero AX children) while staying honest (it still checks real content).
  3. **Re-conceive 03 positively** — assert the window's content is exactly the known toolbar
     controls (Color…/Clear/slider) and nothing else. More faithful to "no content structure" but
     needs an "exactly these" verb the closed set lacks.
  Prefer a small, general scoping mechanism on the negative (option 2) over a one-off — it is the
  reusable closer for the "no content AX on a custom-view surface" shape future apps will hit.
- **Boundary (mirror of the k139 gv-click fix).** The **verb extension is toolkit-side** — committed
  in the **AppSpec** repo (`main`), like `89fb98a`. The **regenerated scenario 03** is **app data** —
  committed **downstream** here (`apps/macos/drawing-canvas/scenarios/03-*.rkt`), a forward-gen
  refinement (feedback to forward-gen, per the run workflow §4 — never a run-loop suite patch). Keep
  the AppSpec KDL/verb docs + `app-spec` language reference in sync if the verb signature changes.
- **Re-verify needs a live VM** (the node done-bar, [[vm_verify_every_app]] — CLI smoke never
  satisfies it): re-provision (the four self-contained `.app`s install with `xattr` + `open -n`, no
  build provisioning — k139 recipe; scenario 03 needs no colour-panel seeding), re-run **03 on all
  four impls** (ideally the full suite to confirm no regression) → 03 green ×4. `run-values` are
  already live-measured (k139); the AppSpec runner is at `49a6340` **+ the k139 gv-click fix**.

## Done when

- Scenario **03 passes on all four impls (17/17 each)** in a live macOS VM, via a scoped
  `expect-no-ax` (or an equivalent re-conception) that genuinely verifies the canvas's AX-absence
  **without** tripping on window chrome — no impl behaviour changed, no suite patched to hide a real
  red.
- The AppSpec verb extension is committed **AppSpec-side** (with its verb-reference/docs updated);
  the regenerated scenario 03 is committed **downstream** here.
- `apps/macos/drawing-canvas/docs/run-results.md` is updated to record 03 resolved → **17/17 ×4**
  (superseding the k139 "sole red = 03" adjudication with the closure, keeping the history legible).
- Commits name `canvas-ax-scope-k140`.

## Notes

- This is the last open child of `appspec-drawing-canvas-k82`; on its retirement the node is done and
  its outcomes promote into the `app-model-k62` brief (the k77–k81 pattern), then the loop continues
  to `swift-native-probe-k83`.
- If the clean fix turns out to belong **upstream in TestAnyware** (e.g. the agent should not surface
  a window's title as a top-level `AXStaticText`), that is a legitimate finding to record — but the
  AppSpec-side scoped negative is the portable closer regardless of what any one agent emits.
