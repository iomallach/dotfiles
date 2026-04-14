{
  flake.modules.shell =

    {
      core = {
        base =
          { pkgs, ... }:
          {
            programs.zsh.enable = true;
            environment.systemPackages = with pkgs; [
              vim
              wget
              curl
              fd
              ripgrep
              eza
              bat
              jq
              btop
              yazi
              nvd
              figlet
              cmatrix
              difftastic
              dive
            ];
          };

        darwinWork =
          { pkgs, ... }:
          {
            environment.systemPackages = with pkgs; [
              mkalias
              databricks-cli
            ];
          };
      };

      base =
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

              zvm_after_init() {
                bindkey -M viins '^R' fzf-history-widget
              }

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

              source ~/.zshrc.secrets
            '';
          };

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          programs.fzf = {
            enable = true;
            enableZshIntegration = true;
          };

          programs.zoxide = {
            enable = true;
            options = [
              "--cmd"
              "cd"
            ];
          };

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

          programs.starship = {
            enable = true;
            settings = {
              command_timeout = 2000;
              palette = "catppuccin_macchiato";
              status = {
                disabled = false;
              };
              palettes = {
                catppuccin_macchiato = {
                  rosewater = "#f4dbd6";
                  flamingo = "#f0c6c6";
                  pink = "#f5bde6";
                  mauve = "#c6a0f6";
                  red = "#ed8796";
                  maroon = "#ee99a0";
                  peach = "#f5a97f";
                  yellow = "#eed49f";
                  green = "#a6da95";
                  teal = "#8bd5ca";
                  sky = "#91d7e3";
                  sapphire = "#7dc4e4";
                  blue = "#8aadf4";
                  lavender = "#b7bdf8";
                  text = "#cad3f5";
                  subtext1 = "#b8c0e0";
                  subtext0 = "#a5adcb";
                  overlay2 = "#939ab7";
                  overlay1 = "#8087a2";
                  overlay0 = "#6e738d";
                  surface2 = "#5b6078";
                  surface1 = "#494d64";
                  surface0 = "#363a4f";
                  base = "#24273a";
                  mantle = "#1e2030";
                  crust = "#181926";
                };
              };
            };
          };
        };

      nixos =
        { pkgs, ... }:
        {
          environment.sessionVariables = {
            GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
            XCURSOR_THEME = "catppuccin-macchiato-blue-cursors";
            XCURSOR_SIZE = "35";
            HYPRCURSOR_THEME = "catppuccin-macchiato-blue-cursors";
            HYPRCURSOR_SIZE = "35";
          };

          environment.systemPackages = with pkgs; [
            powertop
          ];
        };

      darwinWork = {
        system = {
          programs.zsh = {
            shellInit = ''
              eval "$(/opt/homebrew/bin/brew shellenv)"
            '';

            interactiveShellInit = ''
              eval "$(direnv hook zsh)"
            '';
          };
        };

        homeManager = {
          programs.zsh = {
            shellAliases = {
              load-ca-auth = "export UV_INDEX_CODEARTIFACT_USERNAME=aws && export UV_INDEX_CODEARTIFACT_PASSWORD=$(aws codeartifact get-authorization-token --profile production/developer --domain getyourguide --domain-owner 130607246975 --query authorizationToken --output text)";
              c = "clear";
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
        };
      };
    };
}
