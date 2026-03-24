{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (lib.elem config.desktop.profile [ "hyprland" ]) {
  environment.systemPackages = [
    pkgs.waybar
  ];
}
