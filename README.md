# dotfiles

Managed using GNU stow.

Run `bootstrap.sh` to bootstrap base stuff and then:

```bash
brew install stow
```

To STOW user dotfiles, run from the root of this folder

```bash
stow -vv -t ~ nvim zsh ghostty starship lazygit executables opencode git tuicr
stow --no-folding -vv -t ~ agents
```

The `agents` package installs shared skills into `~/.agents/skills`.

The `opencode` package installs the tracked global configuration, local plugins,
and their dependency manifest. On first startup, OpenCode installs the npm
plugins from `opencode.json`.

Optional private configuration can provide `~/.zsh/local.zsh` and
`~/.config/local-nvim-work.lua`. The public packages work without them.

To STOW system keyboard layouts (requires sudo)

```bash
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" keyboard-layouts
```

To UNSTOW

```bash
stow -vv -t ~ -D nvim zsh ghostty starship lazygit executables opencode git tuicr
stow --no-folding -vv -t ~ -D agents
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" -D keyboard-layouts
```
