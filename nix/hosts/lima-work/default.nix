{
  hostname = "lima-work";
  platform = "aarch64-linux";
  backend = "home-manager";

  users = [
    {
      home = ../../homes/jaffa;
      profile = "work";
    }
  ];

  primaryUser = "jaffa";
  modules = [];
}