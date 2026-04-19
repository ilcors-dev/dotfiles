# Neovim Config

Neovim `0.12` config using the built-in `vim.pack` plugin manager.

## Layout

- `init.lua`: entrypoint
- `lua/config`: options, keymaps, autocmds, diagnostics, plugin manager, LSP wiring
- `lua/plugins`: third-party plugin setup
- `lua/core`: local helper modules

## Requirements

- Neovim `0.12+`
- `git`, `make`, `unzip`, `rg`
- `fd`
- a clipboard provider
- a Nerd Font if you want icons

## First Start

Run `nvim`.

On first startup, `vim.pack` installs the declared plugins and writes `nvim-pack-lock.json` in this directory.

## Updating Plugins

From inside Neovim:

```lua
:lua vim.pack.update()
```

Review the update buffer and confirm with `:write`.

## Alternate App Name

To keep this config separate from another Neovim setup:

```sh
alias nvim-pack='NVIM_APPNAME="nvim-pack" nvim'
```

That will use separate config and data directories for the `nvim-pack` app name.
