-- 作用: 调试能力与调试器自动安装
-- 包含: nvim-dap-go, nvim-dap-python, mason-nvim-dap.nvim
return {
  -- Go 调试（依赖 mason 装 delve）
  {
    "leoluz/nvim-dap-go",
    ft = { "go" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },

  -- Python 调试（依赖 mason 装 debugpy）
  {
    "mfussenegger/nvim-dap-python",
    ft = { "python" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local mason = vim.fn.stdpath("data") .. "/mason/"
      local python_path
      if vim.fn.has("win32") == 1 then
        python_path = mason .. "packages/debugpy/venv/Scripts/python.exe"
      else
        python_path = mason .. "packages/debugpy/venv/bin/python"
      end
      require("dap-python").setup(python_path)
    end,
  },

  -- Mason 自动安装调试器（不影响启动；第一次 sync 时装）
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local function add_unique(list, items)
        local seen = {}
        for _, v in ipairs(list) do
          seen[v] = true
        end
        for _, v in ipairs(items) do
          if not seen[v] then
            table.insert(list, v)
            seen[v] = true
          end
        end
      end
      add_unique(opts.ensure_installed, {
        "debugpy", -- python
        "delve", -- go
      })
    end,
  },
}
