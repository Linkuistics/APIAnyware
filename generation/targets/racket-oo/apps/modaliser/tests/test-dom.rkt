#lang racket/base
;; tests/test-dom.rkt — Tests for ui/dom.rkt HTML builder

(require rackunit
         racket/string
         "../ui/dom.rkt")

;; ─── html-escape ──────────────────────────────────────────────

(test-case "html-escape: no special characters"
  (check-equal? (html-escape "hello") "hello"))

(test-case "html-escape: ampersand"
  (check-equal? (html-escape "a&b") "a&amp;b"))

(test-case "html-escape: angle brackets"
  (check-equal? (html-escape "<div>") "&lt;div&gt;"))

(test-case "html-escape: quotes"
  (check-equal? (html-escape "a\"b'c") "a&quot;b&#39;c"))

(test-case "html-escape: all special characters"
  (check-equal? (html-escape "&<>\"'") "&amp;&lt;&gt;&quot;&#39;"))

(test-case "html-escape: empty string"
  (check-equal? (html-escape "") ""))

;; ─── render-attrs ─────────────────────────────────────────────

(test-case "render-attrs: empty"
  (check-equal? (render-attrs '()) ""))

(test-case "render-attrs: single string attribute"
  (check-equal? (render-attrs '((class . "foo"))) " class=\"foo\""))

(test-case "render-attrs: multiple attributes"
  (check-equal? (render-attrs '((class . "foo") (id . "bar")))
                " class=\"foo\" id=\"bar\""))

(test-case "render-attrs: boolean true"
  (check-equal? (render-attrs '((disabled . #t))) " disabled"))

(test-case "render-attrs: boolean false omitted"
  (check-equal? (render-attrs '((hidden . #f))) ""))

(test-case "render-attrs: escapes attribute values"
  (check-equal? (render-attrs '((title . "a\"b")))
                " title=\"a&quot;b\""))

(test-case "render-attrs: #f input"
  (check-equal? (render-attrs #f) ""))

;; ─── element ──────────────────────────────────────────────────

(test-case "element: simple div"
  (check-equal? (html->string (div '() "hello"))
                "<div>hello</div>"))

(test-case "element: div with attributes"
  (check-equal? (html->string (div '((class . "test")) "content"))
                "<div class=\"test\">content</div>"))

(test-case "element: nested elements"
  (check-equal? (html->string (div '() (span '() "inner")))
                "<div><span>inner</span></div>"))

(test-case "element: text children are HTML-escaped"
  (check-equal? (html->string (span '() "<script>alert(1)</script>"))
                "<span>&lt;script&gt;alert(1)&lt;/script&gt;</span>"))

(test-case "element: void element (br)"
  (check-equal? (html->string (br)) "<br>"))

(test-case "element: void element (img with attrs)"
  (check-equal? (html->string (img '((src . "pic.png") (alt . "A pic"))))
                "<img src=\"pic.png\" alt=\"A pic\">"))

(test-case "element: void element (input)"
  (check-equal? (html->string (input-element '((type . "text") (value . "hi"))))
                "<input type=\"text\" value=\"hi\">"))

(test-case "element: multiple children"
  (check-equal? (html->string (ul '()
                                (li '() "one")
                                (li '() "two")))
                "<ul><li>one</li><li>two</li></ul>"))

;; ─── raw-html ─────────────────────────────────────────────────

(test-case "raw-html: not double-escaped"
  (let ([raw (make-raw-html "<b>bold</b>")])
    (check-true (raw-html? raw))
    (check-equal? (raw-html-content raw) "<b>bold</b>")
    ;; When used as a child, should not be escaped
    (check-equal? (html->string (div '() raw))
                  "<div><b>bold</b></div>")))

;; ─── style-element / script-element ───────────────────────────

(test-case "style-element: CSS not escaped"
  (check-equal? (html->string (style-element '() "body { color: red; }"))
                "<style>body { color: red; }</style>"))

(test-case "script-element: JS not escaped"
  (check-equal? (html->string (script-element '() "var x = 1 < 2;"))
                "<script>var x = 1 < 2;</script>"))

;; ─── html-document ────────────────────────────────────────────

(test-case "html-document: full document"
  (let ([doc (html-document
              (style-element '() "body{}")
              (div '((id . "app")) "Hello"))])
    (check-true (string-contains? doc "<!DOCTYPE html>"))
    (check-true (string-contains? doc "<head><meta charset=\"utf-8\"><style>body{}</style></head>"))
    (check-true (string-contains? doc "<body><div id=\"app\">Hello</div></body>"))))

(test-case "html-document: null head"
  (let ([doc (html-document #f (div '() "ok"))])
    (check-true (string-contains? doc "<head><meta charset=\"utf-8\"></head>"))
    (check-true (string-contains? doc "<body><div>ok</div></body>"))))

;; ─── html->string ─────────────────────────────────────────────

(test-case "html->string: raw-html"
  (check-equal? (html->string (make-raw-html "<p>hi</p>")) "<p>hi</p>"))

(test-case "html->string: plain string passthrough"
  (check-equal? (html->string "plain") "plain"))

(displayln "test-dom: all tests passed")
