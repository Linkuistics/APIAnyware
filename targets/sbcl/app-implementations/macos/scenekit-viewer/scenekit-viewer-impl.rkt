#lang app-spec/impl

;; Impl descriptor for the sbcl build of SceneKit Viewer — consumed by
;; the AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/scenekit-viewer/docs/logging-contract.md
;;
;; #:events-path / #:test-config-path mirror the impl's fixed-default paths
;; (logging-contract.md "The events.log file") so the runner tails / the impl
;; writes the same file whether or not #:log-env/#:config-env propagate through
;; LaunchServices under `launch-via 'open`. #:binary is the VM install path
;; (the Tier-2 live-run leaf installs the built .app there); #:bundle-id must
;; equal the built bundle's CFBundleIdentifier (build.sh sets it).
(impl
  #:name             "SceneKit Viewer (SBCL)"
  #:binary           "/Applications/SceneKitViewer-sbcl.app"
  #:config-env       "SCENEKIT_VIEWER_TEST_CONFIG"
  #:log-env          "SCENEKIT_VIEWER_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.scenekit-viewer-sbcl"
  #:launch-via       'open
  #:events-path      "/tmp/scenekit-viewer/events.log"
  #:test-config-path "/tmp/scenekit-viewer/test-config.scm")
