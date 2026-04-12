{
  flake.modules.users =

    {
      iomallach =
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
            packages = with pkgs; [
              tree
            ];
            shell = pkgs.zsh;
          };
        };
    };
}
