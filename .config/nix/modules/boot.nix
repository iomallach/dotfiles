{
  flake.modules.nixos.boot =
    { pkgs, lib, ... }:
    {
      #TODO: this might not be there if it is only the theme
      catppuccin = {
        grub = {
          enable = true;
          flavor = "mocha";
        };
        gtk = {
          icon = {
            enable = true;
            flavor = "macchiato";
            accent = "blue";
          };
        };
      };

      boot = {
        initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "thunderbolt"
          "usb_storage"
          "sd_mod"
          "sdhci_pci"
        ];
        initrd.kernelModules = [ ];

        kernelModules = [
          "kvm-amd"
          "tun"
        ];

        extraModulePackages = [ ];

        kernelParams = [
          "acpi.ec_no_wakeup=1" # acpi wakeup issues
          "amd_pstate=active" # amd power management
          # "amdgpu.dcdebugmask=0x10" # wayland slowdonws/freezes
          # "tuxedo_keyboard.mode=0"
          # "tuxedo_keyboard.brightness=25"
          # "tuxedo_keyboard.color_left=0x0000ff"
        ];

        loader = {
          grub = {
            enable = true;
            configurationLimit = 5;
            device = "nodev";
            efiSupport = true;
            #      useOSProber = true;

            # presentation
            font = lib.mkForce "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSansMono.ttf";
            fontSize = 28;
            # gfxmodeEfi = "1920x1080";
          };
          efi.canTouchEfiVariables = true;
        };

        # Use the systemd-boot EFI boot loader.
        # boot.loader.systemd-boot.enable = true;
        # boot.loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_latest.extend (
          _final: prev: {
            tuxedo-drivers = prev.tuxedo-drivers.overrideAttrs (old: {
              # 4.25.0 replaces ACPI driver APIs removed by Linux 7.3.
              version = "4.25.0";
              src = pkgs.fetchFromGitLab {
                group = "tuxedocomputers";
                owner = "development/packages";
                repo = "tuxedo-drivers";
                rev = "v4.25.0";
                hash = "sha256-AER+JPl3lem1OFV51VdOZAnr3Uy1BFSpEJNrE+shYis=";
              };
              # NixOS runs depmod after assembling the complete module tree.
              makeFlags = old.makeFlags ++ [ "DEPMOD=true" ];
              postInstall = builtins.replaceStrings
                [ "usr/lib/udev/rules.d" ]
                [ "files/usr/lib/udev/rules.d" ]
                old.postInstall;
              postPatch = (old.postPatch or "") + ''
                # Let recursive make inherit flags without exposing signing expressions to the shell.
                substituteInPlace Makefile \
                  --replace-fail 'make -C' '$(MAKE) -C' \
                  --replace-fail ' $(MAKEFLAGS)' ""
              '';
            });
          }
        );

        kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };

      };
    };
}
