# Drawing Canvas (Node TypeScript)

Ladder rung 7/7 — the **last** sample app: a 640×480 resizable window with a 36-point toolbar band
(`Color…` button, a 1–20 line-width slider, `Clear` button) over a freehand-drawing canvas. The
canvas is a dynamic `NSView` subclass overriding `drawRect:` (repaints every stroke via direct
CoreGraphics C calls) and `mouseDown:`/`mouseDragged:`/`mouseUp:` (the drawing gesture) — the
portfolio's custom-view showcase. Each stroke freezes its colour and width at mouse-down; tool
changes never repaint existing strokes.

Written against the settled ADR-0055 object-model surface, same as the rest of the ladder. **First
app to subclass `NSView` itself** (every earlier subclass was a plain `NSObject` target-action
controller) and the first to need an explicit inbound `CallbackMarshal` for an `OBJ`-kind override
argument (`NSEvent`) — see `app.ts`'s own header comment and `learnings.md` for the two prerequisite
gaps (`inbound-struct-arg-surface-k123`, `coregraphics-context-function-surface-k124`) this app
unblocked.

## Files

| File | Role |
|---|---|
| `app.ts` | the app — window/toolbar/canvas construction, `DrawingCanvasView` (the NSView subclass), `ToolbarController` (the four target-actions) |
| `globals.d.ts` | the ambient Node globals (`process.env`, `console`) app.ts reads |
| `bootstrap.cjs` | entry point: registers `loader.mjs`, installs the native dispatch backend, THEN imports app.js |
| `loader.mjs` | a Node ESM `resolve` hook — bare `@apianyware/*` specifiers + extensionless relative imports |
| `embed_main.mm` | the dev launcher: a native `main()`-owner that embeds Node under AppKit and pumps libuv as a guest — identical to hello-window's |
| `tsconfig.json` | compiles `app.ts` + its transitive `@apianyware/*` closure into `build/js/` |
| `build.sh` | full build: regenerate bindings/addon if absent → tsc compile → link the launcher |

## Build

```sh
targets/typescript/app-implementations/macos/drawing-canvas/build.sh
# → targets/typescript/app-implementations/macos/drawing-canvas/build/drawing-canvas-launcher
```

## Run

```sh
# Host construction pre-flight (no window shown — safe to run on your own machine):
AW_DC_SMOKE=1 build/drawing-canvas-launcher

# The real run (pops a real window — TestAnyware VM only, never on your own screen):
build/drawing-canvas-launcher
```

Quit via Cmd-Q or the "Quit Drawing Canvas" menu item.

## Not the shipped launcher

Same posture as hello-window's own `embed_main.mm` — a dev-loop launcher reused as-is by every
ladder rung until Step 8 (`bundle-typescript`, ADR-0060) lands. See hello-window's README for the
full rationale.
