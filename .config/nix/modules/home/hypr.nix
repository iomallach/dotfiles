{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/hypr";
}
