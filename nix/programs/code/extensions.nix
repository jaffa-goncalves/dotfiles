{ pkgs, ... }:

{
  programs.vscode.profiles.default.extensions =
    with pkgs.vscode-extensions; [
      # Appearance
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons

      # Nix
      jnoortheen.nix-ide

      # Python
      ms-python.python
      ms-python.debugpy
      ms-python.vscode-pylance
      ms-python.vscode-python-envs

      # Rust
      rust-lang.rust-analyzer

      # Build systems
      ms-vscode.makefile-tools

      # Configuration languages
      redhat.vscode-yaml
      tamasfe.even-better-toml

      # Markdown and knowledge management
      davidanson.vscode-markdownlint
      foam.foam-vscode
      shd101wyy.markdown-preview-enhanced
      yzhang.markdown-all-in-one

      # Documents
      chrischinchilla.vscode-pandoc

      # Web development

      # Writing
      streetsidesoftware.code-spell-checker
    ];
}