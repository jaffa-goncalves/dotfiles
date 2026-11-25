{ ... }:

{
  imports = [
    ./packages.nix
    ./programs
    ./open-webui.nix
    ./environment.nix
  ];

  home = {
    username = "jaffa";
    homeDirectory = "/Users/jaffa";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
  
}