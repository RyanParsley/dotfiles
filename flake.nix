{
  description = "Ryan's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    pi-nix.url = "github:lukasl-dev/pi.nix";
    pi-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, pi-nix, ... }:
    let
      # pi.nix only publishes its coding-agent module under `nixosModules`
      # and `homeModules` flake outputs. Newer nixpkgs/nix-darwin infers a
      # module's `_class` from that conventional output attribute name and
      # rejects `nixosModules.*` inside a `darwinSystem` evaluation, even
      # though the module itself has nothing NixOS-specific. Import the
      # module file directly (bypassing the tagged flake output) so it's
      # evaluated untagged and accepted under the darwin module class.
      pi-coding-agent-module = import "${pi-nix}/coding-agent/module.nix" {
        self = pi-nix;
        inherit (pi-nix.inputs) jail-nix;
      };
    in {
    darwinConfigurations."Daddio-M4" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/core.nix ./darwin/home.nix pi-coding-agent-module ];
      specialArgs = { inherit inputs; };
    };
    darwinConfigurations."MACX-410869RX" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/core.nix ./darwin/work.nix pi-coding-agent-module ];
      specialArgs = { inherit inputs; };
    };
  };
}
