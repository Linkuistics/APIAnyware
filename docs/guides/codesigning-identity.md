# Local code-signing identity

Sample-app bundles are signed with a persistent self-signed certificate so the
binary CDHash is stable across rebuilds and macOS TCC grants (Accessibility,
Screen Recording, …) survive a rebuild. Create it once per machine.

## Create the certificate

Keychain Access → Certificate Assistant → "Create a Certificate…":

- Name: `APIAnyware Local Signing`
- Identity Type: Self-Signed Root
- Certificate Type: **Code Signing**
- Let me override defaults: not required

Leave it in the **login** keychain.

## Verify

    security find-identity -p codesigning -v

`APIAnyware Local Signing` must appear in the list. The bundler
(`apianyware-macos-bundle-racket`) uses it automatically when present and
falls back to ad-hoc signing (with a warning) when it is absent.

## Verification

Verified 2026-05-21 (Core Pipeline Hardening Task 12).

**CDHash stability.** `Hello Window.app` was bundled twice in succession via
`cargo run --example bundle_app -p apianyware-macos-bundle-racket -- hello-window`.
Both builds produced an identical `CDHash=3015696cbd6e6d4a73f172dbc56f369914fa4183`
with `Authority=APIAnyware Local Signing` — the persistent identity makes the
signed code identity stable across rebuilds.

**TCC-grant survival (in-VM).** In a macOS 26.3 VM (SIP enabled), the bundled
`Hello Window.app` was granted the Accessibility permission via
System Settings → Privacy & Security → Accessibility. The app was then rebuilt
on the host (identical CDHash) and redeployed over the granted copy. The system
TCC database row for `com.linkuistics.HelloWindow` was byte-identical before and
after the rebuild — `kTCCServiceAccessibility`, `auth_value=2` (allowed),
`last_modified` unchanged — so `tccd` never re-evaluated or invalidated the
grant. The stored `csreq` decodes to `identifier "com.linkuistics.HelloWindow"`
plus the `APIAnyware Local Signing` certificate leaf, which the rebuilt binary
still satisfies.

By contrast, re-signing the same app ad-hoc (`codesign --force --sign -`)
yields a different CDHash and a bare `cdhash`-pinned requirement — which is
exactly why ad-hoc-signed bundles lose their TCC grants on every rebuild, and
why the persistent identity is used by default.
