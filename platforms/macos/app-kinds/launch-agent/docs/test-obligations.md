# launch-agent — test obligations

The `kind.apiw` declares two `test-obligation` references — `lifecycle` and
`background-activation`. These are **forward pointers**: the obligation *bodies* (the
projection-free, target-independent expectation declarations) are authored later in
`platforms/macos/tests/app-kinds/launch-agent.apiw` (workstream 4 child 3,
`platform-tests`), and they are *executed* against a built binding by the testing
architecture (workstream 9; ADR-0046 declare-now / execute-later seam, node brief
D3). This file records what each obligation will assert, in prose.

## `lifecycle`

Drives the entry → run-loop → termination model end-to-end against a built binding,
under launchd management:

- launchd loads the job and the agent starts, entering `main` with the configured
  `ProgramArguments`;
- the agent enters and runs its `cf-run-loop`, servicing the source it was loaded
  for (without busy-waiting and without an AppKit / window-server connection);
- on unload launchd sends SIGTERM, and the agent runs its signal handler — stopping
  the run loop, releasing resources, and exiting cleanly **before** launchd escalates
  to SIGKILL.

## `background-activation`

Checks the agent has no GUI session:

- it shows no Dock tile and owns no menu bar;
- it makes no window-server connection (it is a true background process, not an
  accessory);
- it runs in the user's launchd agent context, observable via `launchctl`.

## Boundary

This kind owns only the *declaration* of these obligations — what a `launch-agent`
must satisfy. It owns neither the fixtures-and-runner that execute them (workstream
9) nor any target-specific hook that builds the binary under test (workstream 6).
The launchd *job plist* that drives the agent is app-spec material (workstream 7;
see `launchd.md`). The obligation names here are the stable handles those later
layers resolve against.
