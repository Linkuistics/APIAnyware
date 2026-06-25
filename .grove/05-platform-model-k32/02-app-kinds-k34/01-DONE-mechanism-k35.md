# mechanism-k35

**Kind:** work

## Goal

ws4 child 2, **first sub-child**: stand up the **app-kinds mechanism** and prove the
`kind.apiw` grammar end-to-end with one exemplar. Build the new
`platforms/macos/tools/app-kinds` crate (parse + schema embed + typed enums + registry +
focused validator + standing test guard), author `schemas/spec-format/app-kind.kdl-schema`,
author the **`gui-app`** exemplar kind (`app-kinds/gui-app/{kind.apiw, docs/}`), and raise
the **app-kind-model ADR** (parallel to ADR-0048). The remaining six kinds follow
mechanically in child 2 (`remaining-kinds`) against this proven grammar.

## Context (inherited — see `grove-llm brief-chain`; node BRIEF carries the full steer)

- **Mirror two siblings.** Crate layout mirrors `apianyware-patterns`
  (`semantic/tools/patterns`: `lib`/`error`/`kind`/`apiw`/`schema`/`registry` + a
  `tests/` registry guard) for the *directory-of-authored-files* registry shape, and
  `apianyware-platform-manifest` (`platforms/macos/tools/platform-manifest`) for the
  platforms-domain home + `include_str!` schema embed + the `../../../../../schemas/`
  relative path depth. The app-kind enums are **flat serde enums in `kind.rs`** + schema
  `enum` constraints (like the manifest's `DiscoverSource`), *not* a side `vocab.rs` table.
- **`kind.apiw` carries (D2, projection-free):** a `process` block (entry / run-loop /
  termination — controlled enums); a `bundle` block (bundle type; optional
  `CFBundlePackageType`; optional principal-class key; optional extension-point identifier;
  required Info.plist keys); an `activation` policy (regular / accessory=`LSUIElement` /
  background=`LSBackgroundOnly` / hosted); and `test-obligation` references (forward
  pointers to child 3's `tests/app-kinds/<kind>.apiw`). Settle the exact grammar while
  authoring — keep it minimal; every field must be platform truth, never projection.
- **Ground in real shapes:** Info.plist keys the bundlers emit
  (`targets/_shared/tools/stub-launcher/src/generate.rs`: `CFBundleName`,
  `CFBundleIdentifier`, `CFBundleExecutable`, `CFBundlePackageType=APPL`,
  `CFBundleInfoDictionaryVersion`, `LSMinimumSystemVersion`, `NSHighResolutionCapable`).
  `gui-app` is the canonical bundled NSApplication case.
- **ADR** documents the *model* (distinct-entity decision, the process-model vocabulary,
  the platforms-domain crate home) — it earns the bar exactly when the crate + schema +
  exemplar establish it. Next number is **ADR-0049**; ADRs live in root `adr/`.
- **Crate registration:** add `platforms/macos/tools/app-kinds` to the root `Cargo.toml`
  `members` list AND a `apianyware-app-kinds = { path = … }` workspace dependency line (so
  the `tests/` can name it), mirroring how `apianyware-platform-manifest` is wired.

## Done when

- `platforms/macos/tools/app-kinds` crate builds + tests green; workspace member; wired in
  root `Cargo.toml`.
- `schemas/spec-format/app-kind.kdl-schema` authored (authoritative contract, embedded via
  `include_str!`).
- `app-kinds/gui-app/kind.apiw` + `app-kinds/gui-app/docs/{lifecycle,bundle-structure,
  test-obligations}.md` authored; the exemplar loads + validates under the standing test
  guard.
- ADR-0049 (app-kind model) raised, parallel to ADR-0048.
- `CONTEXT.md` gains the app-kind term(s) as they resolve.
- Existing test sweep green; no emit-golden movement.

## Notes

- Do **not** author the other six kinds or touch `app-kinds/README.md` here — those are
  child 2's (`remaining-kinds`), grown after this retires. Keep this session focused.
- `cargo fmt --all` + a standalone `style:` commit if the tree drifts (user steer).
