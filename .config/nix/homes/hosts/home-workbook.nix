{ pkgs, lib, ... }:

{
  imports = [
    ../../systems/darwin/modules/aerospace.nix
    ../../systems/darwin/modules/borders.nix
    ../../modules/common/alacritty.nix
    ../../modules/common/helix.nix
    ../../modules/home/kanata.nix
    ../../modules/common/tmux.nix
    ../../modules/home/doom-emacs.nix
    ../../modules/common/kitty.nix
    ../../modules/home/karabiner.nix
    ../../modules/common/neovide.nix
    ../../modules/home/nvim.nix
    ../../modules/home/scripts.nix
    ../../modules/home/wezterm.nix
    ../../modules/home/zed.nix
    ../../modules/home/vscode.nix
    ../../modules/home/zellij.nix
    ../../modules/common/zsh.nix
    ../../modules/common/ghostty.nix
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
    OH_MY_OPENCODE_SLIM_PRESET = "work";
    PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.rd/bin"
    "/opt/homebrew/opt/node@22/bin"
    "/Users/alexander.butenko/Library/pnpm"
  ];
}
