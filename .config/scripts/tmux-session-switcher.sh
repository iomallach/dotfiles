selected=$(tmux list-sessions -F '#S' | fzf)

if [[ -z $selected ]]; then
    exit 0
fi

tmux switch-client -t $selected