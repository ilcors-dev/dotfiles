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
`power-report [days]` prints day-by-day kWh with an ASCII chart.
CSV schema (`~/.local/share/powerlog/power-<year>.csv`):
| column | unit | meaning |
|---|---|---|
| `timestamp` | ISO-8601 | sample time |
| `boottime` | epoch sec | reboot detection; report starts a new segment on change |
| `wall_acc_mJ` | mJ odometer | wall-drawn energy; frozen on battery; **bill ledger** via deltas ÷ 3.6e9 |
| `sys_acc_mJ` | mJ odometer | energy the Mac consumed, counts through sleep; **consumption ledger** |
| `inp_mW` / `sys_mW` / `wall_mW` | mW instant | debug/context only, never billed (staircase sensor); folded ≥ 0 |
| `batt_mW` | mW instant, signed | `>0` charging, `<0` discharging |
Rules: kWh from accumulator deltas only; backward step (wrap or SMC reset) → new
segment, gap Δ=0 + flagged; sleep needs no interpolation (SMC counts through it).

The `agents` package installs shared skills into `~/.agents/skills`.

The `opencode` package installs the tracked global configuration, local plugins,
and their dependency manifest. On first startup, OpenCode installs the npm
plugins from `opencode.json`.

The `omp` package links `~/.omp/agent/config.yml`, `~/.omp/agent/AGENTS.md`,
`~/.omp/agent/writer.md`;
`--no-folding` keeps sessions, databases, and
logs out of the repository. omp writes `/settings` changes through the link, so
they show up as diffs here. `AGENTS.md` holds the user-level instructions for
every omp session and subagent; it imports `writer.md`, which imports the
`write-docs` skill from `agents`, so stow `agents` together with `omp`.
`bootstrap.sh` installs omp with Bun, the rtk extension, and the
`pi-rtk-optimizer` plugin. `omp/.stow-local-ignore` keeps omp's untracked
`config.yml.lock` out of the stow.
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
