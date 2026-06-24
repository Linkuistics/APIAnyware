# hello-window x chez

**2026-05-28:**
- 🟡 Window + centered label render correctly — validated in TestAnyware VM
  after runtime fix for bundled dylib lookup. See
  `targets/chez/bindings/macos/reports/hello-window/report.md`.

**2026-05-30 (standalone, leaf `060/050/010`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  4.5 MB, kernel baked in). Launches + renders correctly in a **no-Chez VM**
  (no provisioning); menu bar now reads "Hello Window", banner suppressed. See
  the "Standalone re-verification" section of the report.
