# sbcl `.app` self-containment: `dlopen` namestring relocation + `DYLD_FALLBACK`, not `install_name_tool`

The **sbcl** target's `bundle-sbcl` achieves `.app` self-containment at **runtime**, not
by rewriting Mach-O load commands: `install_name_tool` and the peer targets'
vendor-and-relocate path (`bundle-gerbil`'s `relocate.rs`, gerbil ADR-0029 §3 / chez
ADR-0009) are **impossible** on an SBCL target, because a `save-lisp-and-die` image cannot
be edited (§Context). ADR-0038 §6 owns the self-containment *principle* (the dylib is the
only new non-system dependency); this ADR owns the *relocation mechanism*. Governed by
ADR-0010 (the native library *is* the binding), ADR-0011 (per-target hermetic bundling),
and composes ADR-0034 §6 / ADR-0038 §5 (the `save-lisp-and-die` startup re-resolution
split). It is realized in `bundle-sbcl`.

## Context — a dumped image cannot be edited or `install_name_tool`'d

`save-lisp-and-die :executable t` produces the app artifact by **appending the Lisp
core after the runtime executable's `__LINKEDIT` segment**. That layout breaks every
post-dump Mach-O edit the peer bundlers rely on (per
`apps/hello-window/learnings.md`):

- `install_name_tool` refuses it — *"the `__LINKEDIT` segment does not cover the end
  of the file"*. So **no load command can be rewritten** after the dump.
- `codesign --force` rejects the same layout under strict validation — but SBCL
  **already ad-hoc signs** the dumped exe on arm64 (so it launches), and that
  signature **must be left intact**.

What the dumped exe actually links (`otool -L`) is minimal and fixed: only
`/usr/lib/libSystem.B.dylib` and **`/opt/homebrew/opt/zstd/lib/libzstd.1.dylib`**
(SBCL's core-compression dependency, a *hard* `LC_LOAD_DYLIB` by absolute Homebrew
path). The Swift-native `libAPIAnywareSbcl` is **not** a load command — it is
`dlopen`ed by the runtime and kept in SBCL's `*shared-objects*` (ADR-0038 §5). So the
two self-containment gaps are of *different kinds*, and neither can be closed by
editing the image.

## Decision

**Close both gaps at runtime — never edit the dumped image.** `bundle-sbcl` produces:

```text
<App>.app/Contents/
  MacOS/<script>            <- a thin Swift stub (CFBundleExecutable)
  Resources/<script>        <- the save-lisp-and-die image (keeps its own ad-hoc sig)
  Frameworks/
    libzstd.1.dylib         <- vendored; resolved by leaf name via DYLD_FALLBACK
    libAPIAnywareSbcl.dylib <- vendored (residual apps); reopened via @executable_path
  Info.plist
```

### 1. `libzstd` (hard load command) — vendor by leaf name + a `DYLD_FALLBACK` stub

The `CFBundleExecutable` is a tiny Swift **stub** that sets
`DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks` and `execv`s the image. When
the image's absolute `/opt/homebrew/...` libzstd path is absent on a clean target, dyld
falls back to searching `DYLD_FALLBACK_LIBRARY_PATH` **by leaf name** and finds the
vendored `Contents/Frameworks/libzstd.1.dylib`. The stub is non-hardened-runtime
ad-hoc/self-signed, so `DYLD_*` survives the `execv` (verified). It also gives the
bundle a per-app CDHash for macOS TCC — the stub-launcher crate's original purpose.

### 2. `libAPIAnywareSbcl` (dlopen'd) — relocate the recorded `*shared-objects*` namestring

The dylib is `dlopen`ed, and SBCL **re-opens it on image restart from its recorded
namestring** (ADR-0038 §5). So the dump loads it from the real `swift build` path (so
every `aw_sbcl_*` symbol resolves at dump time) and then **rewrites only the recorded
`sb-alien::shared-object` `NAMESTRING`** to `@executable_path/../Frameworks/libAPIAnywareSbcl.dylib`
(nulling the `PATHNAME` so the namestring wins). dyld expands `@executable_path`
relative to the dumped *image* (which the stub `execv`s, under `Contents/Resources/`),
resolving to the vendored `Contents/Frameworks/` copy — with **no Mach-O surgery**.

