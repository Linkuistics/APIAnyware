;; standalone-collisions.ss — compute the duplicate-import collision set an
;; app's entry must reconcile to become a strict R6RS top-level program.
;;
;; Usage:
;;   chez --script standalone-collisions.ss <source-root> <entry-script>
;;
;; `load`/`--script` evaluates in the interaction environment (last-wins
;; rebinding), but `compile-program`/`compile-whole-program` enforce strict
;; top-level-program semantics where a name exported by two imported
;; libraries is a hard duplicate-import error (spike F2). The standalone
;; bundler wraps the app entry in a generated top-level program; this script
;; computes, per app, which names each framework facade must yield.
;;
;; Mechanism (design spec §3):
;;   1. Read the entry's leading (import ...) form with Chez's own reader and
;;      reduce each import spec to its underlying library reference (strip the
;;      only/except/prefix/rename/for/library wrappers — same shape as
;;      extract-deps.ss).
;;   2. Classify each imported library as a *facade* — a length-2
;;      (apianyware <fw>) framework rollup, the libraries that yield — or
;;      *curated*: everything else (`(apianyware runtime ...)`, `(chezscheme)`,
;;      `(rnrs ...)`), the libraries that win.
;;   3. Compute every library's bound names via `environment-symbols` (ground
;;      truth — honours re-exports and renames, unlike parsing (export ...)).
;;   4. For each name a facade shares with the union of curated names, add it
;;      to that facade's `except` list. The facade always yields.
;;
;; Output: one line per facade that has ≥1 collision —
;;   (apianyware <fw>)\t<name> <name> ...
;; names sorted, facades in import order. Bundle-chez parses this into the
;; per-facade except map and asserts on it (the regression anchor), then emits
;; the wrapper. A facade with no collisions prints nothing.

(import (chezscheme))

(define (die fmt . args)
  (apply fprintf (current-error-port) fmt args)
  (newline (current-error-port))
  (exit 1))

;; Read every top-level datum from `file` into a list.
(define (read-all-from-file file)
  (call-with-input-file file
    (lambda (port)
      (let loop ((acc '()))
        (let ((d (read port)))
          (if (eof-object? d)
              (reverse acc)
              (loop (cons d acc))))))))

;; Reduce an import-spec to its underlying library reference. The R6RS / Chez
;; wrappers (only/except/prefix/rename/for/library) all have the shape
;; `(KEYWORD <import-set> ...)`, so recursing into the second element strips
;; them. A bare `(id ...)` IS the reference. (Mirrors extract-deps.ss.)
(define (extract-lib-ref spec)
  (cond
    ((not (pair? spec)) #f)
    ((memq (car spec) '(only except prefix rename for library))
     (and (pair? (cdr spec))
          (extract-lib-ref (cadr spec))))
    (else spec)))

;; The library references imported by the entry's leading (import ...) form.
;; Apps are authored as `(import ...) <body> (main)`, so the import is the
;; first top-level form; we take every import form to be safe.
(define (entry-imports entry)
  (let loop ((forms (read-all-from-file entry)) (acc '()))
    (cond
      ((null? forms) (reverse acc))
      ((and (pair? (car forms)) (eq? (caar forms) 'import))
       (loop (cdr forms)
             (let inner ((specs (cdar forms)) (acc acc))
               (if (pair? specs)
                   (let ((lib (extract-lib-ref (car specs))))
                     (inner (cdr specs) (if lib (cons lib acc) acc)))
                   acc))))
      (else (loop (cdr forms) acc)))))

;; A facade is a length-2 (apianyware <fw>) rollup whose second element is not
;; `runtime` — i.e. a framework facade, not a curated runtime library. Curated
;; = everything else the app imports.
(define (facade? lib)
  (and (pair? lib)
       (eq? (car lib) 'apianyware)
       (pair? (cdr lib))
       (null? (cddr lib))
       (not (eq? (cadr lib) 'runtime))))

;; Names bound in a library's environment (its effective exports).
(define (lib-names lib)
  (guard (e (#t (die "could not load library ~s: ~a" lib
                     (if (condition? e)
                         (with-output-to-string (lambda () (display-condition e)))
                         e))))
    (environment-symbols (environment lib))))

(define (main)
  (let ((args (command-line-arguments)))
    (unless (= (length args) 2)
      (die "usage: standalone-collisions.ss <source-root> <entry-script>"))
    (let ((root (car args)) (entry (cadr args)))
      (unless (file-directory? root) (die "source-root not a directory: ~a" root))
      (unless (file-exists? entry) (die "entry-script not found: ~a" entry))
      (library-directories root)
      (let* ((libs (entry-imports entry))
             (facades (filter facade? libs))
             (curated (filter (lambda (l) (not (facade? l))) libs))
             ;; Union of every curated library's names — the set the facades
             ;; yield to.
             (curated-names (make-hashtable symbol-hash eq?)))
        (for-each
         (lambda (lib)
           (for-each (lambda (s) (hashtable-set! curated-names s #t))
                     (lib-names lib)))
         curated)
        (for-each
         (lambda (facade)
           (let ((collisions
                  (sort (lambda (a b) (string<? (symbol->string a)
                                                (symbol->string b)))
                        (filter (lambda (s) (hashtable-ref curated-names s #f))
                                (lib-names facade)))))
             (unless (null? collisions)
               (display (with-output-to-string (lambda () (write facade))))
               (write-char #\tab)
               (let loop ((ns collisions) (first #t))
                 (when (pair? ns)
                   (unless first (write-char #\space))
                   (display (car ns))
                   (loop (cdr ns) #f)))
               (newline))))
         facades)))))

(main)
