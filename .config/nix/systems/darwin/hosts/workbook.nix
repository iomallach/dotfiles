{ inputs, self, ... }:
{
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ./workbook/configuration.nix
      inputs.home-manager.darwinModules.home-manager
      self.lib.darwinOverlaysModule
      (
        { config, ... }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bak";
            extraSpecialArgs = {
              ghosttyHost = "workbook";
            };
            users.${config.system.primaryUser} = import ../../../homes/hosts/home-workbook.nix;
          };
        }
      )
    ];
  };
}
