#lang racket/base
;; ffi/main-thread.rkt — Dispatch thunks to the macOS main thread via GCD
;;
;; When an app enters the Cocoa run loop via nsapplication-run, the main
;; Racket place thread is blocked in a C call. Racket CS's green thread
;; scheduler cannot advance — (thread ...), (sleep ...), (sync ...) are
;; all dead. This module provides run-loop-integrated dispatch utilities.
;;
;; Delegates to the upstream APIAnyware runtime helper, which uses
;; dispatch_async_f / dispatch_after_f with a thunk registry and
;; module-level function-ptr for GC stability — same implementation
;; this file previously carried inline.
;;
;; API:
;;   (on-main-thread?)                → #t if on the main OS thread
;;   (call-on-main-thread thunk)      → run thunk on main thread
;;   (call-on-main-thread-after s th) → run thunk on main thread after s seconds

(require "../bindings/runtime/main-thread.rkt")

(provide call-on-main-thread
         call-on-main-thread-after
         on-main-thread?)
