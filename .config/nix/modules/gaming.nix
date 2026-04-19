{
  flake.modules.generic.gaming =
    { pkgs, ... }:
    {
      programs.steam.enable = true;
      environment.systemPackages = with pkgs; [
        xwayland-satellite
      ];
    };
}
