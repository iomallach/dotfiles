{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  programs.alacritty = {
    enable = false;
    settings = {
      import = [ "~/.config/alacritty/themes/zenburn.toml" ];
      shell = {
        program = "/bin/zsh";
        args = [ "--login" ];
      };

      cursor.style = "Block";

      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        size = 16.0;
      };

      window.option_as_alt = "OnlyLeft";
    };
  };

  xdg.configFile."alacritty/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/alacritty/themes";
}
