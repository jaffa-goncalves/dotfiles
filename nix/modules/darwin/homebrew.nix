{ ... }:

{
  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  homebrew = {
    enable = true;

    brews = [

    ];

    casks = [
      # Browsers
      "vivaldi"
      "chromium"

      # Development
      "wezterm"
      "docker-desktop"

      # Window management and desktop
      "aerospace"
      "raycast"
      "alcove"
      "aerial"

      # AI
      "chatgpt"
      "ollama"
      "open-webui"
      "anythingllm"

      # Communication
      "discord"

      # Media and utilities
      "iina"
      "crossover"
      "lexicon-dj"
      "ea"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
