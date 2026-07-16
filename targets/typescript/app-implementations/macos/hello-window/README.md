# Hello Window (Node TypeScript)

The simplest sample app (ladder rung 1/7): a 400×200 centred window titled "Hello from Node
TypeScript" with a centred 24 pt "Hello, macOS!" label, a standard application menu (Quit only),
and AppKit's own run loop pumping the Node event loop as a guest (ADR-0056). The forcing function
that stood up the Node TypeScript target's first real GUI app pipeline — see `learnings.md`.

Written against the settled ADR-0055 object-model surface: real ES6 classes (`NSApplication`,
`NSWindow`, `NSTextField`, …) from the generated `@apianyware/appkit`/`@apianyware/foundation`
modules, `__alloc(Cls)` + an `init…` instance method for construction (ADR-0055 §6's "faithful
alloc/init" — `__alloc` is a shared runtime primitive, not emitted per class; see `classes.ts`).

## Files

| File | Role |
|---|---|
| `app.ts` | the app — builds the menu, window, and label; no `NSApplication.run()` call (see below) |
| `globals.d.ts` | the one ambient Node global (`process.env`) app.ts reads, without a full `@types/node` dependency |
| `bootstrap.cjs` | entry point: registers `loader.mjs`, installs the native dispatch backend, THEN imports `app.js` |
| `loader.mjs` | a Node ESM `resolve` hook — bare `@apianyware/*` specifiers + extensionless relative imports (not a bundler; see its own doc and ADR-0060 §4) |
| `embed_main.mm` | the dev launcher: a native `main()`-owner that embeds Node under AppKit and pumps libuv as a guest, adapted from `native/harness/embed_main.mm` (test-only) for a real window |
| `tsconfig.json` | compiles `app.ts` + its transitive `@apianyware/*` closure (17 frameworks + the runtime) into `build/js/` |
| `build.sh` | full build: regenerate bindings/addon if absent → tsc compile → link the launcher |

## Build

```sh
targets/typescript/app-implementations/macos/hello-window/build.sh
# → targets/typescript/app-implementations/macos/hello-window/build/hello-window-launcher
```

## Run

```sh
# Host construction pre-flight (no window shown — safe to run on your own machine):
AW_HELLO_SMOKE=1 build/hello-window-launcher

# The real run (pops a real window — TestAnyware VM only, never on your own screen):
build/hello-window-launcher
```

Quit via Cmd-Q or the "Quit Hello Window" menu item — both route to `-[NSApplication terminate:]`
through the standard nil-targeted responder chain (no delegate/target wiring needed).

## Why no `NSApplication.run()` call in `app.ts`

The native launcher (`embed_main.mm`) owns `main()` and calls `[NSApp run]` itself, AFTER
`app.ts`'s top-level code finishes building the UI (ADR-0056). A JS call to `.run()` would
re-introduce the blocking JS→native call the whole pump architecture exists to avoid — the
k6 FINDINGS this target's substrate spike already established.

## Not the shipped launcher

`embed_main.mm` here (like its `native/harness/` ancestor) is a dev-loop launcher: it resolves its
own app directory at runtime from the executable's path (so a build from this host can be copied
to a TestAnyware VM verbatim) and links against the *host's* `libnode`/`libuv` at their absolute
Homebrew paths — VM-verification vendors those (plus their transitive Homebrew dependency closure)
onto the guest at the same absolute paths rather than repeat the build there. The **shipped**
per-app launcher — a per-app-compiled binary with baked bundle identity and a vendored, relocated
`libnode` — is Step 8 (`bundle-typescript`, ADR-0060); this dev launcher is reused as-is by every
later ladder rung until that lands.
