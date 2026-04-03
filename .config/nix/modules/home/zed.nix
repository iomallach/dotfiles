{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/zed";
}
