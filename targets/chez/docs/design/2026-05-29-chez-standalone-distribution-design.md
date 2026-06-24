# Chez self-contained distribution — design spec

**Status:** approved (output of
`.grove/060-chez-self-contained-runtime/020-decide-spec-and-grow.md`)
**Supersedes:** §8 ("Bundle-chez crate surface") of
`targets/chez/docs/design/2026-05-27-chez-target-design.md` — the source-exec / precompile
bundling model described there is retired by this spec.
**Companion ADR:** 0009 (chez apps bundle as self-contained binaries).
**Evidence:** `targets/chez/docs/research/2026-05-29-chez-standalone-spike.md` (the D1 spike
that proved the native standalone path, both modes, on a no-Chez VM).

## 1. Decision summary

Two calls, made on the spike's measurements:

- **D4 — Source-exec is retired entirely.** Chez `.app`s are distributed as
  self-contained binaries that embed the Chez kernel. There is no system-Chez
  dependency: `DEFAULT_CHEZ_PATH`, `launch.ss`, the precompile pass, and the
  Chez-version coupling all go away. (The unbundled
  `chez --libdirs <tree> --script <entry>` dev-run path is unaffected — it is
  not a bundle, and a dev machine has Chez installed.)
- **Closed-world is dropped (supersedes node decisions D2/D3).** Open-world
  standalone already delivers full self-containment (4.5 MB / 0.29 s cold
  launch). Closed-world's marginal gain over open-world is ~1 MB / ~60 ms, but
  closed-world for *dispatch-using* apps requires building an entire eval-free
  dispatch backend (spike F1/D2). On those numbers the gain does not justify the
  cost. **Open-world standalone is the single chez bundle shape.** The
  `eval`-synthesized `dispatch.sls` substrate stays as the *sole* dispatch
  backend; requirement 1 (runtime dynamic Scheme load) is satisfied universally
  and for free.

A consequence of single-mode + source-exec-retired: the `AppSpec` build-mode
enum proposed in node decision D5 (`SourceExec | StandaloneOpen |
StandaloneClosed`) **does not exist**. There is one bundle shape, so there is no
mode to select. If closed-world ever earns its place, it is added back as a
variant then — not speculated now.

## 2. The build pipeline (productionised from the spike)

The spike's hand-driven scripts become a new `standalone.rs` module in
`bundle-chez`. The pipeline, per app:

1. **Generate the top-level-program wrapper** (F2 — see §3). The bundler emits a
   strict R6RS top-level program around the app's entry, reconciling
   duplicate-import collisions.
2. **Whole-program compile.** `(generate-wpo-files #t)` +
   `(compile-imported-libraries #t)`, `(library-directories <chez-tree>)`,
   `(compile-program <wrapper>)`, `(compile-whole-program <wpo> <whole.so> #f)`.
   First pass over the import closure (incl. the ~70k-line AppKit facade) is
   ~160 s / ~1.6 GB peak RSS, one-time per app; `compile-whole-program`
   tree-shakes the 139 MB source closure to a ~413 KB object (hello-window).
3. **Make the self-contained boot** (open-world: compiler present).
   `(make-boot-file <app.boot> '() petite.boot scheme.boot whole.so)` — the
   **empty base list** plus boot files as ordinary inputs concatenates
   everything into one boot needing no external registration.
4. **Link the embedding host.** `cc -O2 -I<kernel> -DBOOTNAME=... -o <bin>
   embed_main.c <kernel>/libkernel.a liblz4.a libz.a -liconv -lncurses -lz
   -framework Foundation -framework AppKit`. `embed_main.c` does
   `Sscheme_init` → `Sregister_boot_file(<resdir>/BOOTNAME)` → `Sbuild_heap` →
   `Sscheme_start`; the app installs a `(scheme-start)` thunk rather than calling
   `(main)` at top level. **Do not link the kernel's `main.o`** — it defines its
   own `main()` and collides with `embed_main.c`'s (F9).
5. **Assemble + sign the `.app`.** `Contents/MacOS/<bin>` +
   `Contents/Resources/{<app.boot>, lib/libAPIAnywareChez.dylib}`; sign nested
   dylib, then bundle, with `APIAnyware Local Signing`. Yields a unique CDHash
   per app under the persistent identity.

Kernel artifacts are the Homebrew Chez 10.4.1 set under
`/opt/homebrew/Cellar/chezscheme/<v>/lib/csv<v>/tarm64osx/`: `petite.boot`,
`scheme.boot`, `libkernel.a`, `liblz4.a`, `libz.a`, `scheme.h`. These are a
**build-time** dependency of the bundler (the dev host has Chez); they are baked
into the boot and the shipped `.app` has no runtime Chez dependency. Their
discovery and the dev-repro recipe are documented by the toolchain-docs leaf
(original requirement 2).

## 3. The top-level-program wrapper (F2)

