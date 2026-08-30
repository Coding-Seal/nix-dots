# Disk layout for the work laptop.
#
# Layout:
#   <disk>1   512 MB   FAT32    /boot  (EFI system partition)
#   <disk>2   rest     LUKS2 → Btrfs   (root volume, encrypted)
#     subvol @           →  /
#     subvol @home       →  /home
#     subvol @nix        →  /nix
#     subvol @snapshots  →  /.snapshots
#     subvol @var-log    →  /var/log
#
# The root partition is LUKS2-encrypted. `disko --mode disko` prompts for a
# passphrase interactively when formatting; the same passphrase is then
# prompted at every boot to unlock before the bootloader hands off — no
# keyfile, matching typical laptop full-disk-encryption UX.
#
# TODO: verify the disk name with `lsblk` on the work laptop.
#   NVMe drives  → /dev/nvme0n1
#   SATA/USB SSD → /dev/sda
_:

let
  disk = "/dev/nvme0n1";

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

          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "scadrial-crypted";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "scadrial"
                ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = btrfsOpts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = btrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsOpts;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = btrfsOpts;
                  };
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
  };
}
