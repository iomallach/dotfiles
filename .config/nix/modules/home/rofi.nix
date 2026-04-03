{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/rofi";
}
