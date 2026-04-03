{ config, ... }:

{
  xdg.configFile."vscode".source = config.lib.file.mkOutOfStoreSymlink (toString ../../vscode);
}
