# 040-vm-verify-hello-window

**Kind:** work

## Goal

VM-verify the bundled hello-window `.app` via TestAnyware — the node's done-bar. The
window must **actually draw** (titled window, centred "Hello, macOS!" label, working
app menu); CLI smoke does NOT satisfy this.

## Context

Project rule (memory): never run GUI apps from the CLI — verify in a macOS VM via
TestAnyware (the unified driver). `testanyware` is brew-installed; see
`reference_testanyware_cli` memory for the VM provisioning + chunked-upload +
`open -n` launch recipe, and `knowledge/targets/chez.md` §9 for the no-runtime-on-VM
recipe (the gerbil `.app` is self-contained, so the VM needs no Gerbil install —
that is the whole point of the 030 bundle).

The gerbil bundle is self-contained (static runtime + vendored openssl), so unlike
racket it needs no interpreter on the VM image.

## Done when

- hello-window `.app` uploaded to the VM and launched via `open -n`.
- Screenshot shows the window actually drawn: title "Hello from Gerbil" (or chosen),
  centred 24pt "Hello, macOS!" label, standard app menu with the app name.
- Result recorded under `generation/targets/gerbil/test-results/hello-window/report.md`
  (+ screenshot) and `knowledge/matrix/hello-window/gerbil.md` (per the guide Step 7).
- Sample apps must be visually correct, not merely "a window appeared" (memory:
  budget polish time — label centring, font, menu name all matter).

## Notes

This is the first proof the whole gerbil pipeline produces a working macOS GUI app.
On success the 070 node is complete (ask before retiring; remaining nodes 080/090/100).
