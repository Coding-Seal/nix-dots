# Flake Restructure: Dendritic Pattern

## What changed

Migrated from a flat `flake.nix` + `home/` layout to the **Dendritic Pattern**
using `flake-parts` + `import-tree` + `wrapper-modules`.

### Before
```
flake.nix                   — inputs + full outputs logic in one file
home/
  default.nix               — HM root (imports, packages)
  niri.nix                  — HM niri config
  noctalia.nix              — HM noctalia
  shells/{fish,zsh,nu,...}  — HM shell configs
  wezterm.nix               — HM wezterm
  nvim.nix                  — HM neovim
  firefox.nix               — HM firefox
hosts/nixos/
  default.nix               — NixOS system config
  disko.nix                 — disk layout
  hardware-configuration.nix
```

### After
```
flake.nix                   — 3 lines: inputs + delegates to import-tree
modules/
  parts.nix                 — systems list + shared options (username, nixosModules, hmModules)
  nixos.nix                 — assembles nixosConfiguration from collected options
  features/
    system.nix              — boot, users, security, swap, VM guest
    networking.nix          — hostname, proxy
    desktop.nix             — greetd, pipewire, bluetooth, portals, fonts
    niri.nix                — programs.niri (NixOS) + niri KDL config (HM)
    shells.nix              — fish, zsh, nushell, starship (HM)
    wezterm.nix             — wezterm (HM)
    nvim.nix                — neovim + packages (HM)
    firefox.nix             — firefox (HM)
    noctalia.nix            — noctalia-shell (HM)
    packages.nix            — home.packages CLI tools (HM)
hosts/nixos/
  disko.nix                 — disk layout (unchanged)
  hardware-configuration.nix — generated, machine-specific
```

## Dendritic Pattern: key rules

1. **Every non-entry-point file is a flake-parts module** — not a NixOS module,
   not an HM module. All files in `modules/` take `{ config, inputs, lib, ... }`
   from flake-parts, not from NixOS.

2. **Feature-centric, not layer-centric** — `niri.nix` contains both the NixOS
   enablement (`programs.niri.enable`) and the HM config (KDL file). Related
   config lives together regardless of which layer it targets.

3. **No `specialArgs` pass-through** — `username` is a flake-parts option defined
   in `parts.nix`. Feature modules read it as `config.username`. It's evaluated
   in the flake-parts context before being embedded in NixOS/HM modules.

4. **`nixosModules` / `hmModules` options collect contributions** — each feature
   module appends to these lists. `nixos.nix` assembles them into the final
   `nixosSystem` call.

## New inputs added

- `flake-parts` — `mkFlake` replaces the manual outputs function
- `import-tree` — auto-imports all `.nix` files under `modules/`
- `wrapper-modules` — available for niri/noctalia wrapper config (future use)

Run after any new input is added:
```bash
nix flake lock
```

## How to add a new feature

Create `modules/features/my-feature.nix`:

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

`import-tree` picks it up automatically — no manual imports needed.

## How to add a new machine

Create `modules/machines/my-machine.nix`:

```nix
{ config, inputs, ... }:
{
  flake.nixosConfigurations.my-machine = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = config.nixosModules ++ [
      ../hosts/my-machine/hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.users.${config.username}.imports = config.hmModules;
      }
    ];
  };
}
```

## Changing the username

Edit `modules/parts.nix`:
```nix
username = lib.mkOption {
  type = lib.types.str;
  default = "your-username";  # ← change here
};
```

## Important: pkgs in feature modules

Feature modules are flake-parts modules — `pkgs` is NOT available directly.
When a NixOS or HM module inside `nixosModules`/`hmModules` needs pkgs,
write it as a function:

```nix
# WRONG — pkgs not in scope here
config.nixosModules = [{
  services.greetd.settings.default_session.command =
    "${pkgs.greetd.tuigreet}/bin/tuigreet";  # error: pkgs undefined
}];

# CORRECT — pkgs injected by NixOS module system at eval time
config.nixosModules = [
  ({ pkgs, ... }: {
    services.greetd.settings.default_session.command =
      "${pkgs.greetd.tuigreet}/bin/tuigreet";
  })
];
```
