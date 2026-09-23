# docs-foundation-k4

## Goal

Lay the mechanical ground every document increment builds on. Add explicit,
stable anchors for the rule identifiers. Add the first repeatable
documentation checks as root `Taskfile.yml` tasks. Remove the links that leave
the repository. Change no rule text.

## Context

- Documentation plan, §4 (rule anchors and citation form) and §7 (checks):
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- Audit findings F5 (heading-derived anchors) and F9 (links outside the
  repository): `semantic/docs/research/interface-language-documentation-audit.md`.
- No `Taskfile.yml` exists yet. `task` (go-task) is installed at
  `/opt/homebrew/bin/task`. This is the first Taskfile in the repository, so
  keep it small and wrap the scripts it adds.

## Work

1. **Anchors.** Place an explicit anchor for each of `l1`–`l6`, `c1`–`c8`,
   `a1`–`a5` and `f1`, immediately before the heading it names, in
   `language.md`, `contracts.md` and `profiles.md`. Use a form GitHub renders,
   for example `<a id="c3"></a>`. Keep the headings, so existing
   heading-slug links (such as `conformance.md` → `#f1-synthetic-fixture-catalogue`)
   still resolve. The anchors are the only change to these files.
2. **Out-of-repository links.** Replace the seven links in `baseline.md`
   (lines 11–17 at `1c4b8e7ec3da`) with plain-text paths that name the
   `APIAnyware.add-ocaml-target` workspace, so no link leaves the repository.
   Change nothing else in the table.
3. **`docs:links`.** Check every relative link and `#fragment` in the Markdown
   under `semantic/specification/interface-language/`, plus the plan and the
   audit. A fragment must match an explicit anchor or GitHub's heading slug
   for the target file. Links that leave the repository fail. External URLs
   are listed, not fetched. Code spans and fenced blocks are not links; this
   includes code spans that wrap across lines, which the plan's §4 uses.
4. **`docs:examples`.** Every fenced block has an info string. Every `ail`
   fence is preceded by an example or fragment marker, in the HTML-comment
   syntax you define and document in the plan's §7. An example marker names a
   `.ail` file and either a region (`// region: <name>` … `// endregion` lines
   in the file) or a line range. The fence body must equal that text with the
   marker lines removed. There are no `ail` fences yet, so prove the check
   with a scratch fixture that passes and one that fails.
5. **`docs:check`** runs both. Use only the Python 3 standard library. Keep the
   scripts with their subject (for example a `tools/` directory beside the
   specification) unless the repository already has a better home.

## Done when

- `task docs:check` exits 0 on the current tree. It has been seen to fail
  against a deliberately broken link, a broken anchor, an out-of-repository
  link, an untagged fence and a mismatched example.
- Every rule identifier resolves as `<file>#<lower-case id>`. `git diff` (or
  `jj diff`) of the three normative files shows only added anchor lines.
- The plan's §7 describes the marker syntax and the task names exactly as
  built.

## Notes

This leaf establishes checks; it does not validate AIL. Do not write a parser
or grammar recognizer (root brief, *Technical scope and verification*). No
review leaf follows: the checks are proven by their failing controls.
