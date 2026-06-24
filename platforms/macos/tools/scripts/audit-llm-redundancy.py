#!/usr/bin/env python3
"""
SUPERSEDED by the pipeline cutover (pipeline-cutover-k20, ADR-0046): the
`_llm-annotations/*.llm.json` side-channel is retired (folded into the per-family
`platforms/macos/api/<Framework>/annotations.apiw` overlay) and the
`analysis/ir/{resolved,annotated,enriched,llm-summaries}` checkpoints no longer
exist. This script targets the OLD layout; reworking the LLM redundancy audit over
`.apiw` is workstream 5 (see TODO.md).

Audit which frameworks' `.llm.json` annotations are now redundant given the
current heuristic coverage. Three categories:

1. **redundant_active**: framework has classes in resolved IR; every
   .llm.json annotation is matched by the heuristic-only output. Re-running
   the subagent is pure cost — its current `.llm.json` can stay as-is.
2. **orphaned**: framework has 0 classes in resolved IR. The `.llm.json`
   exists but never merges into `analysis/ir/annotated/`. Re-annotation is
   futile until the resolved-IR regression is fixed.
3. **net_additive**: framework has classes; LLM contributes ≥1 net new
   annotation. Must keep LLM in the loop.

Prerequisite — produce a heuristic-only annotated checkpoint to compare
against the merged checkpoint:

    mkdir -p /tmp/empty-llm-dir /tmp/heuristic-only-annotated
    ./target/release/apianyware-analyze annotate \\
        --output-dir /tmp/heuristic-only-annotated \\
        --llm-dir /tmp/empty-llm-dir

Then run this script from the repo root.
"""

from __future__ import annotations

import json
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent.parent.parent
RESOLVED = REPO / "analysis/ir/resolved"
LLM_ANNS = REPO / "platforms/macos/api/_llm-annotations"
MERGED = REPO / "analysis/ir/annotated"
HEUR = Path("/tmp/heuristic-only-annotated")


def class_count(framework: str) -> int:
    p = RESOLVED / f"{framework}.json"
    if not p.exists():
        return 0
    return len(json.loads(p.read_text()).get("classes", []))


def load_method_map(path: Path) -> dict:
    if not path.exists():
        return {}
    data = json.loads(path.read_text())
    out = {}
    for cls in data.get("class_annotations") or []:
        for m in cls.get("methods", []):
            out[(cls["class_name"], m["selector"])] = m
    return out


def normalise(a: dict | None) -> dict | None:
    if a is None:
        return None
    return {
        "block_parameters": a.get("block_parameters") or [],
        "parameter_ownership": a.get("parameter_ownership") or [],
        "threading": a.get("threading"),
        "error_pattern": a.get("error_pattern"),
    }


def llm_keys(framework: str) -> set:
    p = LLM_ANNS / f"{framework}.llm.json"
    if not p.exists():
        return set()
    keys = set()
    for cls in json.loads(p.read_text()).get("classes", []):
        for m in cls.get("methods", []):
            keys.add((cls["class_name"], m["selector"]))
    return keys


def main() -> None:
    if not HEUR.exists():
        raise SystemExit(
            f"missing {HEUR} — run the heuristic-only annotate command "
            "from the docstring first"
        )

    redundant_active: list[tuple[str, int]] = []
    orphaned: list[tuple[str, int]] = []
    net_additive: list[tuple[str, int, int]] = []

    for llm_path in sorted(LLM_ANNS.glob("*.llm.json")):
        fw = llm_path.stem.removesuffix(".llm")
        keys = llm_keys(fw)
        if not keys:
            continue
        classes = class_count(fw)
        merged = load_method_map(MERGED / f"{fw}.json")
        heur = load_method_map(HEUR / f"{fw}.json")

        additive = sum(
            1 for k in keys if normalise(merged.get(k)) != normalise(heur.get(k))
        )

        if classes == 0:
            orphaned.append((fw, len(keys)))
        elif additive == 0:
            redundant_active.append((fw, len(keys)))
        else:
            net_additive.append((fw, len(keys), additive))

    print(f"=== redundant_active ({len(redundant_active)} frameworks) ===")
    print("LLM call can be skipped — heuristic now matches every annotation.")
    print()
    total = 0
    for fw, n in sorted(redundant_active, key=lambda x: -x[1]):
        print(f"  {fw:<40} {n:>5} methods")
        total += n
    print(f"  {'TOTAL':<40} {total:>5} methods")
    print()

    print(f"=== orphaned ({len(orphaned)} frameworks) ===")
    print("Resolved IR has 0 classes — LLM annotations never merge.")
    print()
    total = 0
    for fw, n in sorted(orphaned, key=lambda x: -x[1]):
        print(f"  {fw:<40} {n:>5} methods")
        total += n
    print(f"  {'TOTAL':<40} {total:>5} methods")
    print()

    print(f"=== net_additive ({len(net_additive)} frameworks) ===")
    print("LLM still contributes net new annotations — keep in the loop.")
    print()
    for fw, total_methods, add in sorted(net_additive, key=lambda x: -x[2])[:20]:
        print(f"  {fw:<40} {total_methods:>5} methods, +{add} net new")
    if len(net_additive) > 20:
        print(f"  ... and {len(net_additive) - 20} more.")


if __name__ == "__main__":
    main()
