{
  flake.modules.homeManager.ai =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        opencode
        claude-code
        crush
        copilot-language-server
      ];
    };

  flake.configSources.opencode.source = "opencode";
}
