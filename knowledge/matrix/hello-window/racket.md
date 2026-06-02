# hello-window x racket

**2026-03-31:**
- 🟡 Window + centered label render correctly — validated in TestAnyware VM

**2026-06-02 (Racket 9.2 + ffi2, native dispatch):**
- 🟢 Re-verified after the ffi2 / generated-native-dispatch (ADR-0013) migration.
  Window "Hello from Racket" + centered "Hello, macOS!" label render correctly;
  correct menu-bar app name via `CFBundleName`. TestAnyware VM (macOS 26.3).
