{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  zenPackage = inputs.zen-browser.packages."${pkgs.system}".default;
  zenProfileDir = "${config.users.users.iomallach.home}/.zen/main";
  zenWrapper = pkgs.writeShellScriptBin "zen" ''
    exec ${zenPackage}/bin/zen \
      -profile "${zenProfileDir}" \
      --no-remote "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    # Terminal
    ghostty
    kitty

    # Mutliplexer
    tmux
    zellij

    # CLI
    claude-code
    crush
    opencode
    playerctl
    powertop
    cava

    # Dev
    rustup
    clang

    # Editor & Notes
    zed-editor-fhs
    obsidian

    # Pdf
    zathura

    # Xray & co
    xray
    sing-box
    v2rayn
    amnezia-vpn
    amneziawg-tools

    nerd-fonts.jetbrains-mono

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

  security.wrappers.xray = {
    source = "${pkgs.xray}/bin/xray";
    capabilities = "cap_net_admin,cap_net_bind_service=+eip";
    owner = "root";
    group = "root";
    permissions = "u+rx,g+x,o+x";
  };
}
