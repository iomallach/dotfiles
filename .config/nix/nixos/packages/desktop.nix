{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdePackages.qtsvg
    kdePackages.dolphin
    papirus-icon-theme
    arc-icon-theme
    flat-remix-icon-theme
    waybar
    rofi
    rofi-calc
    blueman
    networkmanagerapplet
    pavucontrol
    mission-center
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font = "Noto Sans";
      fontSize = "20";
      # background = "${./wallpaper.png}";
      loginBackground = true;
    })
  ];
}
