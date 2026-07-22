{
  flake.modules.nixos.systemd =
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

  flake.modules.darwin.systemd =
    { config, pkgs, ... }:
    let
      karabinerVirtualHidDaemon = "${pkgs.karabiner-elements.driver}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
    in
    {
      # Kanata grabs physical keyboards directly, but on macOS it emits remapped keys
      # through Karabiner-DriverKit-VirtualHIDDevice. If this root daemon is not
      # running, Kanata can still grab input but cannot output keys, leaving the
      # configured keyboards apparently dead with `connect_failed asio.system:61`.
      # The daemon binary comes from nixpkgs so launchd does not depend on a
      # manually installed /Library copy.
      launchd.daemons."karabiner-vhid-daemon" = {
        serviceConfig = {
          Label = "org.pqrs.Karabiner-VirtualHIDDevice-Daemon";
          ProgramArguments = [
            karabinerVirtualHidDaemon
          ];
          UserName = "root";
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/var/log/karabiner-vhid-daemon.log";
          StandardErrorPath = "/var/log/karabiner-vhid-daemon.log";
        };
      };

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
}
