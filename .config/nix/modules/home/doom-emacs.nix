{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/doom";
  xdg.configFile."emacs".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/emacs";
}
