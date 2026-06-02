# mini-browser x racket

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Navigation toolbar (back/forward, Reload, URL field, Go) + WKWebView render.
- 🟢 WKWebView loaded live https://www.apple.com/ and rendered the full page
  (region chooser, nav bar, hero logo) — end-to-end WebKit integration through
  generated bindings + native dispatch. Window title tracks the page title.
- TestAnyware VM (macOS 26.3).
