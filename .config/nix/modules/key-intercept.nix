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
    };

  flake.configSources.karabiner = {
    source = "karabiner";
    target = "karabiner";
    # darwin-only behavior is preserved by host/module selection elsewhere.
  };

  flake.configSources.kanata.source = "kanata";
}
