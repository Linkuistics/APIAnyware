#lang racket/base
;; app-menu.rkt — Install the standard macOS app menu on an NSApplication.
;;
;; Every sample app needs the same toolbar at the top of the main menu:
;;
;;     <App>
;;       About <App>
;;       ─────────────
;;       Hide <App>           ⌘H
;;       Hide Others          ⌥⌘H
;;       Show All
;;       ─────────────
;;       Quit <App>           ⌘Q
;;
;; Without this menu macOS still shows an app-name slot in the menu bar
;; (driven by `CFBundleName` from the bundle's `Info.plist`), but the
;; standard items — and the keyboard equivalents that come with them —
;; are missing. ⌘Q in particular is non-negotiable for any user-facing
;; sample app.
;;
;; ## Why raw `objc_msgSend` instead of `tell`
;;
;; `tell` from `ffi/unsafe/objc` is the usual way to send messages, but
;; the variants we need here all take SEL parameters (the `action:` slot
;; in `addItemWithTitle:action:keyEquivalent:`, etc.). `tell` reads each
;; argument's runtime type, and a Racket SEL — which is a plain
;; `cpointer` — fails its `_id` check with
;; `id->C: argument is not 'id' pointer`. The generated framework
;; bindings work around this by emitting typed `_msg-N` `objc_msgSend`
;; bindings for any selector that has a non-`_id` parameter, and
;; calling those directly. This file does the same: a small set of
;; explicitly-typed `objc_msgSend` aliases plus `sel_registerName`
;; calls, no `tell` involved for the action-bearing variants.
;;
;; Bundling note: the *bold* app-name slot in the menu bar still comes
;; from `CFBundleName` in the bundle's `Info.plist`, not from this Racket
;; code. An unbundled `racket script.rkt` will display "racket" up there
;; even with this menu installed. Bundle via
;; `apianyware-macos-bundle-racket-oo` for the full effect.

(require ffi/unsafe
         ffi/unsafe/objc
         "objc-base.rkt"
         "type-mapping.rkt")

(provide install-standard-app-menu!)

(import-class NSMenu NSMenuItem)

;; --- NSEventModifierFlag (subset used here) ---
(define NSEventModifierFlagCommand #x100000)
(define NSEventModifierFlagOption  #x80000)

;; --- Typed objc_msgSend aliases ---
;;
;; Each `_msg-*` is `objc_msgSend` typed for one specific call shape.
;; Using `_id` for objc-object args and `_pointer` for SELs lets the FFI
;; layer marshal correctly without going through `tell`'s id-only path.

(define _objc-lib (ffi-lib "libobjc"))

;; `[receiver alloc]` and similar zero-arg id-returning calls
(define _msg-0
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _id _pointer -> _id)))

;; `[receiver msg: id-arg]`
(define _msg-id
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _id _pointer _id -> _id)))

;; `[NSMenuItem alloc] init...` taking title (id), action (SEL), keyEquivalent (id)
(define _msg-init-with-title-action-key
  (get-ffi-obj "objc_msgSend" _objc-lib
               (_fun _id _pointer _id _pointer _id -> _id)))

;; `[menu addItemWithTitle: id action: SEL keyEquivalent: id] -> id`
(define _msg-add-item-with-title-action-key _msg-init-with-title-action-key)

;; `[menuItem setKeyEquivalentModifierMask: NSUInteger] -> void`
(define _msg-set-modifier-mask
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _id _pointer _uint64 -> _void)))

;; `[menuItem setSubmenu: NSMenu] -> void` and similar void/id pairs
(define _msg-id->void
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _id _pointer _id -> _void)))

;; --- Selectors (cached on first load) ---
(define sel-alloc                     (sel_registerName "alloc"))
(define sel-init-with-title           (sel_registerName "initWithTitle:"))
(define sel-init-with-title-action-key (sel_registerName "initWithTitle:action:keyEquivalent:"))
(define sel-add-item-with-title-action-key
  (sel_registerName "addItemWithTitle:action:keyEquivalent:"))
