-- 作用: 主题与高亮体系（Catppuccin）
-- 包含: LazyVim/LazyVim, catppuccin/nvim
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.termguicolors = true
      vim.o.background = "dark"
    end,
    opts = {
      flavour = "mocha",
      term_colors = true,
      -- Neovide 下关闭主题透明，避免 dashboard 显示为黑底。
      transparent_background = not vim.g.neovide,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      integrations = {
        aerial = true,
        blink_cmp = true,
        flash = true,
        gitsigns = true,
        grug_far = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      custom_highlights = function(colors)
        return {
          RainbowRed = { fg = "#E06C75" },
          RainbowYellow = { fg = "#E5C07B" },
          RainbowBlue = { fg = "#61AFEF" },
          RainbowOrange = { fg = "#D19A66" },
          RainbowGreen = { fg = "#98C379" },
          RainbowViolet = { fg = "#C678DD" },
          RainbowCyan = { fg = "#56B6C2" },
          CursorLine = { bg = "NONE" },
          CursorLineNr = { fg = colors.mauve, style = { "bold" } },
          BufferLineFill = { bg = colors.none },
          BufferLineBackground = { fg = colors.overlay0, bg = colors.none },
          BufferLineSeparator = { fg = colors.none, bg = colors.none },
          BufferLineSeparatorSelected = { fg = colors.none, bg = colors.none },
          BufferLineIndicatorSelected = { fg = colors.mauve, bg = colors.none },
          SnacksDashboardHeader = { fg = colors.blue, style = { "bold" } },
          SnacksDashboardIcon = { fg = colors.pink },
          SnacksDashboardKey = { fg = colors.pink, style = { "bold" } },
          SnacksDashboardDesc = { fg = colors.text },
          SnacksDashboardFooter = { fg = colors.overlay1 },
          SnacksDashboardSpecial = { fg = colors.surface2 },
          -- 统一 Snacks Explorer / Picker 与 Dashboard 的底色，避免左右区域色差明显。
          SnacksNormal = { fg = colors.text, bg = colors.base },
          SnacksPicker = { fg = colors.text, bg = colors.base },
          SnacksPickerInput = { fg = colors.text, bg = colors.base },
          SnacksPickerList = { fg = colors.text, bg = colors.base },
          SnacksPickerPreview = { fg = colors.text, bg = colors.base },
          SnacksPickerBorder = { fg = colors.surface2, bg = colors.base },
          SnacksPickerTitle = { fg = colors.blue, bg = colors.base, style = { "bold" } },
          NormalFloat = { bg = colors.base },
          FloatBorder = { fg = colors.surface2, bg = colors.base },
          Visual = { bg = colors.surface1 },
          WinSeparator = { fg = colors.surface2 },
        }
      end,
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.special.bufferline").get_theme()
          end
        end,
      },
    },
  },
}
