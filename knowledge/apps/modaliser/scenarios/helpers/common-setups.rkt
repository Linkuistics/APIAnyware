#lang racket/base
;; helpers/common-setups.rkt — composite scenario actions
;; that drive the impl into a known state (leader pressed, chooser open,
;; etc.) so individual scenarios stay focused on their assertions.
;;
;; Log-event regexes match exact emitter output. lib/events.rkt quotes
;; string values; register-tree! stores scope as a string and
;; modal-handle-key's char is a string, so tree="global" / key="f" are
;; quoted. The chooser 'selector value is the `'prompt` field of the
;; selector node, so for test-config.scm's Find Apps selector the value
;; is "Find app…" (the prompt), not "Find Apps" (the label).
;;
;; wait-for-log (not expect-log) because the VM propagation pipeline
;; — CGEvent tap → state-machine → flush → log tailer poll — has
;; non-zero latency. expect-log's single-poll check would race.

(require app-spec/main)

(provide press-leader!
         open-find-apps!)

(define (press-leader!)
  (press 'F18)
  (wait-for-log #px"\\[modal\\] enter tree=\"global\"" #:timeout 5.0))

(define (open-find-apps!)
  (press-leader!)
  (press "f")
  (wait-for-log #px"\\[modal\\] group key=\"f\"" #:timeout 5.0)
  (press "a")
  (wait-for-log #px"\\[chooser\\] open selector=\"Find app…\"" #:timeout 5.0))
