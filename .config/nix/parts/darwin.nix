{ self, ... }:
{
  flake.lib.darwinOverlaysModule = {
    nixpkgs.overlays = [ self.overlays.default ];
  };
}
