{ lib, pkgs, ... }:
{
  environment.systemPackages = lib.optionals (pkgs ? niri) [
    pkgs.niri
  ];
}
