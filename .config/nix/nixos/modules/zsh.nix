{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    initExtraBeforeCompInit = ''
      fpath+=${pkgs.zsh-completions}/share/zsh/site-functions
    '';

    history = {
      size = 5000;
      save = 5000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      gs = "git status";
      ls = "eza -lh --icons --git";
    };

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "omz-git";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/git/git.plugin.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    initExtra = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color --oneline --icons --git -a $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color --oneline --icons --git -a $realpath'
      zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat $realpath'

      zellij_set_pane_name() {
        if [[ -n $ZELLIJ ]]; then
          local pane_name="$1"
          if [[ -z "$pane_name" ]]; then
            pane_name="$PWD"
            if [[ "$pane_name" == "$HOME" ]]; then
              pane_name="~"
            fi
          fi
          echo -ne "\033]0;''${pane_name}\007"
        fi
      }

      if [[ -n $ZELLIJ ]]; then
        autoload -U add-zsh-hook
        zellij_set_pane_name
        add-zsh-hook chpwd zellij_set_pane_name
        add-zsh-hook preexec zellij_set_pane_name
        add-zsh-hook precmd zellij_set_pane_name
      fi

      zvm_after_init() {
        source <(fzf --zsh)
      }

      source ~/.zshrc.secrets
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.direnv.enable = true;

  programs.starship.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    FZF_DEFAULT_OPTS = ''
      --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
      --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
      --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
    '';
    FZF_CTRL_T_OPTS = ''
      --walker-skip .git,node_modules,target
      --preview 'bat -n --color=always {}'
      --bind 'ctrl-/:change-preview-window(down|hidden|)'
    '';
  };

  home.sessionPath = [
    "$HOME/.spicetify"
    "$HOME/.go/bin"
    "$HOME/.zig"
  ];
}
