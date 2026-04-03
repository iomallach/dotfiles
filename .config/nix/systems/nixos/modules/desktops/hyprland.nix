{ pkgs, ... }:
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
