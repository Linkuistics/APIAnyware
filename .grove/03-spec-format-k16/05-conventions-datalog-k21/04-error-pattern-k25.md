# error-pattern-k25

**Kind:** work

## Goal

Port the **error-pattern** facet of `heuristics.rs` to the `ConventionProgram` (the crate stood up
by `scaffold-ownership-k22`, extended by `block-invocation-k23` and `threading-k24`), extending the
characterization harness to gate it. This is the **fourth and last facet**; once it lands, only the
`flip + retire` child remains.

Reproduce *exactly* (goldens-as-truth) `heuristics::derive_error_pattern` → `Option<ErrorPattern>`.
Only `ErrorOutParam` is ever derived by the heuristic (`ThrowsException` / `NilOnFailure` are never
emitted). The single signal:

- **Trailing `NSError**` out-param** — the method's **last** parameter is named `error` or ends with
  `error` (case-insensitive: `name.to_lowercase() == "error" || …ends_with("error")`) **and** its
  declared type is `TypeRefKind::Pointer`. Both conditions on the last param → `ErrorOutParam`.

This is a **per-method** facet (one constraint per method, like threading), keyed on `(receiver,
selector)`; it is **receiver-kind-agnostic** — it consults only the method's last parameter, so
classes and protocols classify identically and there is **no class/protocol collision concern**
(unlike threading-k24).

## Context

Design source (do NOT re-grill): node brief `conventions-datalog-k21`, ADR-0047. Same crate
`platforms/macos/tools/conventions`; add a rule to `program.rs`, base facts to `fact_loader.rs`, and
an `error_pattern` facet to `readback.rs`, each derived fact stamped `convention:<rule>`
(`convention:error-out-param`).

**New fact-base need vs k22/k23/k24:** the existing `param(receiver, selector, index, name, is_block)`
relation carries the parameter name but **not** whether its type is a `Pointer`. The error signal
needs pointer-ness on the last param. Options (pick the cleaner at impl): extend `param` with an
`is_pointer` column (touches the ownership/block facets' fact shape — re-run their tests), or add a
narrow `pointer_param(receiver, selector, index)` fact loaded alongside `param`. The
**last-parameter** gate reuses `param_count` (`index + 1 == total`), exactly as the block
last-param rule does. The name predicate (`error` / `…error`, case-insensitive) ports verbatim.

**Pipeline still UNCHANGED** — `annotate` keeps driving `heuristics.rs`; the flip is the node's last
child (`flip + retire`, grown when this leaf retires). So the 71 suites + emit goldens stay green by
construction.

Characterization: add a sibling `error_pattern_equivalence.rs` (parallel to
`threading_equivalence.rs`) asserting the new error-pattern facet equals
`heuristics::annotate_method_heuristic(...)`/`annotate_protocol_method_heuristic(...)`
`.error_pattern` over synthetic cases (exact-`error` name + `…Error`/`…error` suffix + pointer-type
gate + the non-pointer-named-error negative + the non-last-param-named-error negative + a non-error
last-param negative) and the real Foundation/AppKit IR when present (both now regenerated locally;
AppKit enrich reported `error_methods=72`).

## Done when

- The error-pattern facet is `ascent` rules in `ConventionProgram`; the loader carries the last
  param's pointer-ness (whichever carriage chosen).
- Characterization test asserts `error_pattern` equals `heuristics.rs` over synthetic + real IR.
- Derived facts carry `convention:error-out-param` stamps; `cargo build`/`test`/`clippy` green;
  `cargo fmt --all`.

## Notes

A single rule, one constraint (`ErrorOutParam`) — even simpler than threading (no disjunction, no
precedence). Keep ownership (k22), block-invocation (k23), threading (k24) and this facet decoupled
— they are independent outputs on the same method. After this leaf retires, grow the **`flip +
retire`** child: wire `annotate` to the `ConventionProgram`, retire `heuristics.rs`, finalize the
per-fact `convention:<rule>` stamping + disagreement/precedence audit (ADR-0046 §4), and prove
full-pipeline + emit-goldens equivalence (the node's done-bar).
