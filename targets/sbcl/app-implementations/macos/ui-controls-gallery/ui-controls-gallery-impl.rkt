#lang app-spec/impl

;; Impl descriptor for the sbcl build of UI Controls Gallery — consumed by
;; the AppSpec runner as `runner/main.rkt --impl <this file>` (ADR-0011/ADR-0013).
;; Contract: ../../../../../apps/macos/ui-controls-gallery/docs/logging-contract.md
;;
;; #:events-path / #:test-config-path mirror the impl's fixed-default paths
;; (logging-contract.md "The events.log file") so the runner tails / the impl
;; writes the same file whether or not #:log-env/#:config-env propagate through
;; LaunchServices under `launch-via 'open`. #:binary is the VM install path
;; (the Tier-2 live-run leaf installs the built .app there); #:bundle-id must
;; equal the built bundle's CFBundleIdentifier (build.sh sets it).
(impl
  #:name             "UI Controls Gallery (SBCL)"
  #:binary           "/Applications/UIControlsGallery-sbcl.app"
  #:config-env       "UI_CONTROLS_GALLERY_TEST_CONFIG"
  #:log-env          "UI_CONTROLS_GALLERY_EVENTS_LOG"
  #:bundle-id        "com.linkuistics.ui-controls-gallery-sbcl"
  #:launch-via       'open
  #:events-path      "/tmp/ui-controls-gallery/events.log"
  #:test-config-path "/tmp/ui-controls-gallery/test-config.scm")
