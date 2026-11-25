{ pkgs, config, ... }:

let
  openWebUI = import ./package.nix { inherit pkgs; };
  home = config.home.homeDirectory;
  dataDir = "${home}/.local/share/open-webui";
in
{
  launchd.agents.open-webui = {
    enable = true;

    config = {
      WorkingDirectory = dataDir;

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
        HOME = home;
        DATA_DIR = dataDir;
        WEBUI_SECRET_KEY_LENGTH = "32";
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        SCARF_NO_ANALYTICS = "True";
        DO_NOT_TRACK = "True";
        ANONYMIZED_TELEMETRY = "False";
      };

      StandardOutPath = "${home}/Library/Logs/open-webui.log";
      StandardErrorPath = "${home}/Library/Logs/open-webui.err.log";
    };
  };
}
