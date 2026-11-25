{ inputs, ... }:

{
  # Machine identity
  networking.hostName = "Jaffa-Saahs-MacBook-Pro";

  # Primary macOS user
  system.primaryUser = "jaffa";

  users.users.jaffa = {
    home = "/Users/jaffa";
  };

  # Import system configuration modules
  imports = [
    ../../modules/darwin
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager = {
    backupFileExtension = "pre-nix";

    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs;
    };

    users.jaffa = import ../../modules/home;
  };

  # Homebrew installation management
  nix-homebrew = {
    enable = false;
    user = "jaffa";
    autoMigrate = true;
  };

  # nix-darwin compatibility version
  system.stateVersion = 6;
}