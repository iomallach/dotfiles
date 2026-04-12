{
  flake.modules.media =

    {
      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            playerctl
            cava
            cameractrls-gtk4
            brightnessctl
          ];

          security.rtkit.enable = true;
        };

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            nowplaying-cli
            switchaudio-osx
          ];
        };
    };
}
