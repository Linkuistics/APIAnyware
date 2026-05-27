;; extract-deps.ss — print transitive .sls dependencies of an entry script.
;;
;; Usage:
;;   chez --script extract-deps.ss <source-root> <entry-script>
;;
;; Builds a `library-name → file-path` registry by scanning every `.sls`
;; file under <source-root> for its `(library NAME ...)` declaration,
;; then walks `(import ...)` forms starting at <entry-script>. Resolves
;; each library reference against the registry; built-in libraries
;; like `(chezscheme)` aren't registered and are skipped. Prints the
;; absolute path of every reached `.sls` file (including the entry),
;; sorted, one per line.
;;
;; Bundle-chez invokes this from Rust and parses stdout into the file
;; copy plan. Using Chez itself is what keeps the import-spec walker
;; honest: `only`, `except`, `prefix`, `rename`, `for`, and `library`
;; wrappers are stripped by recursing into the first sublist, and the
;; reader handles all the lexical edge cases (block comments, datum
;; comments, character literals, bytevector syntax) for free.

(import (chezscheme))

(define (die fmt . args)
  (apply fprintf (current-error-port) fmt args)
  (newline (current-error-port))
  (exit 1))

(define (ends-with? s suffix)
  (let ((ns (string-length s)) (nf (string-length suffix)))
    (and (>= ns nf)
         (string=? (substring s (- ns nf) ns) suffix))))

;; Recursive walk under `root`, returning every regular file whose name
;; ends in `.sls`. Symlinks are followed (file-directory? follows them),
;; which matches the bundle semantics: the logical path lives under
;; source_root even when the underlying file is reached through a
;; symlinked directory.
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

;; Read every top-level datum from `file` into a list.
(define (read-all-from-file file)
  (call-with-input-file file
    (lambda (port)
      (let loop ((acc '()))
        (let ((d (read port)))
          (if (eof-object? d)
              (reverse acc)
              (loop (cons d acc))))))))

;; Map library-name (a list of identifiers) → file path. Equal-keyed
;; because library names are lists.
(define (build-registry root)
  (let ((reg (make-hashtable equal-hash equal?)))
    (for-each
     (lambda (file)
       (for-each
        (lambda (datum)
          (when (and (pair? datum)
                     (eq? (car datum) 'library)
                     (pair? (cdr datum)))
            (hashtable-set! reg (cadr datum) file)))
        (read-all-from-file file)))
     (find-sls-files root))
    reg))

;; Reduce an import-spec to its underlying library reference.
;; R6RS / Chez import-spec wrappers (only/except/prefix/rename/for/library)
;; all have the shape `(KEYWORD <import-set> ...)`, so recursing into the
;; second element strips the wrapper. A bare `(id ...)` IS the reference.
(define (extract-lib-ref spec)
  (cond
    ((not (pair? spec)) #f)
    ((memq (car spec) '(only except prefix rename for library))
     (and (pair? (cdr spec))
          (extract-lib-ref (cadr spec))))
    (else spec)))

;; Walk `form` looking for `(import SPEC ...)` forms; for each spec,
;; reduce to a library reference and accumulate. Recurses into every
;; sub-form so that imports nested inside a `library` body are found.
(define (collect-imports-in form)
  (cond
    ((not (pair? form)) '())
    ((eq? (car form) 'import)
     (let loop ((specs (cdr form)) (acc '()))
       (cond
         ((null? specs) acc)
         ((pair? specs)
          (let ((lib (extract-lib-ref (car specs))))
            (loop (cdr specs) (if lib (cons lib acc) acc))))
         (else acc))))
    (else
     (let loop ((parts form) (acc '()))
       (if (pair? parts)
           (loop (cdr parts) (append (collect-imports-in (car parts)) acc))
           acc)))))

;; Library references imported by `file`.
(define (imports-of-file file)
  (let loop ((forms (read-all-from-file file)) (acc '()))
    (if (null? forms)
        acc
        (loop (cdr forms) (append (collect-imports-in (car forms)) acc)))))

;; BFS through the registry starting at `entry`. Returns the visited
;; file list (entry included).
(define (walk-deps entry registry)
  (let ((visited (make-hashtable string-hash string=?)))
    (let loop ((queue (list entry)))
      (unless (null? queue)
        (let ((file (car queue)) (rest (cdr queue)))
          (cond
            ((hashtable-ref visited file #f) (loop rest))
            (else
             (hashtable-set! visited file #t)
             (let ((next
                    (let resolve ((libs (imports-of-file file)) (acc '()))
                      (cond
                        ((null? libs) acc)
                        (else
                         (let ((path (hashtable-ref registry (car libs) #f)))
                           (resolve (cdr libs)
                                    (if path (cons path acc) acc))))))))
               (loop (append next rest))))))))
    (vector->list (hashtable-keys visited))))

(define (main)
  (let ((args (command-line-arguments)))
    (unless (= (length args) 2)
      (die "usage: extract-deps.ss <source-root> <entry-script>"))
    (let* ((root (car args))
           (entry (cadr args)))
      (unless (file-directory? root)
        (die "source-root not a directory: ~a" root))
      (unless (file-exists? entry)
        (die "entry-script not found: ~a" entry))
      (let* ((registry (build-registry root))
             (deps (walk-deps entry registry)))
        (for-each
         (lambda (p) (display p) (newline))
         (sort string<? deps))))))

(main)
