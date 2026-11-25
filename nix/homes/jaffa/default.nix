{
  identity = import ./identity.nix;
  profiles = import ./profiles;

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