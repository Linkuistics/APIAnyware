# SceneKit Viewer (Node TypeScript)

Ladder rung 3/7: a 640×480 resizable window titled "SceneKit Viewer" with a toolbar (a geometry
pop-up picker + a "Colour…" button) over a dark-grey `SCNView`. A lit cube spins continuously;
picking a different shape swaps the geometry, and the colour button opens the shared
`NSColorPanel` to recolour the geometry live. The chosen colour is application state, re-applied
after every geometry swap — see `learnings.md` for why.

Written against the settled ADR-0055 object-model surface, same as hello-window/
ui-controls-gallery. First app in the ladder to exercise `@apianyware/scenekit` and to route
**three** target-action selectors through one `__subclassAlloc`/`__bindSubclass` handler object
(`SceneController`).

## Files

| File | Role |
|---|---|
| `app.ts` | the app — builds the window, toolbar, scene graph, and the `SceneController` handler |
| `globals.d.ts` | the one ambient Node global (`process.env`) app.ts reads |
| `bootstrap.cjs` | entry point: registers `loader.mjs`, installs the native dispatch backend, THEN imports `app.js` |
| `loader.mjs` | a Node ESM `resolve` hook — bare `@apianyware/*` specifiers + extensionless relative imports |
| `embed_main.mm` | the dev launcher: a native `main()`-owner that embeds Node under AppKit and pumps libuv as a guest — identical to hello-window's |
| `tsconfig.json` | compiles `app.ts` + its transitive `@apianyware/*` closure into `build/js/` |
| `build.sh` | full build: regenerate bindings/addon if absent → tsc compile → link the launcher |

## Build

```sh
targets/typescript/app-implementations/macos/scenekit-viewer/build.sh
# → targets/typescript/app-implementations/macos/scenekit-viewer/build/scenekit-viewer-launcher
```

## Run

```sh
# Host construction pre-flight (no window shown — safe to run on your own machine):
AW_SKV_SMOKE=1 build/scenekit-viewer-launcher

# The real run (pops a real window — TestAnyware VM only, never on your own screen):
build/scenekit-viewer-launcher
```

Quit via Cmd-Q or the "Quit SceneKit Viewer" menu item.

## Not the shipped launcher

Same posture as hello-window's own `embed_main.mm` — a dev-loop launcher reused as-is by every
ladder rung until Step 8 (`bundle-typescript`, ADR-0060) lands. See hello-window's README for the
full rationale.
