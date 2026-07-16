# Note Editor (Node TypeScript)

Ladder rung 6/7: a 900×600 resizable window split side-by-side into a plain-text Markdown editor
(`NSTextView` in an `NSScrollView`) and a live HTML preview (`WKWebView`), with a toolbar
(`New`/`Open…`/`Save…`/`Undo`/`Redo` + a status line). A single-document model (current path +
dirty flag) drives the window title and the document-edited indicator. Save uses an `NSSavePanel`
sheet with an async completion handler on first save, then direct-overwrites; Open uses a modal
`NSOpenPanel`; New/Open guard unsaved changes with a warning alert; Undo/Redo drive the text
view's own `NSUndoManager`.

Written against the settled ADR-0055 object-model surface, same as hello-window/
ui-controls-gallery/scenekit-viewer/pdfkit-viewer/mini-browser. **First app in the ladder to
exercise `NSTextView`/`NSSplitView`/`NSScrollView`, `NSUndoManager`, an `NSSavePanel` sheet (an
escaping block completion handler, vs. pdfkit-viewer's modal-only panel usage), and Node's own
`fs`** — file I/O is deliberately not a Cocoa API (spec §8). One controller object carries six
selectors: five toolbar target-actions plus the `NSTextDidChangeNotification` observer — see
`learnings.md` for how the two prerequisite gaps (the Save sheet's block call site, the
Undo/Redo surface) were closed by prior leaves before this app was built.

## Files

| File | Role |
|---|---|
| `app.ts` | the app — window/toolbar/split-view/text-view/web-view construction, the `NoteController` handler, the pure-TypeScript Markdown→HTML renderer |
| `globals.d.ts` | the ambient Node globals (`process.env`, `console`, `node:fs`'s two functions this app calls) app.ts reads |
| `bootstrap.cjs` | entry point: registers `loader.mjs`, installs the native dispatch backend, THEN imports app.js |
| `loader.mjs` | a Node ESM `resolve` hook — bare `@apianyware/*` specifiers + extensionless relative imports |
| `embed_main.mm` | the dev launcher: a native `main()`-owner that embeds Node under AppKit and pumps libuv as a guest — identical to hello-window's |
| `tsconfig.json` | compiles `app.ts` + its transitive `@apianyware/*` closure into `build/js/` |
| `build.sh` | full build: regenerate bindings/addon if absent → tsc compile → link the launcher (links `-framework WebKit`) |

## Build

```sh
targets/typescript/app-implementations/macos/note-editor/build.sh
# → targets/typescript/app-implementations/macos/note-editor/build/note-editor-launcher
```

## Run

```sh
# Host construction pre-flight (no window shown — safe to run on your own machine):
AW_NE_SMOKE=1 build/note-editor-launcher

# The real run (pops a real window — TestAnyware VM only, never on your own screen):
build/note-editor-launcher
```

Quit via Cmd-Q or the "Quit Note Editor" menu item.

## Not the shipped launcher

Same posture as hello-window's own `embed_main.mm` — a dev-loop launcher reused as-is by every
ladder rung until Step 8 (`bundle-typescript`, ADR-0060) lands. See hello-window's README for the
full rationale.
