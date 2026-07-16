// loader.mjs — a Node ESM `resolve` hook, NOT a bundler (ADR-0060 §4 rules out a JS-bundler
// dependency for the shipped app; this is the mechanism that makes "Node's own ESM loader
// resolves the rest" concrete). Two gaps it closes, both inherent to the emitter's output shape
// (ADR-0055 §2's per-framework-module design), not bugs in the generated code:
//
//  1. Bare `@apianyware/<fw>` specifiers (every generated class file cross-references its own and
//     other frameworks' classes through the package name, never a relative path) have no
//     `node_modules/@apianyware/<fw>` package to resolve against — mapped here straight to this
//     app's own compiled output tree.
//  2. Each framework's `index.js` barrel re-exports every class file with an EXTENSIONLESS
//     relative specifier (`export * from './nswindow'`) — deliberately, so the same emitted source
//     serves both this loader and a future real bundler (ADR-0060's own tsconfig comment). Real
//     Node ESM requires an explicit extension for a relative specifier, so this appends `.js` on a
//     first-resolve failure.
//
// Registered by bootstrap.mjs via `module.register()` before the app module is ever imported.

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
