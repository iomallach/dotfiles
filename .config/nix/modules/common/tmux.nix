{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    plugins = [
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.catppuccin
      pkgs.tmuxPlugins.battery
      pkgs.tmuxPlugins.cpu
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.continuum
    ];
    extraConfig = ''
      # Enable Colours
      set-option -g default-terminal "tmux-256color"
      set -sg terminal-overrides ",*:RGB"

      # Map Default Prefix
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # Split Windows
      unbind %
      bind | split-window -h
      unbind '"'
      bind - split-window -v
      bind y new-window

      # Reload Config
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Resize Panes
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r h resize-pane -L 5
      bind -r l resize-pane -R 5
      bind -r m resize-pane -Z
      bind C-p previous-window
      bind C-n next-window

      # Prefix + z toggles maximize pane!

      # Enable Mouse
      set -g mouse on

      # Terminal Scrollback
      set -g history-limit 50000

      # Status Bar Position
      set-option -g status-position top

      # Enable VIM motions
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
      bind-key -T copy-mode-vi 'y' send-keys -X copy-selection

      # Sessionizer
      bind-key -r f run-shell "tmux display-popup -E ~/dotfiles/.config/scripts/tmux-sessionizer.sh"
      bind-key -r v run-shell "tmux display-popup -E ~/dotfiles/.config/scripts/tmux-session-switcher.sh"
      bind-key -r M run-shell "tmux display-popup -w 20% -h 30% -E ~/.go/bin/tmux-session-manager"
      bind-key -r W run-shell "tmux display-popup -w 20% -h 30% -E ~/.go/bin/tmux-session-manager"

      # Popup
      bind-key -r o run-shell "~/dotfiles/.config/scripts/popup.sh"

      # Enable Mouse Dragging
      unbind -T copy-mode-vi MouseDragEnd1Pane

      # tmux-resurrect / tmux-continuum
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'

      # Catppucin settings
      set -g @catppuccin_flavour 'macchiato' # or frappe, macchiato, mocha
      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " █"
      set -g @catppuccin_window_number_position "right"

      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"

      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W"

      set -g @catppuccin_status_modules_right "application session"
      set -g @catppuccin_status_left_separator  " "
      set -g @catppuccin_status_right_separator ""
      set -g @catppuccin_status_right_separator_inverse "no"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "no"

      set -g @catppuccin_directory_text "#{pane_current_path}"
    '';
  };
}
