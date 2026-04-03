{ config, ... }:

{
  xdg.configFile."scripts".source = config.lib.file.mkOutOfStoreSymlink (toString ../../scripts);
}
