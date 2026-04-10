-- 作用: LaTeX 编辑/编译/预览
-- 包含: lervag/vimtex
return {
  -- LaTeX：编辑/编译/预览
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "bib" },
    init = function()
      vim.g.vimtex_view_method = "zathura"
      if vim.fn.has("win32") == 1 then
        -- Windows 下常见可用 viewer：SumatraPDF（需自行安装）
        vim.g.vimtex_view_method = "sumatrapdf"
      end
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_syntax_conceal_disable = 1
    end,
  },
}
