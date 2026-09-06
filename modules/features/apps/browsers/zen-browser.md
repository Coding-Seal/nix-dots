# Zen Browser — flake capabilities

`inputs.zen-browser` is `github:0xc000022070/zen-browser-flake` (locked rev
`8d0d0f036b0104699e60ec0d549d36a24d6e8637` at time of writing) — a
purpose-built Zen module, not a generic Firefox wrapper. Its `hm-module/` and
`examples/` cover far more of Zen's feature surface than the options
currently used in `zen-browser.nix`.

## Declarative (real options in this flake)

| Area | Option | Notes |
|---|---|---|
| Extensions | `profiles.<name>.extensions.packages` | In use — NUR rycee addons |
| Prefs (about:config) | `profiles.<name>.settings` | In use |
| Enterprise policies | `policies.*` | In use — `PasswordManagerEnabled = false` removes Firefox's own password manager outright (Bitwarden is the only one), instead of hand-picking `signon.*` prefs |
| Search engines | `profiles.<name>.search` | In use |
| Mods (zen-browser.app/mods) | `profiles.<name>.mods = [ "<uuid>" ... ]` | In use — Ghost Tabs, Better CtrlTab Panel. Installs by UUID at activation — no in-browser UI step needed |
| Spaces (workspaces) | `profiles.<name>.spaces.<name> = { id, icon, theme, position }` + `spacesForce` | Not in use. Full gradient themes, ordering |
| Pinned tabs / folders | `profiles.<name>.pins` / `spaces.<name>.pins` + `pinsForce` | Not in use. Nested folders, container assignment, essentials |
| Containers | `profiles.<name>.containers.<name> = { color, icon, id }` + `containersForce` | Not in use |
| Keyboard shortcuts | `profiles.<name>.keyboardShortcuts` + `keyboardShortcutsVersion` | Not in use. Version-guarded against Zen shortcut-schema changes |
| userChrome/userContent CSS | `profiles.<name>.userChrome` | Not in use. Raw CSS string written into the profile's `chrome/` dir — this is the declarative alternative to installing a Zen Mod by hand |
| Space routing | `profiles.<name>.spaceRouting` | Not in use. Regex/domain rules that route a URL to a given space on open |
| Native messaging hosts, extension buttons, env vars, live folders, joined tabs | one option each, see `examples/14`, `19`, `16`, `17`, `15` | Not inspected in detail |

`pins`, `spaces`, `containers`, and `keyboardShortcuts` all require **closing
Zen before `home-manager switch`** — their activation scripts edit live
session/session-store files (`zen-sessions.jsonlz4`,
`zen-keyboard-shortcuts.json`) that Zen locks while running. Declarative, but
not hot-reloadable.

## Not declarative (no option anywhere in this flake, or any other)

- **Toolbar layout mode** (Multiple toolbars / Single toolbar / Collapsed —
  what gives you a "collapsed sidebar"). This lives in Firefox's
  `CustomizableUI` widget-placement state, not a pref or a file this module
  touches. Set it once by hand: toolbar right-click → Change Toolbar Layout.
  (Decided against pursuing this — standard sidebar, left side, stays as-is.)
- Extension-internal runtime state — e.g. actually unlocking/logging into the
  Bitwarden vault, or its own saved settings. That's the extension's private
  storage, outside prefs.js and outside anything Home Manager can reach.
