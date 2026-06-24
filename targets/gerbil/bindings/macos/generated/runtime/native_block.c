/* native_block.c — the clang native companion: ObjC block literals AND the
 * main-thread bounce (ADR-0017 §6 native core + ADR-0022 threading).
 *
 * The pieces of the native core that cannot live in the gsc/gcc-15-compiled
 * Gerbil module, because gcc-15 cannot parse `^` block syntax. This single
 * translation unit is compiled SEPARATELY by `clang -fblocks` and linked into
 * the executable; everything else in the native core (`native-core.ss`) stays
 * gcc-15 C-safe.
 *
 * ## Part 1 — block makers (`make-objc-block`)
 *
 * Each maker builds a heap block (Block_copy) capturing an integer block-id and
 * an opaque dispatcher fn-pointer (one of native-core.ss's `aw_blk_*`
 * `c-define`s, which looks the id up in the Scheme closure table and runs the
 * user's proc). The block carries a fixed 3-arg pointer tail; a block the
 * framework calls with fewer args leaves the upper slots unread.
 *
 * ## Part 2 — the main-thread bounce (ADR-0022)
 *
 * The bottle's Gambit is single-VM / green-thread: the processor state is a
 * process-global, so two OS threads entering Scheme concurrently corrupt the
 * heap (spike: 30/30 crashes). There is no `Sactivate_thread` analogue. So a
 * foreign OS thread must NEVER re-enter Gerbil directly — it must hop to the
 * MAIN thread (which owns the VM and runs the AppKit run loop) first.
 *
 * Both callback paths funnel their foreign-thread entry through this unit, so
 * the bounce lives here:
 *   - BLOCK invokes: the bounce is inside each block body (below), wrapping the
 *     call to the inner `aw_blk_*` dispatcher.
 *   - IMP entries (delegates, transparent-subclass overrides): the inner
 *     `aw_imp_*` `c-define`s are the main-thread-only entry; the NAMED outer
 *     trampolines `aw_imp_*_tramp` here are what `class_addMethod` installs, and
 *     they do the bounce before calling inward.
 *
 * `pthread_main_np()` (pure C) is the on-main check — keeps this a `.c`, no
 * `-x objective-c` needed. The bounce is UNIFORM `dispatch_sync`, NOT
 * sync-for-value / async-for-void: a framework frees a callback's `id` arguments
 * the instant the call returns, so an async hop would run the Scheme work
 * against freed objects (use-after-free). Sync keeps the framework call blocked
 * until the bounce completes, preserving arg lifetime AND the return value. The
 * one cost is the documented deadlock caveat (a value the main thread is itself
 * synchronously blocked awaiting); rare and avoidable.
 *
 * On the main thread already (the run-loop common case — AppKit delegates fire
 * on main), every trampoline calls inward directly: zero added overhead.
 *
 * ## Self-containment (load-bearing for the build)
 *
 * This unit must reference NO external symbol of its own — `gxc -O` links it
 * into EVERY gerbil module's object during the per-module precompile (it is on
 * the `-ld-options` line), so any symbol it names must resolve from system
 * libraries alone, never from another gerbil module's object (which is not on
 * that line). That is why the inner IMP dispatchers are NOT referenced by
 * symbol: native-core.ss PUSHES their function pointers in at load via
 * `aw_register_imp_inner` (the same self-contained shape the block makers get
 * by receiving their dispatcher as an argument). The only externals here are
 * libSystem (dispatch/pthread/Block) — always linked.
 */

#include <Block.h>
#include <stdbool.h>
#include <pthread.h>
#include <dispatch/dispatch.h>

/* --- the bounce primitive ------------------------------------------------- *
 * Run `work` on the main thread and block until it finishes. Direct call when
 * already on main (avoids a needless hop and the deadlock window). `work` is a
 * no-arg block capturing whatever the caller needs (args + an out-cell). */
static inline void aw_on_main(void (^work)(void)) {
    if (pthread_main_np()) work();
    else dispatch_sync(dispatch_get_main_queue(), work);
}

/* ===== Part 1+2: block makers, each with the bounce in the block body ===== */

