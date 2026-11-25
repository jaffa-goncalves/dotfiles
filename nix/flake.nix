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

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    hermes-agent = {
      url = "github:ak2k/hermes-agent/fix/nix-pnpm-deps-darwin-hash";
    };
  };

  outputs =
    inputs@{
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    {
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./hosts/macbook
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
    };
}