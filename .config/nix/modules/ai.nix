{
  flake.modules.homeManager.ai =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        opencode
        claude-code
        crush
        copilot-language-server
        (pkgs.symlinkJoin {
          name = "pi-coding-agent";
          buildInputs = [ pkgs.makeWrapper ];
          paths = [ pkgs.pi-coding-agent ];
          postBuild = ''
            wrapProgram $out/bin/pi \
            --set NPM_CONFIG_PREFIX ${config.home.homeDirectory}/.pi/npm/ \
            --prefix PATH : ${
              pkgs.lib.makeBinPath [
                pkgs.nodejs_latest
              ]
            }
          '';
        })
      ];
    };

  flake.configSources.opencode.source = "opencode";
}
