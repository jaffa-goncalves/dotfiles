{
  description = "Declarative personal computing infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:ak2k/hermes-agent/fix/nix-pnpm-deps-darwin-hash";
    };
  };

  outputs = inputs@{ ... }:

    let
      mkHost = import ./lib/mk-host.nix;
    in
    {
      # Darwin hosts.
      darwinConfigurations = {
        macbook = mkHost {
          inherit inputs;
          host = import ./hosts/macbook;
        };
      };

      # Conventional Linux hosts.
      homeConfigurations = {
        lima-work = mkHost {
          inherit inputs;
          host = import ./hosts/lima-work;
        };
      };

      # Future NixOS hosts.
      nixosConfigurations = {};
    };
}