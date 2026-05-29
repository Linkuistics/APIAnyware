# 010-spike-dual-mode-standalone

**Kind:** work (spike — throwaway-quality allowed; the deliverable is evidence,
not production code)

## Goal
Prove **or refute** the native standalone path for `hello-window`, in **both**
build modes, ending with a binary that opens the window **in a VM with Chez
uninstalled**. This is the gate (BRIEF D1): no implementation leaves are
committed until this spike returns a go.

## Context
- Read the node `BRIEF.md` (decisions D1–D5) and `knowledge/targets/chez.md`
  §6–7 first. The Chez 10.4.1 kernel artifacts are confirmed present under
  `/opt/homebrew/Cellar/chezscheme/10.4.1/lib/csv10.4.1/tarm64osx/`
  (`libkernel.a`, `main.o`, `scheme.h`, `scheme.boot`, `petite.boot`,
  `liblz4.a`, `libz.a`).
- Authoritative recipe: Chez User's Guide §2.8 ("Using Chez Scheme",
  `cisco.github.io/ChezScheme/csug10.0/use.html`) + §4.9 (kernel entry points /
  `main.c`). The pipeline is `compile-whole-program` → `make-boot-file` →
  `cc`-link `main.o` + `libkernel.a` (+ `liblz4.a`/`libz.a`) → codesign.
- `hello-window` is chosen because it uses **no** dispatch (no delegates/blocks/
  dynamic subclasses), so the **closed-world** build needs zero `foreign-callable`
  trampolines — it proves the seal-and-link mechanics without first solving the
  eval-free dispatch backend (BRIEF D3).
- VM verification per [[feedback-use-testanyware]]: the real bar is a vanilla VM
  with Chez **uninstalled** (stronger than leaf-160's). Use the TestAnyware
  recipe in [[reference-testanyware-cli]]. Provision the VM, then **remove/rename
  any system Chez** before launching, to prove zero host dependency.
- This is a spike: hand-driven shell scripts / a scratch directory are fine. Do
  **not** wire it into `bundle-chez` yet — that is `020`'s call once the approach
  is proven. Capture the exact commands so `020` can productionise them.

## Done when
**Open-world half (full `scheme` boot embedded):**
- A standalone arm64 binary for `hello-window` built via `compile-whole-program`
  + `make-boot-file` (full scheme boot) + `cc`-link, that **opens the window with
  no system Chez on PATH / installed**.
- The FFI substrate works under the embedded kernel: `load-shared-object` pulls
  `libAPIAnywareChez.dylib` + `libobjc.dylib` at runtime; `foreign-procedure`,
  `foreign-callable`, `lock-object`, and a guardian drain all behave.
- **Synthetic dynamic-load proof** (BRIEF D2, original requirement 1): inside the
  shipped binary, `eval`/`load` a Scheme form **not seen at link time** and build
  a `foreign-callable` via runtime `eval` — proving the embedded boot retains the
  compiler/loader. (`hello-window` itself loads nothing, so this is added test
  scaffolding.)

**Closed-world half (`compile-whole-program`-sealed, no runtime compiler):**
- A sealed standalone binary for `hello-window` that opens the window in the same
  no-Chez VM. Confirm `eval`/dynamic-load is *absent/refused* (it's the
  closed-world contract) and that this is fine because `hello-window` has no
  dispatch.
- Note any FFI/`lock-object`/guardian surprise under whole-program optimisation.

**Measurements (BRIEF D4 — feeds the source-exec-retirement decision):**
- Cold-launch time and on-disk bundle size for all three of `hello-window`:
  (a) today's source-exec bundle, (b) open-world standalone, (c) closed-world
  standalone. One table.

**TCC / codesigning:**
- Confirm the standalone binary inside `.app/Contents/MacOS/` signs with the
  `com.linkuistics.*` id + persistent local identity and still grants TCC
  (BRIEF Context).

**Output:**
- A spike report (suggest `docs/research/2026-05-XX-chez-standalone-spike.md` or a
  scratch note `020` will fold into the spec) with: go/no-go verdict, the exact
  build commands, the three-way measurement table, the dynamic-load proof
  transcript, and every surprise/gotcha hit (these become spec + chez.md
  entries). If the native path is **refuted**, document precisely where it broke
  so `020` can spec the bundle-the-runtime-tree fallback instead.

## Notes
- Keep racket untouched — racket's stub-launcher path is shared and out of scope.
- If `compile-whole-program` and the open-world `eval` requirement collide in a
  way that can't be reconciled even with the full boot, that is the single most
  important finding — capture it loudly; it would force the fallback.
</content>
