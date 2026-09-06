---
name: add-feature-module
description: Use when adding a new NixOS or Home Manager feature to this dendritic-pattern flake (a new app, service, or system setting). Scaffolds a modules/features/**/*.nix file with the correct pkgs-in-scope pattern and nixosModules/hmModules/personalHmModules wiring, and flags the git-add-before-eval gotcha for the new file.
---

## When to use this

Any time a change means "install/configure X" and X isn't already covered by an
existing file under `modules/features/`. Covers new apps, new NixOS services,
new HM dotfile config.

## Steps

1. **Pick a path.** `import-tree` picks up every `.nix` file under `modules/`
   automatically — the path is purely for humans. Group by purpose:
   `modules/features/apps/<category>/<name>.nix` for user apps
   (`browsers/`, `dev/`, `office/`, `communication/`, `network/`), or
   `modules/features/desktop/<name>.nix` / `modules/features/system/<name>.nix`
   for system-level infra.

2. **Decide which layer(s) you need** — NixOS (`config.nixosModules`), Home
   Manager (`config.hmModules`), or both. Related config for one feature lives
   in one file regardless of layer (e.g. `niri.nix` holds both the NixOS
   `programs.niri.enable` and the HM KDL config).

3. **`pkgs` is not in scope at the top level of a flake-parts module.** Always
   wrap NixOS/HM config needing `pkgs` in a function so the module system
   injects it at eval time:

   ```nix
   { config, inputs, ... }:
   {
     config.nixosModules = [
       ({ pkgs, ... }: {
         services.something.enable = true;
       })
     ];

     config.hmModules = [
       ({ pkgs, ... }: {
         programs.something = {
           enable = true;
           package = pkgs.something;
         };
       })
     ];
   }
   ```

   Both `nixosModules` and `hmModules` are optional — omit whichever layer you
   don't need. `_: { ... }` (ignoring the flake-parts args) is fine when you
   don't need `pkgs`, `config`, or `inputs` at the outer level.

4. **Personal vs. universal app?** If it's a personal/leisure app that
   shouldn't land on the work laptop (`scadrial`) without a per-host
   conditional, use `config.personalHmModules` instead of `config.hmModules`
   — see `zoom.nix` or `claude-code.nix` for the pattern. Everything under
   `config.hmModules` applies to every host unconditionally.

5. **No manual imports needed anywhere** — `import-tree` finds the new file on
   its own, but only once git knows about it:

   ```bash
   git add modules/features/<path>/<name>.nix
   ```

   Skipping this step produces confusing "option does not exist" errors from
   `nix eval`/`nixos-rebuild`, because flake evaluation only sees git-tracked
   files (see the `nixos-rebuild-check` skill).

6. **Verify it builds** before considering the feature done — see the
   `nixos-rebuild-check` skill for the exact command.
