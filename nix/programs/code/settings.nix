{
  programs.vscode.profiles.default.userSettings = {
    # Appearance
    "workbench.colorTheme" = "Catppuccin Mocha";
    "workbench.iconTheme" = "catppuccin-mocha";

    # Editor
    "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
    "editor.fontSize" = 14;
    "editor.fontLigatures" = true;
    "editor.lineHeight" = 22;

    # Integrated terminal
    "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
    "terminal.integrated.fontSize" = 14;
    "terminal.integrated.lineHeight" = 1.1;

    # Nix language server
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nixd";

    # Extension lifecycle
    "extensions.autoUpdate" = false;
    "extensions.autoCheckUpdates" = false;
  };
}