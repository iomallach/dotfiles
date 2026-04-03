{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/niri";
}
