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
        { "<leader><leader>", group = "Hop 跳转" },
        { "<leader>a", group = "AI (Codex / Claude Code)" },
        { "<leader>ai", desc = "Codex 开关" },
        { "<leader>ac", desc = "Claude Code 开关" },
        { "<leader>af", desc = "聚焦 Claude 终端" },
        { "<leader>ar", desc = "恢复 Claude 会话" },
        { "<leader>aC", desc = "继续 Claude 会话" },
        { "<leader>am", desc = "选择 Claude 模型" },
        { "<leader>ab", desc = "当前文件加入 Claude 上下文" },
        { "<leader>as", desc = "发送到 Claude / 文件树加入上下文" },
        { "<leader>aa", desc = "接受 Claude diff" },
        { "<leader>ad", desc = "拒绝 Claude diff" },
        { "<leader>y", group = "Lazy" },
        { "<leader>b", group = "Buffer/标签" },
        { "<leader>bb", desc = "缓冲列表 (常用切换)" },
        { "<leader>bB", desc = "缓冲列表 (全部)" },
        { "<leader>bS", desc = "选择草稿缓冲 (Snacks)" },
        { "<leader>b.", desc = "切换草稿缓冲 (Snacks)" },
        { "<leader>l", group = "LSP" },
        { "<leader>la", desc = "LSP 代码动作" },
        { "<leader>ld", desc = "查看当前诊断" },
        { "<leader>lf", desc = "LSP 格式化当前文件" },
        { "<leader>li", desc = "LSP 状态信息" },
        { "<leader>lr", desc = "LSP 重命名" },
        { "<leader>ls", desc = "LSP Symbols" },
        { "<leader>lS", desc = "LSP Workspace Symbols" },
        { "<leader>f", group = "文件/搜索" },
        { "<leader>fk", desc = "搜索快捷键 (Telescope)" },
        { "<leader>s", group = "搜索替换/TODO" },
        { "<leader>sr", desc = "搜索替换 (GrugFar)" },
        { "<leader>st", desc = "TODO 列表 (Telescope)" },
        { "]T", desc = "下一个 TODO" },
        { "[T", desc = "上一个 TODO" },
        { "<leader>t", group = "终端" },
        { "<leader>g", group = "Git" },
        { "<leader>gD", desc = "Git Diff 视图" },
        { "<leader>gC", desc = "关闭 Diff 视图" },
        { "<leader>gF", desc = "当前文件历史 (Diffview)" },
        { "<leader>gH", desc = "仓库历史 (Diffview)" },
        { "<leader>c", group = "代码/复制" },
        { "<leader>cj", desc = "Join/Split (TreeSJ)" },
        { "<leader>h", group = "Hop 跳转" },
        { "<leader>m", group = "模式/效率/Markdown" },
        { "<leader>mz", desc = "专注模式 (Zen)" },
        { "<leader>mu", desc = "撤销树 (Undotree)" },
        { "<leader>mp", desc = "Markdown 预览开关" },
        { "<leader>mP", desc = "Markdown 开始预览" },
        { "<leader>mr", desc = "Markdown 渲染开关" },
        { "<leader>mR", desc = "Markdown 渲染侧边预览" },
        { "<leader>ms", desc = "Markdown 停止预览" },
        { "<leader>r", group = "运行代码" },
        { "<leader>rk", desc = "停止终端运行任务" },
        { "<leader>u", group = "开关" },
      })
      if vim.g.neovide then
        vim.list_extend(opts.spec, {
          { "<C-=>", desc = "Neovide 放大字体", mode = { "n", "i" } },
          { "<C-->", desc = "Neovide 缩小字体", mode = { "n", "i" } },
          { "<C-0>", desc = "Neovide 重置缩放", mode = { "n", "i" } },
          { "<leader>un", desc = "切换 Neovide 性能档位" },
        })
      end
    end,
  },
  {
    "smoka7/hop.nvim",
    version = "*",
    -- 通过按键触发加载，避免启动阶段就同步加载 hop
    keys = {
      { "<leader><leader>w", mode = { "n", "v" } },
      { "<leader><leader>e", mode = { "n", "v" } },
      { "<leader><leader>b", mode = { "n", "v" } },
      { "<leader><leader>v", mode = { "n", "v" } },
      { "<leader><leader>l", mode = { "n", "v" } },
      { "<leader><leader>h", mode = { "n", "v" } },
      { "<leader><leader>f", mode = { "n", "v" } },
      { "<leader><leader>a", mode = { "n", "v" } },
      { "<leader><leader>j", mode = { "n", "v" } },
      { "<leader><leader>k", mode = { "n", "v" } },
      { "<leader>hw", mode = { "n", "v" } },
      { "<leader>he", mode = { "n", "v" } },
      { "<leader>hb", mode = { "n", "v" } },
      { "<leader>hv", mode = { "n", "v" } },
      { "<leader>hl", mode = { "n", "v" } },
      { "<leader>hh", mode = { "n", "v" } },
      { "<leader>hf", mode = { "n", "v" } },
      { "<leader>ha", mode = { "n", "v" } },
      { "<leader>hj", mode = { "n", "v" } },
      { "<leader>hk", mode = { "n", "v" } },
    },
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
    -- 只在可能需要颜色渲染的文件类型中加载，避免在常规开发/配置文件中产生额外开销。
    ft = {
      "css",
      "scss",
      "less",
      "sass",
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "svelte",
      "astro",
      "tailwindcss",
    },
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
