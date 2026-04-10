-- 作用: 搜索与文件浏览能力增强
-- 包含: nvim-telescope/telescope.nvim 及 fzf/file_browser 扩展
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- 更快的排序/匹配（Windows 下可能需要编译环境；没有也不影响 Telescope 本体使用）
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    opts = function(_, opts)
      local actions = require("telescope.actions")
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      })
      return opts
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "file_browser")
    end,
  },
}
