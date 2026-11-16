{ inputs, ... }:
{
  flake.modules.darwin.ai =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca
      ];
    };

  flake.modules.darwin.herdr =
    { pkgs, ... }:
    {
      environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        herdr
        herdr-app
      ];
    };

  flake.modules.homeManager.ai =
    { pkgs, config, ... }:
    let
      # Generate upstream's integration in the store, never in the live Pi config.
      tuiosPiIntegration = pkgs.runCommand "tuios-pi-integration-${pkgs.tuios.version}" { } ''
        export HOME="$out"
        mkdir -p "$HOME/.pi/agent"
        ${pkgs.tuios}/bin/tuios integration install pi --command "${pkgs.tuios}/bin/tuios"
        test -s "$HOME/.pi/agent/extensions/tuios-agent-state.ts"
        test -s "$HOME/.agents/skills/tuios/SKILL.md"
      '';

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
      home.file = {
        ".pi/agent/extensions/tuios-agent-state.ts".source =
          "${tuiosPiIntegration}/.pi/agent/extensions/tuios-agent-state.ts";
        ".agents/skills/tuios/SKILL.md".source = "${tuiosPiIntegration}/.agents/skills/tuios/SKILL.md";
      };

      home.packages = with pkgs; [
        inputs.nixpkgs-opencode.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode
        claude-code
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
