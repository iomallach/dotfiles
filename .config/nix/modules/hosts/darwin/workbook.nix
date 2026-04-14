{
  inputs,
  self,
  config,
  ...
}:
{
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = with config.flake.modules; [
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew
      ai
      nix
      browsers.darwin
      fonts.darwin
      hardware.darwin
      languages.darwin
      media.darwin
      networking.darwin
      shell.core.base
      shell.core.darwinWork
      systemd.darwin
      desktopGui.darwin
      git.extraPackages
      spotify.package
      keyIntercept.darwin
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
            users."alexander.butenko" = {
              imports = with config.flake.modules; [
                config.flake.modules.home-manager.base
                config.flake.modules.home-manager.darwinWork
                inputs.spicetify-nix.homeManagerModules.default

                xdgConfigs
                homeManager.base
                homeManager.darwinWork
                homebrew
                shell.base
                git.base
                spotify.spicetify
                editors
                terminals
              ];
            };
          };
        }
      )
    ];
  };
}
