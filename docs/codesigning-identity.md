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
(`apianyware-macos-bundle-racket-oo`) uses it automatically when present and
falls back to ad-hoc signing (with a warning) when it is absent.
