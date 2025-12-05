# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "acpi.ec_no_wakeup=1" # acpi wakeup issues
    "amdgpu.dcdebugmask=0x10" # wayland slowdonws/freezes
  ];
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
#      useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "tuxbook"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.tuxedo-control-center.enable = true;
  hardware.tuxedo-drivers.enable = true;
  services.blueman.enable = true;
  services.power-profiles-daemon.enable = false;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iomallach = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    ghostty
    kitty
    waybar
    hyprpaper
    rofi
    kdePackages.qtsvg
    kdePackages.dolphin
    networkmanagerapplet
    blueman
    inputs.zen-browser.packages."${pkgs.system}".default
    claude-code
    crush
    lua54Packages.lua
    stow
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
    tmux
    zellij
    gnumake
    rustup
    clang
    nil
    nixd
    nvd
    brightnessctl
    papirus-icon-theme
    arc-icon-theme
    flat-remix-icon-theme
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font = "Noto Sans";
      fontSize = "9";
      # background = "${./wallpaper.png}";
      loginBackground = true;
    })
  ];

  fonts.packages = with pkgs; [
    maple-mono.NF
    nerd-fonts.symbols-only
    font-awesome
    material-design-icons
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    sddm.theme = "catppuccin-mocha-mauve";
  };

  programs.firefox.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly.packages."${pkgs.system}".default;
  };
  programs.zsh.enable = true;
  users.users.iomallach = {
    shell = pkgs.zsh;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

