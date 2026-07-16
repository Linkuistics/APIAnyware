;;; Generated binding for NSURL (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  NSURL
  NSURL?
  absolute-string
  absolute-url
  base-url
  bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error
  check-promised-item-is-reachable-and-return-error
  check-resource-is-reachable-and-return-error
  custom-playground-quick-look
  data-representation
  encode-with-coder
  file-path-url
  file-reference-url
  file-system-representation
  file-url
  fragment
  has-directory-path
  host
  init-absolute-url-with-data-representation-relative-to-url
  init-file-url-with-file-system-representation-is-directory-relative-to-url
  init-file-url-with-path
  init-file-url-with-path-is-directory
  init-file-url-with-path-is-directory-relative-to-url
  init-file-url-with-path-relative-to-url
  is-file-reference-url
  is-file-url
  item-provider-visibility-for-representation-with-type-identifier
  last-path-component
  load-data-with-type-identifier-for-item-provider-completion-handler
  make-nsurl-init-with-coder
  make-nsurl-init-with-data-representation-relative-to-url
  make-nsurl-init-with-string
  make-nsurl-init-with-string-encoding-invalid-characters
  make-nsurl-init-with-string-relative-to-url
  nsurl-absolute-string
  nsurl-absolute-url
  nsurl-absolute-url-with-data-representation-relative-to-url
  nsurl-base-url
  nsurl-bookmark-data-with-contents-of-url-error
  nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error
  nsurl-check-promised-item-is-reachable-and-return-error
  nsurl-check-resource-is-reachable-and-return-error
  nsurl-custom-playground-quick-look
  nsurl-data-representation
  nsurl-encode-with-coder
  nsurl-file-path-url
  nsurl-file-reference-url
  nsurl-file-system-representation
  nsurl-file-url
  nsurl-file-url-with-file-system-representation-is-directory-relative-to-url
  nsurl-file-url-with-path
  nsurl-file-url-with-path-components
  nsurl-file-url-with-path-is-directory
  nsurl-file-url-with-path-is-directory-relative-to-url
  nsurl-file-url-with-path-relative-to-url
  nsurl-fragment
  nsurl-has-directory-path
  nsurl-host
  nsurl-init-absolute-url-with-data-representation-relative-to-url
  nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url
  nsurl-init-file-url-with-path
  nsurl-init-file-url-with-path-is-directory
  nsurl-init-file-url-with-path-is-directory-relative-to-url
  nsurl-init-file-url-with-path-relative-to-url
  nsurl-is-file-reference-url
  nsurl-is-file-url
  nsurl-item-provider-visibility-for-representation-with-type-identifier
  nsurl-last-path-component
  nsurl-load-data-with-type-identifier-for-item-provider-completion-handler
  nsurl-object-with-item-provider-data-type-identifier-error
  nsurl-parameter-string
  nsurl-password
  nsurl-path
  nsurl-path-components
  nsurl-path-extension
  nsurl-port
  nsurl-promised-item-resource-values-for-keys-error
  nsurl-query
  nsurl-readable-type-identifiers-for-item-provider
  nsurl-relative-path
  nsurl-relative-string
  nsurl-remove-all-cached-resource-values!
  nsurl-remove-cached-resource-value-for-key!
  nsurl-resource-specifier
  nsurl-resource-values-for-keys-error
  nsurl-resource-values-for-keys-from-bookmark-data
  nsurl-scheme
  nsurl-set-resource-value-for-key-error!
  nsurl-set-resource-values-error!
  nsurl-set-temporary-resource-value-for-key!
  nsurl-standardized-url
  nsurl-start-accessing-security-scoped-resource
  nsurl-stop-accessing-security-scoped-resource
  nsurl-supports-secure-coding
  nsurl-url-by-appending-path-component
  nsurl-url-by-appending-path-component-is-directory
  nsurl-url-by-appending-path-extension
  nsurl-url-by-deleting-last-path-component
  nsurl-url-by-deleting-path-extension
  nsurl-url-by-resolving-alias-file-at-url-options-error
  nsurl-url-by-resolving-symlinks-in-path
  nsurl-url-by-standardizing-path
  nsurl-url-with-data-representation-relative-to-url
  nsurl-url-with-string
  nsurl-url-with-string-encoding-invalid-characters
  nsurl-url-with-string-relative-to-url
  nsurl-user
  nsurl-writable-type-identifiers-for-item-provider
  nsurl-write-bookmark-data-to-url-options-error
  parameter-string
  password
  path
  path-components
  path-extension
  port
  promised-item-resource-values-for-keys-error
  query
  relative-path
  relative-string
  remove-all-cached-resource-values!
  remove-cached-resource-value-for-key!
  resource-specifier
  resource-values-for-keys-error
  scheme
  set-resource-value-for-key-error!
  set-resource-values-error!
  set-temporary-resource-value-for-key!
  standardized-url
  start-accessing-security-scoped-resource
  stop-accessing-security-scoped-resource
  url-by-appending-path-component
  url-by-appending-path-component-is-directory
  url-by-appending-path-extension
  url-by-deleting-last-path-component
  url-by-deleting-path-extension
  url-by-resolving-symlinks-in-path
  url-by-standardizing-path
  user
  writable-type-identifiers-for-item-provider
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSURL NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSURL ptr: p)) NSURL::t "NSURL" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-p->i64
            %msg-p->p
            %msg-p->v
            %msg-p-b->p
            %msg-p-b-p->p
            %msg-p-p->p
            %msg-p-p->v
            %msg-p-p-pp->b-e
            %msg-p-p-pp->p-e
            %msg-p-p-u64-pp->b-e
            %msg-p-pp->b-e
            %msg-p-pp->p-e
            %msg-p-u64-pp->p-e
            %msg-pp->b-e
            %msg-str-b-p->p
            %msg-u64-p-p-pp->p-e
            %msg-v->b
            %msg-v->p
            %msg-v->str
            %msg-v->v
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-p->i64 ((pointer void) (pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p-b->p ((pointer void) (pointer void) (pointer void) bool) (pointer void)
    "___return( ((id (*)(id, SEL, id, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-b-p->p ((pointer void) (pointer void) (pointer void) bool (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id, BOOL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-p-p->p ((pointer void) (pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4) );")
  (define-c-lambda %msg-p-p->v ((pointer void) (pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4);")
  (define-c-lambda %msg-p-p-pp->b-e ((pointer void) (pointer void) (pointer void) (pointer void) (pointer (pointer void))) bool
    "___return( ((BOOL (*)(id, SEL, id, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, (id*)___arg5) );")
  (define-c-lambda %msg-p-p-pp->p-e ((pointer void) (pointer void) (pointer void) (pointer void) (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, id, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, (id*)___arg5) );")
  (define-c-lambda %msg-p-p-u64-pp->b-e ((pointer void) (pointer void) (pointer void) (pointer void) unsigned-int64 (pointer (pointer void))) bool
    "___return( ((BOOL (*)(id, SEL, id, id, uint64_t, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5, (id*)___arg6) );")
  (define-c-lambda %msg-p-pp->b-e ((pointer void) (pointer void) (pointer void) (pointer (pointer void))) bool
    "___return( ((BOOL (*)(id, SEL, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, (id*)___arg4) );")
  (define-c-lambda %msg-p-pp->p-e ((pointer void) (pointer void) (pointer void) (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, (id*)___arg4) );")
  (define-c-lambda %msg-p-u64-pp->p-e ((pointer void) (pointer void) (pointer void) unsigned-int64 (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, id, uint64_t, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, (id*)___arg5) );")
  (define-c-lambda %msg-pp->b-e ((pointer void) (pointer void) (pointer (pointer void))) bool
    "___return( ((BOOL (*)(id, SEL, id*))objc_msgSend)(___arg1, (SEL)___arg2, (id*)___arg3) );")
  (define-c-lambda %msg-str-b-p->p ((pointer void) (pointer void) char-string bool (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, const char*, BOOL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5) );")
  (define-c-lambda %msg-u64-p-p-pp->p-e ((pointer void) (pointer void) unsigned-int64 (pointer void) (pointer void) (pointer (pointer void))) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t, id, id, id*))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4, ___arg5, (id*)___arg6) );")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->str ((pointer void) (pointer void)) char-string
    "___return( ___CAST(char*, ((const char* (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2)) );")
  (define-c-lambda %msg-v->v ((pointer void) (pointer void)) void
    "((void (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2);")
  )

(define %sel-nsurl-init-with-string (sel_registerName "initWithString:"))
(define %sel-nsurl-init-with-string-relative-to-url (sel_registerName "initWithString:relativeToURL:"))
(define %sel-nsurl-init-with-string-encoding-invalid-characters (sel_registerName "initWithString:encodingInvalidCharacters:"))
(define %sel-nsurl-init-with-data-representation-relative-to-url (sel_registerName "initWithDataRepresentation:relativeToURL:"))
(define %sel-nsurl-init-with-coder (sel_registerName "initWithCoder:"))
(define %sel-nsurl-init-file-url-with-path-is-directory-relative-to-url (sel_registerName "initFileURLWithPath:isDirectory:relativeToURL:"))
(define %sel-nsurl-init-file-url-with-path-relative-to-url (sel_registerName "initFileURLWithPath:relativeToURL:"))
(define %sel-nsurl-init-file-url-with-path-is-directory (sel_registerName "initFileURLWithPath:isDirectory:"))
(define %sel-nsurl-init-file-url-with-path (sel_registerName "initFileURLWithPath:"))
(define %sel-nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url (sel_registerName "initFileURLWithFileSystemRepresentation:isDirectory:relativeToURL:"))
(define %sel-nsurl-init-absolute-url-with-data-representation-relative-to-url (sel_registerName "initAbsoluteURLWithDataRepresentation:relativeToURL:"))
(define %sel-nsurl-is-file-reference-url (sel_registerName "isFileReferenceURL"))
(define %sel-nsurl-file-reference-url (sel_registerName "fileReferenceURL"))
(define %sel-nsurl-resource-values-for-keys-error (sel_registerName "resourceValuesForKeys:error:"))
(define %sel-nsurl-set-resource-value-for-key-error (sel_registerName "setResourceValue:forKey:error:"))
(define %sel-nsurl-set-resource-values-error (sel_registerName "setResourceValues:error:"))
(define %sel-nsurl-remove-cached-resource-value-for-key (sel_registerName "removeCachedResourceValueForKey:"))
(define %sel-nsurl-remove-all-cached-resource-values (sel_registerName "removeAllCachedResourceValues"))
(define %sel-nsurl-set-temporary-resource-value-for-key (sel_registerName "setTemporaryResourceValue:forKey:"))
(define %sel-nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error (sel_registerName "bookmarkDataWithOptions:includingResourceValuesForKeys:relativeToURL:error:"))
(define %sel-nsurl-start-accessing-security-scoped-resource (sel_registerName "startAccessingSecurityScopedResource"))
(define %sel-nsurl-stop-accessing-security-scoped-resource (sel_registerName "stopAccessingSecurityScopedResource"))
(define %sel-nsurl-is-file-url (sel_registerName "isFileURL"))
(define %sel-nsurl-promised-item-resource-values-for-keys-error (sel_registerName "promisedItemResourceValuesForKeys:error:"))
(define %sel-nsurl-check-promised-item-is-reachable-and-return-error (sel_registerName "checkPromisedItemIsReachableAndReturnError:"))
(define %sel-nsurl-url-by-appending-path-component (sel_registerName "URLByAppendingPathComponent:"))
(define %sel-nsurl-url-by-appending-path-component-is-directory (sel_registerName "URLByAppendingPathComponent:isDirectory:"))
(define %sel-nsurl-url-by-appending-path-extension (sel_registerName "URLByAppendingPathExtension:"))
(define %sel-nsurl-check-resource-is-reachable-and-return-error (sel_registerName "checkResourceIsReachableAndReturnError:"))
(define %sel-nsurl-encode-with-coder (sel_registerName "encodeWithCoder:"))
(define %sel-nsurl-item-provider-visibility-for-representation-with-type-identifier (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:"))
(define %sel-nsurl-load-data-with-type-identifier-for-item-provider-completion-handler (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:"))
(define %sel-nsurl-writable-type-identifiers-for-item-provider (sel_registerName "writableTypeIdentifiersForItemProvider"))
(define %sel-nsurl-file-url-with-path-is-directory-relative-to-url (sel_registerName "fileURLWithPath:isDirectory:relativeToURL:"))
(define %sel-nsurl-file-url-with-path-relative-to-url (sel_registerName "fileURLWithPath:relativeToURL:"))
(define %sel-nsurl-file-url-with-path-is-directory (sel_registerName "fileURLWithPath:isDirectory:"))
(define %sel-nsurl-file-url-with-path (sel_registerName "fileURLWithPath:"))
(define %sel-nsurl-file-url-with-file-system-representation-is-directory-relative-to-url (sel_registerName "fileURLWithFileSystemRepresentation:isDirectory:relativeToURL:"))
(define %sel-nsurl-url-with-string (sel_registerName "URLWithString:"))
(define %sel-nsurl-url-with-string-relative-to-url (sel_registerName "URLWithString:relativeToURL:"))
(define %sel-nsurl-url-with-string-encoding-invalid-characters (sel_registerName "URLWithString:encodingInvalidCharacters:"))
(define %sel-nsurl-url-with-data-representation-relative-to-url (sel_registerName "URLWithDataRepresentation:relativeToURL:"))
(define %sel-nsurl-absolute-url-with-data-representation-relative-to-url (sel_registerName "absoluteURLWithDataRepresentation:relativeToURL:"))
(define %sel-nsurl-resource-values-for-keys-from-bookmark-data (sel_registerName "resourceValuesForKeys:fromBookmarkData:"))
(define %sel-nsurl-write-bookmark-data-to-url-options-error (sel_registerName "writeBookmarkData:toURL:options:error:"))
(define %sel-nsurl-bookmark-data-with-contents-of-url-error (sel_registerName "bookmarkDataWithContentsOfURL:error:"))
(define %sel-nsurl-url-by-resolving-alias-file-at-url-options-error (sel_registerName "URLByResolvingAliasFileAtURL:options:error:"))
(define %sel-nsurl-file-url-with-path-components (sel_registerName "fileURLWithPathComponents:"))
(define %sel-nsurl-object-with-item-provider-data-type-identifier-error (sel_registerName "objectWithItemProviderData:typeIdentifier:error:"))
(define %sel-nsurl-readable-type-identifiers-for-item-provider (sel_registerName "readableTypeIdentifiersForItemProvider"))
(define %sel-nsurl-supports-secure-coding (sel_registerName "supportsSecureCoding"))
(define %sel-nsurl-data-representation (sel_registerName "dataRepresentation"))
(define %sel-nsurl-absolute-string (sel_registerName "absoluteString"))
(define %sel-nsurl-relative-string (sel_registerName "relativeString"))
(define %sel-nsurl-base-url (sel_registerName "baseURL"))
(define %sel-nsurl-absolute-url (sel_registerName "absoluteURL"))
(define %sel-nsurl-scheme (sel_registerName "scheme"))
(define %sel-nsurl-resource-specifier (sel_registerName "resourceSpecifier"))
(define %sel-nsurl-host (sel_registerName "host"))
(define %sel-nsurl-port (sel_registerName "port"))
(define %sel-nsurl-user (sel_registerName "user"))
(define %sel-nsurl-password (sel_registerName "password"))
(define %sel-nsurl-path (sel_registerName "path"))
(define %sel-nsurl-fragment (sel_registerName "fragment"))
(define %sel-nsurl-parameter-string (sel_registerName "parameterString"))
(define %sel-nsurl-query (sel_registerName "query"))
(define %sel-nsurl-relative-path (sel_registerName "relativePath"))
(define %sel-nsurl-has-directory-path (sel_registerName "hasDirectoryPath"))
(define %sel-nsurl-file-system-representation (sel_registerName "fileSystemRepresentation"))
(define %sel-nsurl-file-url (sel_registerName "fileURL"))
(define %sel-nsurl-standardized-url (sel_registerName "standardizedURL"))
(define %sel-nsurl-file-path-url (sel_registerName "filePathURL"))
(define %sel-nsurl-path-components (sel_registerName "pathComponents"))
(define %sel-nsurl-last-path-component (sel_registerName "lastPathComponent"))
(define %sel-nsurl-path-extension (sel_registerName "pathExtension"))
(define %sel-nsurl-url-by-deleting-last-path-component (sel_registerName "URLByDeletingLastPathComponent"))
(define %sel-nsurl-url-by-deleting-path-extension (sel_registerName "URLByDeletingPathExtension"))
(define %sel-nsurl-url-by-standardizing-path (sel_registerName "URLByStandardizingPath"))
(define %sel-nsurl-url-by-resolving-symlinks-in-path (sel_registerName "URLByResolvingSymlinksInPath"))
(define %sel-nsurl-custom-playground-quick-look (sel_registerName "customPlaygroundQuickLook"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-nsurl-init-with-string url-string)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSURL") (sel_registerName "alloc")) %sel-nsurl-init-with-string (->ptr url-string)) #t))

(define (make-nsurl-init-with-string-relative-to-url url-string base-url)
  (wrap (%msg-p-p->p (%msg-v->p (objc_getClass "NSURL") (sel_registerName "alloc")) %sel-nsurl-init-with-string-relative-to-url (->ptr url-string) (->ptr base-url)) #t))

(define (make-nsurl-init-with-string-encoding-invalid-characters url-string encoding-invalid-characters)
  (wrap (%msg-p-b->p (%msg-v->p (objc_getClass "NSURL") (sel_registerName "alloc")) %sel-nsurl-init-with-string-encoding-invalid-characters (->ptr url-string) encoding-invalid-characters) #t))

(define (make-nsurl-init-with-data-representation-relative-to-url data base-url)
  (wrap (%msg-p-p->p (%msg-v->p (objc_getClass "NSURL") (sel_registerName "alloc")) %sel-nsurl-init-with-data-representation-relative-to-url (->ptr data) (->ptr base-url)) #t))

(define (make-nsurl-init-with-coder coder)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSURL") (sel_registerName "alloc")) %sel-nsurl-init-with-coder (->ptr coder)) #t))

;; --- Properties ---
(define (nsurl-data-representation self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-data-representation)))
(defmethod {data-representation NSURL} (lambda (self) (nsurl-data-representation self)))
(g:defmethod (data-representation (o NSURL)) (nsurl-data-representation o))

(define (nsurl-absolute-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-absolute-string)))
(defmethod {absolute-string NSURL} (lambda (self) (nsurl-absolute-string self)))
(g:defmethod (absolute-string (o NSURL)) (nsurl-absolute-string o))

(define (nsurl-relative-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-relative-string)))
(defmethod {relative-string NSURL} (lambda (self) (nsurl-relative-string self)))
(g:defmethod (relative-string (o NSURL)) (nsurl-relative-string o))

(define (nsurl-base-url self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-base-url)))
(defmethod {base-url NSURL} (lambda (self) (nsurl-base-url self)))
(g:defmethod (base-url (o NSURL)) (nsurl-base-url o))

(define (nsurl-absolute-url self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-absolute-url)))
(defmethod {absolute-url NSURL} (lambda (self) (nsurl-absolute-url self)))
(g:defmethod (absolute-url (o NSURL)) (nsurl-absolute-url o))

(define (nsurl-scheme self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-scheme)))
(defmethod {scheme NSURL} (lambda (self) (nsurl-scheme self)))
(g:defmethod (scheme (o NSURL)) (nsurl-scheme o))

(define (nsurl-resource-specifier self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-resource-specifier)))
(defmethod {resource-specifier NSURL} (lambda (self) (nsurl-resource-specifier self)))
(g:defmethod (resource-specifier (o NSURL)) (nsurl-resource-specifier o))

(define (nsurl-host self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-host)))
(defmethod {host NSURL} (lambda (self) (nsurl-host self)))
(g:defmethod (host (o NSURL)) (nsurl-host o))

(define (nsurl-port self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-port)))
(defmethod {port NSURL} (lambda (self) (nsurl-port self)))
(g:defmethod (port (o NSURL)) (nsurl-port o))

(define (nsurl-user self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-user)))
(defmethod {user NSURL} (lambda (self) (nsurl-user self)))
(g:defmethod (user (o NSURL)) (nsurl-user o))

(define (nsurl-password self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-password)))
(defmethod {password NSURL} (lambda (self) (nsurl-password self)))
(g:defmethod (password (o NSURL)) (nsurl-password o))

(define (nsurl-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-path)))
(defmethod {path NSURL} (lambda (self) (nsurl-path self)))
(g:defmethod (path (o NSURL)) (nsurl-path o))

(define (nsurl-fragment self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-fragment)))
(defmethod {fragment NSURL} (lambda (self) (nsurl-fragment self)))
(g:defmethod (fragment (o NSURL)) (nsurl-fragment o))

(define (nsurl-parameter-string self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-parameter-string)))
(defmethod {parameter-string NSURL} (lambda (self) (nsurl-parameter-string self)))
(g:defmethod (parameter-string (o NSURL)) (nsurl-parameter-string o))

