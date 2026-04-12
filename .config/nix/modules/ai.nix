{
  flake.modules.ai =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        opencode
        claude-code
        crush
      ];
    };

  flake.configSources.opencode.source = "opencode";
}
