{ config, ... }:
{
  # Btrfs snapshots of the root subvolume. Every host's disko.nix already
  # carves out a dedicated @snapshots subvolume mounted at /.snapshots,
  # which is exactly what snapper's "root" config expects to find.
  config.nixosModules = [
    {
      services.snapper = {
        snapshotInterval = "hourly";
        cleanupInterval = "1d";
        persistentTimer = true;
        configs.root = {
          SUBVOLUME = "/";
          ALLOW_USERS = [ config.username ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 5;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 4;
          TIMELINE_LIMIT_MONTHLY = 3;
          TIMELINE_LIMIT_YEARLY = 0;
        };
      };
    }
  ];
}