(define (nsurl-query self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-query)))
(defmethod {query NSURL} (lambda (self) (nsurl-query self)))
(g:defmethod (query (o NSURL)) (nsurl-query o))

(define (nsurl-relative-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-relative-path)))
(defmethod {relative-path NSURL} (lambda (self) (nsurl-relative-path self)))
(g:defmethod (relative-path (o NSURL)) (nsurl-relative-path o))

(define (nsurl-has-directory-path self)
  (%msg-v->b (NSObject-ptr self) %sel-nsurl-has-directory-path))
(defmethod {has-directory-path NSURL} (lambda (self) (nsurl-has-directory-path self)))
(g:defmethod (has-directory-path (o NSURL)) (nsurl-has-directory-path o))

(define (nsurl-file-system-representation self)
  (%msg-v->str (NSObject-ptr self) %sel-nsurl-file-system-representation))
(defmethod {file-system-representation NSURL} (lambda (self) (nsurl-file-system-representation self)))
(g:defmethod (file-system-representation (o NSURL)) (nsurl-file-system-representation o))

(define (nsurl-file-url self)
  (%msg-v->b (NSObject-ptr self) %sel-nsurl-file-url))
(defmethod {file-url NSURL} (lambda (self) (nsurl-file-url self)))
(g:defmethod (file-url (o NSURL)) (nsurl-file-url o))

