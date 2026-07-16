// Integration check for the Swift-native `s:` residual trampolines (fn-trampoline-spine-k53,
// ADR-0027 ported to TS/N-API).
//
// Loads the REAL Swift-native N-API addon and exercises a generated-shaped `aw_ts_swift_*`
// trampoline: a `objc_exposed == false` scalar free function reachable ONLY across the Swift
// ABI (ADR-0025). The entry is a napi callback that `import`s the owning framework and calls
// the API by name (swiftc owns the Swift ABI, ADR-0027 §1) — proving the residual path runs
// end-to-end, headless on arm64. The one exemplar (the sbcl swift-native-probe's own choice):
//   - CoreGraphics.hypot(CGFloat, CGFloat) -> CGFloat, dispatched with (3, 4) → 5.0.
//
// Run: node targets/typescript/bindings/node/native/test/swift-native.mjs
// Requires: the addon built (build.sh).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));
const addon = require(addonPath);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// The residual trampoline entry is registered on the addon (the emitted `.ts` call site's target).
check('addon exports aw_ts_swift_CoreGraphics_hypot', typeof addon.aw_ts_swift_CoreGraphics_hypot === 'function');

// The mechanism: call-by-name into CoreGraphics's Swift-native `hypot(CGFloat,CGFloat)` overload.
// This decl has no reachable C symbol for the CGFloat overload — the only way to call it is the
// swiftc-compiled by-name trampoline (ADR-0025 residual). (3,4,5) is the classic right triangle.
const r = addon.aw_ts_swift_CoreGraphics_hypot(3, 4);
check('hypot(3, 4) === 5', r === 5, r);

// A second, non-integer case proves it is real floating-point math, not a fixed answer.
const r2 = addon.aw_ts_swift_CoreGraphics_hypot(5, 12);
check('hypot(5, 12) === 13', r2 === 13, r2);

const r3 = addon.aw_ts_swift_CoreGraphics_hypot(1, 1);
check('hypot(1, 1) ≈ √2', Math.abs(r3 - Math.SQRT2) < 1e-12, r3);

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);
