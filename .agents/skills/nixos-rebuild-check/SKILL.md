---
name: nixos-rebuild-check
description: Use before claiming any change to this flake works, and whenever nix eval/nixos-rebuild throws a confusing "option does not exist" error. Stages new files first (flake evaluation only sees git-tracked content), then verifies with a non-destructive build before a real switch.
---

## When to use this

After any edit under `modules/`, `hosts/`, or `flake.nix` — before telling the
user it's done. Also the first thing to check when `nix eval`/
`nixos-rebuild` reports an option or file that "doesn't exist" even though it
plainly does on disk.

## Steps

1. **Stage new files.** Local flake evaluation resolves through the git
   working tree: it includes uncommitted *modifications to tracked files* but
   completely excludes brand-new *untracked* files. This is the #1 cause of
   confusing "option does not exist" errors in this repo.

   ```bash
   git status --short   # check for `??` entries you just created
   git add <new files>
   ```

2. **Build without activating** — this needs no `sudo` and won't touch the
   running system, so it's always safe to run:

   ```bash
   nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link
   ```

   Hosts in this repo: `taldain` (VM), `lumar` (home laptop), `scadrial`
   (work laptop — hardware config is a stub, expect it to fail differently
   from a real hardware issue).

3. **If `just`/devenv is available**, `just dry` wraps
   `sudo nixos-rebuild dry-activate --flake .#<host>` for a closer-to-real
   check (needs sudo, interactive password — can't run unattended in a
   non-interactive session). `just diff` additionally runs `nvd diff` against
   the running system so you can see exactly what would change.

4. **Only after a clean build/dry-activate**, apply for real:

   ```bash
   just switch          # or: sudo nixos-rebuild switch --flake .#<host>
   ```

5. **If a switch breaks something**, `just rollback` /
   `sudo nixos-rebuild switch --rollback` returns to the previous generation.
   Treat this as a real, hard-to-reverse action — confirm with the user
   before rolling back a system they're actively using, same as any other
   destructive operation.
