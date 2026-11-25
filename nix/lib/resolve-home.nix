{ lib, system, path, profile }:

let
  manifest = import path;
  identity = manifest.identity;

  platform =
    if lib.hasSuffix "-darwin" system then "darwin"
    else if lib.hasSuffix "-linux" system then "linux"
    else throw "Unsupported platform: ${system}";

  username = identity.username;

  platformConfig = manifest.${platform} or {};

  homeDirectory = platformConfig.homeDirectory or (
    if platform == "darwin"
    then "/Users/${username}"
    else "/home/${username}"
  );

  profileCollections = manifest.profiles or {};

  selectedProfiles =
    profileCollections.${profile} or (
      throw "Unknown profile '${profile}' for user '${username}'"
    );

  programs = import ./resolve-programs.nix {
    inherit lib system;

    profiles = lib.unique (
      selectedProfiles
      ++ (platformConfig.profiles or [])
    );
  };

in
{
  inherit identity username homeDirectory;

  homeModules = lib.unique (
    [
      {
        home = {
          inherit username homeDirectory;
        };
      }
    ]
    ++ (manifest.home or [])
    ++ (platformConfig.home or [])
    ++ programs.homeModules
  );

  systemModules = programs.systemModules;

  userSystemModules = platformConfig.system or [];
}