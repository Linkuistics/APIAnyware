# The Node TypeScript target's `.app`: a native launcher owns `main()` and embeds a vendored Node

A **Node TypeScript** sample app is distributed as a `.app` whose
`CFBundleExecutable` is a **per-app native launcher that owns `main()` and embeds
Node** — the Electron / NativeScript-for-macOS `NSApplicationMain` shape. The launcher
boots a Node environment via the C++ embedder API (V8 isolate + libuv loop, *without*
entering `uv_run(DEFAULT)`), loads the app's JS, then calls `NSApplicationMain()` and
pumps libuv as a guest (ADR-0056 mechanism (c)). A **pinned `libnode.<ver>.dylib`** is
vendored into every bundle alongside the `APIAnywareTypeScript` native core; the Swift
runtime stays OS-resident (macOS ≥ 12). This is the TypeScript-target analogue of chez
**ADR-0009** / sbcl **ADR-0041**, realized by a new `bundle-typescript` crate. It applies
**ADR-0010** (the native library *is* the binding) and **ADR-0011** (per-target hermetic
bundling); it is scoped to the **Node** target (**ADR-0054** §"target scope") — the JSC
target's `~0 MB` distribution is a separate future grove.

## Context — the stub-`execv`-runtime model does not apply here

The four Lisp targets distribute through `stub-launcher`: a tiny per-app Swift stub becomes
`CFBundleExecutable`, carries a unique CDHash for macOS TCC, and `execv`s a **shared** system
runtime (`/opt/homebrew/bin/racket`, or a `save-lisp-and-die` image). The stub indirection
exists **only because the runtime binary is byte-identical across apps** and so cannot carry
per-app identity.

That model is structurally wrong for the Node target, for a reason established first-hand by
the k6 runloop-integration spike and recorded in **ADR-0056**: **the native side must own
`main()` with no ambient blocking JS→native call while pumping.** A `node app.js` (or a Node
SEA) keeps `node` owning `main()`, so the only way to reach the Cocoa loop is a blocking
JS→native `run()` call — which leaves a JS frame on the stack while pumping, whereupon V8
suppresses the microtask checkpoint and the nested `uv_run` corrupts the loop
(`pump_shim.cc`, k6 FINDINGS). The pump also *requires* the node/V8 embedding primitives
(`HandleScope`, `Context::Scope`), which exist only when the native core links the embedder
API. So embedding Node in a native `main()` is not a distribution choice — it is forced by the
runtime design; Q7 only settles how that embedding is packaged, signed, and made
self-contained.

This **refutes research D8's own suggestion** (Node SEA / prebuilt-`.node` in a `.app`): the
research predates k6, and SEA is incompatible with the settled pump architecture.

## Decision

### 1. A per-app native launcher owns `main()` and embeds Node

`CFBundleExecutable` is a native binary, generated and compiled per app by `bundle-typescript`.
Its per-app `main` is **thin** — it bakes the app name, bundle identifier, and the
Resources-relative JS entry path as string literals — and links a **shared prebuilt embedder
core** (`CommonEnvironmentSetup::Create` + `LoadEnvironment` + the `aw_rl_pump_v8` pump, in the
`APIAnywareTypeScript` native core) plus the vendored `libnode`. At launch it creates the Node
environment but does **not** call `SpinEventLoop`/`uv_run(DEFAULT)`; it hands control to
`NSApplicationMain()`, and the libuv loop is pumped as a guest from a `kCFRunLoopCommonModes`
source (ADR-0056). The distribution shape is therefore **structurally unlike all four Lisp
targets** — no stub, no `execv`.

### 2. A pinned `libnode.<ver>.dylib` is vendored; distribution is coupled to one Node major

Every bundle vendors a `libnode.<NODE_MODULE_VERSION>.dylib` (built `./configure --shared`).
The app does **not** float on a system `node` (Homebrew's is not `--shared`, and no system
version is guaranteed). Two forces make this a *pinned matched pair* — launcher + libnode built
against the same `node.h`/`v8.h`:

- **Self-containment** (chez ADR-0009): a `.app` is a double-clickable, dependency-free
  artifact; it carries its Node.
- **The Node C++ embedder API is not ABI-stable.** Its documentation states breaking changes
  "do not follow typical Node.js deprecation policy and may occur on each semver-major release
  without prior warning" (nodejs.org/api/embedding.html). So the vendored `libnode` *must*
  match the headers the launcher was compiled against.

