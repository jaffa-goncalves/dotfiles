{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  home = {
    sessionVariables = {
      LANG = "en_US.UTF-8";
      EDITOR = "hx";
      VISUAL = "hx";
    };

    sessionPath = [
      "${home}/.local/bin"
      "${home}/local/bin"
      "${home}/.cargo/bin"
    ];
  };
}