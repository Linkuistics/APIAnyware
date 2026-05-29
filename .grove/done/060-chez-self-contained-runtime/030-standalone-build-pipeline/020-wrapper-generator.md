# 020-wrapper-generator

**Kind:** work

## Goal
Replace `010`'s hand-coded hello-window `except` set with an **automatic
top-level-program wrapper generator**: given any app's `--script`-style entry,
the bundler computes the duplicate-import collision set from the app's import
closure and emits a strict R6RS top-level program whose framework facades yield
(`(except <facade> <names>…)`) to `runtime/objc` + `(chezscheme)`, ending in
`(scheme-start (lambda args (main) 0))`. App authors keep writing `--script`
entries (no authoring-convention change — spec §3 decision).

## Context
- Why it's needed (F2): `load`/`--script` evaluates in the interaction
  environment (last-wins rebinding); `compile-program`/`compile-whole-program`
  enforce strict top-level-program semantics where a name exported by two
  imported libraries is a hard duplicate-import error. hello-window has exactly 4
  such collisions; other apps will differ — so the set must be **computed**.
- Mechanism (spec §3 + spike F2): compute each imported library's exports via a
  chez `environment-symbols` probe (sibling to `deps.rs`'s `extract-deps.ss`
  shell-out pattern), classify imports as **facade** (`(apianyware <fw>)`) vs
  **curated** (`(apianyware runtime …)` + `(chezscheme)`), and for every name a
  facade shares with a curated lib add it to that facade's `except` clause. The
  facade always yields.
- Keep British-vs-American spelling working: `localised`/`localized`,
  `userinfo`/`user-info` already don't collide — don't "fix" them.
- The generator parses the app entry's leading `(import …)` form and its trailing
  top-level `(main)` call. All 7 apps follow this shape (`(import …)` … `(main)`),
  verified 2026-05-29. Use chez's own reader for the parse (don't hand-roll an
  s-expr parser in Rust — same rationale as `deps.rs`).

## Done when
- A `scripts/standalone-collisions.ss` (or equivalent) probe + Rust glue compute
  the per-facade `except` lists for an arbitrary app from its import set.
- `standalone.rs` generates the wrapper for `hello-window` and reproduces the
  hand-coded `010` result **exactly** (same 4 names, same facade assignment) —
  this is the regression anchor.
- The generated wrapper drives the full pipeline to a `codesign --strict`-valid
  `Hello Window.app` (same bar as `010`, now via generated wrapper).
- A unit/integration test asserts the computed collision set for hello-window's
  import closure is `{nserror-code, nserror-domain, reverse,
  nsevent-location-in-window}` mapped to the right facades.
- `cargo build`/`cargo test -p apianyware-macos-bundle-chez` green.

## Notes
- At least one *other* app (pick a richer one, e.g. ui-controls-gallery or
  note-editor) should be run through the generator to confirm it computes a
  *different* set without error — generality check, no full build required.
- The trailing-`(main)` → `(scheme-start …)` rewrite must be robust to whitespace
  / a trailing newline; prefer reading the entry as data and reconstructing over
  fragile text munging where practical.
- [[feedback-chez-target-idiomatic-not-portable]],
  [[feedback-regenerate-pipeline-aggressively]].
