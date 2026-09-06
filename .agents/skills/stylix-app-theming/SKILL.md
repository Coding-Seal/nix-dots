---
name: stylix-app-theming
description: Use when adding a new app that should be themed, or when app theming isn't applying/looks wrong. Stylix is this repo's single source of truth for color theming — walks through checking for a Stylix target, the profileNames/module-existence gotchas that make targets silently no-op, and the fallback pattern for apps with no target at all.
---

## When to use this

- Adding a new app under `modules/features/apps/` that has visible UI and
  should match the system theme.
- An app's colors don't match the rest of the desktop after adding it.
- Noctalia's palette or an app's theme looks stale/wrong after a Stylix
  scheme change.

## The rule: Stylix is the source of truth, not app-native theming

Color theming flows from `stylix.enable` / `polarity` / `base16Scheme` in
`modules/features/desktop/stylix.nix`. Because that file imports
`inputs.stylix.nixosModules.stylix` (the NixOS module, not just the HM one),
Stylix auto-injects itself into every HM user via
`home-manager.sharedModules` — no per-host wiring needed. Don't hand-roll a
competing color scheme for a new app if a Stylix target exists for it.

## Steps

1. **Check if a Stylix target exists** for the app: look at
   `inputs.stylix` (`nix eval --impure --expr '(builtins.getFlake (toString ./.)).inputs.stylix.outPath'`
   then browse `modules/` in that source, e.g. `modules/wezterm.nix`,
   `modules/firefox.nix`) or search the Stylix docs. If one exists, prefer
   `stylix.targets.<app>.enable` (often already true via `autoEnable`) over
   any app-native theme setting.

2. **Some targets need explicit config to actually activate** — they don't
   discover everything automatically and fail silently (an evaluation
   warning, not an error):
   - `stylix.targets.firefox.profileNames` / `stylix.targets.zen-browser.profileNames`
     must list the HM profile name(s) (e.g. `[ "default" ]`).
   - The zen-browser target additionally requires the real
     `programs.zen-browser` HM module (from the zen-browser flake's
     `inputs.zen-browser.homeModules.default`) to exist in the config — a bare
     `home.packages` install of the browser binary does **not** trigger it.

3. **Structured settings vs. `extraConfig`**: for apps like WezTerm, once
   *any* module (including a Stylix target) also sets
   `programs.<app>.settings`, Home Manager stops inlining `extraConfig`
   directly and wraps it in a function instead — a self-contained
   `extraConfig` script (e.g. one ending in its own `return config`) silently
   becomes dead code with no error. Use `programs.<app>.settings` (structured
   attrs) for anything Stylix also touches.

4. **No Stylix target exists** (true today for Telegram, Zoom, and full
   CSS-level Chrome theming — Chrome only gets a lightweight
   `programs.chromium` browser-theme-color policy): fall back to the
   hand-built pattern in `modules/features/apps/communication/telegram.nix` —
   fetch/build the app's own theme asset at build time, recolor its literal
   hex values onto `config.lib.stylix.colors` (see
   `telegram-theme-recolor.py` for a lightness-preserving hue remap), and drop
   the result at a path the app can import. If the app's theme storage is
   opaque (e.g. Telegram's `tdata`), a one-time manual import step is
   sometimes unavoidable — say so explicitly rather than pretending Nix
   finished the job.

5. **Noctalia specifically**: its palette is derived from Stylix by hand in
   `modules/features/desktop/noctalia.nix` (`customPalettes.stylix` +
   `settings.theme`, built from `config.lib.stylix.colors`) — nixpkgs'
   bundled Stylix "noctalia" target only wires the deprecated
   `programs.noctalia-shell` option and is a no-op here. Leave Noctalia's own
   `theme.templates.builtin_ids` / `community_ids` empty for anything Stylix
   already targets (`gtk`, `qt`, `wezterm`, and the hand-rolled `telegram`
   case) — letting both engines write the same files causes them to fight.

6. **Verify**: rebuild (see the `nixos-rebuild-check` skill) and visually
   confirm the app's colors against the running Stylix scheme — this is a
   visual/theming change, so a successful build is necessary but not
   sufficient.
