# bundle-chez

Bundle chez sample apps into macOS `.app` directories.

```text
cargo run --example bundle_app -p apianyware-bundle-chez -- hello-window
cargo run --example bundle_app -p apianyware-bundle-chez -- --all
```

Output lands at
`targets/chez/app-implementations/macos/<script-name>/build/<App Name>.app`.

## Pipeline

1. Resolve the entry script under `apps/<script>/<script>.sls`.
2. Shell out to `chez --script scripts/extract-deps.ss` to find every
   `.sls` the entry transitively `(import …)`s — Chez itself does the
   reading and library-name resolution, so the dep walker handles
   every R6RS / Chez wrapper form (`only`, `except`, `prefix`,
   `rename`, `for`, `library`) without a hand-rolled s-expression
   reader.
3. Copy each `.sls` into `Resources/chez-app/<rel>` and lay out the
   mandatory `libAPIAnywareChez.dylib` under
   `Resources/chez-app/lib/`.
4. **Pre-compile** every staged library `.sls` into a sibling `.so`
   via `chez --script scripts/precompile.ss` — see below.
5. Codesign the bundle.

## Pre-compile pass

Chez does not cache compiled `.so` files for `--script` invocations;
every cold launch otherwise recompiles every imported library from
source. The AppKit facade alone is 70k lines; the on-import compile
costs ~75s on the dev host. Pre-compiling at bundle time turns that
into ~1.85s.

The pass iterates **only root libraries** —
`apianyware/<fw>.sls` (framework facades) and
`apianyware/runtime/<cluster>.sls` (runtime libraries) — and lets
`(compile-imported-libraries #t)` chase the per-class leaves
(`apianyware/<fw>/<cls>.sls`) and protocols
(`apianyware/<fw>/protocols/<p>.sls`) transitively in one consistent
run.

The naive alternative — iterate every `.sls` and call
`compile-library` on each — produces a `.so` per source, but each
later call writes a fresh timestamp that invalidates the dependants'
"I was compiled when my deps looked like X" record. Chez then
reloads from source on import, defeating the cache. Root-only
iteration is the consistency-preserving variant.

### Caveats

- **Chez-version coupling.** `.so` files carry the exact Chez
  version's compiled output. If the host's Chez upgrades after a
  bundle is built (e.g. `brew upgrade chezscheme`), `--script`
  startup errors with a version-mismatch condition. **Rebuild the
  bundle after a Chez upgrade.**
- **Bundle-size growth.** The compiled `.so` files roughly triple
  bundle size (hello-window: 38M source-only → 102M with `.so`).
  Acceptable for a launch-time cache; reconsider if a much larger
  framework lands.
- **Entry script is not precompiled.** The per-app entry script
  (`apps/<script>/<script>.sls`) is a top-level program, and the
  stub launcher invokes Chez as `--script <entry.sls>` (exact-path).
  Pre-compiling the entry to `.so` would require also pointing the
  launcher at `.so` — out of scope for the current launcher shape.
  The entry script body is small (~60 lines for hello-window); cold
  launch with the library cache in place is dominated by image
  startup, not by compiling the entry.

### Skipping the pass

Set `skip_precompile: true` on `AppSpec` to opt out. The example
binary (`examples/bundle_app.rs`) also honours the
`APIANYWARE_BUNDLE_CHEZ_SKIP_PRECOMPILE` env var as a convenience
for one-off CLI invocations:

```text
APIANYWARE_BUNDLE_CHEZ_SKIP_PRECOMPILE=1 \
  cargo run --example bundle_app -p apianyware-bundle-chez -- hello-window
```

The skipped bundle is smaller and survives a Chez upgrade unchanged,
but pays the full on-import compile cost at every cold launch. The
project's per-app TestAnyware runs use the precompiled (default)
form; the env var exists for emitter-debugging iterations where a
fast bundle-rebuild matters more than a fast launch.
