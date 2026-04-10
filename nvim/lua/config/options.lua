-- Options are automatically loaded before lazy.nvim startup.
-- Default options that are always set: https://www.lazyvim.org/configuration/general
-- Add any additional options here.

local opt = vim.opt
local g = vim.g

opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.linebreak = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.updatetime = 200
opt.timeoutlen = 300
opt.pumblend = 10
opt.winblend = 0
opt.conceallevel = 0
opt.confirm = true
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.autowrite = true
opt.autoread = true
opt.inccommand = "split"
opt.laststatus = 3
opt.showmode = false
opt.cmdheight = 0
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "❯",
  precedes = "❮",
}
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
}

if vim.fn.has("win32") == 1 then
  opt.shell = "pwsh"
  opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  opt.shellquote = ""
  opt.shellxquote = ""
end

-- Neovide (Win11) 适配：
-- 保持与终端 nvim 同主题（继续使用你现有 colorscheme），这里只调整 GUI 体验参数。
if g.neovide then
  -- 字体：按你机器安装情况可改成你喜欢的 Nerd Font
  opt.guifont = "CaskaydiaCove Nerd Font Mono:h12"

  -- Neovide 性能档位（均衡/省电/极致）
  local neovide_profiles = {
    {
      name = "极致",
      refresh_rate = 120,
      refresh_rate_idle = 30,
      cursor_animation = 0.05,
      scroll_animation = 0.1,
      position_animation = 0.08,
    },
    {
      name = "均衡",
      refresh_rate = 90,
      refresh_rate_idle = 24,
      cursor_animation = 0.07,
      scroll_animation = 0.14,
      position_animation = 0.12,
    },
    {
      name = "省电",
      refresh_rate = 60,
      refresh_rate_idle = 15,
      cursor_animation = 0.1,
      scroll_animation = 0.2,
      position_animation = 0.18,
    },
  }

  _G.neovide_cycle_profile = function()
    local index = (vim.g.neovide_profile_index or 1) + 1
    if index > #neovide_profiles then
      index = 1
    end
    vim.g.neovide_profile_index = index
    local p = neovide_profiles[index]
    g.neovide_refresh_rate = p.refresh_rate
    g.neovide_refresh_rate_idle = p.refresh_rate_idle
    g.neovide_cursor_animation_length = p.cursor_animation
    g.neovide_scroll_animation_length = p.scroll_animation
    g.neovide_position_animation_length = p.position_animation
    vim.notify(
      ("Neovide 性能档位：%s (%dHz / idle %dHz)"):format(p.name, p.refresh_rate, p.refresh_rate_idle),
      vim.log.levels.INFO
    )
  end

  -- 默认使用“极致”档位
  vim.g.neovide_profile_index = vim.g.neovide_profile_index or 1
  do
    local p = neovide_profiles[vim.g.neovide_profile_index]
    g.neovide_refresh_rate = p.refresh_rate
    g.neovide_refresh_rate_idle = p.refresh_rate_idle
    g.neovide_cursor_animation_length = p.cursor_animation
    g.neovide_scroll_animation_length = p.scroll_animation
    g.neovide_position_animation_length = p.position_animation
  end

  -- 光标与渲染
  g.neovide_cursor_trail_size = 0.2
  g.neovide_cursor_animate_in_insert_mode = true
  g.neovide_cursor_animate_command_line = false

  -- 光标粒子特效（参考 fanlusky/FanyLazyvim options.lua）
  -- 可选: "railgun" "torpedo" "pixiedust" "sonicboom" "ripple" "wireframe"
  g.neovide_cursor_vfx_mode = "pixiedust"
  g.neovide_cursor_vfx_particle_density = 100.0
  g.neovide_floating_shadow = false
  g.neovide_hide_mouse_when_typing = true

  -- GUI 下光标形态：块状普通模式、插入竖条、无闪烁（与 FanyLazyvim 一致）
  opt.guicursor =
    "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait0-blinkoff0-blinkon0-Cursor/lCursor,sm:block-blinkwait0-blinkoff0-blinkon0"

  -- Win11 输入体验
  g.neovide_input_ime = true
  g.neovide_input_touch = false

  -- 为了让 dashboard/普通窗口背景稳定显示主题底色，这里使用不透明。
  g.neovide_opacity = 1.0
  g.neovide_normal_opacity = 1.0
  g.neovide_floating_blur_amount_x = 2.0
  g.neovide_floating_blur_amount_y = 2.0
end

g.autoformat = true
g.autosave_enabled = true
g.snacks_animate = false
g.lazyvim_cmp = "blink.cmp"
g.lazyvim_python_lsp = "pyright"
g.lazyvim_python_ruff = "ruff"
g.lazyvim_ts_lsp = "vtsls"
