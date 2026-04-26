#lang racket/base
;; test-config-loading.rkt — End-to-end test for config.scm loading
;;
;; Loads the actual user config (~/.config/modaliser/config.scm) via the
;; config loader and verifies:
;; 1. No eval errors during loading
;; 2. All expected trees are registered (global + app-local)
;; 3. Tree structure matches expectations (groups, keys, selectors)
;; 4. Representative commands can be invoked structurally

(require rackunit
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../core/keymap.rkt"
         "../core/state-machine.rkt"
         "../core/event-dispatch.rkt"
         "../lib/dsl.rkt"
         "../lib/config-loader.rkt"
         "../ffi/permissions.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

;; ─── Setup NSApplication (needed for ObjC bindings) ─────────────

(define NSApplicationActivationPolicyAccessory 1)
(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app NSApplicationActivationPolicyAccessory))

;; ─── Start keyboard dispatch (wires up leader hooks) ────────────

(unless (accessibility-trusted?)
  (eprintf "test-config-loading: accessibility permission required — grant racket access in System Settings → Privacy & Security → Accessibility\n")
  (exit 1))

(unless (start-keyboard-dispatch!)
  (eprintf "test-config-loading: start-keyboard-dispatch! returned #f — CGEvent tap install failed\n")
  (exit 1))

;; ─── Stub overlay hooks (no UI during tests) ────────────────────

(clear-trees!)
(set-overlay-delay! 0)

