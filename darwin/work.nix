{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # ── Cloud ─────────────────────────────────────────────────────────────────
    azure-cli
    google-cloud-sdk
  ];
}
