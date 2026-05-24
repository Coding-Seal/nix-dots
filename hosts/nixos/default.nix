# System-level NixOS configuration.
# This is for things that affect the whole machine: hardware, users,
# system services, kernel. User apps and dotfiles live in home/ instead.
{ pkgs, username, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ──────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ────────────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.proxy.default = "http://192.168.122.1:2081";
  networking.proxy.noProxy = "127.0.0.1,localhost";

  # ── Locale & time ─────────────────────────────────────────────────────────
  # TODO: change to your timezone — run `timedatectl list-timezones` to find yours
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Users ─────────────────────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    # Fish is the default login shell; see home/shells/ to try others
    shell = pkgs.fish;
  };

  # ── Nix settings ──────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ── Wayland compositor (Niri) ─────────────────────────────────────────────
  # This makes niri available system-wide and creates a Wayland session entry.
  programs.niri.enable = true;

  # Fish must be enabled at system level for it to work as a login shell
  programs.fish.enable = true;

  # ── Display manager ───────────────────────────────────────────────────────
  # greetd + tuigreet: minimal terminal-based login screen, works great with Niri
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri";
      user = "greeter";
    };
  };

  # ── Audio (PipeWire) ──────────────────────────────────────────────────────
  # PipeWire replaces PulseAudio and JACK on modern systems.
  # pulse.enable gives compatibility with apps that use the PulseAudio API.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ── Hardware ──────────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ── System services (required by Noctalia desktop shell) ──────────────────
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.blueman.enable = true; # Bluetooth manager GUI

  # ── XDG desktop portals ───────────────────────────────────────────────────
  # Portals allow sandboxed apps (like Firefox) to open file pickers,
  # share screens, etc. gnome portal works well with Niri.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = "gnome";
  };

  # ── Fonts ─────────────────────────────────────────────────────────────────
  # JetBrains Mono Nerd Font is used by WezTerm and Neovim for icons/glyphs
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # ── VM guest (SPICE) ─────────────────────────────────────────────────────
  # spice-vdagentd enables clipboard sharing, dynamic display resolution,
  # and file transfer when running as a SPICE/QEMU VM guest.
  services.spice-vdagentd.enable = true;

  # ── Swap ──────────────────────────────────────────────────────────────────
  # zram creates a compressed RAM disk used as swap — no disk partition needed,
  # performs better than disk swap in a VM, and pairs perfectly with Btrfs
  # (Btrfs swapfiles are awkward to set up; zram sidesteps that entirely).
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # Size = 50% of RAM. Raise to "100%" if the VM has less than 4 GB RAM.
    memoryPercent = 50;
  };

  # ── Security ──────────────────────────────────────────────────────────────
  security.polkit.enable = true; # required for GUI apps that need elevated permissions
  security.rtkit.enable = true;  # real-time scheduling for PipeWire

  # This value determines the NixOS release from which the default settings
  # for stateful data were taken. Don't change it after initial install.
  system.stateVersion = "25.05";
}
