# NixOS Workstation Dotfiles

## What this repo is

Declarative NixOS configuration for a personal workstation. Everything is reproducible — rebuilding from scratch should produce the same system.

**Stack**: Niri (Wayland WM) · Noctalia (desktop shell — panels, dock, notifications) · Stylix (system-wide app theming) · WezTerm · Neovim (LazyVim) · Firefox

**Hosts**: `taldain` (VM) · `lumar` (home laptop) · `scadrial` (work laptop, stub — hardware config pending)

> **Noctalia** ([docs](https://docs.noctalia.dev/v4/)) is a QML/Quickshell desktop shell, not a CLI shell. It provides the visual layer on top of Niri (status bar, launcher, notifications, widgets). Requires `nixpkgs-unstable` and its own flake input.

---

## Architecture: Dendritic Pattern

This repo uses the **Dendritic Pattern**: `flake-parts` + `import-tree` + feature modules.

`flake.nix` is 3 lines — it declares inputs and delegates all logic to `import-tree ./modules`. Every `.nix` file under `modules/` is automatically picked up as a **flake-parts module** (not a NixOS module, not a Home Manager module).

### Three kinds of files in `modules/`

| Kind | Role | Example |
|------|------|---------|
| **`parts.nix`** | Declares shared flake-parts options | `username`, `nixosModules`, `hmModules` |
| **Host configs** (`taldain.nix`, `lumar.nix`, `scadrial.nix`) | Assembles a `nixosSystem` from collected modules | Wires hardware + features into final output |
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
  taldain.nix               # assembles nixosConfigurations.taldain (VM)
  lumar.nix                 # assembles nixosConfigurations.lumar (home laptop)
  scadrial.nix              # assembles nixosConfigurations.scadrial (work laptop, stub)
  features/
    system/
      system.nix            # boot, users, security, swap
      networking.nix        # networkmanager (hostname/proxy stay in host configs)
    desktop/
      desktop.nix           # greeter, pipewire, bluetooth, portals, fonts
      niri.nix              # programs.niri (NixOS) + niri KDL config (HM)
      noctalia.nix          # programs.noctalia (NixOS + HM) — palette derived from Stylix, see Theming below
      stylix.nix            # system-wide theming: base16 scheme, polarity (NixOS, cascades to HM)
      theming.nix           # dconf + GTK/Qt support packages Stylix's targets need at runtime
    apps/
      browsers/
        firefox.nix         # firefox (HM) — themed via Stylix's firefox target
        chrome.nix          # google-chrome (HM)
        zen-browser.nix     # zen-browser flake's programs.zen-browser module (HM) — themed via Stylix
      wezterm.nix           # wezterm (HM) — colors/fonts owned by Stylix's wezterm target
      zed.nix               # zed-editor (HM) — themed via Stylix's zed target
      communication.nix     # telegram, zoom (HM) — no Stylix target exists for either
    shell/
      shells.nix            # fish, zsh, nushell, starship (HM)
      packages.nix          # home.packages CLI tools (HM)
      devenv.nix            # devenv + direnv (HM)
hosts/
  taldain/
    disko.nix               # disk layout for VM (/dev/vda, Btrfs subvolumes)
    hardware-configuration.nix  # generated — do not hand-edit
  lumar/
    disko.nix               # disk layout for home laptop (/dev/nvme0n1, Btrfs subvolumes)
    hardware-configuration.nix  # generated — do not hand-edit
  scadrial/
    disko.nix               # disk layout for work laptop (template — verify disk name)
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
| VM proxy / spice agent | Inline in `modules/taldain.nix` |
| Disk layout | `hosts/<hostname>/disko.nix` |
| Hardware | `hosts/<hostname>/hardware-configuration.nix` |
| Everything else | `modules/features/` |

---

## Common commands

```bash
# Apply system + home config
sudo nixos-rebuild switch --flake .#taldain      # VM
sudo nixos-rebuild switch --flake .#lumar        # home laptop
sudo nixos-rebuild switch --flake .#scadrial     # work laptop

# Dry-run to check for errors without applying
sudo nixos-rebuild dry-activate --flake .#taldain

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

Noctalia has its own flake input in `flake.nix`. Its HM module is `inputs.noctalia.homeModules.default`, wired in `modules/features/desktop/noctalia.nix`. The real (locked) HM option namespace is `programs.noctalia` — not `programs.noctalia-shell`, which is a deprecated v4 module that also exists upstream. Don't trust cached/stale nix store copies when checking option names; resolve the actual locked input (`nix eval --impure --expr '(builtins.getFlake (toString ./.)).inputs.noctalia.outPath'`) and read `nix/home-module.nix` from there.

Required system services are declared in `modules/features/desktop/desktop.nix` (bluetooth, pipewire, portals) and `modules/features/system/networking.nix` (networkmanager).

Use the Cachix cache to avoid compiling Quickshell locally — cache settings live inline in each host config file (`modules/nixos.nix`, `modules/laptop.nix`).

---

## Theming: Stylix is the source of truth

App color theming flows from **Stylix**, not from Noctalia's own template engine. `modules/features/desktop/stylix.nix` sets `stylix.enable`, `polarity`, and `base16Scheme` at the NixOS level; because it imports `inputs.stylix.nixosModules.stylix` (not just the HM module), Stylix auto-injects itself into home-manager via `home-manager.sharedModules` and cascades those three values to every HM user automatically — no separate wiring needed per host.

- **Noctalia's palette is derived from Stylix**, not picked independently. Stylix's `noctalia` target writes `programs.noctalia.customPalettes.stylix` from the active base16 scheme and points `programs.noctalia.settings.theme` at it. Don't re-enable Noctalia's own `theme.templates.builtin_ids` for `gtk3`/`gtk4`/`qt`/`kcolorscheme` — Stylix's `gtk`/`qt` targets nix-manage those exact same file paths (`gtk-3.0/gtk.css`, etc.), so both writing to them will fight.
- **`modules/features/desktop/theming.nix`** only carries what Stylix's targets still need at the system level (`programs.dconf.enable`) plus unrelated manual tools (`nwg-look`, `gsettings-desktop-schemas`). Don't add `adw-gtk3`/`qt6ct` back — Stylix's gtk/qt targets install those declaratively themselves (`gtk.theme.package`, `qt.platformTheme.name`).
- **Some Stylix targets need explicit config to activate**, they don't all just work from `autoEnable`:
  - `stylix.targets.firefox.profileNames` / `stylix.targets.zen-browser.profileNames` must list your HM profile names (e.g. `[ "default" ]`) — these targets can't discover profile names on their own and silently no-op without it (surfaces as an `evaluation warning`, not an error).
  - The zen-browser target additionally requires the `programs.zen-browser` HM option namespace to exist at all — a raw `home.packages` install of the browser (no HM module) doesn't trigger it. Use the zen-browser flake's own HM module (`inputs.zen-browser.homeModules.default`), which mirrors home-manager's built-in firefox module.
- **WezTerm**: `apps/wezterm.nix` uses `programs.wezterm.settings` (structured attrs), not `extraConfig`. This is required, not stylistic — once any module (Stylix's wezterm target included) also sets `programs.wezterm.settings`, home-manager stops inlining `extraConfig` directly and instead wraps it in a function; a self-contained `local config = wezterm.config_builder(); ...; return config` extraConfig would silently become dead code (mutating a shadowed local, its `return` discarded) with no error.
- **No Stylix target exists** for Telegram, Zoom, or (as a full app-theming target) Chrome — Chrome only gets a lightweight `programs.chromium` browser-theme-color policy, not real CSS-level theming.

---

## Gotcha: `nix eval`/flake commands only see git-tracked files

New files invisible to `nix eval .#...` / `nixos-rebuild` (producing confusing "option does not exist" errors that look like real config bugs) almost always mean the file is untracked. Local flake evaluation resolves through the git working tree, which includes uncommitted *modifications to tracked files* but excludes brand-new *untracked* files entirely. Run `git add` on new files before evaluating/building, even before committing.
