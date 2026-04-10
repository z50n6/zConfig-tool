-- 作用: 编辑交互与终端/Git 辅助
-- 包含: which-key, hop.nvim, auto-save, toggleterm, lazygit, nvim-highlight-colors
return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { ";", group = "Telescope(快速)" },
        { "s", group = "窗口/浏览" },
        { "<leader>a", group = "AI" },
        { "<leader>y", group = "Lazy" },
        { "<leader>l", group = "LSP" },
        { "<leader>la", desc = "LSP 代码动作" },
        { "<leader>ld", desc = "查看当前诊断" },
        { "<leader>lf", desc = "LSP 格式化当前文件" },
        { "<leader>li", desc = "LSP 状态信息" },
        { "<leader>lr", desc = "LSP 重命名" },
        { "<leader>f", group = "文件/搜索" },
        { "<leader>t", group = "终端" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "代码/复制" },
        { "<leader>h", group = "Hop 跳转" },
        { "<leader>m", group = "模式/效率/Markdown" },
        { "<leader>mp", desc = "Markdown 预览开关" },
        { "<leader>mP", desc = "Markdown 开始预览" },
        { "<leader>mr", desc = "Markdown 渲染开关" },
        { "<leader>mR", desc = "Markdown 渲染侧边预览" },
        { "<leader>ms", desc = "Markdown 停止预览" },
        { "<leader>r", group = "运行代码" },
        { "<leader>rk", desc = "停止终端运行任务" },
        { "<leader>u", group = "开关" },
      })
    end,
  },
  {
    "smoka7/hop.nvim",
    version = "*",
    opts = {},
  },
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      debounce_delay = 500,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost", "InsertLeave", "TextChanged" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = function(buf)
        if vim.g.autosave_enabled == false then
          return false
        end
        if vim.bo[buf].buftype ~= "" then
          return false
        end
        if vim.bo[buf].modifiable == false or vim.bo[buf].readonly then
          return false
        end
        local ignore = {
          snacks_dashboard = true,
          lazy = true,
          mason = true,
        }
        return not ignore[vim.bo[buf].filetype]
      end,
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,
      direction = "float",
      float_opts = {
        border = "rounded",
      },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = {
      render = "background",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_hsl_without_function = true,
      enable_ansi = true,
      enable_var_usage = true,
      enable_tailwind = true,
    },
  },
}
