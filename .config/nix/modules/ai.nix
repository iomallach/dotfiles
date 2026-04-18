{
  flake.modules.ai =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        opencode
        claude-code
        crush
        copilot-language-server
      ];
    };

  flake.configSources.opencode.source = "opencode";
}
