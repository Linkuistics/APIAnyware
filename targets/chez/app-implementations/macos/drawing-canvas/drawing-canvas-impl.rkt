#lang app-spec/impl

;; Impl descriptor for the chez build of Drawing Canvas — consumed by
;; the AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/drawing-canvas/docs/logging-contract.md
;;
;; #:events-path / #:test-config-path mirror the impl's fixed-default paths
;; (logging-contract.md "The events.log file") so the runner tails / the impl
;; writes the same file whether or not #:log-env/#:config-env propagate through
;; LaunchServices under `launch-via 'open`. #:binary is the VM install path
;; (the Tier-2 live-run leaf installs the built .app there); #:bundle-id must
;; equal the built bundle's CFBundleIdentifier (build.sh sets it).
(impl
  #:name             "Drawing Canvas (Chez)"
  #:binary           "/Applications/DrawingCanvas-chez.app"
  #:config-env       "DRAWING_CANVAS_TEST_CONFIG"
  #:log-env          "DRAWING_CANVAS_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.drawing-canvas-chez"
  #:launch-via       'open
  #:events-path      "/tmp/drawing-canvas/events.log"
  #:test-config-path "/tmp/drawing-canvas/test-config.scm")
