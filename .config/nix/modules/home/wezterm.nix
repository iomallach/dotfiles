{ config, ... }:

let
  dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
in
{
  xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesConfig}/wezterm";
}
