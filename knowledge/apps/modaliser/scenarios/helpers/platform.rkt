#lang racket/base
;; spec/scenarios/helpers/platform.rkt — macOS-version predicate for
;; scenarios that gate on a minimum OS version.
;;
;; Shelled out to `sw_vers` rather than reading Gestalt/Foundation APIs
;; because spec scenarios run as plain Racket — no Cocoa bindings are
;; loaded in the scenario-side VM. This keeps helpers loadable outside
;; the runner for tests and REPL exploration.

(require racket/port
         racket/string
         racket/system)

(provide at-least-macos?)

(define (current-macos-major)
  (define out
    (with-output-to-string
     (lambda () (system* "/usr/bin/sw_vers" "-productVersion"))))
  (string->number (car (string-split (string-trim out) "."))))

(define (at-least-macos? n)
  (>= (current-macos-major) n))
