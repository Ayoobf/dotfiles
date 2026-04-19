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
    "tmux/.config/tmux:.config/tmux"
    "alacritty/.config/alacritty:.config/alacritty"
    "git/.gitconfig:.gitconfig"
    "git/.gitignore_global:.gitignore_global"
    "gh/config.yml:.config/gh/config.yml"
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

# Force zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    echo -e "${GREEN}shell${NC}  zsh set as default"
else
    echo -e "${YELLOW}skip${NC}  zsh (already default)"
fi

# Detect OS and run platform-specific installs
OS="$(uname)"

if [ "$OS" = "Darwin" ]; then
    # Install Homebrew if missing
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew bundle install --file="$DOTFILES_DIR/Brewfile"

    # Cargo packages (brew bundle doesn't run cargo installs)
    if command -v cargo &>/dev/null; then
        cargo install tree-sitter-cli
    fi

    # Karabiner (macOS only)
    KARABINER_SRC="$DOTFILES_DIR/karabiner/.config/karabiner"
    KARABINER_TGT="$HOME/.config/karabiner"
    if [ -d "$KARABINER_SRC" ]; then
        if [ -L "$KARABINER_TGT" ] && [ "$(readlink "$KARABINER_TGT")" = "$KARABINER_SRC" ]; then
            echo -e "${YELLOW}skip${NC}  karabiner (already linked)"
        else
            [ -e "$KARABINER_TGT" ] && mv "$KARABINER_TGT" "${KARABINER_TGT}.backup"
            ln -s "$KARABINER_SRC" "$KARABINER_TGT"
            echo -e "${GREEN}link${NC}   karabiner -> $KARABINER_SRC"
        fi
    fi

    # Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo -e "${YELLOW}skip${NC}  oh-my-zsh (already installed)"
    fi

elif [ "$OS" = "Linux" ]; then
    echo -e "${BLUE}Linux detected — installing dependencies...${NC}"

    # Install Homebrew if missing
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    brew bundle install --file="$DOTFILES_DIR/Brewfile"

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
    
    # keyd (Karabiner equivalent)
    if ! command -v keyd &>/dev/null; then
        sudo apt install -y keyd
    else
        echo -e "${YELLOW}skip${NC}  keyd (already installed)"
    fi
    sudo mkdir -p /etc/keyd
    sudo ln -sf "$DOTFILES_DIR/keyd/default.conf" /etc/keyd/default.conf
    sudo systemctl enable --now keyd

fi

# iTerm2 preferences
if [ "$OS" = "Darwin" ]; then
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    echo -e "${GREEN}set${NC}    iTerm2 prefs -> $DOTFILES_DIR/iterm2"
fi

# Neovim config
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
if [ ! -d "$NVIM_DIR/.git" ]; then
    git clone https://github.com/ayoobf/neovim.nvim.git "$NVIM_DIR"
    echo -e "${GREEN}cloned${NC} neovim config -> $NVIM_DIR"
else
    echo -e "${YELLOW}skip${NC}  neovim config (already cloned)"
fi

# SSH key
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "rflooivl@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
    echo -e "${GREEN}created${NC}  SSH key ~/.ssh/id_ed25519"
else
    echo -e "${YELLOW}skip${NC}  SSH key (already exists)"
fi

# gh auth + register SSH key with GitHub
if command -v gh &>/dev/null; then
    if ! gh auth status &>/dev/null; then
        gh auth login
        if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
            gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)"
        fi
    else
        echo -e "${YELLOW}skip${NC}  gh auth (already authenticated)"
    fi
fi

echo ""
echo "Done!"
