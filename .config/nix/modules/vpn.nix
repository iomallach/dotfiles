{
  flake.modules.vpn =

    {
      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            xray
            sing-box
            v2rayn
            amnezia-vpn
            amneziawg-tools
          ];

          security.wrappers.xray = {
            source = "${pkgs.xray}/bin/xray";
            capabilities = "cap_net_admin,cap_net_bind_service=+eip";
            owner = "root";
            group = "root";
            permissions = "u+rx,g+x,o+x";
          };
        };
    };
}
