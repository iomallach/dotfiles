{ inputs, ... }:
{
  flake.overlays.default = final: prev: {
    neovim-nightly = inputs.neovim-nightly.packages.${prev.system};
    kanata-tray = inputs.kanata-tray.packages.${prev.system};
  };
}
