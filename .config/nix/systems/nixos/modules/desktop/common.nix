{ config, pkgs, ... }:
{
  catppuccin = {
    grub = {
      enable = true;
      flavor = "mocha";
    };
    gtk = {
      icon = {
        enable = true;
        flavor = "macchiato";
        accent = "blue";
      };
    };
  };

  fonts.packages = with pkgs; [
    maple-mono.NF
    nerd-fonts.symbols-only
    font-awesome
    material-design-icons
  ];

  programs.firefox.enable = false;
  programs.steam.enable = true;
  programs.nm-applet.enable = true;

  services.blueman.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.displayManager = {
    defaultSession = "hyprland";
    sddm.enable = true;
    sddm.wayland.enable = true;
    sddm.theme = "catppuccin-mocha-mauve";
  };

  systemd.services.systemd-rfkill.enable = false;
  systemd.sockets.systemd-rfkill.enable = false;

  services.dbus.packages = [ pkgs.networkmanager-openvpn ];

  systemd.services.amneziavpn-daemon = {
    description = "AmneziaVPN Service Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };

  services.udisks2.enable = true;

  environment.sessionVariables = {
    GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    XCURSOR_THEME = "Catppuccin-Macchiato-Blue-Cursors";
    XCURSOR_SIZE = "35";
    HYPRCURSOR_THEME = "catppuccin-macchiato-blue-cursors";
    HYPRCURSOR_SIZE = "35";
  };

  systemd.tmpfiles.rules = [
    "L+ /home/iomallach/.local/share/v2rayN/bin/xray/xray - - - - ${config.security.wrapperDir}/xray"
    "L+ /home/iomallach/.local/share/v2rayN/bin/geoip.dat - - - - ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat"
    "L+ /home/iomallach/.local/share/v2rayN/bin/geosite.dat - - - - ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat"
    "L+ /home/iomallach/.local/share/v2rayN/bin/sing_box/sing-box - - - - ${pkgs.sing-box}/bin/sing-box"
  ];
}
