
{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.ollama
  ];

  launchd.user.agents.ollama = {
    serviceConfig = {
      Label = "org.nix-darwin.ollama";

      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];

      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";

      EnvironmentVariables = {
        HOME = "/Users/jaffa";
        OLLAMA_HOST = "127.0.0.1:11434";
        OLLAMA_MODELS = "/Users/jaffa/.ollama/models";
      };

      StandardOutPath = "/Users/jaffa/Library/Logs/ollama.log";
      StandardErrorPath = "/Users/jaffa/Library/Logs/ollama.err.log";
    };
  };
}
