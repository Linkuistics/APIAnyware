# spotlight-importer — host-process constraints

A `spotlight-importer` does not run as its own process — the Spotlight indexing host
(`mdworker`) loads it into *its* address space and calls it. That hosting imposes
constraints on importer code that are platform truth: facts about what the API
context permits, which a target binding must honour. This is the §30
**source-semantic difficulty** territory the platform model carries (node brief D4);
it is *not* a representability status (that is per-target, workstream 6 / §20). It
does not say how any target builds the importer (that is `targets/`, workstream 6).

## The host owns the process

The importer has `host-loaded` entry, a `host-driven` run loop, and
`host-controlled` termination — the host decides when to load it, calls its factory
for a file, and unloads it. Consequences:

- **No entry point of its own.** There is no `main`, no `NSApplicationMain`; the
  importer is a passive plug-in the host drives. It must do all its work inside the
  importer callback it is invoked through, not at some "startup."
- **No run loop, no UI.** `mdworker` is a headless indexing worker. The importer
  must not present UI, must not assume a window-server connection, and must not spin
  its own run loop or block the host — it extracts attributes and returns.
- **Short-lived, per-file.** The host may load the importer, run it for one or a few
  files, and unload it; it must not stash long-lived global state expecting to be
  resident.

## Reentrancy and isolation

- **Reentrancy / thread-safety.** The host may run importers concurrently and may
  reuse a loaded importer across files. Importer code must be reentrant-safe and not
  rely on mutable global state (`may-reenter` in the §30 vocabulary).
- **Sandboxed.** `mdworker` runs in a restrictive sandbox: the importer can read the
  file it was handed but should not assume broad filesystem, network, or IPC access.
  Side effects beyond returning attributes are off-limits.
- **Fork / process assumptions.** The importer must not assume it is the main
  process, must not `fork`, and must not depend on inheriting a particular
  environment — it lives inside whatever worker the host spun up
  (`fork-unsafe` / `ownership-unknown` in the §30 vocabulary).

## Why this is platform truth, not projection

These constraints describe what *macOS* requires of any code loaded as a Spotlight
importer — they hold regardless of which target language wrote the importer. A
target binding (workstream 6) must *satisfy* them; whether a given target *can*
(e.g. a runtime that assumes it owns the process or needs a message pump may be only
`unsafe-only` or `unsupported` here) is the per-target representability question
workstream 6 answers by *consuming* these facts. The platform model only states the
facts.
