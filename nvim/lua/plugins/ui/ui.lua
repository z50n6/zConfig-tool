-- 作用: UI 组件、图标与仪表盘体验
-- 包含: snacks_explorer 导入, treesitter 扩展, bufferline, mini.icons, gitsigns, snacks.nvim
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

  { import = "lazyvim.plugins.extras.editor.snacks_explorer" },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.routes = opts.routes or {}

      -- 过滤无用提示，减少消息噪音
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })

      -- 失焦时将通知转系统消息，避免错过关键信息
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local ok, presets = pcall(require, "markview.presets")
      require("markview").setup({
        preset = ok and presets.obsidian or nil,
        -- 纯阅读：所有模式都渲染，不显示原始语法
        modes = { "n", "no", "c", "i" },
        hybrid_modes = {},
        callbacks = {
          on_enable = function(_, win)
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "nc"
          end,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      add_unique(opts.ensure_installed, {
        "bash",
        "c",
        "cpp",
        "cmake",
        "css",
        "diff",
        "dockerfile",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "html",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        "php",
        "python",
        "query",
        "regex",
        "ruby",
        "rust",
        "scss",
        "sql",
        "latex",
        "bibtex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "xml",
        "yaml",
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.always_show_bufferline = true
      opts.options.separator_style = "thin"
      opts.options.show_close_icon = false
      opts.options.show_buffer_close_icons = false
      opts.options.diagnostics = "nvim_lsp"
      opts.options.diagnostics_indicator = function(_, _, diag)
        local icons = LazyVim.config.icons.diagnostics
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return vim.trim(ret)
      end
      opts.options.offsets = {
        {
          filetype = "snacks_layout_box",
          text = "Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      }
      opts.highlights = opts.highlights or require("catppuccin.special.bufferline").get_theme()
    end,
  },
  {
    "nvim-mini/mini.icons",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.file = vim.tbl_deep_extend("force", opts.file or {}, {
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        ["pyproject.toml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["go.mod"] = { glyph = "", hl = "MiniIconsBlue" },
      })
      opts.filetype = vim.tbl_deep_extend("force", opts.filetype or {}, {
        yaml = { glyph = "", hl = "MiniIconsYellow" },
        markdown = { glyph = "", hl = "MiniIconsGrey" },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      preview_config = {
        border = "rounded",
      },
    },
  },
  {
    "folke/snacks.nvim",
    -- 原 `<leader>,` 的 Snacks 缓冲列表已关掉；缓冲列表改由 Telescope `<leader>bf`（见 telescope.lua）
    keys = {
      { "<leader>,", false },
      -- Grep 根目录：与 LazyVim `<leader>sg` 相同，去掉重复的 `<leader>/`
      { "<leader>/", false },
      -- 分屏改用 keymaps.lua 中 ss/sv 等；去掉 LazyVim/Snacks 默认
      { "<leader>-", false },
      { "<leader>|", false },
      -- 草稿缓冲迁到 `<leader>b`（原 `<leader>S` / `<leader>.`）
      { "<leader>S", false },
      { "<leader>.", false },
      {
        "<leader>bS",
        function()
          Snacks.scratch.select()
        end,
        desc = "选择草稿缓冲 (Snacks)",
      },
      {
        "<leader>b.",
        function()
          Snacks.scratch()
        end,
        desc = "切换草稿缓冲 (Snacks)",
      },
    },
    opts = function(_, opts)
      opts.explorer = opts.explorer or {}
      opts.indent = opts.indent or {}
      opts.picker = opts.picker or {}
      opts.picker.hidden = true
      opts.picker.ignored = true
      opts.dashboard = {
        enabled = true,
        preset = {
          pick = function(cmd, picker_opts)
            return LazyVim.pick(cmd, picker_opts)()
          end,
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua require('telescope.builtin').find_files({ hidden = true })" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua require('telescope.builtin').live_grep()" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua require('telescope.builtin').oldfiles()" },
            { icon = " ", key = "c", desc = "Config", action = ":lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config'), hidden = true })" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "S", desc = "Select Session", action = ":lua require('persistence').select()" },
            { icon = "󰒲 ", key = "y", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit Neovim", action = ":qa" },
          },
        },
        formats = {
          header = { "%s", align = "center", hl = "SnacksDashboardHeader" },
          icon = function(item)
            return { item.icon, width = 2, hl = "SnacksDashboardIcon" }
          end,
          key = function(item)
            return { { item.key, hl = "SnacksDashboardKey" } }
          end,
          desc = function(item)
            return { { item.desc, hl = "SnacksDashboardDesc" } }
          end,
          footer = { "%s", align = "center", hl = "SnacksDashboardFooter" },
        },
        sections = {
          { section = "header", padding = 2 },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      }
    end,
  },
}
