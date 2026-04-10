{ ... }:

{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      "after-login-command" = [ ];
      "after-startup-command" = [ "exec-and-forget ~/.config/borders/bordersrc" ];
      "exec-on-workspace-change" = [
        "/bin/bash"
        "-c"
        "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];

      "enable-normalization-flatten-containers" = true;
      "enable-normalization-opposite-orientation-for-nested-containers" = true;

      "accordion-padding" = 30;
      "default-root-container-layout" = "tiles";
      "default-root-container-orientation" = "auto";

      "on-focused-monitor-changed" = [ "move-mouse monitor-lazy-center" ];
      "automatically-unhide-macos-hidden-apps" = true;

      "key-mapping".preset = "qwerty";

      gaps = {
        inner = {
          horizontal = 20;
          vertical = 20;
        };
        outer = {
          left = 20;
          bottom = 20;
          top = [
            { monitor."built-in" = 15; }
            45
          ];
          right = 20;
        };
      };

      mode = {
        main.binding = {
          "alt-shift-cmd-ctrl-enter" = "exec-and-forget open -n \"/Applications/Nix Apps/Ghostty.app\"";
          "alt-cmd-ctrl-g" = "exec-and-forget open -n \"/Applications/Nix Apps/Ghostty.app\"";
          "alt-cmd-ctrl-z" = "exec-and-forget open -n \"/Applications/Nix Apps/Zed.app\"";
          "alt-cmd-ctrl-b" = "exec-and-forget brew services restart borders";

          "alt-shift-cmd-ctrl-slash" = "layout tiles horizontal vertical";
          "alt-shift-cmd-ctrl-comma" = "layout accordion horizontal vertical";

          "alt-shift-cmd-ctrl-h" = "focus left";
          "alt-shift-cmd-ctrl-j" = "focus down";
          "alt-shift-cmd-ctrl-k" = "focus up";
          "alt-shift-cmd-ctrl-l" = "focus right";

          "alt-shift-cmd-ctrl-1" = "workspace 1";
          "alt-shift-cmd-ctrl-2" = "workspace 2";
          "alt-shift-cmd-ctrl-3" = "workspace 3";
          "alt-shift-cmd-ctrl-4" = "workspace 4";
          "alt-shift-cmd-ctrl-5" = "workspace 5";
          "alt-shift-cmd-ctrl-6" = "workspace 6";
          "alt-shift-cmd-ctrl-7" = "workspace 7";
          "alt-shift-cmd-ctrl-8" = "workspace 8";
          "alt-shift-cmd-ctrl-9" = "workspace 9";
          "alt-shift-cmd-ctrl-a" = "workspace A";
          "alt-shift-cmd-ctrl-b" = "workspace B";
          "alt-shift-cmd-ctrl-c" = "workspace C";
          "alt-shift-cmd-ctrl-d" = "workspace D";
          "alt-shift-cmd-ctrl-e" = "workspace E";
          "alt-shift-cmd-ctrl-f" = "workspace F";
          "alt-shift-cmd-ctrl-g" = "workspace G";
          "alt-shift-cmd-ctrl-i" = "workspace I";
          "alt-shift-cmd-ctrl-m" = "workspace M";
          "alt-shift-cmd-ctrl-n" = "workspace N";
          "alt-shift-cmd-ctrl-o" = "workspace O";
          "alt-shift-cmd-ctrl-p" = "workspace P";
          "alt-shift-cmd-ctrl-q" = "workspace Q";
          "alt-shift-cmd-ctrl-r" = "workspace R";
          "alt-shift-cmd-ctrl-s" = "workspace S";
          "alt-shift-cmd-ctrl-t" = "workspace T";
          "alt-shift-cmd-ctrl-u" = "workspace U";
          "alt-shift-cmd-ctrl-v" = "workspace V";
          "alt-shift-cmd-ctrl-w" = "workspace W";
          "alt-shift-cmd-ctrl-x" = "workspace X";
          "alt-shift-cmd-ctrl-y" = "workspace Y";
          "alt-shift-cmd-ctrl-z" = "workspace Z";

          "alt-shift-1" = "move-node-to-workspace 1";
          "alt-shift-2" = "move-node-to-workspace 2";
          "alt-shift-3" = "move-node-to-workspace 3";
          "alt-shift-4" = "move-node-to-workspace 4";
          "alt-shift-5" = "move-node-to-workspace 5";
          "alt-shift-6" = "move-node-to-workspace 6";
          "alt-shift-7" = "move-node-to-workspace 7";
          "alt-shift-8" = "move-node-to-workspace 8";
          "alt-shift-9" = "move-node-to-workspace 9";
          "alt-shift-a" = "move-node-to-workspace A";
          "alt-shift-b" = "move-node-to-workspace B";
          "alt-shift-c" = "move-node-to-workspace C";
          "alt-shift-d" = "move-node-to-workspace D";
          "alt-shift-e" = "move-node-to-workspace E";
          "alt-shift-f" = "move-node-to-workspace F";
          "alt-shift-g" = "move-node-to-workspace G";
          "alt-shift-i" = "move-node-to-workspace I";
          "alt-shift-m" = "move-node-to-workspace M";
          "alt-shift-n" = "move-node-to-workspace N";
          "alt-shift-o" = "move-node-to-workspace O";
          "alt-shift-p" = "move-node-to-workspace P";
          "alt-shift-q" = "move-node-to-workspace Q";
          "alt-shift-r" = "move-node-to-workspace R";
          "alt-shift-s" = "move-node-to-workspace S";
          "alt-shift-t" = "move-node-to-workspace T";
          "alt-shift-u" = "move-node-to-workspace U";
          "alt-shift-v" = "move-node-to-workspace V";
          "alt-shift-w" = "move-node-to-workspace W";
          "alt-shift-x" = "move-node-to-workspace X";
          "alt-shift-y" = "move-node-to-workspace Y";
          "alt-shift-z" = "move-node-to-workspace Z";

          "alt-shift-cmd-ctrl-tab" = "workspace-back-and-forth";
          "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";

          "alt-shift-cmd-ctrl-semicolon" = "mode service";
        };

        service.binding = {
          "alt-h" = [
            "move left"
            "mode main"
          ];
          "alt-j" = [
            "move down"
            "mode main"
          ];
          "alt-k" = [
            "move up"
            "mode main"
          ];
          "alt-l" = [
            "move right"
            "mode main"
          ];

          j = "resize smart -50";
          k = "resize smart +50";

          esc = [ "mode main" ];
          r = [
            "reload-config"
            "mode main"
          ];
          "shift-f" = [
            "flatten-workspace-tree"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];

          "alt-shift-h" = [
            "join-with left"
            "mode main"
          ];
          "alt-shift-j" = [
            "join-with down"
            "mode main"
          ];
          "alt-shift-k" = [
            "join-with up"
            "mode main"
          ];
          "alt-shift-l" = [
            "join-with right"
            "mode main"
          ];
        };
      };

      "on-window-detected" = [
        {
          "if".app-id = "com.github.wez.wezterm";
          run = "move-node-to-workspace T";
        }
        {
          "if".app-id = "company.thebrowser.Browser";
          run = "move-node-to-workspace B";
        }
        {
          "if".app-id = "com.spotify.client";
          run = "move-node-to-workspace S";
        }
        {
          "if".app-id = "com.jetbrains.intellij.ce";
          run = "move-node-to-workspace I";
        }
        {
          "if".app-id = "com.jetbrains.intellij";
          run = "move-node-to-workspace I";
        }
        {
          "if".app-id = "com.google.Chrome";
          run = "move-node-to-workspace C";
        }
      ];
    };
  };
}
