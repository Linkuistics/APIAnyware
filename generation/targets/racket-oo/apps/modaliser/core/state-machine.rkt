#lang racket/base
;; state-machine.rkt — Modal navigation state machine
;;
;; Manages command tree registration, lookup, and modal navigation.
;; Trees are stored in a hash table keyed by scope string (e.g., "global").
;; Navigation is side-effecting: modal-handle-key directly executes actions,
;; updates the overlay via hooks, and opens the chooser.
;;
;; This module uses hooks for keyboard registration and overlay updates
;; so it can be loaded independently from event-dispatch.rkt and ui/.

(require racket/string
         "../ffi/main-thread.rkt"
         "../lib/events.rkt")

(provide ;; Tree registry
         register-tree!
         lookup-tree
         clear-trees!

         ;; Node predicates
         command?
         group?
         selector?

         ;; Node accessors
         node-children
         node-key
         node-label
         node-action
         find-child

         ;; Modal state (read-only access)
         modal-active?
         modal-current-node
         modal-root-node
         modal-current-path
         modal-leader-keycode

         ;; Modal navigation
         modal-enter
         modal-exit
         modal-handle-key
         modal-step-back

         ;; Hook setters — wired by event-dispatch.rkt and ui/overlay.rkt
         set-modal-key-handler!
         set-keyboard-hooks!
         set-overlay-hooks!

         ;; Delay utility
         after-delay
         set-after-delay-handler!

         ;; Overlay delay config
         set-overlay-delay!)

;; ─── Tree Registry ──────────────────────────────────────────────

(define tree-registry (make-hash))