(set-overlay-hooks!
 #:show (lambda (r p) (void))
 #:update (lambda (r p) (void))
 #:hide (lambda () (void))
 #:open-chooser (lambda (n) (void))
 #:open? (lambda () #f))

;; ═══════════════════════════════════════════════════════════════════
;; Test 1: Config file exists
;; ═══════════════════════════════════════════════════════════════════

(displayln "--- Test 1: Config file exists ---")
(check-true (file-exists? config-path)
            (format "config.scm must exist at ~a" config-path))

;; ═══════════════════════════════════════════════════════════════════
;; Test 2: Config loads without errors
;; ═══════════════════════════════════════════════════════════════════

(displayln "--- Test 2: Config loads without errors ---")

;; Capture stderr to detect config errors
(define error-output (open-output-string))
(define original-stderr (current-error-port))

(parameterize ([current-error-port error-output])
  (load-config!))

(define errors (get-output-string error-output))
(check-equal? errors ""
              (format "config should load without errors, got: ~a" errors))

;; ═══════════════════════════════════════════════════════════════════
;; Test 3: Global tree registered
;; ═══════════════════════════════════════════════════════════════════

(displayln "--- Test 3: Global tree registered ---")

(define global-tree (lookup-tree 'global))
(check-not-false global-tree "global tree must be registered")
(check-true (group? global-tree) "global tree root must be a group")

;; Check known top-level keys in global tree
(define global-children (node-children global-tree))
(define global-keys (map node-key global-children))

(displayln (format "  Global tree has ~a entries: ~a" (length global-children) global-keys))

(check-not-false (member "s" global-keys) "global tree should have 's' (Safari)")
(check-not-false (member "i" global-keys) "global tree should have 'i' (iTerm)")
(check-not-false (member "z" global-keys) "global tree should have 'z' (Zed)")
(check-not-false (member " " global-keys) "global tree should have ' ' (Spotlight)")
(check-not-false (member "," global-keys) "global tree should have ',' (Settings)")
(check-not-false (member "g" global-keys) "global tree should have 'g' (Google)")
(check-not-false (member "f" global-keys) "global tree should have 'f' (Find)")
(check-not-false (member "o" global-keys) "global tree should have 'o' (Open App)")
(check-not-false (member "w" global-keys) "global tree should have 'w' (Windows)")
(check-not-false (member "n" global-keys) "global tree should have 'n' (Notes)")

;; ═══════════════════════════════════════════════════════════════════
;; Test 4: Global tree structure — groups and selectors
;; ═══════════════════════════════════════════════════════════════════

(displayln "--- Test 4: Tree structure validation ---")

;; Find group
(define find-group (find-child global-tree "f"))
(check-not-false find-group "'f' (Find) must exist")
(check-true (group? find-group) "'f' must be a group")

(define find-children (node-children find-group))
(define find-keys (map node-key find-children))
(displayln (format "  Find group has ~a entries: ~a" (length find-children) find-keys))

(check-not-false (member "a" find-keys) "Find group should have 'a' (Find Apps)")
(check-not-false (member "f" find-keys) "Find group should have 'f' (Find File)")
(check-not-false (member "w" find-keys) "Find group should have 'w' (Window)")

;; Verify Find Apps is a selector
(define find-apps (find-child find-group "a"))
(check-not-false find-apps "'a' (Find Apps) must exist")
(check-true (selector? find-apps) "'a' must be a selector")

;; Windows group
(define win-group (find-child global-tree "w"))
(check-not-false win-group "'w' (Windows) must exist")
(check-true (group? win-group) "'w' must be a group")

(define win-children (node-children win-group))
(define win-keys (map node-key win-children))
(displayln (format "  Windows group has ~a entries: ~a" (length win-children) win-keys))

(check-not-false (member "d" win-keys) "Windows should have 'd' (First Third)")
(check-not-false (member "c" win-keys) "Windows should have 'c' (Center)")
(check-not-false (member "m" win-keys) "Windows should have 'm' (Maximise)")

;; Google selector
(define google-selector (find-child global-tree "g"))
(check-not-false google-selector "'g' (Google Search) must exist")
(check-true (selector? google-selector) "'g' must be a selector")

;; ═══════════════════════════════════════════════════════════════════
;; Test 5: App-local trees registered
;; ═══════════════════════════════════════════════════════════════════

(displayln "--- Test 5: App-local trees registered ---")

(define safari-tree (lookup-tree "com.apple.Safari"))
(check-not-false safari-tree "Safari tree must be registered")

(define zed-tree (lookup-tree "dev.zed.Zed"))
(check-not-false zed-tree "Zed tree must be registered")

(define iterm-tree (lookup-tree "com.googlecode.iterm2"))
(check-not-false iterm-tree "iTerm tree must be registered")

;; Verify Safari tree structure
(define safari-children (node-children safari-tree))
(define safari-keys (map node-key safari-children))
(displayln (format "  Safari tree has ~a entries: ~a" (length safari-children) safari-keys))
(check-not-false (member "t" safari-keys) "Safari should have 't' (Tabs)")
(check-not-false (member "b" safari-keys) "Safari should have 'b' (Browser)")

;; ═══════════════════════════════════════════════════════════════════
;; Test 6: Command actions are callable
;; ═══════════════════════════════════════════════════════════════════

(displayln "--- Test 6: Command actions are callable ---")

;; Safari quick-launch: should be a lambda that calls launch-app
(define safari-cmd (find-child global-tree "s"))
(check-not-false safari-cmd "'s' (Safari) must exist")
(check-true (command? safari-cmd) "'s' must be a command")
(check-true (procedure? (node-action safari-cmd))
            "Safari command must have a callable action")

;; Spotlight keystroke: verify it's a procedure
(define spotlight-cmd (find-child global-tree " "))
(check-not-false spotlight-cmd "' ' (Spotlight) must exist")
(check-true (procedure? (node-action spotlight-cmd))
            "Spotlight command must have a callable action")

;; Window move: verify it's a procedure (uses fractional coords)
(define first-third (find-child win-group "d"))
(check-not-false first-third "'d' (First Third) must exist")
(check-true (procedure? (node-action first-third))
            "First Third command must have a callable action")

;; ═══════════════════════════════════════════════════════════════════
;; Test 7: Selector properties are preserved
;; ═══════════════════════════════════════════════════════════════════

(displayln "--- Test 7: Selector properties ---")

;; Google selector should have dynamic-search and on-select
(define (selector-prop node key)
  (define pair (assoc key node))
  (and pair (cdr pair)))

(check-true (procedure? (selector-prop google-selector 'dynamic-search))
            "Google selector must have dynamic-search handler")
(check-true (procedure? (selector-prop google-selector 'on-select))
            "Google selector must have on-select handler")
(check-equal? (selector-prop google-selector 'prompt)
              "Search Google…"
              "Google selector prompt must match")

;; Find Apps should have source, on-select, actions
(check-true (procedure? (selector-prop find-apps 'source))
            "Find Apps must have source function")
(check-true (procedure? (selector-prop find-apps 'on-select))
            "Find Apps must have on-select handler")
(check-true (list? (selector-prop find-apps 'actions))
            "Find Apps must have actions list")

;; ═══════════════════════════════════════════════════════════════════
;; Summary
;; ═══════════════════════════════════════════════════════════════════

(displayln "\n=== Config loading tests complete ===")
