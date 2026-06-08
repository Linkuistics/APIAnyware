/* smoke_dispatch.c — clang harness for the background-callback smoke
 * (leaf 080/020, ADR-0022). Compiled by `clang -fblocks` and linked into
 * smoke-dispatch only; kept OUT of the gcc-15 smoke unit because it uses
 * dispatch `^` blocks + CoreFoundation (run-smokes.sh, like native_block.c).
 *
 * Drives a Gerbil-built ObjC block from REAL GCD worker threads, so the
 * native-core bounce is exercised under genuine concurrency: each invocation's
 * block body hops to the main thread before running Scheme. The main thread
 * pumps its run loop (aw_smoke_pump) to service the bounced work. If the bounce
 * were absent, the Scheme proc would run on the worker concurrently with the
 * main thread → the heap corruption the spike measured (30/30 crashes).
 */

#include <dispatch/dispatch.h>
#include <pthread.h>
#include <CoreFoundation/CoreFoundation.h>

typedef void (^aw_void_block)(void *, void *, void *);

static volatile int g_done = 0;

int  aw_smoke_done(void)     { return g_done; }
int  aw_smoke_on_main(void)  { return pthread_main_np() ? 1 : 0; }
void aw_smoke_reset(void)    { g_done = 0; }

/* Pump the main run loop for up to `secs`, servicing the main dispatch queue
 * (where the bounced callbacks land). Returns when idle or after the timeout. */
void aw_smoke_pump(double secs) {
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, (CFTimeInterval)secs, false);
}

/* Fire the objc block `n` times, each from a fresh GCD worker (a real
 * background thread). Each invocation drives the block, whose body bounces to
 * main before running the Gerbil proc; g_done is bumped on the worker once the
 * (bounced) call returns. */
void aw_smoke_fire(void *blk, int n) {
    aw_void_block b = (aw_void_block)blk;
    for (int i = 0; i < n; i++) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            b(0, 0, 0);
            __sync_fetch_and_add(&g_done, 1);
        });
    }
}
