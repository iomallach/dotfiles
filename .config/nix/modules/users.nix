{
  flake.modules.generic.iomallach =
    { pkgs, ... }:

    {
      users.users.iomallach = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
        ];
        shell = pkgs.zsh;
      };
    };
}
