{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    kdePackages.qtsvg
    kdePackages.dolphin
    lua54Packages.lua
    brightnessctl
    papirus-icon-theme
    arc-icon-theme
    flat-remix-icon-theme

    # CLI core
    git
    stow
    vim
    wget
    fd
    fzf
    ripgrep
    eza
    bat
    jq
    btop
    gitu
    starship
    zoxide
    gnumake

    # Nix core
    nvd

    # Gui core
    waybar
    hyprpaper
    rofi
    blueman
    networkmanagerapplet
    wlogout
    hyprlock
    hyprpwcenter
    pavucontrol
    mission-center
    hyprcursor
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
