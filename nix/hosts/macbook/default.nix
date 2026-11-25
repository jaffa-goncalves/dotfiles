{
  hostname = "Jaffa-Saahs-MacBook-Pro";
  platform = "aarch64-darwin";

  users = [
    {
      home = ../../homes/jaffa;
      profile = "personal";
    }
  ];

  primaryUser = "jaffa";
  stateVersion = 6;

  modules = [];
}