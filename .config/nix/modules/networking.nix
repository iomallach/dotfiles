{
  flake.modules.nixos.networking =
    { pkgs, ... }:

    {
      programs.nm-applet.enable = true;

      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };

      environment.systemPackages = with pkgs; [
        networkmanager-openvpn
      ];

      networking = {
        networkmanager = {
          enable = true;
          plugins = with pkgs; [
            networkmanager-openvpn
          ];
        };

        wireguard.enable = true;

        firewall.allowedUDPPorts = [ 5353 ];

        hostName = "tuxbook";
      };
    };

  flake.modules.darwin.networking = {
    homebrew = {
      brews = [
        "ifstat"
      ];
    };
  };
}
