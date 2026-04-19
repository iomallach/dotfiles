{
  flake.modules.homeManager.git =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        gitu
        lazygit
        gh
      ];

      programs.git = {
        enable = true;
        settings = {
          merge.tool = "codediff";
          "mergetool \"codediff\"".cmd = "nvim \"$MERGED\" -c \"CodeDiff merge \\\"$MERGED\\\"\"";
          diff.tool = "codediff";
          "difftool \"codediff\"".cmd = "nvim \"$LOCAL\" \"$REMOTE\" +\"CodeDiff file $LOCAL $REMOTE\"";
          init.defaultBranch = "main";
        };
      };
    };
}
