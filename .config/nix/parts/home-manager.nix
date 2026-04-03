{ inputs, self, ... }:
{
  flake.homeConfigurations.debian = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-linux";
      config.allowUnfree = true;
      overlays = [
        inputs.neovim-nightly.overlays.default
      ];
    };

    extraSpecialArgs = { inherit self; };

    modules = [
      ../homes/hosts/home-rpi.nix
    ];
  };
}
