{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.azure-cli
    pkgs.google-cloud-sdk
  ];
}
