// callback_thread.m — spike: invoke a language-made C function pointer from a
// NON-main OS thread, to test whether ffi2-callback changes the Racket-CS
// foreign-thread SIGILL / #:async-apply-deadlock story (020 §3.7, the biggest
// unknown). THROWAWAY spike code (leaf 040/010). Not shipped.

#import <Foundation/Foundation.h>
#include <pthread.h>
#include <dispatch/dispatch.h>

typedef void (*aw_void_cb)(void);

struct cb_box {
    aw_void_cb cb;
};

static void *thread_main(void *arg) {
    struct cb_box *b = (struct cb_box *)arg;
    b->cb(); // invoke the callback from a freshly-created, non-main pthread
    return NULL;
}

// Create a brand-new pthread, invoke the callback on it, join.
// This is the harshest case: a thread Racket CS has never seen.
void aw_spike_call_on_pthread(aw_void_cb cb) {
    struct cb_box b = {cb};
    pthread_t t;
    pthread_create(&t, NULL, thread_main, &b);
    pthread_join(t, NULL);
}

// Invoke the callback on a GCD global concurrent queue worker thread
// (the realistic case: completion handlers, libdispatch workers).
void aw_spike_call_on_gcd(aw_void_cb cb) {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        cb();
        dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

// Baseline: invoke on the calling (main) thread — must always work.
void aw_spike_call_on_main(aw_void_cb cb) {
    cb();
}
