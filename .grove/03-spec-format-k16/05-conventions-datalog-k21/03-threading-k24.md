# threading-k24

**Kind:** work

## Goal

Port the **threading** facet of `heuristics.rs` to the `ConventionProgram` (the crate stood up by
`scaffold-ownership-k22`, extended by `block-invocation-k23`), extending the characterization
harness to gate it.

Reproduce *exactly* (goldens-as-truth) `heuristics::derive_threading` →
`Option<ThreadingConstraint>` (only `MainThreadOnly` is ever derived; `AnyThread` is never emitted
by the heuristic). The three legacy signals, in order (any one fires → `MainThreadOnly`):
- **Class-level `@MainActor`** — any entry in the receiver's `swift_attributes` matches
  `is_main_actor_attribute` (equality after stripping a leading module qualifier, so `MainActor`
  and `_Concurrency.MainActor` match but `Available`/`HasStorage`/`MacroRole` do not). Propagates
  to **every** method on the class (instance *and* class methods).
- **Hardcoded UIKit class list** — `{UIView, UIWindow, UIButton, UILabel, UITextField, UITableView,
  UICollectionView, UIViewController}`. (AppKit classes are deliberately absent — they reach the
  heuristic via `swift_attributes`/`NS_SWIFT_UI_ACTOR`; a hardcoded AppKit list would be dead code.)
- **UI selector list** — exact-match `{display, setNeedsDisplay, setNeedsLayout, layout, drawRect:,
  updateLayer}` on any class.

This is a **class/receiver-level** facet (not per-parameter): the output keys on `(receiver,
selector)` but the value is the method's single threading constraint.

## Context

Design source (do NOT re-grill): node brief `conventions-datalog-k21`, ADR-0047. Same crate
`platforms/macos/tools/conventions`; add rules to `program.rs`, base facts to `fact_loader.rs`,
and a `threading` facet to `readback.rs`, each derived fact stamped `convention:<rule>`.

**New fact-base need vs k22/k23:** the loader must carry the receiver's **Swift attributes** as
facts (`swift_attribute(receiver, attr)` — classes only; the IR records no Swift attributes on
protocols, and `annotate_protocol_method_heuristic` passes an empty slice, so protocol methods get
**no** class-`@MainActor` signal). The selector-list and UIKit-class-list signals are string/
membership predicates ported verbatim; `is_main_actor_attribute` ports verbatim.

**Receiver kind matters here (unlike k22/k23):** the class-`@MainActor` and UIKit-list signals are
class-only; the legacy passes `&[]` swift-attributes for protocols. Since the program keys facts by
bare receiver name, take care a same-named protocol does not inherit a class's `@MainActor` (and
vice-versa). k23's real-IR test showed bare-name keying did not diverge for the block facet — but
the threading facet's class-only signals make a class/protocol name collision more consequential;
verify against real Foundation **and** AppKit IR (AppKit carries the `NS_SWIFT_UI_ACTOR` attributes
this facet keys on, so it is the stronger corpus here). If a collision diverges, scope the
swift-attribute/UIKit signals to class receivers (e.g. a `class_receiver(name)` fact the rule joins).

**Pipeline still UNCHANGED** — `annotate` keeps driving `heuristics.rs`; the flip is the node's
last child (`flip + retire`, not yet grown). So the 71 suites + emit goldens stay green by
construction.

Characterization: add a sibling `threading_equivalence.rs` (parallel to `block_equivalence.rs`)
asserting the new threading facet equals `heuristics::annotate_method_heuristic(...)`/
`annotate_protocol_method_heuristic(...)` `.threading` over synthetic cases (all three signals +
the `_Concurrency.`-qualified `@MainActor` + unrelated-attribute negatives + class-method
propagation + the protocol-gets-no-class-attr case) and the real Foundation/AppKit IR when present.

## Done when

- The threading facet is `ascent` rules in `ConventionProgram`; loader carries `swift_attribute`
  facts for classes.
- Characterization test asserts `threading` equals `heuristics.rs` over synthetic + real IR.
- Derived facts carry `convention:<rule>` stamps; `cargo build`/`test`/`clippy` green; `cargo fmt --all`.

## Notes

Three independent rules, all producing the same `MainThreadOnly` constraint, so there is **no
precedence ladder** (unlike block-invocation) — the facet is a simple disjunction (any signal →
main-thread-only), and the stamp records which rule fired (`convention:main-actor-attribute` /
`convention:uikit-class` / `convention:ui-selector`). Keep ownership (k22), block-invocation (k23)
and this facet decoupled — they are independent outputs on the same method.