(define (nsurl-standardized-url self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-standardized-url)))
(defmethod {standardized-url NSURL} (lambda (self) (nsurl-standardized-url self)))
(g:defmethod (standardized-url (o NSURL)) (nsurl-standardized-url o))

(define (nsurl-file-path-url self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-file-path-url)))
(defmethod {file-path-url NSURL} (lambda (self) (nsurl-file-path-url self)))
(g:defmethod (file-path-url (o NSURL)) (nsurl-file-path-url o))

(define (nsurl-path-components self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-path-components)))
(defmethod {path-components NSURL} (lambda (self) (nsurl-path-components self)))
(g:defmethod (path-components (o NSURL)) (nsurl-path-components o))

(define (nsurl-last-path-component self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-last-path-component)))
(defmethod {last-path-component NSURL} (lambda (self) (nsurl-last-path-component self)))
(g:defmethod (last-path-component (o NSURL)) (nsurl-last-path-component o))

(define (nsurl-path-extension self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-path-extension)))
(defmethod {path-extension NSURL} (lambda (self) (nsurl-path-extension self)))
(g:defmethod (path-extension (o NSURL)) (nsurl-path-extension o))

(define (nsurl-url-by-deleting-last-path-component self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-url-by-deleting-last-path-component)))
(defmethod {url-by-deleting-last-path-component NSURL} (lambda (self) (nsurl-url-by-deleting-last-path-component self)))
(g:defmethod (url-by-deleting-last-path-component (o NSURL)) (nsurl-url-by-deleting-last-path-component o))

