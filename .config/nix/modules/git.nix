{
  flake.modules.git =

    {
      extraPackages =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.gitu
            pkgs.lazygit
            pkgs.gh
          ];
        };

      base = {
        programs.git.enable = true;
        programs.git = {
          settings = {
            merge.tool = "codediff";
            "mergetool \"codediff\"".cmd = "nvim \"$MERGED\" -c \"CodeDiff merge \\\"$MERGED\\\"\"";
            diff.tool = "codediff";
            "difftool \"codediff\"".cmd = "nvim \"$LOCAL\" \"$REMOTE\" +\"CodeDiff file $LOCAL $REMOTE\"";
          };
        };
      };

      darwinWork = {
        programs.git = {
          settings = {
            user.name = "Alexander Butenko";
            user.email = "alexander.butenko@getyourguide.com";
          };
        };
      };

      nixos = {
        programs.git = {
          settings = {
            user.name = "Alexander Butenko";
            user.email = "a.butenko.o@gmail.com";
            init.defaultBranch = "main";
          };
        };
      };
    };
}
