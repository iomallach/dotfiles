# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./services.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  catppuccin = {
    grub = {
      enable = true;
      flavor = "mocha";
    };
    gtk = {
      icon = {
        enable = true;
        flavor = "macchiato";
        accent = "blue";
      };
    };
  };

  networking.hostName = "tuxbook"; # Define your hostname.
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

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

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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

  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iomallach = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ]; # Enable ‘sudo’ for the user.
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
    nixfmt
    nvd
    brightnessctl
    papirus-icon-theme
    arc-icon-theme
    flat-remix-icon-theme
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font = "Noto Sans";
      fontSize = "20";
      # background = "${./wallpaper.png}";
      loginBackground = true;
    })
    # Desktop entry for zen browser (non-beta command)
    (makeDesktopItem {
      name = "zen";
      desktopName = "Zen Browser";
      exec = "zen --name zen %U";
      icon = "zen-browser";
      comment = "Browse the Web";
      genericName = "Web Browser";
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeTypes = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      startupNotify = true;
      extraConfig = {
        StartupWMClass = "zen";
      };
      actions = {
        new-window = {
          name = "New Window";
          exec = "zen --new-window %U";
        };
        new-private-window = {
          name = "New Private Window";
          exec = "zen --private-window %U";
        };
        profile-manager-window = {
          name = "Profile Manager";
          exec = "zen --ProfileManager";
        };
      };
    })
    wlogout
    hyprlock
    hyprpwcenter
    pavucontrol
    nerd-fonts.jetbrains-mono
    playerctl
    mission-center
    zathura
    obsidian
    cava
    hyprcursor
    powertop
    zed-editor-fhs
  ];

  fonts.packages = with pkgs; [
    maple-mono.NF
    nerd-fonts.symbols-only
    font-awesome
    material-design-icons
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
  programs.steam.enable = true;

  # Set GDK_PIXBUF_MODULE_FILE to include librsvg for SVG support in GTK apps
  environment.sessionVariables = {
    GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
  };

  users.users.iomallach = {
    shell = pkgs.zsh;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
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
