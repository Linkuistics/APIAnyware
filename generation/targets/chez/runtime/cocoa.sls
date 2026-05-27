;; runtime/cocoa.sls — chez target high-level Cocoa helpers.
;;
;; Scaffold: all bodies are `(error ... "not yet implemented")` stubs.
;; Real bodies land in `.grove/050-chez-target/050-runtime-types-cocoa.md`.
;;
;; Eventually holds:
;;   - install-standard-app-menu! (the canonical Apple/File/Edit/etc.
;;     menu bar)
;;   - main-thread dispatch via dispatch_get_main_queue + dispatch_async
;;   - AppKit / AX / SPI helper procedures the sample apps call
;;   - objc-subclass facade (the static-subclass authoring sugar)
;;
;; This is the topmost runtime cluster — sample apps generally import
;; only `(apianyware runtime cocoa)` and pull the others in transitively.
;;
;; Absorbs from the racket runtime: app-menu.rkt, main-thread.rkt,
;; nsview-helpers.rkt, nsevent-helpers.rkt, cgevent-helpers.rkt,
;; ax-helpers.rkt, spi-helpers.rkt, objc-subclass.rkt (logic ports,
;; FFI signatures rewritten against `foreign-procedure`).

(library (apianyware runtime cocoa)
  (export
    install-standard-app-menu!
    dispatch-on-main-thread
    dispatch-on-main-thread-async
    nsview-add-subview!
    nsview-remove-from-superview!
    nsevent-modifier-flags
    cgevent-post
    ax-application-element
    spi-private-method-bind
    objc-subclass-define)
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc)
          (apianyware runtime dispatch)
          (apianyware runtime types))

  (define (install-standard-app-menu!)
    (error 'install-standard-app-menu! "not yet implemented"))

  (define (dispatch-on-main-thread proc)
    (error 'dispatch-on-main-thread "not yet implemented"))

  (define (dispatch-on-main-thread-async proc)
    (error 'dispatch-on-main-thread-async "not yet implemented"))

  (define (nsview-add-subview! parent child)
    (error 'nsview-add-subview! "not yet implemented"))

  (define (nsview-remove-from-superview! v)
    (error 'nsview-remove-from-superview! "not yet implemented"))

  (define (nsevent-modifier-flags evt)
    (error 'nsevent-modifier-flags "not yet implemented"))

  (define (cgevent-post evt)
    (error 'cgevent-post "not yet implemented"))

  (define (ax-application-element pid)
    (error 'ax-application-element "not yet implemented"))

  (define (spi-private-method-bind name)
    (error 'spi-private-method-bind "not yet implemented"))

  (define (objc-subclass-define name parent methods)
    (error 'objc-subclass-define "not yet implemented")))
