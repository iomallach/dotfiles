{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/karabiner";
}
