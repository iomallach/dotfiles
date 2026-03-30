{ config, ... }:

{
  imports = [
    ../modules/zsh.nix
  ];

  home.username = config.system.primaryUser;
  home.homeDirectory = "/Users/${config.system.primaryUser}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