(define sel-add-item                  (sel_registerName "addItem:"))
(define sel-separator-item            (sel_registerName "separatorItem"))
(define sel-set-submenu               (sel_registerName "setSubmenu:"))
(define sel-set-main-menu             (sel_registerName "setMainMenu:"))
(define sel-set-key-equivalent-modifier-mask
  (sel_registerName "setKeyEquivalentModifierMask:"))
(define sel-about                     (sel_registerName "orderFrontStandardAboutPanel:"))
(define sel-hide                      (sel_registerName "hide:"))
(define sel-hide-others               (sel_registerName "hideOtherApplications:"))
(define sel-unhide-all                (sel_registerName "unhideAllApplications:"))
(define sel-terminate                 (sel_registerName "terminate:"))

;; --- NSString construction ---
;;
;; `string->nsstring` returns a CoreFoundation pointer that's toll-free
;; bridged to NSString, but it isn't `_id`-tagged at the FFI level — we
;; cast to `_id` so the typed `objc_msgSend` bindings accept it.
(define (ns-string s)
  (cast (string->nsstring s) _pointer _id))

;; --- Helpers ---

;; Allocate and init an NSMenu with the given title. Returns _id.
(define (make-menu title)
  (define alloced (_msg-0 (cast NSMenu _pointer _id) sel-alloc))
  (_msg-id alloced sel-init-with-title (ns-string title)))

;; Allocate and init an NSMenuItem with title, action, keyEquivalent.
;; `action` may be a SEL cpointer or `#f`.
(define (make-menu-item title action key)
  (define alloced (_msg-0 (cast NSMenuItem _pointer _id) sel-alloc))
  (_msg-init-with-title-action-key
   alloced
   sel-init-with-title-action-key
   (ns-string title)
   (or action #f)
   (ns-string key)))

(define (menu-add-item! menu item)
  (_msg-id->void menu sel-add-item item))

;; Add an item via the convenience method that returns the item back
;; (so we can mutate it further, e.g. to set a modifier mask).
(define (menu-add-item-with-title! menu title action key)
  (_msg-add-item-with-title-action-key
   menu
   sel-add-item-with-title-action-key
   (ns-string title)
   action
   (ns-string key)))

(define (separator-item)
  (_msg-0 (cast NSMenuItem _pointer _id) sel-separator-item))

;; --- The function ---
;;
;; Install the standard application menu on `application` (typically the
;; result of `nsapplication-shared-application`). Pass the human-readable
;; `app-name` (e.g. "Hello Window") — it gets interpolated into "About",
;; "Hide", and "Quit" item titles.
(define (install-standard-app-menu! application app-name)
  (define main-menu (make-menu ""))
  (define app-menu-item (make-menu-item "" #f ""))
  (define app-menu (make-menu app-name))

  ;; About <App>
  (menu-add-item-with-title! app-menu
                             (string-append "About " app-name)
                             sel-about
                             "")

  (menu-add-item! app-menu (separator-item))

  ;; Hide <App>  ⌘H
  (menu-add-item-with-title! app-menu
                             (string-append "Hide " app-name)
                             sel-hide
                             "h")

  ;; Hide Others  ⌥⌘H
  (define hide-others
    (menu-add-item-with-title! app-menu "Hide Others" sel-hide-others "h"))
  (_msg-set-modifier-mask hide-others
                          sel-set-key-equivalent-modifier-mask
                          (bitwise-ior NSEventModifierFlagCommand
                                       NSEventModifierFlagOption))

  ;; Show All
  (menu-add-item-with-title! app-menu "Show All" sel-unhide-all "")

  (menu-add-item! app-menu (separator-item))

  ;; Quit <App>  ⌘Q
  (menu-add-item-with-title! app-menu
                             (string-append "Quit " app-name)
                             sel-terminate
                             "q")

  (_msg-id->void app-menu-item sel-set-submenu app-menu)
  (menu-add-item! main-menu app-menu-item)
  (_msg-id->void (as-id application) sel-set-main-menu main-menu))
