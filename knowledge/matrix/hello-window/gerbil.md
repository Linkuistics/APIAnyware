# hello-window x gerbil

**2026-06-08 (leaf `070/040`):**
- 🟢 **PASS** — first proof the whole gerbil pipeline produces a working macOS GUI app.
  Self-contained `.app` (73 MB, `gxc -exe` static Gambit runtime + vendored openssl@3,
  `otool -L` dylib-clean) launches + renders correctly in a **no-Gerbil VM** (no
  provisioning). Window "Hello from Gerbil", centred 24pt "Hello, macOS!" label,
  standard app menu reading "Hello Window" (About/Hide/Quit), Cmd+Q quits clean. See
  `generation/targets/gerbil/test-results/hello-window/report.md`.
- ⚠️ Build-time only: the **cold** build took ~5h, dominated by `gsc -target C` + `gcc
  -O1` on the monolithic full-framework `generics.ss` (60 MB `.scm` → 94 MB `.c`, 9.7 GB
  gcc RSS). Runtime is unaffected. Follow-up leaf `075-generics-compile-cost` at the
  grove root.
