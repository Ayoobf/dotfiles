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

echo ""
echo "Done!"
