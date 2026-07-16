// A minimal ambient declaration for the one Node global this app reads, without a full
// @types/node dependency — see hello-window's globals.d.ts for the rationale (identical here).
declare const process: { readonly env: Readonly<Record<string, string | undefined>> };
declare const console: { log(...args: unknown[]): void };
