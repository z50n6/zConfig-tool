-- 状态栏显示当前 LSP 名称
return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      opts.statusline = opts.statusline or {}
      opts.statusline.left = opts.statusline.left or {}

      -- 添加 LSP 名称组件到状态栏左侧
      table.insert(opts.statusline.left, 1, function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return ""
        end
        local names = {}
        for _, c in ipairs(clients) do
          table.insert(names, c.name)
        end
        return "  " .. table.concat(names, ", ")
      end)
    end,
  },
}