(define (nsurl-url-by-deleting-path-extension self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-url-by-deleting-path-extension)))
(defmethod {url-by-deleting-path-extension NSURL} (lambda (self) (nsurl-url-by-deleting-path-extension self)))
(g:defmethod (url-by-deleting-path-extension (o NSURL)) (nsurl-url-by-deleting-path-extension o))

(define (nsurl-url-by-standardizing-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-url-by-standardizing-path)))
(defmethod {url-by-standardizing-path NSURL} (lambda (self) (nsurl-url-by-standardizing-path self)))
(g:defmethod (url-by-standardizing-path (o NSURL)) (nsurl-url-by-standardizing-path o))

(define (nsurl-url-by-resolving-symlinks-in-path self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-url-by-resolving-symlinks-in-path)))
(defmethod {url-by-resolving-symlinks-in-path NSURL} (lambda (self) (nsurl-url-by-resolving-symlinks-in-path self)))
(g:defmethod (url-by-resolving-symlinks-in-path (o NSURL)) (nsurl-url-by-resolving-symlinks-in-path o))

(define (nsurl-custom-playground-quick-look self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-custom-playground-quick-look)))
(defmethod {custom-playground-quick-look NSURL} (lambda (self) (nsurl-custom-playground-quick-look self)))
(g:defmethod (custom-playground-quick-look (o NSURL)) (nsurl-custom-playground-quick-look o))

