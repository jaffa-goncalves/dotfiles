
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Navigation and search
    ripgrep
    fd
    eza
    bat
    jq
    yq-go

    # Development
    uv
    micromamba
    rustup
    fnm
    deno
    nodejs
    wrangler

    # Documents and media
    cspell
    pandoc
    yt-dlp
    ffmpeg

    # Utilities
    btop
    tree
    just
  ];
}
