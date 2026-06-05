;;; runtime/cocoa.ss — gerbil target Cocoa app-support helpers.
;;;
;;; The small layer every sample app needs on top of the generated bindings:
;;;   - by-value geometry constructors (CGRect/CGPoint/CGSize) — the generated
;;;     class modules consume geometry structs by value (FINDINGS §4, ADR-0020)
;;;     but expose no constructor, so apps build them here.
;;;   - the standard application menu (About/Hide/Quit), a near-mechanical port
;;;     of the chez target's `runtime/cocoa.sls`.
;;;
;;; CoreGraphics is plain-C-safe, so the geometry `define-c-lambda`s compile
;;; under the default gcc-15 like the rest of the runtime (ADR-0021); the menu
;;; rides the libobjc seam (objc_getClass / sel_registerName / objc_msgSend),
;;; also C-safe. Imported by app code, NOT by the generated bindings.
(import :std/foreign
        :gerbil-bindings/runtime/ffi
        :gerbil-bindings/runtime/objc)
(export make-rect make-point make-size
        rect-x rect-y rect-width rect-height
        install-standard-app-menu!)

;; --- geometry (by value) --------------------------------------------------
;; A CGRect built here flows by value into a generated constructor's
;; `(c-define-type CGRect (struct "CGRect"))` crossing — both spell the same C
;; struct, so Gambit passes it across the module boundary unchanged.
(begin-ffi (make-rect make-point make-size
            rect-x rect-y rect-width rect-height)
  (c-declare "#include <CoreGraphics/CGGeometry.h>")
  (c-define-type CGRect  (struct "CGRect"))
  (c-define-type CGPoint (struct "CGPoint"))
  (c-define-type CGSize  (struct "CGSize"))
  (define-c-lambda make-rect (double double double double) CGRect
    "CGRect r = CGRectMake(___arg1, ___arg2, ___arg3, ___arg4); ___return(r);")
  (define-c-lambda make-point (double double) CGPoint
    "CGPoint p = CGPointMake(___arg1, ___arg2); ___return(p);")
  (define-c-lambda make-size (double double) CGSize
    "CGSize s = CGSizeMake(___arg1, ___arg2); ___return(s);")
  (define-c-lambda rect-x      (CGRect) double "___return(___arg1.origin.x);")
  (define-c-lambda rect-y      (CGRect) double "___return(___arg1.origin.y);")
  (define-c-lambda rect-width  (CGRect) double "___return(___arg1.size.width);")
  (define-c-lambda rect-height (CGRect) double "___return(___arg1.size.height);"))

