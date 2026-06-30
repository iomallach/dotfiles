{
  flake.modules.darwin.keyIntercept =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        kanata
        kanata-tray.default
      ];
      homebrew = {
        casks = [
          "karabiner-elements"
        ];
      };
    };

  flake.modules.nixos.keyIntercept =
    { config, pkgs, ... }:
    {
      hardware.uinput.enable = true;

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="AULA-F75 5.0 KB Keyboard", ATTRS{uniq}=="ca:cb:2c:9e:29:93", SYMLINK+="input/by-id/aula-f75-bluetooth-event-kbd", TAG+="systemd", ENV{SYSTEMD_WANTS}+="kanata-restart.service"
      '';

      systemd.services.kanata = {
        description = "Kanata keyboard remapper";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.kanata}/bin/kanata \
              --cfg ${config.users.users.iomallach.home}/.config/kanata/kanata.kbd \
              --quiet
          '';
          Restart = "on-failure";
          RestartSec = 3;
        };
      };

      systemd.services.kanata-restart = {
        description = "Restart Kanata when Aula F75 reconnects";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemctl try-restart kanata.service";
        };
      };
    };

  flake.configSources.karabiner = {
    source = "karabiner";
    target = "karabiner";
    # darwin-only behavior is preserved by host/module selection elsewhere.
  };

  flake.configSources.kanata.source = "kanata";
}
