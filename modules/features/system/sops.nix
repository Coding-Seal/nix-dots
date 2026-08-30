{ inputs, ... }:
{
  # Module wiring only — no secrets defined yet. Key is a dedicated age key
  # (not derived from the host's SSH key) at the sops-nix convention path,
  # readable by root during activation regardless of $HOME mount state:
  #   sudo mkdir -p /var/lib/sops-nix
  #   sudo age-keygen -o /var/lib/sops-nix/key.txt
  #   age-keygen -y /var/lib/sops-nix/key.txt   # public key, goes in .sops.yaml
  # Then create .sops.yaml and add entries under `sops.secrets`.
  config.nixosModules = [
    inputs.sops-nix.nixosModules.sops
    ({ pkgs, ... }: {
      environment.systemPackages = [
        pkgs.sops
        pkgs.age
      ];
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    })
  ];
}
