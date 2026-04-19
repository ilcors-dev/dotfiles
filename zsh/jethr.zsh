ssh-add --apple-use-keychain ~/.ssh/jethr

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
