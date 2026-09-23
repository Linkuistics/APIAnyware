"""Regenerate diagram SVGs and compare bytes; --write updates them explicitly.

Sources are .puml or .d2 files below the supplied figures directory, excluding
style/. Each has exactly one sibling .svg; orphan SVGs and unpinned Mermaid
sources fail. PlantUML 1.2026.8 / Graphviz 16.1.0 and D2 0.9.0 are checked only
when used. Rendering uses each source's directory for relative style imports.
The check never writes in the source tree. Renderer errors and missing outputs
fail; no image content is normalised away. Requires Python's standard library.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path


def run(command: list[str], *, cwd: Path, data: bytes | None = None) -> bytes:
    """Run a bounded renderer command, retaining actionable error output."""
    result = subprocess.run(
        command, cwd=cwd, input=data, capture_output=True, timeout=120
    )
    if result.returncode:
        message = (result.stderr + result.stdout).decode(errors="replace")
        raise ValueError(
            f"{' '.join(command)} failed ({result.returncode}):\n{message}"
        )
    return result.stdout + result.stderr if data is None else result.stdout


def check_versions(suffixes: set[str], root: Path) -> None:
    """Reject renderer drift before comparing any generated files."""
    checks: list[tuple[list[str], str]] = []
    if ".puml" in suffixes:
        checks.extend(
            [
                (["plantuml", "-version"], r"PlantUML version 1\.2026\.8\b"),
                (["dot", "-V"], r"graphviz version 16\.1\.0\b"),
            ]
        )
    if ".d2" in suffixes:
        checks.append((["d2", "--version"], r"\bv0\.9\.0\b"))
    for command, pattern in checks:
        output = run(command, cwd=root).decode(errors="replace")
        if not re.search(pattern, output):
            raise ValueError(
                f"Renderer version mismatch: {' '.join(command)}\n{output}"
            )


def check(root: Path, *, write: bool) -> int:
    """Render each discovered source; return one if any committed SVG differs."""
    files = {path for path in root.rglob("*") if path.is_file()}
    unsupported = sorted(path for path in files if path.suffix in {".mmd", ".mermaid"})
    if unsupported:
        raise ValueError(
            f"Pin and add the Mermaid renderer before using: {unsupported}"
        )
    sources = sorted(
        path
        for path in files
        if path.suffix in {".puml", ".d2"}
        and "style" not in path.relative_to(root).parts
    )
    if not sources:
        raise ValueError(f"No diagram sources under {root}")
    expected = {source.with_suffix(".svg") for source in sources}
    if len(expected) != len(sources):
        raise ValueError(
            "Two sources target the same SVG; give each diagram a unique stem"
        )
    orphans = sorted(
        path for path in files if path.suffix == ".svg" and path not in expected
    )
    if orphans:
        raise ValueError(f"SVGs without sources: {orphans}")
    check_versions({source.suffix for source in sources}, root)
    failed = False
    with tempfile.TemporaryDirectory(prefix="ail-diagrams-") as temporary:
        output = Path(temporary) / "rendered.svg"
        for source in sources:
            if source.suffix == ".puml":
                rendered = run(
                    ["plantuml", "-tsvg", "-nometadata", "-pipe"],
                    cwd=source.parent,
                    data=source.read_bytes(),
                )
            else:
                output.unlink(missing_ok=True)
                run(
                    ["d2", "--layout=dagre", "--theme=0", str(source), str(output)],
                    cwd=source.parent,
                )
                rendered = output.read_bytes()
            if b"<svg" not in rendered:
                raise ValueError(f"Renderer did not produce SVG for {source}")
            target = source.with_suffix(".svg")
            if write:
                target.write_bytes(rendered)
                print(f"WROTE {target.relative_to(root)}")
            elif not target.exists() or target.read_bytes() != rendered:
                print(
                    f"STALE {target.relative_to(root)} — run task docs:diagrams:write"
                )
                failed = True
            else:
                print(f"OK {target.relative_to(root)}")
    return int(failed)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("figures", type=Path)
    parser.add_argument("--write", action="store_true", help="replace committed SVGs")
    args = parser.parse_args()
    try:
        return check(args.figures.resolve(), write=args.write)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        print(f"Diagram check failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
