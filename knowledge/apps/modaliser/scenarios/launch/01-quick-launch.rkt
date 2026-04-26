#lang app-spec

;; Table-driven scenario: one run per quick-launch binding.
;;
;; helpers/quick-launch.rkt's `quick-launch-bindings` table must stay in
;; sync with the 'global tree in spec/config/test-config.scm. Each entry
;; binds a modal key (e.g. "s") to `(launch-bundle "com.apple.Safari")`,
;; which calls activate-app and emits [launch] bundle id="..." via
;; lib/util.rkt.
;;
;; The `scenario` form is a registration macro, so running it inside a
;; for-loop produces one registered scenario per iteration — the runner
;; harvests them all from `scenario-registry` afterward.
;;
;; Plan snippet used the regex `bundle=<id>` (bare), but the actual
;; emission is `bundle id="<id>"` (event-name then quoted-string key).

(require "../helpers/quick-launch.rkt"
         racket/format)

(for ([b (in-list quick-launch-bindings)])
  (scenario (format "quick-launch-~a" (binding-label b))
    #:description (format "F18 ~a launches ~a" (binding-key b) (binding-label b))
    (press 'F18)
    (wait-for-log #px"\\[modal\\] enter tree=\"global\"" #:timeout 5.0)
    (press (binding-key b))
    (wait-for-log (pregexp (format "\\[launch\\] bundle id=\"~a\""
                                   (regexp-quote (binding-bundle b))))
                  #:timeout 5.0)
    (wait 1.0)
    (expect-running-app (binding-bundle b))))
