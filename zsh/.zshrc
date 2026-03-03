# Source private vars
if [ -f ~/.env.local ]; then
    source ~/.env.local
fi

ZSH_THEME=robbyrussell
plugins=(git)
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Aliases
eval $(thefuck --alias)
alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias cls="clear"

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

case "$(uname)" in
    Darwin)
        export PNPM_HOME="$HOME/Library/pnpm"
        export JAVA_HOME=/opt/homebrew/opt/openjdk@17
        export ANDROID_HOME=$HOME/Library/Android/sdk
        export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
        export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
        export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
        ;;
    Linux)
        export PNPM_HOME="$HOME/.local/share/pnpm"
        ;;
esac

case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

export EDITOR='nvim'
export VISUAL='nvim'

# Go
export PATH="$PATH:/usr/local/go/bin"

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
