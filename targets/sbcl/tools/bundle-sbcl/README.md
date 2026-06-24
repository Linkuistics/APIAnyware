# bundle-sbcl

Bundle sbcl sample apps into self-contained macOS `.app` directories.

```text
cargo run --example bundle_app -p apianyware-bundle-sbcl -- hello-window
```

Output lands at
`targets/sbcl/app-implementations/macos/<script-name>/build/<App Name>.app`.

## Pipeline (ADR-0041)

1. **Dump** (`dump.rs`) — drive the app's **own** `dump.lisp`
   (`save-lisp-and-die :executable t`) to write the image into
   `Contents/Resources/<script>`. The driver already declares the app's
   framework set, `:load-residual` flags, and run-loop `:toplevel`; the bundler
   only redirects the output path. For a residual app (one whose `dump.lisp`
   calls `aw-load-native-dylib`), the dylib is loaded from its `swift build`
   path and its recorded `*shared-objects*` namestring is relocated to
   `@executable_path/../Frameworks/libAPIAnywareSbcl.dylib` via the
   `AW_NATIVE_DYLIB_RECORD_AS` env the runtime honours.
2. **Stub** (`stub.rs`) — compile a tiny Swift launcher as `CFBundleExecutable`
   that sets `DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks` and
   `execv`s the image. Per-app CDHash for macOS TCC.
3. **Vendor** (`vendor.rs`) — copy the Homebrew `libzstd` the image links (by
   leaf name) and the residual `libAPIAnywareSbcl` into `Contents/Frameworks/`,
   re-signing each.
4. **Sign** (`standalone.rs`) — sign the whole bundle (stub + sealed
   resources). The dumped image keeps its own `save-lisp-and-die` ad-hoc
   signature.

## Why a stub, not `install_name_tool`

The peer bundlers (chez ADR-0009, gerbil ADR-0029 §3) relocate Homebrew dylibs
with `install_name_tool` + `@executable_path`. That is **impossible** on a
dumped image: `save-lisp-and-die` appends the Lisp core *past* `__LINKEDIT`, so
the Mach-O is uneditable (`install_name_tool` refuses it, `codesign --force`
rejects the layout). The two self-containment gaps are closed at **runtime**
instead, neither editing the image:

- **`libzstd`** is a hard `LC_LOAD_DYLIB` with an absolute Homebrew path. It is
  vendored by leaf name; the stub's `DYLD_FALLBACK_LIBRARY_PATH` makes dyld
  resolve it by leaf name when the absolute path is absent on a clean target.
- **`libAPIAnywareSbcl`** (residual apps) is `dlopen`ed, not a load command.
  SBCL re-opens it on image restart from the recorded `*shared-objects*`
  namestring (ADR-0038 §5), which the dump relocated to the `@executable_path`
  vendored copy.

The Swift runtime is OS-resident (`/usr/lib/swift/`) — not vendored.

## Toolchain

The build needs `sbcl` on `PATH` and (residual apps) the Swift toolchain to
build `libAPIAnywareSbcl`. The shipped `.app` needs **neither SBCL nor Homebrew**
on the target — both are build-time only.

## Tests

`cargo test -p apianyware-bundle-sbcl` runs the cheap, deterministic checks
(residual classification against the real app tree, Info.plist shape, the stub
source, the otool parser, the missing-driver precheck). The heavy end-to-end
build (drives `save-lisp-and-die`, then revives the dumped image through the
stub) is `#[ignore]`d — run it explicitly:

```text
cargo test -p apianyware-bundle-sbcl -- --ignored --nocapture
```

The GUI-actually-draws verification is the 060 sample-app ladder (TestAnyware /
VM) — never run a GUI app from the CLI.
