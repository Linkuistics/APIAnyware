# 070-startup-re-resolution

**Kind:** work

## Goal

Build the **mandatory startup re-resolution pass** (ADR-0034 §6 / ADR-0038 §5). A
dumped image (`save-lisp-and-die`) keeps the baked Lisp metadata — the class graph,
selector strings, opt-in ivar offsets — but **loses every live `Class`/`SEL`/function
pointer** (they were addresses in the generating process). So the runtime must, at
every process start, re-derive them from **baked string identity** — never reuse a
baked pointer. Load-bearing for **070-distribution** (the dumped exe is dead without it).

- **Re-`dlopen` each direct-msgSend framework** — the frameworks reached via direct
  `objc_msgSend` (not through the dylib) must be re-loaded so their classes are
  registered with the ObjC runtime. (The **residual-owning** frameworks the dylib links
  are re-loaded by dyld for free — §5; this Lisp pass owns the *direct* set only.)
- **Re-resolve `+objc-msgsend+`** — the `objc_msgSend` SAP (020 defined the var; 070
  owns re-resolving it at startup; it lives in always-mapped libobjc).
- **Re-resolve every `Class`** — walk the `register-objc-class` string table,
  `objc_getClass("<ObjCName>")` each, store the fresh `Class` SAP on the metaclass
  metaobject (the `aw-class` cache + the metaclass slot 030 reads).
- **`SEL`s** — `aw-sel` already resolves lazily from the baked string + caches (020);
  070 just **invalidates** any cache the dump may have frozen so the first post-dump
  `aw-sel` re-resolves. (SELs live in always-mapped libobjc — no eager table needed.)
- **Opt-in ivar offsets** (open item §8) — if the baked-offset fast path is in use,
  either re-resolve via `ivar_getOffset` at startup or rely on the accessor-selector
  safe default. Currently the table is empty (no IR ivar layout) — wire the re-resolve
  hook + the inert empty path.
- **Composition with the dylib auto-reopen (ADR-0038 §5):** SBCL auto-reopens the dylib
  (in `*shared-objects*`) ⇒ `aw_sbcl_*` re-link for free; the dylib stays **passive**
  (no `aw_sbcl_revive` entry). This Lisp pass owns exactly the complement: the direct
  frameworks + all `Class`/`SEL`. Document the split inline.
- **The hook** — register the pass to run at image startup (`sb-ext:*init-hooks*` /
  the `:toplevel` of `save-lisp-and-die`, finalized in 070-distribution; 050/070
  provides the callable pass + a `--load` smoke).

## Context

Node BRIEF (METACLASS + ROOT re-resolution notes, `+objc-msgsend+` "MUST be
re-resolved at startup", `aw-sel`/`aw-class` "re-resolved per process"). Design spec
§2 (static emit + startup re-resolution) + §4 (the relive-split) + ADR-0034 §6 +
ADR-0038 §5. Spike: `2026-06-20-sbcl-mop-spike/5-startup-re-resolution.sh` (verified
the dump/reload/re-resolve cycle). Needs 020 (the caches + `+objc-msgsend+`) + 030
(the `register-objc-class` table + the metaclass slot to store fresh `Class`es on).

## Done when

- A `--load`-time smoke: after deliberately **clearing** the resolved caches (simulating
  a fresh image), the pass re-resolves `+objc-msgsend+` + every registered `Class` + the
  framework set; subsequent dispatch works (the same selectors that worked pre-clear).
- The empty ivar-offset path is inert; the re-resolve hook is wired (exercised by a
  hand-constructed offset entry, mirroring 030's slot smoke).
- The pass is idempotent (running it twice is safe) and ordered correctly (frameworks
  re-`dlopen`ed before `objc_getClass`).
- A genuine `save-lisp-and-die` → relaunch round-trip (even a minimal one) resolves +
  dispatches — proving the dumped-image path (the real reason this leaf exists).

## Notes

- The "never reuse a baked pointer" rule is the entire correctness invariant — a baked
  `Class` SAP that *happens* to still work in the generating process will segfault in a
  dumped one. Test the **dumped** path, not just the live one.
- Full `save-lisp-and-die :executable t` + relocation is **070-distribution**'s job;
  this leaf only needs the re-resolution pass to be correct + a minimal dump round-trip
  to prove it.
