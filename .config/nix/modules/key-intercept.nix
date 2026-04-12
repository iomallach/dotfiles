{
  flake.modules.key-intercept =
    { pkgs, ... }:
    {
      darwin = {
        environment.systemPackages = with pkgs; [
          kanata
          kanata-tray.default
        ];
        homebrew = {
          casks = [
            "karabiner-elements"
          ];
        };
      };
    };

  flake.configSources.karabiner = {
    source = "karabiner";
    target = "karabiner";
    # darwin-only behavior is preserved by host/module selection elsewhere.
  };

  flake.configSources.kanata.source = "kanata";
}
