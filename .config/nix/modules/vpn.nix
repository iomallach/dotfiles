{
  flake.modules.nixos.vpn =
    { pkgs, ... }:
    let
      # Capability wrappers must target ELF executables, not shell launchers.
      xray = pkgs.xray.override { makeWrapper = pkgs.makeBinaryWrapper; };
    in
    {
      environment.systemPackages = with pkgs; [
        xray
        sing-box
        v2rayn
        amnezia-vpn
        amneziawg-tools
      ];

      security.wrappers.xray = {
        source = "${xray}/bin/xray";
        capabilities = "cap_net_admin,cap_net_bind_service=+eip";
        owner = "root";
        group = "root";
        permissions = "u+rx,g+x,o+x";
      };
    };
}
