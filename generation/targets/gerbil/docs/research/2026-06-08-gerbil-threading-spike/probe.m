// probe.m — gerbil/Gambit foreign-thread callback probe. THROWAWAY.
//
// Calls a Gambit `c-define`d entry (aw_probe_cb — real Scheme heap work,
// ~100k pairs) from several OS-thread contexts to characterize whether a
// green-thread (___SINGLE_VM / ___SINGLE_THREADED_VMS, ___MAX_PROCESSORS 1)
// Gambit can safely enter Scheme from a non-primordial OS thread.
//
// Header finding (gambit.h, ___SINGLE_THREADED_VMS branch): the processor
// state is a GLOBAL (&___GSTATE->vmstate0...pstate[0]), NOT thread-local — so
// every OS thread shares one heap/allocation pointer. The serialized stages
// (direct/pthread/gcd) therefore SURVIVE (only one thread touches the VM at a
// time). The `concurrent` stage is the real test: main thread allocating WHILE
// a GCD worker allocates, both bumping the same global hp with no lock.
//
// One stage per process (argv-driven in the .ss); 134 = crash.

#import <Foundation/Foundation.h>
#include <pthread.h>
#include <dispatch/dispatch.h>
#include <stdio.h>

extern void aw_probe_cb(void);    // real heap work, ~100k pairs
extern void aw_worker_cb(void);   // heavy heap work for the concurrent stage

static void where(const char *tag) {
    fprintf(stderr, "  [C] %s: isMainThread=%d\n", tag, (int)[NSThread isMainThread]);
    fflush(stderr);
}

// --- serialized stages -----------------------------------------------------

// main thread (re-entrant Scheme->C->Scheme): the control
void probe_direct(void) { where("direct"); aw_probe_cb(); fprintf(stderr, "  direct SURVIVED\n"); }

// fresh pthread, no activation; main joins (serialized)
static void *pt_body(void *a) { where("pthread"); aw_probe_cb(); return NULL; }
void probe_pthread(void) {
    pthread_t t; pthread_create(&t, NULL, pt_body, NULL); pthread_join(t, NULL);
    fprintf(stderr, "  pthread SURVIVED\n");
}

// GCD global concurrent queue; main waits on the semaphore (serialized)
void probe_gcd(void) {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        where("gcd-async"); aw_probe_cb(); dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    fprintf(stderr, "  gcd SURVIVED\n");
}

// --- concurrent stage: the real hazard -------------------------------------
// Fire the worker on a GCD thread and DO NOT wait — return to Scheme, which
// then hammers the heap on the main thread concurrently. The worker sets a
// global flag when done; Scheme polls it via worker_is_done().

static volatile int g_worker_done = 0;
int  worker_is_done(void) { return g_worker_done; }

void probe_concurrent_start(void) {
    g_worker_done = 0;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        where("concurrent-worker");
        aw_worker_cb();          // heavy concurrent allocation in Scheme
        g_worker_done = 1;
    });
}
