{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/opencode";
}
