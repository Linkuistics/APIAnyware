#lang racket/base
;; app-scanner.rkt — Discover installed macOS applications via Spotlight
;;
;; Uses `mdfind` + `mdls` subprocesses to query Spotlight for all .app bundles
;; with their bundle identifiers. Returns a sorted, deduplicated list of
;; application records.
;;
;; Each app is an alist: ((name . "Foo") (path . "/Applications/Foo.app")
;;                        (directory . "/Applications") (bundle-id . "com.example.foo"))

(require racket/port
         racket/string
         racket/list)

(provide scan-installed-apps
         app-name
         app-path
         app-directory
         app-bundle-id)

;; --- App record accessors ---

(define (app-name app)      (cdr (assq 'name app)))
(define (app-path app)      (cdr (assq 'path app)))
(define (app-directory app)  (cdr (assq 'directory app)))
(define (app-bundle-id app)  (cdr (assq 'bundle-id app)))

;; --- Scanning ---

;; Query Spotlight for all application bundles.
;; Returns a list of app alists, sorted alphabetically by name, deduplicated by name.
;; Uses a two-step approach:
;;   1. mdfind discovers all .app paths
;;   2. A single mdls batch call gets all bundle IDs (avoids O(n) subprocesses)
(define (scan-installed-apps)
  (with-handlers ([exn:fail? (lambda (e)
                                (displayln (format "app-scanner: error: ~a" (exn-message e)))
                                '())])
    ;; Step 1: Get all .app paths via mdfind
    (define paths (run-mdfind))

    ;; Step 2: Get bundle IDs for all paths in one batch mdls call
    (define bundle-ids (batch-read-bundle-ids paths))

    ;; Step 3: Build app records, deduplicate by name, sort
    (define seen (make-hash))
    (define apps
      (for/list ([path-str (in-list paths)]
                 #:when (non-empty-string? path-str)
                 #:unless (hash-has-key? seen (path->name path-str)))
        (define name (path->name path-str))
        (hash-set! seen name #t)
        `((name . ,name)
          (path . ,path-str)
          (directory . ,(path->directory path-str))
          (bundle-id . ,(hash-ref bundle-ids path-str "")))))

    (sort apps (lambda (a b)
                 (string-ci<? (app-name a) (app-name b))))))

;; Run mdfind to get all .app paths.
(define (run-mdfind)
  (define-values (proc stdout stdin stderr)
    (subprocess #f #f #f "/usr/bin/mdfind"
                "kMDItemContentType == 'com.apple.application-bundle'"))
  (close-output-port stdin)
  (define output (port->string stdout))
  (define _err (port->string stderr))
  (close-input-port stdout)
  (close-input-port stderr)
  (subprocess-wait proc)
  (filter (lambda (s) (and (non-empty-string? s) (string-suffix? s ".app")))
          (string-split output "\n")))

;; Batch-read bundle IDs for a list of paths using a single mdls call.
;; Returns a hash: path → bundle-id-string.
;; mdls output format per app:
;;   kMDItemCFBundleIdentifier = "com.example.foo"
;;   kMDItemPath               = "/Applications/Foo.app"
;; or with (null) for missing values.
(define (batch-read-bundle-ids paths)
  (define result (make-hash))
  (when (null? paths)
    (return-hash result))

  ;; Use shell pipeline: mdfind -0 | xargs -0 mdls
  ;; This handles paths with spaces correctly via null delimiters.
  (define cmd
    (string-append
     "mdfind -0 \"kMDItemContentType == 'com.apple.application-bundle'\" "
     "| xargs -0 mdls -name kMDItemCFBundleIdentifier -name kMDItemPath"))

  (define-values (proc stdout stdin stderr)
    (subprocess #f #f #f "/bin/zsh" "-c" cmd))
  (close-output-port stdin)
  (define output (port->string stdout))
  (define _err (port->string stderr))
  (close-input-port stdout)
  (close-input-port stderr)
  (subprocess-wait proc)

  ;; Parse mdls output — alternating bundle-id and path lines
  (define lines (string-split output "\n"))
  (parse-mdls-pairs lines result)
  result)

;; Parse mdls key=value pairs into path→bundle-id hash.
(define (parse-mdls-pairs lines result)
  (define current-bundle-id #f)
  (for ([line (in-list lines)])
    (cond
      [(regexp-match #rx"kMDItemCFBundleIdentifier = \"(.+)\"" line)
       => (lambda (m) (set! current-bundle-id (cadr m)))]
      [(regexp-match #rx"kMDItemCFBundleIdentifier = \\(null\\)" line)
       (set! current-bundle-id "")]
      [(regexp-match #rx"kMDItemPath *= \"(.+)\"" line)
       => (lambda (m)
            (define path (cadr m))
            (hash-set! result path (or current-bundle-id ""))
            (set! current-bundle-id #f))]
      [else (void)])))

;; Extract the app name from a path: "/Applications/Foo.app" → "Foo"
(define (path->name path-str)
  (define filename (last (string-split path-str "/")))
  (if (string-suffix? filename ".app")
      (substring filename 0 (- (string-length filename) 4))
      filename))

;; Extract the parent directory from a path.
(define (path->directory path-str)
  (define idx (string-last-index-of path-str "/"))
  (if idx
      (let ([dir (substring path-str 0 idx)])
        (if (string=? dir "") "/" dir))
      "/"))

;; Find the last occurrence of a character in a string.
(define (string-last-index-of str ch)
  (for/last ([i (in-range (string-length str))]
             #:when (char=? (string-ref str i) (string-ref ch 0)))
    i))

;; Helper for early return
(define-syntax-rule (return-hash h) (void))

;; Helper — check for non-empty string
(define (non-empty-string? s)
  (and (string? s) (> (string-length s) 0)))
