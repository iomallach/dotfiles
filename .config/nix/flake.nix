{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay/cd02956a1f6376f524a10b94893bc9408b476322";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    # homebrew
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Kanata-tray
    kanata-tray.url = "github:rszyma/kanata-tray";
    kanata-tray.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      neovim-nightly,
      nix-homebrew,
      kanata-tray,
      ...
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          nixpkgs.config.allowUnfree = true;
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            mkalias
            vim
            neovim-nightly.packages.${pkgs.system}.default
            qmk # split keyboard
            fzf
            eza
            asciiquarium
            zed-editor
            uv
            nix-search-tv
            figlet # ascii prints
            bat
            jq
            cmatrix
            curl
            wget
            blueutil
            btop
            fd
            helix
            lazygit
            gitu
            neovide
            nowplaying-cli
            switchaudio-osx
            yazi
            openvpn
            ripgrep
            starship # prompt
            tmux
            tldr
            zoxide
            (lua54Packages.lua.withPackages (
              ps: with ps; [
                luasocket
                cjson
                luasec
              ]
            ))
            ghostty-bin
            # nix dev
            nixfmt-rfc-style # formatter
            nil # lsp
            nixd # lsp 2
            crush
            nvd # package diff between generations
            kanata # keyboard remapping
            kanata-tray.packages.${pkgs.system}.default
          ];

          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications.
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';
          # Add Homebrew to PATH
          # environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Because of homebrew.enable?
          system.primaryUser = "iomallach";

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."macbookair" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/homebrew.nix
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "iomallach";

              # Automatically migrate existing Homebrew installations
              autoMigrate = true;
            };
          }
        ];
      };
    };
}
