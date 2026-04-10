-- Keymaps are automatically loaded on the VeryLazy event.
-- Default keymaps that are always set: https://www.lazyvim.org/configuration/keymaps
-- Add any additional keymaps here.

local map = vim.keymap.set

local function opts(desc)
  return { desc = desc, silent = true }
end

-- Telescope 快速入口（更偏“肌肉记忆流”的搜索/导航）
local function with_telescope(cb)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
      vim.notify("telescope.nvim 未加载/未安装", vim.log.levels.WARN)
      return
    end
    cb(builtin)
  end
end

-- 禁用默认的 <leader><leader>（通常是快速文件查找）
pcall(vim.keymap.del, "n", "<leader><leader>")
pcall(vim.keymap.del, "n", "<leader>l")
map("n", "<leader>y", "<cmd>Lazy<cr>", opts("Lazy 面板"))

-- Neovide 缩放（Win11 下很常用）
if vim.g.neovide then
  map({ "n", "i" }, "<C-=>", function()
    vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) + 0.05
  end, opts("Neovide 放大字体"))
  map({ "n", "i" }, "<C-->", function()
    vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) - 0.05
  end, opts("Neovide 缩小字体"))
  map({ "n", "i" }, "<C-0>", function()
    vim.g.neovide_scale_factor = 1.0
  end, opts("Neovide 重置缩放"))
  map("n", "<leader>un", function()
    if type(_G.neovide_cycle_profile) == "function" then
      _G.neovide_cycle_profile()
    end
  end, opts("切换 Neovide 性能档位"))
end

map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>w<cr>", opts("保存文件"))
map("n", "<leader>fn", "<cmd>lua Snacks.explorer.reveal()<cr>", opts("文件树定位当前文件"))
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files({ hidden = true })
end, opts("查找文件"))
map("n", "<leader>fr", function()
  require("telescope.builtin").oldfiles()
end, opts("最近文件"))
map("n", "<leader>fw", function()
  require("telescope.builtin").live_grep()
end, opts("全文搜索"))
map("n", "<leader>fW", function()
  require("telescope.builtin").grep_string()
end, opts("搜索当前单词"))

-- 类 craftzdog 快速键（不占用 <leader>，更快进入搜索）
map("n", ";f", with_telescope(function(builtin)
  builtin.find_files({ hidden = true })
end), opts("Telescope 查找文件"))
map("n", ";r", with_telescope(function(builtin)
  builtin.live_grep({ additional_args = { "--hidden" } })
end), opts("Telescope 全文搜索"))
map("n", ";;", with_telescope(function(builtin)
  builtin.resume()
end), opts("Telescope 恢复上次"))
map("n", ";e", with_telescope(function(builtin)
  builtin.diagnostics()
end), opts("Telescope 诊断列表"))
map("n", ";t", with_telescope(function(builtin)
  builtin.help_tags()
end), opts("Telescope 帮助标签"))
map("n", ";s", with_telescope(function(builtin)
  builtin.treesitter()
end), opts("Telescope Treesitter 符号"))
map("n", "\\\\", with_telescope(function(builtin)
  builtin.buffers()
end), opts("Telescope Buffers"))

-- 当前文件目录浏览（需要 telescope-file-browser 扩展）
map("n", "sf", function()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    vim.notify("telescope.nvim 未加载/未安装", vim.log.levels.WARN)
    return
  end
  local ok_fb = pcall(telescope.load_extension, "file_browser")
  if not ok_fb then
    vim.notify("telescope-file-browser 未加载/未安装", vim.log.levels.WARN)
    return
  end
  local dir = vim.fn.expand("%:p:h")
  telescope.extensions.file_browser.file_browser({
    path = dir,
    cwd = dir,
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 },
  })
end, opts("Telescope 文件浏览器(当前目录)"))

