{ inputs, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };
  networking.wireguard.enable = true;

  time.timeZone = "Europe/Berlin";

  security.rtkit.enable = true;

  users.users.iomallach = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly.packages."${pkgs.system}".default;
  };
  programs.zsh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  networking.firewall.allowedUDPPorts = [ 5353 ];
}
