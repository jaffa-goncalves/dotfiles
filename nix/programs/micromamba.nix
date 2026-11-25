{ pkgs, lib, config, ... }:

let
  rootPrefix = "${config.home.homeDirectory}/.mamba";
in
{
  home.packages = [
    pkgs.micromamba
  ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = rootPrefix;
  };

  home.activation.micromambaInit =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${rootPrefix}"
    '';

  programs.zsh.initContent = ''
    export MAMBA_EXE="${pkgs.micromamba}/bin/micromamba"

    if [[ -z "''${DISABLE_MAMBA:-}" ]]; then
      eval "$("$MAMBA_EXE" shell hook --shell zsh |
        sed "s|/nix/store/[^\" ]*/bin/\.mamba-wrapped|$MAMBA_EXE|g")"
    fi
  '';

  home.file.".mambarc".text = ''
  changeps1: false
'';
}