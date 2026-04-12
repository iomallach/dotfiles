{ config, inputs, ... }:
{
  flake.nixosConfigurations.tuxbook = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with config.flake.modules; [
      inputs.tuxedo-nixos.nixosModules.default
      inputs.catppuccin.nixosModules.catppuccin
      inputs.home-manager.nixosModules.home-manager
      ai
      nix
      boot.nixos
      browsers.nixos
      fonts.base
      gaming
      hardware.nixos
      languages.base
      media.nixos
      networking.nixos
      services.nixos
      shell.core.base
      shell.nixos
      systemd.nixos
      users.iomallach
      desktopGui.extraPackages
      desktopGui.nixos
      vpn.nixos
      git.extraPackages
      spotify.package
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.iomallach = {
            imports = with config.flake.modules; [
              inputs.spicetify-nix.homeManagerModules.default
              inputs.dms.homeModules.dank-material-shell

              xdgConfigs
              homeManager.base
              homeManager.nixos
              editors
              terminals
              anki
              git.base
              git.nixos
              pdf
              shell.base
              spotify.spicetify
            ];
          };
        };
      }
    ];
  };
}
