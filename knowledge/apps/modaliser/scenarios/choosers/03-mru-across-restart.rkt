#lang app-spec

;; MRU persistence across impl restart.
;;
;; Selecting TextEdit emits [mru] record key="apps" id="com.apple.TextEdit"
;; and appends to ~/.config/modaliser/mru.dat via lib/mru-store.rkt. The
;; remember-key and id-value are both strings (from test-config.scm's
;; 'remember "apps" and the chooser item's bundleId), so events.rkt
;; quotes both — the plan's bare `key=apps` would not match.
;;
;; restart-impl! quits and relaunches the impl; mru-load! at startup
;; reads mru.dat back, so the TextEdit entry survives. read-mru reads
;; the file directly via the driver and returns a hash keyed by the
;; same string "apps".

(require "../helpers/common-setups.rkt")

(scenario "mru-persists-across-restart"
  #:description "Select TextEdit; restart impl; MRU survives"
  (open-find-apps!)
  (type "textedit")
  (wait-for-ocr "TextEdit" #:timeout 3.0)
  (press 'Return)
  (wait-for-log #px"\\[mru\\] record key=\"apps\" id=\"com\\.apple\\.TextEdit\""
                #:timeout 5.0)
  (wait 1.0)

  (restart-impl!)
  (wait-for-log #px"\\[lifecycle\\] startup" #:timeout 10.0)

  (define mru (read-mru))
  (unless (member "com.apple.TextEdit" (hash-ref mru "apps" '()))
    (error 'mru-persists
           "TextEdit not in MRU after restart: ~v" mru)))
