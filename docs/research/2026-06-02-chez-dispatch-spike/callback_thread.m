// callback_thread.m — foreign-thread callback probe. THROWAWAY.
//
// Calls a C function pointer (a Chez foreign-callable entry point) from several
// thread contexts to determine whether Chez can safely enter Scheme from a
// non-Scheme OS thread, and whether Sactivate_thread() (available because the
// Homebrew Chez is a THREADED build) lets a foreign thread enter Scheme safely
// without a main-thread bounce. Chez analogue of racket's ffi2-callback-SIGILL.

#import <Foundation/Foundation.h>
#include <pthread.h>
#include <dispatch/dispatch.h>
#include <stdio.h>

// Resolved against the chez executable at load (build with -undefined dynamic_lookup).
extern int Sactivate_thread(void);
extern void Sdeactivate_thread(void);

typedef void (*cb_t)(void);
static cb_t g_cb;

static void where(const char *tag) {
    fprintf(stderr, "  [C] %s: isMainThread=%d\n", tag, (int)[NSThread isMainThread]);
    fflush(stderr);
}

// --- main thread (caller) ---
void probe_call_direct(cb_t cb) { where("direct"); cb(); }

// --- fresh pthread, no activation ---
static void *pt_body(void *a) { where("pthread"); g_cb(); return NULL; }
void probe_call_pthread(cb_t cb) {
    g_cb = cb; pthread_t t; pthread_create(&t, NULL, pt_body, NULL); pthread_join(t, NULL);
}

// --- fresh pthread, Sactivate_thread()-wrapped ---
static void *pt_body_act(void *a) {
    where("pthread-act"); Sactivate_thread(); g_cb(); Sdeactivate_thread(); return NULL;
}
void probe_call_pthread_activated(cb_t cb) {
    g_cb = cb; pthread_t t; pthread_create(&t, NULL, pt_body_act, NULL); pthread_join(t, NULL);
}

// --- GCD global concurrent queue via dispatch_async (a REAL worker thread) ---
void probe_call_gcd_async(cb_t cb) {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        where("gcd-async"); cb(); dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

// --- GCD async worker, Sactivate_thread()-wrapped ---
void probe_call_gcd_async_activated(cb_t cb) {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        where("gcd-async-act"); Sactivate_thread(); cb(); Sdeactivate_thread();
        dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}
