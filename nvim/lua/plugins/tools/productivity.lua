-- 作用: 专注写作与撤销历史面板
-- 包含: zen-mode.nvim, undotree
return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        width = 0.75,
        options = {
          number = true,
          relativenumber = true,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
        },
      },
    },
    keys = {
      { "<leader>mz", "<cmd>ZenMode<cr>", desc = "专注模式 (Zen)" },
    },
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>mu", "<cmd>UndotreeToggle<cr>", desc = "撤销树 (Undotree)" },
    },
  },
}
