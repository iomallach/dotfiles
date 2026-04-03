{ config, ... }:

{
  imports = [
    ../modules/darwin/aerospace.nix
    ../modules/darwin/borders.nix
    ../modules/alacritty.nix
    ../modules/helix.nix
    ../home-manager/kanata.nix
    ../modules/tmux.nix
    ../home-manager/doom-emacs.nix
    ../modules/kitty.nix
    ../home-manager/karabiner.nix
    ../modules/neovide.nix
    ../home-manager/nvim.nix
    ../home-manager/scripts.nix
    ../home-manager/wezterm.nix
    ../home-manager/zed.nix
    ../home-manager/vscode.nix
    ../home-manager/zellij.nix
    ../modules/zsh.nix
    ../modules/ghostty.nix
  ];

  home.username = config.system.primaryUser;
  home.homeDirectory = "/Users/${config.system.primaryUser}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
