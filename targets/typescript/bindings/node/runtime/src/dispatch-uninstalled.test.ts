import { expect, test } from 'vitest';
import { __dispatch } from './dispatch.js';

// This file NEVER installs a dispatch backend, and vitest isolates module state per
// file — so it observes the pristine "addon not loaded" default (Step 4 provides the
// real addon; until then any dispatch access must fail loudly, not silently no-op).

test('the default __dispatch throws until a native addon is installed', () => {
  expect(() => __dispatch.release(1n)).toThrow(/native addon not loaded/i);
});
