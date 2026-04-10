-- 作用: Claude Code IDE 级集成（WebSocket MCP，与 VS Code 插件同协议）
-- 插件: coder/claudecode.nvim · 依赖 folke/snacks.nvim
-- 需本机已安装 Claude Code CLI（`claude` 在 PATH）；本地安装见 opts 注释
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend",
      "ClaudeCodeAdd",
      "ClaudeCodeSelectModel",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeTreeAdd",
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code 开关" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "聚焦 Claude 终端" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "恢复 Claude 会话" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "继续 Claude 会话" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "选择 Claude 模型" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "当前文件加入 Claude 上下文" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "选区发送到 Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "文件树中文件加入 Claude",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_layout_box" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "接受 Claude diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "拒绝 Claude diff" },
    },
    opts = {
      git_repo_cwd = true,
      log_level = "warn",
      -- 若使用 `claude migrate-installer` 本地安装，可改为实际路径，例如：
      -- terminal_cmd = vim.fn.expand("~/.claude/local/claude"),
      terminal = {
        split_side = "right",
        split_width_percentage = 0.32,
        provider = "auto",
        auto_close = true,
        snacks_win_opts = {
          position = "float",
          width = 0.88,
          height = 0.88,
          border = "rounded",
          keys = {
            claude_hide = {
              "<C-\\><C-n>",
              function(self)
                self:hide()
              end,
              mode = "t",
              desc = "退出终端模式并隐藏浮窗",
            },
          },
        },
      },
      diff_opts = {
        layout = "vertical",
        open_in_new_tab = false,
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)
    end,
  },
}
