{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf
  (lib.elem config.desktop.profile [
    "hyprland"
    "hyprland-quickshell"
  ])
  {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      hyprpaper
      hyprlock
      hyprpwcenter
      hyprcursor
      wlogout
    ];
  }
