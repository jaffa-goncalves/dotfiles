{ pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."github.com" = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "~/.ssh/id_ed25519";
      AddKeysToAgent = "yes";
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      UseKeychain = "yes";
    };
  };
}