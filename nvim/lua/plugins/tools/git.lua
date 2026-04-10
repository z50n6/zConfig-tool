-- 作用: Git Diff 与历史可视化
-- 包含: sindrets/diffview.nvim
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Git Diff 视图" },
      { "<leader>gC", "<cmd>DiffviewClose<cr>", desc = "关闭 Diff 视图" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "当前文件历史" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "仓库历史" },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    },
  },
}
