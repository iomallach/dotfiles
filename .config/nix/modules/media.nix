{
  flake.modules.nixos.media =
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

  flake.modules.darwin.media =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        nowplaying-cli
        switchaudio-osx
      ];
    };
}