;; --- Instance methods ---
(define (nsurl-init-file-url-with-path-is-directory-relative-to-url self path is-dir base-url)
  (wrap (%msg-p-b-p->p (NSObject-ptr self) %sel-nsurl-init-file-url-with-path-is-directory-relative-to-url (->ptr path) is-dir (->ptr base-url)) #t))
(defmethod {init-file-url-with-path-is-directory-relative-to-url NSURL} (lambda (self path is-dir base-url) (nsurl-init-file-url-with-path-is-directory-relative-to-url self path is-dir base-url)))

(define (nsurl-init-file-url-with-path-relative-to-url self path base-url)
  (wrap (%msg-p-p->p (NSObject-ptr self) %sel-nsurl-init-file-url-with-path-relative-to-url (->ptr path) (->ptr base-url)) #t))
(defmethod {init-file-url-with-path-relative-to-url NSURL} (lambda (self path base-url) (nsurl-init-file-url-with-path-relative-to-url self path base-url)))

(define (nsurl-init-file-url-with-path-is-directory self path is-dir)
  (wrap (%msg-p-b->p (NSObject-ptr self) %sel-nsurl-init-file-url-with-path-is-directory (->ptr path) is-dir) #t))
(defmethod {init-file-url-with-path-is-directory NSURL} (lambda (self path is-dir) (nsurl-init-file-url-with-path-is-directory self path is-dir)))

(define (nsurl-init-file-url-with-path self path)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsurl-init-file-url-with-path (->ptr path)) #t))
(defmethod {init-file-url-with-path NSURL} (lambda (self path) (nsurl-init-file-url-with-path self path)))

(define (nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url self path is-dir base-url)
  (wrap (%msg-str-b-p->p (NSObject-ptr self) %sel-nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url path is-dir (->ptr base-url)) #t))
(defmethod {init-file-url-with-file-system-representation-is-directory-relative-to-url NSURL} (lambda (self path is-dir base-url) (nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url self path is-dir base-url)))

(define (nsurl-init-absolute-url-with-data-representation-relative-to-url self data base-url)
  (wrap (%msg-p-p->p (NSObject-ptr self) %sel-nsurl-init-absolute-url-with-data-representation-relative-to-url (->ptr data) (->ptr base-url)) #t))
(defmethod {init-absolute-url-with-data-representation-relative-to-url NSURL} (lambda (self data base-url) (nsurl-init-absolute-url-with-data-representation-relative-to-url self data base-url)))

(define (nsurl-is-file-reference-url self)
  (%msg-v->b (NSObject-ptr self) %sel-nsurl-is-file-reference-url))
(defmethod {is-file-reference-url NSURL} (lambda (self) (nsurl-is-file-reference-url self)))
(g:defmethod (is-file-reference-url (o NSURL)) (nsurl-is-file-reference-url o))

(define (nsurl-file-reference-url self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-file-reference-url)))
(defmethod {file-reference-url NSURL} (lambda (self) (nsurl-file-reference-url self)))
(g:defmethod (file-reference-url (o NSURL)) (nsurl-file-reference-url o))

(define (nsurl-resource-values-for-keys-error self keys)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-pp->p-e (NSObject-ptr self) %sel-nsurl-resource-values-for-keys-error (->ptr keys) %err-cell)))))
(defmethod {resource-values-for-keys-error NSURL} (lambda (self keys) (nsurl-resource-values-for-keys-error self keys)))

(define (nsurl-set-resource-value-for-key-error! self value key)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-p-pp->b-e (NSObject-ptr self) %sel-nsurl-set-resource-value-for-key-error (->ptr value) (->ptr key) %err-cell))))
(defmethod {set-resource-value-for-key-error! NSURL} (lambda (self value key) (nsurl-set-resource-value-for-key-error! self value key)))

(define (nsurl-set-resource-values-error! self keyed-values)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-pp->b-e (NSObject-ptr self) %sel-nsurl-set-resource-values-error (->ptr keyed-values) %err-cell))))
(defmethod {set-resource-values-error! NSURL} (lambda (self keyed-values) (nsurl-set-resource-values-error! self keyed-values)))

