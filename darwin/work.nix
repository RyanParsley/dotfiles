{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.azure-cli
    pkgs.google-cloud-sdk
  ];

  # Reverse proxy for spin-up worktree routing (e.g. loads_ui, jbi-prototype).
  # Runs as a per-user launchd agent. Note: nix-darwin does not reconcile
  # ~/Library/LaunchAgents on activation (only /Library/LaunchAgents), so
  # this declaration won't remove a stale plist on its own if ever changed --
  # `launchctl unload ~/Library/LaunchAgents/org.nixos.caddy.plist` by hand
  # first if the config here diverges from what's currently loaded.
  launchd.user.agents.caddy = {
    serviceConfig = {
      ProgramArguments = [
        "/run/current-system/sw/bin/caddy"
        "run"
        "--config"
        "/usr/local/etc/caddy/Caddyfile"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/caddy.log";
      StandardErrorPath = "/tmp/caddy.log";
    };
  };
}
