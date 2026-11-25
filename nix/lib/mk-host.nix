{ inputs, host }:

let
  lib = inputs.nixpkgs.lib;
  system = host.platform;

  isDarwin = lib.hasSuffix "-darwin" system;
  isLinux = lib.hasSuffix "-linux" system;

  resolvedHomes = map
    (path: import ./resolve-home.nix {
      inherit lib system path;
    })
    host.users;

  users = lib.listToAttrs (
    map (user: {
      name = user.username;
      value = user;
    }) resolvedHomes
  );

  primaryUser = users.${host.primaryUser};

  programSystemModules = lib.unique (
    lib.concatMap
      (user: user.systemModules)
      resolvedHomes
  );

  homeManagerModule = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "pre-nix";

      extraSpecialArgs = {
        inherit inputs;
      };

      users = lib.mapAttrs (_: user: {
        imports = user.homeModules;

        _module.args.identity = user.identity;
      }) users;
    };
  };

  commonModule = {
    networking.hostName = host.hostname;
    nixpkgs.hostPlatform = system;
  };

  darwinModule = {
    system.primaryUser = host.primaryUser;
    system.stateVersion = host.stateVersion;

    users.users = lib.mapAttrs (_: user: {
      home = user.homeDirectory;
    }) users;
  };

  darwinModules = [
    ../systems/darwin
    inputs.home-manager.darwinModules.home-manager
    commonModule
    darwinModule
    homeManagerModule
  ]
  ++ programSystemModules
  ++ primaryUser.userSystemModules
  ++ (host.modules or []);

in

assert lib.assertMsg
  (builtins.length resolvedHomes == builtins.length (builtins.attrNames users))
  "Duplicate usernames in host ${host.hostname}";

assert lib.assertMsg
  (builtins.hasAttr host.primaryUser users)
  "Primary user is not declared in host ${host.hostname}";

if isDarwin then
  inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = darwinModules;
  }
else if isLinux then
  throw "NixOS host composition is not implemented yet"
else
  throw "Unsupported platform: ${system}"
