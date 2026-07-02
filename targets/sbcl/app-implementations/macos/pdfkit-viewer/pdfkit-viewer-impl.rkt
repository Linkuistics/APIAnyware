#lang app-spec/impl

;; Impl descriptor for the sbcl build of PDFKit Viewer — consumed by
;; the AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/pdfkit-viewer/docs/logging-contract.md
;;
;; #:events-path / #:test-config-path mirror the impl's fixed-default paths
;; (logging-contract.md "The events.log file") so the runner tails / the impl
;; writes the same file whether or not #:log-env/#:config-env propagate through
;; LaunchServices under `launch-via 'open`. #:binary is the VM install path
;; (the Tier-2 live-run leaf installs the built .app there); #:bundle-id must
;; equal the built bundle's CFBundleIdentifier (build.sh sets it).
(impl
  #:name             "PDFKit Viewer (SBCL)"
  #:binary           "/Applications/PDFKitViewer-sbcl.app"
  #:config-env       "PDFKIT_VIEWER_TEST_CONFIG"
  #:log-env          "PDFKIT_VIEWER_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.pdfkit-viewer-sbcl"
  #:launch-via       'open
  #:events-path      "/tmp/pdfkit-viewer/events.log"
  #:test-config-path "/tmp/pdfkit-viewer/test-config.scm")
