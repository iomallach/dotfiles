{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_frappe";

      editor = {
        line-number = "relative";
        bufferline = "multiple";
        cursor-shape.insert = "bar";
      };
    };
  };
}
