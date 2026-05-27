# 090-bundle-chez

**Kind:** work

## Goal
Stand up `generation/crates/bundle-chez/` mirroring `bundle-racket`'s
surface (source-launched, per the 010 grilling). A chez app source tree
+ runtime + generated tree + dylib + Info.plist becomes a runnable `.app`.

## Context
- Design spec §8 (bundle layout, stub-launcher dispatch into
  `chez --script`).
- `generation/crates/bundle-racket/src/{lib.rs,bundle.rs,deps.rs,spec.rs}`
  — mirror exactly, with the source-tree pattern adapted from `.rkt` to
  `.sls`.
- `generation/crates/stub-launcher/` — the existing Swift stub that
  bundle-chez configures to exec `chez --script`.

## Done when
- `generation/crates/bundle-chez/` compiles and `cargo test` passes.
- `apianyware-macos-bundle-chez hello-window` (or however
  `bundle-racket`'s CLI is shaped today) produces a `.app` with the
  layout from design spec §8.
- The `.app`'s `MacOS/<App>` stub launches `chez --script` on the
  right entry file. The app **runs** (full end-to-end UI test waits
  for leaf 100).
- Bundle-time signing identity resolution mirrors bundle-racket's
  `LOCAL_SIGNING_IDENTITY` constant.

## Notes
- `deps.rs` must traverse `(import …)` forms in `.sls` files, not
  `(require …)` in `.rkt`. The import form is richer (renaming, prefix,
  rename, only-export) — keep the traversal conservative (find the
  library reference, recurse).
- The dylib must always ship in the bundle (mandatory-dylib decision).
  No fallback path.
