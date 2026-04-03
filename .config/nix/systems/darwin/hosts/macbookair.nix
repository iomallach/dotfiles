{ inputs, self, ... }:
{
  flake.darwinConfigurations.macbookair = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ./macbookair/configuration.nix
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew
      ../modules/homebrew.nix
      (
        { config, ... }:
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;

          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "iomallach";
            autoMigrate = true;
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              ghosttyHost = "iomabook";
            };
            users.${config.system.primaryUser} = import ../../../homes/hosts/home-macbookair.nix;
          };
        }
      )
      self.lib.darwinOverlaysModule
    ];
  };
}
