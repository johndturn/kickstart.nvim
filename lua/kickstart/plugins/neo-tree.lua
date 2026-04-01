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
    enable_git_status = true,
    sources = {
      'filesystem',
      'git_status',
      'document_symbols',
    },
    filesystem = {
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        never_show = {
          '.DS_Store',
        },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<leader>rf'] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.jobstart({ 'open', '-R', path }, { detach = true })
          end,
          --
          -- Jump up to parent directory on file or closed directory, or close on open directory
          ['h'] = function(state)
            local node = state.tree:get_node()
            if (node.type == 'directory' or node:has_children()) and node:is_expanded() then
              state.commands.toggle_node(state)
            else
              require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
            end
          end,
          --
          -- Open on file or closed directory, or jump down to top subdirectory on open directory
          ['l'] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' or node:has_children() then
              if not node:is_expanded() then
                state.commands.toggle_node(state)
              else
                require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
              end
            else
              require('neo-tree.sources.filesystem.commands').open(state)
            end
          end,
        },
      },
    },
  },
}
