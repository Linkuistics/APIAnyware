;; tests/smoke-import-frameworks.ss — leaf-080 spot-check: every chez
;; library generated for a framework loads cleanly, and the framework's
;; `main.sls` re-export succeeds (its (export ...) form must match the
;; union of the sub-libraries' exports).
;;
;; Run from the repository root:
;;   chez --script generation/targets/chez/runtime/tests/smoke-import-frameworks.ss
;;
;; Exits 0 on success; loads every framework whose name is in `targets`.

(define runtime "generation/targets/chez/runtime")
(define generated "generation/targets/chez/generated")

;; Load the five-library runtime cluster first. Every emitted library
;; transitively imports from these.
(load (string-append runtime "/ffi.sls"))
(load (string-append runtime "/objc.sls"))
(load (string-append runtime "/dispatch.sls"))
(load (string-append runtime "/types.sls"))

;; Frameworks to exercise. Per the leaf's "Done when" — appkit and webkit
;; both touch every file type (classes, enums, constants, functions,
;; protocols, main).
(define targets
  ;; Mix the leaf's required spot-check (appkit, webkit) with a wider
  ;; sample so scale-only bugs surface here rather than during sample-app
  ;; ports. Foundation is always loaded first because most others
  ;; transitively reference its protocols / classes through identifier
  ;; namespace collisions (handled in main.sls's rename forms).
  '("foundation" "appkit" "webkit"
    "coredata" "coregraphics" "coreimage"
    "pdfkit" "scenekit" "metalkit"
    "libdispatch" "swiftuicore" "swiftui"))

(define (sls-file? path)
  (let ([n (string-length path)])
    (and (> n 4)
         (string=? (substring path (- n 4) n) ".sls"))))

(define (list-sls-files dir)
  (let loop ([entries (directory-list dir)]
             [out '()])
    (cond
      [(null? entries) (reverse out)]
      [else
       (let* ([name (car entries)]
              [full (string-append dir "/" name)])
         (cond
           [(file-directory? full)
            (loop (cdr entries) (append (reverse (list-sls-files full)) out))]
           [(sls-file? name)
            (loop (cdr entries) (cons full out))]
           [else
            (loop (cdr entries) out)]))])))

(define (load-sub-libraries fw-dir)
  ;; Order matters less than completeness: chez resolves library names by
  ;; what's been registered. main.sls imports its siblings so we must
  ;; load every other .sls in the framework directory first.
  (for-each
    (lambda (path)
      (unless (string=? path (string-append fw-dir "/main.sls"))
        (load path)))
    (list-sls-files fw-dir))
  ;; Then main, then return the framework lib path for import.
  (load (string-append fw-dir "/main.sls")))

(for-each
  (lambda (fw)
    (printf "[smoke-import] loading ~a~n" fw)
    (load-sub-libraries (string-append generated "/" fw))
    ;; `eval` lets us synthesise the import form per framework. Each
    ;; framework's main is a `library (apianyware <fw>)`; importing it
    ;; triggers chez to resolve the (export ...) list against every
    ;; imported sibling — which is the bit this spot-check is verifying.
    (eval `(import (apianyware ,(string->symbol fw))) (interaction-environment))
    (printf "[smoke-import] ~a OK~n" fw))
  targets)

(printf "[smoke-import] all frameworks imported~n")
(exit 0)
