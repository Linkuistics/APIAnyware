#lang racket/base
(require rackunit
         racket/file
         "../lib/mru-store.rkt")

;; ─── Test Setup ─────────────────────────────────────────────

(define test-mru-path (make-temporary-file "mru-test-~a.dat"))
(when (file-exists? test-mru-path) (delete-file test-mru-path))

(mru-set-path! test-mru-path)

;; ─── mru-record! and mru-get ────────────────────────────────

(test-case "mru-get returns empty for unknown key"
  (check-equal? (mru-get "unknown") '()))

(test-case "mru-record! stores and retrieves"
  (mru-record! "test-ns" "item-a")
  (check-equal? (mru-get "test-ns") '("item-a")))

(test-case "mru-record! maintains MRU order"
  (mru-record! "test-ns" "item-b")
  (mru-record! "test-ns" "item-c")
  (check-equal? (mru-get "test-ns") '("item-c" "item-b" "item-a")))

(test-case "mru-record! deduplicates — re-recording moves to front"
  (mru-record! "test-ns" "item-a")
  (check-equal? (mru-get "test-ns") '("item-a" "item-c" "item-b")))

(test-case "namespaces are independent"
  (mru-record! "other-ns" "x")
  (check-equal? (mru-get "other-ns") '("x"))
  (check-equal? (car (mru-get "test-ns")) "item-a"))

;; ─── Persistence ────────────────────────────────────────────

(test-case "data persists to disk and reloads"
  (mru-record! "persist-test" "val1")
  (mru-record! "persist-test" "val2")
  ;; Reload from disk
  (mru-load!)
  (check-equal? (mru-get "persist-test") '("val2" "val1")))

;; ─── mru-reorder-items ─────────────────────────────────────

(test-case "mru-reorder-items with no history returns items unchanged"
  (define items (list '((text . "A") (id . "1"))
                      '((text . "B") (id . "2"))
                      '((text . "C") (id . "3"))))
  (check-equal? (mru-reorder-items items "no-history" 'id) items))

(test-case "mru-reorder-items puts MRU items first"
  ;; Record some history
  (mru-record! "reorder-test" "3")
  (mru-record! "reorder-test" "1")
  ;; MRU order: "1", "3"
  (define items (list '((text . "A") (id . "1"))
                      '((text . "B") (id . "2"))
                      '((text . "C") (id . "3"))))
  (define reordered (mru-reorder-items items "reorder-test" 'id))
  ;; "1" first (most recent), then "3", then "2" (non-MRU in original order)
  (check-equal? (map (lambda (item) (cdr (assoc 'id item))) reordered)
                '("1" "3" "2")))

(test-case "mru-reorder-items handles MRU ids not in current items"
  ;; "1" and "3" are in MRU, but items only has "3" and "4"
  (define items (list '((text . "C") (id . "3"))
                      '((text . "D") (id . "4"))))
  (define reordered (mru-reorder-items items "reorder-test" 'id))
  ;; "3" moves to front, "4" stays
  (check-equal? (map (lambda (item) (cdr (assoc 'id item))) reordered)
                '("3" "4")))

(test-case "mru-reorder-items preserves items without id-field"
  (mru-record! "mixed-test" "a")
  (define items (list '((text . "X"))              ; no id field
                      '((text . "A") (id . "a"))
                      '((text . "B") (id . "b"))))
  (define reordered (mru-reorder-items items "mixed-test" 'id))
  ;; "a" moves to front, then items without id and non-MRU items follow
  (check-equal? (map (lambda (item) (cdr (assoc 'text item))) reordered)
                '("A" "X" "B")))

;; ─── Integration: simulates real config usage ──────────────

(test-case "mru-reorder-items works with symbol keys matching real app items"
  ;; Simulates find-installed-apps output (symbol keys) with
  ;; 'bundleId as id-field (already converted from string to symbol by chooser)
  (mru-record! "apps" "com.apple.Safari")
  (mru-record! "apps" "com.googlecode.iterm2")
  (define items
    (list '((text . "Chrome") (bundleId . "com.google.Chrome") (path . "/Applications/Chrome.app"))
          '((text . "iTerm") (bundleId . "com.googlecode.iterm2") (path . "/Applications/iTerm.app"))
          '((text . "Safari") (bundleId . "com.apple.Safari") (path . "/Applications/Safari.app"))
          '((text . "Zed") (bundleId . "dev.zed.Zed") (path . "/Applications/Zed.app"))))
  (define reordered (mru-reorder-items items "apps" 'bundleId))
  ;; iTerm most recent, then Safari, then rest in original order
  (check-equal? (map (lambda (item) (cdr (assoc 'text item))) reordered)
                '("iTerm" "Safari" "Chrome" "Zed")))

;; ─── Cleanup ────────────────────────────────────────────────
(when (file-exists? test-mru-path) (delete-file test-mru-path))
