{ pkgs, config, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    mkalias
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
    starship
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
    nil
    nixd
    nvd
    kanata
    kanata-tray.default
    spotify
    aerospace
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

  nix.settings.experimental-features = "nix-command flakes";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.sketchybar = {
    enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