-- LSP 跳转更清晰：不要复用窗口（可选，但对导航很爽）
map("n", "gd", with_telescope(function(builtin)
  builtin.lsp_definitions({ reuse_win = false })
end), opts("跳转定义(Telescope)"))
map("n", "gr", with_telescope(function(builtin)
  builtin.lsp_references()
end), opts("查找引用(Telescope)"))
map("n", "gi", with_telescope(function(builtin)
  builtin.lsp_implementations()
end), opts("查找实现(Telescope)"))
map("n", "<leader>lr", function()
  vim.lsp.buf.rename()
end, opts("LSP 重命名"))
map({ "n", "v" }, "<leader>la", function()
  vim.lsp.buf.code_action()
end, opts("LSP 代码动作"))
map("n", "<leader>ld", function()
  vim.diagnostic.open_float()
end, opts("查看当前诊断"))
map("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, opts("LSP 格式化当前文件"))
map("n", "<leader>li", "<cmd>LspInfo<cr>", opts("LSP 状态信息"))

-- 全选（Normal / Insert / Visual）
map("n", "<C-a>", "ggVG", opts("全选"))
map("i", "<C-a>", "<Esc>ggVG", opts("全选"))
map("x", "<C-a>", "<Esc>ggVG", opts("全选"))

-- Split window
map("n", "ss", "<cmd>split<cr>", opts("水平分屏"))
map("n", "sv", "<cmd>vsplit<cr>", opts("垂直分屏"))
-- Move window
map("n", "sh", "<C-w>h", opts("切到左侧窗口"))
map("n", "sk", "<C-w>k", opts("切到上方窗口"))
map("n", "sj", "<C-w>j", opts("切到下方窗口"))
map("n", "sl", "<C-w>l", opts("切到右侧窗口"))

-- 避免和 LazyVim 默认的 flash.nvim 单键 s/S 冲突：
-- 这里禁用 s/S 跳转，把 ss/sv/sh/sj/sk/sl 作为窗口操作前缀。
pcall(vim.keymap.del, { "n", "x", "o" }, "s")
pcall(vim.keymap.del, { "n", "x", "o" }, "S")

-- Bufferline 标签操作
pcall(vim.keymap.del, "n", "]b")
pcall(vim.keymap.del, "n", "[b")
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", opts("下一个标签"))
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", opts("上一个标签"))
map("n", "<leader>bp", "<cmd>BufferLinePick<cr>", opts("选择标签"))
map("n", "<leader>bd", "<cmd>bdelete<cr>", opts("关闭当前标签"))
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", opts("关闭其他标签"))

local function move_buffer(dir)
  local step = (dir == "left") and -1 or 1
  local times = vim.v.count > 0 and vim.v.count or 1
  local ok, bufferline = pcall(require, "bufferline")
  if not ok then
    return
  end
  for _ = 1, times do
    bufferline.move(step)
  end
end

map("n", "<b", function()
  move_buffer("left")
end, opts("标签左移"))
map("n", ">b", function()
  move_buffer("right")
end, opts("标签右移"))
map("n", "<leader>bh", function()
  move_buffer("left")
end, opts("标签左移"))
map("n", "<leader>bl", function()
  move_buffer("right")
end, opts("标签右移"))

-- hop.nvim 跳转
-- 1) 主用 <leader><leader> 前缀，保持你给的 FanyLazyvim 风格
-- 2) 保留一组 <leader>h 快捷别名，方便单手操作
-- 注意：这里不要在启动阶段 require("hop")，避免插件未加载时 keymaps 直接报错，
-- 同时也更利于 lazy-load（按键触发时再加载/require）。
local function with_hop(cb)
  return function()
    local ok, hop = pcall(require, "hop")
    if not ok then
      vim.notify("hop.nvim 未加载/未安装", vim.log.levels.WARN)
      return
    end
    local hint = require("hop.hint")
    cb(hop, hint)
  end
end

