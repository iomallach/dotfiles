{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf
  (lib.elem config.desktop.profile [
    "niri"
    "niri-quickshell"
  ])
  {
    environment.systemPackages = lib.optionals (pkgs ? niri) [
      pkgs.niri
    ];
  }
