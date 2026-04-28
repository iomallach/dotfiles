{ inputs, ... }:
{
  flake.modules.homeManager.editors =
    { pkgs, ... }:
    {
      programs = {
        helix = {
          enable = true;
          settings = {
            theme = "catppuccin_frappe";
            editor = {
              line-number = "relative";
              bufferline = "multiple";
              cursor-shape.insert = "bar";
            };
          };
        };
        neovide = {
          enable = false;
          settings.frame = "transparent";
        };
        neovim = {
          enable = true;
          defaultEditor = true;
          # package = inputs.neovim-nightly.packages."${pkgs.system}".default;
          package = pkgs.neovim-unwrapped;
          withPython3 = false; # no Python remote plugins used
          withRuby = false; # no Ruby remote plugins used
          sideloadInitLua = true;
        };
        obsidian.enable = true;
        zed-editor = {
          enable = true;
          package = if pkgs.stdenv.isDarwin then pkgs.zed-editor else pkgs.zed-editor-fhs;
        };
      };
    };

  flake.configSources = {
    doom.source = "doom";
    emacs.source = "emacs";
    nvim.source = "nvim";
    vscode.source = "vscode";
    zed.source = "zed";
  };
}
