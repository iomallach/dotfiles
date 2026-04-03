{ pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    neovim-nightly.default
    qmk # split keyboard
    nix-search-tv
    figlet # ascii prints
    cmatrix
    blueutil
    btop
    helix
    lazygit
    neovide
    openvpn
    # nix dev
    nixfmt-rfc-style # formatter
    crush
    claude-code
    claude-monitor
    bun
    nodejs
  ];

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Because of homebrew.enable?
  system.primaryUser = "iomallach";

  imports = [
    ../../modules/base.nix
  ];
}