(define (nsurl-remove-cached-resource-value-for-key! self key)
  (%msg-p->v (NSObject-ptr self) %sel-nsurl-remove-cached-resource-value-for-key (->ptr key)))
(defmethod {remove-cached-resource-value-for-key! NSURL} (lambda (self key) (nsurl-remove-cached-resource-value-for-key! self key)))

(define (nsurl-remove-all-cached-resource-values! self)
  (%msg-v->v (NSObject-ptr self) %sel-nsurl-remove-all-cached-resource-values))
(defmethod {remove-all-cached-resource-values! NSURL} (lambda (self) (nsurl-remove-all-cached-resource-values! self)))
(g:defmethod (remove-all-cached-resource-values! (o NSURL)) (nsurl-remove-all-cached-resource-values! o))

(define (nsurl-set-temporary-resource-value-for-key! self value key)
  (%msg-p-p->v (NSObject-ptr self) %sel-nsurl-set-temporary-resource-value-for-key (->ptr value) (->ptr key)))
(defmethod {set-temporary-resource-value-for-key! NSURL} (lambda (self value key) (nsurl-set-temporary-resource-value-for-key! self value key)))

(define (nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error self options keys relative-url)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-u64-p-p-pp->p-e (NSObject-ptr self) %sel-nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error options (->ptr keys) (->ptr relative-url) %err-cell)))))
(defmethod {bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error NSURL} (lambda (self options keys relative-url) (nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error self options keys relative-url)))

