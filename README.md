# dotfiles

Managed using GNU stow.

Run `bootstrap.sh` to bootstrap base stuff and then:

```bash
brew install stow
```

To STOW user dotfiles, run from the root of this folder

```bash
stow -vv -t ~ nvim zsh ghostty starship lazygit executables opencode git tuicr launchd
stow --no-folding -vv -t ~ agents omp
```

The `launchd` package installs `~/Library/LaunchAgents/dev.ilcors.powerlog.plist`,
which runs `power-log` every 60s into `~/.local/share/powerlog/` (untracked).
Enable with `launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/dev.ilcors.powerlog.plist`.

The `agents` package installs shared skills into `~/.agents/skills`.

The `opencode` package installs the tracked global configuration, local plugins,
and their dependency manifest. On first startup, OpenCode installs the npm
plugins from `opencode.json`.

The `omp` package links only `~/.omp/agent/config.yml`; `--no-folding` keeps
sessions, databases, and logs out of the repository. omp writes `/settings`
changes through the link, so they show up as diffs here. `bootstrap.sh`
installs omp with Bun, the rtk extension, and the `pi-rtk-optimizer` plugin.
Provider logins and MCP OAuth tokens live in `~/.omp/agent/agent.db` and are
not tracked: run `/login` after restoring.

Optional private configuration can provide `~/.zsh/local.zsh` and
`~/.config/local-nvim-work.lua`. The public packages work without them.

The default agent executable for the `<leader>o1`, `<leader>o2`, and
`<leader>o3` terminals is configured in
`nvim/.config/nvim/lua/config/options.lua`:

```lua
vim.g.terminal_manager_agent_command = "omp"
```

To STOW system keyboard layouts (requires sudo)

```bash
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" keyboard-layouts
```

To UNSTOW

```bash
stow -vv -t ~ -D nvim zsh ghostty starship lazygit executables opencode git tuicr launchd
stow --no-folding -vv -t ~ -D agents omp
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" -D keyboard-layouts
```
