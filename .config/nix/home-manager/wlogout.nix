{ config, ... }:

{
  xdg.configFile."wlogout".source = config.lib.file.mkOutOfStoreSymlink (toString ../../wlogout);
}
