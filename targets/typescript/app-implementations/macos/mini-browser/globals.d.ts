// A minimal ambient declaration for the Node globals this app reads — deliberately not a
// dependency on @types/node (this app has no node_modules of its own; @apianyware/runtime and the
// generated corpus need no Node globals at all, so pulling in the full Node type surface for two
// globals would be disproportionate). See hello-window's globals.d.ts for `process`;
// ui-controls-gallery's for `console` (this app's own launch diagnostic uses it too).
declare const process: { readonly env: Readonly<Record<string, string | undefined>> };
declare const console: { log(...args: unknown[]): void };
