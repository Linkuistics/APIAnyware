#!/usr/bin/env python3
# pyright: strict
"""Check a lexical AIL reference inventory against reviewed TSV dispositions.

Candidates: EBNF productions and word terminals; name( tokens throughout the
three normative Markdown sources (including prose/tables); core-type-table
names; call-like tokens in top-level conformance examples; rule and mutation IDs.
Reading aids are excluded from Markdown; comments, quoted AIL strings and
callable declaration heads are excluded from example sources. Nested value
constructors are candidates too: classification is human.
Source locations accompany every candidate. This does not parse or validate AIL.

TSV columns are Disposition's fields. `entry` owns a file#explicit-anchor and
one model concept. `covered` names another candidate classified as an entry.
`non-vocabulary` records why a token needs no entry. Pending entries require an
owner and an absent file; landing the file requires changing them to ready.
Model concepts come from the model page's explicit anchors. All need an entry.
The check verifies existence, not the technical truth of an entry or judgement.

Standard library only. Exit 0: accounted for (pending printed); 1: coverage or
input error; 2: command usage error. --require-complete also rejects pending.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

sys.dont_write_bytecode = True
import mdscan  # noqa: E402

NAME = r"[A-Za-z_][A-Za-z_0-9]*(?:::[A-Za-z_][A-Za-z_0-9]*)*"
HEAD = re.compile(rf"\b({NAME})\s*\(")
AID = re.compile(r"<!-- reading-aid:.*?<!-- /reading-aid -->", re.S)
STRINGS_COMMENTS = re.compile(r'"(?:\\.|[^"\\])*"|/\*.*?\*/|//[^\n]*', re.S)


@dataclass(frozen=True)
class Disposition:
    candidate: str
    kind: str
    target: str
    concept: str
    status: str
    owner: str
    reason: str


def blank(match: re.Match[str]) -> str:
    return re.sub(r"[^\n]", " ", match.group())


def extract(site: Path) -> dict[str, list[str]]:
    """Enumerate lexical candidates with original source locations."""
    found: dict[str, list[str]] = {}

    def add(kind: str, name: str, path: Path, text: str, offset: int) -> None:
        location = f"{path.relative_to(site)}:{text.count(chr(10), 0, offset) + 1}"
        places = found.setdefault(f"{kind}:{name}", [])
        if location not in places:
            places.append(location)

    path = site / "grammar.ebnf"
    grammar = re.sub(r"\(\*.*?\*\)", blank, path.read_text(), flags=re.S)
    for match in re.finditer(r"(?m)^([a-z_]+)\s*=", grammar):
        add("production", match[1], path, grammar, match.start())
    for match in re.finditer(r'"([A-Za-z_][A-Za-z_0-9]*)"', grammar):
        add("keyword", match[1], path, grammar, match.start())
    for filename in ("language.md", "contracts.md", "profiles.md"):
        path = site / filename
        text = AID.sub(blank, path.read_text())
        for match in re.finditer(r"<a id=\"([lcaf][0-9]+)\"></a>", text):
            add("rule", match[1].upper(), path, text, match.start())
        # Search all prose, code spans and cells; classification removes false positives.
        for match in HEAD.finditer(text):
            add("head", match[1], path, text, match.start())
        if filename == "language.md":
            table = re.search(r"\| Type \| Meaning \|.*?(?=\n\n)", text, re.S)
            if table:
                for span in re.finditer(r"`([^`]+)`", table.group()):
                    for match in re.finditer(NAME, span[1]):
                        add("type", match.group(), path, text, table.start() + span.start())
    for path in sorted((site / "examples").glob("*.ail")):
        text = STRINGS_COMMENTS.sub(blank, path.read_text())
        for match in HEAD.finditer(text):
            if re.search(r"\b(?:fn|callback)\s+$", text[: match.start()]):
                continue
            add("head", match[1], path, text, match.start())
    path = site / "conformance.md"
    text = path.read_text()
    for match in re.finditer(r"(?m)^\|\s*(N[0-9]+)\s*\|", text):
        add("mutation", match[1], path, text, match.start())
    return dict(sorted(found.items()))


def check(
    site: Path,
    candidates: dict[str, list[str]],
    rows: list[Disposition],
    concepts: set[str],
) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    pending: list[str] = []
    dispositions: dict[str, Disposition] = {}
    represented: set[str] = set()
    model_anchors = mdscan.anchors(site / "explanation/model.md")
    for row in rows:
        key = row.candidate
        if key in dispositions:
            errors.append(f"{key}: duplicate disposition; keep one classification")
        dispositions[key] = row
        if key not in candidates:
            errors.append(f"{key}: absent from sources; remove or correct disposition")
        if not row.reason:
            errors.append(f"{key}: add the classification reason")
        if row.kind == "entry":
            if row.concept not in concepts or row.concept not in model_anchors:
                errors.append(f"{key}: missing/unknown model concept {row.concept!r}")
            else:
                represented.add(row.concept)
            filename, sep, anchor = row.target.partition("#")
            path = (site / filename).resolve()
            if not path.is_relative_to(site.resolve()) or not sep or not anchor:
                errors.append(f"{key}: entry target needs an in-site file#anchor")
                continue
            if row.status == "pending":
                if path.exists():
                    errors.append(f"{key}: pending entry in landed file {filename}; finish entry")
                elif not row.owner:
                    errors.append(f"{key}: pending entry needs an owner")
                else:
                    pending.append(f"{key} -> {row.target} ({row.owner})")
            elif row.status != "ready":
                errors.append(f"{key}: entry status must be ready or pending")
            elif not path.is_file() or anchor not in mdscan.anchors(path):
                errors.append(f"{key}: missing entry {row.target}; add its anchor and content")
        elif row.kind not in {"covered", "non-vocabulary"}:
            errors.append(f"{key}: unknown disposition kind {row.kind!r}")
    for key, locations in candidates.items():
        if key not in dispositions:
            errors.append(f"{key}: unclassified at {', '.join(locations)}; add a disposition")
    for row in rows:
        if row.kind == "covered":
            target = dispositions.get(row.target)
            if target is None or target.kind != "entry":
                errors.append(f"{row.candidate}: covered target {row.target!r} needs an entry")
    for concept in sorted(concepts - represented):
        errors.append(
            f"model concept {concept}: no entry; record its structural coverage as an entry"
        )
    return errors, pending


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Examples:\n  task docs:coverage\n  python3 docs_coverage.py SITE --inventory\n"
        "  python3 docs_coverage.py SITE --require-complete --json",
    )
    parser.add_argument("site", type=Path, help="interface-language directory")
    parser.add_argument(
        "--dispositions", type=Path, default=Path(__file__).with_name("reference-dispositions.tsv")
    )
    parser.add_argument(
        "--inventory", action="store_true", help="emit candidate/location JSON only"
    )
    parser.add_argument(
        "--require-complete", action="store_true", help="fail on future entries too"
    )
    parser.add_argument(
        "--json", action="store_true", help="emit candidates, dispositions, errors, pending"
    )
    args = parser.parse_args()
    try:
        candidates = extract(args.site)
        if args.inventory:
            print(json.dumps(candidates, indent=2))
            return 0
        with args.dispositions.open(newline="") as stream:
            rows = [Disposition(**row) for row in csv.DictReader(stream, delimiter="\t")]
        model = (args.site / "explanation/model.md").read_text()
        concepts = set(re.findall(r'<a id="([^"]+)"></a>', model))
        errors, pending = check(args.site, candidates, rows, concepts)
        if args.require_complete and pending:
            errors.append("pending entries remain; finish their owning drafts")
    except (OSError, ValueError, TypeError, csv.Error) as error:
        if args.json:
            print(json.dumps({"errors": [str(error)], "pending": []}))
        else:
            print(f"coverage input error: {error}", file=sys.stderr)
        return 1
    if args.json:
        print(
            json.dumps(
                {
                    "candidates": candidates,
                    "dispositions": [asdict(r) for r in rows],
                    "errors": errors,
                    "pending": pending,
                },
                indent=2,
            )
        )
    else:
        for error in errors:
            print(f"ERROR {error}", file=sys.stderr)
        for item in pending:
            print(f"PENDING {item}")
        print(
            f"Coverage: {len(candidates)} candidates; {len(pending)} pending; {len(errors)} errors."
        )
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
