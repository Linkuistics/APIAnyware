# Bundle Chez-version coupling — VM Verification

**Date:** 2026-05-29
**Status:** Pass
**Leaf:** `050-chez-target/160-chez-bundle-version-coupling`

Verifies the fix for leaf 130's Issue 1: a precompiled chez `.app` no longer
crashes on a VM whose Chez differs from the one that precompiled it. The bundle
now ships a generated `launch.ss` bootstrap (the stub's `--script` target) that
version-stamps the precompiling Chez and, on mismatch, drops the object half of
every `library-extensions` pair so Chez loads source instead of erroring on the
cross-version `.so`. See `bundle-chez/src/launch.rs` and the 🟢 2026-05-29 entry
in `knowledge/targets/chez.md`.

## Setup

- **Bundle:** `hello-window` built on the dev host with `cargo run --example
  bundle_app -p apianyware-bundle-chez -- hello-window` (full precompile;
  838 `.so` objects; 104 MB / 49 MB tarred, stamped Chez **10.4.1**).
- **VM:** vanilla `testanyware-golden-macos-tahoe` clone. Chez provisioned the
  *intended* way — `brew install chezscheme` — which today poured **10.4.1**.
  **No manual Cellar copy / `chez` symlink swap** (the leaf-130 workaround) was
  performed. Bundle transferred as twelve 4 MB chunks, md5-verified after
  reassembly (`06298ff800f02aec29aae3f13d722ee4`).

## Match path — versions agree (the shipping case)

Brew's 10.4.1 matched the bundle stamp, so `launch.ss` is a no-op and the fast
precompiled `.so` path runs. `open -n` brought the window up within seconds:

- Process: `chez --libdirs …/chez-app --script …/chez-app/launch.ss` (confirms
  the stub now execs the bootstrap, not the entry directly).
- Window: `"Hello from Chez" 400x232 [focused] app:"Hello Window"`, centred
  label `Hello, macOS!`. (screenshot-001-match-fast-path.png)
- **No manual chez version swap** — the literal leaf done-when.

## Mismatch path — versions differ (the original 10.3.0 failure mode)

To exercise the fallback deterministically under the VM's 10.4.1, the bundle's
`launch.ss` version comparison was forced to a non-matching stamp (`9.9.9`),
standing in for the 10.3.0-vs-10.4.1 split that triggered Issue 1. (Only the
comparison literal was edited, so the log line still prints the baked `10.4.1`
text — a genuinely-generated bundle's message is internally consistent.)

- Log: `[apianyware] bundle precompiled by Chez 10.4.1, but 10.4.1 is running;
  loading source (slower launch)` — fallback detected and taken.
- Chez compiled the AppKit facade from source in memory (~75–90 s, RSS climbing
  past 1.1 GB during compile), then painted the **identical** window.
  (screenshot-002-mismatch-source-fallback.png)
- `.so` count **838 → 838**: the in-memory compile wrote no objects, so a
  code-signed bundle's signature stays valid.

## Conclusion

A precompiled chez bundle launches on a vanilla provisioned VM with no manual
Chez version swap, in both the version-match (fast `.so`) and version-mismatch
(source fallback) cases. The leaf-130 Cellar-copy workaround is obsolete. The
golden-image pre-install follow-up (050 brief) is now a launch-*speed*
optimisation, not a correctness requirement.

## Notes

- A macOS "Software Update Available" / Notification Center widget sits in
  several full-desktop captures — VM environment, unrelated to the app.
- Host-side proof (deterministic, version-independent because the fallback never
  opens the `.so`) was run first and matches the VM result exactly.
