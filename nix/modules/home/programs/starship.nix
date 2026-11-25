{ lib, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = lib.recursiveUpdate
      (builtins.fromTOML (
        builtins.readFile ../../../../starship/starship.toml
      ))
      {
        conda = {
          disabled = false;
          ignore_base = false;
          symbol = "🐍 ";
          format = "via [$symbol$environment]($style) ";
          style = "bold green";
        };
      };
  };
}