**The trade-off, stated plainly:** the target's *dispatch* substrate is ABI-stable across
Node/Deno/Bun (N-API, ADR-0054 §4), but its *distribution* is pinned to **one** `libnode`
build. The engine-agnostic hedge protects the dispatch layer, not the shipped app — a future
reader should not expect a bundled app to run on an arbitrary system Node.

The self-containment invariant widens by exactly one over sbcl ADR-0038 §6: `libnode` is an
**additional vendored non-system dependency** (Node is not OS-resident), while the Swift
runtime stays OS-resident. Accepted cost: **bundle weight** — originally estimated ~50–90 MB,
V8-dominated (the Electron tax); `bundle-typescript-k126` measured hello-window's actual bundle
at **132 MB**, the gap being this Homebrew `node@26` build's wide dynamic Homebrew closure (§5)
rather than `libnode` alone. Shrinking the vendored `libnode` (small-ICU, `--without-inspector`,
a stripped, more-statically-linked build) is a **future-optimization** concern, not a blocker (as
chez deferred closed-world).

### 3. Per-app TCC identity: the launcher carries its own CDHash — no stub

Because the launcher is bespoke and per-app-compiled, its baked-in per-app strings make its
bytes unique, giving it a **unique CDHash** directly — the exact property `stub-launcher`
engineers, without the stub or the `execv`. macOS TCC (camera/mic/automation) keys on that
per-app identity. The hard constraint honoured: a byte-identical launcher shipped in every
`.app` would share a CDHash and collide in TCC; per-app baked strings prevent that for free.
`bundle-typescript` **reuses** `stub-launcher`'s `codesign_path` helper (like every peer bundler)
but **not** its stub-source/`execv` path or its `generate_info_plist` (which bakes stub-specific
concepts — a `runtime_path`, a script resource dir — that don't apply here; `bundle-typescript`
writes its own `Info.plist`, the same shape every self-contained-binary peer bundler already does).
CDHash stabilization across rebuilds (so TCC grants survive) uses an explicit `signing_identity`;
ad-hoc signing serves the dev loop.

### 4. Bundle layout; JS shipped as loose ES modules; the `.d.ts` is not shipped

```text
<App>.app/Contents/
  MacOS/<App>                        <- per-app native launcher (CFBundleExecutable, unique CDHash;
                                         embeds the shared pump.swift/pump_shim.cc embedder core
                                         directly, per-app-compiled, same as every sample app's dev
                                         launcher — bundle-typescript-k126 kept this split rather
                                         than folding it into the addon below)
  Frameworks/
    libnode.<ver>.dylib              <- vendored embedded Node (+ its own further Homebrew
                                         dylib closure on this build — §5)
    APIAnywareTypeScript.node        <- vendored native addon (generated N-API dispatch; kept its
                                         `.node` extension — `require()`'s module loader dispatches
                                         on it, unlike an ordinary linked dylib found via `otool -L`)
  Resources/app/<js tree>            <- emitted app entry + generated per-framework .mjs modules
  Info.plist
```

The app's JavaScript ships as a **loose `.mjs` tree** under `Resources/app/`; the launcher's
`LoadEnvironment` targets the entry and Node's ESM loader resolves the rest. This adds **no
JS-bundler (esbuild/rollup) dependency** to the crate and stays walk-away-legible (the `.app`
can be opened and read), preserving the emitter's per-framework module structure (ADR-0055). A
JS bundler / V8 snapshot is a **future size/launch optimization**, not required here. The
**`.d.ts` is a dev-time deliverable** (type-checking app TS *before* emit) and is **not** in the
runnable bundle. The seven sample apps carry **no `node_modules`** (self-contained against the
generated runtime); vendoring a real app's npm deps is a deferred concern the samples do not
exercise. **Settled by `bundle-typescript-k126`**: the native addon is vendored as a `.node` file in
`Frameworks/` (its own extension kept, not renamed to `.dylib` — `require()`'s module loader
dispatches on it); the shared `pump.swift`/`pump_shim.cc` embedder core stays compiled directly
into the per-app launcher (§4's own diagram), not folded into the addon — the layout the four
options below all anticipated supports this split cleanly.

### 5. Vendor-and-relocate (not runtime relocation); sign inside-out; record the JIT entitlement

- **Relocation is the peer targets' `install_name_tool` / `@executable_path` path** (gerbil
  ADR-0029 §3, chez ADR-0009), **not** sbcl's runtime relocation. sbcl was *forced* into runtime
  relocation (ADR-0041) by an un-editable `save-lisp-and-die` image (Lisp core past
  `__LINKEDIT`); the launcher here is an **ordinary Mach-O**, so Mach-O surgery works. Every
  vendored dylib's install-name and every referencing load command (in the launcher and in the
  other vendored dylibs) → `@executable_path/../Frameworks/<leaf>` — the gerbil/chez precedent's
  own concrete form (no separate `LC_RPATH` entry is needed alongside it).
  **`bundle-typescript-k126` measured this Homebrew `node@26` build directly and found this
  decision's original "minimal transitive vendoring" premise false**: `libnode` dynamically links ~20 further
  Homebrew dylibs (ICU, brotli, c-ares, nghttp2/3/ngtcp2, sqlite, openssl, zstd, llhttp, ada-url,
  simdjson, …), two of them (`libicudata`, `libbrotlicommon`) reachable only via
  `@loader_path`/`@rpath` rather than an absolute path — invisible to a naive absolute-path-only
  `otool -L` scan. The mechanism this decision commits to (vendor-and-relocate via
  `install_name_tool`) is unaffected — it already generalizes to a wider closure and to
  `@loader_path`/`@rpath`-relative same-closure references, which is exactly what
  `bundle-typescript`'s `relocate.rs` walks — only the *size* of what gets vendored differs from
  what was assumed here. (A statically-linked, small-ICU/no-inspector `libnode` build, mentioned
  below as a bundle-weight optimization, would restore something closer to the original premise;
  it is not what this Homebrew build ships.)
