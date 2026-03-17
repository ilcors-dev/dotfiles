# dotfiles

Managed using GNU stow.

Run `bootstrap.sh` to bootstrap base stuff and then:

```bash
brew install stow
```

To STOW user dotfiles, run from the root of this folder

```bash
stow -vv -t ~ nvim zsh ghostty starship lazygit android-emulator
```

Android emulator (optional, minimal, no Android Studio):

```bash
# One-time install of SDK/emulator + AVD
android-emu-setup

# Start emulator
android-emu testphone

# If blurry, recreate AVD with proper device profile
android-emu-setup --avd-name testphone --device pixel_8 --recreate-avd

# GPU fallback if host mode still looks bad
ANDROID_EMU_GPU=swiftshader_indirect android-emu testphone
```

To STOW system keyboard layouts (requires sudo)

```bash
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" keyboard-layouts
```

To UNSTOW

```bash
stow -vv -t ~ -D nvim zsh ghostty starship lazygit android-emulator
sudo stow -vv -d "$HOME/src/dotfiles" -t "/Library/Keyboard Layouts" -D keyboard-layouts
```
