#lang racket/base
;; lib/mru-store.rkt — MRU (most recently used) persistence for chooser selectors
;;
;; Stores ordered lists of item identifiers, keyed by a namespace string
;; (the 'remember property from selector config). Persists to disk as a
;; Racket hash literal.
;;
;; API:
;;   (mru-record! remember-key id-value)  — push id to front of MRU list
;;   (mru-get remember-key)               — get ordered list of ids (most recent first)
;;   (mru-reorder-items items remember-key id-field) — reorder items: MRU first, rest in original order
;;   (mru-load!)                          — load from disk (called at startup)
;;   (mru-set-path! path)                 — override storage path (for testing)

(require racket/file
         racket/list
         racket/path
         racket/set
         "events.rkt")

(provide mru-record!
         mru-get
         mru-reorder-items
         mru-load!
         mru-set-path!)

;; ─── Configuration ──────────────────────────────────────────

(define mru-max-entries 50)

(define mru-default-path
  (build-path (find-system-path 'home-dir) ".config" "modaliser" "mru.dat"))

(define mru-path mru-default-path)

(define (mru-set-path! path)
  (set! mru-path path))

;; ─── In-memory Store ────────────────────────────────────────

;; Hash: string → (listof any)
;; Keys are remember-key strings, values are ordered id lists (MRU first).
(define mru-store (make-hash))

;; ─── Persistence ────────────────────────────────────────────

(define (mru-load!)
  (when (file-exists? mru-path)
    (with-handlers ([exn:fail? (lambda (e)
                                 (displayln (format "warning: failed to load MRU data: ~a"
                                                    (exn-message e))))])
      (define data (file->value mru-path))
      (when (hash? data)
        (set! mru-store (make-hash (hash->list data)))))))

(define (mru-save!)
  (with-handlers ([exn:fail? (lambda (e)
                               (displayln (format "warning: failed to save MRU data: ~a"
                                                  (exn-message e))))])
    (define dir (path-only mru-path))
    (when (and dir (not (directory-exists? dir)))
      (make-directory* dir))
    (write-to-file (make-immutable-hash (hash->list mru-store))
                   mru-path
                   #:exists 'replace)))

;; ─── API ────────────────────────────────────────────────────

;; (mru-record! remember-key id-value) — push id to front, dedup, cap at max.
(define (mru-record! remember-key id-value)
  (define current (hash-ref mru-store remember-key '()))
  (define updated (cons id-value (filter (lambda (v) (not (equal? v id-value))) current)))
  (define capped (if (> (length updated) mru-max-entries)
                     (take updated mru-max-entries)
                     updated))
  (hash-set! mru-store remember-key capped)
  (log-event 'mru 'record 'key remember-key 'id (format "~a" id-value))
  (mru-save!))

;; (mru-get remember-key) — list of ids, most recent first. Empty if unknown key.
(define (mru-get remember-key)
  (hash-ref mru-store remember-key '()))

;; (mru-reorder-items items remember-key id-field) → reordered items list
;; MRU items first (in MRU order), then remaining items in their original order.
;; id-field: symbol key to extract the identity value from each item alist.
(define (mru-reorder-items items remember-key id-field)
  (define mru-ids (mru-get remember-key))
  (if (null? mru-ids)
      items  ; nothing to reorder
      (let ()
        ;; Build index: id-value → item (first occurrence wins for dedup)
        (define id->item (make-hash))
        (define seen-ids '())
        (for ([item (in-list items)])
          (define pair (assoc id-field item))
          (when (and pair (not (hash-has-key? id->item (cdr pair))))
            (hash-set! id->item (cdr pair) item)
            (set! seen-ids (cons (cdr pair) seen-ids))))
        ;; Partition: MRU items that exist in current items, rest in original order
        (define mru-items
          (filter values
                  (map (lambda (id) (hash-ref id->item id #f)) mru-ids)))
        (define mru-id-set (list->set mru-ids))
        (define rest-items
          (filter (lambda (item)
                    (define pair (assoc id-field item))
                    (or (not pair)
                        (not (set-member? mru-id-set (cdr pair)))))
                  items))
        (append mru-items rest-items))))
