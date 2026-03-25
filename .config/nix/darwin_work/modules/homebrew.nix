{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none";
    };

    taps = [
      "felixkratz/formulae"
      "getyourguide/dev"
    ];

    # Formulae
    brews = [
      "ifstat"
      "borders"
      "sketchybar"
      "zellij"
      "postgresql@14"
      "zig"
      "awscli" # move to nix
      # gyg
      "dev-bundle"
      "dev-scripts"
      "gdbc"
    ];

    casks = [
      "aerospace" # move to nixpkgs
      "dbeaver-community"
      "raycast"
      "karabiner-elements"
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
      "font-jetbrains-mono-nerd-font"
      "font-maple-mono-nf"
      "font-martian-mono-nerd-font"
      "font-meslo-lg-nerd-font"
      "font-monofur-nerd-font"
      "font-roboto-mono-nerd-font"
      "font-sf-mono"
      "font-sf-pro"
      "font-symbols-only-nerd-font"
      "font-terminess-ttf-nerd-font"
      "font-zed-mono-nerd-font"
      "sf-symbols"
    ];
  };
}
