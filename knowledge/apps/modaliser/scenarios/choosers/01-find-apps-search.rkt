#lang app-spec

;; Find-Apps chooser search → Safari launch.
;;
;; open-find-apps! navigates F18 → "f" → "a" which opens the Find Apps
;; chooser (test-config.scm binds "a" to the selector). Typing narrows
;; results by substring; Return on the selected row calls activate-app
;; with the item's alist, which emits [launch] bundle id="..." via
;; lib/util.rkt and launches the app.
;;
;; The plan snippet's regex `\\[launch\\] bundle=com\\.apple\\.Safari`
;; targets a non-existent format. Actual emission per lib/events.rkt is
;; `[launch] bundle id="com.apple.Safari"` — `id` is the key, bundle is
;; the event-name, and the string value is quoted.

(require "../helpers/common-setups.rkt")

(scenario "find-apps-search-launches-safari"
  #:description "Find Apps chooser: type 'safari', Return → launches Safari"
  (open-find-apps!)
  (expect-ocr "Find app")
  (type "safari")
  (wait-for-ocr "Safari" #:timeout 3.0)
  (press 'Return)
  (wait-for-log #px"\\[launch\\] bundle id=\"com\\.apple\\.Safari\"" #:timeout 5.0)
  (wait 1.0)
  (expect-running-app "com.apple.Safari"))
