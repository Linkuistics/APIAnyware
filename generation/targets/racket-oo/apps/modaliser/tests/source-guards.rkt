#lang racket/base
;; source-guards.rkt — Static guardrail for Racket scheduler APIs that
;; silently no-op under nsapplication-run.
;;
;; The Cocoa run loop blocks the Racket place main thread, so the green
;; thread scheduler cannot advance. Any form that depends on it —
;; (thread ...), (sleep ...), (sync ...), (sync/timeout ...),
;; (thread-wait ...), (semaphore-wait ...) — never fires in the app
;; context. The failure mode is a silent no-op, which is exactly what
;; has historically caused the hardest-to-debug regressions (overlay
;; delay timer, chooser search, shell/http timeouts).
;;
;; Sanctioned alternatives:
;;   - ffi/main-thread.rkt    call-on-main-thread / call-on-main-thread-after
;;   - state-machine.rkt      after-delay (built on call-on-main-thread-after)
;;   - services/shell.rkt     shell-level timeout via backgrounded zsh watcher
;;
;; Exports a single tree walker, check-source-tree, that scans runtime
;; source directories for any forbidden form and fails the rackunit
;; suite on a match. Invoked once per suite from tests/test-source-
;; guards.rkt — do not sprinkle per-module calls.
;;
;; Pair tree-level static checks with per-module dynamic-require smoke
;; loads when landing a fix, per memory's "Verify regenerated bindings
;; by loading, not grepping" lesson — grep alone misses name collisions,
;; missing exports, and contract blame.

(require racket/file
         racket/path
         racket/port
         racket/string)

(provide check-source-tree)

;; ─── Forbidden forms ──────────────────────────────────────────
;; Each entry is (name . regex). The regex requires an open paren
;; immediately before the form name and a whitespace character
;; immediately after, so string literals like "sleep ..." inside a
;; shell-script constant won't trip the check.

(define forbidden-patterns
  (list
   (cons "thread"         #rx"\\(thread[ \t\n]")
   (cons "sleep"          #rx"\\(sleep[ \t\n]")
   (cons "sync"           #rx"\\(sync[ \t\n]")
   (cons "sync/timeout"   #rx"\\(sync/timeout[ \t\n]")
   (cons "thread-wait"    #rx"\\(thread-wait[ \t\n]")
   (cons "semaphore-wait" #rx"\\(semaphore-wait[ \t\n]")))

;; Drop comment-only lines (first non-whitespace char is `;`) so prose
;; inside doc comments doesn't trip the patterns.
(define (strip-comment-lines src)
  (string-join
   (for/list ([line (in-list (string-split src "\n"))]
              #:unless (regexp-match? #px"^[ \t]*;" line))
     line)
   "\n"))

;; Check one file against every forbidden pattern. Appends a
;; (file . form-name) violation record to the supplied box for each match
;; so the caller can report all violations in a single raise.
(define (check-file abs-path label violations)
  (define code (strip-comment-lines
                (call-with-input-file abs-path port->string)))
  (for ([entry (in-list forbidden-patterns)])
    (define name (car entry))
    (define rx   (cdr entry))
    (when (regexp-match? rx code)
      (set-box! violations
                (cons (cons label name) (unbox violations))))))

;; Walk a directory recursively for .rkt files.
(define (rkt-files-in dir)
  (find-files
   (lambda (p)
     (and (file-exists? p)
          (regexp-match? #rx"\\.rkt$" (path->string p))))
   dir))

;; Resolve a root (project-relative path) to a list of
;; (abs-path . rel-label) pairs. A file root yields one pair; a
;; directory root yields one pair per .rkt file found under it.
(define (resolve-root root)
  (define abs (simplify-path (build-path (current-directory) root)))
  (cond
    [(file-exists? abs)
     (list (cons abs root))]
    [(directory-exists? abs)
     (for/list ([f (in-list (rkt-files-in abs))])
       (cons f (path->string
                (find-relative-path (current-directory) f))))]
    [else
     (error 'check-source-tree
            "source-guard root not found: ~a" root)]))

;; Same as check-file but honors a per-form allowlist hash: patterns
;; whose name is in allow-forms are skipped for this file only.
(define (check-file/allow abs-path label allow-forms violations)
  (define code (strip-comment-lines
                (call-with-input-file abs-path port->string)))
  (for ([entry (in-list forbidden-patterns)])
    (define name (car entry))
    (define rx   (cdr entry))
    (unless (hash-ref allow-forms name #f)
      (when (regexp-match? rx code)
        (set-box! violations
                  (cons (cons label name) (unbox violations)))))))

;; (check-source-tree roots #:allow allow-list)
;;   roots      — list of project-relative paths (dirs or .rkt files)
;;   allow-list — list of (file-path . form-name) pairs exempting a
;;                specific forbidden form in a specific file. Per-form
;;                granularity so exempting one construct never hides
;;                regressions for the other forbidden forms in the
;;                same file.
;;
;; Scans every .rkt file under roots for any forbidden scheduler form.
;; Raises an error listing every violation if any are found — rackunit's
;; check-* forms only print failures, so they'd let a violation pass
;; with exit code 0 (silent-failure is the anti-pattern this guard
;; exists to prevent).
(define (check-source-tree roots #:allow [allow-list '()])
  ;; Index the allowlist as file-path → hash-of-allowed-form-names.
  (define per-file-allow (make-hash))
  (for ([entry (in-list allow-list)])
    (define file (car entry))
    (define form (cdr entry))
    (hash-update! per-file-allow file
                  (lambda (h) (hash-set h form #t))
                  (lambda () (hash))))
  (define targets
    (apply append (for/list ([r (in-list roots)]) (resolve-root r))))
  (define violations (box '()))
  (for ([entry (in-list targets)])
    (define abs   (car entry))
    (define label (cdr entry))
    (define allow-forms (hash-ref per-file-allow label (hash)))
    (check-file/allow abs label allow-forms violations))
  (define found (reverse (unbox violations)))
  (unless (null? found)
    (error 'check-source-tree
           "forbidden scheduler forms found (dead under nsapplication-run):\n~a\nUse ffi/main-thread.rkt (call-on-main-thread[-after]) or an allowlisted primitive."
           (string-join
            (for/list ([v (in-list found)])
              (format "  ~a: (~a ...)" (car v) (cdr v)))
            "\n"))))
