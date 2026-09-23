#!/usr/bin/env python3
"""docs:links — check relative links, fragments and reachability.

Usage: docs_links.py --root REPO --site DIR [--also FILE ...]

Every Markdown file under --site, plus each --also file, is checked:

- a relative link must name an existing path inside the repository root;
- a `#fragment` must match an explicit `id`/`name` anchor or a GitHub heading
  slug in the target Markdown file (GitHub line anchors `#L10` or `#L10-L20`
  are accepted for other files);
- a link that resolves outside the repository, or is an absolute path, fails;
- external URLs are listed, not fetched.

Code (fences and code spans, including spans wrapped across lines) and HTML
comments are not links. Finally, every Markdown page under --site must be
reachable from --site/README.md by following relative links between pages
under --site, so an orphaned page fails.

Exits 1 on any failure. Standard library only.
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import deque
from pathlib import Path
from urllib.parse import unquote

sys.dont_write_bytecode = True  # keep the tree free of __pycache__
sys.path.insert(0, str(Path(__file__).resolve().parent))
import mdscan  # noqa: E402

INLINE = re.compile(r"\]\(\s*(<[^>\n]*>|[^\s()<>]*(?:\([^\s()]*\)[^\s()<>]*)*)(?:\s+(?:\"[^\"]*\"|'[^']*'|\([^)]*\)))?\s*\)")
REFDEF = re.compile(r"^ {0,3}\[[^\]\n]+\]:[ \t]*(<[^>\n]*>|\S+)", re.M)
HTML_ATTR = re.compile(r"""\b(?:href|src)\s*=\s*(?:"([^"]*)"|'([^']*)')""")
AUTOLINK = re.compile(r"<([A-Za-z][A-Za-z0-9+.-]{1,31}:[^\s<>]*)>")
BARE_URL = re.compile(r"(?<![<(\w])(?:https?://|www\.)[^\s<>)\]]+")
SCHEME = re.compile(r"^[A-Za-z][A-Za-z0-9+.-]*:")
LINE_ANCHOR = re.compile(r"^L\d+(?:-L\d+)?$")


def links(path: Path) -> list[tuple[int, str]]:
    """(line, destination) for every link outside code and comments."""
    text = mdscan.mask_code_and_comments(mdscan.read_lines(path))
    found: list[tuple[int, int, str]] = []
    for rx in (INLINE, REFDEF):
        for m in rx.finditer(text):
            found.append((m.start(1), m.end(1), m.group(1).strip("<>")))
    for m in HTML_ATTR.finditer(text):
        g = 1 if m.group(1) is not None else 2
        found.append((m.start(g), m.end(g), m.group(g)))
    for m in AUTOLINK.finditer(text):
        found.append((m.start(1), m.end(1), m.group(1)))
    taken = [(a, b) for a, b, _ in found]
    for m in BARE_URL.finditer(text):
        if not any(a <= m.start() < b for a, b in taken):
            found.append((m.start(), m.end(), m.group(0).rstrip(".,;:")))
    return sorted((text.count("\n", 0, a) + 1, dest) for a, _, dest in found)


class Checker:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()
        self.errors: list[str] = []
        self.external: set[str] = set()
        self._anchors: dict[Path, set[str]] = {}

    def rel(self, p: Path) -> str:
        try:
            return str(p.relative_to(self.root))
        except ValueError:
            return str(p)

    def anchors(self, p: Path) -> set[str]:
        if p not in self._anchors:
            self._anchors[p] = mdscan.anchors(p)
        return self._anchors[p]

    def check_file(self, src: Path) -> list[Path]:
        """Check one file's links; return the Markdown pages it links to."""
        targets: list[Path] = []
        for line, dest in links(src):
            where = f"{self.rel(src)}:{line}: {dest}"
            if SCHEME.match(dest) or dest.startswith("www."):
                self.external.add(dest)
                continue
            path_part, _, fragment = dest.partition("#")
            path_part = unquote(path_part)
            if path_part.startswith("/"):
                self.errors.append(f"{where}: absolute path; use a relative link")
                continue
            target = (src.parent / path_part).resolve() if path_part else src.resolve()
            if not target.is_relative_to(self.root):
                self.errors.append(f"{where}: leaves the repository")
                continue
            if not target.exists():
                self.errors.append(f"{where}: no such file {self.rel(target)}")
                continue
            if target.suffix == ".md" and target.is_file():
                targets.append(target)
            if not fragment:
                continue
            fragment = unquote(fragment)
            if target.suffix == ".md" and target.is_file():
                if fragment not in self.anchors(target):
                    self.errors.append(f"{where}: no anchor #{fragment} in {self.rel(target)}")
            elif not (target.is_file() and LINE_ANCHOR.match(fragment)):
                self.errors.append(f"{where}: fragment #{fragment} cannot be checked in {self.rel(target)}")
        return targets


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--root", type=Path, required=True, help="repository root")
    ap.add_argument("--site", type=Path, required=True, help="directory whose README.md is the landing page")
    ap.add_argument("--also", type=Path, nargs="*", default=[], help="further Markdown files to check")
    args = ap.parse_args()

    checker = Checker(args.root)
    site = args.site.resolve()
    pages = sorted(site.rglob("*.md"))
    graph: dict[Path, list[Path]] = {}
    for f in pages + [p.resolve() for p in args.also]:
        graph[f] = checker.check_file(f)

    landing = site / "README.md"
    seen = {landing}
    queue = deque([landing])
    while queue:
        for t in graph.get(queue.popleft(), []):
            if t.is_relative_to(site) and t not in seen:
                seen.add(t)
                queue.append(t)
    for p in pages:
        if p not in seen:
            checker.errors.append(f"{checker.rel(p)}: not reachable from {checker.rel(landing)}")

    for url in sorted(checker.external):
        print(f"external (not fetched): {url}")
    for e in checker.errors:
        print(f"error: {e}", file=sys.stderr)
    checked = len(graph)
    if checker.errors:
        print(f"docs:links: {len(checker.errors)} error(s) in {checked} file(s)", file=sys.stderr)
        return 1
    print(f"docs:links: {checked} file(s) ok, {len(pages)} page(s) reachable")
    return 0


if __name__ == "__main__":
    sys.exit(main())
