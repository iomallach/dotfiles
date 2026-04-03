{ config, ... }:

{
  xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink (toString ../../rofi);
}