`load`/`--script` evaluates in the interaction environment (last-wins rebinding,
like Racket's `define`); `compile-program` / `compile-whole-program` enforce
strict R6RS top-level-program semantics where a name exported by two imported
libraries is a hard duplicate-import error. For hello-window's import set,
**exactly 4** identifiers collide:

| Identifier | exported by | …and by |
|---|---|---|
| `nserror-code` | `(apianyware foundation)` | `(apianyware runtime objc)` |
| `nserror-domain` | `(apianyware foundation)` | `(apianyware runtime objc)` |
| `reverse` | `(apianyware foundation)` (re-exported enum) | `(chezscheme)` |
| `nsevent-location-in-window` | `(apianyware appkit)` | `(apianyware runtime cocoa)` |

**Decision: the bundler emits a generated top-level-program wrapper**, rather
than changing the app-authoring convention. App authors keep writing
`--script`-style entries; the bundler computes the collision set from the app's
import closure (reusing the `deps.rs` walker + an `environment-symbols` probe)
and emits `(except <facade> <colliding-names>…)` clauses so the **framework
facades yield** to the curated runtime API and `(chezscheme)`. The wrapper's
body is the app's existing top-level forms. This keeps the reconciliation rule
mechanical and centralised; an app's import set determines its collisions, so the
generator is per-app, not a fixed list. (British-vs-American spelling already
spares `localised`/`localized` and `userinfo`/`user-info` from colliding — keep
that.)

## 4. The dylib-search-root prelude (F3)

`runtime/ffi.sls`'s `resolve-dylib-path` probes each `(library-directories)`
entry for `lib/libAPIAnywareChez.dylib` **during boot load** — before any Scheme
hook the app controls. The standalone has no stub-launcher to pass `--libdirs`,
the embedded kernel's `(library-directories)` defaults to `"."`, and a custom
host does **not** read `CHEZSCHEMELIBDIRS` (that is the standard executable's
arg-parsing). **Fix: link a tiny prelude object into the boot ahead of the app**
that sets `(library-directories)` from an exe-relative path
(`<bin>/../Resources`). This is cleaner than the spike's `chdir`-from-C
expedient and keeps the process cwd sane.

## 5. Bundle layout

```text
<App>.app/
  Contents/
    MacOS/<App>                          ← native binary: embed_main + libkernel + app boot
    Info.plist                           ← CFBundleName = "<App>"
    Resources/
      <App>.boot                         ← petite+scheme+app whole-program boot
      lib/libAPIAnywareChez.dylib        ← loaded at runtime by ffi.sls (mandatory)
```

The boot **and** dylib live under `Resources/`, not `MacOS/`: `codesign
--strict` rejects non-Mach-O files in `Contents/MacOS/` ("code object is not
signed at all"), so the `.boot` (a data file) is sealed as a resource (F4). The
host probes both a flat run-dir layout and the `.app` `../Resources` layout.
Banner suppression via `(suppress-greeting #t)` before `Sscheme_start` (F6) — the
kernel's startup banner is harmless in a windowed `.app` but noise in console
runs.

## 6. `bundle-chez` crate after the change

```text
generation/crates/bundle-chez/src/
  lib.rs
  bundle.rs        — AppSpec (no build-mode enum, no skip_precompile, no
                     runtime_path/DEFAULT_CHEZ_PATH); bundle_app drives standalone.rs
  deps.rs          — import-closure walker (retained; reused by the wrapper generator)
  standalone.rs    — NEW: the §2 pipeline + §3 wrapper gen + §4 prelude + §5 assemble/sign
  -- DELETED --
  launch.rs        — source-exec launch.ss bootstrap (gone)
  precompile.rs    — precompile pass (gone)
```

`AppSpec` keeps `app_name` / `bundle_id` / `script_name` /
`info_plist_overrides` / `signing_identity`; it loses `runtime_path` and
`skip_precompile`. The stub-launcher's execv-into-system-chez path for chez is
removed; **racket's stub-launcher path is untouched** (shared crate, out of
scope).

## 7. What this obsoletes

A self-contained binary with no system-Chez dependency evaporates several
deferred follow-ups (confirmed by the spike, recorded here per the leaf brief):

- **Leaf-160 Chez-version coupling** (`launch.ss` version-stamp + `.so-disabled`
  fallback): no system Chez → no cross-version `.so` mismatch. Gone.
- **Menu-bar-name gotcha** (chez.md 🟢 2026-05-26): no `execv` into a `chez`
  process to mislabel the menu bar — it reads `CFBundleName` directly. Gone.
- **Golden-image Chez pre-install** (050 brief): unnecessary for a standalone.
- **F8 re-measurement** of the source-exec baseline: moot — the path is deleted.
  The comparative conclusion (standalone ~30× smaller, ~50× faster) is what drove
  the D4 call and is robust regardless of the absolute source-exec number.

## 8. Measurements (spike, hello-window)

| Build | On-disk | Boot/objects | Cold launch → run loop |
|---|---:|---|---:|
| source-exec (retired) | 104 MB | 838 `.so` + dylib | ~13.9 s |
| **open-world standalone (shipping)** | **4.5 MB** | 3.71 MB boot | **~0.29 s** |
| closed-world standalone (dropped) | 3.5 MB | 2.58 MB boot | ~0.23 s |

## 9. Grown work (node 060 leaves)

- `030` — standalone build pipeline in `bundle-chez` (§2–§5); hello-window builds
  and launches as a self-contained `.app` via `bundle_app`. Source-exec left in
  place temporarily (never without a green path).
- `040` — retire the source-exec path (§6 deletions) + record obsoleted
  follow-ups (§7).
- `050` — convert the full 7-app portfolio to standalone and VM-verify each in a
  no-Chez VM ([[feedback-use-testanyware]], [[feedback-vm-verify-every-app]]); the
  parity bar from the grove root brief. May decompose into per-app leaves when
  picked.
- `060` — toolchain docs (original requirement 2): required Chez kernel
  artifacts, where they come from, the exact build pipeline, the dev-repro
  recipe. Feeds `070-rewrite-adding-language-target`.
</content>
</invoke>
