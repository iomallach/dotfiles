{ inputs, self, ... }:
{
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ../darwin_work/configuration.nix
      self.lib.darwinOverlaysModule
    ];
  };
}
