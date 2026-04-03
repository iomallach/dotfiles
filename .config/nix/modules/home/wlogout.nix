{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."wlogout".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/wlogout";
}
