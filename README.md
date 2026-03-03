# dotfiles

My dotfiles managed with plain git and a simple install script.

## What's included

- **zsh** - oh-my-zsh config with aliases and tool integrations
- **nvim** - Neovim config with packer, LSP, telescope, harpoon, treesitter
- **tmux** - tmux config with kanagawa theme, vim-tmux-navigator, tpm
- **alacritty** - Alacritty terminal config

## Prerequisites

- [oh-my-zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/)
- [tmux](https://github.com/tmux/tmux) + [tpm](https://github.com/tmux-plugins/tpm)
- [Alacritty](https://alacritty.org/)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)

## Install

```sh
git clone https://github.com/Ayoobf/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Existing files are backed up as `<file>.backup` before symlinking.
