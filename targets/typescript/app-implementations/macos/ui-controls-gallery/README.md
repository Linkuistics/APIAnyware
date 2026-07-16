# UI Controls Gallery (Node TypeScript)

The broad-surface AppKit control roster (ladder rung 2/7): a single 480×820 window presenting the
14 control kinds `apps/macos/ui-controls-gallery/docs/spec.md` §6 requires — push button, checkbox,
radio group, slider, stepper, progress bar, spinner, pop-up button, combo box, text field, secure
text field, colour well, date picker, and an image view — each grouped under a bold section header.
The portfolio's visual-regression baseline for the AppKit binding; see `learnings.md` for what it
found, including the one control (the radio pair) that needed real target-action wiring.

Reuses hello-window's dev-launcher/bootstrap/loader shape unchanged (`embed_main.mm`,
`bootstrap.cjs`, `loader.mjs`, `tsconfig.json` are all structurally identical — only app-specific
names/paths differ); see hello-window's own README for the full rationale of that shape.

## Files

| File | Role |
|---|---|
| `app.ts` | the app — builds the menu, window, and 14-control roster; wires the radio pair's target-action; no `NSApplication.run()` call (see hello-window's README for why) |
| `globals.d.ts` | ambient Node globals this app reads (`process.env`, `console.log`), without a full `@types/node` dependency |
| `bootstrap.cjs` / `loader.mjs` | entry point + ESM resolve hook, identical shape to hello-window's own |
| `embed_main.mm` | the dev launcher, identical shape to hello-window's own (only the smoke env var name — `AW_UCG_SMOKE` — differs) |
| `tsconfig.json` | compiles `app.ts` + its transitive `@apianyware/*` closure into `build/js/` |
| `build.sh` | full build: regenerate bindings/addon if absent → tsc compile → link the launcher |

## Build

```sh
targets/typescript/app-implementations/macos/ui-controls-gallery/build.sh
# → targets/typescript/app-implementations/macos/ui-controls-gallery/build/ui-controls-gallery-launcher
```

## Run

```sh
# Host construction pre-flight (no window shown — safe to run on your own machine):
AW_UCG_SMOKE=1 build/ui-controls-gallery-launcher

# The real run (pops a real window — TestAnyware VM only, never on your own screen):
build/ui-controls-gallery-launcher
```

Quit via Cmd-Q or the "Quit UI Controls Gallery" menu item — both route to
`-[NSApplication terminate:]` through the standard nil-targeted responder chain.

## Not the shipped launcher

Same posture as hello-window: `embed_main.mm` here is a dev-loop launcher, reused as-is by every
later ladder rung until Step 8 (`bundle-typescript`, ADR-0060) lands the shipped per-app launcher.
