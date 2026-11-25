
{ pkgs, hermes-agent, ... }:

{
  # macOS preferences
  system.defaults = {
    dock.autohide = true;

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
    };

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
    };
  };

  # Enable Nix flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # System-wide packages
  environment.systemPackages = with pkgs; [
    lima
    ollama
    #hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
