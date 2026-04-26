#lang racket/base
;; lifecycle.rkt — Status bar, relaunch, quit
;;
;; Sets up the system status bar item with a dropdown menu:
;;   Settings… (Cmd+,)  — opens config.scm in default editor
;;   Relaunch  (Cmd+R)  — re-exec the process
;;   Quit      (Cmd+Q)  — terminates the application

(require racket/runtime-path
         "../bindings/runtime/objc-interop.rkt"
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/runtime/delegate.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../bindings/generated/oo/appkit/nsstatusbar.rkt"
         "../bindings/generated/oo/appkit/nsstatusitem.rkt"
         "../bindings/generated/oo/appkit/nsmenu.rkt"
         "../bindings/generated/oo/appkit/nsmenuitem.rkt"
         "../bindings/generated/oo/appkit/nsimage.rkt")

(provide setup-status-bar!
         open-settings!
         relaunch!
         quit!
         modaliser-config-path)

;; Test-hooks submodule exposes the status item built by `setup-status-bar!`
;; so integration tests can inspect the menu structure without re-implementing
;; the lookup. Production callers do not need this — the status item is
;; managed by Cocoa and routed via the menu delegate.
(module+ test-hooks
  (provide current-status-item
           current-menu-handler))

;; NSVariableStatusItemLength — tells the status bar to size the item to fit
(define NSVariableStatusItemLength -1.0)

;; --- GC roots ---
;; Prevent garbage collection of objects held weakly by Cocoa.
;; If these are collected, the status item vanishes or menu clicks crash.
(define current-status-item #f)
(define current-menu-handler #f)

;; --- Status bar setup ---

(define (setup-status-bar!)
  ;; Get system status bar and create our item
  (define status-bar (nsstatusbar-system-status-bar))
  (set! current-status-item
    (nsstatusbar-status-item-with-length status-bar NSVariableStatusItemLength))

  ;; Set button icon — SF Symbol "keyboard", marked as template for dark/light mode.
  ;; Using raw `tell` for setImage: because button is NSStatusBarButton (inherits
  ;; from NSButton) and there's no generated binding for NSButton.setImage:.
  (define button (nsstatusitem-button current-status-item))
  (define icon (nsimage-image-with-system-symbol-name-accessibility-description
                "keyboard" "Modaliser"))
  (nsimage-set-template! icon #t)
  (tell (coerce-arg button) setImage: (coerce-arg icon))

  ;; Build dropdown menu
  (define menu (make-nsmenu-init-with-title "Modaliser"))

  ;; Single delegate handles all menu actions via target-action.
  ;; Each body is wrapped in with-handlers — unhandled exceptions in ObjC
  ;; delegate callbacks crash the app with no Racket stack trace.
  (set! current-menu-handler
    (make-delegate
     "settingsClicked:"
     (lambda (sender)
       (with-handlers ([exn:fail?
                        (lambda (e)
                          (eprintf "settingsClicked delegate error: ~a\n"
                                   (exn-message e)))])
         (open-settings!)))
     "relaunchClicked:"
     (lambda (sender)
       (with-handlers ([exn:fail?
                        (lambda (e)
                          (eprintf "relaunchClicked delegate error: ~a\n"
                                   (exn-message e)))])
         (relaunch!)))
     "quitClicked:"
     (lambda (sender)
       (with-handlers ([exn:fail?
                        (lambda (e)
                          (eprintf "quitClicked delegate error: ~a\n"
                                   (exn-message e)))])
         (quit!)))))

  ;; Settings…
  (define settings-item
    (make-nsmenuitem-init-with-title-action-key-equivalent
     "Settings…" "settingsClicked:" ","))
  (nsmenuitem-set-target! settings-item current-menu-handler)
  (nsmenu-add-item! menu settings-item)

  ;; ---
  (nsmenu-add-item! menu (nsmenuitem-separator-item))

  ;; Relaunch
  (define relaunch-item
    (make-nsmenuitem-init-with-title-action-key-equivalent
     "Relaunch" "relaunchClicked:" "r"))
  (nsmenuitem-set-target! relaunch-item current-menu-handler)
  (nsmenu-add-item! menu relaunch-item)

  ;; ---
  (nsmenu-add-item! menu (nsmenuitem-separator-item))

  ;; Quit Modaliser
  (define quit-item
    (make-nsmenuitem-init-with-title-action-key-equivalent
     "Quit Modaliser" "quitClicked:" "q"))
  (nsmenuitem-set-target! quit-item current-menu-handler)
  (nsmenu-add-item! menu quit-item)

  ;; Attach menu to status item
  (nsstatusitem-set-menu! current-status-item menu)

  (displayln "Status bar configured"))

;; --- Actions ---

;; Canonical config path — shared with config-loader.rkt via this export.
(define modaliser-config-path
  (path->string (build-path (find-system-path 'home-dir) ".config" "modaliser" "config.scm")))

(define (open-settings!)
  (with-handlers ([exn:fail? (lambda (e)
                               (displayln (format "open-settings! error: ~a" (exn-message e))))])
    (define-values (_proc _o _i _e)
      (subprocess #f #f #f "/usr/bin/open" modaliser-config-path))
    (void)))

;; Detect if running inside a .app bundle by checking the executable path.
;; Layout: Something.app/Contents/MacOS/Modaliser → go up 3 levels to get .app
(define (find-app-bundle)
  (define exe (find-system-path 'run-file))
  (define app-dir (simplify-path (build-path exe 'up 'up 'up)))
  (and (regexp-match? #rx"\\.app$" (path->string app-dir))
       app-dir))

;; Path to main.rkt, resolved at compile time (fallback for non-bundle launch).
(define-runtime-path main-script "../main.rkt")

(define (relaunch!)
  (displayln "modaliser: relaunching…")
  (define app-bundle (find-app-bundle))
  (cond
    ;; Running as .app bundle — relaunch via open(1)
    [app-bundle
     (subprocess #f #f #f "/usr/bin/open" "-a" (path->string app-bundle))
     (quit!)]
    ;; Running as bare `racket main.rkt` — relaunch via racket
    [else
     (define racket-path (find-executable-path "racket"))
     (cond
       [(not racket-path)
        (displayln "relaunch!: cannot find racket executable")]
       [else
        (subprocess #f #f #f
                    (path->string racket-path)
                    (path->string main-script))
        (quit!)])]))

(define (quit!)
  (nsapplication-terminate (nsapplication-shared-application) #f))
