# Mini Browser (Node TypeScript)

Ladder rung 5/7: an 800×600 resizable window titled "Mini Browser" with a toolbar
(`◀`/`▶`/`Reload`/an address field/`Go`) over a `WKWebView`, and a status line that mirrors the
`WKNavigationDelegate` callbacks. Typing a URL (or a bare host) and pressing Return or clicking Go
navigates — a missing scheme gets `https://` prepended; `◀`/`▶` walk the web view's own
back-forward history.

Written against the settled ADR-0055 object-model surface, same as hello-window/
ui-controls-gallery/scenekit-viewer/pdfkit-viewer. **First app in the ladder to exercise WebKit
and an async, multi-callback ObjC delegate *protocol*** (`WKNavigationDelegate`) via the runtime's
dedicated delegate machinery: the navigation delegate is a **plain JS object literal** implementing
the generated `WKNavigationDelegate` interface, bridged automatically when passed to
`setNavigationDelegate_` — no subclass, no manual keep-alive. Target-action (the four toolbar
buttons + the address field's Return action) still uses the `__subclassAlloc`/`__bindSubclass`
pattern the first four apps established (`NSControl.setTarget_` requires a real ObjC object) — see
`learnings.md` for why the two mechanisms split cleanly by framework slot.

## Files

| File | Role |
|---|---|
| `app.ts` | the app — builds the window, toolbar, `WKWebView`, the `BrowserController` target-action handler, and the `navigationDelegate` object literal |
| `globals.d.ts` | the ambient Node globals (`process.env`, `console`) app.ts reads |
| `bootstrap.cjs` | entry point: registers `loader.mjs`, installs the native dispatch backend, THEN imports app.js |
| `loader.mjs` | a Node ESM `resolve` hook — bare `@apianyware/*` specifiers + extensionless relative imports |
| `embed_main.mm` | the dev launcher: a native `main()`-owner that embeds Node under AppKit and pumps libuv as a guest — identical to hello-window's |
| `tsconfig.json` | compiles `app.ts` + its transitive `@apianyware/*` closure into `build/js/` |
| `build.sh` | full build: regenerate bindings/addon if absent → tsc compile → link the launcher (links `-framework WebKit`) |

## Build

```sh
targets/typescript/app-implementations/macos/mini-browser/build.sh
# → targets/typescript/app-implementations/macos/mini-browser/build/mini-browser-launcher
```

## Run

```sh
# Host construction pre-flight (no window shown — safe to run on your own machine; this DOES
# kick off a real network request to the home URL, https://example.com):
AW_MB_SMOKE=1 build/mini-browser-launcher

# The real run (pops a real window — TestAnyware VM only, never on your own screen):
build/mini-browser-launcher
```

Quit via Cmd-Q or the "Quit Mini Browser" menu item.

The app has one fixed home URL (`https://example.com`), prefilled into the address field and
navigated to at launch through the same text-navigation rule user input uses.

## Not the shipped launcher

Same posture as hello-window's own `embed_main.mm` — a dev-loop launcher reused as-is by every
ladder rung until Step 8 (`bundle-typescript`, ADR-0060) lands. See hello-window's README for the
full rationale.
