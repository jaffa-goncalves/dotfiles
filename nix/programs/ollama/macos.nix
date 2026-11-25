{ pkgs, config, ... }:

{
  home.packages = [ pkgs.ollama ];

  launchd.agents.ollama = {
    enable = true;

    config = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];

      RunAtLoad = true;
      KeepAlive = true;

      EnvironmentVariables = {
        OLLAMA_HOST = "127.0.0.1:11434";
      };

      StandardOutPath =
        "${config.home.homeDirectory}/Library/Logs/ollama.log";

      StandardErrorPath =
        "${config.home.homeDirectory}/Library/Logs/ollama.err.log";
    };
  };
}