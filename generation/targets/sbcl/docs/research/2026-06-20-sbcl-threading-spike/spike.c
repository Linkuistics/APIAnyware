#include <dispatch/dispatch.h>
#include <pthread.h>
#include <stdint.h>
void aw_spike_run(void (*cb)(long), long outer, long inner) {
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t g = dispatch_group_create();
    for (long i = 0; i < outer; i++) {
        dispatch_group_async(g, q, ^{
            for (long j = 0; j < inner; j++) cb((long)(uintptr_t)pthread_self());
        });
    }
    dispatch_group_wait(g, DISPATCH_TIME_FOREVER);
}
int aw_is_main_thread(void) { return (int)pthread_main_np(); }
