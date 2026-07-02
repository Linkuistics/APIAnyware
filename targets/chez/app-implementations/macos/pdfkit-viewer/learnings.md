# pdfkit-viewer x chez

**2026-05-29 (source-exec port):**
- 🟡 Multi-delegate (4 selectors incl. NSNotificationCenter observer) fires;
  PDF loads + paginates in the TestAnyware VM. Source-exec/precompile bundle
  (107 MB). See `targets/chez/bindings/macos/reports/pdfkit-viewer/report.md`.

**2026-05-30 (standalone, leaf `060/050/040`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.0 MB, kernel baked in) in a **no-Chez VM**. All four selectors fire:
  openDocument: (NSOpenPanel → load), goNext:/goPrev: (page nav), pageChanged:
  (notification observer → "Page N of 3" label + button states). RSS ~226 MB
  with document loaded. See the "Standalone re-verification" section of the report.

**2026-07-02 (AppSpec instrument + build, leaf k99):**
- 🟢 Instrumented to the k96 logging contract
  (`apps/macos/pdfkit-viewer/docs/logging-contract.md`): emitter inlined in the
  `.sls` (the k90 rationale — a sibling `events.sls` would need an
  `apps/`-prefixed library name under the whole-program compile tree; only
  `(chezscheme)` names used), `pv-` prefixed, with the two `[document]`
  state-transition events + the lifecycle triad + the contract's string quoting.
- **App-level shape from the racket sibling (k98):** `refresh-ui!` returns the
  state it applied (`#f` empty / `(page . total)` loaded), so both `[document]`
  events mirror the §7.2 label **by construction** — including the
  nil-current-page → `page=1` fallback. `opened` emits only on the open success
  path, post-state (store + `setDocument:` + refresh already applied); the
  basename comes from `nsurl-last-path-component` + `nsstring-utf8-string`
  (FFI `string` return maps NULL → `#f`, hence the `(or … "")` guard); cancel /
  nil URL / failed `initWithURL:` stay silent. `page-changed` rides the existing
  `pageChanged:` observer, post-refresh. New `applicationWillTerminate:`
  delegate → `reason=menu`; startup + test-config no-op are top-level
  expressions before `(main)` (R6RS body semantics, the k90 placement).
- **PDFKit bindings had to be regenerated first** (the k98 collection landed
  after the last chez generate): `apianyware-generate --target chez` (29 PDFKit
  classes; trampolines grew to 170 entries) + `swift build --product
  APIAnywareChez` relink — product not target, [[swift_build_product_vs_target]].
  build.sh's prereq check now keys on `apianyware/pdfkit.sls` (not `appkit.sls`)
  so a pre-PDFKit binding tree triggers regeneration.
- **Gotcha:** the bundler's chez deps walker `read`s the whole `.sls` before
  compiling — a paren miscount in a hand-edit surfaces there as "unexpected
  end-of-file reading list", not at the emitter test. A plain `chez -q` read
  loop over the file is the fast pre-flight.
- 🟢 Emitter verified in isolation against the contract matchers (block
  extracted verbatim, `chez --script`, 16 assertions — startup-first ordering,
  bare launch line, contract example lines, quoting edges, truncate-on-startup,
  post-close no-op, fixed-default path). Built standalone via new `build.sh`
  (k90 recipe + shared-identity re-sign): `PDFKitViewer-chez.app` (5.2 MB),
  `CFBundleIdentifier=com.linkuistics.pdfkit-viewer-chez`. Descriptor
  `pdfkit-viewer-impl.rkt` authored. Live launch + document interaction is the
  Tier-2 live-run leaf's bar (VM).
