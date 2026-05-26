ssh-add --apple-use-keychain ~/.ssh/jethr

jet_sync_host_venv() {
  local repo="$HOME/src/jethr"
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
  local repo="$HOME/src/jethr"

  jet_sync_host_venv "$@" || return 1
  cd "$repo" || return 1
  nvim .
}

jet_migrate_undo() {
  if (( $# == 0 )); then
    print -u2 "Usage: jet-mu <migration_id> [migration_id ...]"
    print -u2 "Example: jet-mu 0575 0576"
    return 1
  fi

  local id numeric_id
  local min_id=""
  for id in "$@"; do
    numeric_id="${id%%[^0-9]*}"
    if [[ -z "$numeric_id" ]]; then
      print -u2 "Invalid migration id: $id"
      print -u2 "Migration ids must start with digits (example: 0575 or 0575_merge_foo)"
      return 1
    fi

    if [[ -z "$min_id" || 10#$numeric_id -lt 10#$min_id ]]; then
      min_id="$numeric_id"
    fi
  done

  if (( 10#$min_id <= 1 )); then
    print "Undoing via migrate to: zero"
    jet manage migrate jet zero
    return $?
  fi

  local target_num=$((10#$min_id - 1))
  local width=${#min_id}
  local target
  target=$(printf "%0${width}d" "$target_num")

  print "Undoing via migrate to: $target"
  jet manage migrate jet "$target"
}

alias jet="./dev-tools.sh"
alias jet-sync-venv="jet_sync_host_venv"
alias jet-nvim="jet_nvim"
alias jet-mu="jet_migrate_undo"
alias jet-format-be="jet format-backend && jet ruff-fix && jet lint-backend"
alias jet-db="jet db-get-newest-dump && jet db-from-dump"
alias jet-reset="jet pip-sync && jet npm ci && jet migrate"
alias jet-sh="jet manage shell_plus"

export DEV_SKIP_SPA="jet_accountant jet_studio jet_studio_customer jet_studio_employee"
