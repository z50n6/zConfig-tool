-- 作用: 统一格式化与开发工具自动安装
-- 包含: stevearc/conform.nvim, mason-org/mason.nvim
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

return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        go = { "goimports", "gofmt" },
        sh = { "shfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        cmake = { "cmake_format" },
        tex = { "latexindent" },
      },
      formatters = {
        prettier = {
          prepend_args = { "--single-quote", "--trailing-comma", "all" },
        },
        ["clang-format"] = {
          command = "clang-format",
        },
        cmake_format = {
          command = "cmake-format",
        },
        latexindent = {
          command = "latexindent",
          args = { "-" },
          stdin = true,
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    -- 避免启动或首次打开文件时后台安装拖慢体验；
    -- 需要时再用 :Mason / :MasonInstall 等命令触发加载。
    event = "VeryLazy",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUpdate",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
    },
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      add_unique(opts.ensure_installed, {
        "stylua",
        "prettier",
        "black",
        "isort",
        "goimports",
        "shfmt",
        "shellcheck",
        "selene",
        "luacheck",
        "lua-language-server",
        "pyright",
        "ruff",
        "vtsls",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
        "gopls",
        "marksman",
        "yaml-language-server",
        "json-lsp",
        "clangd",
        "clang-format",
        "cmake-language-server",
        "cmakelang",
        "texlab",
        "latexindent",
      })
    end,
  },
}
