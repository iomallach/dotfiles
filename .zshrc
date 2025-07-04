# Set directory for zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Zsh plugins
# zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Zsh snippets
zinit snippet OMZP::git

# Load completions
autoload -U compinit && compinit

# Fast syntax highlighting theme
# fast-theme XDG:catppuccin-macchiato

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color --oneline --icons --git -a $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color --oneline --icons --git -a $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat $realpath'

export EDITOR='nvim'

# Fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

alias gs='git status'
alias ls='eza -lh --icons --git'

# Zoxide
eval "$(zoxide init zsh --cmd cd)"

export XDG_CONFIG_HOME="$HOME/.config"

# Starship shell
eval "$(starship init zsh)"

# Add brewed LLVM to path
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

export PATH=$PATH:/Users/iomallach/.spicetify

# Created by `pipx` on 2024-07-24 18:43:00
export PATH="$PATH:/Users/iomallach/.local/bin"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Set path for GO to install binaries into
export GOBIN="$HOME/.go/bin"

# Add zig
export PATH="$PATH:/Users/iomallach/.zig"

zellij_tab_name_update() {
  if [[ -n $ZELLIJ ]]; then
    tab_name=$PWD
    if [[ $tab_name == $HOME ]]; then
         	tab_name="~"
    fi
    command nohup zellij action rename-pane $tab_name >/dev/null 2>&1
  fi
}

zellij_tab_name_update
chpwd_functions+=(zellij_tab_name_update)

zellij_pane_name_process_update() {
  if [[ -n $ZELLIJ ]]; then
    pane_name=$1
    command nohup zellij action rename-pane $pane_name >/dev/null 2>&1
  fi
}

autoload -U add-zsh-hook
add-zsh-hook preexec zellij_pane_name_process_update
add-zsh-hook precmd zellij_tab_name_update
