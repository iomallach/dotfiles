{
  inputs,
  self,
  config,
  ...
}:
{
  flake.darwinConfigurations.macbookair = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit self inputs; };
    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nixpkgs.overlays = [ self.overlays.default ];
      }
      config.flake.modules.homebrew
      (
        { config, ... }:
        {
          networking.hostName = "macbookair";
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.primaryUser = "iomallach";

          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "iomallach";
            autoMigrate = true;
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${config.system.primaryUser} = {
              imports = [
                config.flake.modules.home-manager.base
                config.flake.modules.home-manager.darwinPrivate
              ];
            };
          };
        }
      )
    ];
  };
}
