{ inputs, host }:

let
  lib = inputs.nixpkgs.lib;
  system = host.platform;

  isDarwin = lib.hasSuffix "-darwin" system;
  isLinux = lib.hasSuffix "-linux" system;

  backend = host.backend or (
    if isDarwin then "darwin"
    else if isLinux then "home-manager"
    else throw "Unsupported platform: ${system}"
  );

  # Resolve user manifests.
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

  # Collect program-level system modules.
  programSystemModules = lib.unique (
    lib.concatMap
      (user: user.systemModules)
      resolvedHomes
  );

  # Integrated Home Manager configuration.
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

  # Shared system configuration.
  commonModule = {
    networking.hostName = host.hostname;
    nixpkgs.hostPlatform = system;
  };

  # Darwin-specific system configuration.
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

  # Standalone Home Manager configuration.
  standaloneHomeModules =
    primaryUser.homeModules
    ++ (host.modules or []);

  standaloneHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
    };

    extraSpecialArgs = {
      inherit inputs;
      identity = primaryUser.identity;
    };

    modules = standaloneHomeModules;
  };

in

# Host validation.
assert lib.assertMsg
  (builtins.length resolvedHomes == builtins.length (builtins.attrNames users))
  "Duplicate usernames in host ${host.hostname}";

assert lib.assertMsg
  (builtins.hasAttr host.primaryUser users)
  "Primary user is not declared in host ${host.hostname}";

# Backend dispatch.
if backend == "darwin" then

  assert lib.assertMsg isDarwin
    "Darwin backend requires a Darwin platform";

  inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = darwinModules;
  }

else if backend == "home-manager" then

  assert lib.assertMsg isLinux
    "Standalone Home Manager backend requires a Linux platform in this configuration";

  assert lib.assertMsg
    (builtins.length resolvedHomes == 1)
    "Standalone Home Manager requires exactly one user";

  assert lib.assertMsg
    (programSystemModules == [])
    "Standalone Home Manager cannot apply program system modules";

  assert lib.assertMsg
    (primaryUser.userSystemModules == [])
    "Standalone Home Manager cannot apply user system modules";

  standaloneHome

else if backend == "nixos" then

  throw "NixOS host composition is not implemented yet"

else

  throw "Unsupported backend: ${backend}"