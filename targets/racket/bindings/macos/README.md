# `bindings/macos/` — the Racket binding (macOS)

The Racket-facing binding for the macOS platform. Per REFACTOR.md §18 / §42:

| dir          | role                                                              |
|--------------|------------------------------------------------------------------|
| `generated/` | emitted per-framework `.rkt` binding source (gitignored, absent) |
| `runtime/`   | hand-written runtime modules (FFI seam, object model, helpers)    |
| `lib/`       | the built `libAPIAnywareRacket.dylib` (symlink into the racket adapter package's `.build`) |
| `tests/`     | Racket-level binding tests                                        |
| `reports/`   | screenshots / VM-verify artifacts (was `test-results/`)          |
| `docs/`      | §22 binding mapping docs (`user-guide`, `platform-docs-mapping`, `api-coverage`, `unsafe-escape-hatches`) |

The §18 *target* docs (overview, language characteristics, FFI model, idiom map,
representability) live one level up at [`../../docs/`](../../docs/); the authored
target-model `.apiw` entities are under [`../../`](../../) (`target.apiw`,
`capability.apiw`, `idioms/`, `policies/`, `adapters/`, `conformance/`).

## Open follow-ups (skeleton relocate — `move-racket-material-k11`)

- **dylib home is `lib/`, not §42's `build/`** *(→ ws6 child 7, bundler reshape)*. The
  runtime loads the dylib via a single hardcoded `../lib/` path
  (`runtime/swift-helpers.rkt`, `runtime/ffi2-dispatch.rkt`), and the bundler copies
  it to `racket-app/lib/` inside each `.app` with an `@executable_path/.../racket-app/lib/`
  install name. Moving the in-tree dylib to §42's `build/` would force that one
  load-path to diverge between the in-tree and in-bundle contexts. The target model
  (ws6) is authored against the dylib *as it is* — the adapter spec
  ([`../../adapters/macos/spec.apiw`](../../adapters/macos/spec.apiw)) documents the
  existing `APIAnywareRacket` library, no ABI redesign. The remaining in-tree-vs-bundle
  load-path reconciliation is a **bundler concern, deferred to ws6 child 7 (bundler
  reshape + guide resync)**. Kept at `lib/` here so the move stays behaviour-preserving.
- **`runtime/` stays here (ws6-resolved).** The adapter-model question — is the
  hand-written runtime binding-level or adapter-level? — is settled by the ws6 target
  model: the *native adapter* (the Swift `APIAnywareRacket` sources + dylib) is the
  `adapters/macos/` material the [adapter spec](../../adapters/macos/spec.apiw)
  describes; the Racket-side `runtime/` (ffi2 seam, object model, bridges' Racket faces)
  is **binding-level and stays at `bindings/macos/runtime/`**. No move.
