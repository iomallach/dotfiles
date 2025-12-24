{
  config,
  lib,
  pkgs,
  ...
}:
{

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "acpi.ec_no_wakeup=1" # acpi wakeup issues
    "amdgpu.dcdebugmask=0x10" # wayland slowdonws/freezes
    "amd_pstate=active" # amd power management
    # "tuxedo_keyboard.mode=0"
    # "tuxedo_keyboard.brightness=25"
    # "tuxedo_keyboard.color_left=0x0000ff"
  ];

  boot.loader = {
    grub = {
      enable = true;
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

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "tun" ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
