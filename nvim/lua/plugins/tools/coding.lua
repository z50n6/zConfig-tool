-- 作用: 代码编辑增强与重构辅助
-- 包含: treesj, mini.surround, grug-far, nvim-lightbulb, trouble, inc-rename, todo-comments
return {
  -- 结构化拆分/合并（适合 TS/Go/Lua 等）
  {
    "Wansmer/treesj",
    cmd = { "TSJToggle", "TSJJoin", "TSJSplit" },
    keys = {
      { "<leader>cj", "<cmd>TSJToggle<cr>", desc = "Join/Split (TreeSJ)" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { use_default_keymaps = false, max_join_length = 200 },
  },

  -- Surround：快速加/改/删包裹符号（轻量稳定）
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  -- 工程级搜索替换（预览+逐个确认）
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar" },
    keys = {
      { "<leader>sr", "<cmd>GrugFar<cr>", desc = "搜索替换 (GrugFar)" },
    },
    opts = {},
  },

  -- Code Action 灯泡提示（有可用 action 时提示）
  {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = true },
      virtual_text = { enabled = false },
      status_text = { enabled = false },
    },
  },

  -- Trouble：诊断/引用列表（LazyVim 通常已带，这里只做轻配置+按需加载）
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = { auto_close = true },
  },

  -- 增量重命名
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },

  -- TODO 注释增强
  {
    "folke/todo-comments.nvim",
    opts = {
      signs = true,
      highlight = {
        keyword = "wide",
      },
    },
    keys = {
      { "]T", function() require("todo-comments").jump_next() end, desc = "下一个 TODO" },
      { "[T", function() require("todo-comments").jump_prev() end, desc = "上一个 TODO" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "搜索 TODO/FIXME" },
    },
  },
}
