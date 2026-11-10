{ ... }:
{
  flake.modules.homeManager.omniwm =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      nativeWidgetNames = [
        "clock"
        "bluetooth"
        "volume"
        "battery-details"
        "notifications"
        "control-center"
      ];
      nativeWidgets = pkgs.runCommand "omniwm-native-widgets-${pkgs.omniwm.version}" { } ''
        widgets="${pkgs.omniwm}/Applications/OmniWM.app/Contents/Resources/OmniWM_OmniWM.bundle/Contents/Resources/ShellDefault/widgets"
        mkdir -p "$out"
        for name in ${lib.concatStringsSep " " nativeWidgetNames}; do
          target="$out/noctalia-native-$name.luau"
          printf 'local render, popout\n' > "$target"
          # Flat library modules use ./look rather than ../lib/look.
          sed 's#require("../lib/#require("./#g' "$widgets/$name/init.luau" >> "$target"
          printf '\nreturn { render = render, popout = popout }\n' >> "$target"
        done
      '';
    in
    {
      programs.aerospace.enable = lib.mkForce false;
      programs.omniwm = {
        enable = true;
        launchd.enable = true;
        settings = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/omniwm/settings.toml";
      };

      # Keep editable shell config beside other dotfiles; OmniWM owns shell/default.
      xdg.configFile = {
        "omniwm/shell/shell.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/omniwm/shell/shell.toml";
        "omniwm/shell/noctalia".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/omniwm/shell/noctalia";
      }
      // lib.listToAttrs (
        map (
          name:
          lib.nameValuePair "omniwm/shell/lib/noctalia-native-${name}.luau" {
            source = "${nativeWidgets}/noctalia-native-${name}.luau";
          }
        ) nativeWidgetNames
      );
    };

  flake.modules.darwin.omniwm =
    { config, pkgs, ... }:
    {
      # TODO: Remove this override once pinned nixpkgs provides OmniWM >= 0.8.0.
      # Retain nixpkgs' signed-app packaging without updating unrelated packages.
      nixpkgs.overlays = [
        (final: prev: {
          omniwm = prev.omniwm.overrideAttrs (
            finalAttrs: _: {
              version = "0.8.0";
              src = final.fetchurl {
                url = "https://github.com/OmniNull/OmniWM/releases/download/v${finalAttrs.version}/OmniWM-v${finalAttrs.version}.zip";
                hash = "sha256-b3+z4hHeOoPncrExgAaAyz0g1MY4gRofAhIP0iXwPMc=";
              };
            }
          );
        })
      ];

      services.sketchybar.extraPackages = [ pkgs.omniwm ];
      launchd.user.agents.sketchybar.serviceConfig.EnvironmentVariables.NOCTALIA_WM = "omniwm";

      # Keep workspace updates immediate; polling still covers startup and previews.
      launchd.user.agents.omniwm-sketchybar.serviceConfig = {
        ProgramArguments = [
          "${pkgs.omniwm}/bin/omniwmctl"
          "watch"
          "active-workspace"
          "--reconnect"
          "--exec"
          "${config.services.sketchybar.package}/bin/sketchybar"
          "--trigger"
          "omniwm_workspace_change"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        ThrottleInterval = 5;
        StandardOutPath = "/tmp/omniwm-sketchybar.log";
        StandardErrorPath = "/tmp/omniwm-sketchybar.err.log";
      };

      # Supplement native Bluetooth data with the same accessory report as SketchyBar.
      launchd.user.agents.omniwm-bluetooth-power.serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "${
            config.users.users.${config.system.primaryUser}.home
          }/dotfiles/.config/omniwm/bin/bluetooth-power.sh"
          "${pkgs.omniwm}/bin/omniwmctl"
        ];
        RunAtLoad = true;
        StartInterval = 30;
        ProcessType = "Background";
        StandardOutPath = "/tmp/omniwm-bluetooth-power.log";
        StandardErrorPath = "/tmp/omniwm-bluetooth-power.err.log";
      };
    };
}
