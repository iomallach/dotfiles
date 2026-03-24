{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf
  (lib.elem config.desktop.profile [
    "hyprland-quickshell"
    "niri-quickshell"
  ])
  {
    environment.systemPackages = lib.optionals (pkgs ? quickshell) [
      pkgs.quickshell
    ];
  }
