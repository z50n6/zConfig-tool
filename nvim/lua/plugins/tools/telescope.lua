-- 作用: 搜索与文件浏览能力增强
-- 包含: nvim-telescope/telescope.nvim 及 fzf/file_browser 扩展
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      -- 对应 LazyVim 原 `<leader>fb` / `<leader>fB`，迁到 `<leader>b` 组
      {
        "<leader>bb",
        function()
          require("telescope.builtin").buffers({
            sort_mru = true,
            sort_lastused = true,
            ignore_current_buffer = true,
          })
        end,
        desc = "缓冲列表 (常用切换)",
      },
      {
        "<leader>bB",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "缓冲列表 (全部)",
      },
      { "<leader>fb", false },
      { "<leader>fB", false },
      {
        "<leader>fk",
        "<cmd>Telescope keymaps<cr>",
        desc = "搜索快捷键 (Telescope keymaps)",
      },
    },
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
      -- 与 LazyVim 合并 keys 时 `{ "<leader>fb", false }` 可能不生效，加载后再删一次
      pcall(vim.keymap.del, "n", "<leader>fb")
      pcall(vim.keymap.del, "n", "<leader>fB")
    end,
  },
}
