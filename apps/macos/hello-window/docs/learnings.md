# Hello Window — App-Universal Learnings

Discoveries that apply to this app regardless of which target implements it.

- **Termination is Quit-driven, not close-driven** (found during the `spec.md`
  reverse-gen, 2026-06-26). None of the four implementations install an app delegate or
  `applicationShouldTerminateAfterLastWindowClosed:`, and the `gui-app` app-kind's
  termination model is `ns-application-terminate` (Quit → `terminate:`). So on stock
  AppKit, closing the window hides it but the process keeps running. The earlier prose
  claim that "closing the window terminates the app" was an over-claim, corrected in
  `spec.md` §3.8 and flagged there for live-VM confirmation. Applies to every target.
