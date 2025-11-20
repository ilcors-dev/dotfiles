-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
        position = 'right',
      },
      filtered_items = {
        visible = true, -- Show hidden files
        hide_dotfiles = false, -- Also show dotfiles
        hide_gitignored = false,
      },
    },
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = true,
    window = {
      position = 'right',
    },
  },
}
