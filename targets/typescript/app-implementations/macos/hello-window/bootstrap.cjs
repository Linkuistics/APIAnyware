// bootstrap.cjs — the entry the native launcher's `LoadEnvironment` boot script requires (and the
// entry a plain `node bootstrap.cjs` dev-run uses too). CommonJS, not an ES module: the embedder's
// dynamic `import()` needs a real CJS-file referrer to resolve against (a bare inline boot-script
// string passed straight to `LoadEnvironment` has no such referrer and fails with
// ERR_UNKNOWN_BUILTIN_MODULE on its own first `import()` — the k42 harness's `app.cjs` sidesteps
// this the same way: `require()` a real file from the boot string, do every ESM-only step inside
// it via an async IIFE).
//
// Order is load-bearing:
//   1. Register loader.mjs's specifier-resolution hook (bare `@apianyware/*` + extensionless
//      relative imports — see its own doc).
//   2. Load the runtime and install the real native dispatch backend.
//   3. ONLY THEN import app.js.
//
// Step 3 must come last because an ES module's static imports evaluate before anything else in
// the importing file runs: app.js's top-level `import { NSWindow } from '@apianyware/appkit'`
// would otherwise execute NSWindow's `static { __registerClass(...) }` / `static __cls =
// __class(...)` against dispatch.ts's throwing NOT_LOADED sentinel.
'use strict';

const { register } = require('node:module');
const path = require('node:path');
const { pathToFileURL } = require('node:url');

const HERE = __dirname;

register(pathToFileURL(path.join(HERE, 'loader.mjs')).href);

(async () => {
  const addonPath = path.join(
    HERE, '..', '..', '..', 'bindings', 'node', 'native', 'build', 'APIAnywareTypeScript.node',
  );
  const runtime = await import(
    pathToFileURL(path.join(HERE, 'build', 'js', 'bindings', 'node', 'runtime', 'src', 'index.js')).href,
  );
  const addon = require(addonPath);
  runtime.__installDispatch(addon);

  await import(
    pathToFileURL(path.join(HERE, 'build', 'js', 'app-implementations', 'macos', 'hello-window', 'app.js')).href,
  );
})().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
