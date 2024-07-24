echo "Installing command line tools"
xcode-select --install

echo "Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/iomallach/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "Homebrew has been installed"

echo "Tapping..."
brew tap homebrew/cask-fonts
brew tap d12frosted/emacs-plus
brew tap zegervdv/zathura
brew tap FelixKratz/formulae
brew tap d12frosted/emacs-plus

echo "Installing packages"
brew search '/font-.*-nerd-font' | awk '{ print $1 }' | xargs -I{} brew install --cask {} || true
brew install --cask font-sf-pro
brew install neovim
brew install stow
brew install eza
brew install fzf
brew install zoxide
brew install tmux
brew install pipx
brew install --cask raycast
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd
brew install sketchybar
brew install fd
brew install ripgrep
brew install go
brew install hugo
brew install helix
brew install --cask zed
brew install jq
brew install lazygit
brew install luarocks
brew install --cask neovide
brew install --cask bitwarden
brew install --cask sf-symbols
brew install --cask wezterm
brew install --cask alacritty
brew install --cask google-drive
brew install --cask spotify
brew install borders
brew install rust-analyzer
brew install --cask elmedia-player
brew install --cask firefox
brew install --cask the-unarchiver
brew install --cask notion
brew install openjdk
brew install --cask telegram
brew install pyenv
brew install --cask google-chrome
brew install emacs --with-native-comp
brew install tldr
brew install wireshark
brew install --cask sioyek

echo "Installing app icons for sketchybar"
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.23/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

echo "Installing rust toolchain"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rustfmt

echo "Cloning dotfiles..."
git clone https://github.com/iomallach/dotfiles ~/

echo "Clonning tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Starting services..."
brew services start sketchybar
brew services start borders
yabai --start-service
