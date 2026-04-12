{
  flake.modules.homeManager = {
    base = {
      home = {
        stateVersion = "25.05";
        sessionVariables = {
          EDITOR = "nvim";
        };
      };

      programs.home-manager.enable = true;
    };

    darwinWork = {
      home.username = "alexander.butenko";
      home.homeDirectory = "/Users/alexander.butenko";
      home.sessionVariables = {
        OH_MY_OPENCODE_SLIM_PRESET = "work";
        DEFAULT_USER = "alex";
        GRPC_PYTHON_BUILD_SYSTEM_OPENSSL = "1";
        GRPC_PYTHON_BUILD_SYSTEM_ZLIB = "1";
        MLFLOW_TRACKING_URI = "databricks";
        PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
      };
      home.sessionPath = [
        "$HOME/.cargo/bin"
        "$HOME/.rd/bin"
        "/opt/homebrew/opt/node@22/bin"
        "/Users/alexander.butenko/Library/pnpm"
      ];
    };

    darwinPrivate = {
      home.username = "iomallach";
      home.homeDirectory = "/Users/iomallach";
      home.sessionVariables = {
        OH_MY_OPENCODE_SLIM_PRESET = "openai";
      };
    };

    nixos =
      { pkgs, ... }:
      {
        home.username = "iomallach";
        home.homeDirectory = "/home/iomallach";
        home.sessionVariables = {
          OH_MY_OPENCODE_SLIM_PRESET = "openai";
        };
        home.pointerCursor = {
          name = "Catppuccin-Macchiato-Blue-Cursors";
          package = pkgs.catppuccin-cursors;
          size = 35;
          gtk.enable = true;
          x11.enable = true;
        };
        xdg.dataFile."icons/catppuccin-macchiato-blue-cursors".source = pkgs.fetchzip {
          url = "https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-macchiato-blue-cursors.zip";
          sha256 = "1b30cwdl5m7ll5k2kwn91h16pr7i3xrg5x018kbxzyjk7z59pfnw";
        };
      };
  };
}
