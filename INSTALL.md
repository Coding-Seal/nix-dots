# Installation Guide

Two paths depending on your situation:

- **[A] Fresh install from ISO** — boot NixOS ISO on the VM, let disko partition the disk, install everything in one shot
- **[B] NixOS already running** — you have a minimal NixOS VM and just want to apply this config

---

## Before you start (both paths)

### 1. Push this repo to GitHub

You need the repo accessible from the VM. On your host machine:

```bash
# Create a repo on GitHub, then:
cd ~/nix-dots
git add .
git commit -m "initial config"
git remote add origin https://github.com/YOUR_USERNAME/nix-dots.git
git push -u origin main
```

### 1b. Wait for flake.lock to be generated

After the push, GitHub Actions runs automatically and generates `flake.lock`
(a file that pins all inputs to exact versions). **Do not skip this step** —
without it, the live ISO has to download nixpkgs on its tiny RAM disk, which
runs out of space.

- Open your repo on GitHub → click the **Actions** tab
- Wait for the "Generate flake.lock" job to go green (~2 minutes)
- It will commit `flake.lock` back to the repo automatically

If you want to trigger it manually: Actions → "Generate flake.lock" → Run workflow.

### 2. Edit your username in flake.nix

Open [flake.nix](flake.nix) and change:
```nix
username = "nixos";  # ← change to whatever you want your username to be
```

### 3. Check your disk name

The disko config assumes `/dev/vda` (QEMU/KVM VMs).  
If you use VirtualBox or VMware it's likely `/dev/sda`.

Open [hosts/nixos/disko.nix](hosts/nixos/disko.nix) and update:
```nix
disk = "/dev/vda";  # ← check with `lsblk` on the VM
```

Commit and push after making these edits.

---

## Path A — Fresh install from NixOS ISO

### Step 1: Boot the NixOS ISO

Download the **minimal** ISO from https://nixos.org/download and attach it to your VM.
Boot from it. You'll land in a root shell.

### Step 2: Get internet access

```bash
# Wired (ethernet) — usually works automatically
ping nixos.org

# Wi-Fi — run the interactive setup
iwctl
  station wlan0 scan
  station wlan0 get-networks
  station wlan0 connect "Your Network"
  quit
```

### Step 3: Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/nix-dots.git /tmp/nix-dots
cd /tmp/nix-dots
```

### Step 4: Run the install script

This handles flakes setup, disk partitioning (disko), and hardware config generation in one shot.
Pass your HTTP proxy if downloads are hanging (common in VMs with no IPv6 route):

```bash
# Without proxy:
bash install.sh

# With proxy (replace host/port with yours):
export http_proxy=http://192.168.122.1:3128
export https_proxy=http://192.168.122.1:3128
bash install.sh
```

The script will show your disks, ask for confirmation before wiping, then print the
`nixos-install` command to run next.

### Step 5: Install NixOS

```bash
sudo nixos-install --flake /tmp/nix-dots#nixos --no-root-passwd
```

This will take a while on first run — it's downloading and building the full system.  
`--no-root-passwd` skips setting a root password (you'll set your user password next).

### Step 8: Set your user password

```bash
# Replace "nixos" with your actual username
sudo nixos-enter --root /mnt -c "passwd nixos"
```

### Step 9: Reboot

```bash
reboot
```

Remove the ISO from the VM's boot order. You should land at the tuigreet login screen.  
Log in with your username and the password you just set. Niri will start, and Noctalia will launch automatically.

---

## Path B — NixOS already running on the VM

If you already have a minimal NixOS installed and just want to apply this config:

### Step 1: Clone the repo on the VM

```bash
nix-shell -p git   # if git isn't installed yet
git clone https://github.com/YOUR_USERNAME/nix-dots.git ~/nix-dots
cd ~/nix-dots
```

### Step 2: Copy your existing hardware config

```bash
sudo nixos-generate-config --show-hardware-config \
  > hosts/nixos/hardware-configuration.nix
```

### Step 3: Enable flakes (if not already)

Add this to your current `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then apply: `sudo nixos-rebuild switch`

### Step 4: Apply this config

```bash
cd ~/nix-dots
sudo nixos-rebuild switch --flake .#nixos
```

> **Note on disko:** When applied to an already-running system, the disko module
> only manages the `fileSystems` declarations in NixOS — it does NOT reformat your
> disk. Reformatting only happens when you explicitly run the `disko` command.
> If your existing partitions don't match `disko.nix`, either update `disko.nix`
> to match reality, or remove the disko import from `flake.nix` and keep your
> `hardware-configuration.nix` managing mounts instead.

---

## After first boot

### Neovim (LazyVim)
On first launch, LazyVim will download and install all plugins:
```bash
nvim   # wait ~1 minute on first open, then it's fully set up
```

### Noctalia setup wizard
Noctalia launches automatically with Niri. On first run it shows a wizard — follow it to pick your color scheme and panel layout.

### Try the other shells
```bash
zsh    # try Zsh
nu     # try Nushell
```
To make one permanent, change `shell = pkgs.fish` to `shell = pkgs.zsh` or `shell = pkgs.nushell` in [hosts/nixos/default.nix](hosts/nixos/default.nix) and rebuild.

---

## Useful commands after setup

```bash
# Apply config changes
sudo nixos-rebuild switch --flake ~/nix-dots#nixos

# Roll back if something breaks
sudo nixos-rebuild switch --rollback

# Update all packages
cd ~/nix-dots && nix flake update && sudo nixos-rebuild switch --flake .#nixos

# List generations (previous system states you can roll back to)
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Free disk space
sudo nix-collect-garbage -d
```
