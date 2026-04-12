{
  inputs,
  self,
  config,
  ...
}:
{
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit self inputs; };
    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nixpkgs.overlays = [ self.overlays.default ];
      }
      (
        { config, ... }:
        {
          networking.hostName = "workbook";
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.primaryUser = "alexander.butenko";

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bak";
            users.${config.system.primaryUser} = {
              imports = [
                config.flake.modules.home-manager.base
                config.flake.modules.home-manager.darwinWork
              ];
            };
          };
        }
      )
    ];
  };
}