(define (register-tree! scope . children)
  (define scope-str (if (symbol? scope) (symbol->string scope) scope))
  (define label (if (equal? scope-str "global") "Global" scope-str))
  ;; 'scope carries the registry key so the event log can record which
  ;; tree modal mode entered without plumbing it through every call site.
  (define root (list (cons 'kind 'group)
                     (cons 'key "")
                     (cons 'label label)
                     (cons 'scope scope-str)
                     (cons 'children children)))
  (hash-set! tree-registry scope-str root))

(define (lookup-tree scope)
  (define scope-str (if (symbol? scope) (symbol->string scope) scope))
  (hash-ref tree-registry scope-str #f))

(define (clear-trees!)
  (hash-clear! tree-registry))

;; ─── Node Predicates ────────────────────────────────────────────

(define (node-kind node)
  (define entry (assoc 'kind node))
  (and entry (cdr entry)))

(define (command? node)
  (and (pair? node) (eq? (node-kind node) 'command)))

(define (group? node)
  (and (pair? node) (eq? (node-kind node) 'group)))

(define (selector? node)
  (and (pair? node) (eq? (node-kind node) 'selector)))

;; ─── Node Accessors ─────────────────────────────────────────────

(define (node-children node)
  (define entry (assoc 'children node))
  (if entry (cdr entry) '()))

(define (node-key node)
  (define entry (assoc 'key node))
  (if entry (cdr entry) ""))

(define (node-label node)
  (define entry (assoc 'label node))
  (if entry (cdr entry) ""))

(define (node-action node)
  (define entry (assoc 'action node))
  (if entry (cdr entry) #f))

(define (find-child node key)
  (let loop ([children (node-children node)])
    (cond
      [(null? children) #f]
      [(equal? (node-key (car children)) key) (car children)]
      [else (loop (cdr children))])))

;; ─── Hooks ──────────────────────────────────────────────────────
;; These are set by event-dispatch.rkt and ui/overlay.rkt to break
;; circular module dependencies.

;; Keyboard hooks (set by event-dispatch.rkt)
(define modal-key-handler-fn #f)
(define register-all-keys-fn (lambda (handler) (void)))
(define unregister-all-keys-fn (lambda () (void)))

(define (set-modal-key-handler! fn)
  (set! modal-key-handler-fn fn))

(define (set-keyboard-hooks! register-fn unregister-fn)
  (set! register-all-keys-fn register-fn)
  (set! unregister-all-keys-fn unregister-fn))

;; Overlay hooks (set by ui/overlay.rkt)
(define show-overlay-fn (lambda (root-node path) (void)))
(define update-overlay-fn (lambda (root-node path) (void)))
(define hide-overlay-fn (lambda () (void)))
(define open-chooser-fn (lambda (selector-node) (void)))
(define overlay-open-fn (lambda () #f))

(define (set-overlay-hooks! #:show show-fn
                            #:update update-fn
                            #:hide hide-fn
                            #:open-chooser open-fn
                            #:open? open?-fn)
  (set! show-overlay-fn show-fn)
  (set! update-overlay-fn update-fn)
  (set! hide-overlay-fn hide-fn)
  (set! open-chooser-fn open-fn)
  (set! overlay-open-fn open?-fn))

;; ─── Delay Utility ──────────────────────────────────────────────
;; Dispatches callback on the main thread after a delay.
;; Uses GCD (via call-on-main-thread-after) because Racket green threads
;; cannot make progress while nsapplication-run blocks the scheduler.
;;
;; The handler is indirected through a mutable variable so tests can
;; substitute a synchronous/recording stand-in (the GCD path requires a
;; running NSApplication run loop and cannot fire under unit tests).

(define after-delay-handler call-on-main-thread-after)

(define (set-after-delay-handler! handler)
  (set! after-delay-handler handler))

(define (after-delay seconds callback)
  (after-delay-handler seconds callback))

;; ─── Modal State ────────────────────────────────────────────────

(define modal-active? #f)
(define modal-current-node #f)
(define modal-root-node #f)
(define modal-current-path '())
(define modal-leader-keycode #f)
(define modal-overlay-generation 0)
(define modal-overlay-delay 1.0)

(define (set-overlay-delay! seconds)
  (set! modal-overlay-delay seconds))

;; ─── Modal Navigation ──────────────────────────────────────────

;; Show overlay immediately, cancelling pending delayed show.
(define (modal-show-overlay-now)
  (set! modal-overlay-generation (add1 modal-overlay-generation))
  (show-overlay-fn modal-root-node modal-current-path))

;; Schedule overlay to appear after delay. Generation counter
;; ensures stale callbacks are ignored.
;; Uses GCD dispatch_after (via call-on-main-thread-after) instead of
;; Racket green threads, because nsapplication-run blocks the Racket
;; scheduler — green threads cannot make progress.
(define (modal-show-overlay-delayed)
  (if (<= modal-overlay-delay 0)
      (show-overlay-fn modal-root-node modal-current-path)
      (let ()
        (set! modal-overlay-generation (add1 modal-overlay-generation))
        (define gen modal-overlay-generation)
        (after-delay modal-overlay-delay
          (lambda ()
            (when (and modal-active? (= gen modal-overlay-generation))
              (show-overlay-fn modal-root-node modal-current-path)))))))

;; Safety timeout (seconds) — auto-exit modal if still active after this.
;; Prevents keyboard lockup if the overlay fails to appear.
(define modal-safety-timeout 5)

(define (tree-scope-name tree)
  (define entry (assoc 'scope tree))
  (if entry (cdr entry) (node-label tree)))

;; Enter modal mode with the given tree and leader keycode.
(define (modal-enter tree leader-kc)
  (when tree
    (set! modal-active? #t)
    (set! modal-root-node tree)
    (set! modal-current-node tree)
    (set! modal-current-path '())
    (set! modal-leader-keycode leader-kc)
    (log-event 'modal 'enter 'tree (tree-scope-name tree))
    (when modal-key-handler-fn
      (register-all-keys-fn modal-key-handler-fn))
    (modal-show-overlay-delayed)
    ;; Safety watchdog — auto-exit if modal is still active after timeout.
    ;; Uses the generation counter so it doesn't fire if the user already
    ;; exited and re-entered modal in the meantime.
    (let ([gen modal-overlay-generation])
      (after-delay modal-safety-timeout
        (lambda ()
          (when (and modal-active? (= gen modal-overlay-generation))
            (displayln "modaliser: safety timeout — auto-exiting modal mode")
            (modal-exit 'watchdog)))))))

;; Exit modal mode. reason: 'user (default), 'watchdog, 'focus-loss.
(define (modal-exit [reason 'user])
  (when modal-active?
    (log-event 'modal 'exit 'reason reason))
  (set! modal-overlay-generation (add1 modal-overlay-generation))
  (unregister-all-keys-fn)
  (hide-overlay-fn)
  (set! modal-active? #f)
  (set! modal-current-node #f)
  (set! modal-root-node #f)
  (set! modal-current-path '())
  (set! modal-leader-keycode #f))

;; Handle a character key press while modal is active.
(define (modal-handle-key char)
  (define child (find-child modal-current-node char))
  (cond
    [(not child)
     (modal-exit)]
    [(command? child)
     (define action (node-action child))
     (modal-exit)
     (when action (action))]
    [(group? child)
     (set! modal-current-node child)
     (set! modal-current-path
       (append modal-current-path (list char)))
     (log-event 'modal 'group 'key char)
     (if (overlay-open-fn)
         (update-overlay-fn modal-root-node modal-current-path)
         (modal-show-overlay-delayed))]
    [(selector? child)
     (modal-exit)
     (open-chooser-fn child)]
    [else
     (modal-exit)]))

;; Step back one level in the navigation path.
(define (modal-step-back)
  (if (null? modal-current-path)
      (modal-exit)
      (let* ([new-path (reverse (cdr (reverse modal-current-path)))]
             [new-node (navigate-to-path modal-root-node new-path)])
        (set! modal-current-path new-path)
        (set! modal-current-node new-node)
        (update-overlay-fn modal-root-node modal-current-path))))

;; Navigate from root following a list of key strings.
(define (navigate-to-path root path)
  (if (null? path)
      root
      (let ([child (find-child root (car path))])
        (if child
            (navigate-to-path child (cdr path))
            root))))
