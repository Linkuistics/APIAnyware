;; verify.ss — scaffold load-test for the chez runtime.
;;
;; Run from the repository root:
;;   chez --script generation/targets/chez/runtime/verify.ss
;;
;; Pre-loads the five cluster libraries in dependency order so that the
;; top-level `(import (apianyware runtime cocoa))` resolves from the
;; library registry rather than via library-directories path lookup.
;;
;; A later leaf (bundle-chez and/or 070-emit-chez-scaffold) replaces
;; this hand-rolled boot with a proper library-directories layout or
;; a generated `main.sls` aggregator.

(define here "generation/targets/chez/runtime")

(load (string-append here "/ffi.sls"))
(load (string-append here "/objc.sls"))
(load (string-append here "/dispatch.sls"))
(load (string-append here "/types.sls"))
(load (string-append here "/cocoa.sls"))

(import (apianyware runtime cocoa))

(display "[runtime scaffold] loaded\n")
