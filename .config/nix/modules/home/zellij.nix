{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."zellij".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/zellij";
}
