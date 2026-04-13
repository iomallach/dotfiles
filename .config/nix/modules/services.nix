{
  flake.modules.services.nixos =
    { pkgs, ... }:
    {
      services = {
        blueman.enable = true;

        upower.enable = true;

        power-profiles-daemon.enable = false;

        tlp = {
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

        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        displayManager = {
          defaultSession = "niri";
          sddm.enable = true;
          sddm.wayland.enable = true;
          sddm.theme = "catppuccin-mocha-mauve";
        };

        dbus.packages = [ pkgs.networkmanager-openvpn ];

        resolved = {
          enable = true;
          dnssec = "false";
        };

        logind = {
          settings.Login = {
            HandleLidSwitch = "suspend";
            HandleLidSwitchExternalPower = "ignore";
            HandleLidSwitchDocked = "ignore";
          };
        };

        udisks2.enable = true;
      };
    };
}
