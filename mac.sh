echo "Downloading kitty"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

echo "Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing fish and fisher"
brew install fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

echo "Setting fish as default terminal"
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s $(which fish)

echo "Installing neovim and dependencies"
brew install neovim
brew install tree-sitter-cli
brew install ripgrep
brew install fzf
brew install fd

echo "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
