#lang racket/base
;; services/window-manager.rkt — Window manipulation via Accessibility API
;;
;; High-level window operations: list, focus, center, move (fractional),
;; toggle fullscreen, restore. Uses ffi/accessibility.rkt for low-level AX.
;;
;; Coordinate system: AX uses top-left origin (Y down).
;; Cocoa (NSScreen) uses bottom-left origin (Y up).
;; All window position operations work in AX coordinates.
;; Conversion: axY = primaryScreenHeight - cocoaY - height.
;;
;; Public API:
;;   (list-windows)                    — list visible windows as alists
;;   (focus-window choice)             — focus window from list-windows alist
;;   (center-window)                   — center focused window on screen
;;   (move-window x y width height)    — fractional positioning (0.0–1.0)
;;   (toggle-fullscreen)               — toggle fullscreen on focused window
;;   (restore-window)                  — restore to saved frame
;;   (focused-app-bundle-id)           — bundle ID of frontmost app

(require "../bindings/runtime/objc-interop.rkt"
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/runtime/type-mapping.rkt"
         "../bindings/generated/oo/appkit/nsrunningapplication.rkt"
         "../bindings/generated/oo/appkit/nsworkspace.rkt"
         "../lib/events.rkt"
         "../ffi/accessibility.rkt"
         "../ffi/main-thread.rkt")

(provide list-windows
         focus-window
         center-window
         move-window
         toggle-fullscreen
         restore-window
         focused-app-bundle-id
         ;; Exposed for tests
         window-cache-key
         bump-window-generation!
         window-generation)

;; ─── Constants ──────────────────────────────────────────────────

(define NSApplicationActivationPolicyRegular 0)
(define NSApplicationActivationOptionActivateApp 1)  ; 1 << 0

;; Our own bundle ID — exclude from window lists
(define modaliser-bundle-id "dev.antony.Modaliser-Racket")

;; ─── Screen Helpers ─────────────────────────────────────────────
;; NSScreen.visibleFrame is in Cocoa coordinates (bottom-left origin).
;; AXUIElement uses screen coordinates (top-left origin).
;; Convert via: axY = primaryHeight - cocoaY - height.

(import-class NSScreen)

