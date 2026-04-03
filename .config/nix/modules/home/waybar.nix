{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/waybar";
}
