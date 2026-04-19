{
  config,
  inputs,
  ...
}:
let
  externalModules = [
    inputs.tuxedo-nixos.nixosModules.default
    inputs.catppuccin.nixosModules.catppuccin
    inputs.home-manager.nixosModules.home-manager
  ];
  genericModules = with config.flake.modules.generic; [
    nix
    fonts
    gaming
    languages
    shell
    iomallach
  ];
  nixosModules = with config.flake.modules.nixos; [
    boot
    browsers
    hardware
    media
    networking
    services
    systemd
    desktopGui
    vpn
  ];
  hostBoundModules = [
    (
      { pkgs, ... }:
      {
        environment.sessionVariables = {
          GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
        };

        environment.systemPackages = [
          pkgs.powertop
        ];
      }
    )
  ];
  externalHomeManagerModules = [
    inputs.spicetify-nix.homeManagerModules.default
    inputs.dms.homeModules.dank-material-shell
  ];
  homeManagerModules = with config.flake.modules.homeManager; [
    xdgConfigs
    iomallach
    editors
    terminals
    anki
    git
    pdf
    shell
    spotify
    ai
  ];
in
{
  flake.nixosConfigurations.tuxbook = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      externalModules
      ++ genericModules
      ++ nixosModules
      ++ hostBoundModules
      ++ [
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.iomallach = {
              imports = externalHomeManagerModules ++ homeManagerModules;
            };
          };
        }
      ];
  };
}
