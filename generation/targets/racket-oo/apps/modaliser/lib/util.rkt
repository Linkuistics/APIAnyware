#lang racket/base
;; util.rkt — Utility functions for config.scm compatibility
;;
;; Provides high-level convenience functions that bridge the gap between
;; the original LispKit-based Modaliser config and the Racket reimplementation.
;; These are the functions the user's config.scm calls directly.

(require "../services/shell.rkt"
         "../services/app-scanner.rkt"
         "../ffi/cgevent-emitter.rkt"
         "../bindings/runtime/objc-interop.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/generated/oo/appkit/nsrunningapplication.rkt"
         "events.rkt")

(provide ;; App interaction
         open-url
         launch-app
         activate-app
         reveal-in-finder
         open-with
         ;; App discovery
         find-installed-apps
         ;; Keystroke emission (config-compatible signature)
         config-send-keystroke
         ;; Alist helpers
         alist-ref
         ;; String helpers
         shell-quote)

;; ─── Shell quoting ─────────────────────────────────────────────

;; (shell-quote str) → string
;; Wraps str in single quotes, escaping embedded single quotes.
;; "it's" → "'it'\\''s'"
(define (shell-quote str)
  (unless (string? str)
    (raise-argument-error 'shell-quote "string?" str))
  (string-append "'" (regexp-replace* #rx"'" str "'\\\\''") "'"))

;; ─── Alist helpers ─────────────────────────────────────────────

;; (alist-ref alist key [default]) → value or default
(define (alist-ref alist key [default #f])
  (define pair (assoc key alist))
  (if pair (cdr pair) default))

;; ─── App interaction ───────────────────────────────────────────

;; (open-url url-string) → void
;; Opens a URL with the system default handler.
(define (open-url url-string)
  (log-event 'launch 'url 'url url-string)
  (void (run-shell (string-append "/usr/bin/open " (shell-quote url-string)))))

;; (launch-app name) → void
;; Launches or focuses an app by display name.
(define (launch-app name)
  (log-event 'launch 'app 'name name)
  (void (run-shell (string-append "/usr/bin/open -a " (shell-quote name)))))

;; (emit-focus-for-bundle-id! bundle-id) → void
;; If an NSRunningApplication exists for `bundle-id`, emit the
;; `[window] focus pid=… title=…` record required by the logging
;; contract. No-op when the app isn't running yet (the caller just
;; issued an async `open`; either the app is already up — common
;; case — or it's in the middle of launching and we skip this time).
(define (emit-focus-for-bundle-id! bundle-id)
  (with-handlers ([exn:fail? (lambda (_) (void))])
    (define apps
      (nsrunningapplication-running-applications-with-bundle-identifier bundle-id))
    (when apps
      (define count (tell #:type _long (coerce-arg apps) count))
      (when (positive? count)
        (define running (tell (coerce-arg apps) objectAtIndex: #:type _long 0))
        (define pid (tell #:type _int32 running processIdentifier))
        (define name-obj (tell running localizedName))
        (define name (or (and name-obj
                              (tell #:type _string (coerce-arg name-obj) UTF8String))
                         bundle-id))
        (log-event 'window 'focus 'pid pid 'title name)))))

;; (activate-app choice) → void
;; Activates an app from a chooser result alist.
;; Tries bundleId first, falls back to path.
(define (activate-app choice)
  (define bundle-id (alist-ref choice 'bundleId))
  (define path (alist-ref choice 'path))
  (cond
    [bundle-id
     (log-event 'launch 'bundle 'id bundle-id)
     (void (run-shell (string-append "/usr/bin/open -b " (shell-quote bundle-id))))
     (emit-focus-for-bundle-id! bundle-id)]
    [path
     (log-event 'launch 'path 'path path)
     (void (run-shell (string-append "/usr/bin/open " (shell-quote path))))]
    [else (void)]))

;; (reveal-in-finder choice) → void
;; Reveals a file/app in Finder from a chooser result alist.
(define (reveal-in-finder choice)
  (define path (alist-ref choice 'path))
  (when path
    (void (run-shell (string-append "/usr/bin/open -R " (shell-quote path))))))

;; (open-with app-name file-path) → void
;; Opens a file with a specific application.
(define (open-with app-name file-path)
  (void (run-shell (string-append "/usr/bin/open -a " (shell-quote app-name)
                                  " " (shell-quote file-path)))))

;; ─── App discovery ─────────────────────────────────────────────

;; (find-installed-apps) → list of alists
;; Scans installed apps and formats for chooser display.
;; Returns alists with keys: text, subText, bundleId, path
(define (find-installed-apps)
  (define apps (scan-installed-apps))
  (for/list ([app (in-list apps)])
    (list (cons 'text (alist-ref app 'name ""))
          (cons 'subText (alist-ref app 'directory ""))
          (cons 'bundleId (alist-ref app 'bundle-id ""))
          (cons 'path (alist-ref app 'path "")))))

;; ─── Keystroke emission ────────────────────────────────────────

;; (config-send-keystroke mods key-name) → void
;; Config-compatible wrapper for send-keystroke.
;; The config uses: (send-keystroke '(cmd shift) "t")
;; The FFI emitter uses: (send-keystroke "t" numeric-flags)
;; This bridges the argument order and modifier format.
(define (config-send-keystroke mods key-name)
  (define flags (parse-modifier-symbols mods))
  (send-keystroke key-name flags))
