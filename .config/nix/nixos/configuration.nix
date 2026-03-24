# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../modules/nixos/base.nix
    ../modules/nixos/desktop/profiles.nix
    ../modules/nixos/desktop/common.nix
    ../modules/nixos/desktops/hyprland.nix
    ../modules/nixos/desktops/waybar.nix
    ../modules/nixos/desktops/quickshell.nix
    ../modules/nixos/desktops/niri.nix
    ./packages/core.nix
    ./packages/desktop.nix
    ./packages/apps.nix
  ];

  desktop.profile = "hyprland";

  networking.hostName = "tuxbook"; # Define your hostname.
  # Configure network connections interactively with nmcli or nmtui.
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    tuxedo-control-center.enable = true;
    tuxedo-drivers.enable = true;
    tuxedo-keyboard.enable = true;
    tuxedo-rs = {
      enable = false;
      tailor-gui.enable = false;
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
