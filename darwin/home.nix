{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # ── Forgejo / Codeberg ────────────────────────────────────────────────────
    forgejo-cli
    woodpecker-cli

    # ── Cloudflare ────────────────────────────────────────────────────────────
    wrangler
    cloudflared

    # ── Backup ────────────────────────────────────────────────────────────────
    restic
  ];

  homebrew.casks = [
    "espanso"
    "localsend"
  ];
}
