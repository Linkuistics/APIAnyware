;; runtime/cocoa.sls — chez target Cocoa helpers (core).
;;
;; Absorbs from racket: app-menu.rkt, main-thread.rkt, nsview-helpers.rkt,
;; nsevent-helpers.rkt. The heavier helpers — cgevent, ax, spi, and the
;; declarative `define-objc-subclass` — live in `cocoa-helpers.sls` so this
;; library stays focused on what every sample app needs.
;;
;; Forced rewrites against `foreign-procedure` rather than ffi/unsafe; logic
;; is a near-mechanical port of the racket originals.

(library (apianyware runtime cocoa)
  (export
    install-standard-app-menu!
    on-main-thread? call-on-main-thread call-on-main-thread-after
    set-autoresizing-mask!
    nsevent-location-in-window)
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc)
          (apianyware runtime types))

  ;; --- objc_msgSend variants used here -------------------------------

  (define %msg-0
    (foreign-procedure "objc_msgSend" (void* void*) void*))

  (define %msg-id
    (foreign-procedure "objc_msgSend" (void* void* void*) void*))

  (define %msg-id->void
    (foreign-procedure "objc_msgSend" (void* void* void*) void))

  (define %msg-init-with-title-action-key
    (foreign-procedure "objc_msgSend"
                       (void* void* void* void* void*) void*))

  (define %msg-set-modifier-mask
    (foreign-procedure "objc_msgSend" (void* void* unsigned-64) void))

  (define %msg-set-uint64
    (foreign-procedure "objc_msgSend" (void* void* unsigned-64) void))

  ;; objc_msgSend returning NSPoint by value. No `_stret` variant is needed
  ;; (a 16-byte aggregate is register-returned by the C ABI), but Chez's
  ;; `(& NSPoint)` *result* convention is uniform regardless of size: the
  ;; foreign-procedure takes the result buffer as a hidden leading arg and
  ;; writes the struct into it. The caller (see `nsevent-location-in-window`)
  ;; must allocate that buffer and pass it first; calling with just
  ;; `(self sel)` fails at runtime with "incorrect number of arguments".
  (define %msg-point
    (foreign-procedure "objc_msgSend" (void* void*) (& NSPoint)))

  ;; --- install-standard-app-menu! ------------------------------------
  ;;
  ;; Installs the standard application menu — `About <App>` / separator /
  ;; `Hide <App>` ⌘H / `Hide Others` ⌥⌘H / `Show All` / separator /
  ;; `Quit <App>` ⌘Q — on the supplied NSApplication.
  ;;
  ;; The bold app-name slot in the menu bar still comes from
  ;; `CFBundleName` in the bundle's `Info.plist` — running unbundled will
  ;; show "chez" there even with this menu installed.

  (define NSEventModifierFlagCommand #x100000)
  (define NSEventModifierFlagOption  #x80000)

  (define sel-alloc                     (sel-register "alloc"))
  (define sel-init-with-title           (sel-register "initWithTitle:"))
  (define sel-init-with-title-action-key
    (sel-register "initWithTitle:action:keyEquivalent:"))
  (define sel-add-item-with-title-action-key
    (sel-register "addItemWithTitle:action:keyEquivalent:"))
  (define sel-add-item                  (sel-register "addItem:"))
  (define sel-separator-item            (sel-register "separatorItem"))
  (define sel-set-submenu               (sel-register "setSubmenu:"))
  (define sel-set-main-menu             (sel-register "setMainMenu:"))
  (define sel-set-key-equivalent-modifier-mask
    (sel-register "setKeyEquivalentModifierMask:"))
  (define sel-about
    (sel-register "orderFrontStandardAboutPanel:"))
  (define sel-hide                      (sel-register "hide:"))
  (define sel-hide-others
    (sel-register "hideOtherApplications:"))
  (define sel-unhide-all
    (sel-register "unhideAllApplications:"))
  (define sel-terminate                 (sel-register "terminate:"))

  (define (ns-string s) (string->nsstring-ptr s))

  (define (raw-id v)
    (cond
      [(not v) 0]
      [(objc-object? v) (objc-object-ptr v)]
      [(integer? v) v]
      [else (error 'install-standard-app-menu!
                   "expected objc-object or integer" v)]))

  (define (make-menu title)
    (let* ([cls     (objc_getClass "NSMenu")]
           [alloced (%msg-0 cls sel-alloc)])
      (%msg-id alloced sel-init-with-title (ns-string title))))

  (define (make-menu-item title action key)
    (let* ([cls     (objc_getClass "NSMenuItem")]
           [alloced (%msg-0 cls sel-alloc)])
      (%msg-init-with-title-action-key
        alloced sel-init-with-title-action-key
        (ns-string title)
        (or action 0)
        (ns-string key))))

  (define (menu-add-item! menu item)
    (%msg-id->void menu sel-add-item item))

  (define (menu-add-item-with-title! menu title action key)
    (%msg-init-with-title-action-key
      menu sel-add-item-with-title-action-key
      (ns-string title)
      (or action 0)
      (ns-string key)))

  (define (separator-item)
    (%msg-0 (objc_getClass "NSMenuItem") sel-separator-item))

  (define (install-standard-app-menu! application app-name)
    (let* ([app          (raw-id application)]
           [main-menu    (make-menu "")]
           [app-menu-item (make-menu-item "" #f "")]
           [app-menu     (make-menu app-name)])
      ;; About <App>
      (menu-add-item-with-title!
        app-menu (string-append "About " app-name) sel-about "")
      (menu-add-item! app-menu (separator-item))
      ;; Hide <App>  ⌘H
      (menu-add-item-with-title!
        app-menu (string-append "Hide " app-name) sel-hide "h")
      ;; Hide Others  ⌥⌘H
      (let ([hide-others
              (menu-add-item-with-title!
                app-menu "Hide Others" sel-hide-others "h")])
        (%msg-set-modifier-mask
          hide-others sel-set-key-equivalent-modifier-mask
          (bitwise-ior NSEventModifierFlagCommand
                       NSEventModifierFlagOption)))
      ;; Show All
      (menu-add-item-with-title! app-menu "Show All" sel-unhide-all "")
      (menu-add-item! app-menu (separator-item))
      ;; Quit <App>  ⌘Q
      (menu-add-item-with-title!
        app-menu (string-append "Quit " app-name) sel-terminate "q")
      (%msg-id->void app-menu-item sel-set-submenu app-menu)
      (menu-add-item! main-menu app-menu-item)
      (%msg-id->void app sel-set-main-menu main-menu)))

  ;; --- Main-thread dispatch ------------------------------------------
  ;;
  ;; Once `[NSApplication run]` is entered, the calling thread is parked
  ;; inside C. To run Scheme code on a future iteration of the run loop
  ;; we hand a function pointer to GCD's `dispatch_async_f`, which fires
  ;; the function from the main run loop on its next tick. Using the
  ;; function-pointer variant avoids the ObjC block ABI.

  (define %pthread-main-np
    (foreign-procedure "pthread_main_np" () int))

  (define %dispatch-async-f
    (foreign-procedure "dispatch_async_f" (void* void* void*) void))

  (define %dispatch-after-f
    (foreign-procedure "dispatch_after_f"
                       (unsigned-64 void* void* void*) void))

  (define %dispatch-time
    (foreign-procedure "dispatch_time" (unsigned-64 integer-64) unsigned-64))

  ;; The GCD main queue is a global struct exported by libdispatch
  ;; (`_dispatch_main_q`). `foreign-entry` gives us the symbol's address,
  ;; which is what `dispatch_get_main_queue()` (a macro) returns.
  (define main-queue (foreign-entry "_dispatch_main_q"))

  ;; Thunk registry — background threads register a thunk under an
  ;; integer id; the GCD callback retrieves the thunk on the main thread.
  (define %next-thunk-id 0)
  (define %thunk-registry (make-eqv-hashtable))

  (define (%register-thunk! thunk)
    (let ([id %next-thunk-id])
      (set! %next-thunk-id (+ id 1))
      (hashtable-set! %thunk-registry id thunk)
      id))

  ;; The dispatch callback. Locked against GC so the C side can keep its
  ;; function pointer indefinitely.
  (define %dispatch-callback-code
    (foreign-callable
      (lambda (context)
        (let ([thunk (hashtable-ref %thunk-registry context #f)])
          (when thunk
            (hashtable-delete! %thunk-registry context)
            (guard (c [#t
                       (let ([p (current-error-port)])
                         (display "[chez cocoa] main-thread thunk raised: "
                                  p)
                         (display-condition c p)
                         (newline p))])
              (thunk)))))
      (void*) void))

  (define %dispatch-callback-locked
    (begin (lock-object %dispatch-callback-code) #t))

  (define %dispatch-callback-fp
    (foreign-callable-entry-point %dispatch-callback-code))

  (define (on-main-thread?)
    (= 1 (%pthread-main-np)))

  (define (call-on-main-thread thunk)
    (cond
      [(on-main-thread?) (thunk)]
      [else
       (let ([id (%register-thunk! thunk)])
         (%dispatch-async-f main-queue id %dispatch-callback-fp))]))

  (define (call-on-main-thread-after seconds thunk)
    (let* ([id        (%register-thunk! thunk)]
           [delay-ns  (exact (round (* seconds 1e9)))]
           [when-time (%dispatch-time 0 delay-ns)])
      (%dispatch-after-f when-time main-queue id %dispatch-callback-fp)))

  ;; --- NSView helpers ------------------------------------------------
  ;;
  ;; Generated wrappers emit only methods declared on a class — inherited
  ;; ones go here so any NSView subclass can use them without raw FFI.

  (define %msg-set-autoresizing-mask
    (foreign-procedure "objc_msgSend" (void* void* unsigned-64) void))

  (define sel-set-autoresizing-mask
    (sel-register "setAutoresizingMask:"))

  (define (set-autoresizing-mask! view mask)
    (%msg-set-autoresizing-mask (coerce-arg view) sel-set-autoresizing-mask mask))

  ;; --- NSEvent helpers -----------------------------------------------
  ;;
  ;; Dynamic-subclass IMPs receive their NSEvent arg as a raw pointer;
  ;; the generated nsevent.sls can't be used directly today (one of its
  ;; method/class-method names collides). Until that's fixed, app code
  ;; reaches for these.

  (define sel-location-in-window
    (sel-register "locationInWindow"))

  (define (nsevent-location-in-window evt)
    (let ([buf (make-ftype-pointer NSPoint (foreign-alloc (ftype-sizeof NSPoint)))])
      (%msg-point buf (coerce-arg evt) sel-location-in-window)
      buf)))
