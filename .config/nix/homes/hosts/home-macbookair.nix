{ config, ... }:

{
  imports = [
    ../../systems/darwin/modules/aerospace.nix
    ../../systems/darwin/modules/borders.nix
    ../../modules/common/alacritty.nix
    ../../modules/common/helix.nix
    ../../modules/home/kanata.nix
    ../../modules/common/tmux.nix
    ../../modules/home/doom-emacs.nix
    ../../modules/common/kitty.nix
    ../../modules/home/karabiner.nix
    ../../modules/common/neovide.nix
    ../../modules/home/nvim.nix
    ../../modules/home/opencode.nix
    ../../modules/home/scripts.nix
    ../../modules/home/wezterm.nix
    ../../modules/home/zed.nix
    ../../modules/home/vscode.nix
    ../../modules/home/zellij.nix
    ../../modules/common/zsh.nix
    ../../modules/common/ghostty.nix
  ];

  home.username = config.system.primaryUser;
  home.homeDirectory = "/Users/${config.system.primaryUser}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
