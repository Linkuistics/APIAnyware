# Chez self-contained-runtime spike — dual-mode standalone `hello-window`

**Grove:** `add-chez-target` · node `060-chez-self-contained-runtime` · leaf
`010-spike-dual-mode-standalone` (the D1 gate).
**Date:** 2026-05-29 · **Host:** macOS 26.x arm64, Chez Scheme 10.4.1 (Homebrew).
**Status:** spike (throwaway code; the deliverable is this evidence).

---

## Verdict: **GO** — native standalone is proven, both modes

A `hello-window` `.app` that **embeds the Chez kernel** launches and **draws its
window on a pristine macOS 26.3 arm64 VM with no Chez installed** — in *both*
build modes:

- **Open-world** (full `scheme` boot embedded): window draws; runtime
  `eval`/`load` and **`foreign-callable`-via-`eval`** all work in the shipped
  binary (the open-world dispatch substrate is viable).
- **Closed-world** (`compile-whole-program`-sealed, `petite` boot, no compiler):
  window draws; `foreign-callable`-via-`eval` is **refused** — which is the
  closed-world contract and the empirical reason the eval-free dispatch backend
  (BRIEF D2) is *required*, not optional.

VM evidence (no Chez present, `which chez scheme petite` → empty,
`/opt/homebrew/bin/chez` absent):

| Mode | Screenshot | Menu-bar name | Banner on stdout |
|---|---|---|---|
| Open-world | `…-evidence/open-world-window.png` | `Hello Window Open` | `Chez Scheme Version 10.4.1` |
| Closed-world | `…-evidence/closed-world-window.png` | `Hello Window Closed` | `Petite Chez Scheme Version 10.4.1` |

The native path is **not refuted**. The bundle-the-runtime-tree fallback is not
needed. `020` may proceed to spec the production `bundle-chez` standalone modes.

---

## Measurements (BRIEF D4 — feeds the source-exec-retirement decision)

`hello-window`, same host, warm file cache, time = process start → the
`"Hello Window opened."` print immediately preceding `(nsapplication-run)`
(measured identically for all three via `spike-scratch/measure.sh`, median of 4).

| Build | On-disk size | Boot/objects | Cold launch → run loop |
|---|---:|---|---:|
| **(a) source-exec** (today: stub execs system chez over 838 precompiled `.so`) | **104 MB** | 838 `.so` + dylib | **~13.9 s** |
| **(b) open-world standalone** (petite+scheme+app boot) | **4.5 MB** | 3.71 MB boot | **~0.29 s** |
| **(c) closed-world standalone** (petite+app boot) | **3.5 MB** | 2.58 MB boot | **~0.23 s** |

- **~23–30× smaller, ~48–60× faster cold launch.** The win is structural: the
  standalone is one pre-linked, pre-instantiated boot image (a single `mmap`),
  versus the source-exec path's load-and-*instantiate* walk over 838 libraries
  (each running its `load-shared-object` probe).
- The 2.58 → 3.71 MB boot delta between closed- and open-world is exactly the
  `scheme.boot` compiler.
- **Measurement caveat (finding F8):** chez.md records the source-exec
  precompiled cold start as ~1.85 s; this spike measured ~13.9 s **to the
  window** on this host (fast `.so` path confirmed: version 10.4.1 match, zero
  `.so-disabled`). The gap is almost certainly *what is being timed* — to
  `[NSApp run]` after instantiating all 838 libraries, vs. an earlier/lighter
  marker. `020` should re-measure both to a common marker before quoting a
  number; the **comparative** conclusion (standalone is ~50× faster) is robust
  regardless.

---

## The build pipeline (exact, reproducible)

All scripts live in `spike-scratch/` (gitignored). Kernel artifacts are the
Homebrew Chez 10.4.1 set under
`/opt/homebrew/Cellar/chezscheme/10.4.1/lib/csv10.4.1/tarm64osx/`:
`petite.boot`, `scheme.boot`, `libkernel.a`, `liblz4.a`, `libz.a`, `scheme.h`
(`main.o` is **not** linked — see F9).

### 1. One whole-program object, shared by both modes (`build_whole.sh`)

```scheme
(generate-wpo-files #t)
(compile-imported-libraries #t)
(library-directories "chez-tree")          ; the apianyware/ + lib/ tree
(compile-program "hw-entry.ss")            ; compiles the whole import closure
(compile-whole-program "hw-entry.wpo" "hw-whole.so" #f)   ; #f = sealed
```

- First pass compiles the closure (incl. the 70k-line AppKit facade):
  **~160 s, ~1.6 GB peak RSS**, one-time.
- `compile-whole-program` then **tree-shakes 139 MB of source closure down to a
  413 KB object** containing only `runtime/{ffi,objc,types,cocoa}` +
  `appkit/{nsview,nsfont,nstextfield,nswindow,enums,nsapplication}`.

### 2. Make the self-contained boot (`link_standalone.sh`)

```scheme
;; open-world: compiler present
(make-boot-file "hw-open.boot"   '() ".../petite.boot" ".../scheme.boot" "hw-whole.so")
;; closed-world: no compiler
(make-boot-file "hw-closed.boot" '() ".../petite.boot"                   "hw-whole.so")
```

