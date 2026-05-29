# 030-dylib-prelude-and-banner

**Kind:** work

## Goal
Replace the spike's `chdir`-from-C expedient (F3) with the spec §4 **prelude
object**: a tiny Scheme object linked into the boot *ahead of* the app that sets
`(library-directories)` to an exe-relative `../Resources` path, so
`ffi.sls`'s `resolve-dylib-path` finds `lib/libAPIAnywareChez.dylib` during boot
load without touching the process cwd. Also suppress the kernel startup banner
(F6) via `(suppress-greeting #t)` before the heap runs.

## Context
- The problem (F3): the standalone has no stub to pass `--libdirs`; the embedded
  kernel's `(library-directories)` defaults to `"."` and does **not** read
  `CHEZSCHEMELIBDIRS` (that's the standard executable's arg parsing, which a
  custom host bypasses). `resolve-dylib-path` probes each `(library-directories)`
  entry **during boot load** — before any app-controlled Scheme hook — so the
  search root must be seeded earlier, by a prelude that instantiates first.
- Boot ordering: `make-boot-file '() petite scheme prelude.so whole.so` — the
  prelude's top-level forms run before the whole-program object's, hence before
  the `apianyware` libraries (tree-shaken into `whole.so`) instantiate.
- The prelude needs the exe-relative resource dir at runtime. The embedding host
  (`embed_main.c`) already resolves `resdir` (`<exe>/../Resources` or flat);
  hand it to the prelude — simplest is `setenv("AW_RESOURCE_DIR", resdir, 1)`
  before `Sbuild_heap`, prelude reads `(getenv "AW_RESOURCE_DIR")`. Confirm
  `getenv` works under the embedded kernel (libc call; expected yes). Then drop
  the `chdir`.
- `(suppress-greeting #t)` belongs in the prelude (runs before the banner would
  print). Verify the banner is actually gone from a console run.

## Done when
- `embed_main.c` no longer `chdir`s; it `setenv`s the resource dir (or an
  equivalently clean hand-off) and the prelude sets `(library-directories)` from
  it. Process cwd is left untouched.
- Prelude object is compiled and concatenated into the boot ahead of the app;
  `hello-window` standalone still loads `libAPIAnywareChez.dylib` and draws its
  window.
- Console run (`AW`-style smoke or just running the bare binary) shows **no**
  `Chez Scheme Version …` banner.
- `codesign --strict` still valid; `cargo build`/`test -p
  apianyware-macos-bundle-chez` green.

## Notes
- If the prelude-in-boot ordering misbehaves (whole-program object expecting to
  be the sole program), fall back is documented in the spike (chdir works) — but
  prefer the prelude; record any surprise in `chez.md`/the spec.
- Local launch sanity only; the authoritative no-Chez VM proof is `040`.
- [[feedback-chez-target-idiomatic-not-portable]],
  [[feedback-regenerate-pipeline-aggressively]].
