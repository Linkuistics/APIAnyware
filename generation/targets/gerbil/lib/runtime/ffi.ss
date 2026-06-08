;;; runtime/ffi.ss — gerbil target FFI primitives (the C-safe libobjc surface).
;;;
;;; ADR-0017 §6: unlike chez's libAPIAnywareChez.dylib, gerbil keeps NO separate
;;; dylib. The native surface is libobjc, reached through `:std/foreign`
;;; `define-c-lambda` crossings compiled straight into the exe. This unit uses
;;; ONLY C-safe headers (`<objc/runtime.h>`, `<objc/message.h>`), so it builds
;;; under the bottle's default C compiler (gcc-15) with NO `-x objective-c`
;;; — see `knowledge/targets/gerbil.md` toolchain note (gcc-15 cannot parse the
;;; Foundation/AppKit umbrella headers; blocks + `@autoreleasepool` ObjC syntax
;;; are deferred to the native-core unit, leaf 050/020).
;;;
;;; Everything Cocoa-shaped is reached dynamically via `objc_msgSend` + selector
;;; strings (the same shape spike 01-reachability proved), so no framework header
;;; is needed here. `objc_retain` / `objc_release` / `objc_autoreleasePoolPush` /
;;; `objc_autoreleasePoolPop` are libobjc entry points; we `extern`-declare them
;;; rather than pull a Foundation header.

(import :std/foreign)
(export objc-get-class object-get-class class-get-name class-get-superclass
        sel-register sel-get-name
        class-get-instance-method method-type-encoding
        objc-retain objc-release
        autorelease-pool-push autorelease-pool-pop
        string->nsstring nsstring->string cstr->string
        null-ptr ptr-null? ptr->int
        msg-id msg-long
        msg-super-void msg-super-id
        alloc-id-cell id-cell-ref free-cell)

