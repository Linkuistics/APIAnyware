// A minimal ambient declaration for the one Node global this app reads — deliberately not a
// dependency on @types/node (this app has no node_modules of its own; @apianyware/runtime and the
// generated corpus need no Node globals at all, so pulling in the full Node type surface for one
// env var would be disproportionate).
declare const process: { readonly env: Readonly<Record<string, string | undefined>> };
