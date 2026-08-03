{
  description = "Ryan's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    pi-nix.url = "github:lukasl-dev/pi.nix";
    pi-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, pi-nix, ... }: {
    darwinConfigurations."Daddio-M4" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/core.nix ./darwin/home.nix pi-nix.nixosModules.coding-agent ];
      specialArgs = { inherit inputs; };
    };
    darwinConfigurations."MACX-410869RX" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/core.nix ./darwin/work.nix pi-nix.nixosModules.coding-agent ];
      specialArgs = { inherit inputs; };
    };
  };
}
