{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Jaffa-Saah Goncalves";
        email = "jaffagoncalves@gmail.com";
      };

      core = {
        editor = "hx";
        autocrlf = "input";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      push.autoSetupRemote = true;
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";
    };
  };
}