# Declarative disk partitioning via disko.
#
# Layout:
#   /dev/vda1   512 MB   FAT32    /boot  (EFI system partition)
#   /dev/vda2   rest     Btrfs           (root volume)
#     subvol @           →  /            (OS root)
#     subvol @home       →  /home        (user data — survives OS reinstall)
#     subvol @nix        →  /nix         (Nix store — large, benefits most from compression)
#     subvol @snapshots  →  /.snapshots  (snapshot destination for snapper/btrbk)
#     subvol @var-log    →  /var/log     (logs — excluded from root snapshots)
#
# All Btrfs subvolumes use zstd compression, which typically saves 30-40%
# on the Nix store and has near-zero CPU cost.
#
# HOW TO USE:
#   On a fresh VM, run this BEFORE nixos-install to partition the disk:
#     sudo nix run github:nix-community/disko -- --mode disko /path/to/this/file.nix
#
#   On an already-installed system, this file just declares the mounts —
#   disko's NixOS module generates fileSystems entries from it automatically.
#   Remove any duplicate fileSystems entries from hardware-configuration.nix.
_:

let
  # TODO: change this if your VM disk is /dev/sda (VirtualBox/VMware)
  # Run `lsblk` on the VM to see your disk name
  disk = "/dev/vda";

  btrfsOpts = [
    "compress=zstd"
    "noatime"
    "space_cache=v2"
  ];
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {

          # EFI System Partition — bootloader lives here
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # Btrfs root volume — contains all subvolumes below
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-L"
                "nixos"
              ]; # label the volume "nixos"
              subvolumes = {

                # OS root — gets snapshotted before each nixos-rebuild
                "@" = {
                  mountpoint = "/";
                  mountOptions = btrfsOpts;
                };

                # User home — separate so reinstalling the OS keeps your data
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = btrfsOpts;
                };

                # Nix store — largest subvolume, kept separate so snapshots of @
                # don't include all of /nix (it's reproducible anyway)
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOpts;
                };

                # Snapshot destination (used by snapper or btrbk if you add them)
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = btrfsOpts;
                };

                # System logs — excluded from root snapshots so rollbacks
                # don't lose recent log history
                "@var-log" = {
                  mountpoint = "/var/log";
                  mountOptions = btrfsOpts;
                };

              };
            };
          };

        };
      };
    };
  };
}
