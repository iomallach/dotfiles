{
  inputs,
  self,
  config,
  ...
}:
let
  modules = config.flake.modules;
  externalModules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];
  genericModules = with modules.generic; [
    nix
    fonts
    languages
    shell
  ];
  darwinModules = with modules.darwin; [
    work
    browsers
    hardware
    media
    networking
    work
    systemd
    desktopGui
    keyIntercept
    homebrew
  ];
  hostBoundModules = [
    { nixpkgs.overlays = [ self.overlays.default ]; }
    (
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.mkalias
          pkgs.databricks-cli
        ];

        programs.zsh = {
          shellInit = ''
            eval "$(/opt/homebrew/bin/brew shellenv)"
          '';
        };

        networking.hostName = "workbook";
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.primaryUser = "alexander.butenko";
        users.users."alexander.butenko".home = "/Users/alexander.butenko";
      }
    )
  ];
  externalHomeManagerModules = [
    inputs.spicetify-nix.homeManagerModules.default
    inputs.paneru.homeModules.paneru
  ];
  homeManagerModules = with modules.homeManager; [
    xdgConfigs
    alexb
    desktopGui
    shell
    git
    spotify
    editors
    terminals
    ai
    {
      programs.ghostty.settings.font-size = 20;
    }
    {
      programs.zsh = {
        envExtra = ''
          export AWS_PROFILE="production/developer"
          export AWS_REGION="eu-central-1"
        '';

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
in
{
  flake.darwinConfigurations.workbook = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules =
      externalModules
      ++ genericModules
      ++ darwinModules
      ++ hostBoundModules
      ++ [
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bak";
            users."alexander.butenko" = {
              imports = externalHomeManagerModules ++ homeManagerModules;
            };
          };
        }
      ];

  };
}
