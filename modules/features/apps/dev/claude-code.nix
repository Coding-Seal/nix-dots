_: {
  # Personal dev tool — opted into via personalHmModules, so it's absent on
  # the work laptop (scadrial) without any per-host conditional.
  config.personalHmModules = [
    ({ pkgs, ... }: {
      home.packages = with pkgs; [
        claude-code

        # Sandbox dependencies — https://code.claude.com/docs/en/sandboxing
        # nixpkgs' claude-code wrapper already prepends both to PATH, so these
        # are declared for the case where claude isn't launched through that
        # wrapper (its own native self-updater drops a binary in ~/.local/bin).
        bubblewrap # filesystem isolation via unprivileged user namespaces
        socat # relays sandboxed traffic to the network proxy

        # Interpreters that plugin hooks and skills shell out to. Nothing else
        # here pulls either in — without node, every ponytail UserPromptSubmit
        # hook fails with "node: command not found".
        nodejs
        python3
      ];
    })
  ];
}
