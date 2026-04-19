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
    modules = with modules; [
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew
      { nixpkgs.overlays = [ self.overlays.default ]; }
      work
      generic.nix
      darwin.browsers
      generic.fonts
      generic.languages
      darwin.hardware
      darwin.media
      darwin.networking
      darwin.work
      generic.shell
      darwin.systemd
      darwin.desktopGui
      darwin.keyIntercept
      darwin.homebrew
      (
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.mkalias
            databricks-cli
          ];

          programs.zsh = {
            shellInit = ''
              eval "$(/opt/homebrew/bin/brew shellenv)"
            '';
          };
        }
      )
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
            imports = with modules.homeManager; [
              inputs.spicetify-nix.homeManagerModules.default
              inputs.paneru.homeModules.paneru

              xdgConfigs
              alexb
              desktopGui
              shell
              git
              spotify
              editors
              terminals
              {
                programs.ghostty.settings.font-size = 20;
              }
              ai
              {
                programs.zsh = {
                  shellAliases = {
                    load-ca-auth = "export UV_INDEX_CODEARTIFACT_USERNAME=aws && export UV_INDEX_CODEARTIFACT_PASSWORD=$(aws codeartifact get-authorization-token --profile production/developer --domain getyourguide --domain-owner 130607246975 --query authorizationToken --output text)";
                    c = "clear";
                  };

                  initExtra = ''
                    # XDG
                    export XDG_CONFIG_HOME="$HOME/.config"

                    # Enable vi mode
                    bindkey -v

                    # Edit command in $EDITOR with C-x C-e
                    autoload -U edit-command-line
                    zle -N edit-command-line
                    bindkey '^xe' edit-command-line
                    bindkey '^x^e' edit-command-line

                    # Extra completions
                    fpath=(~/.zsh/completions $fpath)

                    # nvm
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
                    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
                    nvm use &>/dev/null

                    # SDKMAN (must be last)
                    export SDKMAN_DIR="$HOME/.sdkman"
                    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
                  '';
                };
              }
            ];
          };
        };
      }
    ];
  };
}
