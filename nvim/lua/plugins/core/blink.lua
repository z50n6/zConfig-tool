-- 作用: 全局补全后端统一为 blink.cmp
-- 包含: hrsh7th/nvim-cmp(禁用), saghen/blink.cmp
return {
  {
    "hrsh7th/nvim-cmp",
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          winblend = vim.o.pumblend,
        },
      },
      signature = {
        window = {
          winblend = vim.o.pumblend,
        },
      },
    },
  },
}
