-- 作用: AI 助手入口与快捷键
-- 包含: johnseth97/codex.nvim
return {
  {
    "johnseth97/codex.nvim",
    cmd = { "Codex", "CodexToggle" },
    keys = {
      {
        "<leader>ai",
        function()
          require("codex").toggle()
        end,
        desc = "Codex 开关",
        mode = { "n", "t" },
      },
    },
    opts = {
      -- 不使用插件内置的 <leader>cc，避免和你现有 leader 体系冲突
      keymaps = {
        toggle = nil,
        quit = "<C-q>",
      },
      -- Windows/跨平台：如果本机没装 codex CLI，就让插件自动装（需要 Node/npm）
      autoinstall = true,
      -- 浮窗体验更接近“随用随开”
      panel = false,
      width = 0.85,
      height = 0.85,
      -- model = nil, -- 需要的话你可以在这里指定，例如 "o3-mini"
      use_buffer = false,
    },
  },
}
