{
  inputs,
  lib,
  config,
  ...
}:
let
  flakeConfig = config;
in
{
  imports = [
    inputs.nix-darwin.flakeModules.default
    inputs.flake-parts.flakeModules.modules
  ];

  options.flake.configSources = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { ... }:
        {
          options = {
            source = lib.mkOption {
              type = lib.types.oneOf [
                lib.types.str
                lib.types.path
              ];
            };
            target = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            recursive = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            executable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            absolute = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        }
      )
    );
    default = { };
  };

  config = {
    flake.modules.homeManager.xdgConfigs =
      { config, lib, ... }:
      let
        dotfilesConfig = "${config.home.homeDirectory}/dotfiles/.config";
        mkSource =
          value:
          let
            sourcePath = toString value.source;
            resolvedPath =
              if value.absolute || lib.hasPrefix "/" sourcePath then
                sourcePath
              else
                "${dotfilesConfig}/${sourcePath}";
          in
          config.lib.file.mkOutOfStoreSymlink resolvedPath;
      in
      {
        xdg.configFile = lib.mapAttrs' (
          name: value:
          let
            targetName = if value.target == null then name else value.target;
          in
          lib.nameValuePair targetName {
            source = mkSource value;
          }
          // lib.optionalAttrs value.recursive { recursive = true; }
          // lib.optionalAttrs value.executable { executable = true; }
        ) flakeConfig.flake.configSources;
      };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
