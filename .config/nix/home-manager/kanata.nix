{ config, ... }:

{
  xdg.configFile."kanata".source = config.lib.file.mkOutOfStoreSymlink (toString ../../kanata);
}
