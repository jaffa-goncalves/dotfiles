{ lib, system, profiles }:

let
  platform =
    if lib.hasSuffix "-darwin" system then "darwin"
    else if lib.hasSuffix "-linux" system then "linux"
    else throw "Unsupported platform: ${system}";

  # Resolve shared and platform-specific profile contents.
  resolveProfile = profile:
    let
      platformProfile =
        (builtins.dirOf profile)
        + "/${platform}/${builtins.baseNameOf profile}";
    in
      (import profile).programs
      ++ lib.optionals
        (builtins.pathExists platformProfile)
        ((import platformProfile).programs);

  # Collect and deduplicate all selected programs.
  programPaths = lib.unique (
    lib.concatMap resolveProfile profiles
  );

  # Resolve each program's platform-specific implementation.
  resolveProgram = path:
    let
      program = import path;

      platformHome =
        if platform == "darwin"
        then (program.macos or {}).home or null
        else (program.linux or {}).home or null;

      homeModules = lib.filter (x: x != null) [
        (program.home or null)
        platformHome
      ];

      systemModule =
        if platform == "darwin"
        then program.darwin or null
        else program.nixos or null;

      systemModules = lib.optional
        (systemModule != null)
        systemModule;

    in
      if homeModules == [] && systemModules == []
      then throw "Program ${toString path} does not support ${system}"
      else {
        home = homeModules;
        system = systemModules;
      };

  resolved = map resolveProgram programPaths;

in
{
  homeModules = lib.unique (
    lib.concatMap (p: p.home) resolved
  );

  systemModules = lib.unique (
    lib.concatMap (p: p.system) resolved
  );
}