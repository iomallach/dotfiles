{
  config,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.tuxbook = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with config.flake.modules; [
      inputs.tuxedo-nixos.nixosModules.default
      inputs.catppuccin.nixosModules.catppuccin
      inputs.home-manager.nixosModules.home-manager
      generic.nix
      nixos.boot
      nixos.browsers
      generic.fonts
      generic.gaming
      generic.languages
      nixos.hardware
      nixos.media
      nixos.networking
      nixos.services
      generic.shell
      nixos.systemd
      generic.iomallach
      nixos.desktopGui
      nixos.vpn
      (
        { pkgs, ... }:
        {
          environment.sessionVariables = {
            GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
            XCURSOR_THEME = "catppuccin-macchiato-blue-cursors";
            XCURSOR_SIZE = "35";
            HYPRCURSOR_THEME = "catppuccin-macchiato-blue-cursors";
            HYPRCURSOR_SIZE = "35";
          };

          environment.systemPackages = [
            pkgs.powertop
          ];
        }
      )
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.iomallach = {
            imports = with config.flake.modules.homeManager; [
              inputs.spicetify-nix.homeManagerModules.default
              inputs.dms.homeModules.dank-material-shell

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
          };
        };
      }
    ];
  };
}
