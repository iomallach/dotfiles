{
  flake.modules.nix = {
    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs.overlays = [
      (final: prev: {
        gitu = prev.gitu.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
        crush = prev.crush.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      })
    ];
  };
}
