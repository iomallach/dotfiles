{ pkgs, config, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    mkalias
    # neovim-nightly.default
    fzf
    eza
    asciiquarium
    zed-editor
    uv
    bat
    jq
    curl
    wget
    fd
    gitu
    nowplaying-cli
    switchaudio-osx
    yazi
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
    # ghostty-bin
    # nix dev
    nixfmt # formatter
    nil # lsp
    nixd # lsp 2
    nvd # package diff between generations
    kanata # keyboard remapping
    kanata-tray.default
    # claude-code
    # bun
    # nodejs
    opencode
    actionlint
    cmake
    hadolint
    gh
    starship
    lazygit
    difftastic
    lua-language-server
    databricks-cli
    just
    ghostty-bin
    shellcheck
    switchaudio-osx
    dive
    stow
    tree
    obsidian
  ];

  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = [ "/Applications" ];
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
  system.primaryUser = "alexander.butenko";

  # Run kanata as a root launchd daemon (needs root to access keyboard devices)
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "org.nixos.kanata";
      ProgramArguments = [
        "/run/current-system/sw/bin/kanata"
        "--cfg"
        "/Users/alexander.butenko/copydotfiles/dotfiles/.config/kanata/kanata.kbd"
        "--quiet"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/kanata.log";
      StandardErrorPath = "/var/log/kanata.log";
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.zsh.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