(define (primary-screen-height)
  (define screens (tell NSScreen screens))
  (define count (tell #:type _long screens count))
  (if (> count 0)
      (let* ([primary (tell screens objectAtIndex: #:type _long 0)]
             [frame (tell #:type _NSRect primary frame)])
        (NSSize-height (NSRect-size frame)))
      0.0))

;; Returns AX-coordinate visible frame as (list x y w h) for a screen.
(define (ax-visible-frame screen)
  (define primary-h (primary-screen-height))
  (define vf (tell #:type _NSRect screen visibleFrame))
  (define vf-x (NSPoint-x (NSRect-origin vf)))
  (define vf-y (NSPoint-y (NSRect-origin vf)))
  (define vf-w (NSSize-width (NSRect-size vf)))
  (define vf-h (NSSize-height (NSRect-size vf)))
  ;; Cocoa → AX: flip Y
  (list vf-x
        (- primary-h vf-y vf-h)
        vf-w
        vf-h))

;; Find the screen containing a point (AX coordinates).
;; Returns NSScreen or main screen as fallback.
(define (screen-containing-ax-point ax-x ax-y)
  (define primary-h (primary-screen-height))
  (define screens (tell NSScreen screens))
  (define count (tell #:type _long screens count))
  (or (let loop ([i 0])
        (if (>= i count)
            #f
            (let* ([screen (tell screens objectAtIndex: #:type _long i)]
                   [frame (tell #:type _NSRect screen frame)]
                   [f-x (NSPoint-x (NSRect-origin frame))]
                   [f-y (NSPoint-y (NSRect-origin frame))]
                   [f-w (NSSize-width (NSRect-size frame))]
                   [f-h (NSSize-height (NSRect-size frame))]
                   ;; Convert frame to AX coordinates
                   [ax-f-y (- primary-h f-y f-h)])
              (if (and (>= ax-x f-x) (< ax-x (+ f-x f-w))
                       (>= ax-y ax-f-y) (< ax-y (+ ax-f-y f-h)))
                  screen
                  (loop (+ i 1))))))
      (tell NSScreen mainScreen)))

;; ─── Focused Window ─────────────────────────────────────────────
;; Returns (cons window-element (list x y w h)) or #f.

(define (focused-window-and-frame)
  (define app-elem (ax-get-focused-app))
  (and app-elem
       (let ([win (ax-get-focused-window app-elem)])
         (and win
              (let ([pos (ax-get-position win)]
                    [sz (ax-get-size win)])
                (and pos sz
                     (cons win (list (car pos) (cdr pos)
                                     (car sz) (cdr sz)))))))))

;; ─── Frame Save/Restore Cache ───────────────────────────────────
;; Key: "pid:title", Value: (list x y w h)

(define saved-frames (make-hash))

(define (window-cache-key pid title)
  (format "~a:~a" pid (or title "")))

;; Per-window generation counters. Bumped by any save/restore, used by
;; the delayed fullscreen-restore continuation to bail if another command
;; touched the same window while we were waiting on the fullscreen-exit
;; animation. Same pattern as chooser-search-generation / overlay timer.
(define window-generations (make-hash))

(define (window-generation key)
  (hash-ref window-generations key 0))

(define (bump-window-generation! key)
  (define next (add1 (window-generation key)))
  (hash-set! window-generations key next)
  next)

(define (save-window-frame! win)
  (define pos (ax-get-position win))
  (define sz (ax-get-size win))
  (define title (ax-get-title win))
  (define pid (ax-get-pid win))
  (when (and pos sz pid)
    (define key (window-cache-key pid title))
    (bump-window-generation! key)
    (hash-set! saved-frames key
      (list (car pos) (cdr pos) (car sz) (cdr sz)))))

;; ─── Focused App Bundle ID ──────────────────────────────────────

(define (focused-app-bundle-id)
  (define ws (nsworkspace-shared-workspace))
  (define front (nsworkspace-frontmost-application ws))
  (and front
       (let ([bid (nsrunningapplication-bundle-identifier front)])
         (and bid
              (tell #:type _string (coerce-arg bid) UTF8String)))))

;; ─── NSString Helper ────────────────────────────────────────────

(define (nsstring->string obj)
  (and obj
       (not (equal? obj #f))
       (tell #:type _string (coerce-arg obj) UTF8String)))

;; ─── list-windows ───────────────────────────────────────────────
;; Enumerates visible windows across all running apps.
;; Phase 1: AX enumeration (current Space windows).
;; Phase 2: Running apps without windows (other Spaces).
;; Returns: list of alists with keys: text, subText, icon, iconType,
;;          windowId, ownerPid.

(define (list-windows)
  (define ws (nsworkspace-shared-workspace))
  (define apps (nsworkspace-running-applications ws))
  (define app-count (tell #:type _long (coerce-arg apps) count))
  (define ordering (cg-window-ordering))
  (define seen-pids (make-hasheqv))
  (define windows '())

  ;; Phase 1: AX enumeration — current Space windows
  (for ([i (in-range app-count)])
    (define ra (tell (coerce-arg apps) objectAtIndex: #:type _long i))
    (define policy (tell #:type _uint64 ra activationPolicy))
    (when (= policy NSApplicationActivationPolicyRegular)
      (define pid (tell #:type _int32 ra processIdentifier))
      (define bid-obj (tell ra bundleIdentifier))
      (define bid (and bid-obj (tell #:type _string bid-obj UTF8String)))
      (define app-name-obj (tell ra localizedName))
      (define app-name (and app-name-obj (tell #:type _string app-name-obj UTF8String)))

      ;; Skip Modaliser itself
      (unless (and bid (equal? bid modaliser-bundle-id))
        (define app-elem (ax-app-element pid))
        (define wins (ax-get-windows app-elem))
        (for ([w wins])
          (define subrole (ax-get-subrole w))
          (define minimized (ax-is-minimized? w))
          (define title (ax-get-title w))
          (when (and subrole
                     (or (equal? subrole "AXStandardWindow")
                         (equal? subrole "AXDialog"))
                     (not minimized)
                     title
                     (not (equal? title "")))
            (hash-set! seen-pids pid #t)
            (define wid (or (ax-get-window-id w) 0))
            (define pos (ax-get-position w))
            (define sz (ax-get-size w))
            ;; Sort key: window z-order (lower = more front)
            (define z-order (hash-ref ordering wid 999999))
            (set! windows
              (cons (list (cons 'text title)
                          (cons 'subText (or app-name ""))
                          (cons 'icon (or bid ""))
                          (cons 'iconType "bundleId")
                          (cons 'windowId wid)
                          (cons 'ownerPid pid)
                          (cons '_z-order z-order))
                    windows))))
        ;; Release CF objects (Create/Copy rule + CFRetain in ax-get-windows)
        (for ([w wins]) (cf-release! w))
        (cf-release! app-elem))))

  ;; Phase 2: apps without visible windows (other Spaces)
  (for ([i (in-range app-count)])
    (define ra (tell (coerce-arg apps) objectAtIndex: #:type _long i))
    (define policy (tell #:type _uint64 ra activationPolicy))
    (when (= policy NSApplicationActivationPolicyRegular)
      (define pid (tell #:type _int32 ra processIdentifier))
      (define hidden (tell #:type _bool ra isHidden))
      (unless (or (hash-ref seen-pids pid #f) hidden)
        (define bid-obj (tell ra bundleIdentifier))
        (define bid (and bid-obj (tell #:type _string bid-obj UTF8String)))
        (define app-name-obj (tell ra localizedName))
        (define app-name (and app-name-obj (tell #:type _string app-name-obj UTF8String)))
        (unless (or (and bid (equal? bid modaliser-bundle-id))
                    (not app-name)
                    (equal? app-name ""))
          (set! windows
            (cons (list (cons 'text app-name)
                        (cons 'subText app-name)
                        (cons 'icon (or bid ""))
                        (cons 'iconType "bundleId")
                        (cons 'windowId 0)
                        (cons 'ownerPid pid)
                        (cons '_z-order 999999))
                  windows))))))

  ;; Sort by z-order (frontmost first), strip internal key
  (define sorted
    (sort windows < #:key (lambda (w) (cdr (assoc '_z-order w)))))
  (map (lambda (w)
         (filter (lambda (pair) (not (eq? (car pair) '_z-order))) w))
       sorted))

;; ─── focus-window ───────────────────────────────────────────────
;; Takes an alist from list-windows. If windowId=0, activates app
;; (switches Space). Otherwise, focuses the specific window.

(define (focus-window choice)
  (define pid (cdr (or (assoc 'ownerPid choice) '(ownerPid . #f))))
  (define wid (cdr (or (assoc 'windowId choice) '(windowId . 0))))
  (define title (cdr (or (assoc 'text choice) '(text . ""))))
  (when pid
    (log-event 'window 'focus 'pid pid 'title title))
  (when pid
    (if (or (not wid) (= wid 0))
        ;; Other Space — just activate the app
        (activate-app! pid)
        ;; Current Space — find and focus the exact window
        (let* ([app-elem (ax-app-element pid)]
               [wins (ax-get-windows app-elem)])
          (for ([w wins])
            (let ([w-title (ax-get-title w)])
              (when (and w-title (equal? w-title title))
                ;; Set main + focused + raise (matches Swift original)
                (ax-set-attribute! w kAXMainAttribute kCFBooleanTrue)
                (ax-set-attribute! w kAXFocusedAttribute kCFBooleanTrue)
                (ax-raise! w))))
          ;; Release CF objects (Create rule + CFRetain in ax-get-windows)
          (for ([w wins]) (cf-release! w))
          (cf-release! app-elem)
          (activate-app! pid)))))

(define (activate-app! pid)
  (define ra (nsrunningapplication-running-application-with-process-identifier pid))
  (when ra
    (nsrunningapplication-activate-with-options ra NSApplicationActivationOptionActivateApp)))

;; ─── center-window ──────────────────────────────────────────────

(define (center-window)
  (define wf (focused-window-and-frame))
  (when wf
    (define win (car wf))
    (define frame (cdr wf))  ;; (x y w h)
    (define win-w (caddr frame))
    (define win-h (cadddr frame))
    ;; Find which screen contains the window center
    (define cx (+ (car frame) (/ win-w 2.0)))
    (define cy (+ (cadr frame) (/ win-h 2.0)))
    (define screen (screen-containing-ax-point cx cy))
    (when screen
      (define vf (ax-visible-frame screen))  ;; (x y w h)
      (define new-x (+ (car vf) (/ (- (caddr vf) win-w) 2.0)))
      (define new-y (+ (cadr vf) (/ (- (cadddr vf) win-h) 2.0)))
      (save-window-frame! win)
      (ax-set-position! win new-x new-y))))

;; ─── move-window ────────────────────────────────────────────────
;; x, y, width, height are unit fractions (0.0–1.0) of visible screen.
;; Accepts exact rationals (e.g., 1/3) — converted to inexact.

(define (move-window x y width height)
  (define wf (focused-window-and-frame))
  (when wf
    (define win (car wf))
    (define frame (cdr wf))
    ;; Convert to inexact floats
    (define fx (exact->inexact x))
    (define fy (exact->inexact y))
    (define fw (exact->inexact width))
    (define fh (exact->inexact height))
    ;; Clamp to prevent overflow past screen edge
    (define cw (min fw (- 1.0 fx)))
    (define ch (min fh (- 1.0 fy)))
    ;; Find containing screen
    (define cx (+ (car frame) (/ (caddr frame) 2.0)))
    (define cy (+ (cadr frame) (/ (cadddr frame) 2.0)))
    (define screen (screen-containing-ax-point cx cy))
    (when screen
      (define vf (ax-visible-frame screen))  ;; (x y w h)
      (define vf-x (car vf))
      (define vf-y (cadr vf))
      (define vf-w (caddr vf))
      (define vf-h (cadddr vf))
      (define new-x (+ vf-x (* vf-w fx)))
      (define new-y (+ vf-y (* vf-h fy)))
      (define new-w (* vf-w cw))
      (define new-h (* vf-h ch))
      (save-window-frame! win)
      ;; Set position first, then size (some apps need this order)
      (ax-set-position! win new-x new-y)
      (ax-set-size! win new-w new-h)
      (log-event 'window 'move
                 'x (exact->inexact new-x) 'y (exact->inexact new-y)
                 'w (exact->inexact new-w) 'h (exact->inexact new-h)))))

;; ─── toggle-fullscreen ──────────────────────────────────────────

(define (toggle-fullscreen)
  (define wf (focused-window-and-frame))
  (when wf
    (define win (car wf))
    (save-window-frame! win)
    (define fs (ax-is-fullscreen? win))
    (ax-set-fullscreen! win (not fs))))

;; ─── restore-window ─────────────────────────────────────────────
;; Restores window to previously saved frame. If window is fullscreen,
;; exits fullscreen first and waits for the animation to complete.
;;
;; The delayed repositioning is dispatched via call-on-main-thread-after
;; (GCD), not via a Racket green-thread sleep — green threads never fire
;; while the Cocoa run loop blocks the place main thread. A per-window
;; generation counter lets the continuation bail if another save/restore/
;; fullscreen command touched the same window during the animation wait.

(define fullscreen-exit-delay 0.5)

(define (restore-window)
  (define wf (focused-window-and-frame))
  (when wf
    (define win (car wf))
    (define title (ax-get-title win))
    (define pid (ax-get-pid win))
    (when pid
      (define key (window-cache-key pid title))
      (define saved (hash-ref saved-frames key #f))
      (when saved
        (define fs (ax-is-fullscreen? win))
        (cond
          [fs
           ;; Exit fullscreen, then reposition after the animation.
           (ax-set-fullscreen! win #f)
           (define my-gen (bump-window-generation! key))
           (call-on-main-thread-after fullscreen-exit-delay
             (lambda ()
               (when (= my-gen (window-generation key))
                 (ax-set-position! win (car saved) (cadr saved))
                 (ax-set-size! win (caddr saved) (cadddr saved)))))]
          [else
           ;; Not fullscreen — restore immediately.
           (ax-set-position! win (car saved) (cadr saved))
           (ax-set-size! win (caddr saved) (cadddr saved))])))))
