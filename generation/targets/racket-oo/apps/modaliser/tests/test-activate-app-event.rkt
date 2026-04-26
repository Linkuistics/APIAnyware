#lang racket/base
;; test-activate-app-event.rkt — Verifies that activate-app emits
;; [window] focus pid=... title=... when the target bundle id resolves
;; to a running NSRunningApplication (spec/docs/logging-contract.md).
;;
;; Finder (com.apple.finder) is always running in any logged-in macOS
;; session, so we probe against it without needing to launch anything.

(require rackunit
         racket/file
         racket/string
         "../lib/events.rkt"
         "../lib/util.rkt")

(define tmp (make-temporary-file "activate-~a.log"))
(events-init! #:path tmp)

;; Chooser-result alist — matches what find-installed-apps returns.
(activate-app '((bundleId . "com.apple.finder")
                (text     . "Finder")))

(close-events!)
(define content (file->string tmp))
(delete-file tmp)

(test-case "activate-app emits [window] focus for running bundle id"
  (check-regexp-match
   #px"\\[window\\] focus pid=[0-9]+ title="
   content))

(displayln "test-activate-app-event: all checks passed")