map({ "n", "v" }, "<leader><leader>w", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR })
end), opts("Hop 下一个词首"))
map({ "n", "v" }, "<leader><leader>e", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR, hint_position = hint.HintPosition.END })
end), opts("Hop 下一个词尾"))
map({ "n", "v" }, "<leader><leader>b", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR })
end), opts("Hop 上一个词首"))
map({ "n", "v" }, "<leader><leader>v", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR, hint_position = hint.HintPosition.END })
end), opts("Hop 上一个词尾"))
map({ "n", "v" }, "<leader><leader>l", with_hop(function(hop, hint)
  hop.hint_camel_case({ direction = hint.HintDirection.AFTER_CURSOR })
end), opts("Hop 下一个 camelCase 词"))
map({ "n", "v" }, "<leader><leader>h", with_hop(function(hop, hint)
  hop.hint_camel_case({ direction = hint.HintDirection.BEFORE_CURSOR })
end), opts("Hop 上一个 camelCase 词"))
map({ "n", "v" }, "<leader><leader>f", with_hop(function(hop, hint)
  hop.hint_char1({ direction = hint.HintDirection.AFTER_CURSOR, current_line_only = true })
end), opts("Hop 当前行单字符跳转"))
---@diagnostic disable-next-line: missing-fields
map({ "n", "v" }, "<leader><leader>a", with_hop(function(hop, _)
  hop.hint_anywhere({})
end), opts("Hop 任意位置"))
map({ "n", "v" }, "<leader><leader>j", with_hop(function(hop, hint)
  hop.hint_lines({ direction = hint.HintDirection.AFTER_CURSOR })
end), opts("Hop 跳到下方行"))
map({ "n", "v" }, "<leader><leader>k", with_hop(function(hop, hint)
  hop.hint_lines({ direction = hint.HintDirection.BEFORE_CURSOR })
end), opts("Hop 跳到上方行"))

-- <leader>h 别名（与上面功能一一对应，二选一都能用）
map({ "n", "v" }, "<leader>hw", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR })
end), opts("Hop 下一个词首"))
map({ "n", "v" }, "<leader>he", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR, hint_position = hint.HintPosition.END })
end), opts("Hop 下一个词尾"))
map({ "n", "v" }, "<leader>hb", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR })
end), opts("Hop 上一个词首"))
map({ "n", "v" }, "<leader>hv", with_hop(function(hop, hint)
  hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR, hint_position = hint.HintPosition.END })
end), opts("Hop 上一个词尾"))
map({ "n", "v" }, "<leader>hl", with_hop(function(hop, hint)
  hop.hint_camel_case({ direction = hint.HintDirection.AFTER_CURSOR })
end), opts("Hop 下一个 camelCase 词"))
map({ "n", "v" }, "<leader>hh", with_hop(function(hop, hint)
  hop.hint_camel_case({ direction = hint.HintDirection.BEFORE_CURSOR })
end), opts("Hop 上一个 camelCase 词"))
map({ "n", "v" }, "<leader>hf", with_hop(function(hop, hint)
  hop.hint_char1({ direction = hint.HintDirection.AFTER_CURSOR, current_line_only = true })
end), opts("Hop 当前行单字符跳转"))
---@diagnostic disable-next-line: missing-fields
map({ "n", "v" }, "<leader>ha", with_hop(function(hop, _)
  hop.hint_anywhere({})
end), opts("Hop 任意位置"))
map({ "n", "v" }, "<leader>hj", with_hop(function(hop, hint)
  hop.hint_lines({ direction = hint.HintDirection.AFTER_CURSOR })
end), opts("Hop 跳到下方行"))
map({ "n", "v" }, "<leader>hk", with_hop(function(hop, hint)
  hop.hint_lines({ direction = hint.HintDirection.BEFORE_CURSOR })
end), opts("Hop 跳到上方行"))

-- 在“雷姆蓝 / 拉姆粉”间切换光标颜色（参考 FanyLazyvim 的 highlight Cursor 方案）
local cursor_palette = {
  rem_blue = "#91bef0",
  ram_pink = "#ffb6c1",
}

local function apply_anime_cursor()
  local scheme = vim.g.anime_cursor_scheme or "rem_blue"
  local color = cursor_palette[scheme] or cursor_palette.rem_blue
  local groups = { "Cursor", "lCursor", "CursorIM", "TermCursor" }
  for _, group in ipairs(groups) do
    -- "bg" 不是合法颜色值，这里使用 NONE 让前景走默认，仅覆盖光标背景色。
    vim.api.nvim_set_hl(0, group, { fg = "NONE", bg = color })
  end
end

map("n", "<leader>ub", function()
  vim.g.anime_cursor_scheme = (vim.g.anime_cursor_scheme == "rem_blue") and "ram_pink" or "rem_blue"
  apply_anime_cursor()
  vim.notify("光标已切换：" .. (vim.g.anime_cursor_scheme == "rem_blue" and "雷姆蓝" or "拉姆粉"))
end, opts("切换光标：雷姆蓝/拉姆粉"))

