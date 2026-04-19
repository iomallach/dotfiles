{
  flake.modules.generic.fonts =
    { pkgs, ... }:

    {
      fonts.packages = with pkgs; [
        maple-mono.NF
        nerd-fonts.symbols-only
        font-awesome
        material-design-icons
      ];
      environment.systemPackages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
