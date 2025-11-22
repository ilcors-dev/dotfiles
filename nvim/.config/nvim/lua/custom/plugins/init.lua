-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    local ok, diagram = pcall(require, 'diagram')
    if ok and diagram.renderer_options then
      local theme = (vim.o.background == 'dark') and 'dark' or 'neutral'
      diagram.renderer_options.mermaid = diagram.renderer_options.mermaid or {}
      diagram.renderer_options.mermaid.theme = theme

      vim.schedule(function()
        if vim.bo.filetype == 'markdown' then
          vim.cmd 'DiagramClear'
          vim.cmd 'DiagramRender'
        end
      end)
    end
  end,
})

return {
  { -- Copilot
    'github/copilot.vim',
    cond = false,
    -- Optional: configure only on setup:
    config = function()
      vim.g.copilot_no_maps = true
      vim.g.copilot_no_tab_map = true -- Disable default Tab mapping for acceptance

      -- Create a custom toggle command for buffer-local enable/disable
      vim.api.nvim_create_user_command('CopilotToggle', function()
        if vim.b.copilot_enabled == 1 then
          vim.cmd 'Copilot disable'
          print 'Copilot disabled for this buffer'
        else
          vim.cmd 'Copilot enable'
          print 'Copilot enabled for this buffer'
        end
      end, { desc = 'Toggle Copilot for current buffer' })

      vim.keymap.set('n', '<leader>ct', '<cmd>CopilotToggle<CR>', { desc = 'Toggle Copilot' })
    end,
  },
  {
    'nmac427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup {}
    end,
  },
  {
    'yetone/avante.nvim',
    cond = false,
    event = 'VeryLazy',
    version = false,
    provider = 'openrouter',
    providers = {
      openrouter = {
        __inherited_from = 'openai',
        endpoint = 'https://openrouter.ai/api/v1',
        api_key_name = 'OPENROUTER_API_KEY',
        model = 'x-ai/grok-code-fast-1',
      },
    },
    opts = {},
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'echasnovski/mini.pick', -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua', -- for file_selector provider fzf
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      latex = {
        -- Enable LaTeX rendering (default: true)
        enabled = true,
        -- Additional modes to render LaTeX (default: normal/command/terminal; add 'i' for insert mode if desired)
        render_modes = false, -- False inherits from global render_modes
        -- Converters to try (in order; install at least one)
        converter = { 'utftex' }, -- Add paths if not in PATH, e.g., '/usr/local/bin/utftex'
        -- Highlight for rendered LaTeX (customize in your colorscheme if needed)
        highlight = 'RenderMarkdownMath',
        -- Position of rendered formula relative to the block
        -- 'above': Above the math block
        -- 'below': Below the math block
        -- 'center': Centered with the block (for single-line only)
        position = 'center',
        -- Empty lines above the math block (for spacing)
        top_pad = 0,
        -- Empty lines below the math block
        bottom_pad = 0,
      },
      -- Global settings that affect LaTeX (ensure these align)
      enabled = true, -- Overall plugin enable
      render_modes = { 'n', 'c', 't' }, -- Render in normal mode by default
      -- Optional: Anti-conceal hides virtual text on cursor line (default: true; disable if you want always-visible LaTeX)
      anti_conceal = {
        enabled = true,
        above = 0, -- Lines above cursor to show (increase for more context)
        below = 0, -- Lines below cursor to show
      },
    },
  },
  {
    '3rd/image.nvim',
    opts = {
      backend = 'kitty',
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { 'markdown' },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    },
  },
  {
    '3rd/diagram.nvim',
    dependencies = { '3rd/image.nvim' },
    opts = {
      events = {
        render_buffer = { 'InsertLeave', 'BufWinEnter', 'TextChanged' },
        clear_buffer = { 'BufLeave' },
      },
      renderer_options = {
        mermaid = {
          background = nil,
          theme = nil,
          scale = 1,
          width = 1200,
          height = 800,
        },
      },
    },
    ft = { 'markdown' },
  },
  {
    'lervag/vimtex',
    lazy = true,
    init = function()
      vim.g.vimtex_view_method = 'zathura'
    end,
    ft = { 'tex', 'plaintex' },
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        size = 20,
        open_mapping = [[<c-t>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'horizontal',
        close_on_exit = true,
        shell = vim.fn.executable 'zsh' and 'zsh' or vim.fn.executable 'bash' and 'bash' or 'sh',
        float_opts = {
          border = 'curved',
        },
        winbar = {
          enabled = false,
          name_formatter = function(term)
            return term.name
          end,
        },
      }

      vim.keymap.set('n', '<leader>ott', '<cmd>1ToggleTerm<cr>', { desc = '[O]pen Terminal' })
      vim.keymap.set('n', '<leader>otnv', '<cmd>2ToggleTerm direction=vertical<cr>', { desc = '[O]pen Terminal (Vertical)' })
      vim.keymap.set('n', '<leader>otf', '<cmd>ToggleTerm direction=float<cr>', { desc = '[O]pen Terminal (Floating)' })
      vim.keymap.set('t', '<esc><esc>', '<cmd>ToggleTerm<cr>', { desc = 'Hide Terminal (Esc Esc)' })

      vim.keymap.set('n', '<leader>otl', '<cmd>TermSelect<cr>', { desc = '[O]pen Terminals List' })
      vim.keymap.set('n', '<leader>otp', '<cmd>ToggleTermNext<cr>', { desc = '[O]pen Next Terminal' })
      vim.keymap.set('n', '<leader>otP', '<cmd>ToggleTermPrev<cr>', { desc = '[O]pen Previous Terminal' })
    end,
  },
}
