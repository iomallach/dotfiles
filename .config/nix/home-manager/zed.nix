{ config, ... }:

{
  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink (toString ../../zed);
}
