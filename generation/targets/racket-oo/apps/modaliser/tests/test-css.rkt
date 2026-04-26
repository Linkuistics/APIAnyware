#lang racket/base
;; tests/test-css.rkt — Tests for ui/css.rkt

(require rackunit
         "../ui/css.rkt")

;; ─── css-rule ─────────────────────────────────────────────────

(test-case "css-rule: single property"
  (check-equal? (css-rule ".key" '((color . "red")))
                ".key { color: red; }"))

(test-case "css-rule: multiple properties"
  (check-equal? (css-rule "body" '((margin . "0") (padding . "0")))
                "body { margin: 0; padding: 0; }"))

(test-case "css-rule: complex selector"
  (check-equal? (css-rule "#overlay .entry" '((display . "flex")))
                "#overlay .entry { display: flex; }"))

(test-case "css-rule: no properties"
  (check-equal? (css-rule ".empty" '())
                ".empty {  }"))

;; ─── css-rules ────────────────────────────────────────────────

(test-case "css-rules: combines rules"
  (check-equal? (css-rules
                 (css-rule "a" '((color . "blue")))
                 (css-rule "b" '((font-weight . "bold"))))
                "a { color: blue; }\nb { font-weight: bold; }"))

(test-case "css-rules: single rule"
  (check-equal? (css-rules (css-rule "p" '((margin . "10px"))))
                "p { margin: 10px; }"))

;; ─── inline-style ─────────────────────────────────────────────

(test-case "inline-style: multiple properties"
  (check-equal? (inline-style '((color . "red") (font-size . "14px")))
                "color: red; font-size: 14px;"))

(test-case "inline-style: single property"
  (check-equal? (inline-style '((display . "none")))
                "display: none;"))

(test-case "inline-style: empty"
  (check-equal? (inline-style '()) ""))

(displayln "test-css: all tests passed")
