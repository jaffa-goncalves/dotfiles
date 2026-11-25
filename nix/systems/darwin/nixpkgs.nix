{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "open-webui"
      "vscode"
      "vscode-extension-MS-python-vscode-pylance"
    ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}