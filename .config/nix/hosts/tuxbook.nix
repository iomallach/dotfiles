{ inputs, ... }:
{
  flake.nixosConfigurations.tuxbook = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      desktopProfile = "hyprland";
    };
    modules = [
      {
        imports = [
          ../nixos/hardware-configuration.nix
          ../nixos/boot.nix
          ../modules/nixos/base.nix
          ../modules/nixos/desktop/profiles.nix
          ../nixos/packages/core.nix
          ../nixos/packages/desktop.nix
          ../nixos/packages/apps.nix
        ];

        networking.hostName = "tuxbook";

        hardware = {
          bluetooth = {
            enable = true;
            powerOnBoot = true;
          };
          tuxedo-control-center.enable = true;
          tuxedo-drivers.enable = true;
          tuxedo-keyboard.enable = true;
          tuxedo-rs = {
            enable = false;
            tailor-gui.enable = false;
          };
        };

        system.stateVersion = "25.11";
      }
      inputs.tuxedo-nixos.nixosModules.default
      inputs.catppuccin.nixosModules.catppuccin
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.iomallach = import ../nixos/home-manager.nix;
      }
    ];
  };
}
