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
    ];
    hyprland-quickshell = [
      ./common.nix
      ../desktops/hyprland.nix
      ../desktops/quickshell.nix
    ];
    niri = [
      ./common.nix
      ../desktops/niri.nix
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
