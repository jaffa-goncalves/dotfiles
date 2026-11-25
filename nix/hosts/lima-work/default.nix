{
  hostname = "lima-work";
  platform = "aarch64-linux";
  backend = "home-manager";

  users = [
    ../../homes/jaffa
  ];

  primaryUser = "jaffa";

  modules = [];
}