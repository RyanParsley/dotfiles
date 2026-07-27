{
  description = "Ryan's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, ... }: {
    darwinConfigurations."MACX-410869RX" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/configuration.nix ];
    };
  };
}
