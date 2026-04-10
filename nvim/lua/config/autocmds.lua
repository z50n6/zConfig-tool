-- Autocmds are automatically loaded on the VeryLazy event.
-- Default autocmds that are always set: https://www.lazyvim.org/configuration/autocmds
-- Add any additional autocmds here.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local user_group = augroup("user_lazyvim_enhance", { clear = true })

autocmd({ "BufRead", "BufNewFile" }, {
  group = user_group,
  pattern = { "*.md", "*.markdown" },
  desc = "Markdown 后缀映射为 markdown filetype",
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})

autocmd("TextYankPost", {
  group = user_group,
  desc = "高亮复制内容",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

autocmd("BufWritePre", {
  group = user_group,
  desc = "保存前自动创建缺失目录",
  callback = function(event)
    local path = event.match
    if path:match("^%w+:[/\\][/\\]") then
      return
    end
    local dir = vim.fn.fnamemodify(path, ":p:h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

autocmd("BufReadPost", {
  group = user_group,
  desc = "恢复上次光标位置",
  callback = function(event)
    local exclude = { gitcommit = true, gitrebase = true, svn = true, hgcommit = true }
    if exclude[vim.bo[event.buf].filetype] then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 1 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("VimResized", {
  group = user_group,
  desc = "缩放终端后平衡窗口",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

autocmd("FileType", {
  group = user_group,
  pattern = { "lua", "python", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "yaml", "markdown" },
  desc = "统一 2 空格缩进",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

autocmd("FileType", {
  group = user_group,
  pattern = { "markdown" },
  desc = "Markdown 增强编辑体验",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
  end,
})

autocmd("FileType", {
  group = user_group,
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  desc = "Go 使用制表符缩进",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

autocmd("FileType", {
  group = user_group,
  pattern = {
    "snacks_layout_box",
    "snacks_picker_list",
    "snacks_picker_input",
    "snacks_picker_preview",
    "snacks_dashboard",
  },
  desc = "统一 Snacks 窗口背景，避免 Explorer 与 Dashboard 色差",
  callback = function()
    vim.wo.winhighlight =
      "Normal:Normal,NormalNC:Normal,SignColumn:Normal,EndOfBuffer:EndOfBuffer,FloatBorder:FloatBorder"
  end,
})
