{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."scripts".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/scripts";
}
