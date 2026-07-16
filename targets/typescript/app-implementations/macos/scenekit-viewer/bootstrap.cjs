// bootstrap.cjs — the entry the native launcher's `LoadEnvironment` boot script requires. Same
// shape as hello-window's bootstrap.cjs (see its own doc for the full rationale — CJS referrer,
// load order): register loader.mjs, install the native dispatch backend, THEN import app.js.
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
    pathToFileURL(path.join(HERE, 'build', 'js', 'app-implementations', 'macos', 'scenekit-viewer', 'app.js')).href,
  );
})().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
