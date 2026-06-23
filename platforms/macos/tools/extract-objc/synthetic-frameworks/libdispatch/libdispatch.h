// Synthetic umbrella header for a pseudo-framework that extracts
// libdispatch and a minimal slice of pthread. These declarations live
// under /usr/include/ in the SDK and have no native .framework wrapper,
// so the extractor treats this header as if it were an umbrella for a
// framework named "libdispatch".
//
// Consumers need: dispatch_async_f, dispatch_after_f, dispatch_time,
// dispatch_get_main_queue (which expands to &_dispatch_main_q),
// pthread_main_np.

#include <dispatch/dispatch.h>
#include <pthread.h>
