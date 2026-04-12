{
  flake.modules.fonts =

    {
      base =
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

      darwin = {
        homebrew = {
          casks = [
            "font-caskaydia-cove-nerd-font"
            "font-caskaydia-mono-nerd-font"
            "font-dejavu-sans-mono-nerd-font"
            "font-droid-sans-mono-nerd-font"
            "font-fira-code-nerd-font"
            "font-fira-mono-nerd-font"
            "font-inconsolata-go-nerd-font"
            "font-inconsolata-lgc-nerd-font"
            "font-inconsolata-nerd-font"
            "font-iosevka-nerd-font"
            "font-iosevka-term-nerd-font"
            "font-iosevka-term-slab-nerd-font"
            "font-meslo-lg-nerd-font"
            "font-monofur-nerd-font"
            "font-sf-mono"
            "font-sf-pro"
            "sf-symbols"
          ];
        };
      };
    };
}