;; --- standard application menu --------------------------------------------
;; About <App> / Hide <App> ⌘H / Hide Others ⌥⌘H / Show All / Quit <App> ⌘Q.
;; The bold app-name slot in the menu bar comes from CFBundleName in the bundle
;; Info.plist (the bundler, leaf 030); unbundled it shows the exe name.
;;
;; All msgSend shapes used here, cast per-signature inside one begin-ffi block
;; (the compiled-FFI equivalent of chez's per-shape `foreign-procedure`s).
(begin-ffi (menu-alloc-init-title menu-item-alloc-init
            menu-add-item-title-action-key! menu-add-item!
            menu-separator-item menu-item-set-submenu!
            menu-item-set-key-modifier-mask! app-set-main-menu!)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  ;; [[NSMenu alloc] initWithTitle:title]
  (define-c-lambda menu-alloc-init-title ((pointer void)) (pointer void)
    "id m = ((id(*)(id,SEL))objc_msgSend)((id)objc_getClass(\"NSMenu\"), sel_registerName(\"alloc\"));
     ___return(((id(*)(id,SEL,id))objc_msgSend)(m, sel_registerName(\"initWithTitle:\"), (id)___arg1));")
  ;; [[NSMenuItem alloc] initWithTitle:action:keyEquivalent:]
  (define-c-lambda menu-item-alloc-init ((pointer void) (pointer void) (pointer void)) (pointer void)
    "id it = ((id(*)(id,SEL))objc_msgSend)((id)objc_getClass(\"NSMenuItem\"), sel_registerName(\"alloc\"));
     ___return(((id(*)(id,SEL,id,SEL,id))objc_msgSend)(it, sel_registerName(\"initWithTitle:action:keyEquivalent:\"), (id)___arg1, (SEL)___arg2, (id)___arg3));")
  ;; [menu addItemWithTitle:action:keyEquivalent:] -> the created NSMenuItem
  (define-c-lambda menu-add-item-title-action-key! ((pointer void) (pointer void) (pointer void) (pointer void)) (pointer void)
    "___return(((id(*)(id,SEL,id,SEL,id))objc_msgSend)((id)___arg1, sel_registerName(\"addItemWithTitle:action:keyEquivalent:\"), (id)___arg2, (SEL)___arg3, (id)___arg4));")
  ;; [menu addItem:item]
  (define-c-lambda menu-add-item! ((pointer void) (pointer void)) void
    "((void(*)(id,SEL,id))objc_msgSend)((id)___arg1, sel_registerName(\"addItem:\"), (id)___arg2);")
  ;; [NSMenuItem separatorItem]
  (define-c-lambda menu-separator-item () (pointer void)
    "___return(((id(*)(id,SEL))objc_msgSend)((id)objc_getClass(\"NSMenuItem\"), sel_registerName(\"separatorItem\")));")
  ;; [item setSubmenu:menu]
  (define-c-lambda menu-item-set-submenu! ((pointer void) (pointer void)) void
    "((void(*)(id,SEL,id))objc_msgSend)((id)___arg1, sel_registerName(\"setSubmenu:\"), (id)___arg2);")
  ;; [item setKeyEquivalentModifierMask:mask]
  (define-c-lambda menu-item-set-key-modifier-mask! ((pointer void) unsigned-long) void
    "((void(*)(id,SEL,unsigned long))objc_msgSend)((id)___arg1, sel_registerName(\"setKeyEquivalentModifierMask:\"), ___arg2);")
  ;; [app setMainMenu:menu]
  (define-c-lambda app-set-main-menu! ((pointer void) (pointer void)) void
    "((void(*)(id,SEL,id))objc_msgSend)((id)___arg1, sel_registerName(\"setMainMenu:\"), (id)___arg2);"))

;; A SEL for the standard app selectors, as a raw foreign pointer.
(begin-ffi (selector)
  (c-declare "#include <objc/runtime.h>")
  (define-c-lambda selector (char-string) (pointer void)
    "___return((void*)sel_registerName(___arg1));"))

(def NSEventModifierFlagCommand #x100000)
(def NSEventModifierFlagOption  #x80000)

(def (install-standard-app-menu! application app-name)
  (let* ((app       (->ptr application))
         (main-menu (menu-alloc-init-title (string->nsstring "")))
         (app-item  (menu-item-alloc-init (string->nsstring "")
                                          (null-ptr)
                                          (string->nsstring "")))
         (app-menu  (menu-alloc-init-title (string->nsstring app-name))))
    (menu-add-item-title-action-key! app-menu (string->nsstring (string-append "About " app-name))
                                     (selector "orderFrontStandardAboutPanel:") (string->nsstring ""))
    (menu-add-item! app-menu (menu-separator-item))
    (menu-add-item-title-action-key! app-menu (string->nsstring (string-append "Hide " app-name))
                                     (selector "hide:") (string->nsstring "h"))
    (let (hide-others (menu-add-item-title-action-key! app-menu (string->nsstring "Hide Others")
                                                       (selector "hideOtherApplications:") (string->nsstring "h")))
      (menu-item-set-key-modifier-mask! hide-others
                                        (bitwise-ior NSEventModifierFlagCommand NSEventModifierFlagOption)))
    (menu-add-item-title-action-key! app-menu (string->nsstring "Show All")
                                     (selector "unhideAllApplications:") (string->nsstring ""))
    (menu-add-item! app-menu (menu-separator-item))
    (menu-add-item-title-action-key! app-menu (string->nsstring (string-append "Quit " app-name))
                                     (selector "terminate:") (string->nsstring "q"))
    (menu-item-set-submenu! app-item app-menu)
    (menu-add-item! main-menu app-item)
    (app-set-main-menu! app main-menu)))
