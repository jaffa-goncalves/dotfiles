{ pkgs, config, lib, ... }:

let
  openWebUI = import ./package.nix { inherit pkgs; };
  dataDir = "${config.home.homeDirectory}/.local/share/open-webui";
in
{
  home.packages = [ openWebUI ];

  home.activation.openWebUIDataDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${dataDir}"
    '';
}
