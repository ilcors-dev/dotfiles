# zmodload zsh/zprof

eval "$(starship init zsh)"

autoload -Uz compinit
# if .zcompdump is missing or older than 24h, rebuild; otherwise use cache.
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#fff,bg=cyan,bold,underline"

if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

export NVM_DIR="$HOME/.nvm"

_lazynvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

for cmd in nvm node npm npx; do
  eval "${cmd}() { _lazynvm; ${cmd} \"\$@\" }"
done

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

# zprof
