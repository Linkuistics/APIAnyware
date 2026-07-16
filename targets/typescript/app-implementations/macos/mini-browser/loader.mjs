// loader.mjs — a Node ESM `resolve` hook, NOT a bundler. Identical to hello-window's own
// loader.mjs (see its doc for the full rationale): maps bare `@apianyware/<fw>` specifiers to
// this app's own compiled output tree, and appends `.js` to an extensionless relative specifier
// on a first-resolve failure (every generated barrel re-exports its class files that way).
//
// Registered by bootstrap.cjs via `module.register()` before the app module is ever imported.

import { pathToFileURL, fileURLToPath } from 'node:url';
import path from 'node:path';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const GENERATED_ROOT = path.join(HERE, 'build', 'js', 'bindings', 'macos', 'generated');
const RUNTIME_INDEX = path.join(HERE, 'build', 'js', 'bindings', 'node', 'runtime', 'src', 'index.js');

export async function resolve(specifier, context, nextResolve) {
  if (specifier.startsWith('@apianyware/')) {
    const name = specifier.slice('@apianyware/'.length);
    const target = name === 'runtime' ? RUNTIME_INDEX : path.join(GENERATED_ROOT, name, 'index.js');
    return nextResolve(pathToFileURL(target).href, context);
  }
  if (specifier.startsWith('.') || specifier.startsWith('/') || specifier.startsWith('file:')) {
    try {
      return await nextResolve(specifier, context);
    } catch (err) {
      if (err?.code === 'ERR_MODULE_NOT_FOUND') {
        return nextResolve(`${specifier}.js`, context);
      }
      throw err;
    }
  }
  return nextResolve(specifier, context);
}
