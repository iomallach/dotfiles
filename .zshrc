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
function zvm_after_init() {
  source <(fzf --zsh)
}
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
# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi

eval "$(starship init zsh)"

export PATH=$PATH:/Users/iomallach/.spicetify

# Set path for GO to install binaries into
export GOBIN="$HOME/.go/bin"

# Add zig
export PATH="$PATH:/Users/iomallach/.zig"

zellij_set_pane_name() {
  if [[ -n $ZELLIJ ]]; then
    local pane_name="$1"
    if [[ -z "$pane_name" ]]; then
      pane_name="$PWD"
      if [[ "$pane_name" == "$HOME" ]]; then
        pane_name="~"
      fi
    fi
    echo -ne "\033]0;${pane_name}\007"
  fi
}

if [[ -n $ZELLIJ ]]; then
  autoload -U add-zsh-hook
  zellij_set_pane_name
  add-zsh-hook chpwd zellij_set_pane_name
  add-zsh-hook preexec zellij_set_pane_name
  add-zsh-hook precmd zellij_set_pane_name
fi

source /Users/iomallach/dotfiles/.zshrc.secrets
