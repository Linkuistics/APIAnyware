# menu-bar-daemon — the LSUIElement accessory policy

A `menu-bar-daemon` is an `accessory` application: it carries `LSUIElement` in its
Info.plist and presents as a menu-bar-only agent with no Dock tile. This documents
that activation policy as platform truth — not how any target's bundler writes the
key (that is `targets/`, workstream 6).

## `LSUIElement` → accessory

Setting `LSUIElement` to true in `Contents/Info.plist` makes the app a
*UIElement* — `NSApplicationActivationPolicyAccessory`:

- **no Dock tile** — the app does not appear in the Dock;
- **no global menu bar** — it never owns the menu bar at the top of the screen, even
  when one of its (rare) windows is frontmost;
- **does not steal activation** — launching it does not deactivate the user's
  current foreground app;
- **still a full GUI session** — unlike `LSBackgroundOnly`, an accessory app *does*
  connect to the window server and can show its `NSStatusItem`, menus, panels, and
  the occasional window. It is windowserver-connected but Dock-absent.

This is the key that distinguishes a `menu-bar-daemon` from a `gui-app`: same AppKit
process model, but `regular` (Dock + menu bar) versus `accessory` (menu bar status
item only). The kind fixes that `LSUIElement` is *required and true* for this kind;
the bundlers emit it, and a concrete app-spec (`apps/macos/<app>/`, workstream 7)
cannot opt out without becoming a different kind.

## Accessory vs background

`accessory` (`LSUIElement`) is not the same as `background` (`LSBackgroundOnly`):

- **accessory** — a windowserver-connected app with UI (status items, menus,
  panels) but no Dock presence. This kind.
- **background** — `LSBackgroundOnly`: no GUI session at all, no window-server
  connection. That is the daemon territory of `launch-agent` (which, as a bare
  executable, expresses "background" through its launchd context rather than a plist
  key).

A `menu-bar-daemon` needs UI — its whole point is the menu-bar item — so it is
`accessory`, never `background`.
