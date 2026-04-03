{ config, ... }:

{
  xdg.configFile."borders".source = config.lib.file.mkOutOfStoreSymlink (toString ../../borders);
}
