{ lib, ... }:
{
  options.desktop.profile = lib.mkOption {
    type = lib.types.enum [
      "hyprland"
      "hyprland-quickshell"
      "niri"
      "niri-quickshell"
    ];
    default = "hyprland";
    description = "Desktop profile name to enable.";
  };
}
