"""Minimal Markdown scanning shared by the documentation checks.

Standard library only. This is not a Markdown renderer: it finds fenced code
blocks, masks code (fences and code spans) and HTML comments so that the text
left over can be searched for links, and computes GitHub heading slugs. It
follows CommonMark closely enough for the documentation set, and no further.
"""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass
from pathlib import Path

FENCE_OPEN = re.compile(r"^( {0,3})(`{3,}|~{3,})(.*)$")
ATX_HEADING = re.compile(r"^ {0,3}(#{1,6})(?:[ \t]+(.*?))?(?:[ \t]+#+)?[ \t]*$")
SETEXT_UNDERLINE = re.compile(r"^ {0,3}(=+|-+)[ \t]*$")
EXPLICIT_ID = re.compile(r"""<[A-Za-z][^>]*?\b(?:id|name)\s*=\s*(?:"([^"]*)"|'([^']*)')""")


@dataclass
class Fence:
    """One fenced code block. Line numbers are 1-based."""

    open_line: int
    close_line: int | None  # None when the fence runs to end of file
    indent: int
    info: str
    body: list[str]


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").split("\n")


def fences(lines: list[str]) -> list[Fence]:
    """Every fenced code block, with its body de-indented as CommonMark does."""
    found: list[Fence] = []
    i = 0
    while i < len(lines):
        m = FENCE_OPEN.match(lines[i])
        if not m or (m.group(2)[0] == "`" and "`" in m.group(3)):
            i += 1
            continue
        indent, marker, info = len(m.group(1)), m.group(2), m.group(3).strip()
        close = re.compile(r"^ {0,3}" + re.escape(marker[0]) + "{" + str(len(marker)) + r",}[ \t]*$")
        body: list[str] = []
        j = i + 1
        while j < len(lines) and not close.match(lines[j]):
            line = lines[j]
            strip = min(indent, len(line) - len(line.lstrip(" ")))
            body.append(line[strip:])
            j += 1
        closed = j < len(lines)
        found.append(Fence(i + 1, j + 1 if closed else None, indent, info, body))
        i = j + 1
    return found


def mask_code_and_comments(lines: list[str]) -> str:
    """The document with fences, code spans and HTML comments blanked.

    Blanked characters become spaces and newlines are kept, so offsets still
    map to the original line numbers. Code spans may wrap across lines inside
    one paragraph; a blank line ends the search for a closing backtick run.
    """
    out = list(lines)
    for f in fences(lines):
        end = f.close_line if f.close_line is not None else len(lines)
        for n in range(f.open_line - 1, end):
            out[n] = ""
    text = "\n".join(out)
    chars = list(text)

    def blank(a: int, b: int) -> None:
        for k in range(a, b):
            if chars[k] != "\n":
                chars[k] = " "

    for m in re.finditer(r"<!--.*?-->", text, re.S):
        blank(m.start(), m.end())
    text = "".join(chars)

    i = 0
    while i < len(text):
        if text[i] == "\\":
            i += 2
            continue
        if text[i] != "`":
            i += 1
            continue
        run = re.match(r"`+", text[i:]).group(0)
        n = len(run)
        j = i + n
        end = None
        while j < len(text):
            if text.startswith("\n", j) and re.match(r"\n[ \t]*\n", text[j:]):
                break
            if text[j] == "`":
                other = re.match(r"`+", text[j:]).group(0)
                if len(other) == n:
                    end = j + n
                    break
                j += len(other)
                continue
            j += 1
        if end is None:
            i += n  # an unmatched run is literal text
            continue
        blank(i, end)
        i = end
    return "".join(chars)


def _heading_text(raw: str) -> str:
    """Heading source reduced to the text GitHub slugs."""
    text = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", raw)  # links and images
    text = re.sub(r"<[^>]+>", "", text)  # inline HTML
    text = text.replace("`", "")
    text = text.replace("*", "")  # emphasis; `_` emphasis is not used in headings here
    return text.strip()


def github_slug(text: str) -> str:
    """The slug GitHub gives a heading (github-slugger, without de-duplication)."""
    text = text.lower()
    kept = []
    for ch in text:
        cat = unicodedata.category(ch)
        if ch in " -_" or cat[0] in "LN" or cat in ("Mn", "Mc"):
            kept.append(ch)
    return "".join(kept).replace(" ", "-")


def anchors(path: Path) -> set[str]:
    """Every fragment a link may name in a Markdown file.

    That is the explicit `id`/`name` attributes outside code, and the
    GitHub heading slugs, de-duplicated with -1, -2, … as GitHub does.
    """
    lines = read_lines(path)
    masked = mask_code_and_comments(lines).split("\n")
    result: set[str] = set()
    for line in masked:
        for m in EXPLICIT_ID.finditer(line):
            result.add(m.group(1) if m.group(1) is not None else m.group(2))
    seen: dict[str, int] = {}
    for n, line in enumerate(masked):
        text = None
        m = ATX_HEADING.match(line)
        if m and line.strip():
            text = m.group(2) or ""
        elif (
            n + 1 < len(masked)
            and SETEXT_UNDERLINE.match(masked[n + 1])
            and line.strip()
            and not line.startswith(("    ", "\t"))
            and not line.lstrip().startswith(("|", ">", "-", "*", "+"))
            and (n == 0 or not masked[n - 1].strip())
        ):
            text = line
        if text is None:
            continue
        slug = github_slug(_heading_text(text))
        count = seen.get(slug, 0)
        seen[slug] = count + 1
        result.add(slug if count == 0 else f"{slug}-{count}")
    return result
