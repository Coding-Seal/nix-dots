# Common workflows for this flake. Run `just` (or `just --list`) to see all recipes.
# Requires the devenv shell (`direnv allow` / `devenv shell`) for just, nvd, fd, etc.

default:
    @just --list

# Apply system + home config for HOST (defaults to this machine's hostname)
switch host=`hostname`:
    sudo nixos-rebuild switch --flake .#{{ host }}

# Dry-run a rebuild without applying it -- check for errors first
dry host=`hostname`:
    sudo nixos-rebuild dry-activate --flake .#{{ host }}

# Roll back to the previous generation
rollback:
    sudo nixos-rebuild switch --rollback

# Build HOST without switching, then show what would change vs. the running system
diff host=`hostname`:
    nix build .#nixosConfigurations.{{ host }}.config.system.build.toplevel -o result
    nvd diff /run/current-system result

# Update all flake inputs (review + commit flake.lock after)
update:
    nix flake update

# Update a single flake input
update-input name:
    nix flake update {{ name }}

# Format all .nix files
fmt:
    fd -e nix -x nixfmt

# Run every pre-commit hook (deadnix, nixfmt, statix) against the whole repo
check:
    prek run --all-files

# Garbage-collect old generations
gc:
    sudo nix-collect-garbage -d
