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
    ../../modules/common/alacritty.nix
    ../../modules/common/helix.nix
    ../../modules/common/tmux.nix
    ../../modules/home/doom-emacs.nix
    ../../modules/common/kitty.nix
    ../../modules/common/neovide.nix
    ../../modules/home/hypr.nix
    ../../modules/home/niri.nix
    ../../modules/home/nvim.nix
    ../../modules/home/rofi.nix
    ../../modules/home/scripts.nix
    ../../modules/home/waybar.nix
    ../../modules/home/wezterm.nix
    ../../modules/home/wlogout.nix
    ../../modules/home/zed.nix
    ../../modules/home/vscode.nix
    ../../modules/home/zellij.nix
    inputs.spicetify-nix.homeManagerModules.default
    ../../modules/common/zsh.nix
    ../../modules/common/ghostty.nix
    # ../../modules/home/kanata.nix
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
