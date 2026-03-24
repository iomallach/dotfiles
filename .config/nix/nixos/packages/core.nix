{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      gitu = prev.gitu.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
      crush = prev.crush.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    lua54Packages.lua
    brightnessctl

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
    networkmanager-openvpn

    # Nix core
    nvd
  ];
}
