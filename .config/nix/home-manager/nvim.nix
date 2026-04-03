{ config, ... }:

{
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink (toString ../../nvim);
}
