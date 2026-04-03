{ config, ... }:

{
  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink (toString ../../waybar);
}
