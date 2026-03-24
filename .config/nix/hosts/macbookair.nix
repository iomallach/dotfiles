{ inputs, self, ... }:
{
  flake.darwinConfigurations.macbookair = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ../darwin/configuration.nix
      inputs.nix-homebrew.darwinModules.nix-homebrew
      ../darwin/modules/homebrew.nix
      {
        system.configurationRevision = self.rev or self.dirtyRev or null;

        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = "iomallach";
          autoMigrate = true;
        };
      }
      self.lib.darwinOverlaysModule
    ];
  };
}
