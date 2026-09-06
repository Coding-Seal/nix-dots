# NixOS Workstation Dotfiles

## What this repo is

Declarative NixOS configuration for a personal workstation. Everything is reproducible — rebuilding from scratch should produce the same system.

**Stack**: Niri (Wayland WM) · Noctalia (desktop shell — panels, dock, notifications) · Stylix (system-wide app theming) · WezTerm · Neovim (LazyVim) · Zen Browser

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
justfile                    # command runner wrapping the workflows below (needs devenv shell)
devenv.nix                  # project devshell: nixfmt/statix/deadnix/just/nvd + git-hooks + fmt/lint scripts
wallpaper/                  # images used by stylix.image and Noctalia's wallpaper picker
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
      noctalia.nix          # programs.noctalia (NixOS + HM) — settings/customPalettes built by hand from Stylix, see Theming below
      stylix.nix            # system-wide theming: base16 scheme, polarity, image (NixOS, cascades to HM)
      theming.nix           # dconf + GTK/Qt support packages Stylix's targets need at runtime
      hidden-apps.nix       # NoDisplay=true overrides (HM) for launcher clutter (blueman, htop, unused LibreOffice components, etc.)
    apps/                   # grouped by purpose — import-tree doesn't care about path/filename,
                             # this layout is purely for humans
      browsers/
        chrome.nix          # google-chrome (HM)
        zen-browser.nix     # zen-browser flake's programs.zen-browser module (HM) — themed via Stylix
      dev/
        wezterm.nix         # wezterm (HM) — colors/fonts owned by Stylix's wezterm target
        zed.nix             # zed-editor (HM) — themed via Stylix's zed target
        claude-code.nix     # personalHmModules — see "Host-specific vs shared config" below
        herdr.nix           # from nixpkgs-unstable (not yet in pinned nixos-26.05)
        opencode.nix
      office/
        libreoffice.nix
      communication/
        telegram.nix               # HM — no Stylix target; builds a gruvbox theme at build time instead, see below
        telegram-theme-recolor.py  # hue-preserving recolor script the derivation above shells out to
        zoom.nix                   # personalHmModules — see "Host-specific vs shared config" below
      network/
        nekoray.nix         # programs.throne (NixOS) — nixpkgs renamed nekoray → throne; wraps Core with cap_net_admin for TUN mode
    shell/
      shells.nix            # fish, starship (HM)
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

`justfile` at the repo root wraps the everyday ones (needs the devenv shell — `direnv allow` or `devenv shell` — for `just`/`nvd`/`fd`):

```bash
just switch          # rebuild switch for this machine's hostname (or: just switch lumar)
just dry             # dry-activate first, to check for errors without applying
just rollback        # roll back to the previous generation
just diff            # build without switching, then nvd diff against the running system
just update          # nix flake update (all inputs) — commit flake.lock after
just update-input nixpkgs
just fmt             # nixfmt every .nix file
just check           # run the full pre-commit suite (deadnix, nixfmt, statix) on demand
just gc              # nix-collect-garbage -d
```

Raw commands, for when the devenv shell isn't active or you need something `just` doesn't wrap:

```bash
sudo nixos-rebuild switch --flake .#taldain      # VM
sudo nixos-rebuild switch --flake .#lumar        # home laptop
sudo nixos-rebuild switch --flake .#scadrial     # work laptop

sudo nixos-rebuild dry-activate --flake .#taldain

sudo nixos-rebuild switch --rollback

nix flake update
nix flake update nixpkgs

nvd diff /run/current-system result

# Search for a package
nix search nixpkgs <name>

# Open a temporary shell with a package (for testing)
nix shell nixpkgs#<name>

sudo nix-collect-garbage -d
```

---

## How to add a new feature

Create a new `.nix` file anywhere under `modules/features/` — `import-tree` picks it up automatically, no imports needed. See the `add-feature-module` skill for the pattern (`pkgs`-in-scope function wrapper, `nixosModules`/`hmModules`/`personalHmModules` wiring).

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

