{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Custom inputs - just like in nix-darwin!
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Add any other flake inputs you want
    # example.url = "github:user/repo";
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly, ... }@inputs:
    let
      system = "aarch64-linux";  # or "aarch64-linux" for ARM
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # Apply neovim-nightly overlay
          neovim-nightly.overlays.default
        ];
      };
    in {
      homeConfigurations."iomallach" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        # Pass inputs to home.nix
        extraSpecialArgs = { inherit inputs; };
        
        modules = [
          ./home.nix
          # You can add more modules here
        ];
      };
    };
}
