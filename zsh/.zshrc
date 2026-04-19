# zmodload zsh/zprof

eval "$(starship init zsh)"
ssh-add --apple-use-keychain ~/.ssh/jethr

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

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
export PATH="/usr/local/gradle/gradle-8.6/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"
export PATH="$HOME/src/executables:$PATH"

# zprof
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools"

# jet
export PATH="/bin/bash:$PATH"

jet_sync_host_venv() {
  local repo="/Users/ilcors-dev/src/jethr"
  local backend="$repo/backend/jet_core"
  local python_bin="${1:-python3.13}"

  if [[ ! -d "$backend" ]]; then
    print -u2 "JetHR backend not found at $backend"
    return 1
  fi

  if ! command -v "$python_bin" >/dev/null 2>&1; then
    print -u2 "Python interpreter not found: $python_bin"
    return 1
  fi

  (
    cd "$backend" || exit 1

    if [[ ! -x .venv/bin/python ]]; then
      "$python_bin" -m venv .venv || exit 1
    fi

    source .venv/bin/activate || exit 1
    python -m pip install -U pip uv || exit 1
    uv pip sync requirements.txt dev-requirements.txt || exit 1
    uv pip install django-stubs djangorestframework-stubs || exit 1
  )
}

jet_nvim() {
  local repo="/Users/ilcors-dev/src/jethr"

  jet_sync_host_venv "$@" || return 1
  cd "$repo" || return 1
  nvim .
}

alias jet="./dev-tools.sh"
alias jet-sync-venv="jet_sync_host_venv"
alias jet-nvim="jet_nvim"
alias jet-format-be="jet format-backend && jet ruff-fix && jet lint-backend"

export DEV_SKIP_SPA="jet_accountant jet_studio jet_studio_customer jet_studio_employee"
