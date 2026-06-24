# `bindings/macos/` — the Racket binding (macOS)

The Racket-facing binding for the macOS platform. Per REFACTOR.md §18 / §42:

| dir          | role                                                              |
|--------------|------------------------------------------------------------------|
| `generated/` | emitted per-framework `.rkt` binding source (gitignored, absent) |
| `runtime/`   | hand-written runtime modules (FFI seam, object model, helpers)    |
| `lib/`       | the built `libAPIAnywareRacket.dylib` (symlink into the racket adapter package's `.build`) |
| `tests/`     | Racket-level binding tests                                        |
| `reports/`   | screenshots / VM-verify artifacts (was `test-results/`)          |

## Open follow-ups (skeleton relocate — `move-racket-material-k11`)

- **dylib home is `lib/`, not §42's `build/`.** The runtime loads the dylib via a
  single hardcoded `../lib/` path (`runtime/swift-helpers.rkt`,
  `runtime/ffi2-dispatch.rkt`), and the bundler copies it to `racket-app/lib/`
  inside each `.app` with an `@executable_path/.../racket-app/lib/` install name.
  Moving the in-tree dylib to §42's `build/` would force that one load-path to
  diverge between the in-tree and in-bundle contexts — a reconciliation that
  belongs to the **bindings/adapter-model workstream (root brief item 6)**, not a
  skeleton relocate. Kept at `lib/` here so the move is behaviour-preserving.
- **`runtime/` may move to `adapters/macos/`.** Racket is the only target with a
  hand-written top-level runtime; the adapter-model workstream (item 6) decides
  whether it is binding-level (here) or adapter-level material.
