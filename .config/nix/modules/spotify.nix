{ inputs, ... }:
{
  flake.modules.spotify = {
    package =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          spotify
        ];
      };

    spicetify =
      { pkgs, ... }:
      {
        programs.spicetify =
          let
            spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
          in
          {
            enable = true;
            theme = spicePkgs.themes.catppuccin;
            colorScheme = "macchiato";
          };
      };
  };
}
