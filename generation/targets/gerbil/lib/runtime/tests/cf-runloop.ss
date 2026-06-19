;;; tests/cf-runloop.ss — a one-binding CoreFoundation run-loop pump for the async
;;; method smoke. The async trampoline binding is non-blocking (R4); a CLI smoke
;;; must drive the main run loop itself (a real Cocoa app's loop already does) so the
;;; main-thread completion (the MainActor hop) can be delivered. The C body pins the
;;; default mode + return-after-source-handled, taking just the timeout — C-safe.

(import :std/foreign)
(export cf-run-loop-run-in-mode)

(begin-ffi (cf-run-loop-run-in-mode)
  (c-declare "#include <CoreFoundation/CoreFoundation.h>")
  (define-c-lambda cf-run-loop-run-in-mode (double) int
    "___return((int)CFRunLoopRunInMode(kCFRunLoopDefaultMode, ___arg1, true));"))
