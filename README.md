# dotfiles

Managed using GNU stow.

Run `bootstrap.sh` to bootstrap base stuff and then:

```bash
brew install stow
```

To STOW user dotfiles, run from the root of this folder

```bash
stow -vv -t ~ nvim zsh ghostty starship lazygit
```

To STOW system keyboard layouts (requires sudo)

```bash
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" keyboard-layouts
```

To UNSTOW

```bash
stow -vv -t ~ -D nvim zsh ghostty starship lazygit
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" -D keyboard-layouts
```
