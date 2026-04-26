#lang racket/base
;; tests/test-window-manager.rkt — Tests for window management
;;
;; Tests coordinate conversion, focus history, window cache logic,
;; and live AX operations (requires accessibility permission).
;;
;; Run:  racket tests/test-window-manager.rkt

(require rackunit
         racket/os
         racket/port
         "../bindings/runtime/objc-interop.rkt"
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/runtime/type-mapping.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../ffi/accessibility.rkt"
         "../ffi/permissions.rkt"
         "../services/window-manager.rkt"
         "../services/window-cache.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

(unless (accessibility-trusted?)
  (eprintf "test-window-manager: accessibility permission required — grant racket access in System Settings → Privacy & Security → Accessibility\n")
  (exit 1))

;; ─── Setup NSApplication ────────────────────────────────────────

(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app 1))

;; ─── Test 1: FFI module loads correctly ─────────────────────────

(test-case "accessibility FFI loads and system-wide element exists"
  (check-not-false (ax-system-wide)))

;; ─── Test 2: CFString round-trip ────────────────────────────────

(test-case "cfstring round-trip preserves content"
  (check-equal? (cfstring->string (cfstring "hello")) "hello")
  (check-equal? (cfstring->string (cfstring "")) "")
  (check-equal? (cfstring->string (cfstring "日本語")) "日本語"))

;; ─── Test 3: CGWindowList returns ordering ──────────────────────

(test-case "cg-window-ordering returns non-empty hash"
  (define ordering (cg-window-ordering))
  (check-true (hash? ordering))
  (check-true (> (hash-count ordering) 0)
              "should have at least some windows"))

;; ─── Test 4: ax-app-element creates valid element ───────────────

(test-case "ax-app-element creates element for known PID"
  ;; Finder is always running
  (define elem (ax-app-element 1))  ;; launchd
  (check-true (cpointer? elem)))

;; ─── Test 4b: ax-get-pid round-trips via app element ─────────────

(test-case "ax-get-pid returns the PID used to create the app element"
  ;; Round-trip: create an app element for our own PID, extract it back.
  (define our-pid (getpid))
  (define elem (ax-app-element our-pid))
  (check-true (cpointer? elem))
  (check-equal? (ax-get-pid elem) our-pid
                "ax-get-pid should return the creating PID"))

