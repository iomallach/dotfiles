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

  programs.git = {
    enable = true;
    settings = {
      user.name = "Alexander Butenko";
      user.email = "a.butenko.o@gmail.com";
      merge.tool = "codediff";
      "mergetool \"codediff\"".cmd = "nvim \"$MERGED\" -c \"CodeDiff merge \\\"$MERGED\\\"\"";
      diff.tool = "codediff";
      "difftool \"codediff\"".cmd = "nvim \"$LOCAL\" \"$REMOTE\" +\"CodeDiff file $LOCAL $REMOTE\"";
      init.defaultBranch = "main";
    };
  };

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    ../modules/zsh.nix
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
