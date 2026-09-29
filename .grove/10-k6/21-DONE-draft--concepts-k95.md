# concepts-k95

## Goal

Correct the source-language and platform framing of the overview, API model
and syntax rationale, as requested at full-set-reading-k12.

## Context

- Human feedback and dispositions: full-set-reading-k12, D6 onward.
- Structure brief: documentation plan §9.2, *Full-set scope correction*;
  intended source/consumer scope in §1.
- The node brief defines the bounded document and single-run limit.

## Work

1. Read the bounded document: `README.md`, `explanation/model.md` and
   `explanation/choices.md` under `semantic/specification/interface-language/`.
2. Establish the intended .NET, Linux/Wayland/GTK/KDE, Rust and other typed-library
   scope. Distinguish described APIs from consumers; interpreted and dynamically
   typed languages remain consumers. Keep the source-side preference tentative.
   Describe intended breadth without claiming a common C ABI or supplied providers.
3. Revise *A dedicated syntax* and its summary row to assess a source language's
   syntax against the common model without privileging Swift.
4. Enumerate and classify source/platform framing across the published set,
   including summaries and captions. Change directly affected prose; preserve
   accurate history, explicitly synthetic fixture names and provider limitations.
   Do not mechanically remove every Swift mention.
5. Preserve the eleven model concepts, canonical wording, grammar and every
   committed `.ail` file. Q7 remains later syntax exploration, and the later
   conversational rewrite is outside this correction. Verify preservation and
   run the documentation checks.

## Done when

- Overview, model and rationale consistently state the intended source/consumer
  breadth without privileged Swift framing or invented support claims.
- Retained source-specific mentions and changed summaries have a reason.
- Canonical wording, grammar and examples are preserved; `task docs:check` passes.

## Notes

The ordered run k95 → k96 → k97 → k98 is already queued. Add no duplicate tail
or automatic rerun. Hand later-stage defects forward in the node brief;
other scope returns to the human. The rest of the set is accepted for now.

## Decisions (running log)

D1 — The named structure brief is the documentation plan §9.2, supplemented
by §1 and the existing model account's §9.8. It names the reader as a language
designer new to API binding, asks them to judge how notation expresses the
model, orders the choice comparisons, and limits this run to source/platform
framing. Preserve that order and the eleven model concepts. The human's D6–D8
in full-set-reading-k12 settles intended scope; no new language decision is
needed.

D2 — Put the intended API and caller scope before the overview's producer/
consumer workflow and before the model's watch example. Keep AIL-consuming
tools distinct from programs calling the described library. Emphasise typed
source contracts while leaving the preference about interpreted or untyped
sources tentative. Explain that access depends on each API's providers, with
no common-C-ABI or supplied-production-provider implication. Recast the
dedicated-syntax paragraph and its summary row around source-language syntax
generally, assessed against the common model.

D3 — Tier 2 graph status confirmed the project at generation
2026-09-23T09:55:55Z. Coverage reports changed/untracked Markdown metadata,
excluded design/example trees and skipped SVGs. This documentation-only
correction uses direct source reads and text enumeration; it makes no code
structure claim. The initially clean jj change is zslpnlxt, parent a1d78472.
A pre-edit SHA-256 manifest in /tmp covers all published files and docs tools
(excluding bytecode caches), Taskfile, plan and audit for preservation checks.

D4 — Enumerated capitalized candidate tokens across the published Markdown,
grammar, examples and diagram sources/styles, then classified language and
platform names and inspected their occurrences alongside source-language,
provider, caller and consumer framing. This also surfaced OCaml, Java, CF/OS,
ObjC and the C-shaped teaching sketches beyond the initial ecosystem list.
The disposition is:

| Surface | Disposition and reason |
|---|---|
| Overview and model opening | Added intended breadth and roles before examples; the model identifies the C header as a teaching choice. |
| Choices, dedicated-syntax discussion and summary row | Changed together to assess any source language's notation against the common model. |
| Overview/choices scope limits; conformance pressure cases | Retained named ecosystem limitations: intended breadth does not supply real profiles or providers. |
| Baseline mapping | Retained Swift/Objective-C/Apple/OCaml names: these describe the inspected implementation and historical mapping, not AIL's intended universe. |
| Canonical contracts/profiles | Retained exact wording, including separate Swift conformance facts, source-access distinctions and .NET/Rust/Zig/Wayland provider requirements. |
| Packages, profile aids, access reference, object walkthrough and G3 | Retained explicitly synthetic `objc_like`/`swift_like` paths and their no-production-support captions. |
| Domain/contracts/choices explanations, glossary and tutorial | Retained Rust borrow/Copy comparisons and the synthetic C-shaped sketches: they explain familiar-term limits or identify the teaching example. |
| Type/package/declaration reference and remaining routes | Retained provider-dependent source identity and exact configuration wording; no scope correction needed. |
| Figure style vocabulary | Retained Java as a renderer/font-environment fact. Model/context figures describe operations and obligations, without a source-language restriction. |

Only the three bounded published pages need edits. All other published files,
including captions, source diagrams and synthetic packages, remain unchanged.
Q7 remains later syntax exploration. No later-charter defect was identified;
copy-edit/art/proof already stand at k96/k97/k98, so add no pipeline leaf.

D5 — Final validation passed: `task docs:check` checked 31 files for links
and examples, reached all 29 pages, reproduced all 26 SVGs, and reported
229 coverage candidates with zero pending entries and zero errors. The 123
enumerated subjects (published corpus, docs tools excluding bytecode caches,
Taskfile, plan and audit) matched their immediately pre-check SHA-256 values
item by item afterwards; there were no added or removed paths. Compared with
the pre-edit manifest, only the three bounded pages changed. Thus the entire
canonical files, grammar, all `.ail` files and all figure artifacts are
byte-identical. Against parent a1d78472, all eleven model anchors retain their
order and the text from the first concept through the closing map is identical;
Q7 and every embedded AIL block in choices are also identical. The old Swift
comparison and summary were positively found in the baseline before checking
their replacements in the current pages.

D6 — Retire concepts-k95 with its three-page correction and this evidence.
Structure follows the brief's order; technical scope follows the human's
recorded direction and A1/A2/A4/F1's provider boundary. No language or
architecture decision changed, so no ADR update is warranted. No ancestor
closes because k96–k98 remain live under concepts-k6. The next stage reads
these three pages under the existing correction contract; no new leaf or
automatic rerun is added.
