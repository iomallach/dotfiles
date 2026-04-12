{ inputs, ... }:
{
  flake.modules.browsers = {
    nixos =
      {
        config,
        pkgs,
        ...
      }:
      let
        zenPackage = inputs.zen-browser.packages."${pkgs.system}".default;
        zenProfileDir = "${config.users.users.iomallach.home}/.zen/main";
        zenWrapper = pkgs.writeShellScriptBin "zen" ''
          exec ${zenPackage}/bin/zen-beta \
            -profile "${zenProfileDir}" \
            --no-remote "$@"
        '';
      in
      {
        programs.firefox.enable = false;

        environment.systemPackages = with pkgs; [
          brave

          # Zen
          zenWrapper
          # Desktop entry for zen browser (non-beta command)
          (makeDesktopItem {
            name = "zen";
            desktopName = "Zen Browser";
            exec = "${zenWrapper}/bin/zen --name zen %U";
            icon = "zen-browser";
            comment = "Browse the Web";
            genericName = "Web Browser";
            categories = [
              "Network"
              "WebBrowser"
            ];
            mimeTypes = [
              "text/html"
              "text/xml"
              "application/xhtml+xml"
              "application/vnd.mozilla.xul+xml"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
            ];
            startupNotify = true;
            extraConfig = {
              StartupWMClass = "zen";
            };
            actions = {
              new-window = {
                name = "New Window";
                exec = "${zenWrapper}/bin/zen --new-window %U";
              };
              new-private-window = {
                name = "New Private Window";
                exec = "${zenWrapper}/bin/zen --private-window %U";
              };
              profile-manager-window = {
                name = "Profile Manager";
                exec = "${zenWrapper}/bin/zen --ProfileManager";
              };
            };
          })
        ];
      };

    darwin = {
      homebrew = {
        casks = [
          "arc"
          "zen"
        ];
      };
    };
  };
}
