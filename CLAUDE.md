# NixOS Workstation Dotfiles

## What this repo is

Declarative NixOS configuration for a personal workstation. Everything is reproducible — rebuilding from scratch should produce the same system.

**Stack**: Niri (Wayland WM) · Noctalia (desktop shell — panels, dock, notifications) · WezTerm · Neovim (LazyVim) · Firefox

**Hosts**: `nixos` (VM) · `laptop` (stub — hardware config pending)

> **Noctalia** ([docs](https://docs.noctalia.dev/v4/)) is a QML/Quickshell desktop shell, not a CLI shell. It provides the visual layer on top of Niri (status bar, launcher, notifications, widgets). Requires `nixpkgs-unstable` and its own flake input.

---

## Architecture: Dendritic Pattern

This repo uses the **Dendritic Pattern**: `flake-parts` + `import-tree` + feature modules.

`flake.nix` is 3 lines — it declares inputs and delegates all logic to `import-tree ./modules`. Every `.nix` file under `modules/` is automatically picked up as a **flake-parts module** (not a NixOS module, not a Home Manager module).

### Three kinds of files in `modules/`

| Kind | Role | Example |
|------|------|---------|
| **`parts.nix`** | Declares shared flake-parts options | `username`, `nixosModules`, `hmModules` |
| **Host configs** (`nixos.nix`, `laptop.nix`) | Assembles a `nixosSystem` from collected modules | Wires hardware + features into final output |
| **Feature modules** (`features/*.nix`) | Appends to `nixosModules` / `hmModules` lists | `desktop.nix`, `niri.nix`, `shells.nix`, … |

### Key rules

1. **Every file in `modules/` is a flake-parts module** — args are `{ config, inputs, lib, ... }` from flake-parts, never from NixOS or HM.
2. **Feature-centric, not layer-centric** — `niri.nix` holds both the NixOS enablement and the HM KDL config. Related config lives together regardless of which layer it targets.
3. **No `specialArgs`** — `username` is a flake-parts option defined in `parts.nix`, read as `config.username` in feature modules, evaluated before NixOS/HM ever runs.
4. **Modules accumulate via list options** — each feature appends to `config.nixosModules` / `config.hmModules`; the host config file concatenates them into the final `nixosSystem` call.
5. **`import-tree` picks up new files automatically** — no manual imports needed anywhere.

### `pkgs` in feature modules

Feature modules are flake-parts modules — `pkgs` is **not** in scope at the outer level. Use a function so NixOS/HM injects `pkgs` at eval time:

```nix
# WRONG — pkgs not in scope here
config.nixosModules = [{
  services.greetd.settings.default_session.command =
    "${pkgs.greetd.tuigreet}/bin/tuigreet";
}];

# CORRECT — pkgs injected by NixOS module system
config.nixosModules = [
  ({ pkgs, ... }: {
    services.greetd.settings.default_session.command =
      "${pkgs.greetd.tuigreet}/bin/tuigreet";
  })
];
```

---

## Directory layout

```
flake.nix                   # 3 lines: inputs + delegates to import-tree
flake.lock                  # pinned inputs — commit after updates
modules/
  parts.nix                 # systems list + shared options (username, nixosModules, hmModules)
  nixos.nix                 # assembles nixosConfigurations.nixos (VM)
  laptop.nix                # assembles nixosConfigurations.laptop (stub)
  features/
    system.nix              # boot, users, security, swap
    networking.nix          # networkmanager (hostname/proxy stay in host configs)
    desktop.nix             # greetd, pipewire, bluetooth, portals, fonts
    niri.nix                # programs.niri (NixOS) + niri KDL config (HM)
    shells.nix              # fish, zsh, nushell, starship (HM)
    wezterm.nix             # wezterm (HM)
    nvim.nix                # neovim + packages (HM)
    firefox.nix             # firefox (HM)
    noctalia.nix            # noctalia-shell (HM)
    packages.nix            # home.packages CLI tools (HM)
hosts/
  nixos/
    disko.nix               # disk layout for VM (/dev/vda, Btrfs subvolumes)
    hardware-configuration.nix  # generated — do not hand-edit
  laptop/
    disko.nix               # disk layout for laptop (/dev/nvme0n1, Btrfs subvolumes)
    hardware-configuration.nix  # placeholder — replace with real file from nixos-generate-config
config/
  nvim/                     # Neovim / LazyVim config
```

---

## Host-specific vs shared config

Shared features live in `modules/features/` and apply to **all hosts** automatically.
Host-specific overrides go inline in each host's config file:

| What | Where |
|------|-------|
| Hostname | Inline in host config (`networking.hostName`) |
| VM proxy / spice agent | Inline in `modules/nixos.nix` |
| Disk layout | `hosts/<hostname>/disko.nix` |
| Hardware | `hosts/<hostname>/hardware-configuration.nix` |
| Everything else | `modules/features/` |

---

## Common commands

```bash
# Apply system + home config
sudo nixos-rebuild switch --flake .#nixos        # VM
sudo nixos-rebuild switch --flake .#laptop       # laptop

# Dry-run to check for errors without applying
sudo nixos-rebuild dry-activate --flake .#nixos

# Roll back to previous generation if something breaks
sudo nixos-rebuild switch --rollback

# Update all flake inputs (then commit flake.lock)
nix flake update

# Update a single input
nix flake update nixpkgs

# Show what changed between generations
nvd diff /run/current-system result

# Search for a package
nix search nixpkgs <name>

# Open a temporary shell with a package (for testing)
nix shell nixpkgs#<name>

# Garbage-collect old generations (free disk space)
sudo nix-collect-garbage -d
```

---

## How to add a new feature

Create `modules/features/my-feature.nix` — `import-tree` picks it up automatically, no imports needed:

```nix
{ config, inputs, ... }:
{
  # NixOS config for this feature
  config.nixosModules = [
    {
      services.something.enable = true;
    }
  ];

  # HM config for this feature (needs pkgs? use a function)
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

Both blocks are optional — omit whichever layer you don't need.

---

## How to add a new machine

1. Create `hosts/<machine>/disko.nix` and `hosts/<machine>/hardware-configuration.nix`
2. Create `modules/<machine>.nix`:

```nix
{ config, inputs, ... }:
{
  flake.nixosConfigurations.<machine> = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      {
        nix.settings = {
          extra-substituters = [ "https://cache.nixos.org" "https://noctalia.cachix.org" ];
          extra-trusted-public-keys = [ /* keys */ ];
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
      { networking.hostName = "<machine>"; }   # machine-specific overrides
    ] ++ config.nixosModules;
  };
}
```

---

## Changing the username

Edit `modules/parts.nix`:
```nix
username = lib.mkOption {
  type = lib.types.str;
  default = "your-username";  # ← change here
};
```

---

## Bootstrapping a machine from scratch

1. Boot NixOS minimal ISO, clone this repo.
2. Fresh disk: `sudo nix run github:nix-community/disko -- --mode disko hosts/<machine>/disko.nix`
3. Generate hardware config: `sudo nixos-generate-config --show-hardware-config > hosts/<machine>/hardware-configuration.nix`
4. `sudo nixos-rebuild switch --flake .#<machine>`

---

## NixOS concepts (quick reference)

| Term | What it means |
|------|---------------|
| **Derivation** | A build recipe: inputs → a path in `/nix/store` |
| **Flake** | A project with `flake.nix` — reproducible, locked inputs |
| **Home Manager** | Manages user dotfiles/apps declaratively (like NixOS but for `~`) |
| **Module** | A `.nix` file that declares `options` and `config` — composable, no ordering issues |
| **flake-parts** | Framework for structuring flake outputs as composable modules |
| **import-tree** | Auto-imports all `.nix` files under a directory as flake-parts modules |
| **Overlay** | Patches or extends the `pkgs` package set |

---

## Shell setup

Three shells are configured; Fish is the login shell. To switch default, change `users.users.<name>.shell` in `modules/features/system.nix`.

| Shell | Role |
|-------|------|
| Fish | Default login shell — beginner-friendly, great autocompletions |
| Zsh | Available — run `zsh` to try it |
| Nushell | Available — run `nu` to try it |

---

## Noctalia notes

Noctalia has its own flake input in `flake.nix`. Its HM module is `inputs.noctalia.homeModules.default`, wired in `modules/features/noctalia.nix`.

Required system services are declared in `modules/features/desktop.nix` (bluetooth, pipewire, portals) and `modules/features/networking.nix` (networkmanager).

Use the Cachix cache to avoid compiling Quickshell locally — cache settings live inline in each host config file (`modules/nixos.nix`, `modules/laptop.nix`).
