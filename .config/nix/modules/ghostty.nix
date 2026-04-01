{
  lib,
  pkgs,
  ghosttyHost ? null,
  ...
}:

let
  defaultFont = {
    family = "Maple Mono NF";
    size = 14;
  };

  fontsByHost = {
    iomabook = defaultFont;
    tuxbook = defaultFont;
    workbook = defaultFont;
  };

  resolvedFont =
    if ghosttyHost != null && lib.hasAttr ghosttyHost fontsByHost then
      fontsByHost.${ghosttyHost}
    else
      defaultFont;
in
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      custom-shader = [
        "shaders/cursor_blaze_no_trail.glsl"
        "shaders/cursor_smear_fade.glsl"
      ];
      font-family = resolvedFont.family;
      font-family-bold = resolvedFont.family;
      font-family-italic = resolvedFont.family;
      font-family-bold-italic = resolvedFont.family;
      font-size = resolvedFont.size;
      theme = "onedark_vaporwave";
      macos-titlebar-style = "hidden";
      macos-option-as-alt = true;
      keybind = "shift+enter=text:\x1b\r";
    };
    themes = {
      Eldritch = {
        palette = [
          "0=#21222c"
          "1=#f9515d"
          "2=#37f499"
          "3=#e9f941"
          "4=#9071f4"
          "5=#f265b5"
          "6=#04d1f9"
          "7=#ebfafa"
          "8=#7081d0"
          "9=#f16c75"
          "10=#69F8B3"
          "11=#f1fc79"
          "12=#a48cf2"
          "13=#FD92CE"
          "14=#66e4fd"
          "15=#ffffff"
        ];
        background = "212337";
        foreground = "ebfafa";
        cursor-color = "37f499";
        selection-background = "bf4f8e";
        selection-foreground = "ebfafa";
      };
      onedark_vaporwave = {
        palette = [
          "0=#21222c"
          "1=#f9515d"
          "2=#37f499"
          "3=#e9f941"
          "4=#9071f4"
          "5=#f265b5"
          "6=#04d1f9"
          "7=#ebfafa"
          "8=#7081d0"
          "9=#f16c75"
          "10=#69F8B3"
          "11=#f1fc79"
          "12=#a48cf2"
          "13=#FD92CE"
          "14=#66e4fd"
          "15=#ffffff"
        ];
        background = "212337";
        foreground = "ebfafa";
        cursor-color = "37f499";
        selection-background = "bf4f8e";
        selection-foreground = "ebfafa";
      };
    };
  };

  xdg.configFile."ghostty/shaders" = {
    source = ../../ghostty/shaders;
    recursive = true;
  };
}
