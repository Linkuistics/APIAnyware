# 010-native-core-bounce

**Kind:** work

## Goal

Implement ADR-0022's main-thread bounce in the gerbil native core, replacing the
050 main-thread *placeholder* (callbacks re-enter Scheme directly, safe only
because the run loop calls on main) with off-main entry that is safe by
construction.

## Context

The `c-define`d dispatchers in `runtime/native-core.ss` (`aw_imp_*`, `aw_blk_*`)
run under gcc-15 and cannot use `[NSThread isMainThread]` / `dispatch_*` (ObjC +
blocks → clang only, same split as `native_block.c`, ADR-0021). So the bounce
must wrap them from a clang companion.

## Done when

- The `c-define`d dispatchers become the **inner**, main-thread-only entry. A
  clang **outer** trampoline per (return-kind × IMP/block) checks the thread and,
  off-main, hops to the main queue before calling inward; on-main it calls inward
  directly (zero overhead — the run-loop common case).
- **Value-returning** (id/bool/long) outer trampolines use `dispatch_sync` to the
  main queue (result needed; args outlive the hop); **void** ones use
  `dispatch_async` (and dodge the sync-while-main-blocked deadlock).
- `class-add-method` installs the outer IMP trampolines; the `native_block.c`
  block makers invoke the outer block dispatchers. Inner symbols stay `extern`-
  visible to the companion only.
- Builds clean with the existing hello-window `build.sh` toolchain (gcc-15 for
  the `c-define` unit, clang `-fblocks` for the companion); hello-window still
  links and runs (no regression to the on-main path).

## Notes

Keep the inner/outer naming obvious (`aw_imp_id` inner → `aw_imp_id_tramp`
outer, or similar). The clang companion may be `native_block.c` extended, or a
new `native_bounce.m` — pick whichever keeps the build line clean. Verified for
real by leaf 020 (the smoke test); this leaf's bar is "compiles + no on-main
regression".
