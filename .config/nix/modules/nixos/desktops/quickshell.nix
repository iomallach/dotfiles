{ lib, pkgs, ... }:
{
  environment.systemPackages = lib.optionals (pkgs ? quickshell) [
    pkgs.quickshell
  ];
}
