;; tests/smoke-import-frameworks.ss — leaf-080 spot-check: every chez
;; library generated for a framework loads cleanly, and the framework's
;; `main.sls` re-export succeeds (its (export ...) form must match the
;; union of the sub-libraries' exports).
;;
;; Run from the repository root:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apianyware/runtime/tests/smoke-import-frameworks.ss
;;
;; The `--libdirs` flag lets Chez resolve `(apianyware <fw> <cls>)`
;; library references against `generation/targets/chez/apianyware/...`
;; directly — no hand-rolled (load ...) chain.
;;
;; Exits 0 on success; imports every framework whose name is in `targets`.

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

(for-each
  (lambda (fw)
    (printf "[smoke-import] loading ~a~n" fw)
    ;; Each framework's main is `(library (apianyware <fw>) ...)`;
    ;; importing it triggers chez to resolve the (export ...) list
    ;; against every imported sibling — which is the bit this
    ;; spot-check is verifying. `eval` lets us synthesise the import
    ;; form once per framework name.
    (eval `(import (apianyware ,(string->symbol fw))) (interaction-environment))
    (printf "[smoke-import] ~a OK~n" fw))
  targets)

(printf "[smoke-import] all frameworks imported~n")
(exit 0)
