# Disk layout for the laptop.
#
# Layout:
#   /dev/nvme0n1p1   512 MB   FAT32    /boot  (EFI system partition)
#   /dev/nvme0n1p2   rest     Btrfs           (root volume)
#     subvol @           →  /
#     subvol @home       →  /home
#     subvol @nix        →  /nix
#     subvol @snapshots  →  /.snapshots
#     subvol @var-log    →  /var/log
#
# TODO: verify the disk name with `lsblk` on the laptop.
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
              type = "btrfs";
              extraArgs = [
                "-L"
                "nixos"
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
}
