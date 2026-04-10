# Plugins Index

按职责拆分后的插件目录结构如下。

## 目录分组

- `core/`: 编辑器核心能力（补全、LSP、格式化）
- `lang/`: 语言/场景特化能力（调试、LaTeX）
- `tools/`: 通用效率工具（搜索、重构、Git、终端、专注）
- `ui/`: 界面与主题（状态、仪表盘、图标、高亮）
- `ai/`: AI 相关插件

## 文件索引

- `core/blink.lua`
  - 职责: 全局补全后端统一为 `blink.cmp`
  - 插件: `hrsh7th/nvim-cmp`(禁用), `saghen/blink.cmp`
- `core/lsp.lua`
  - 职责: LSP 服务器、诊断和 inlay hints 统一配置
  - 说明: 已增强 Tailwind（`classAttributes` + `classRegex`，含 `twMerge`/`tv`/`clsx`/`cn`/`cva`）
  - 插件: `neovim/nvim-lspconfig`, `mason-org/mason-lspconfig.nvim`
- `core/formatting.lua`
  - 职责: 代码格式化与工具链安装
  - 插件: `stevearc/conform.nvim`, `mason-org/mason.nvim`

- `lang/dap.lua`
  - 职责: Go/Python 调试与调试器自动安装
  - 插件: `leoluz/nvim-dap-go`, `mfussenegger/nvim-dap-python`, `jay-babu/mason-nvim-dap.nvim`
- `lang/latex.lua`
  - 职责: LaTeX 编辑、编译、预览
  - 插件: `lervag/vimtex`

- `tools/coding.lua`
  - 职责: 代码编辑增强、重构、TODO 导航
  - 插件: `Wansmer/treesj`, `nvim-mini/mini.surround`, `MagicDuck/grug-far.nvim`, `kosayoda/nvim-lightbulb`, `folke/trouble.nvim`, `smjonas/inc-rename.nvim`, `folke/todo-comments.nvim`
- `tools/editor.lua`
  - 职责: 编辑交互、跳转、自动保存、终端和 Git 命令入口
  - 插件: `folke/which-key.nvim`, `smoka7/hop.nvim`, `okuuva/auto-save.nvim`, `akinsho/toggleterm.nvim`, `kdheepak/lazygit.nvim`, `brenoprata10/nvim-highlight-colors`
- `tools/telescope.lua`
  - 职责: 模糊搜索与文件浏览
  - 插件: `nvim-telescope/telescope.nvim`, `nvim-telescope/telescope-fzf-native.nvim`, `nvim-telescope/telescope-file-browser.nvim`
- `tools/git.lua`
  - 职责: Git diff 与历史可视化
  - 插件: `sindrets/diffview.nvim`
- `tools/productivity.lua`
  - 职责: 专注模式与撤销树
  - 插件: `folke/zen-mode.nvim`, `mbbill/undotree`

- `ui/colorscheme.lua`
  - 职责: 主题、组件高亮与 Catppuccin 集成
  - 插件: `LazyVim/LazyVim`, `catppuccin/nvim`
- `ui/ui.lua`
  - 职责: 仪表盘、bufferline、icons、gitsigns、snacks 与 UI 细节
  - 说明: 已加入 Noice 降噪（过滤 `No information available`）与失焦系统通知转发
  - 插件: `lazyvim.plugins.extras.editor.snacks_explorer`(import), `folke/noice.nvim`, `iamcco/markdown-preview.nvim`(禁用), `nvim-treesitter/nvim-treesitter`, `akinsho/bufferline.nvim`, `nvim-mini/mini.icons`, `lewis6991/gitsigns.nvim`, `folke/snacks.nvim`

- `ai/codex.lua`
  - 职责: Codex AI 面板与快捷键
  - 插件: `johnseth97/codex.nvim`
- `ai/claudecode.lua`
  - 职责: Claude Code IDE 集成（MCP 协议、diff、上下文）
  - 插件: `coder/claudecode.nvim`（依赖 `folke/snacks.nvim`）

## Keymaps 补充

- `lua/config/keymaps.lua`
  - `gd`: 使用 Telescope 跳转定义并设置 `reuse_win = false`
  - `<leader>li`: `:checkhealth vim.lsp`（Neovim 0.11+ 下 `:LspInfo` 可能不可用）