-- Markdown
local function run_markdown_preview(cmd)
  local ok = pcall(vim.cmd, cmd)
  if ok then
    return
  end
  vim.notify(
    "Markdown 预览未就绪：请执行 :Lazy build markdown-preview.nvim 后重试",
    vim.log.levels.WARN
  )
end

map("n", "<leader>mp", function()
  run_markdown_preview("MarkdownPreviewToggle")
end, opts("Markdown 预览开关"))
map("n", "<leader>mP", function()
  run_markdown_preview("MarkdownPreview")
end, opts("Markdown 开始预览"))
map("n", "<leader>ms", function()
  run_markdown_preview("MarkdownPreviewStop")
end, opts("Markdown 停止预览"))
map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", opts("Markdown 渲染开关"))
map("n", "<leader>mR", "<cmd>RenderMarkdown preview<cr>", opts("Markdown 渲染侧边预览"))

-- 主题切换/重载后可能覆盖 Cursor 高亮，这里自动重新应用。
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("anime_cursor_color", { clear = true }),
  callback = apply_anime_cursor,
})
apply_anime_cursor()

map("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal size=12<cr>", opts("水平终端"))
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", opts("浮动终端"))
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=0.4<cr>", opts("垂直终端"))
map("t", "<Esc><Esc>", [[<C-\\><C-n>]], opts("终端返回普通模式"))
map("t", "<C-c>", function()
  local job = vim.b.terminal_job_id
  if job then
    -- ETX (Ctrl+C) to foreground process in terminal job.
    vim.fn.chansend(job, "\003")
  end
end, opts("终端中断当前任务"))
map("n", "<C-c>", function()
  if vim.bo.buftype ~= "terminal" then
    return
  end
  local job = vim.b.terminal_job_id
  if job then
    vim.fn.chansend(job, "\003")
  end
end, opts("普通模式中断终端任务"))

local function stop_all_toggleterm_jobs()
  local ok, term = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm 未加载/未安装", vim.log.levels.WARN)
    return
  end

  local count = 0
  for _, t in pairs(term.get_all() or {}) do
    if t and t.job_id then
      vim.fn.jobstop(t.job_id)
      count = count + 1
    end
  end
  vim.notify(("已停止 %d 个终端任务"):format(count))
end

map("n", "<leader>gg", "<cmd>LazyGit<cr>", opts("打开 LazyGit"))
map("n", "<leader>gl", function()
  require("gitsigns").blame_line({ full = true })
end, opts("查看当前行 Git 信息"))
map("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", opts("切换行内 blame"))

map("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("已复制文件完整路径：" .. path)
end, opts("复制完整路径"))
map("n", "<leader>cP", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify("已复制文件相对路径：" .. path)
end, opts("复制相对路径"))

-- map("n", "<leader>uf", function()
--   vim.g.autoformat = not vim.g.autoformat
--   vim.notify("自动格式化：" .. (vim.g.autoformat and "已开启" or "已关闭"))
-- end, opts("切换自动格式化"))

-- map("n", "<leader>us", function()
--   vim.g.autosave_enabled = not vim.g.autosave_enabled
--   vim.notify("自动保存：" .. (vim.g.autosave_enabled and "已开启" or "已关闭"))
-- end, opts("切换自动保存"))

-- programming language about
-- run single python codes
map("n", "<leader>rp", '<cmd>TermExec cmd="python %"<cr>', opts("运行当前 Python 文件"))
-- run single cmake codes
map("n", "<leader>rc", '<cmd>TermExec cmd="cmake -P %"<cr>', opts("运行当前 CMake 脚本"))
-- execute cargo run
map("n", "<leader>ru", '<cmd>TermExec cmd="cargo run"<cr>', opts("运行 Cargo 项目"))
map("n", "<leader>rg", '<cmd>TermExec cmd="go run %"<cr>', opts("运行当前 Go 文件"))
map("n", "<leader>rk", stop_all_toggleterm_jobs, opts("停止终端运行任务"))