(define (nsurl-start-accessing-security-scoped-resource self)
  (%msg-v->b (NSObject-ptr self) %sel-nsurl-start-accessing-security-scoped-resource))
(defmethod {start-accessing-security-scoped-resource NSURL} (lambda (self) (nsurl-start-accessing-security-scoped-resource self)))
(g:defmethod (start-accessing-security-scoped-resource (o NSURL)) (nsurl-start-accessing-security-scoped-resource o))

(define (nsurl-stop-accessing-security-scoped-resource self)
  (%msg-v->v (NSObject-ptr self) %sel-nsurl-stop-accessing-security-scoped-resource))
(defmethod {stop-accessing-security-scoped-resource NSURL} (lambda (self) (nsurl-stop-accessing-security-scoped-resource self)))
(g:defmethod (stop-accessing-security-scoped-resource (o NSURL)) (nsurl-stop-accessing-security-scoped-resource o))

(define (nsurl-is-file-url self)
  (%msg-v->b (NSObject-ptr self) %sel-nsurl-is-file-url))
(defmethod {is-file-url NSURL} (lambda (self) (nsurl-is-file-url self)))
(g:defmethod (is-file-url (o NSURL)) (nsurl-is-file-url o))

(define (nsurl-promised-item-resource-values-for-keys-error self keys)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-pp->p-e (NSObject-ptr self) %sel-nsurl-promised-item-resource-values-for-keys-error (->ptr keys) %err-cell)))))
(defmethod {promised-item-resource-values-for-keys-error NSURL} (lambda (self keys) (nsurl-promised-item-resource-values-for-keys-error self keys)))

(define (nsurl-check-promised-item-is-reachable-and-return-error self)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-pp->b-e (NSObject-ptr self) %sel-nsurl-check-promised-item-is-reachable-and-return-error %err-cell))))
(defmethod {check-promised-item-is-reachable-and-return-error NSURL} (lambda (self) (nsurl-check-promised-item-is-reachable-and-return-error self)))
(g:defmethod (check-promised-item-is-reachable-and-return-error (o NSURL)) (nsurl-check-promised-item-is-reachable-and-return-error o))

(define (nsurl-url-by-appending-path-component self path-component)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsurl-url-by-appending-path-component (->ptr path-component))))
(defmethod {url-by-appending-path-component NSURL} (lambda (self path-component) (nsurl-url-by-appending-path-component self path-component)))

(define (nsurl-url-by-appending-path-component-is-directory self path-component is-directory)
  (wrap (%msg-p-b->p (NSObject-ptr self) %sel-nsurl-url-by-appending-path-component-is-directory (->ptr path-component) is-directory)))
(defmethod {url-by-appending-path-component-is-directory NSURL} (lambda (self path-component is-directory) (nsurl-url-by-appending-path-component-is-directory self path-component is-directory)))

(define (nsurl-url-by-appending-path-extension self path-extension)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-nsurl-url-by-appending-path-extension (->ptr path-extension))))
(defmethod {url-by-appending-path-extension NSURL} (lambda (self path-extension) (nsurl-url-by-appending-path-extension self path-extension)))

(define (nsurl-check-resource-is-reachable-and-return-error self)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-pp->b-e (NSObject-ptr self) %sel-nsurl-check-resource-is-reachable-and-return-error %err-cell))))
(defmethod {check-resource-is-reachable-and-return-error NSURL} (lambda (self) (nsurl-check-resource-is-reachable-and-return-error self)))
(g:defmethod (check-resource-is-reachable-and-return-error (o NSURL)) (nsurl-check-resource-is-reachable-and-return-error o))

(define (nsurl-encode-with-coder self coder)
  (%msg-p->v (NSObject-ptr self) %sel-nsurl-encode-with-coder (->ptr coder)))
(defmethod {encode-with-coder NSURL} (lambda (self coder) (nsurl-encode-with-coder self coder)))

