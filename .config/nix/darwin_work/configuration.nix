{ pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovim-nightly.default
    nixfmt # formatter
    claude-code
    opencode
    actionlint
    cmake
    hadolint
    gh
    lazygit
    difftastic
    lua-language-server
    databricks-cli
    just
    shellcheck
    dive
    stow
    tree
    obsidian
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
  ];

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

  imports = [
    ../modules/darwin/base.nix
  ];

  programs.zsh.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
