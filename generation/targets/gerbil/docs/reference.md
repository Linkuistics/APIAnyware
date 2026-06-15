# gerbil — Target Reference

First-pass, written-after-the-fact learnings for the `gerbil` generation target,
captured at the close of the `add-gerbil-scheme-target` grove (2026-06). Like
`chez.md` it is deliberately shorter than `racket.md`: where the targets agree
(pipeline, IR, framework set, sample-app portfolio, TestAnyware bar) read the
racket reference; where the two Schemes agree (idiom posture, `(values result
error)`, entry-point pools, self-contained `.app`s) read the chez reference.
This file covers only what is *gerbil-specific* and was *surprising in
practice*. Per `knowledge/README.md`, gotcha entries carry a date and a
🔴/🟡/🟢 priority.

Companion design + decisions:

- Design spec: `docs/specs/2026-06-03-gerbil-target-design.md` (§4 and §7
  carry inline corrections — read the ADRs below as the live state).
- ADR-0017 — generated per-signature `define-c-lambda` dispatch; native core
  compiled by gsc into the exe, **no Swift dylib**.
- ADR-0019 — lifetime = Gambit wills + entry-point autoreleasepool.
- ADR-0020 — manifest ObjC class hierarchy, dual dispatch surface, transparent
  extensible subclassing (supersedes ADR-0018's single-handle veneer).
- ADR-0021 — the emitter synthesizes C declarations; it never `#include`s a
  framework umbrella header (everything compiles under the default gcc-15).
- ADR-0022 — background callbacks bounce to the main thread (no chez-style
  thread activation; the 080 spike proved it structurally unavailable).
- ADR-0023 — the shared `generics.ss` is sharded and compiled without `-O`,
  in parallel (cold build ~5 h → 8.4 min).
- Error model: `(values result error)` — chez ADR-0006 applied verbatim, no
  separate gerbil ADR (design spec § error model).

## 1. Reader's mental model

Gerbil is the third Scheme target and the **paradigm experiment**: racket binds
through dynamic `tell`, chez through plain procedures, gerbil through a **real
class hierarchy with generic functions**. It is a **compiled-FFI target**
(Gerbil → Gambit → C → native exe, like chez and unlike interpreted-FFI racket
— the distinction ADR-0015/0017 turn on), pinned to **Gerbil v0.18.2** on the
vendored Gambit v4.9.7 (one pin: since v0.18 Gambit is a git submodule of
Gerbil, not an external dependency).

Three structural commitments distinguish it from chez:

1. **Manifest class hierarchy (ADR-0020).** The full ObjC class graph is
   reified as Gerbil `defclass`es — `NSButton : NSControl : NSView :
   NSResponder : NSObject` — including intermediate classes we bind no methods
   of. The runtime owns the root `NSObject` (the `ptr` slot + the lifetime
   will); each class is defined once by its owning framework's module, and
   cross-framework ancestry is a cross-module import. A returned `id` is
   `wrap`ped to its **exact bound type** (`object_getClass` → the
   `register-objc-class!` registry, walking the ObjC superclass chain to the
   nearest bound ancestor for unbound dynamic classes like `__NSCFString`).
2. **Dual dispatch surface over one proc core (ADR-0020).** Every bound
   instance method is callable three ways: `(nsstring-length s)` (proc core,
   16.3 ns — the fast path, `(declare (inline))`), `{str-length s}` (built-in
   `{}` MOP, 42.8 ns), and `(str-length s)` (`:std/generic`, 29.4 ns). Both
   surfaces forward to the proc core, which bottoms out in the per-signature
   `%msg-…` `define-c-lambda` crossing (raw `objc_msgSend` cast, ~11 ns).
   Generics are the natural *consumption* surface; OO the natural *extension*
   surface; hot loops drop to the proc core. Class methods stay proc-only.
3. **Transparent extensible subclassing (ADR-0020) — *deriving in Gerbil =
   deriving in ObjC*.** `:gerbil-bindings/runtime/subclass` re-exports
   shadowing `defclass`/`defmethod`/`new`: `(defclass (CanvasView NSView)
   (strokes))` synthesizes a real ObjC subclass (`objc_allocateClassPair` +
   IMP trampolines), so AppKit dispatches `drawRect:` into the user's Gerbil
   method with a typed `self`. Imported only by app code that subclasses —
   generated bindings use the built-in `defclass`.

The runtime is five Gerbil modules + one C companion under
`generation/targets/gerbil/lib/runtime/` — `ffi.ss` (C-safe libobjc seam),
`objc.ss` (class-graph root, registry, wrap, wills, pools, nserror, the
delegate/block bridges), `native-core.ss` (the `c-define` trampolines +
class-pair plumbing), `subclass.ss`, `cocoa.ss` (geometry constructors +
standard app menu), and `native_block.c` (the clang `-fblocks` companion). The
module table, bridge specs, and build recipe live in
`generation/targets/gerbil/lib/runtime/README.md` — read it before touching the
runtime. **There is no `libAPIAnywareGerbil.dylib`** (ADR-0017): the native
core is compiled by gsc into every executable.

## 2. Toolchain provisioning (the bottle)

`brew install gerbil-scheme` → 0.18.2 bottled. Two real obstacles, both
resolved without a source build (2026-06-03 spike FINDINGS §0):

🔴 **2026-06-03 — `gsc` name collision with ghostscript.** Both formulae ship a
`gsc`; Homebrew refuses to link gerbil while ghostscript owns the symlink.
Resolution: keep gerbil **unlinked** and drive it from the Cellar bin
(`/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin`) on PATH.

🔴 **2026-06-03 — the unlinked bottle's split Gambit prefix breaks `~~`
resolution.** `gxc` expects Gambit's `gsc`/`gambuild-C`/`include/` under
`…/0.18.2/v0.18.2/…` but the bottle puts `bin`/`include` one level up, so
builds die with `~~include`/`gambuild-C` "No such file or directory". Three
Cellar-local symlinks fix it (contained to the keg, reversible):

```sh
P=/opt/homebrew/Cellar/gerbil-scheme/0.18.2 ; V=$P/v0.18.2
mkdir -p "$V/bin"
for f in "$P"/bin/*; do ln -sf "../../bin/$(basename "$f")" "$V/bin/"; done
ln -sfn ../include "$V/include"
```

The build env that works (runtime README "Building"):

```sh
export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
unset GERBIL_HOME            # let gerbil self-locate to …/v0.18.2
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
```

🔴 **2026-06-03 — stale-lockfile hang.** A killed `gxc` leaves a zero-byte
`~/.gerbil/lib/static/<mod>.o.lock`; the next `gxc` blocks on it **forever**
(low CPU, growing elapsed). Clear `~/.gerbil/lib/static/<mod>*` before
retrying. If a build "hangs" with no compiler process burning CPU, this is why.

🟡 **2026-06-08 (070/020) — ONE toolchain: the bottle does everything. The
static source toolchain is retired.** The 020 spike (FINDINGS §5) concluded a
`--enable-shared=no` source build was needed for a runtime-embedded exe, and
§3b added the rule "measure on the bottle, distribute on the static build"
because the static prelude's `-O` Scheme codegen ran **~10× slower** (proc
16→83 ns, `{}` 43→476 ns; FFI path unchanged). Leaf 070/020 corrected the
premise: `gxc -exe` links `libgambit.a` **by default**, and the
`--enable-shared` bottle ships that `.a` too — so the bottle already produces a
self-contained, runtime-embedded exe (`otool -L` shows no libgambit/libgerbil;
a trivial exe runs under `env -i`). The bottle wins on *both* speed and
self-containment; `~/.local/gerbil-0.18.2-static` and its 80-min build are
unused. The surviving lesson: gerbil toolchains are **not interchangeable for
performance measurement** — never benchmark Scheme paths on a from-source
non-single-host build.

