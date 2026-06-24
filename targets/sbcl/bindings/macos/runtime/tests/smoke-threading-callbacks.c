/* smoke-threading-callbacks.c — the foreign-thread storm harness for leaf 050/060.
 *
 * Compiled by the companion `.lisp` smoke (`clang -fblocks ... -framework
 * CoreFoundation`) and `load-shared-object`ed into the SBCL image. It reproduces the
 * EXACT shape the threading spike crashed 5/5 on — `outer` CONCURRENT GCD worker
 * threads, each invoking a callback `inner` times under GC pressure — but here the
 * callback is a Lisp `aw-block` whose body BOUNCES to the main thread (ADR-0035), so the
 * foreign workers never enter Lisp and `GC-STOP-THE-WORLD` never has to suspend one.
 * The pre-bounce spike used a raw `define-alien-callable` fired the same way; this is
 * the regression gate that the bounce closes the crash.
 *
 * The wrinkle vs the spike: the spike BLOCKED the main thread in
 * `dispatch_group_wait`, which would deadlock here (the workers' `dispatch_sync(main)`
 * bounces could never run). So the storm runs on a BACKGROUND queue and the main thread
 * spins its run loop — exactly as a real app does under `[NSApp run]` — servicing the
 * bounced work; the storm stops the loop when every worker has finished.
 */

#include <dispatch/dispatch.h>
#include <CoreFoundation/CoreFoundation.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>

/* Fire the universal `aw-block` (its ABI is `(void*,void*,void*) -> void*`, the result
 * an integer-class value in x0) from `outer` concurrent GCD workers, `inner` times each,
 * accumulating the integer returns. Runs the storm on a background queue while THIS
 * (main) thread services the run loop so the per-call main-thread bounce is delivered;
 * returns the summed result once the storm completes. */
long aw_sbcl_smoke_block_storm(void *blockptr, long outer, long inner) {
    intptr_t (^blk)(void *, void *, void *) =
        (intptr_t (^)(void *, void *, void *))blockptr;

    _Atomic long *total = calloc(1, sizeof(_Atomic long));
    _Atomic int *done = calloc(1, sizeof(_Atomic int));
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(q, ^{
        dispatch_group_t g = dispatch_group_create();
        for (long i = 0; i < outer; i++) {
            dispatch_group_async(g, q, ^{
                for (long j = 0; j < inner; j++) {
                    /* a1 = a sentinel (the worker's pthread id), a2 = the index j,
                     * a3 = null — all integer-class, as the universal block expects. */
                    intptr_t r = blk((void *)(uintptr_t)pthread_self(),
                                     (void *)(uintptr_t)j,
                                     (void *)0);
                    atomic_fetch_add(total, (long)r);
                }
            });
        }
        dispatch_group_wait(g, DISPATCH_TIME_FOREVER);
        atomic_store(done, 1);
        CFRunLoopStop(CFRunLoopGetMain());
    });

    /* Service the bounced main-thread work until the storm signals completion. Looping
     * (not a bare `CFRunLoopRun`) is robust to a spurious empty-run-loop return. */
    while (!atomic_load(done)) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e9, false);
    }

    long result = atomic_load(total);
    free((void *)total);
    free((void *)done);
    return result;
}

/* Run the main run loop for up to `seconds`, servicing any pending main-thread work
 * (a worker's `aw-on-main` bounce). Returns when work is handled, the loop is stopped,
 * or the timeout elapses — the smoke pumps in a bounded loop until its flag flips. */
void aw_sbcl_smoke_pump(double seconds) {
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, seconds, false);
}

/* pthread_main_np for the smoke's own assertions. */
int aw_sbcl_smoke_is_main(void) { return (int)pthread_main_np(); }
