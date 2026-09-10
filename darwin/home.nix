{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.forgejo-cli
    pkgs.woodpecker-cli

    pkgs.wrangler
    pkgs.cloudflared

    pkgs.restic

    # Nix language tooling
    pkgs.nixd
    pkgs.nixfmt
  ];

  homebrew.casks = [
    "espanso"
    "localsend"
  ];
}
