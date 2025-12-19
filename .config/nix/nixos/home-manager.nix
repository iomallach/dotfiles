{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "iomallach";
  home.homeDirectory = "/home/iomallach";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # Configure Spicetify with Catppuccin
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "macchiato";
    };

  # Zen Browser profile fix - prevents profile reset on updates
  # This ensures all installation hashes point to the main profile
  home.activation.fixZenProfile = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ZEN_DIR="$HOME/.zen"
    MAIN_PROFILE="ywc9b4dn.Default (release)"

    if [ -d "$ZEN_DIR" ] && [ -f "$ZEN_DIR/profiles.ini" ]; then
      # Remove Default=1 from all profiles
      ${pkgs.gnused}/bin/sed -i '/^Default=1$/d' "$ZEN_DIR/profiles.ini"

      # Add Default=1 to the main profile section
      ${pkgs.gnused}/bin/sed -i "/^Path=$MAIN_PROFILE$/a Default=1" "$ZEN_DIR/profiles.ini"

      # Update profiles.ini to point all Install sections to main profile
      ${pkgs.gnused}/bin/sed -i '/^\[Install.*\]/,/^Locked=/ {
        /^Default=/ s|=.*|='"$MAIN_PROFILE"'|
      }' "$ZEN_DIR/profiles.ini"

      # Also update installs.ini if it exists
      if [ -f "$ZEN_DIR/installs.ini" ]; then
        ${pkgs.gnused}/bin/sed -i '/^\[.*\]/,/^Locked=/ {
          /^Default=/ s|=.*|='"$MAIN_PROFILE"'|
        }' "$ZEN_DIR/installs.ini"
      fi

      $DRY_RUN_CMD echo "Fixed Zen Browser profile mappings to use $MAIN_PROFILE"
    fi
  '';

}
