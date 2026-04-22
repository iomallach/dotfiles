{
  flake.modules.homeManager.ai =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        opencode
        claude-code
        crush
        copilot-language-server
        pi-coding-agent
      ];
    };

  flake.configSources.opencode.source = "opencode";
}
