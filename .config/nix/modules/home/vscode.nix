{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."vscode".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/vscode";
}
