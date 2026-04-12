{
  flake.modules.systemd =

    {
      nixos =
        { config, pkgs, ... }:
        {
          systemd = {
            services.systemd-rfkill.enable = false;

            sockets.systemd-rfkill.enable = false;

            services.amneziavpn-daemon = {
              description = "AmneziaVPN Service Daemon";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig = {
                ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
                Restart = "on-failure";
                RestartSec = 3;
              };
            };

            tmpfiles.rules = [
              "L+ /home/iomallach/.local/share/v2rayN/bin/xray/xray - - - - ${config.security.wrapperDir}/xray"
              "L+ /home/iomallach/.local/share/v2rayN/bin/geoip.dat - - - - ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat"
              "L+ /home/iomallach/.local/share/v2rayN/bin/geosite.dat - - - - ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat"
              "L+ /home/iomallach/.local/share/v2rayN/bin/sing_box/sing-box - - - - ${pkgs.sing-box}/bin/sing-box"
            ];
          };
        };

      darwin =
        { config, ... }:
        {
          # Run kanata as a root launchd daemon (needs root to access keyboard devices)
          launchd.daemons.kanata = {
            serviceConfig = {
              Label = "org.nixos.kanata";
              ProgramArguments = [
                "/run/current-system/sw/bin/kanata"
                "--cfg"
                "/Users/${config.system.primaryUser}/.config/kanata/kanata.kbd"
                "--quiet"
              ];
              RunAtLoad = true;
              KeepAlive = true;
              StandardOutPath = "/var/log/kanata.log";
              StandardErrorPath = "/var/log/kanata.log";
            };
          };
        };
    };
}
