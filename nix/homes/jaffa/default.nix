{
  identity = import ./identity.nix;
  profiles = import ./profiles.nix;

  home = [
    ./environment.nix
    ./settings.nix
  ];

  darwin = {
    system = [
      ./darwin/system.nix
    ];
  };
}