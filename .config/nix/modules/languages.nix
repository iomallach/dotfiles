{
  flake.modules.languages =

    {
      base =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            lua54Packages.lua
            gnumake
            tree-sitter
            actionlint
            cmake
            hadolint
            shellcheck
            copilot-language-server
          ];
        };

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.uv ];

          homebrew = {
            brews = [
              "nasm"
            ];
          };
        };
    };
}