- **Codesigning is sign-inside-out** (each vendored dylib, then the whole bundle), reusing
  `codesign_path` — simpler than sbcl's "sign around, never re-sign the image" rule (which came
  from the un-editable image; there is none here).
- **The V8 JIT entitlement is recorded even though the samples do not exercise it.** Any
  hardened-runtime / notarized bundle **must** carry `com.apple.security.cs.allow-jit` — V8 maps
  executable memory for JIT, and Electron ships exactly this by default
  (`@electron/osx-sign` `default.darwin.plist`). The **dev / VM-verified sample loop uses ad-hoc
  signing without a hardened runtime**, so it does not need the entitlement; recording it here
  stops a future distributable build from rediscovering it at notarization. This is a
  distribution concern **no Lisp target has** — none JIT under a hardened runtime.

## Considered options

- **Node SEA / `node app.js` in a `.app` (research D8's suggestion).** *Refuted by ADR-0056* —
  both keep `node` owning `main()`, forcing the blocking JS→native call that corrupts the pump.
- **A stub that `execv`s a shared launcher.** Reintroduces exec indirection to buy nothing: the
  thin per-app `main` already compiles in well under a second and yields the unique CDHash
  directly. The stub earns its place only when the runtime binary is shared (the Lisp four); it
  does not here.
- **Depend on a system-installed Node.** Breaks self-containment *and* the version-pinning the
  non-ABI-stable embedder API requires. Rejected.
- **Bundle the JS to a single file (or V8 snapshot) now.** Front-loads a JS-toolchain dependency
  for a launch-speed benefit the embedder/pump cost dominates, and fights the emitter's
  per-module structure. Deferred as an optimization.
- **Copy sbcl's runtime relocation for uniformity.** Strictly more complex for zero benefit when
  the Mach-O is editable. Rejected.

## Consequences

- **A new crate `bundle-typescript`** (peer to `bundle-sbcl`/`bundle-chez`/`bundle-gerbil`):
  generate + compile the per-app launcher, vendor `libnode` + the native core, lay out the JS
  tree, generate `Info.plist`, relocate via `@executable_path`, and sign inside-out. Scoped here;
  grown as a build leaf after the design tree retires (delivered `bundle-typescript-k126`, for
  hello-window; the remaining six sample apps are a follow-on leaf).
- **Hard to reverse:** native-owns-`main()`, the vendored-`libnode` matched pair, the
  per-app-launcher-as-`CFBundleExecutable` layout, and the one-Node-major coupling are baked into
  the launcher, every sample app, and the bundler.
- **Distribution is pinned to one Node major** even though dispatch is engine-agnostic — the two
  layers have different portability stories, by design.
- **Future distributable/notarized builds need `com.apple.security.cs.allow-jit`** and a hardened
  runtime; the sample loop does not.
- Applies **ADR-0010** economics, target-local under **ADR-0011**, atop the **ADR-0054**
  substrate and the **ADR-0056** runloop polarity.

See `CONTEXT.md` (*`bundle-typescript` / typescript distribution*), ADR-0054 (the substrate +
target-scope this builds on), ADR-0056 (the native-owns-`main()` finding that forces the
launcher shape), ADR-0055 (the emitter output this ships), ADR-0009/0041 (the peer
self-containment precedents), and ADR-0010/0011 (the north star + isolation).
