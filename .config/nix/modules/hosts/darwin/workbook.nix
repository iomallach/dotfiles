{
  inputs,
  self,
  config,
  ...
}:
let
  modules = config.flake.modules;
in
{
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = with config.flake.modules; [
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew
      { nixpkgs.overlays = [ self.overlays.default ]; }
      work
      ai
      nix
      browsers.darwin
      fonts.darwin
      hardware.darwin
      languages.darwin
      languages.base
      media.darwin
      networking.darwin
      shell.core.base
      shell.core.darwinWork
      shell.darwinWork.system
      systemd.darwin
      desktopGui.darwin.system
      git.extraPackages
      spotify.package
      keyIntercept.darwin
      homebrew
      {
        networking.hostName = "workbook";
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.primaryUser = "alexander.butenko";
        users.users."alexander.butenko".home = "/Users/alexander.butenko";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-bak";
          users."alexander.butenko" = {
            imports = with modules; [
              inputs.spicetify-nix.homeManagerModules.default
              inputs.paneru.homeModules.paneru

              xdgConfigs
              homeManager.base
              homeManager.darwinWork
              desktopGui.darwin.homeManager
              shell.base
              shell.darwinWork.homeManager
              git.base
              git.darwinWork
              spotify.spicetify
              editors
              terminals
              {
                programs.ghostty.settings.font-size = 20;
              }
            ];
          };
        };
      }
    ];
  };
}
