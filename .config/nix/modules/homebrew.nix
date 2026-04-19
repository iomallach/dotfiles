{
  flake.modules.darwin.homebrew = {
    homebrew = {
      enable = false;

      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "none";
      };

      taps = [
        "sst/tap"
      ];
    };
  };
}
