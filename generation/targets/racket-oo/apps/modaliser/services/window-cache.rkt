#lang racket/base
;; services/window-cache.rkt — Cross-Space window tracking and focus history
;;
;; Wraps window-manager.rkt's raw AX enumeration with:
;;   1. Focus history (most-recently-focused app first)
;;   2. Cross-Space caching (windows from other Spaces persist)
;;   3. Alt-Tab ordering (current app last, previous app first)
;;
;; Notification observers for app activation/termination are wired
;; in Phase 8 via start-window-cache!. Until then, record-focus-change!
;; can be called manually.
;;
;; Public API:
;;   (list-windows-cached)             — focus-ordered window list
;;   (record-focus-change! pid)        — update focus history
;;   (remove-app-from-cache! pid)      — prune terminated app
;;   (start-window-cache!)             — start observing (Phase 8)

(require "../bindings/runtime/objc-interop.rkt"
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/generated/oo/appkit/nsworkspace.rkt"
         "../bindings/generated/oo/appkit/nsrunningapplication.rkt"
         "../ffi/accessibility.rkt"
         "window-manager.rkt")

(provide list-windows-cached
         record-focus-change!
         remove-app-from-cache!
         start-window-cache!)

;; ─── Constants ──────────────────────────────────────────────────

(define NSApplicationActivationPolicyRegular 0)

;; ─── State ──────────────────────────────────────────────────────

;; Focus history: list of PIDs, most recently focused first.
(define focus-history '())

;; Other-Space cache: hash of "pid:title" → window alist.
(define other-space-cache (make-hash))

;; ─── Focus History ──────────────────────────────────────────────

(define (record-focus-change! pid)
  (set! focus-history
    (cons pid (filter (lambda (p) (not (= p pid))) focus-history))))

(define (remove-app-from-cache! pid)
  ;; Remove from focus history
  (set! focus-history
    (filter (lambda (p) (not (= p pid))) focus-history))
  ;; Remove from other-Space cache
  (for ([key (in-hash-keys other-space-cache)])
    (define cached (hash-ref other-space-cache key))
    (when (= (cdr (assoc 'ownerPid cached)) pid)
      (hash-remove! other-space-cache key))))

(define (focus-rank pid)
  (let loop ([history focus-history] [rank 0])
    (cond
      [(null? history) 999999]
      [(= (car history) pid) rank]
      [else (loop (cdr history) (+ rank 1))])))

;; ─── Cache Key ──────────────────────────────────────────────────

(define (cache-key window-alist)
  (format "~a:~a"
    (cdr (assoc 'ownerPid window-alist))
    (cdr (assoc 'text window-alist))))

;; ─── list-windows-cached ────────────────────────────────────────
;; Full window enumeration with cross-Space caching and focus ordering.

(define (list-windows-cached)
  ;; Get current running PIDs for pruning
  (define ws (nsworkspace-shared-workspace))
  (define apps (nsworkspace-running-applications ws))
  (define app-count (tell #:type _long (coerce-arg apps) count))
  (define running-pids (make-hasheqv))
  (for ([i (in-range app-count)])
    (define ra (tell (coerce-arg apps) objectAtIndex: #:type _long i))
    (define pid (tell #:type _int32 ra processIdentifier))
    (hash-set! running-pids pid #t))

  ;; Prune cache and focus history for terminated apps
  (for ([key (in-hash-keys other-space-cache)])
    (define cached (hash-ref other-space-cache key))
    (unless (hash-ref running-pids (cdr (assoc 'ownerPid cached)) #f)
      (hash-remove! other-space-cache key)))
  (set! focus-history
    (filter (lambda (p) (hash-ref running-pids p #f)) focus-history))

  ;; Phase 1: Fresh AX enumeration (list-windows from window-manager.rkt)
  (define current-windows (list-windows))
  (define current-pids (make-hasheqv))

  ;; Track which PIDs have windows on the current Space
  (for ([w current-windows])
    (define wid (cdr (assoc 'windowId w)))
    (when (and wid (> wid 0))
      (define pid (cdr (assoc 'ownerPid w)))
      (hash-set! current-pids pid #t)
      ;; Update cache with current state
      (hash-set! other-space-cache (cache-key w) w)))

  ;; Clear stale cache entries for PIDs seen on current Space
  ;; (AX is authoritative for apps on this Space)
  (for ([key (in-hash-keys other-space-cache)])
    (define cached (hash-ref other-space-cache key))
    (define pid (cdr (assoc 'ownerPid cached)))
    (when (hash-ref current-pids pid #f)
      ;; Only keep if it's still in current windows
      (unless (member key (map cache-key current-windows))
        (hash-remove! other-space-cache key))))

  ;; Phase 2: Add cached windows from other Spaces
  ;; (PIDs not seen in current AX enumeration, one entry per PID)
  (define other-pids-seen (make-hasheqv))
  (define other-windows '())
  (for ([(key info) (in-hash other-space-cache)])
    (define pid (cdr (assoc 'ownerPid info)))
    (unless (or (hash-ref current-pids pid #f)
                (hash-ref other-pids-seen pid #f))
      (hash-set! other-pids-seen pid #t)
      (set! other-windows (cons info other-windows))))

  ;; Combine all windows
  (define all-windows (append current-windows other-windows))

  ;; Sort by focus recency.
  ;; Alt-Tab behavior: current (switching-from) app goes to end.
  (define switching-from-pid
    (let loop ([h focus-history])
      (if (null? h) #f (car h))))

  (sort all-windows
    (lambda (a b)
      (define pid-a (cdr (assoc 'ownerPid a)))
      (define pid-b (cdr (assoc 'ownerPid b)))
      (define a-is-current (and switching-from-pid (= pid-a switching-from-pid)))
      (define b-is-current (and switching-from-pid (= pid-b switching-from-pid)))
      (cond
        ;; Current app goes to end
        [(and a-is-current (not b-is-current)) #f]
        [(and b-is-current (not a-is-current)) #t]
        ;; Otherwise sort by focus rank (lower = more recent)
        [else (< (focus-rank pid-a) (focus-rank pid-b))]))))

;; ─── start-window-cache! ────────────────────────────────────────
;; Wires up NSWorkspace notification observers for app activation
;; and termination. Called once during app bootstrap (Phase 8).
;; For now, seed focus history with the frontmost app.

(define (start-window-cache!)
  (define ws (nsworkspace-shared-workspace))
  (define front (nsworkspace-frontmost-application ws))
  (when front
    (record-focus-change!
     (nsrunningapplication-process-identifier front))))