void *aw_make_block_void(int bid, void *dv) {
    void (*d)(int, void *, void *, void *) = (void (*)(int, void *, void *, void *))dv;
    void (^b)(void *, void *, void *) =
        ^(void *a1, void *a2, void *a3) {
            aw_on_main(^{ d(bid, a1, a2, a3); });
        };
    return (void *)Block_copy(b);
}

void *aw_make_block_id(int bid, void *dv) {
    void *(*d)(int, void *, void *, void *) = (void *(*)(int, void *, void *, void *))dv;
    void *(^b)(void *, void *, void *) =
        ^void *(void *a1, void *a2, void *a3) {
            __block void *r = (void *)0;
            aw_on_main(^{ r = d(bid, a1, a2, a3); });
            return r;
        };
    return (void *)Block_copy(b);
}

void *aw_make_block_bool(int bid, void *dv) {
    bool (*d)(int, void *, void *, void *) = (bool (*)(int, void *, void *, void *))dv;
    bool (^b)(void *, void *, void *) =
        ^bool(void *a1, void *a2, void *a3) {
            __block bool r = false;
            aw_on_main(^{ r = d(bid, a1, a2, a3); });
            return r;
        };
    return (void *)Block_copy(b);
}

void *aw_make_block_long(int bid, void *dv) {
    long (*d)(int, void *, void *, void *) = (long (*)(int, void *, void *, void *))dv;
    long (^b)(void *, void *, void *) =
        ^long(void *a1, void *a2, void *a3) {
            __block long r = 0;
            aw_on_main(^{ r = d(bid, a1, a2, a3); });
            return r;
        };
    return (void *)Block_copy(b);
}

/* ===== Part 2: IMP outer trampolines (installed by class_addMethod) ======= *
 * The inner dispatchers are native-core.ss `c-define`s (Gambit's standard C
 * types: void / void* / ___BOOL=bool / long); on arm64 unused upper arg slots
 * are benignly unread. We hold them as REGISTERED function pointers (not symbol
 * references — see "Self-containment" above); native-core calls
 * aw_register_imp_inner once at load. Each outer trampoline has the same ABI as
 * the IMP and bounces to main before calling inward. */

typedef void  (*imp_void_fn)(void *, void *, void *, void *, void *, void *);
typedef void *(*imp_id_fn)  (void *, void *, void *, void *, void *, void *);
typedef bool  (*imp_bool_fn)(void *, void *, void *, void *, void *, void *);
typedef long  (*imp_long_fn)(void *, void *, void *, void *, void *, void *);

static imp_void_fn g_imp_void = (imp_void_fn)0;
static imp_id_fn   g_imp_id   = (imp_id_fn)0;
static imp_bool_fn g_imp_bool = (imp_bool_fn)0;
static imp_long_fn g_imp_long = (imp_long_fn)0;

/* Called once by native-core.ss at load with the addresses of its inner
 * `aw_imp_*` c-defines (opaque void* to keep this unit's prototype simple). */
void aw_register_imp_inner(void *v, void *i, void *b, void *l) {
    g_imp_void = (imp_void_fn)v;
    g_imp_id   = (imp_id_fn)i;
    g_imp_bool = (imp_bool_fn)b;
    g_imp_long = (imp_long_fn)l;
}

void aw_imp_void_tramp(void *s, void *c, void *a1, void *a2, void *a3, void *a4) {
    aw_on_main(^{ g_imp_void(s, c, a1, a2, a3, a4); });
}

void *aw_imp_id_tramp(void *s, void *c, void *a1, void *a2, void *a3, void *a4) {
    __block void *r = (void *)0;
    aw_on_main(^{ r = g_imp_id(s, c, a1, a2, a3, a4); });
    return r;
}

bool aw_imp_bool_tramp(void *s, void *c, void *a1, void *a2, void *a3, void *a4) {
    __block bool r = false;
    aw_on_main(^{ r = g_imp_bool(s, c, a1, a2, a3, a4); });
    return r;
}

long aw_imp_long_tramp(void *s, void *c, void *a1, void *a2, void *a3, void *a4) {
    __block long r = 0;
    aw_on_main(^{ r = g_imp_long(s, c, a1, a2, a3, a4); });
    return r;
}
