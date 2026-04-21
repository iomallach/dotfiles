{ inputs, ... }:
{
  flake.modules.homeManager.desktopGui = {
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

            "alt-1" = "workspace 1";
            "alt-2" = "workspace 2";
            "alt-3" = "workspace 3";
            "alt-4" = "workspace 4";
            "alt-5" = "workspace 5";
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
            "if".app-id = "com.google.Chrome";
            run = "move-node-to-workspace C";
          }
        ];
      };
    };

    services.paneru = {
      enable = false;
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          preset_column_widths = [
            0.25
            0.33
            0.5
            0.66
            0.75
            1.0
          ];
        };
        padding = {
          top = 20;
          bottom = 20;
          left = 20;
          right = 20;
        };
        bindings = {
          window_focus_west = "alt - h";
          window_focus_east = "alt - l";
          window_focus_north = "alt - k";
          window_focus_south = "alt - j";
          # window_swap_west = "cmd - ctrl - h";
          # window_swap_east = "cmd - ctrl - l";
          # window_swap_north = "cmd - ctrl - k";
          # window_swap_south = "cmd - ctrl - j";
          window_resize = "alt - r";
          window_manage = "alt - v"; # tiled/floating
          # window_next_display = "alt - shift - tab";
          window_fullwidth = "alt - f";
          window_center = "alt - c";
          mouse_nextdisplay = "alt - n";
        };
        decorations.active.border = {
          enabled = false;
          width = 2.0;
          radius = 20;
          color = "#ff0000";
        };
      };
    };
  };

  flake.modules.nixos.desktopGui =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        hyprpaper
        hyprlock
        hyprpwcenter
        hyprcursor
        wlogout
        rofi
        rofi-calc
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        kdePackages.qtsvg
        kdePackages.dolphin
        blueman
        networkmanagerapplet
        pavucontrol
        mission-center
        (pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          accent = "mauve";
          font = "Noto Sans";
          fontSize = "20";
          # background = "${./wallpaper.png}";
          loginBackground = true;
        })
        papirus-icon-theme
        arc-icon-theme
        flat-remix-icon-theme
      ];

      programs = {
        # dank-material-shell.enable = false;
        hyprland = {
          enable = false;
          xwayland.enable = true;
        };
        niri.enable = true;
        waybar = {
          enable = false;
        };
      };

      time.timeZone = "Europe/Berlin";
    };

  flake.modules.darwin.desktopGui =
    { pkgs, config, ... }:
    {
      services.sketchybar = {
        enable = true;
      };

      homebrew = {
        taps = [
          "felixkratz/formulae"
        ];
        brews = [
          "borders"
        ];
        casks = [
          "raycast"
          "betterdisplay"
        ];
      };

      system.activationScripts.applications.text =
        let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = [ "/Applications" ];
          };
        in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';
    };

  flake.configSources = {
    borders.source = "borders";
    hypr.source = "hypr";
    niri.source = "niri";
    waybar.source = "waybar";
    wlogout.source = "wlogout";
    rofi.source = "rofi";
  };
}
