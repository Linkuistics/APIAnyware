;; verify.ss — scaffold load-test for the chez runtime.
;;
;; Run from the repository root:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/bindings/macos/apianyware/runtime/verify.ss
;;
;; The `--libdirs` flag tells Chez to resolve `(apianyware ...)`
;; library names against `targets/chez/bindings/macos/apianyware/...`
;; (see targets/chez/docs/design/2026-05-27-chez-target-design.md §8). No
;; explicit `(load ...)` is needed — Chez walks the import graph
;; and pulls each library in dependency order.

(import (apianyware runtime cocoa)
        (apianyware runtime cocoa-helpers))

(display "[runtime scaffold] loaded\n")
