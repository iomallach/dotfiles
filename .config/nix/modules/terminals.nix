let
  defaultFont = {
    family = "Maple Mono NF";
    size = 14;
  };
in
{
  flake.modules.homeManager.terminals =
    { pkgs, ... }:
    {
      programs = {
        alacritty = {
          enable = false;
          settings = {
            import = [ "~/.config/alacritty/themes/zenburn.toml" ];
            shell = {
              program = "/bin/zsh";
              args = [ "--login" ];
            };
            cursor.style = "Block";
            font = {
              normal = {
                family = "FiraCode Nerd Font";
                style = "Regular";
              };
              size = 16.0;
            };
            window.option_as_alt = "OnlyLeft";
          };
        };
        ghostty = {
          enable = true;
          package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
          enableZshIntegration = true;
          settings = {
            custom-shader = [
              "shaders/cursor_blaze_no_trail.glsl"
              "shaders/cursor_smear_fade.glsl"
            ];
            font-family = defaultFont.family;
            font-family-bold = defaultFont.family;
            font-family-italic = defaultFont.family;
            font-family-bold-italic = defaultFont.family;
            font-size = defaultFont.size;
            theme = "onedark_vaporwave";
            macos-titlebar-style = "hidden";
            macos-option-as-alt = true;
            window-decoration = "none";
            keybind = "shift+enter=text:\x1b\r";
          };
          themes = {
            Eldritch = {
              palette = [
                "0=#21222c"
                "1=#f9515d"
                "2=#37f499"
                "3=#e9f941"
                "4=#9071f4"
                "5=#f265b5"
                "6=#04d1f9"
                "7=#ebfafa"
                "8=#7081d0"
                "9=#f16c75"
                "10=#69F8B3"
                "11=#f1fc79"
                "12=#a48cf2"
                "13=#FD92CE"
                "14=#66e4fd"
                "15=#ffffff"
              ];
              background = "212337";
              foreground = "ebfafa";
              cursor-color = "37f499";
              selection-background = "bf4f8e";
              selection-foreground = "ebfafa";
            };
            onedark_vaporwave = {
              palette = [
                "0=#21222c"
                "1=#f9515d"
                "2=#37f499"
                "3=#e9f941"
                "4=#9071f4"
                "5=#f265b5"
                "6=#04d1f9"
                "7=#ebfafa"
                "8=#7081d0"
                "9=#f16c75"
                "10=#69F8B3"
                "11=#f1fc79"
                "12=#a48cf2"
                "13=#FD92CE"
                "14=#66e4fd"
                "15=#ffffff"
              ];
              background = "212337";
              foreground = "ebfafa";
              cursor-color = "37f499";
              selection-background = "bf4f8e";
              selection-foreground = "ebfafa";
            };
          };
        };
        kitty.enable = false;
        wezterm.enable = false;
        tmux = {
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
            set-option -g default-terminal "tmux-256color"
            set -sg terminal-overrides ",*:RGB"
            set -g prefix C-a
            unbind C-b
            bind C-a send-prefix
            unbind %
            bind | split-window -h
            unbind '"'
            bind - split-window -v
            bind y new-window
            unbind r
            bind r source-file ~/.config/tmux/tmux.conf
            bind -r j resize-pane -D 5
            bind -r k resize-pane -U 5
            bind -r h resize-pane -L 5
            bind -r l resize-pane -R 5
            bind -r m resize-pane -Z
            bind C-p previous-window
            bind C-n next-window
            set -g mouse on
            set -g history-limit 50000
            set-option -g status-position top
            set-window-option -g mode-keys vi
            bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
            bind-key -T copy-mode-vi 'y' send-keys -X copy-selection
            bind-key -r f run-shell "tmux display-popup -E ~/dotfiles/.config/scripts/tmux-sessionizer.sh"
            bind-key -r v run-shell "tmux display-popup -E ~/dotfiles/.config/scripts/tmux-session-switcher.sh"
            bind-key -r M run-shell "tmux display-popup -w 20% -h 30% -E ~/.go/bin/tmux-session-manager"
            bind-key -r W run-shell "tmux display-popup -w 20% -h 30% -E ~/.go/bin/tmux-session-manager"
            bind-key -r o run-shell "~/dotfiles/.config/scripts/popup.sh"
            unbind -T copy-mode-vi MouseDragEnd1Pane
            set -g @resurrect-capture-pane-contents 'on'
            set -g @continuum-restore 'on'
            set -g @catppuccin_flavour 'macchiato'
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
        zellij.enable = true;
      };
    };

  flake.configSources = {
    "alacritty/themes" = {
      source = "alacritty/themes";
      recursive = true;
    };
    "ghostty/shaders" = {
      source = "ghostty/shaders";
      recursive = true;
    };
    zellij.source = "zellij";
  };
}
