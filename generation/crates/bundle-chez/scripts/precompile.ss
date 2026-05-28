;; precompile.ss — pre-compile bundled .sls libraries to .so.
;;
;; Usage:
;;   chez --script precompile.ss <libdir>
;;
;; Walks <libdir> for `.sls` library files that sit at "root"
;; positions in the apianyware layout, runs `compile-library` on each
;; of them with `(compile-imported-libraries #t)` set, and lets Chez
;; chase the per-class / per-protocol leaves transitively. Output
;; `.so` files land next to source via Chez's default
;; `library-extensions`.
;;
;; ## Why only roots?
;;
;; Iterating *every* `.sls` and calling `compile-library` on it
;; produces a `.so` per source, but each call writes a fresh
;; timestamp into the dependants' "I was compiled when my deps
;; looked like X" record. By the end of the walk, half the `.so`
;; files have a dep-stamp that disagrees with the actual newer `.so`
;; on disk, and Chez reloads them from source on import — exactly the
;; ~75s on-import compile pass we were trying to skip.
;;
;; `compile-imported-libraries #t` makes one root compile produce
;; consistent `.so` files for the entire transitive closure: each
;; library is compiled exactly once and its dep-stamps reference
;; freshly-written siblings. Iterating only the *roots* preserves
;; that consistency.
;;
;; ## What is a root?
;;
;; A "root" library here is anything the entry script can plausibly
;; `(import …)` directly:
;;
;;   - `<libdir>/apianyware/<fw>.sls`              — framework facade
;;   - `<libdir>/apianyware/runtime/<cluster>.sls` — runtime library
;;
;; The per-class libraries at `<libdir>/apianyware/<fw>/<cls>.sls`
;; and protocols at `<libdir>/apianyware/<fw>/protocols/<p>.sls` are
;; reached via the facades' `(import …)` re-exports; they get
;; compiled transitively.
;;
;; Script-style `.sls` files (the per-app entry script — top-level
;; body, no `(library …)` wrapper) are skipped — `--script <path>`
;; is exact-path in the stub launcher, so pre-compiling them would
;; not be picked up without a launcher change. The entry script body
;; is small; the cold-start cost lives in the library imports.
;;
;; ## Parameters
;;
;;  - (library-directories <libdir>) so (import …) forms encountered
;;    by compile-imported-libraries resolve against the same root the
;;    stub launcher uses.
;;  - (compile-imported-libraries #t) so a single root compile chases
;;    its entire dependency closure within one consistent run.
;;  - (generate-wpo-files #f) — no whole-program-optimisation files
;;    in the bundle; they bloat the resource tree without helping
;;    launch speed.
;;
;; ## Errors
;;
;; A `compile-library` failure exits non-zero with Chez's condition
;; on stderr. bundle-chez turns that into a build-time error so an
;; emitter regression that produces uncompilable Chez source fails
;; the bundle build loudly rather than degrading cold-launch back to
;; ~75s.

(import (chezscheme))

(define (die fmt . args)
  (apply fprintf (current-error-port) fmt args)
  (newline (current-error-port))
  (exit 1))

(define (ends-with? s suffix)
  (let ((ns (string-length s)) (nf (string-length suffix)))
    (and (>= ns nf)
         (string=? (substring s (- ns nf) ns) suffix))))

(define (find-sls-files root)
  (let loop ((dir root) (acc '()))
    (fold-left
     (lambda (acc name)
       (let ((path (string-append dir "/" name)))
         (cond
           ((file-directory? path) (loop path acc))
           ((ends-with? name ".sls") (cons path acc))
           (else acc))))
     acc
     (directory-list dir))))

(define (string-split s sep)
  (let loop ((i 0) (start 0) (acc '()))
    (cond
      ((= i (string-length s))
       (reverse (cons (substring s start i) acc)))
      ((char=? (string-ref s i) sep)
       (loop (+ i 1) (+ i 1) (cons (substring s start i) acc)))
      (else
       (loop (+ i 1) start acc)))))

(define (strip-prefix s prefix)
  (let ((ns (string-length s)) (np (string-length prefix)))
    (and (>= ns np)
         (string=? (substring s 0 np) prefix)
         (substring s np ns))))

;; A library file is a "root" we should iterate if it sits at:
;;   - <libdir>/apianyware/<fw>.sls               (a framework facade)
;;   - <libdir>/apianyware/runtime/<cluster>.sls  (a runtime library)
;; Everything deeper is reached transitively via compile-imported-libraries.
(define (root-library? path libdir)
  (let ((rel (strip-prefix path (string-append libdir "/"))))
    (and rel
         (let ((segs (string-split rel #\/)))
           (or
             ;; apianyware/<fw>.sls — two segments
             (and (= 2 (length segs))
                  (string=? "apianyware" (car segs)))
             ;; apianyware/runtime/<cluster>.sls — three segments
             (and (= 3 (length segs))
                  (string=? "apianyware" (car segs))
                  (string=? "runtime" (cadr segs))))))))

(define (main)
  (let ((args (command-line-arguments)))
    (unless (= (length args) 1)
      (die "usage: precompile.ss <libdir>"))
    (let ((libdir (car args)))
      (unless (file-directory? libdir)
        (die "libdir not a directory: ~a" libdir))
      (library-directories (list libdir))
      (compile-imported-libraries #t)
      (generate-wpo-files #f)
      (let* ((all (find-sls-files libdir))
             (roots (filter (lambda (p) (root-library? p libdir)) all))
             ;; Compile runtime libs first so framework facades that
             ;; reach them via compile-imported-libraries find them
             ;; already-compiled in this process's library table.
             ;; Within each group, alphabetical for stable logs.
             (ordered (list-sort
                       (lambda (a b)
                         (let ((ar (root-rank a libdir))
                               (br (root-rank b libdir)))
                           (cond
                             ((< ar br) #t)
                             ((> ar br) #f)
                             (else (string<? a b)))))
                       roots)))
        (for-each
         (lambda (f)
           (fprintf (current-error-port) "compile-library ~a~%" f)
           (compile-library f))
         ordered)))))

;; Lower rank = compile earlier. Runtime libs are 0, framework
;; facades are 1.
(define (root-rank path libdir)
  (let* ((rel (strip-prefix path (string-append libdir "/")))
         (segs (string-split rel #\/)))
    (if (and (>= (length segs) 2) (string=? "runtime" (cadr segs)))
        0
        1)))

(main)