The rewrite is a small, general runtime capability on `aw-load-native-dylib`
(`runtime/swift-trampoline.lisp`), gated on the `AW_NATIVE_DYLIB_RECORD_AS` env var the
bundler sets — inert in every dev/interactive load. The bundler **reuses each app's own
`dump.lisp` unchanged**: it passes the build-path dylib as the driver's arg 2 and sets
the env, so the per-app framework set / `:load-residual` flags / run-loop `:toplevel`
all stay in the app's driver and the bundler stays app-agnostic.

### 3. Codesigning — sign around the image, never re-sign it

`bundle-sbcl` re-signs the vendored dylibs (consistent bundle seal), then signs the
whole bundle (stub as main exe + sealed Resources/Frameworks). The dumped image in
`Contents/Resources/` is sealed by hash only — its `save-lisp-and-die` ad-hoc signature
is untouched (re-signing it is both unnecessary and impossible, §Context).

## Considered options

- **`install_name_tool` + `@executable_path` (the peer targets' path).** *Impossible*
  on a dumped image (§Context) — the reason sbcl relocates at runtime instead.
- **Dump against a custom `--without-zstd` (or relocatable) SBCL.** Removes the libzstd
  load command at the source, so no stub would be needed for it. Rejected: it makes the
  bundler depend on a non-stock SBCL build/maintenance burden, for a gap the
  `DYLD_FALLBACK` stub closes with the stock Homebrew SBCL the whole target already uses.
  (Left as a future simplification if a relocatable SBCL is ever standardized here.)
- **Vendor libzstd at its absolute path on the target.** Cannot — the path is under
  `/opt/homebrew`, which a clean target lacks and the bundle cannot write to.
- **A launcher that records `libAPIAnywareSbcl` by bare leaf name + `DYLD_FALLBACK`
  (uniform with libzstd).** Works, but the `@executable_path` namestring is more robust
  (env-independent) for the one dylib we control the recorded path of; the hybrid keeps
  each gap on its most robust mechanism.

## Consequences

- A new runtime capability: `aw-load-native-dylib` honours `AW_NATIVE_DYLIB_RECORD_AS`
  (`runtime/swift-trampoline.lisp`), proven by `tests/smoke-bundle-relocate.lisp`.
- A new crate `apianyware-bundle-sbcl` (`generation/crates/bundle-sbcl`), invoked
  `cargo run --example bundle_app -p apianyware-bundle-sbcl -- <app>`, peer to
  `bundle-chez`/`bundle-gerbil`. It does **not** extend `bundle-gerbil`'s `relocate.rs`.
- **Hard to reverse:** the stub-as-`CFBundleExecutable` + image-as-Resource layout, the
  `AW_NATIVE_DYLIB_RECORD_AS` contract, and the don't-re-sign-the-image rule are baked
  into every bundled sbcl `.app`.
- The relocation mechanism lives here; ADR-0038 §6 owns the complementary
  self-containment *principle* (dylib = only new non-system dependency) and points here.

## Evidence

- **Residual reopen, move-away proof:** `swift-native-probe.app` revives and runs every
  Swift-native trampoline (`hypot`, `Scanner.scanUpToString`, value-box, …) with the
  `swift build` copy of `libAPIAnywareSbcl` **moved away** — only the vendored
  `Contents/Frameworks/` copy can satisfy the `@executable_path` reopen.
- **`DYLD_FALLBACK` rescue:** a codesigned non-hardened stub's `setenv` survives `execv`
  and dyld resolves a missing-absolute-path dependency by leaf name.
- **Full ladder:** all 8 sample apps bundle, codesign-validate, and revive on-host
  (`bundle-sbcl` crate `#[ignore]`d e2e covers hello-window; the rest verified via the
  example). GUI-draws verification remains the 060 ladder's TestAnyware/VM bar.

See `CONTEXT.md` (*`bundle-sbcl` / sbcl distribution*), ADR-0038 (the dylib + relive
split this composes), ADR-0009/0029 §3 (the peer relocation this *cannot* reuse), and
`generation/crates/bundle-sbcl/README.md`.
