#lang racket/base
;; spec/scenarios/helpers/quick-launch.rkt — shared table of quick-launch
;; bindings used by scenarios that exercise the `[launch] bundle` event.
;;
;; Keep entries aligned with spec/config/test-config.scm's `'global` tree;
;; each `(binding KEY BUNDLE LABEL)` here must map to a `key KEY LABEL
;; (launch-bundle BUNDLE)` entry in the test config.

(provide quick-launch-bindings
         (struct-out binding))

(struct binding (key bundle label) #:transparent)

(define quick-launch-bindings
  (list (binding "s" "com.apple.Safari"   "Safari")
        (binding "t" "com.apple.TextEdit" "TextEdit")))
