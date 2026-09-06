---
name: add-nixos-host
description: Use when bootstrapping a new machine/host in this flake (new laptop, VM, etc). Scaffolds hosts/<machine>/{disko.nix,hardware-configuration.nix} and modules/<machine>.nix with the nixosSystem wiring — cachix substituters, disko, hardware, home-manager, hostname.
---

## When to use this

Adding a genuinely new host to `flake.nixosConfigurations` — not a config
change to an existing host (`taldain`, `lumar`, `scadrial`), which is just a
feature-module edit instead (see the `add-feature-module` skill).

## Steps

1. **Disk layout**: create `hosts/<machine>/disko.nix`. Base it on an existing
   host's disko config (`hosts/lumar/disko.nix` or `hosts/taldain/disko.nix`)
   and adjust the disk device path (`/dev/nvme0n1`, `/dev/vda`, etc — verify
   the real device name on the target machine, don't assume).

2. **Hardware config**: create `hosts/<machine>/hardware-configuration.nix`.
   If you're on the real target hardware already, generate it for real:

   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/<machine>/hardware-configuration.nix
   ```

   Never hand-edit this file once generated. If you don't have hardware access
   yet, a placeholder is acceptable short-term (see `scadrial` for the stub
   pattern) — but note it explicitly as pending in the file.

3. **Host module**: create `modules/<machine>.nix` assembling the
   `nixosSystem`:

   ```nix
   { config, inputs, ... }:
   {
     flake.nixosConfigurations.<machine> = inputs.nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       modules = [
         {
           nix.settings = {
             extra-substituters = [ "https://cache.nixos.org" "https://noctalia.cachix.org" ];
             extra-trusted-public-keys = [ /* keys — copy from an existing host */ ];
           };
         }
         inputs.disko.nixosModules.disko
         ../hosts/<machine>/disko.nix
         ../hosts/<machine>/hardware-configuration.nix
         inputs.home-manager.nixosModules.home-manager
         {
           home-manager = {
             useGlobalPkgs = true;
             useUserPackages = true;
             backupFileExtension = "bak";
             users.${config.username} = {
               imports = config.hmModules;
               home.username = config.username;
               home.homeDirectory = "/home/${config.username}";
               programs.home-manager.enable = true;
               home.stateVersion = "25.05";
             };
           };
         }
         { networking.hostName = "<machine>"; }   # machine-specific overrides go here
       ] ++ config.nixosModules;
     };
   }
   ```

   Anything host-specific (hostname, VM proxy/spice agent, other per-machine
   overrides) goes inline in this file, not in `modules/features/` — shared
   features apply to every host automatically via `config.nixosModules` /
   `config.hmModules`.

4. **Stage the new files before evaluating anything** — `nix eval`/
   `nixos-rebuild` only see git-tracked content, and three brand-new files at
   once makes the "option does not exist" failure mode from skipping this even
   more confusing than usual:

   ```bash
   git add hosts/<machine>/ modules/<machine>.nix
   ```

5. **Verify** with `nix build .#nixosConfigurations.<machine>.config.system.build.toplevel --no-link` (see the `nixos-rebuild-check` skill) before attempting a real `nixos-rebuild switch` on the target machine.

6. **First switch on the real machine** (not from a dev shell elsewhere):

   ```bash
   sudo nixos-rebuild switch --flake .#<machine>
   ```
