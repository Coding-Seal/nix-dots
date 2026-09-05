# TODO

Ideas and open items for future sessions. Not a changelog — remove entries once done.

## Next up

-

## Ideas

- Hermes agent — look into what it'd take to set up/integrate (see `.claude/worktrees/hermes-agent-research`)
- Investigate boot/login startup time, see if anything's worth trimming
- Custom Claude Code skills for this repo (e.g. rebuild-and-check, new-feature-module scaffold)
- More thorough niri config: proper multi-monitor layout, per-workspace assignment, window rules beyond the current zoom float-only rule
- KDE Connect + Noctalia plugin (the `icefish/phone-connect` plugin already enabled in noctalia.nix — check if it needs KDE Connect installed/configured on the NixOS side too)

## Known issues

- Noctalia config isn't fully declarative — some settings living in `~/.local/state/noctalia/settings.toml` (GUI-set runtime overrides) aren't mirrored into `programs.noctalia.settings` in `modules/features/desktop/noctalia.nix`, so a fresh install won't reproduce them. Port the missing ones over.
