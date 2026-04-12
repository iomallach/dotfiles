{
  flake.modules.hardware = {
    nixos =
      {
        config,
        modulesPath,
        lib,
        ...
      }:
      {
        hardware = {
          bluetooth = {
            enable = true;
            powerOnBoot = true;
          };
          tuxedo-control-center.enable = true;
          tuxedo-drivers.enable = true;
          tuxedo-keyboard.enable = true;
          tuxedo-rs = {
            enable = false;
            tailor-gui.enable = false;
          };
        };

        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/564fa550-2939-4164-a588-cf8e41964414";
          fsType = "ext4";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/9A8D-BB6A";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };

        swapDevices = [
          { device = "/dev/disk/by-uuid/db7c0045-932b-4c1d-a890-39f1a13b6d37"; }
        ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        system.stateVersion = "25.11";
      };

    darwin = {
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  };
}
