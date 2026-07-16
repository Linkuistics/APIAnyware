# PDFKit Viewer (Node TypeScript)

Ladder rung 4/7: a 720×540 resizable window titled "PDFKit Viewer" with a toolbar
(`Open…`/`◀`/`▶` + a "Page n of N" status label) over a `PDFView`. The user opens a `.pdf`
through the standard open panel; the toolbar buttons step through its pages; the label stays
synchronized with the view's current page via PDFKit's page-changed notification — however the
page turns (buttons, arrow keys, or scrolling).

Written against the settled ADR-0055 object-model surface, same as hello-window/
ui-controls-gallery/scenekit-viewer. First app in the ladder to exercise `@apianyware/pdfkit`, a
modal `NSOpenPanel`, and an `NSNotificationCenter` observer — one `__subclassAlloc`/
`__bindSubclass` handler object (`PdfController`) carries all four selectors: the three
target-actions (`openDocument:`/`goPrev:`/`goNext:`) *and* the notification callback
(`pageChanged:`).

## Files

| File | Role |
|---|---|
| `app.ts` | the app — builds the window, toolbar, `PDFView`, and the `PdfController` handler |
| `globals.d.ts` | the ambient Node globals (`process.env`, `console`) app.ts reads |
| `bootstrap.cjs` | entry point: registers `loader.mjs`, installs the native dispatch backend, THEN imports `app.js` |
| `loader.mjs` | a Node ESM `resolve` hook — bare `@apianyware/*` specifiers + extensionless relative imports |
| `embed_main.mm` | the dev launcher: a native `main()`-owner that embeds Node under AppKit and pumps libuv as a guest — identical to hello-window's |
| `tsconfig.json` | compiles `app.ts` + its transitive `@apianyware/*` closure into `build/js/` |
| `build.sh` | full build: regenerate bindings/addon if absent → tsc compile → link the launcher |

## Build

```sh
targets/typescript/app-implementations/macos/pdfkit-viewer/build.sh
# → targets/typescript/app-implementations/macos/pdfkit-viewer/build/pdfkit-viewer-launcher
```

## Run

```sh
# Host construction pre-flight (no window shown — safe to run on your own machine):
AW_PKV_SMOKE=1 build/pdfkit-viewer-launcher

# The real run (pops a real window — TestAnyware VM only, never on your own screen):
build/pdfkit-viewer-launcher
```

Quit via Cmd-Q or the "Quit PDFKit Viewer" menu item.

The app ships no document — the only way one enters is the `Open…` panel. A 3-page fixture PDF
(`PAGE 1`/`PAGE 2`/`PAGE 3` markers) lives at `apps/macos/pdfkit-viewer/fixtures/fixture.pdf` for
VM verification.

## Not the shipped launcher

Same posture as hello-window's own `embed_main.mm` — a dev-loop launcher reused as-is by every
ladder rung until Step 8 (`bundle-typescript`, ADR-0060) lands. See hello-window's README for the
full rationale.
