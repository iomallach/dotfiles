{ pkgs, config, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    mkalias
    vim
    neovim-nightly.default
    qmk # split keyboard
    fzf
    eza
    asciiquarium
    zed-editor
    uv
    nix-search-tv
    figlet # ascii prints
    bat
    jq
    cmatrix
    curl
    wget
    blueutil
    btop
    fd
    helix
    lazygit
    gitu
    neovide
    nowplaying-cli
    switchaudio-osx
    yazi
    openvpn
    ripgrep
    starship # prompt
    tmux
    tldr
    zoxide
    (lua54Packages.lua.withPackages (
      ps: with ps; [
        luasocket
        cjson
        luasec
      ]
    ))
    ghostty-bin
    # nix dev
    nixfmt-rfc-style # formatter
    nil # lsp
    nixd # lsp 2
    crush
    nvd # package diff between generations
    kanata # keyboard remapping
    kanata-tray.default
  ];

  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
    in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Because of homebrew.enable?
  system.primaryUser = "iomallach";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
