{ config, ... }:

{
  xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink (toString ../../doom);
  xdg.configFile."emacs".source = config.lib.file.mkOutOfStoreSymlink (toString ../../emacs);
}