The **empty base list** + boot files passed as ordinary inputs is the lever:
it concatenates everything into one boot needing no external registration.

### 3. Link the embedding host (`embed_main.c`, `link_standalone.sh`)

```sh
cc -O2 -I$KERNEL -DBOOTNAME='"hw-open.boot"' -o hw_open embed_main.c \
   $KERNEL/libkernel.a $KERNEL/liblz4.a $KERNEL/libz.a \
   -liconv -lncurses -lz -framework Foundation -framework AppKit
```

`embed_main.c`: `Sscheme_init` → `Sregister_boot_file(<resdir>/BOOTNAME)` →
`Sbuild_heap` → `Sscheme_start` (which invokes the heap's `(scheme-start)`
thunk — the app installs that instead of calling `(main)` at top level).
AppKit/Foundation are pulled at runtime by `load-shared-object` in `ffi.sls`;
linking the frameworks into the host is belt-and-suspenders.

### 4. Assemble + sign the `.app` (`assemble_app.sh`)

`Contents/MacOS/<bin>` + `Contents/Resources/{<boot>,lib/libAPIAnywareChez.dylib}`;
sign nested dylib, then bundle, with `APIAnyware Local Signing`. Result:
`codesign --verify --strict` → `valid on disk` / `satisfies its Designated
Requirement`; **unique CDHash per app** under the persistent identity.

---

## Dynamic-load proof transcript (BRIEF D2 / original requirement 1)

Run with `AW_SPIKE_PROVE=1` (console-only, no window). Verbatim:

```
### OPEN-WORLD ###                         ### CLOSED-WORLD ###
Chez Scheme Version 10.4.1                 Petite Chez Scheme Version 10.4.1
=== DYNAMIC-LOAD PROOF ===                 === DYNAMIC-LOAD PROOF ===
boot kind: Chez Scheme Version 10.4.1      boot kind: Petite Chez Scheme Version 10.4.1
 [eval fresh form … 5050] 5050             [eval fresh form … 5050] 5050
 [load fresh def … (spike-dyn 7)] 49       [load fresh def … (spike-dyn 7)] 49
 [foreign-callable via eval … 41] 42       [foreign-callable via eval … 41]
                                             REFUSED/ERROR: Exception in interpret:
                                             cannot compile foreign-callable:
                                             compiler is not loaded
 [guardian drains after gc] drained        [guardian drains after gc] drained
=== PROOF COMPLETE ===                     === PROOF COMPLETE ===
```

The foreign-callable round-trip mirrors `dispatch.sls`'s real mechanism:
`(eval '(foreign-callable (lambda (x) (+ x 1)) (int) int) (interaction-environment))`
→ `lock-object` → `foreign-callable-entry-point` → call back via a
`foreign-procedure` built from that address → `42`.

---

## Findings & gotchas (these become spec + `chez.md` entries)

