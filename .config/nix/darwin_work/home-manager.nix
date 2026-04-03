{ pkgs, lib, ... }:

{
  imports = [
    ../modules/darwin/aerospace.nix
    ../modules/darwin/borders.nix
    ../modules/alacritty.nix
    ../modules/helix.nix
    ../home-manager/kanata.nix
    ../modules/tmux.nix
    ../home-manager/doom-emacs.nix
    ../modules/kitty.nix
    ../home-manager/karabiner.nix
    ../modules/neovide.nix
    ../home-manager/nvim.nix
    ../home-manager/scripts.nix
    ../home-manager/wezterm.nix
    ../home-manager/zed.nix
    ../home-manager/vscode.nix
    ../home-manager/zellij.nix
    ../modules/zsh.nix
    ../modules/ghostty.nix
  ];

  home.username = "alexander.butenko";
  home.homeDirectory = lib.mkForce "/Users/alexander.butenko";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.zsh = {
    shellAliases = {
      load-ca-auth = "export UV_INDEX_CODEARTIFACT_USERNAME=aws && export UV_INDEX_CODEARTIFACT_PASSWORD=$(aws codeartifact get-authorization-token --profile production/developer --domain getyourguide --domain-owner 130607246975 --query authorizationToken --output text)";
    };

    initExtra = ''
      # XDG
      export XDG_CONFIG_HOME="$HOME/.config"

      # Enable vi mode
      bindkey -v

      # Edit command in $EDITOR with C-x C-e
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^xe' edit-command-line
      bindkey '^x^e' edit-command-line

      # Extra completions
      fpath=(~/.zsh/completions $fpath)

      # nvm
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
      nvm use &>/dev/null

      # SDKMAN (must be last)
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    '';
  };

  home.sessionVariables = {
    DEFAULT_USER = "alex";
    GRPC_PYTHON_BUILD_SYSTEM_OPENSSL = "1";
    GRPC_PYTHON_BUILD_SYSTEM_ZLIB = "1";
    MLFLOW_TRACKING_URI = "databricks";
    PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.rd/bin"
    "/opt/homebrew/opt/node@22/bin"
    "/Users/alexander.butenko/Library/pnpm"
  ];
}
