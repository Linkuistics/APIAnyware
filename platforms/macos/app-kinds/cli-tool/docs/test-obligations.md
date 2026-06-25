# cli-tool — test obligations

The `kind.apiw` declares one `test-obligation` reference — `lifecycle`. This is a
**forward pointer**: the obligation *body* (the projection-free, target-independent
expectation declaration) is authored later in
`platforms/macos/tests/app-kinds/cli-tool.apiw` (workstream 4 child 3,
`platform-tests`), and it is *executed* against a built binding by the testing
architecture (workstream 9; ADR-0046 declare-now / execute-later seam, node brief
D3). This file records what the obligation will assert, in prose.

## `lifecycle`

Drives the entry → run-loop → termination model end-to-end against a built binding:

- the binary `exec`s directly and enters `main` with the expected `argv` (no bundle,
  no Launch Services involved);
- it runs to completion — reading any stdin, writing the expected stdout/stderr —
  without entering or requiring an event loop;
- it returns a process exit code, and that status is the contract: `0` on success
  and a documented non-zero code on failure, observed by the caller.

## Boundary

This kind owns only the *declaration* of this obligation — what a `cli-tool` must
satisfy. It owns neither the fixtures-and-runner that execute it (workstream 9) nor
any target-specific hook that builds the binary under test (workstream 6). The
obligation name here is the stable handle those later layers resolve against.
