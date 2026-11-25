{ ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "catppuccin_transparent";
    };

    themes.catppuccin_transparent = {
      inherits = "catppuccin_mocha";

      "ui.background" = {
        fg = "text";
      };
    };
  };
}