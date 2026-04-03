{ config, ... }:

{
  xdg.configFile."karabiner".source = config.lib.file.mkOutOfStoreSymlink (toString ../../karabiner);
}
