# concepts-k98

## Goal

Proof the bounded source/platform correction, verify its preservation
boundaries and close the authorized run.

## Context

- Documentation plan §9.2, *Full-set scope correction*, and the node brief.
- Full-set-reading-k12: the human verdict, reading-extent limit, proxy
  dispositions and explicitly later presentation/syntax aims.
- `semantic/docs/research/interface-language-documentation-audit.md`, Step 2.

## Work

Read the whole bounded document and affected summaries/routes. Verify the
intended source/consumer scope is clear, no Swift privilege or common-C-ABI
claim is implied, and provider support remains honestly bounded. Check Q7 is
still later design work. Inspect retained source-specific examples in context.
Verify the eleven model concepts, canonical wording, grammar and all committed
`.ail` files are preserved. Run `task docs:check` with the Grove measurement
provenance. Update the audit to identify the supplied framing correction,
without claiming a fresh human read or expanding the existing verdict.

## Done when

- The document meets the corrected scope, prose and figure contract, with
  no outstanding in-charter defect or handed-forward item.
- Preserved artifacts match the pre-correction boundary; `task docs:check` passes.
- Audit and brief promotion distinguish the completed correction, the human's
  reported assessment and the work explicitly left for later.

## Notes

This is the final step of the one run authorized at full-set-reading-k12.
Cut no new correction or automatic reading checkpoint. If the exit holds,
close concepts-k6 by the normal retirement cascade. Otherwise preserve residue
and return it to the human. The driver owns the whole-grove finish session.

## Decisions (running log)

D1 — Read the whole bounded document (`README.md`, `explanation/model.md`,
`explanation/choices.md` under `semantic/specification/interface-language/`),
the k95–k97 diff against pre-correction `a1d78472`, the glossary entries the
new prose links (consumer, provider, producer, caller and callee), plan §1,
§8 and §9.2, and the audit's Step 2. The scope section, model opening and
recast dedicated-syntax paragraph and summary row agree with one another,
with README's draft-0.1 limit list (no complete Swift/Rust/Zig/CLR/Wayland
profiles) and with choices' coverage paragraph. No page implies a Swift
privilege, a common C ABI or supplied providers; the source-side preference
stays tentative; Q7 is unchanged and remains later design work. Callers
(programs) and consumers (tools) keep the glossary's distinct meanings.

D2 — Cross-set coherence sweep: enumerated every language/platform name and
"interpreted/dynamically typed/untyped" across all 29 published pages (a
`.NET` pattern needed a fixed-string search; README/model hits were its
positive control). Every retained Swift/Objective-C mention outside the
bounded pages is an explicitly synthetic `objc_like`/`swift_like` path, a
synthetic-conformance disclaimer, a glossary distinction from compiler
conformance, the historical baseline or a named provider limitation — each
consistent with k95 D4. No affected summary needed change.

D3 — Three in-charter fixes, all prose clarity with no change of claim:
README's "Interpretation and typing are separate properties, so…" now states
why (a library in an interpreted language can still state a typed contract);
model's "those ecosystems" reached back across the watch paragraph and now
reads "the ecosystems listed above"; choices' "that common model … the
consumers that use it" had no antecedent and a wrong referent, and now reads
"one common API model … the consumers that use its descriptions". No defect
belongs to an earlier stage's class, so no correction run is cut; none would
be authorized in any case (node brief).

D4 — Audit updated: *Reader evidence and unresolved work* replaced
"scheduled … has not yet landed" with what the correction changed, what it
preserved and that it was checked editorially and by `task docs:check`. It
states the human has not re-read the corrected pages, so it records the
supplied direction's application and does not extend the k12 verdict. The
later conversational presentation and Q7 remain later work.

D5 — Preservation: `jj diff --from a1d78472` shows only the three bounded
pages changed across the repository before this session (their presence is
the instrument's positive control); this session adds only those three pages
and the audit. Canonical rules, grammar, figures, every `.ail` file and the
eleven model sections are therefore byte-identical to the pre-correction
boundary. Measurement: all edits finished first; SHA-256 manifests of 123
subjects (interface-language corpus, docs tools excluding bytecode caches,
Taskfile, plan, audit) matched item by item before and after the run.
`task docs:check` exited 0: links 31 files ok, 29 pages reachable (audit
included via `--also`), examples 31 files ok, 26 SVGs reproduced, coverage
229 candidates, 0 pending, 0 errors. Link-check control: a scratch copy of
the audit with a mutated `#apis-and-languages-in-scope` anchor was reported
as an error, then removed.

D6 — Hand-forward: the node brief holds no `## Handed forward` list; no stage
of this run created one, and this proof leaves none. Retire k98. concepts-k6
has no live leaf and its Done when and full-set exit hold, so it closes;
promote the completed correction to the root brief. No ADR change: framing
only. The root then has no live leaf; finishing belongs to the driver.
