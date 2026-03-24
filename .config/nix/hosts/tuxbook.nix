{ inputs, ... }:
{
  flake.nixosConfigurations.tuxbook = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      desktopProfile = "hyprland";
    };
    modules = [
      ../nixos/configuration.nix
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
