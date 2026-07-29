{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.forgejo-cli
    pkgs.woodpecker-cli

    pkgs.wrangler
    pkgs.cloudflared

    pkgs.restic
  ];

  homebrew.casks = [
    "espanso"
    "localsend"
  ];
}
