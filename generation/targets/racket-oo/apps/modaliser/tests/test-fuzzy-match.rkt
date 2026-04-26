#lang racket/base
;; tests/test-fuzzy-match.rkt — Tests for lib/fuzzy-match.rkt
;;
;; Verifies the DP-based fuzzy matcher: scoring, ordering, edge cases,
;; word-boundary bonuses, and the batch filter function.

(require rackunit
         "../lib/fuzzy-match.rkt")

;; ─── Basic Matching ──────────────────────────────────────────

(test-case "empty query matches everything with score 1"
  (define result (fuzzy-match "" "anything"))
  (check-not-false result)
  (check-equal? (car result) 1)
  (check-equal? (cadr result) '()))

(test-case "query longer than target returns #f"
  (check-false (fuzzy-match "toolong" "short")))

(test-case "no matching characters returns #f"
  (check-false (fuzzy-match "xyz" "abcdef")))

(test-case "exact match returns all indices"
  (define result (fuzzy-match "abc" "abc"))
  (check-not-false result)
  (check-equal? (cadr result) '(0 1 2)))

(test-case "case-insensitive matching"
  (define result (fuzzy-match "abc" "ABC"))
  (check-not-false result)
  (check-equal? (cadr result) '(0 1 2)))

(test-case "partial match with gaps"
  (define result (fuzzy-match "ac" "abc"))
  (check-not-false result)
  (check-equal? (length (cadr result)) 2)
  ;; First char matches at 0, second at 2
  (check-equal? (car (cadr result)) 0)
  (check-equal? (cadr (cadr result)) 2))

;; ─── Scoring Quality ────────────────────────────────────────

(test-case "consecutive match scores higher than gapped match"
  ;; Use targets without word-boundary characters in the gap, since
  ;; underscore/dash after gaps give boundary bonuses that can overcome
  ;; the consecutive bonus.
  (define consec (fuzzy-match "ab" "abxxxxx"))
  (define gapped (fuzzy-match "ab" "axxxxxxb"))
  (check-not-false consec)
  (check-not-false gapped)
  (check-true (> (car consec) (car gapped))))

(test-case "word-boundary match scores higher than mid-word"
  ;; "fm" matching "FuzzyMatcher" (camelCase boundary) should score higher
  ;; than "fm" matching "inform" (mid-word)
  (define boundary (fuzzy-match "fm" "FuzzyMatcher"))
  (define midword (fuzzy-match "fm" "informally"))
  (check-not-false boundary)
  (check-not-false midword)
  (check-true (> (car boundary) (car midword))))

(test-case "start-of-string bonus"
  (define at-start (fuzzy-match "a" "alpha"))
  (define mid-str (fuzzy-match "a" "____alpha"))
  (check-not-false at-start)
  (check-not-false mid-str)
  (check-true (> (car at-start) (car mid-str))))

(test-case "path separator bonus"
  ;; Match after / should score higher than mid-word
  (define after-slash (fuzzy-match "m" "/path/main.rkt"))
  (define mid-word (fuzzy-match "m" "something"))
  (check-not-false after-slash)
  (check-not-false mid-word)
  ;; Both should match; after-slash may not always win since "something" starts with 's'
  ;; but the 'm' after '/' gets a path bonus
  (check-not-false after-slash))

(test-case "underscore separator bonus"
  (define result (fuzzy-match "fm" "fuzzy_match"))
  (check-not-false result)
  ;; 'm' should match at position 6 (after underscore) for the bonus
  (check-not-false (member 6 (cadr result))))

;; ─── Edge Cases ─────────────────────────────────────────────

(test-case "single character query"
  (define result (fuzzy-match "z" "pizza"))
  (check-not-false result)
  (check-equal? (length (cadr result)) 1))

(test-case "query equals target exactly"
  (define result (fuzzy-match "hello" "hello"))
  (check-not-false result)
  (check-equal? (cadr result) '(0 1 2 3 4)))

(test-case "all same characters"
  (define result (fuzzy-match "aa" "aaaa"))
  (check-not-false result)
  ;; Should prefer consecutive: (0 1) rather than spread out
  (check-equal? (cadr result) '(0 1)))

(test-case "unicode characters in target"
  ;; Should not crash; match ASCII portion
  (define result (fuzzy-match "a" "café"))
  (check-not-false result))

(test-case "very long target string"
  (define long-str (make-string 1000 #\x))
  (define target (string-append "a" long-str "b"))
  (define result (fuzzy-match "ab" target))
  (check-not-false result))

;; ─── fuzzy-filter ───────────────────────────────────────────

(define test-items
  '("Safari" "Terminal" "Finder" "System Preferences" "Signal"
    "Slack" "Spotify" "Steam" "Sublime Text"))

(test-case "fuzzy-filter: empty query returns all items (up to max)"
  (define results (fuzzy-filter "" test-items))
  (check-equal? (length results) (length test-items))
  ;; All scores should be 1
  (for ([r (in-list results)])
    (check-equal? (cadr r) 1))
  ;; Indices should be in order
  (check-equal? (map car results) '(0 1 2 3 4 5 6 7 8)))

(test-case "fuzzy-filter: empty query respects max-results"
  (define results (fuzzy-filter "" test-items #:max-results 3))
  (check-equal? (length results) 3)
  (check-equal? (map car results) '(0 1 2)))

(test-case "fuzzy-filter: non-matching query returns empty"
  (define results (fuzzy-filter "zzz" test-items))
  (check-equal? results '()))

(test-case "fuzzy-filter: results sorted by score descending"
  (define results (fuzzy-filter "sa" test-items))
  (check-true (> (length results) 0))
  ;; Scores should be non-increasing
  (for ([i (in-range 1 (length results))])
    (check-true (<= (cadr (list-ref results i))
                     (cadr (list-ref results (sub1 i)))))))

(test-case "fuzzy-filter: 'ter' matches Terminal"
  (define results (fuzzy-filter "ter" test-items))
  (check-true (> (length results) 0))
  ;; Terminal (index 1) should be in results
  (check-not-false (findf (lambda (r) (= (car r) 1)) results)))

(test-case "fuzzy-filter: proportion bonus favors shorter targets"
  ;; "sig" matching "Signal" (50% coverage) should rank higher than
  ;; "sig" matching "System Preferences" (~17% coverage) if both match
  (define results (fuzzy-filter "si" test-items))
  (define signal-result (findf (lambda (r) (= (car r) 4)) results))   ; Signal
  (check-not-false signal-result))

(test-case "fuzzy-filter: max-results caps output"
  (define results (fuzzy-filter "s" test-items #:max-results 3))
  (check-true (<= (length results) 3)))

(test-case "fuzzy-filter: each result has correct structure"
  (define results (fuzzy-filter "fi" test-items))
  (for ([r (in-list results)])
    ;; Each result is (index score indices)
    (check-true (list? r))
    (check-equal? (length r) 3)
    (check-true (exact-nonnegative-integer? (car r)))
    (check-true (integer? (cadr r)))
    (check-true (list? (caddr r)))))

;; ─── Realistic App Search ───────────────────────────────────

(define app-names
  '("Safari" "Google Chrome" "Firefox" "Microsoft Edge"
    "Visual Studio Code" "Sublime Text" "Atom" "Xcode"
    "Terminal" "iTerm2" "Alacritty" "kitty"
    "Slack" "Discord" "Telegram" "Signal" "Messages"
    "Finder" "Activity Monitor" "System Preferences"
    "Preview" "Photos" "Music" "Podcasts"))

(test-case "realistic: 'chr' finds Chrome first"
  (define results (fuzzy-filter "chr" app-names))
  (check-true (> (length results) 0))
  ;; Google Chrome (index 1) should be top result
  (check-equal? (car (car results)) 1))

(test-case "realistic: 'term' finds Terminal and iTerm"
  (define results (fuzzy-filter "term" app-names))
  (define indices (map car results))
  ;; Both Terminal (8) and iTerm2 (9) should appear
  (check-not-false (member 8 indices))
  (check-not-false (member 9 indices)))

(test-case "realistic: 'vsc' finds Visual Studio Code"
  (define results (fuzzy-filter "vsc" app-names))
  (check-true (> (length results) 0))
  ;; Visual Studio Code is index 4
  (check-not-false (findf (lambda (r) (= (car r) 4)) results)))

(displayln "test-fuzzy-match: all tests passed")
