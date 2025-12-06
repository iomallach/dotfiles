{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "iomallach";
  home.homeDirectory = "/home/iomallach";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # Configure Spicetify with Catppuccin
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "macchiato";
    };
}
