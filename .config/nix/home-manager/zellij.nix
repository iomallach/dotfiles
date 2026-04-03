{ config, ... }:

{
  xdg.configFile."zellij".source = config.lib.file.mkOutOfStoreSymlink (toString ../../zellij);
}
