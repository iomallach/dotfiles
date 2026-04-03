{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."borders".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/borders";
}