(begin-ffi (objc-get-class object-get-class class-get-name class-get-superclass
            sel-register sel-get-name
            class-get-instance-method method-type-encoding
            objc-retain objc-release
            autorelease-pool-push autorelease-pool-pop
            string->nsstring nsstring->string cstr->string
            null-ptr ptr-null? ptr->int
            msg-id msg-long
            msg-super-void msg-super-id
            alloc-id-cell id-cell-ref free-cell)
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")
  ;; libobjc ARC + autorelease-pool entry points — C-safe, extern-declared so we
  ;; need no Foundation header (which gcc-15 can't parse — see module banner).
  (c-declare "extern id objc_retain(id);")
  (c-declare "extern void objc_release(id);")
  (c-declare "extern void* objc_autoreleasePoolPush(void);")
  (c-declare "extern void objc_autoreleasePoolPop(void*);")

  ;; --- class / selector lookup ---------------------------------------------
  (define-c-lambda objc-get-class (char-string) (pointer void)
    "___return((void*)objc_getClass(___arg1));")
  ;; object_getClass: the dynamic class of a live instance — backs the
  ;; class-aware `wrap` (ADR-0020 wrap boundary).
  (define-c-lambda object-get-class ((pointer void)) (pointer void)
    "___return((void*)object_getClass((id)___arg1));")
  (define-c-lambda class-get-name ((pointer void)) char-string
    "___return((char*)class_getName((Class)___arg1));")
  ;; class_getSuperclass: walk to the nearest bound ancestor when the exact
  ;; class is unbound (wrap fallback).
  (define-c-lambda class-get-superclass ((pointer void)) (pointer void)
    "___return((void*)class_getSuperclass((Class)___arg1));")
  (define-c-lambda sel-register (char-string) (pointer void)
    "___return((void*)sel_registerName(___arg1));")
  ;; sel_getName: an IMP trampoline (native-core) reads the live SEL back to its
  ;; selector string to key the per-class dispatch table.
  (define-c-lambda sel-get-name ((pointer void)) char-string
    "___return((char*)sel_getName((SEL)___arg1));")

  ;; --- subclass-override signature inference (leaf 050/030) ------------------
  ;; class_getInstanceMethod searches the class AND its superclasses, so the
  ;; transparent-subclassing bridge reads an INHERITED selector's Method off the
  ;; ObjC superclass to recover its @encode string — the ABI-exact signature the
  ;; IMP trampoline + class_addMethod need (the NSRect/CGRect struct encoding is
  ;; version-sensitive; pulling it from the live superclass is always correct).
  (define-c-lambda class-get-instance-method ((pointer void) (pointer void)) (pointer void)
    "___return((void*)class_getInstanceMethod((Class)___arg1,(SEL)___arg2));")
  (define-c-lambda method-type-encoding ((pointer void)) char-string
    "___return((char*)method_getTypeEncoding((Method)___arg1));")

  ;; --- lifetime primitives (ADR-0019) --------------------------------------
  (define-c-lambda objc-retain ((pointer void)) (pointer void)
    "___return((void*)objc_retain((id)___arg1));")
  (define-c-lambda objc-release ((pointer void)) void
    "objc_release((id)___arg1);")
  (define-c-lambda autorelease-pool-push () (pointer void)
    "___return(objc_autoreleasePoolPush());")
  (define-c-lambda autorelease-pool-pop ((pointer void)) void
    "objc_autoreleasePoolPop(___arg1);")

  ;; --- NSString marshalling (constants contract: +1-retained, caller owns) --
  ;; `+[NSString stringWithUTF8String:]` is +0 autoreleased; retain so the caller
  ;; owns +1 (the runtime `wrap … #t` then registers the balancing release will).
  ;;
  ;; The string slots use Gambit's `UTF-8-string`, NOT `char-string`: `char-string`
  ;; marshals through the C locale (ISO-8859-1), so any non-ASCII codepoint — e.g.
  ;; the `…` in a "Color…" button title — fails conversion ("Can't convert to C
  ;; char-string", found at leaf 100/030). `UTF-8-string` encodes the Scheme string
  ;; as UTF-8 bytes (which `stringWithUTF8String:` decodes) and decodes a returned
  ;; `UTF8String` as UTF-8, so the round trip is codepoint-exact for the full
  ;; Unicode range. (ASCII-only class/selector/type-encoding crossings keep
  ;; `char-string` — those are ASCII by construction.)
  (define-c-lambda string->nsstring (UTF-8-string) (pointer void)
    "Class cls = objc_getClass(\"NSString\");
     SEL sel = sel_registerName(\"stringWithUTF8String:\");
     id (*send)(Class, SEL, const char*) =
       (id (*)(Class, SEL, const char*))objc_msgSend;
     id ns = send(cls, sel, ___arg1);
     ___return((void*)objc_retain(ns));")
  (define-c-lambda nsstring->string ((pointer void)) UTF-8-string
    "SEL sel = sel_registerName(\"UTF8String\");
     const char* (*send)(id, SEL) = (const char* (*)(id, SEL))objc_msgSend;
     ___return((char*)send((id)___arg1, sel));")
  ;; A raw `char*` (delivered to a callback as an opaque pointer) → Scheme
  ;; string — the C-string analogue of `nsstring->string`, used by the native
  ;; callback bridge's string param coercion. UTF-8 to match the NSString path.
  (define-c-lambda cstr->string ((pointer void)) UTF-8-string
    "___return((char*)___arg1);")

  ;; --- pointer helpers ------------------------------------------------------
  (define-c-lambda null-ptr () (pointer void) "___return(NULL);")
  (define-c-lambda ptr-null? ((pointer void)) bool "___return(___arg1 == NULL);")
  ;; Reinterpret a tagged foreign pointer's bits as a signed machine integer.
  ;; Two uses in the native core: keying the IMP dispatch table by a class's
  ;; address, and recovering a callback's integer/bool argument (delivered to a
  ;; generic all-pointer trampoline as pointer-width bits) per its FFI token.
  (define-c-lambda ptr->int ((pointer void)) ssize_t "___return((intptr_t)___arg1);")

  ;; --- generic msgSend variants (used by call-with-nserror-out to read an
  ;;     NSError's fields; one cast per return shape) --------------------------
  (define-c-lambda msg-id ((pointer void) (pointer void)) (pointer void)
    "id (*send)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
     ___return((void*)send((id)___arg1, (SEL)___arg2));")
  (define-c-lambda msg-long ((pointer void) (pointer void)) long
    "long (*send)(id, SEL) = (long (*)(id, SEL))objc_msgSend;
     ___return(send((id)___arg1, (SEL)___arg2));")

  ;; --- super-dispatch (leaf 050/030, ADR-0020 "call super then extend") -----
  ;; `objc_msgSendSuper` against `{ self, <super-class> }`: the receiver stays
  ;; `self` but the method lookup begins at the SUPERCLASS, so an override body
  ;; can chain to the inherited implementation. `super-name` is the synthesized
  ;; class's ObjC superclass (the bound class being subclassed). Argument-passing
  ;; super-sends are deferred (struct/typed args need per-signature crossings);
  ;; the void + id zero-arg shapes cover the common `[super drawRect:]`-style and
  ;; lifecycle chains. void/id return shapes only.
  (define-c-lambda msg-super-void ((pointer void) char-string (pointer void)) void
    "struct objc_super sup = { (id)___arg1, objc_getClass(___arg2) };
     void (*send)(struct objc_super*, SEL) =
       (void (*)(struct objc_super*, SEL))objc_msgSendSuper;
     send(&sup, (SEL)___arg3);")
  (define-c-lambda msg-super-id ((pointer void) char-string (pointer void)) (pointer void)
    "struct objc_super sup = { (id)___arg1, objc_getClass(___arg2) };
     id (*send)(struct objc_super*, SEL) =
       (id (*)(struct objc_super*, SEL))objc_msgSendSuper;
     ___return((void*)send(&sup, (SEL)___arg3));")

  ;; --- NSError** out-param cell (call-with-nserror-out, ADR-0006) -----------
  ;; A heap-allocated id* slot, zeroed: the emitted `%msg-…-e` crossing takes it
  ;; as its trailing (pointer (pointer void)) arg and casts to NSError**.
  (define-c-lambda alloc-id-cell () (pointer (pointer void))
    "id* cell = (id*)calloc(1, sizeof(id)); ___return((void**)cell);")
  (define-c-lambda id-cell-ref ((pointer (pointer void))) (pointer void)
    "___return((void*)(*((id*)___arg1)));")
  (define-c-lambda free-cell ((pointer (pointer void))) void "free(___arg1);"))
