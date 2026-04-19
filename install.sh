#!/usr/bin/env bash
set -eo pipefail
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
# Mappings: "source:target" (relative to DOTFILES_DIR and $HOME respectively)
LINKS=(
    "zsh/.zshrc:.zshrc"
    "nvim/.config/nvim:.config/nvim"
    "tmux/.config/tmux:.config/tmux"
    "alacritty/.config/alacritty:.config/alacritty"
)
for entry in "${LINKS[@]}"; do
    src_rel="${entry%%:*}"
    tgt_rel="${entry#*:}"
    src="$DOTFILES_DIR/$src_rel"
    tgt="$HOME/$tgt_rel"
    # Skip if already the correct symlink
    if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$src" ]; then
        echo -e "${YELLOW}skip${NC}  $tgt (already linked)"
        continue
    fi
    # Back up existing file/directory
    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
        echo -e "${BLUE}backup${NC} $tgt -> ${tgt}.backup"
        mv "$tgt" "${tgt}.backup"
    fi
    # Create parent directory if needed
    mkdir -p "$(dirname "$tgt")"
    # Create symlink
    ln -s "$src" "$tgt"
    echo -e "${GREEN}link${NC}   $tgt -> $src"
done

# Detect OS and run platform-specific installs
OS="$(uname)"

if [ "$OS" = "Darwin" ]; then
    # Install Homebrew if missing
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew bundle install --file="$DOTFILES_DIR/Brewfile"

elif [ "$OS" = "Linux" ]; then
    echo -e "${BLUE}Linux detected — installing dependencies...${NC}"

    # Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo -e "${YELLOW}skip${NC}  oh-my-zsh (already installed)"
    fi

    # thefuck
    if ! command -v thefuck &>/dev/null; then
        if ! command -v pipx &>/dev/null; then
            sudo apt install -y pipx
            pipx ensurepath
        fi
        pipx install thefuck
    else
        echo -e "${YELLOW}skip${NC}  thefuck (already installed)"
    fi

    # fnm
    if ! command -v fnm &>/dev/null; then
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        echo -e "${YELLOW}skip${NC}  fnm (already installed)"
    fi

    # pyenv
    if ! command -v pyenv &>/dev/null; then
        curl -fsSL https://pyenv.run | bash
    else
        echo -e "${YELLOW}skip${NC}  pyenv (already installed)"
    fi

fi

echo ""
echo "Done!"
