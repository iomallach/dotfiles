{
  flake.modules.work = {
    homebrew = {
      taps = [
        "getyourguide/dev"
      ];

      brews = [
        "postgresql@14"
        "zig"
        "awscli" # move to nix
        # gyg
        "dev-bundle"
        "dev-scripts"
        "gdbc"
      ];

      casks = [
        "dbeaver-community"
      ];
    };
  };
}
