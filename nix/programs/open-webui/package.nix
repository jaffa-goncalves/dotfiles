{ pkgs }:

let
  frontend = pkgs.open-webui.frontend.overrideAttrs (old: {
    nativeBuildInputs =
      (builtins.filter
        (pkg: !(pkgs.lib.hasPrefix "nodejs-" (pkg.name or "")))
        (old.nativeBuildInputs or []))
      ++ [ pkgs.nodejs_22 ];
  });
in
pkgs.open-webui.overrideAttrs (old: {
  makeWrapperArgs = [
    "--set"
    "FRONTEND_BUILD_DIR"
    "${frontend}/share/open-webui"
  ];

  passthru = (old.passthru or {}) // {
    inherit frontend;
  };
})
