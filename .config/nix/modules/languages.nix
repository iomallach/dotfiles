{
  flake.modules.generic.languages =
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
        uv
      ];
    };
}
