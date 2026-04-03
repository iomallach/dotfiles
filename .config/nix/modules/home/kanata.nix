{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."kanata".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/kanata";
}
