{ inputs, self, ... }:
{
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ../darwin_work/configuration.nix
      inputs.home-manager.darwinModules.home-manager
      self.lib.darwinOverlaysModule
      ({ config, ... }:
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${config.system.primaryUser} = import ../home-manager/home-darwin.nix;
        };
      })
    ];
  };
}