## 3. FFI — plain C under gcc-15, one clang companion (ADR-0021)

`gsc` compiles `define-c-lambda` bodies as **C**, with the bottle configured
`CC=gcc-15`. gcc-15 cannot parse Objective-C — `#include
<Foundation/Foundation.h>` dies on `stray '@'`. The target's answer is **not**
`-cc clang` or `-x objective-c` (both rejected — a runtime `-cc clang` on the
gcc-built bottle breaks the `-dynamic` loadable link with a spurious
`_main` error); it is to keep every emitted module **plain-C-safe**:

- **Dispatch needs no headers.** The emitter open-codes one typed
  `define-c-lambda` per distinct method ABI signature with an **inline-cast
  `objc_msgSend`** body — `((id (*)(id, SEL, const char*))objc_msgSend)(…)` —
  since arm64 forbids calling variadic msgSend directly. This is the
  compiled-FFI analogue of chez's per-signature `foreign-procedure`
  (ADR-0015/0017). Cast `const` returns through `___CAST(char*, …)`.
- **Named C symbols get synthesized declarations.** `constants.ss` /
  `functions.ss` name C symbols, and Gambit emits real C that must see a
  *declaration* (chez's dlsym-style `foreign-entry` has no analogue). The
  emitter synthesizes an `extern` / prototype per symbol, spelling ObjC
  pointer types as `void *` — never an umbrella `#include`. The token→C-type
  table and per-flavour shapes are in ADR-0021.
- **Geometry crosses by value.** `(c-define-type CGRect (struct "CGRect"))` +
  by-value args/returns (arm64 ≤16 B in registers, larger via x8 — proven,
  spike FINDINGS §4). CoreGraphics headers are C-safe and get `#include`d;
  the four NS-prefixed/affine structs' headers are not, so the emitter
  declares **inline plain-C tagged typedefs** (`CGFloat`→`double`) with
  SDK-exact layouts, round-tripped in `tests/smoke-geometry.ss`.
- **The ONE non-default compile** in the whole target is the ObjC
  block-literal companion: `clang -fblocks -c runtime/native_block.c`. Its
  `.o` joins every link line (runtime modules and app exes), alongside
  `-lobjc` and the touched `-framework`s.

🔴 **2026-06-09 (100/050) — never name an ObjC type in a crossing cast.** The
first imported `NSError**`-out method (`sceneWithURL:options:error:`) emitted
`NSError**` inside the msgSend cast; with no Foundation header in scope,
`gxc -O` fails with `unknown type name 'NSError'`. The emitter spells it
`id*` (ABI-identical, always in scope via `<objc/*>`). Same trap applies to
any hand-written `begin-ffi` shim in app code.

🔴 **2026-06-08 (100/030) — NSString crossings must be `UTF-8-string`, not
`char-string`.** Gambit's `char-string` token is ISO-8859-1; a non-ASCII
character (the `…` in a "Color…" button title) crashed the process. All
runtime `string->nsstring`/`nsstring->string` crossings use `UTF-8-string`.
**Caught only by VM-verify** — the build was clean.

## 4. Lifetime — wills + entry-point pool (ADR-0019)

The chez two-mechanism model (ADR-0007) transposed to Gambit: `wrap` registers
a Gambit **will** (`make-will testator action`) that sends `objc_release` when
the wrapper is collected; the app `main` and every callback trampoline wrap
their body in an autoreleasepool (`with-autorelease-pool` /
`define-entry-point`, via the C `objc_autoreleasePoolPush/Pop` — not
`@autoreleasepool`, which gcc-15 can't parse). Differences from chez worth
knowing:

- **Wills self-execute at GC** — there is no guardian drain to run at pool
  boundaries; `with-autorelease-pool` manages only the `+0` pool. The
  per-instance-finalizer release-ordering objection that pushed chez to a
  guardian is benign here (release order among independently-retained objects
  doesn't matter), so gerbil gets racket-style finalization with chez-style
  pools.
- **Off-run-loop loops must wrap themselves** in `(with-autorelease-pool …)` —
  the same rule Cocoa imposes on ObjC command-line tools, same as chez.

🔴 **2026-06-09 (100/070, the most important fix of the sample-app run) —
delegates must be pinned against Gambit GC, not just lexically held.**
AppKit and NSNotificationCenter hold delegates **weakly**. Under note-editor's
per-keystroke allocation pressure, Gambit GC reaped `make-delegate` wrappers
that were still installed: their release-wills fired, the ObjC delegate
instances deallocated, and every callback silently died (preview frozen,
buttons dead). The runtime now pins every `make-delegate` instance in a
process-global `*delegate-roots*` table (the same strong-table discipline
`subclass.ss` uses for synthesized instances). Earlier apps were equally
fragile — just never allocation-heavy enough to trip it. The chez "keep
delegates reachable via `letrec*` in main" advice is **insufficient** here;
the runtime owns the pin.

## 5. Error model — `(values result error)` (chez ADR-0006, applied)

Identical convention to chez: every emitted procedure with a trailing
`NSError**` returns two values — the result, and `#f` or an `nserror`
defstruct (`call-with-nserror-out` in `runtime/objc.ss` builds the out-cell).
In-band, no raise; callers use `let-values`.

🟡 **2026-06-09 (100/060) — generated `foundation/nserror` accessors collide
with the runtime defstruct's.** The generated module exports
`nserror-code`/`nserror-domain` (ObjC properties); `runtime/objc`'s `nserror`
defstruct exports the same names. An app importing both selects with
`(only-in :gerbil-bindings/foundation/nserror nserror-localized-description)`.
The chez target has the same collision solved emitter-side with `(except …)`;
gerbil currently leaves it to the app — remember `only-in`.

## 6. Threading — main-thread bounce (ADR-0022)

The biggest chez→gerbil divergence. The bottle's Gambit is a **single-VM,
single-threaded-VMs, green-thread** build (`___MAX_PROCESSORS 1`): the
processor state is a process-global, so every OS thread shares one heap and
one allocation pointer. The 080 spike
(`docs/research/2026-06-08-gerbil-threading-spike/FINDINGS.md`) measured:

- **Serialized** foreign entry (worker enters Scheme while main is blocked)
  *survives* — a **false positive**: a sample app that happens to await its
  background work passes casual testing, then corrupts the moment a callback
  truly overlaps the run loop.
- **Concurrent** foreign entry crashed **30/30 runs** (SIGSEGV / heap
  overflow).
- There is **no `Sactivate_thread` analogue** — nothing per-thread exists to
  activate. Chez's ADR-0016 activation model is structurally unavailable.

So gerbil adopts racket's model (ADR-0014), not chez's: a foreign OS thread
**never re-enters Scheme directly**. The clang companion owns an outer
trampoline that checks `[NSThread isMainThread]` and, when off-main, hops to
the main queue before calling the gcc-15-compiled inner dispatcher —
`dispatch_sync` for value-returning IMPs/blocks (the framework needs the
result), `dispatch_async` for void completions (also immune to the
sync-while-main-blocked deadlock). On the main thread (the run-loop common
case) it calls straight in: zero overhead for ordinary UI callbacks.

Consequences for app authors: the bounce drains only when the main thread
services the main queue — true under `[NSApp run]`, but long synchronous work
on the main thread starves background callbacks; and a value-returning
callback whose result the main thread is itself blocked on would deadlock
(racket's bounce carries the same caveat). No per-thread pools or
guardian-mutex machinery exists because none is needed — Scheme only ever
runs on the main thread.

## 7. Precompilation & build cost (ADR-0017, ADR-0023)

The compile-time story is what re-routed the whole dispatch design, so it gets
its own section.

- **Bindings compile once; apps reuse.** `gxc` compiles a module to
  `.ssi` + `.o1`; importing apps do **not** recompile it (verified: the
  library `.o1` mtime is untouched across an app build). Per-method emission
  cost (~13 ms/method for `define-c-lambda`) is therefore a
  **binding-regeneration-loop** cost (~70 s for a ~5k-method binding), not a
  per-app tax — the finding that falsified the 020 spike's "go fat-native"
  headline (ADR-0017).
- **`gxc -exe` does NOT recursively compile imports.** The bundler pre-compiles
  the app's full import closure with `gxc -O` into a persistent `GERBIL_PATH`
  cache, then links. Hand-building an app without pre-compiling its closure
  fails confusingly.

🔴 **2026-06-08 (090, ADR-0023) — the shared generics module made cold builds
take ~5 hours; sharding + no-`-O` + parallelism fixed it (8.4 min).** Every
distinct instance-surface selector is declared exactly once in a shared
generics package (6,5xx `defgeneric`s for Foundation+AppKit), and every class
module imports it — so even hello-window pulls it into a cold compile. As one
module it macro-expanded to a 60 MB `.scm` / 94 MB `.c`; both `gsc -target C`
and `gcc -O1` are **superlinear in translation-unit size** (hours each, 9.7 GB
RSS). No-`-O` alone was insufficient — `gsc` itself chokes on raw size. The
durable fix (emitter `emit_generics.rs`, `GENERICS_SHARD_SIZE = 256`):
`generics/NNN.ss` shards behind a re-exporting `generics.ss` facade, compiled
**without `-O`** (the module is pure declarations — nothing to optimize) and
**in parallel** (one `gxc` per shard). Cold hello-window: 8.4 min, under the
15-min/app budget. The shipped `.app` is unaffected.

🟡 **2026-06-08/09 (100/030, 100/040) — the `gxc -O` closure pass needs the
`-framework` flags too, not just the `-exe` link.** Any module that names a C
symbol directly (a `functions.ss` CG call, a `constants.ss` `extern` like
`PDFViewPageChangedNotification`) makes the pre-compile *loadable link* need
the framework. `bundle-gerbil` passes the touched frameworks on both passes.

🟡 **2026-06-08 (100/030) — cold-cache parallel shard compiles race.**
`bundle-gerbil` warms the first shard serially before fanning out.

## 8. Self-contained distribution (`bundle-gerbil`)

A gerbil `.app` is a self-contained native binary built **entirely on the
bottle toolchain** (spec §7 as corrected at 070/020): `gxc -exe` links
`libgambit.a` statically, so the binary embeds the whole Gerbil/Gambit runtime
and launches on a machine with **no Gerbil installed**. Realises ADR-0009 on
gerbil's terms; markedly **simpler than bundle-chez** — no boot image, no
kernel embed, no whole-program compile, no collision probe.

- **`-static` (fully static) is unsupported on macOS** (`ld: crt0.o not
  found` — Apple won't statically link libSystem). Not needed.
- **The only self-containment gap is openssl@3.** The Gerbil stdlib links
  Homebrew's `libssl`/`libcrypto`; `bundle-gerbil` vendors them into
  `Contents/Frameworks/` and rewrites every Homebrew load command to
  `@executable_path/../Frameworks/<name>` via `install_name_tool` — including
  the **exe's and inter-dylib** `-change` commands, not just each dylib's
  `-id`. After relocation `otool -L` shows no Homebrew path.
- Pipeline per app (`bundle-gerbil/src/lib.rs`): walk the `(import …)`
  closure → clang the block companion → `gxc -O` the closure into the cache →
  `gxc -exe -O` link → assemble `.app` + `Info.plist`
  (`com.linkuistics.*` bundle id, display name from the app spec H1) →
  relocate dylibs → codesign (dylibs first, then the bundle).

```text
<App>.app/Contents/
  MacOS/<App>            ← gxc -exe binary (embeds the Gambit runtime)
  Info.plist             ← CFBundleName = "<App>"
  Frameworks/
    libssl.3.dylib       ← vendored + relocated to @executable_path
    libcrypto.3.dylib
```

Dev-repro for one app:

```sh
cargo run --release --example bundle_app -p apianyware-macos-bundle-gerbil -- <script-name>
# → generation/targets/gerbil/apps/<script>/build/<App Name>.app
```

Apps weigh ~73 MB (the embedded Gambit runtime + stdlib dominates — contrast
chez's ~4.5 MB whole-program-tree-shaken boot). Cold bundle build ≈ 8.4 min
(§7); warm rebuilds are fast.

## 9. Known gaps (as of grove close, 2026-06-10)

- ✅ **Protocol-method flattening** (grove leaf 120, CLOSED 2026-06-10): the
  emitter now flattens conformed-protocol instance methods/properties onto
  each bound class — `SCNNode.runAction:` (SCNActionable) and
  `SCNView.autoenablesDefaultLighting` (SCNSceneRenderer) come straight from
  the generated bindings, and scenekit-viewer's app-local raw-`objc_msgSend`
  shim is gone. Gerbil-specific shape (unlike chez/racket's wholesale
  `all_methods`): only the class's **own** conformance closure is flattened
  (`Class.protocols` closed over protocol `inherits` via the cross-framework
  `ProtocolRegistry`, the `ClassRegistry` analogue) — ancestor conformances
  ride the manifest `defclass` hierarchy; protocols unknown to the loaded set
  are skipped (their `all_methods` entries are wrong-arity stubs); the
  `NSObject` protocol is excluded (name-collides with the root class); a
  protocol `initWithCoder:` never suppresses the synthesized `make-<cls>`
  (default-ctor check is own-inits-only). Protocol *properties* need no
  separate path — their accessors arrive as protocol methods. ~5.1k methods
  added across the 6 frameworks (+37 generics shards, was 26).
- 🟡 **Generic-trampoline marshalling limits** (runtime README): IMP/block
  callbacks cannot deliver `float`/`double` or by-value struct args (the
  bridge raises on those tokens; `drawRect:`'s override is `(self)` — draw
  whole bounds); IMP arity caps at 4 method args, blocks at 3; struct/FP
  override *returns* unsupported. Argument-passing super-sends deferred.
- 🟢 Synthesized-subclass instances and delegates are pinned for the process
  (no `dealloc`-driven reclaim yet) — fine for the few app-lifetime
  views/controllers the portfolio needed.

## 10. Verification

Same bar as chez (`chez.md` §7): CLI smoke proves linking and import
resolution, **never** that the GUI works. Every sample app was VM-verified as
a self-contained `.app` in a **no-Gerbil VM** via TestAnyware (no
provisioning needed — the runtime is embedded); reports + screenshots under
`generation/targets/gerbil/test-results/<app>/`, per-app notes under
`knowledge/matrix/<app>/gerbil.md`. Defects invisible to CLI smoke that only
the VM caught: the `char-string` UTF-8 crash (§3) and the weak-delegate GC
reaping (§4) — the latter needed *sustained interaction* (typing) to trip,
which is exactly what the VM-verify bar exists to exercise.

## 11. When does each target shine?

Extends `chez.md` §8 (racket = batteries + finalizers; chez = tight
transparent bridge + tiny fast-launch binary):

- **gerbil** — the native-OO experience: a real class hierarchy matching
  Apple's docs, generic-function *and* `{}` method-call surfaces, and
  first-class subclassing where `(defclass (MyView NSView) …)` IS an ObjC
  subclass AppKit dispatches into. Compiled-FFI performance (≈11 ns raw
  crossing; 16 ns proc core) with an explicit fast-path ladder when dispatch
  cost matters. Ships as a self-contained static-runtime binary with a far
  simpler bundler than chez. Costs: a heavier `.app` (~73 MB vs chez's
  ~4.5 MB), background callbacks serialized through the main thread
  (green-thread Gambit), few batteries (hand-rolled parsing, like chez), and
  a binding-regeneration loop measured in minutes (mitigated by ADR-0023
  sharding). Best when you want bindings that *feel like Cocoa* — subclass,
  override, dispatch — in a Scheme.
