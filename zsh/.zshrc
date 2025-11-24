autoload -Uz compinit
compinit

eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#fff,bg=cyan,bold,underline"
source <(COMPLETE=zsh jj)

if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"

export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export GPG_TTY=$(tty)
export TERM="xterm-256color"
export EDITOR="nvim"

export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
export PATH="/usr/local/gradle/gradle-8.6/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"
export PATH="$HOME/src/executables:$PATH"
