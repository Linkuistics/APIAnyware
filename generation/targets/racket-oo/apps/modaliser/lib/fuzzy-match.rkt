#lang racket/base
;; lib/fuzzy-match.rkt — DP-based fuzzy string matcher (fzf/fzy-inspired)
;;
;; Finds the optimal alignment of query characters in a target string,
;; maximizing consecutive runs, word-boundary matches, and start-of-string
;; matches. Penalizes gaps between matched characters.
;;
;; API:
;;   (fuzzy-match query target) → (list score matched-indices) or #f
;;   (fuzzy-filter query texts [#:max-results n]) → list of (list index score matched-indices)
;;     sorted by score descending

(require racket/string)

(provide fuzzy-match
         fuzzy-filter)

;; ─── Scoring Constants (fzf-inspired) ───────────────────────

(define MATCH-BASE 16)
(define GAP-PENALTY -3)
(define CONSECUTIVE-BONUS 4)
(define MIN-SCORE (- (expt 2 30)))  ; sufficiently negative sentinel

;; ─── Position Bonus Computation ─────────────────────────────

;; Compute word-boundary bonuses for each position in the target.
;; Higher bonuses at word starts (after separators, camelCase transitions).
;; Returns a vector of integers, one per character.
(define (compute-position-bonuses target-chars)
  (define len (vector-length target-chars))
  (define bonus (make-vector len 0))
  (when (> len 0)
    (vector-set! bonus 0 10)  ; start of string
    (for ([j (in-range 1 len)])
      (define prev (vector-ref target-chars (sub1 j)))
      (define curr (vector-ref target-chars j))
      (vector-set! bonus j
        (cond
          [(or (char=? prev #\/) (char=? prev #\\)) 9]
          [(or (char=? prev #\space) (char=? prev #\tab)) 10]
          [(or (char=? prev #\-) (char=? prev #\_)) 8]
          [(char=? prev #\.) 7]
          [(and (char-lower-case? prev) (char-upper-case? curr)) 7]
          [else 0]))))
  bonus)

;; ─── Core DP Matcher ────────────────────────────────────────

;; (fuzzy-match query target) → (list score matched-indices) or #f
;;
;; query: string to search for (matched case-insensitively)
;; target: string to search in
;; Returns: (list score (list idx ...)) where idx are 0-based character positions,
;;          or #f if no match is possible.
(define (fuzzy-match query target)
  (cond
    [(string=? query "")
     (list 1 '())]
    [else
     (define query-chars (string->vector (string-downcase query)))
     (define target-original (string->vector target))
     (define target-lower (string->vector (string-downcase target)))
     (define n (vector-length query-chars))
     (define m (vector-length target-lower))

     (cond
       [(> n m) #f]
       [else
        ;; Quick existence check: greedy forward scan
        (define exists?
          (let loop ([qi 0] [ti 0])
            (cond
              [(= qi n) #t]
              [(= ti m) #f]
              [(char=? (vector-ref query-chars qi) (vector-ref target-lower ti))
               (loop (add1 qi) (add1 ti))]
              [else (loop qi (add1 ti))])))

        (cond
          [(not exists?) #f]
          [else
           ;; Precompute position bonuses
           (define bonus (compute-position-bonuses target-original))

           ;; DP with flat vectors: index = i*m+j
           ;; best-scores[i*m+j]  = best score matching query[0..i] ending at target[j]
           ;; consec-scores[i*m+j] = same but target[j-1] matched query[i-1] (consecutive)
           ;; traceback[i*m+j]    = previous j position for traceback
           (define size (* n m))
           (define best-scores (make-vector size MIN-SCORE))
           (define consec-scores (make-vector size MIN-SCORE))
           (define traceback (make-vector size -1))

           ;; Row 0: first query character
           (for ([j (in-range m)])
             (when (char=? (vector-ref target-lower j) (vector-ref query-chars 0))
               (define score (+ MATCH-BASE (vector-ref bonus j)))
               (vector-set! best-scores j score)
               (vector-set! consec-scores j score)))

           ;; Rows 1..n-1
           (for ([i (in-range 1 n)])
             (define row (* i m))
             (define prev-row (* (sub1 i) m))
             (define best-prev-score MIN-SCORE)
             (define best-prev-pos -1)

             (for ([j (in-range i m)])
               ;; Track running max of previous row for gap path
               (when (and (> j 0)
                          (> (vector-ref best-scores (+ prev-row (sub1 j)))
                             best-prev-score))
                 (set! best-prev-score
                   (vector-ref best-scores (+ prev-row (sub1 j))))
                 (set! best-prev-pos (sub1 j)))

               (when (char=? (vector-ref target-lower j)
                             (vector-ref query-chars i))
                 (define pos-bonus (vector-ref bonus j))

                 ;; Consecutive path: query[i-1] matched at target[j-1]
                 (define d-score
                   (if (> j 0)
                       (let* ([prev-best (vector-ref best-scores (+ prev-row (sub1 j)))]
                              [prev-consec (vector-ref consec-scores (+ prev-row (sub1 j)))]
                              [from-consec
                               (if (> prev-consec MIN-SCORE)
                                   (+ prev-consec MATCH-BASE (max pos-bonus CONSECUTIVE-BONUS))
                                   MIN-SCORE)]
                              [from-best
                               (if (> prev-best MIN-SCORE)
                                   (+ prev-best MATCH-BASE pos-bonus)
                                   MIN-SCORE)])
                         (max from-consec from-best))
                       MIN-SCORE))
                 (vector-set! consec-scores (+ row j) d-score)

                 ;; Gap path: best M[i-1][k] for k < j, plus gap penalty
                 (define g-score
                   (if (> best-prev-score MIN-SCORE)
                       (+ best-prev-score GAP-PENALTY MATCH-BASE pos-bonus)
                       MIN-SCORE))

                 (cond
                   [(and (>= d-score g-score) (> d-score MIN-SCORE))
                    (vector-set! best-scores (+ row j) d-score)
                    (vector-set! traceback (+ row j) (sub1 j))]
                   [(> g-score MIN-SCORE)
                    (vector-set! best-scores (+ row j) g-score)
                    (vector-set! traceback (+ row j) best-prev-pos)]))))

           ;; Find best ending position in last row
           (define last-row (* (sub1 n) m))
           (define-values (final-score final-pos)
             (for/fold ([best MIN-SCORE] [pos -1])
                       ([j (in-range (sub1 n) m)])
               (define s (vector-ref best-scores (+ last-row j)))
               (if (> s best)
                   (values s j)
                   (values best pos))))

           (cond
             [(or (<= final-score MIN-SCORE) (< final-pos 0)) #f]
             [else
              ;; Traceback to recover matched positions
              (define matched
                (let loop ([i (sub1 n)] [j final-pos] [acc '()])
                  (define new-acc (cons j acc))
                  (if (= i 0)
                      new-acc
                      (loop (sub1 i)
                            (vector-ref traceback (+ (* i m) j))
                            new-acc))))
              (list final-score matched)])])])]))

;; ─── Batch Filter ───────────────────────────────────────────

;; (fuzzy-filter query texts [#:max-results n]) → list of (list index score matched-indices)
;;
;; Match query against each string in texts (a list of strings).
;; Returns results sorted by score descending, limited to max-results.
;; Applies a match-proportion bonus: queries covering more of the target
;; score higher (e.g., "dev" matching "Development" >> matching a 150-char path).
(define (fuzzy-filter query texts #:max-results [max-results 100])
  (define query-len (string-length query))
  (cond
    [(string=? query "")
     ;; Empty query: return first max-results items with score 1
     (define limit (min (length texts) max-results))
     (for/list ([i (in-range limit)])
       (list i 1 '()))]
    [else
     ;; Match each text and apply proportion bonus
     (define matches
       (for/fold ([acc '()])
                 ([text (in-list texts)]
                  [i (in-naturals)])
         (define result (fuzzy-match query text))
         (if result
             (let* ([raw-score (car result)]
                    [indices (cadr result)]
                    [target-len (max (string-length text) 1)]
                    [proportion (quotient (* query-len 100) target-len)]
                    [adjusted-score (+ raw-score proportion)])
               (cons (list i adjusted-score indices) acc))
             acc)))
     ;; Sort by score descending, take top results
     (define sorted (sort matches > #:key cadr))
     (if (> (length sorted) max-results)
         (take sorted max-results)
         sorted)]))

;; ─── Helpers ────────────────────────────────────────────────

(define (string->vector s)
  (list->vector (string->list s)))

(define (take lst n)
  (if (or (zero? n) (null? lst))
      '()
      (cons (car lst) (take (cdr lst) (sub1 n)))))
