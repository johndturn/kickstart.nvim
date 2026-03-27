return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      lint.linters.oxlint = {
        name = 'oxlint',
        cmd = function()
          local local_bin = vim.fn.getcwd() .. '/node_modules/.bin/oxlint'
          if vim.fn.filereadable(local_bin) == 1 then
            return local_bin
          end
          return 'oxlint'
        end,
        stdin = false,
        args = { '--format', 'json' },
        stream = 'stdout',
        ignore_exitcode = true,
        parser = function(output)
          if output == '' then
            return {}
          end
          local ok, decoded = pcall(vim.json.decode, output)
          if not ok or not decoded then
            return {}
          end
          local diagnostics = {}
          local severities = {
            [1] = vim.diagnostic.severity.WARN,
            [2] = vim.diagnostic.severity.ERROR,
          }
          for _, file_result in ipairs(decoded) do
            for _, msg in ipairs(file_result.messages or {}) do
              table.insert(diagnostics, {
                lnum = (msg.line or 1) - 1,
                col = (msg.column or 1) - 1,
                end_lnum = msg.endLine and (msg.endLine - 1) or nil,
                end_col = msg.endColumn and (msg.endColumn - 1) or nil,
                severity = severities[msg.severity] or vim.diagnostic.severity.WARN,
                message = msg.message,
                source = 'oxlint',
                code = msg.ruleId,
              })
            end
          end
          return diagnostics
        end,
      }

      lint.linters_by_ft = {
        typescript = { 'oxlint' },
        typescriptreact = { 'oxlint' },
        javascript = { 'oxlint' },
        javascriptreact = { 'oxlint' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
