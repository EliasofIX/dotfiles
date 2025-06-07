return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x', -- Use stable branch for reliability
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required dependency
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make', -- Build the native fzf extension
        cond = function()
          return vim.fn.executable('make') == 1 and vim.fn.executable('fzf') == 1
        end, -- Only load if make and fzf are available
      },
      'stevearc/aerial.nvim', -- Optional, for aerial extension
    },
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          wrap_results = true,
          mappings = {
            i = {
              ['<esc>'] = require('telescope.actions').close,
              ['<C-Down>'] = require('telescope.actions').cycle_history_next,
              ['<C-Up>'] = require('telescope.actions').cycle_history_prev,
            },
          },
          layout_strategy = 'vertical',
          layout_config = {
            vertical = {
              width = 0.9,
              preview_cutoff = 10,
            },
          },
        },
        pickers = {
          lsp_references = { wrap_results = true },
          lsp_definitions = { wrap_results = true },
          diagnostics = { wrap_results = true },
          find_files = { wrap_results = true },
          buffers = { sort_mru = true, ignore_current_buffer = true },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      })

      -- Load extensions
      telescope.load_extension('fzf') -- Load fzf-native
      pcall(telescope.load_extension, 'aerial') -- Safely load aerial if available
    end,
    keys = {
      -- Recent files
      {
        '<leader>fo',
        function()
          require('telescope.builtin').oldfiles({
            prompt_title = 'Recent Files',
            sort_mru = true,
          })
        end,
        desc = 'Old (recent) files',
      },
      -- Buffers (consolidated from <leader><space>, <leader>b, <leader>p)
      { '<leader>b', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
      -- Find files
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find filenames' },
      -- Marks
      { '<leader>fm', '<cmd>Telescope marks<cr>', desc = 'Marks' },
      -- Grep files
      { '<leader>fw', '<cmd>Telescope live_grep<cr>', desc = 'Grep files' },
      -- Diagnostics
      { '<leader>ld', '<cmd>Telescope diagnostics<cr>', desc = 'Diagnostics' },
      -- Grep open files
      {
        '<leader>fb',
        function()
          require('telescope.builtin').live_grep({
            prompt_title = 'Grep Open Files',
            grep_open_files = true,
          })
        end,
        desc = 'Grep open files',
      },
      -- Grep current file
      {
        '<leader>fc',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find()
        end,
        desc = 'Grep this file',
      },
      -- Command history
      {
        '<leader>:',
        function()
          require('telescope.builtin').command_history({ prompt_title = 'Command History' })
        end,
        desc = 'Command history',
      },
      -- Search symbols (aerial or lsp_document_symbols)
      {
        '<leader>ls',
        function()
          local aerial_avail, _ = pcall(require, 'aerial')
          if aerial_avail then
            require('telescope').extensions.aerial.aerial()
          else
            require('telescope.builtin').lsp_document_symbols()
          end
        end,
        desc = 'Search symbols',
      },
    },
  },
}
