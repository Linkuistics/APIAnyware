#lang racket/base
;; test-app-scanner.rkt — Tests for services/app-scanner.rkt

(require rackunit
         racket/list
         racket/string
         "../services/app-scanner.rkt")

;; --- path parsing (via scan and accessors) ---
;; We test the full scan-installed-apps which calls mdfind.
;; This is an integration test — it requires Spotlight to be available.

(define apps (scan-installed-apps))

;; Should find at least some apps (macOS always has system apps)
(check-true (> (length apps) 0)
            "should find at least one app on macOS")

;; Each app should have all four fields
(for ([app (in-list (take apps (min 5 (length apps))))])
  (check-true (string? (app-name app))
              (format "app should have string name: ~a" app))
  (check-true (string? (app-path app))
              (format "app should have string path: ~a" app))
  (check-true (string? (app-directory app))
              (format "app should have string directory: ~a" app))
  (check-true (string? (app-bundle-id app))
              (format "app should have string bundle-id: ~a" app)))

;; Paths should end with .app
(for ([app (in-list (take apps (min 5 (length apps))))])
  (check-true (regexp-match? #rx"\\.app$" (app-path app))
              (format "path should end with .app: ~a" (app-path app))))

;; Should be sorted alphabetically (case-insensitive)
(for ([i (in-range 1 (min 10 (length apps)))])
  (define prev-name (string-downcase (app-name (list-ref apps (- i 1)))))
  (define curr-name (string-downcase (app-name (list-ref apps i))))
  (check-true (string<=? prev-name curr-name)
              (format "apps should be sorted: ~a <= ~a" prev-name curr-name)))

;; Should contain well-known macOS apps
(define app-names (map app-name apps))
(check-not-false (member "Safari" app-names)
                 "should find Safari")

;; No duplicate names
(define unique-names (remove-duplicates app-names))
(check-equal? (length unique-names) (length app-names)
              "should have no duplicate names")

(displayln (format "test-app-scanner: all checks passed (~a apps found)" (length apps)))
