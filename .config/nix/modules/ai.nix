{
  flake.modules.homeManager.ai =
    { pkgs, config, ... }:
    let
      babysitter-sdk = pkgs.writeShellApplication {
        name = "babysitter";
        runtimeInputs = [
          pkgs.nodejs_22
        ];
        text = ''
          exec ${pkgs.nodejs_22}/bin/npx \
          -y \
          -p @a5c-ai/babysitter-sdk \
          babysitter "$@"
        '';
      };
    in
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
        babysitter-sdk
      ];
    };

  flake.configSources.opencode.source = "opencode";
}
