# Modaliser Observable State

Files and paths every Modaliser implementation exposes, consumable by
Modaliser-Spec scenarios via direct filesystem reads (`testanyware exec`
+ `cat`/`stat`).

## Paths (XDG-conformant on macOS)

| Path | Purpose | Format | Writer |
|------|---------|--------|--------|
| `~/.config/modaliser/config.scm` | User config; LispKit-style flat-namespace DSL | s-expression | User (Modaliser reads only) |
| `~/.config/modaliser/mru.dat` | Per-selector MRU id lists | Racket `write`/`read` of an immutable hash (string → list) | Modaliser (on every `mru-record!`) |
| `~/.cache/modaliser/events.log` | Structured event log | See `logging-contract.md` | Modaliser (line-buffered, flush-per-line) |
| `~/.config/modaliser/.lock` | Single-instance lock file | Plain text: pid as decimal, trailing newline | Modaliser (on startup; removed on clean shutdown) |

All paths honour `$XDG_CONFIG_HOME` / `$XDG_CACHE_HOME` when set.

## MRU File Format (v1)

v1 format is Racket s-expression: the file contains exactly one datum,
a `write`-serialised immutable hash. Keys are strings (the selector's
`remember` property); values are lists of id values (most recent first,
cap 50 entries).

Example (`(read)` on the file yields):

```racket
#hash(("apps" . ("com.apple.Safari" "com.apple.TextEdit" "com.apple.finder"))
      ("windows" . ("12345:Untitled" "23456:README.md")))
```

**Language-neutral lift deferred** until a second implementation exists.
Rationale: the Modaliser-Racket impl is the only writer today; rewriting
user MRU files for a speculative future reader is premature. When Swift
(or other) impl lands, migrate to JSON (`{ "apps": ["com.apple.Safari", …]
}`) with a one-shot on-startup converter that recognises both formats
and rewrites s-expr → JSON.

## Lock File Format (v1)

Plain text: `<pid>\n`. Contents are sufficient for the single-instance
guard; scenarios use `read-file` + parse to verify only-one-instance
invariants.

Path: `~/.config/modaliser/.lock` (note: under `$XDG_CONFIG_HOME`, not
`$XDG_CACHE_HOME`, matching the Modaliser-Racket impl's `main.rkt`
under `APIAnyware-MacOS/generation/targets/racket-oo/apps/modaliser/`
today).

Cleanup: removed on clean shutdown (menu Quit via `remove-lock-file!`
in `applicationWillTerminate:`); left behind on error-exit (next
startup stales-detects it by `/bin/kill -0 <pid>` and replaces if the
PID is not alive).

## Scenario Access Patterns

Scenarios read observable state through harness verbs:

- `(read-mru)` → parses `mru.dat` into a hash.
- `(read-file path)` → raw bytes; caller parses.
- `(expect-file path #:exists? #t)` / `(expect-file path #:absent? #t)`
  — existence assertion.
- Log assertions go through the log-specific harness verbs
  (`expect-log`, `wait-for-log`, `expect-not-log`), not `read-file`.
