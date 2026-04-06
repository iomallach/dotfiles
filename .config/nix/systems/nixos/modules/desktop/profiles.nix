{
  desktopProfile ? "hyprland",
  ...
}:
let
  profiles = {
    hyprland = [
      ./common.nix
      ../desktops/hyprland.nix
      ../desktops/waybar.nix
      ../desktops/quickshell.nix
    ];
    hyprland-quickshell = [
      ./common.nix
      ../desktops/hyprland.nix
      ../desktops/quickshell.nix
    ];
    niri-waybar = [
      ./common.nix
      ../desktops/niri.nix
      ../desktops/waybar.nix
    ];
    niri-quickshell = [
      ./common.nix
      ../desktops/niri.nix
      ../desktops/quickshell.nix
    ];
  };
in
{
  imports = profiles.${desktopProfile} or [ ];
}
