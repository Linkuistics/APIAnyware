// A minimal ambient declaration for the Node globals this app reads — deliberately not a
// dependency on @types/node (this app has no node_modules of its own; @apianyware/runtime and the
// generated corpus need no Node globals at all, so pulling in the full Node type surface for a
// handful of globals would be disproportionate). See hello-window's globals.d.ts for `process`;
// ui-controls-gallery's for `console`.
declare const process: { readonly env: Readonly<Record<string, string | undefined>> };
declare const console: { log(...args: unknown[]): void };

// This app is the FIRST in the ladder to touch the filesystem directly from app.ts (spec §8 —
// file I/O is deliberately not a Cocoa API). Only the two functions this app calls, typed exactly
// as used (a `'utf8'` encoding literal, matching the two real call sites in app.ts) — same
// minimal-surface posture as the two globals above, not a partial `@types/node` shim.
declare module 'node:fs' {
  export function readFileSync(path: string, encoding: 'utf8'): string;
  export function writeFileSync(path: string, data: string, encoding: 'utf8'): void;
}
