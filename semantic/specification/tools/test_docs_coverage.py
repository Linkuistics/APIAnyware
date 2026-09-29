# pyright: strict
"""Contract tests: extraction blind spots and falsely green dispositions."""

from pathlib import Path

import pytest
from docs_coverage import Disposition, check, extract


@pytest.fixture
def site(tmp_path: Path) -> Path:
    (tmp_path / "examples").mkdir()
    (tmp_path / "reference").mkdir()
    (tmp_path / "explanation").mkdir()
    (tmp_path / "grammar.ebnf").write_text('document = "language", string ;\n')
    (tmp_path / "language.md").write_text(
        '<a id="l1"></a>\nProse `surface("text")` and `values(closed)`.\n'
        "| Clause |\n| plain_call(x) |\n"
        "<!-- reading-aid: example -->\n`teaching_only(x)`\n<!-- /reading-aid -->\n"
    )
    (tmp_path / "contracts.md").write_text("`extent($p, one)` and `contents($p, binary)`.")
    (tmp_path / "profiles.md").write_text(
        '`callback_abi(a, "c")`, `representation(p, "kind")`, `fixture::actor(none)`.'
    )
    (tmp_path / "conformance.md").write_text("| N01 | bad | L1 |\n")
    (tmp_path / "examples" / "sample.ail").write_text(
        "// ignored(x);\nfn sample() -> unit { actual(nested(x)); }\n"
    )
    (tmp_path / "explanation" / "model.md").write_text('<a id="operations"></a>\n')
    (tmp_path / "reference" / "types.md").write_text('<a id="unit"></a>\n')
    return tmp_path


def test_extracts_prose_tables_grammar_examples_rules_and_mutations(site: Path) -> None:
    ids = set(extract(site))
    assert {
        "production:document",
        "keyword:language",
        "head:surface",
        "head:values",
        "head:plain_call",
        "head:extent",
        "head:contents",
        "head:callback_abi",
        "head:representation",
        "head:fixture::actor",
        "head:actual",
        "head:nested",
        "rule:L1",
        "mutation:N01",
    } <= ids
    assert not {"head:teaching_only", "head:ignored", "head:sample"} & ids


def entry(**changes: str) -> Disposition:
    data = dict(
        candidate="type:unit",
        kind="entry",
        target="reference/types.md#unit",
        concept="operations",
        status="ready",
        owner="reference-k16",
        reason="Result type",
    )
    data.update(changes)
    return Disposition(**data)


def test_accepts_existing_entry(site: Path) -> None:
    assert check(site, {"type:unit": ["language.md:1"]}, [entry()], {"operations"}) == ([], [])


@pytest.mark.parametrize(
    ("candidates", "rows", "needle"),
    [
        ({"new": ["language.md:1"]}, [], "unclassified"),
        (
            {"type:unit": ["language.md:1"]},
            [entry(target="reference/types.md#absent")],
            "missing entry",
        ),
        ({}, [entry()], "absent from sources"),
        ({"type:unit": ["language.md:1"]}, [entry(concept="")], "concept"),
        ({"type:unit": ["language.md:1"]}, [entry(concept="typo")], "concept"),
        ({"type:unit": ["language.md:1"]}, [entry(status="pending")], "landed"),
        ({"type:unit": ["language.md:1"]}, [entry(), entry()], "duplicate"),
        ({"type:unit": ["language.md:1"]}, [entry(kind="covered", target="missing")], "covered"),
    ],
)
def test_rejects_false_coverage(
    site: Path,
    candidates: dict[str, list[str]],
    rows: list[Disposition],
    needle: str,
) -> None:
    errors, _ = check(site, candidates, rows, {"operations"})
    assert any(needle in error for error in errors)


def test_pending_names_owner_and_becomes_failure_when_file_lands(site: Path) -> None:
    row = entry(target="reference/future.md#unit", status="pending", owner="reference-k21")
    candidates = {"type:unit": ["language.md:1"]}
    errors, pending = check(site, candidates, [row], {"operations"})
    assert not errors
    assert len(pending) == 1 and "type:unit" in pending[0] and "reference-k21" in pending[0]
    (site / "reference" / "future.md").write_text("# Landed\n")
    errors, _ = check(site, candidates, [row], {"operations"})
    assert any("landed" in error for error in errors)


def test_all_concepts_need_entry_or_reason(site: Path) -> None:
    errors, _ = check(
        site, {"type:unit": ["language.md:1"]}, [entry()], {"operations", "agreement"}
    )
    assert any("agreement" in error for error in errors)


def test_concept_must_exist_in_model_even_when_requested(site: Path) -> None:
    errors, _ = check(
        site,
        {"type:unit": ["language.md:1"]},
        [entry(concept="missing-anchor")],
        {"missing-anchor"},
    )
    assert any("concept" in error for error in errors)


def test_source_changes_cannot_hide_behind_an_old_classification(site: Path) -> None:
    before = extract(site)
    source = site / "contracts.md"
    source.write_text(source.read_text() + "\nNew rule in prose: `new_obligation($p)`.\n")
    after = extract(site)
    assert "head:new_obligation" not in before
    assert "head:new_obligation" in after
    errors, _ = check(site, after, [], set())
    assert any("head:new_obligation: unclassified" in error for error in errors)
