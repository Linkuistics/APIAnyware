#!/usr/bin/env python3
"""docs:examples — check code fences and keep AIL examples in step with files.

Usage: docs_examples.py FILE_OR_DIR ...

In every Markdown file named, or found under a named directory:

- every fenced code block has an info string;
- every `ail` fence is preceded by a marker comment, as its nearest non-blank
  line, and every marker is followed by an `ail` fence;
- an example marker's fence body equals the text it names.

Markers (the documentation plan, §7, is the authority for this syntax):

    <!-- ail-example: examples/buffers.ail -->                 whole file
    <!-- ail-example: examples/buffers.ail region=create -->   a named region
    <!-- ail-example: examples/buffers.ail lines=12-30 -->     lines 12 to 30
    <!-- ail-fragment -->                                      not compared

The path is relative to the Markdown file. A region is the lines between
`// region: <name>` and its matching `// endregion` in the `.ail` file.
In every form, region and endregion lines are removed before comparison.

Exits 1 on any failure. Standard library only.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # keep the tree free of __pycache__
sys.path.insert(0, str(Path(__file__).resolve().parent))
import mdscan  # noqa: E402

EXAMPLE = re.compile(r"^ {0,3}<!--\s*ail-example:\s*(\S+)(?:\s+(region=[\w.-]+|lines=\d+-\d+))?\s*-->\s*$")
FRAGMENT = re.compile(r"^ {0,3}<!--\s*ail-fragment\s*-->\s*$")
ANY_MARKER = re.compile(r"^ {0,3}<!--\s*ail-(?:example|fragment)\b")  # a marker owns its line
REGION = re.compile(r"^\s*//\s*region:\s*(\S+)\s*$")
ENDREGION = re.compile(r"^\s*//\s*endregion\s*$")


def is_marker_line(line: str) -> bool:
    return bool(REGION.match(line) or ENDREGION.match(line))


def extract(path: Path, selector: str | None) -> list[str]:
    """The lines a marker names, with region marker lines removed."""
    lines = mdscan.read_lines(path)
    if lines and lines[-1] == "":
        lines.pop()
    if selector is None:
        chosen = lines
    elif selector.startswith("lines="):
        a, b = (int(x) for x in selector[len("lines="):].split("-"))
        if not 1 <= a <= b <= len(lines):
            raise ValueError(f"lines={a}-{b} is outside 1-{len(lines)}")
        chosen = lines[a - 1 : b]
    else:
        name = selector[len("region="):]
        starts = [i for i, l in enumerate(lines) if (m := REGION.match(l)) and m.group(1) == name]
        if len(starts) != 1:
            raise ValueError(f"region {name!r} {'is not defined' if not starts else 'is defined more than once'}")
        depth, end = 0, None
        for i in range(starts[0] + 1, len(lines)):
            if REGION.match(lines[i]):
                depth += 1
            elif ENDREGION.match(lines[i]):
                if depth == 0:
                    end = i
                    break
                depth -= 1
        if end is None:
            raise ValueError(f"region {name!r} has no matching // endregion")
        chosen = lines[starts[0] + 1 : end]
    return [l for l in chosen if not is_marker_line(l)]


def check(md: Path, root: Path) -> list[str]:
    errors: list[str] = []
    lines = mdscan.read_lines(md)
    rel = md.relative_to(root) if md.is_relative_to(root) else md
    used_markers: set[int] = set()
    for f in mdscan.fences(lines):
        where = f"{rel}:{f.open_line}"
        if not f.info:
            errors.append(f"{where}: fence has no info string")
            continue
        if f.info.split()[0] != "ail":
            continue
        k = f.open_line - 2
        while k >= 0 and not lines[k].strip():
            k -= 1
        prev = lines[k] if k >= 0 else ""
        if FRAGMENT.match(prev):
            used_markers.add(k)
            continue
        m = EXAMPLE.match(prev)
        if not m:
            errors.append(f"{where}: ail fence is not preceded by an ail-example or ail-fragment marker")
            continue
        used_markers.add(k)
        source = (md.parent / m.group(1)).resolve()
        if not source.is_file():
            errors.append(f"{where}: marker names missing file {m.group(1)}")
            continue
        try:
            expected = extract(source, m.group(2))
        except ValueError as e:
            errors.append(f"{where}: {m.group(1)}: {e}")
            continue
        if f.close_line is None:
            errors.append(f"{where}: fence is never closed")
        elif f.body != expected:
            n = next((i for i, (a, b) in enumerate(zip(f.body, expected)) if a != b), min(len(f.body), len(expected)))
            got = f.body[n] if n < len(f.body) else "<end of fence>"
            want = expected[n] if n < len(expected) else "<end of source>"
            errors.append(
                f"{where}: body differs from {m.group(1)} {m.group(2) or '(whole file)'} "
                f"at body line {n + 1}: fence has {got!r}, source has {want!r}"
            )
    fenced = set()
    for f in mdscan.fences(lines):
        end = f.close_line if f.close_line is not None else len(lines)
        fenced.update(range(f.open_line - 1, end))
    for i, line in enumerate(lines):
        if i not in fenced and i not in used_markers and ANY_MARKER.search(line):
            if EXAMPLE.match(line) or FRAGMENT.match(line):
                errors.append(f"{rel}:{i + 1}: marker is not followed by an ail fence")
            else:
                errors.append(f"{rel}:{i + 1}: malformed ail marker")
    return errors


def main() -> int:
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        return 0 if len(sys.argv) >= 2 else 2
    root = Path.cwd().resolve()
    files: list[Path] = []
    for arg in sys.argv[1:]:
        p = Path(arg).resolve()
        files.extend(sorted(p.rglob("*.md")) if p.is_dir() else [p])
    errors = [e for f in files for e in check(f, root)]
    for e in errors:
        print(f"error: {e}", file=sys.stderr)
    if errors:
        print(f"docs:examples: {len(errors)} error(s) in {len(files)} file(s)", file=sys.stderr)
        return 1
    print(f"docs:examples: {len(files)} file(s) ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