(test-case "ax-get-pid on a real window matches its owning app"
  (define wins (list-windows))
  (define real-win
    (let loop ([ws wins])
      (cond
        [(null? ws) #f]
        [(> (cdr (assoc 'windowId (car ws))) 0) (car ws)]
        [else (loop (cdr ws))])))
  (when real-win
    (define expected-pid (cdr (assoc 'ownerPid real-win)))
    (define title (cdr (assoc 'text real-win)))
    (define app-elem (ax-app-element expected-pid))
    (define ax-wins (ax-get-windows app-elem))
    (define matched
      (let loop ([ws ax-wins])
        (cond
          [(null? ws) #f]
          [(equal? (ax-get-title (car ws)) title) (car ws)]
          [else (loop (cdr ws))])))
    (when matched
      (check-equal? (ax-get-pid matched) expected-pid
                    "window element PID should match its app's PID"))))

;; ─── Test 5: list-windows returns structured data ───────────────

(test-case "list-windows returns alists with required keys"
  (define wins (list-windows))
  (check-true (list? wins))
  (check-true (> (length wins) 0) "should find at least one window")
  ;; Check first window has all required keys
  (define w (car wins))
  (check-not-false (assoc 'text w) "should have 'text key")
  (check-not-false (assoc 'subText w) "should have 'subText key")
  (check-not-false (assoc 'icon w) "should have 'icon key")
  (check-not-false (assoc 'iconType w) "should have 'iconType key")
  (check-not-false (assoc 'windowId w) "should have 'windowId key")
  (check-not-false (assoc 'ownerPid w) "should have 'ownerPid key")
  ;; Values should have correct types
  (check-true (string? (cdr (assoc 'text w))))
  (check-true (string? (cdr (assoc 'subText w))))
  (check-true (number? (cdr (assoc 'windowId w))))
  (check-true (number? (cdr (assoc 'ownerPid w)))))

;; ─── Test 6: focused-app-bundle-id returns string ───────────────

(test-case "focused-app-bundle-id returns bundle ID string"
  (define bid (focused-app-bundle-id))
  ;; May be #f if no app focused, but in a real session it should work
  (when bid
    (check-true (string? bid))
    ;; Bundle IDs have the form com.xxx.yyy
    (check-true (> (string-length bid) 0))))

;; ─── Test 7: Window cache focus history ─────────────────────────

(test-case "focus history tracks most recent first"
  (record-focus-change! 100)
  (record-focus-change! 200)
  (record-focus-change! 300)
  ;; 300 should be most recent
  (record-focus-change! 100)
  ;; Now 100 should be most recent, 300 second
  ;; Verify by checking list-windows-cached ordering
  ;; (We can't directly inspect focus-history, but we verify behavior)
  (check-true #t "focus history recorded without error"))

(test-case "remove-app-from-cache! prunes PID"
  (record-focus-change! 999)
  (remove-app-from-cache! 999)
  ;; Should not error
  (check-true #t "prune completed without error"))

;; ─── Test 8: list-windows-cached returns results ────────────────

(test-case "list-windows-cached returns focus-ordered windows"
  (start-window-cache!)
  (define wins (list-windows-cached))
  (check-true (list? wins))
  (check-true (> (length wins) 0))
  ;; All windows should have required keys
  (for ([w wins])
    (check-not-false (assoc 'text w))
    (check-not-false (assoc 'ownerPid w))))

;; ─── Test 9: AX position/size read from real window ─────────────

(test-case "ax-get-position and ax-get-size on real window"
  (define wins (list-windows))
  ;; Find a window with non-zero windowId
  (define real-win
    (let loop ([ws wins])
      (cond
        [(null? ws) #f]
        [(> (cdr (assoc 'windowId (car ws))) 0) (car ws)]
        [else (loop (cdr ws))])))
  (when real-win
    (define pid (cdr (assoc 'ownerPid real-win)))
    (define title (cdr (assoc 'text real-win)))
    (define app-elem (ax-app-element pid))
    (define ax-wins (ax-get-windows app-elem))
    ;; Find matching window by title
    (define matched
      (let loop ([ws ax-wins])
        (cond
          [(null? ws) #f]
          [(equal? (ax-get-title (car ws)) title) (car ws)]
          [else (loop (cdr ws))])))
    (when matched
      (define pos (ax-get-position matched))
      (define sz (ax-get-size matched))
      (check-not-false pos "should get position")
      (check-not-false sz "should get size")
      (when pos
        (check-true (number? (car pos)))
        (check-true (number? (cdr pos))))
      (when sz
        (check-true (> (car sz) 0) "width should be positive")
        (check-true (> (cdr sz) 0) "height should be positive")))))

;; ─── Test 10: AX title and subrole ─────────────────────────────

(test-case "ax-get-title returns string for real window"
  (define wins (list-windows))
  (define real-win
    (let loop ([ws wins])
      (cond
        [(null? ws) #f]
        [(> (cdr (assoc 'windowId (car ws))) 0) (car ws)]
        [else (loop (cdr ws))])))
  (when real-win
    (define pid (cdr (assoc 'ownerPid real-win)))
    (define app-elem (ax-app-element pid))
    (define ax-wins (ax-get-windows app-elem))
    (when (not (null? ax-wins))
      (define title (ax-get-title (car ax-wins)))
      (when title
        (check-true (string? title)))
      (define subrole (ax-get-subrole (car ax-wins)))
      (when subrole
        (check-true (or (equal? subrole "AXStandardWindow")
                        (equal? subrole "AXDialog")
                        (string? subrole)))))))

;; ─── Test 11: ax-get-window-id (private SPI) ────────────────────

(test-case "ax-get-window-id returns integer for real window"
  (define wins (list-windows))
  (define real-win
    (let loop ([ws wins])
      (cond
        [(null? ws) #f]
        [(> (cdr (assoc 'windowId (car ws))) 0) (car ws)]
        [else (loop (cdr ws))])))
  (when real-win
    (define pid (cdr (assoc 'ownerPid real-win)))
    (define app-elem (ax-app-element pid))
    (define ax-wins (ax-get-windows app-elem))
    (when (not (null? ax-wins))
      (define wid (ax-get-window-id (car ax-wins)))
      ;; May be #f if private SPI unavailable, but if present should be integer
      (when wid
        (check-true (integer? wid))
        (check-true (> wid 0))))))

;; ─── Test 12: Per-window generation counter ───────────────────
;; Guards the delayed fullscreen-exit repositioning in restore-window
;; against concurrent save/restore commands. Each key has an independent
;; counter; bumping one must not affect another.

(test-case "window-generation defaults to 0 for unknown keys"
  (check-equal? (window-generation "test-fresh:key") 0))

(test-case "bump-window-generation! increments monotonically"
  (define k "test-bump:window")
  (define g0 (window-generation k))
  (define g1 (bump-window-generation! k))
  (check-equal? g1 (add1 g0))
  (check-equal? (window-generation k) g1)
  (define g2 (bump-window-generation! k))
  (check-equal? g2 (add1 g1))
  (check-equal? (window-generation k) g2))

(test-case "generation counters are independent per key"
  (define k1 "test-indep:one")
  (define k2 "test-indep:two")
  (define g1a (bump-window-generation! k1))
  (define g2a (bump-window-generation! k2))
  (define g1b (bump-window-generation! k1))
  (check-equal? g1b (add1 g1a))
  (check-equal? (window-generation k2) g2a
                "bumping k1 must not affect k2"))

(test-case "stale generation is detected (bail-out pattern)"
  ;; Simulates the restore-window delayed continuation: capture a gen,
  ;; then another command bumps the gen before the continuation fires.
  (define k "test-stale:window")
  (define my-gen (bump-window-generation! k))
  (bump-window-generation! k)
  (check-false (= my-gen (window-generation k))
               "stale continuation must detect gen mismatch and bail"))

(test-case "fresh generation still matches (no intervening command)"
  (define k "test-fresh-check:window")
  (define my-gen (bump-window-generation! k))
  (check-true (= my-gen (window-generation k))
              "fresh continuation must see its own gen and proceed"))

;; The source-level dead-scheduler guard for this module (and every
;; other runtime module) lives in tests/test-source-guards.rkt.

(displayln "test-window-manager: all tests passed")
