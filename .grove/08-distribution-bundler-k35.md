# distribution-bundler-k35

**Kind:** work

## Goal

Build the `bundle-sbcl` crate (guide Step 8) that packages a sample app as a
self-contained `.app` via `sb-ext:save-lisp-and-die :executable t` (D4): load the
sbcl bindings + app into an image, dump a standalone executable, wrap it with the
shared `stub-launcher` `.app` skeleton + codesigning, `CFBundleName` from the
app spec H1, bundle id `com.linkuistics.<NoSpaceTitle>`. No SBCL needed on the
target machine.

## Context

Peers: `bundle-chez` (self-contained, ADR-0009), `bundle-gerbil` (gxc -exe). The
language-agnostic `apianyware-macos-stub-launcher` provides the `.app` skeleton +
codesigning; this crate does the image dump + dependency staging. **Self-containment
+ the dylib (ADR-0038 §6 / design spec §4):** `save-lisp-and-die :executable t`
embeds the SBCL runtime in the exe; `libAPIAnywareSbcl` is **vendored + relocated**
into `Contents/Frameworks/` via `install_name_tool` (extend `bundle-gerbil`'s
`relocate.rs` path, ADR-0029 §3), after which the bundled exe's `otool -L` shows
only `/usr/lib/*`, system frameworks, and `@executable_path/..`. The Swift runtime
is OS-resident (`/usr/lib/swift/`) — not vendored.

## Done when

- `cargo run --example bundle_app -p apianyware-macos-bundle-sbcl -- <app>`
  produces a runnable, codesigned, self-contained `.app`; used by the 060 apps.

## Notes

- **FINDING from 060/020-hello-window (2026-06-21) — the `install_name_tool` relocation
  plan above (Context lines on `Contents/Frameworks/` + `bundle-gerbil`'s `relocate.rs`)
  is IMPOSSIBLE on a dumped image.** `save-lisp-and-die` appends the Lisp core *after*
  `__LINKEDIT`, so `install_name_tool` refuses the exe ("the __LINKEDIT segment does not
  cover the end of the file") and `codesign --force` fails "strict validation" on that
  layout. So **post-dump Mach-O surgery is off the table** — `bundle-sbcl` CANNOT extend
  `bundle-gerbil`'s `install_name_tool` path. Consequences to design around:
  - `libAPIAnywareSbcl` cannot be relocated into `Contents/Frameworks/` via
    `install_name_tool`. Realistic alternatives: link/dump the exe with an
    `@executable_path/..`-relative install name set BEFORE the dump (the dylib's own
    install name + an rpath chosen at `swift build`/load time), or a launcher that sets
    `DYLD_FALLBACK_LIBRARY_PATH` to a vendored `Contents/Frameworks/`. (Pure-ObjC apps
    like hello-window dodge this entirely — `:load-residual nil`, no dylib.)
  - **`libzstd` surfaced as an unplanned dep:** the dumped exe links Homebrew's
    `/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` (SBCL core-compression). Same relocation
    constraint applies → dump against an SBCL runtime built `--without-zstd` or relocatable,
    or vendor + `DYLD_*` launcher. Verification provisioned the one dylib into the VM.
  - **Do NOT re-`codesign --force` the dumped exe** — `save-lisp-and-die` ALREADY ad-hoc
    signs it on arm64 (so it launches); that signature must be left intact. The
    `stub-launcher` codesigning step must sign around it, not re-sign the main exe.
  - Working dev precursor to extend: `apps/hello-window/{dump.lisp,build.sh}` (dump +
    `.app` wrap + Info.plist). Full detail in `apps/hello-window/learnings.md`.
