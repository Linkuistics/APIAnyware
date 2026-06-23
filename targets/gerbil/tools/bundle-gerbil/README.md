# bundle-gerbil

Bundle gerbil sample apps into self-contained macOS `.app` directories.

```text
cargo run --example bundle_app -p apianyware-bundle-gerbil -- hello-window
```

Output lands at
`generation/targets/gerbil/apps/<script-name>/build/<App Name>.app`.

## Pipeline

1. **Walk the import closure** (`deps.rs`) — parse the app's `(import …)`
   form, follow every `:gerbil-bindings/…` reference transitively (each
   generated class module imports its superclass module + `runtime/objc` +
   `generics`), topologically order the result. Pure Rust: the emitter's
   import syntax is a flat module-reference list, far simpler than the R6RS
   wrapper forms that made chez's walker shell out.
2. **Compile** (`compile.rs`) — drive the **bottle** gerbil toolchain
   (generalising the per-app `build.sh`):
   - clang the one block-literal companion (`runtime/native_block.c`,
     `-fblocks`) — the only non-default compile (ADR-0021);
   - `gxc -O` the closure into a persistent `GERBIL_PATH` cache, since
     `gxc -exe` does not recursively compile imports;
   - `gxc -exe -O` to link the app exe with `-lobjc`, one `-framework` per
     framework the closure touches, and the companion `.o`.
3. **Assemble + relocate** (`standalone.rs`, `relocate.rs`) — lay out the
   bundle (the `gxc -exe` binary at `Contents/MacOS/<script>`, `Info.plist`),
   then vendor every `/opt/homebrew/*` dylib the exe transitively links into
   `Contents/Frameworks/` and rewrite every Homebrew load command to
   `@executable_path/../Frameworks/<name>` via `install_name_tool`.
4. **Codesign** the relocated dylibs then the whole bundle.

## Why gerbil is simpler than chez

`gxc -exe` links `libgambit.a` statically, so the binary embeds the whole
Gerbil/Gambit runtime — there is no boot image, no kernel embed, and no
duplicate-import collision probe (the chez bundler's machinery). The *only*
self-containment gap is the Gerbil stdlib's openssl@3 (`libssl`/`libcrypto`)
Homebrew dylib dependency, which step 3 vendors and relocates.

The relocation reads each Mach-O's **actual** `otool -L` output rather than
assuming paths: `libssl` references `libcrypto` by its *Cellar* path while the
exe references it by the *opt* symlink path. `install_name_tool -change` needs
the exact existing string, so every `/opt/homebrew/*` load command is rewritten
in place, keyed by basename.

## Toolchain

The build needs the **bottle** gerbil (`/opt/homebrew/Cellar/gerbil-scheme/<ver>`).
Discovery globs the Cellar; override with `AW_GERBIL_BIN_DIR=<bin>`. The shipped
`.app` has no gerbil runtime dependency — the toolchain is build-time only.

## Tests

`cargo test -p apianyware-bundle-gerbil` runs the cheap, deterministic
checks (closure walk, import parsing, relocation path math, the entry
precheck). The heavy end-to-end build (drives `gxc` over the AppKit closure,
asserts the bundle is Homebrew-clean) is `#[ignore]`d — run it explicitly:

```text
cargo test -p apianyware-bundle-gerbil -- --ignored --nocapture
```

The GUI-actually-draws verification is grove leaf 070/040 (TestAnyware / VM) —
never run a GUI app from the CLI.
