# platforms/macos/app-kinds/ — macOS app-kind definitions

The kinds of macOS application a target can be asked to build (REFACTOR.md §13/§14).
An **app-kind** is **platform process-model truth** — how a program of that kind
starts, runs, and stops; how it presents to the window server; what on-disk container
and Info.plist keys it requires; and which platform-level test obligations it carries.
It is a **distinct entity** with its own authored `.apiw` registry (ADR-0049),
parsed and validated by the `platforms/macos/tools/app-kinds` crate
(`apianyware-app-kinds`). It is *not* a semantic pattern-kind (an API-usage axis,
`semantic/`) and *not* a common app-spec (one concrete app that *names* its kind,
`apps/macos/`, workstream 7).

Each kind is one directory `<kind>/` holding a `kind.apiw` definition plus `docs/`
describing its lifecycle, bundle structure, and test obligations. The kind's stable
identity is its **containing directory** name (every file is `kind.apiw`).

## The seven kinds

| kind | entry | run-loop | termination | activation | bundle |
| --- | --- | --- | --- | --- | --- |
| [`cli-tool`](cli-tool/kind.apiw) | `c-main` | `none` | `return` | `background` | `none` |
| [`gui-app`](gui-app/kind.apiw) | `ns-application-main` | `ns-application` | `ns-application-terminate` | `regular` | `app` (APPL) |
| [`menu-bar-daemon`](menu-bar-daemon/kind.apiw) | `ns-application-main` | `ns-application` | `ns-application-terminate` | `accessory` (`LSUIElement`) | `app` (APPL) |
| [`launch-agent`](launch-agent/kind.apiw) | `c-main` | `cf-run-loop` | `signal` | `background` | `none` |
| [`spotlight-importer`](spotlight-importer/kind.apiw) | `host-loaded` | `host-driven` | `host-controlled` | `hosted` | `mdimporter` (CFPlugIn) |
| [`quicklook-extension`](quicklook-extension/kind.apiw) | `host-loaded` | `host-driven` | `host-controlled` | `hosted` | `appex` (`com.apple.quicklook.preview`) |
| [`finder-sync-extension`](finder-sync-extension/kind.apiw) | `host-loaded` | `host-driven` | `host-controlled` | `hosted` | `appex` (`com.apple.FinderSync`) |

They span the three process shapes a macOS program takes: **standalone** programs the
system launches (`cli-tool`, `gui-app`, `menu-bar-daemon`, `launch-agent`) and
**hosted** plug-ins another process loads (`spotlight-importer` as a legacy
`.mdimporter` CFPlugIn; `quicklook-extension` and `finder-sync-extension` as
NSExtension `.appex` bundles).

## Grammar

A `kind.apiw` is a KDL 2.0 `.apiw` overlay (workstream 2, ADR-0046/0047). The
authoritative, language-neutral contract is
[`schemas/spec-format/app-kind.kdl-schema`](../../../schemas/spec-format/app-kind.kdl-schema);
`apianyware-app-kinds` is one conforming validator of it. The controlled
vocabularies — `entry` / `run-loop` / `termination` / `activation` / `bundle` type —
are flat enums expressed both in the schema and as serde enums in the crate; the
crate's focused validator adds the cross-field semantics the schema cannot state
(`bundle "none"` carries no bundle metadata; an `extension-point` implies a hosted
bundle; `require` / `test-obligation` refs are unique; name = containing directory).

```kdl
app-kind "gui-app" {
    doc "A bundled, windowed Cocoa application."
    process {
        entry "ns-application-main"
        run-loop "ns-application"
        termination "ns-application-terminate"
    }
    activation "regular"
    bundle "app" {
        package-type "APPL"
        principal-class-key "NSPrincipalClass"
        info-plist { require "CFBundleName"; require "CFBundleIdentifier" }
    }
    test-obligation "lifecycle"
    test-obligation "bundle-structure"
}
```

## Projection-free, and what consumes a kind

`kind.apiw` states what a kind **is**, never how any target language builds it (the
domain rule — projection lives in `targets/`, workstream 6). The downstream consumers
read the registry: ws6 target emitters/bundlers project a kind's bundle and process
model to a build (`.app` layout, Info.plist / launchd-plist emission); a ws7 app-spec
(`apps/macos/<app>/`) *names* its kind; and the `test-obligation` references are
forward pointers whose bodies are authored in `platforms/macos/tests/app-kinds/<kind>.apiw`
(workstream 4 child 3) and executed by the testing architecture (workstream 9) — the
declare-now / execute-later seam.
