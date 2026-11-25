
{ pkgs, ... }:

let
  # Build Open WebUI's frontend using Node.js 22
  frontend = pkgs.open-webui.frontend.overrideAttrs (old: {
    nativeBuildInputs =
      (builtins.filter
        (pkg: !(pkgs.lib.hasPrefix "nodejs-" (pkg.name or "")))
        (old.nativeBuildInputs or []))
      ++ [ pkgs.nodejs_22 ];
  });

  # Point Open WebUI at the rebuilt frontend
  openWebUI = pkgs.open-webui.overrideAttrs (old: {
    makeWrapperArgs = [
      "--set"
      "FRONTEND_BUILD_DIR"
      "${frontend}/share/open-webui"
    ];

    passthru = (old.passthru or {}) // {
      inherit frontend;
    };
  });

in
{
  home.packages = [
    openWebUI
  ];

  launchd.agents.open-webui = {
    enable = true;

    config = {
      WorkingDirectory = "/Users/jaffa/.local/share/open-webui";
      ProgramArguments = [
        "${openWebUI}/bin/open-webui"
        "serve"
        "--host"
        "127.0.0.1"
        "--port"
        "8080"
      ];

      RunAtLoad = true;
      KeepAlive = true;

      EnvironmentVariables = {
        HOME = "/Users/jaffa";
        DATA_DIR = "/Users/jaffa/.local/share/open-webui";
        WEBUI_SECRET_KEY_LENGTH = "32";
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        SCARF_NO_ANALYTICS = "True";
        DO_NOT_TRACK = "True";
        ANONYMIZED_TELEMETRY = "False";
      };

      StandardOutPath = "/Users/jaffa/Library/Logs/open-webui.log";
      StandardErrorPath = "/Users/jaffa/Library/Logs/open-webui.err.log";
    };
  };
}
