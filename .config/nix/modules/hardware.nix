{ inputs, ... }:
{
  flake.modules.nixos.hardware =
    {
      config,
      modulesPath,
      lib,
      pkgs,
      ...
    }:
    {
      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = true;
        };
        tuxedo-control-center = {
          enable = true;
          package = inputs.tuxedo-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (
            old:
            let
              desktopItem = pkgs.makeDesktopItem {
                name = "tuxedo-control-center";
                desktopName = "TUXEDO Control Center";
                comment = "An application helping you to tune your TUXEDO";
                exec = "tuxedo-control-center";
                icon = "tuxedo-control-center";
                categories = [ "System" ];
                keywords = [ "TCC" ];
                extraConfig.X-KDE-Shortcuts = "Meta+Alt+F6";
              };
            in
            {
              # Compatibility with the 3.1.3 source layout; remove when fixed in tuxedo-nixos.
              # Application patches do not affect package-lock.json or the npm cache.
              npmDeps = old.npmDeps.overrideAttrs {
                postPatch = "";
              };
              prePatch = (old.prePatch or "") + ''
                # Upstream generates this with electron-builder, which the Nix build bypasses.
                cp ${desktopItem}/share/applications/tuxedo-control-center.desktop src/dist-data/
              '';
              # Skip format-files: it chmods a bundled tccd that the Nix build does not produce.
              buildPhase =
                lib.replaceStrings
                  [ "npm run copy-files\n" ]
                  [
                    ''
                      npm run copy-package-json
                      npm run copy-dist-files
                      npm run copy-cameractls
                    ''
                  ]
                  old.buildPhase;
              installPhase =
                lib.replaceStrings
                  [ "com.tuxedocomputers.tccd.policy" "com.tuxedocomputers.tccd.conf" ]
                  [ "com.tuxedocomputers.tccd-service.policy" "com.tuxedocomputers.tccd-dbus.conf" ]
                  old.installPhase;
              postPatch = (old.postPatch or "") + ''
                # A separate Electron binary reports app.isPackaged=false even for this installed app.
                substituteInPlace src/e-app/backendAPIs/utilsAPI.ts \
                  --replace-fail 'export const environmentIsProduction: boolean = app.isPackaged;' \
                    'export const environmentIsProduction: boolean = true;'

                # Camera discovery and controls must not depend on the desktop session's PATH.
                substituteInPlace src/e-app/backendAPIs/webcamAPI.ts \
                  --replace-fail 'python3 ' '${lib.getExe pkgs.python3} '
                substituteInPlace src/cameractrls/cameractrls.py \
                  --replace-fail '#!/usr/bin/env python3' '#!${lib.getExe pkgs.python3}'

                # Use NixOS's setuid wrapper, not an unprivileged pkexec from a package's bin directory.
                substituteInPlace src/e-app/backendAPIs/configAPI.ts src/e-app/backendAPIs/webcamAPI.ts \
                  --replace-fail 'pkexec ' '${config.security.wrapperDir}/pkexec '

                # Match the installed daemon while preserving upstream's auth_admin_keep policy.
                substituteInPlace src/dist-data/com.tuxedocomputers.tccd-service.policy \
                  --replace-fail '/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/service/tccd' \
                    "$out/bin/tccd"
              '';
            }
          );
        };
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

  flake.modules.darwin.hardware = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 5;

    nixpkgs.hostPlatform = "aarch64-darwin";
  };
}