**🔴 F1 — Closed-world is "no code generation", not "no `eval`"; that is exactly
why D2's two dispatch backends exist.** A `petite`-boot sealed program still
*interprets* ordinary `eval`/`load` (the proof's steps 1–2 pass). What it
**cannot** do is compile a `foreign-callable` — `"cannot compile
foreign-callable: compiler is not loaded"`. Since the open-world dispatch
substrate (`dispatch.sls`) *is* `eval`-synthesized `foreign-callable` forms
(chez.md 🔴 2026-05-27), it is **physically impossible** in a closed-world boot.
This empirically grounds the requirement-1 amendment (D2): open-world ships the
compiler and keeps today's substrate; closed-world must enumerate trampolines
from static usage. `hello-window` uses no dispatch, so its closed-world build
needs **zero** trampolines (D3 confirmed) — proving the seal-and-link mechanics
without first solving the eval-free backend.

**🔴 F2 — The sample-app entry, as authored for `--script`, is NOT a valid R6RS
top-level program; whole-program compilation forces explicit name
reconciliation.** `load`/`--script` evaluates in the *interaction environment*
(later imports rebind, last-wins — like Racket's `define`). `compile-program` /
`compile-whole-program` enforce strict top-level-program semantics where a name
exported by two imported libraries is a hard duplicate-import error. For
`hello-window`'s import set, **exactly 4** identifiers collide (computed via
`environment-symbols`):

| Identifier | exported by | … and by |
|---|---|---|
| `nserror-code` | `(apianyware foundation)` (NSError ObjC accessor) | `(apianyware runtime objc)` (record accessor) |
| `nserror-domain` | `(apianyware foundation)` | `(apianyware runtime objc)` |
| `reverse` | `(apianyware foundation)` (re-exported enum value) | `(chezscheme)` (the procedure) |
| `nsevent-location-in-window` | `(apianyware appkit)` (NSEvent accessor) | `(apianyware runtime cocoa)` (helper) |

Resolved by having the **framework facades yield** to the curated runtime API
and `(chezscheme)`: `(except (apianyware appkit) nsevent-location-in-window)` and
`(except (apianyware foundation) nserror-code nserror-domain reverse)`. This is a
**general rule for the closed/open-world build**: every app importing a facade +
`runtime/objc` (+ `(chezscheme)`) needs this reconciliation. **`020` decision
needed:** bake the rule into a generated top-level-program wrapper the bundler
emits around the app, or change the app-authoring convention to a proper
top-level program. (British vs American spelling spares
`localised`/`localized` and `userinfo`/`user-info` from colliding — keep that.)

**🟡 F3 — The standalone has no launcher to seed `(library-directories)`, so the
dylib search root must be set from C, before `Sbuild_heap`.** `runtime/ffi.sls`'s
`resolve-dylib-path` probes each `(library-directories)` entry for
`lib/libAPIAnywareChez.dylib`, and it runs **during boot load** (when the
apianyware libraries instantiate) — *before* any Scheme hook the app controls.
The source-exec path relies on the stub passing `--libdirs`; the standalone has
no stub. The embedded kernel's `(library-directories)` defaults to `"."` and
**does not read `CHEZSCHEMELIBDIRS`** (that is the standard executable's
arg-parsing, which a custom host bypasses). Spike fix: `chdir` to the resource
dir in C so `"."` resolves. **`020` should instead link a tiny *prelude* object
into the boot, ahead of the app, that sets `(library-directories)` from an
exe-relative path** — cleaner than `chdir` and keeps the process cwd sane.

**🟡 F4 — `codesign --strict` rejects non-Mach-O files in `Contents/MacOS/`.**
The `.boot` is a data file; placed next to the binary it fails with `code object
is not signed at all … In subcomponent: …/<app>.boot`. Put the boot **and** the
dylib under `Contents/Resources/` (sealed as resources); the host finds them via
`../Resources`. `embed_main.c` probes both layouts (flat run dir, and `.app`
`../Resources`).

**🟢 F5 — Codesigning carries over for free.** Each standalone signs with the
persistent `APIAnyware Local Signing` identity, verifies strict, and gets a
**unique CDHash per app** (distinct binary+resources) — so the
unique-CDHash-per-app + TCC-grant-continuity rationale (BRIEF Context) holds for
standalone binaries unchanged. `hello-window` exercises no TCC-gated resource;
a TCC-resource sample app will confirm grant continuity in its own VM-verify.

**🟢 F6 — The kernel prints a startup banner on stdout.** Harmless inside a
`.app` (no console), useful here as the open/closed tell. Production should
suppress via `(suppress-greeting #t)` / the host before `Sscheme_start`.

**🟢 F7 — Whole-program tree-shaking is dramatic.** 139 MB source closure → a
413 KB object. This is the entire reason the standalone is ~30× smaller than the
source-exec bundle, which ships the *whole* precompiled facade closure.

**🟢 F8 — Re-measure the source-exec baseline to a common marker** before
quoting absolute cold-launch numbers (see Measurements caveat).

**🟢 F9 — Do not link the kernel's `main.o` with a custom host.** `main.o`
defines its own `main()`; with `embed_main.c` that is a duplicate-symbol link
error. Link `libkernel.a` only.

---

## What this obsoletes (confirms BRIEF Notes; `020` records in the spec)

A standalone binary that embeds its own kernel and ships **no system Chez
dependency** evaporates several deferred follow-ups at once:

- **Leaf-160 Chez-version coupling** (`launch.ss` version-stamp + `.so-disabled`
  fallback): no system Chez → no cross-version `.so` mismatch → no `launch.ss`,
  no precompile-version stamp.
- **Menu-bar-name gotcha** (chez.md 🟢 2026-05-26): the menu bar already reads
  the `CFBundleName` (`Hello Window Open` / `Closed`) — there is no `execv` into
  a `chez` process to mislabel it.
- **Golden-image Chez pre-install** (050 brief): unnecessary for a standalone.

The source-exec path stays working until `020` makes the D4 retirement call on
the numbers (never without a green path).

---

## Hand-off to `020-decide-spec-and-grow`

1. Make the **D4 source-exec-retirement** call on re-measured numbers (F8).
2. Spec the `bundle-chez` standalone modes (D5): `AppSpec` build-mode enum
   `SourceExec | StandaloneOpen | StandaloneClosed`; a `standalone.rs` running
   the §"build pipeline" steps; the **prelude-object** dylib-path fix (F3); the
   `Resources/` boot+lib layout (F4); banner suppression (F6).
2. Spec the **top-level-program reconciliation** (F2) — generated wrapper vs.
   authoring-convention change — and the **eval-free closed-world dispatch
   backend** (F1/D2) as its own work leaf, proven on a delegate-using app.
3. Raise the ADRs: standalone build modes; the D2 two-dispatch-backend /
   requirement-1 amendment.
4. Record the obsoleted follow-ups (above) in the spec.

### Repro

`spike-scratch/`: `build_whole.sh` → `link_standalone.sh {open,closed}` →
`assemble_app.sh {open,closed}`; `smoke.sh`/`measure.sh` for local timing;
`embed_main.c` + `hw-entry.ss` are the host + entry. VM: `testanyware vm start
--platform macos`, upload the `.tgz`, `xattr -dr com.apple.quarantine`, `open -n`.