## Adding a new machine / bootstrapping from scratch

See the `add-nixos-host` skill for the full walkthrough — scaffolding `hosts/<machine>/{disko.nix,hardware-configuration.nix}` and `modules/<machine>.nix`, plus the bootstrap commands for a fresh install (disko partitioning, `nixos-generate-config`, first `nixos-rebuild switch`).

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

Fish is the only shell configured (`modules/features/shell/shells.nix`) and the login shell (`users.users.<name>.shell` in `modules/features/system/system.nix`).

---

## Noctalia notes

Noctalia has its own flake input in `flake.nix`. Its HM module is `inputs.noctalia.homeModules.default`, wired in `modules/features/desktop/noctalia.nix`. The real (locked) HM option namespace is `programs.noctalia` — not `programs.noctalia-shell`, which is a deprecated v4 module that also exists upstream. Don't trust cached/stale nix store copies when checking option names; resolve the actual locked input (`nix eval --impure --expr '(builtins.getFlake (toString ./.)).inputs.noctalia.outPath'`) and read `nix/home-module.nix` from there.

Required system services are declared in `modules/features/desktop/desktop.nix` (bluetooth, pipewire, portals) and `modules/features/system/networking.nix` (networkmanager).

Use the Cachix cache to avoid compiling Quickshell locally — cache settings live inline in each host config file (`modules/nixos.nix`, `modules/laptop.nix`).

---

## Theming: Stylix is the source of truth

App color theming flows from **Stylix**, not from Noctalia's own template engine. `modules/features/desktop/stylix.nix` sets `stylix.enable`, `polarity`, and `base16Scheme` at the NixOS level; because it imports `inputs.stylix.nixosModules.stylix` (not just the HM module), Stylix auto-injects itself into home-manager via `home-manager.sharedModules` and cascades those three values to every HM user automatically — no separate wiring needed per host.

Noctalia's palette is hand-derived from `config.lib.stylix.colors` in `modules/features/desktop/noctalia.nix` rather than picked independently — nixpkgs' bundled Stylix "noctalia" target is a complete no-op in this tree (it only wires the deprecated `programs.noctalia-shell`, not the real `programs.noctalia` from `inputs.noctalia.homeModules.default`).

See the `stylix-app-theming` skill for the full checklist when adding a new themed app or debugging why colors aren't applying — target-activation gotchas (`profileNames`, zen-browser's HM module requirement), WezTerm's `extraConfig` trap, and the hand-rolled fallback pattern used for apps with no Stylix target (Telegram).

---

## Agent instructions & skills are tool-agnostic

`AGENTS.md` (this file) is the canonical instructions file, following the cross-tool [AGENTS.md](https://agents.md) convention that opencode/herdr and others read directly. `CLAUDE.md` is a **symlink** to `AGENTS.md` — Claude Code only looks for `CLAUDE.md` by name, so the symlink gets it the same content with no duplication.

Agent Skills follow the same pattern: canonical files live under `.agents/skills/<name>/SKILL.md` (the path opencode reads natively); make them visible to Claude Code with a symlink at `.claude/skills/<name>` pointing at `../../.agents/skills/<name>`. Claude Code's own frontmatter extensions (`allowed-tools`, `context: fork`, hooks, etc.) are silently ignored by opencode rather than erroring — keep any skill's *core* behavior working with just `name`/`description`/prose, and treat Claude-only fields as optional enhancements.

## Gotcha: `nix eval`/flake commands only see git-tracked files

New files invisible to `nix eval .#...` / `nixos-rebuild` (producing confusing "option does not exist" errors that look like real config bugs) almost always mean the file is untracked — flake evaluation resolves through the git working tree, which excludes brand-new *untracked* files entirely. See the `nixos-rebuild-check` skill for the stage-then-verify workflow.
