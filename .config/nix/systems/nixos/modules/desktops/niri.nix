{ lib, pkgs, ... }:
{
  environment.systemPackages = lib.optionals (pkgs ? niri) [
    pkgs.niri
    pkgs.wlogout
    pkgs.hyprlock
    pkgs.hyprpaper
  ];
}
