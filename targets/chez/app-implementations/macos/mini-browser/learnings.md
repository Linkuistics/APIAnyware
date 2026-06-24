# mini-browser x chez

**2026-05-29 (source-exec port):**
- 🟡 Async WKNavigationDelegate (4 selectors) + UI target-action (4 selectors)
  all fire incl. the failure path (`didFailProvisionalNavigation:` → NSAlert);
  RSS flat across a reload loop. Source-exec/precompile bundle (121 MB). See
  `targets/chez/bindings/macos/reports/mini-browser/report.md`.

**2026-05-30 (standalone, leaf `060/050/050`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  4.9 MB, kernel baked in) in a **no-Chez VM** (network reachable). WKWebView
  renders live pages (apple.com, example.com); async didStart/didFinish fire
  ("Loading…"→"Done", title/address refresh); go:/back: navigate with history.
  RSS stable ~143 MB across ~6 navigations — no async-callback leak. Error-path
  selectors covered-by-construction (field-input quirk blocked a live re-trigger;
  proven live in the source-exec run above). See the report's standalone section.
