#lang racket/base
;; config-loader.rkt — Loads and evaluates user config.scm
;;
;; Creates a Racket namespace populated with all DSL functions, service
;; bindings, and utility functions, then evaluates the config file in it.
;; This is the Racket equivalent of the Swift Modaliser's SchemeEngine
;; which auto-imported all native libraries into LispKit's global environment.

(require racket/path
         "dsl.rkt"
         "events.rkt"
         "util.rkt"
         "../services/shell.rkt"
         "../services/pasteboard.rkt"
         "../services/window-manager.rkt"
         "../services/lifecycle.rkt"
         "../services/http.rkt"
         "web-search.rkt")

(provide load-config!
         config-path)

;; Default config location. Priority: MODALISER_CONFIG env var > the
;; canonical XDG path exported by lifecycle.rkt.
(define config-path
  (let ([override (getenv "MODALISER_CONFIG")])
    (if (and override (not (equal? override "")))
        (string->path override)
        (string->path modaliser-config-path))))

;; SECURITY NOTE: config.scm runs with full user privileges. run-shell,
;; run-shell-async, and http-get give it arbitrary code execution and network
;; access. Only load config from the user's own config directory.

;; All bindings available to config.scm.
;; Each entry is (symbol . value).
(define (config-bindings)
  (list
   ;; ── DSL ────────────────────────────────────────────
   (cons 'key key)
   (cons 'group group)
   (cons 'selector selector)
   (cons 'action action)
   (cons 'define-tree define-tree)
   (cons 'set-leader! set-leader!)
   (cons 'set-overlay-delay! set-overlay-delay!)
   (cons 'set-theme! set-theme!)

   ;; ── Keycode constants ──────────────────────────────
   (cons 'F1 F1)   (cons 'F2 F2)   (cons 'F3 F3)   (cons 'F4 F4)
   (cons 'F5 F5)   (cons 'F6 F6)   (cons 'F7 F7)   (cons 'F8 F8)
   (cons 'F9 F9)   (cons 'F10 F10) (cons 'F11 F11) (cons 'F12 F12)
   (cons 'F17 F17) (cons 'F18 F18) (cons 'F19 F19) (cons 'F20 F20)
   (cons 'ESCAPE ESCAPE) (cons 'RETURN RETURN)
   (cons 'TAB TAB) (cons 'SPACE SPACE) (cons 'DELETE DELETE)

   ;; ── App interaction ────────────────────────────────
   (cons 'open-url open-url)
   (cons 'launch-app launch-app)
   (cons 'activate-app activate-app)
   (cons 'reveal-in-finder reveal-in-finder)
   (cons 'open-with open-with)
   (cons 'find-installed-apps find-installed-apps)

   ;; ── Keystroke emission ─────────────────────────────
   ;; Config uses: (send-keystroke '(cmd) "t")
   ;; We provide the config-compatible wrapper, not the raw FFI fn.
   (cons 'send-keystroke config-send-keystroke)

   ;; ── Services ───────────────────────────────────────
   (cons 'run-shell run-shell)
   (cons 'run-shell-async run-shell-async)
   (cons 'set-clipboard! set-clipboard!)
   (cons 'get-clipboard get-clipboard)
   (cons 'list-windows list-windows)
   (cons 'focus-window focus-window)
   (cons 'move-window move-window)
   (cons 'center-window center-window)
   (cons 'toggle-fullscreen toggle-fullscreen)
   (cons 'restore-window restore-window)
   (cons 'open-settings! open-settings!)
   (cons 'http-get http-get)

   ;; ── Web search ─────────────────────────────────────
   (cons 'web-search-handler web-search-handler)
   (cons 'web-search-on-select web-search-on-select)))


;; (load-config! [path]) → void
;; Loads and evaluates the config file in a prepared namespace.
;; Reports errors to stderr without crashing the app.
(define (load-config! [path config-path])
  (cond
    [(not (file-exists? path))
     (fprintf (current-error-port) "modaliser: config not found: ~a\n" path)
     (log-event 'config 'missing 'path (path->string path))]
    [else
     (displayln (format "modaliser: loading config ~a" path))
     (log-event 'config 'load 'path (path->string path))
     (define ns (make-base-namespace))

     ;; Install all bindings into the namespace
     (for ([binding (in-list (config-bindings))])
       (namespace-set-variable-value! (car binding) (cdr binding) #t ns))

     ;; Evaluate config file
     (with-handlers
         ([exn:fail?
           (lambda (e)
             (fprintf (current-error-port)
                      "modaliser: config error: ~a\n" (exn-message e))
             (log-event 'config 'error 'message (exn-message e)))])
       (parameterize ([current-namespace ns]
                      [current-directory (let ([dir (path-only (simplify-path path))])
                                           (or dir (current-directory)))])
         (load path))
       (displayln "modaliser: config loaded successfully")
       (log-event 'config 'loaded))]))
