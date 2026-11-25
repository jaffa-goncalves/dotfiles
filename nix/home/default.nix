
{ ... }:

{
  imports = [
    ./packages.nix
    ./programs/git.nix
  ];

  home.stateVersion = "25.11";
}
