# Modaliser Logging Contract

Every Modaliser implementation MUST emit a structured event log
consumed by Modaliser-Spec scenarios.

## File Location

- **Default path:** `$XDG_CACHE_HOME/modaliser/events.log`
  (fallback `~/.cache/modaliser/events.log`).
- **Override:** env var `MODALISER_EVENTS_LOG` takes precedence.
- **Lifecycle:** truncated on impl startup (single-writer; lock file
  guarantees no second process appends concurrently). Parent directory
  created if missing.
- **Buffering:** line-buffered; flushed after every record.

## Line Format

```
[<module>] <event-name> <key1>=<value1> <key2>=<value2>\n
```

- `<module>` and `<event-name>` are bare lowercase identifiers
  (`[a-z][a-z0-9_-]*`).
- Key-value pairs, space-separated; order is stable per event (listed
  below).
- Unknown keys MAY be added at the end of a line without breaking
  scenarios — scenarios match with anchored prefixes.

### Value encoding

| Type | Encoding | Example |
|------|----------|---------|
| boolean | bare `true` / `false` | `enabled=true` |
| exact integer | bare decimal | `pid=1234` |
| rational | decimal (may include `.`) | `delay=0.35` |
| safe symbol | bare (pattern `[A-Za-z0-9_.:/+*?<>=!@#$%^&-]+`) | `reason=menu` |
| string | double-quoted, escaped (`\\`, `\"`, `\n`, `\r`, `\t`) | `title="Untitled — TextEdit"` |
| path | string-encoded | `path="/Users/x/.config/modaliser/config.scm"` |

## Required Events (v1)

Stability: events below are **stable**; new events may be introduced
additively. Renaming or removing an event is a breaking change.

### `[lifecycle]`

| Event | Keys | When |
|-------|------|------|
| `startup` | (none) | After `events-init!` succeeds; before any other events |
| `shutdown` | `reason` = `menu` \| `signal` \| `error`; if `error`, also `message="..."` | Any terminal path |

### `[config]`

| Event | Keys | When |
|-------|------|------|
| `load` | `path="..."` | Just before evaluating `config.scm` |
| `loaded` | (none) | Config evaluation returned successfully |
| `missing` | `path="..."` | Config file not found |
| `error` | `message="..."` | Config evaluation raised |

### `[modal]`

| Event | Keys | When |
|-------|------|------|
| `enter` | `tree=<name>` | Leader key pressed; modal entered |
| `group` | `key=<key>` | Group-node key selected in modal |
| `exit` | `reason` = `user` \| `watchdog` \| `focus-loss` | Modal dismissed |

### `[chooser]`

| Event | Keys | When |
|-------|------|------|
| `open` | `selector="<label>"` | Chooser panel shown |
| `push` | `query="<text>"` `results=<n>` | Query entered; results recomputed |
| `close` | `reason` = `select` \| `cancel` \| `secondary-action` | Chooser dismissed |

### `[launch]`

| Event | Keys | When |
|-------|------|------|
| `bundle` | `id="<bundle-id>"` | App launched by bundle id |
| `app` | `name="<display-name>"` | App launched by display name |
| `path` | `path="<path>"` | App launched by filesystem path |
| `url` | `url="<url>"` | Non-app URL opened |

### `[window]`

| Event | Keys | When |
|-------|------|------|
| `focus` | `pid=<n>` `title="<text>"` | Window focused (explicit or implicit via `activate-app`) |
| `move` | `x=<n>` `y=<n>` `w=<n>` `h=<n>` | Window position/size changed via Modaliser |

### `[mru]`

| Event | Keys | When |
|-------|------|------|
| `record` | `key=<remember-key>` `id="<id>"` | Item pushed to MRU front |

## Emitter Implementation Notes (non-contractual)

Modaliser-Racket (the Racket-OO impl, at
`APIAnyware-MacOS/generation/targets/racket-oo/apps/modaliser/`)
implements the contract via `lib/events.rkt` in that directory. Other
implementations MAY use any mechanism; only on-disk output is observable
by scenarios.

- Emission is a no-op before `events-init!` is called — prevents unit
  tests from polluting the log.
- Filesystem errors post-init are swallowed silently (don't crash the
  app just because disk is full).
- Argument-shape errors (odd number of key/value args) ARE raised — they
  indicate a programming bug.
