# 010-pipeline-skeleton-handwrapper

**Kind:** work

## Goal
Port the spike's proven pipeline into `bundle-chez/standalone.rs` as a new
public `bundle_app_standalone(spec, source_root, output_dir)` that builds a
self-contained `hello-window` `.app` **entirely from Rust**. To isolate the
orchestration from the wrapper-generator problem (`020`), use a **hand-coded**
hello-window top-level-program wrapper (the spike's 4-`except` reconciliation,
F2) and the spike's proven `chdir`-host `embed_main.c` (F3 — the prelude is
`030`). End state: `bundle_app_standalone` produces a `Hello Window.app` that
`codesign --verify --strict` accepts, on this dev host.

## Context
- Recipe to port verbatim: spike evidence
  `docs/research/2026-05-29-chez-standalone-spike-evidence/`
  (`embed_main.c`, `hw-entry.ss`, `build_whole.sh`, `link_standalone.sh`,
  `assemble_app.sh`) and spec §2/§5.
- Kernel artifacts on this host:
  `/opt/homebrew/Cellar/chezscheme/10.4.1/lib/csv10.4.1/tarm64osx/`
  (`petite.boot`, `scheme.boot`, `libkernel.a`, `liblz4.a`, `libz.a`, `scheme.h`;
  **not** `main.o`, F9). Discover the dir from the host install (don't hardcode
  the version) — glob `…/Cellar/chezscheme/*/lib/csv*/tarm64osx`.
- Reuse `deps.rs` to stage the `apianyware/` + `apps/<name>/` + `lib/` tree into
  the temp build dir that the whole-program compile reads (`library-directories`).
- The hand-wrapper = `hw-entry.ss` minus the spike's `prove-dynamic-load`
  scaffolding: the real `hello-window` imports with `(except (apianyware appkit)
  nsevent-location-in-window)` + `(except (apianyware foundation) nserror-code
  nserror-domain reverse)`, the app body, and `(scheme-start (lambda args (main)
  0))` instead of the top-level `(main)`.
- `embed_main.c` + the hand-wrapper live as `include_str!` resources in the
  crate (like `extract-deps.ss`), materialised to the temp build dir.

## Done when
- `standalone.rs` exists; `bundle_app_standalone` runs, from Rust: stage tree →
  write wrapper + `embed_main.c` to a temp build dir → `compile-program` +
  `compile-whole-program` (sealed `#f`) → `make-boot-file '() petite scheme
  whole.so` (open-world) → `cc -O2 -I<kernel> -DBOOTNAME=… embed_main.c
  libkernel.a liblz4.a libz.a -liconv -lncurses -lz -framework Foundation
  -framework AppKit` → assemble `.app` (`MacOS/<bin>` + `Resources/{<boot>,
  lib/libAPIAnywareChez.dylib}`, F4) → sign nested dylib then bundle (F5).
- `Hello Window.app` builds; `codesign --verify --strict --verbose=2` → valid;
  `codesign -dvvv` shows the `APIAnyware Local Signing` identity + a CDHash.
- An `examples/bundle_standalone.rs` (or extend the existing example) drives it
  for `hello-window`.
- Source-exec `bundle_app` path untouched and still compiles/tests green.
- `cargo build -p apianyware-macos-bundle-chez` + `cargo test -p
  apianyware-macos-bundle-chez` green.

## Notes
- Local launch check (windowed) optional here; the **no-Chez VM** proof is `040`.
  A quick local `open` of the `.app` is a sanity tell, not the done-bar.
- Keep iteration cheap: the 160 s whole-program compile is unavoidable for the
  real closure, but develop the Rust glue against a tiny throwaway entry first if
  helpful, then validate once on hello-window.
- Don't reinvent codesign/install-name logic — reuse `stub-launcher`'s
  `codesign_path` and the `normalize_dylib_install_names` pattern from `bundle.rs`
  (install-name now `@executable_path/../Resources/lib/<dylib>`).
- [[feedback-chez-target-idiomatic-not-portable]],
  [[feedback-regenerate-pipeline-aggressively]].