(define (nsurl-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (%msg-p->i64 (NSObject-ptr self) %sel-nsurl-item-provider-visibility-for-representation-with-type-identifier (->ptr type-identifier)))
(defmethod {item-provider-visibility-for-representation-with-type-identifier NSURL} (lambda (self type-identifier) (nsurl-item-provider-visibility-for-representation-with-type-identifier self type-identifier)))

(define (nsurl-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (wrap (%msg-p-p->p (NSObject-ptr self) %sel-nsurl-load-data-with-type-identifier-for-item-provider-completion-handler (->ptr type-identifier) completion-handler)))
(defmethod {load-data-with-type-identifier-for-item-provider-completion-handler NSURL} (lambda (self type-identifier completion-handler) (nsurl-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)))

(define (nsurl-writable-type-identifiers-for-item-provider self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsurl-writable-type-identifiers-for-item-provider)))
(defmethod {writable-type-identifiers-for-item-provider NSURL} (lambda (self) (nsurl-writable-type-identifiers-for-item-provider self)))
(g:defmethod (writable-type-identifiers-for-item-provider (o NSURL)) (nsurl-writable-type-identifiers-for-item-provider o))

;; --- Class methods ---
(define (nsurl-file-url-with-path-is-directory-relative-to-url path is-dir base-url)
  (wrap (%msg-p-b-p->p (objc_getClass "NSURL") %sel-nsurl-file-url-with-path-is-directory-relative-to-url (->ptr path) is-dir (->ptr base-url))))

(define (nsurl-file-url-with-path-relative-to-url path base-url)
  (wrap (%msg-p-p->p (objc_getClass "NSURL") %sel-nsurl-file-url-with-path-relative-to-url (->ptr path) (->ptr base-url))))

(define (nsurl-file-url-with-path-is-directory path is-dir)
  (wrap (%msg-p-b->p (objc_getClass "NSURL") %sel-nsurl-file-url-with-path-is-directory (->ptr path) is-dir)))

(define (nsurl-file-url-with-path path)
  (wrap (%msg-p->p (objc_getClass "NSURL") %sel-nsurl-file-url-with-path (->ptr path))))

(define (nsurl-file-url-with-file-system-representation-is-directory-relative-to-url path is-dir base-url)
  (wrap (%msg-str-b-p->p (objc_getClass "NSURL") %sel-nsurl-file-url-with-file-system-representation-is-directory-relative-to-url path is-dir (->ptr base-url))))

(define (nsurl-url-with-string url-string)
  (wrap (%msg-p->p (objc_getClass "NSURL") %sel-nsurl-url-with-string (->ptr url-string))))

(define (nsurl-url-with-string-relative-to-url url-string base-url)
  (wrap (%msg-p-p->p (objc_getClass "NSURL") %sel-nsurl-url-with-string-relative-to-url (->ptr url-string) (->ptr base-url))))

(define (nsurl-url-with-string-encoding-invalid-characters url-string encoding-invalid-characters)
  (wrap (%msg-p-b->p (objc_getClass "NSURL") %sel-nsurl-url-with-string-encoding-invalid-characters (->ptr url-string) encoding-invalid-characters)))

(define (nsurl-url-with-data-representation-relative-to-url data base-url)
  (wrap (%msg-p-p->p (objc_getClass "NSURL") %sel-nsurl-url-with-data-representation-relative-to-url (->ptr data) (->ptr base-url))))

(define (nsurl-absolute-url-with-data-representation-relative-to-url data base-url)
  (wrap (%msg-p-p->p (objc_getClass "NSURL") %sel-nsurl-absolute-url-with-data-representation-relative-to-url (->ptr data) (->ptr base-url))))

(define (nsurl-resource-values-for-keys-from-bookmark-data keys bookmark-data)
  (wrap (%msg-p-p->p (objc_getClass "NSURL") %sel-nsurl-resource-values-for-keys-from-bookmark-data (->ptr keys) (->ptr bookmark-data))))

(define (nsurl-write-bookmark-data-to-url-options-error bookmark-data bookmark-file-url options)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-p-u64-pp->b-e (objc_getClass "NSURL") %sel-nsurl-write-bookmark-data-to-url-options-error (->ptr bookmark-data) (->ptr bookmark-file-url) options %err-cell))))

(define (nsurl-bookmark-data-with-contents-of-url-error bookmark-file-url)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-pp->p-e (objc_getClass "NSURL") %sel-nsurl-bookmark-data-with-contents-of-url-error (->ptr bookmark-file-url) %err-cell)))))

(define (nsurl-url-by-resolving-alias-file-at-url-options-error url options)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-u64-pp->p-e (objc_getClass "NSURL") %sel-nsurl-url-by-resolving-alias-file-at-url-options-error (->ptr url) options %err-cell)))))

(define (nsurl-file-url-with-path-components components)
  (wrap (%msg-p->p (objc_getClass "NSURL") %sel-nsurl-file-url-with-path-components (->ptr components))))

(define (nsurl-object-with-item-provider-data-type-identifier-error data type-identifier)
  (call-with-nserror-out
    (lambda (%err-cell)
      (wrap (%msg-p-p-pp->p-e (objc_getClass "NSURL") %sel-nsurl-object-with-item-provider-data-type-identifier-error (->ptr data) (->ptr type-identifier) %err-cell)))))

(define (nsurl-readable-type-identifiers-for-item-provider)
  (wrap (%msg-v->p (objc_getClass "NSURL") %sel-nsurl-readable-type-identifiers-for-item-provider)))

(define (nsurl-supports-secure-coding)
  (%msg-v->b (objc_getClass "NSURL") %sel-nsurl-supports-secure-coding))

