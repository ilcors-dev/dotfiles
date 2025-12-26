# dotfiles

Managed using GNU stow.

Run `bootstrap.sh` to bootstrap base stuff and then:

```bash
brew install stow
```

To STOW, run from the root of this folder

```bash
stow -vv -t ~ */
```

To UNSTOW

```bash
stow -vv -t ~ -D */
```
