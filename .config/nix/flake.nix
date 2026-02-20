{
  description = "Unified nix-darwin, NixOS, and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Shared inputs
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    # homebrew (darwin only)
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

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

    # NixOS specific inputs
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # tuxedo-specific modules (control center, keyboard, etc.)
    tuxedo-nixos.url = "github:sund3RRR/tuxedo-nixos";

    # spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # catppuccin nixos modules
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      neovim-nightly,
      nix-homebrew,
      kanata-tray,
      zen-browser,
      tuxedo-nixos,
      spicetify-nix,
      catppuccin,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      # macOS configuration with nix-darwin
      darwinConfigurations."macbookair" = nix-darwin.lib.darwinSystem {
        modules = [
          ./darwin/configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          ./darwin/modules/homebrew.nix
          {
            # Set Git commit hash for darwin-version.
            system.configurationRevision = self.rev or self.dirtyRev or null;

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
          # Make neovim-nightly and kanata-tray available in darwin config
          {
            nixpkgs.overlays = [
              (final: prev: {
                neovim-nightly = neovim-nightly.packages.${prev.system};
                kanata-tray = kanata-tray.packages.${prev.system};
              })
            ];
          }
        ];
      };

      # Debian/Linux configuration with home-manager
      homeConfigurations."debian" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config.allowUnfree = true;
          overlays = [
            # Apply neovim-nightly overlay
            neovim-nightly.overlays.default
          ];
        };

        # Pass inputs to home.nix
        extraSpecialArgs = { inherit self; };

        modules = [
          ./home-manager/home-linux.nix
        ];
      };

      # NixOS configuration
      nixosConfigurations."tuxbook" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          tuxedo-nixos.nixosModules.default
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.iomallach = import ./nixos/home-manager.nix;
          }
        ];
      };

      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nil
              pkgs.nixd
              pkgs.nixfmt
            ];
          };
        }
      );
    };
}
