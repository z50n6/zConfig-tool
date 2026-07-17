# Plugins Index

基于 LazyVim v8，按职责拆分，每个插件独立文件。

## 目录

| 分组 | 路径 | 职责 |
|------|------|------|
| core | `core/` | 补全、LSP、格式化 |
| lang | `lang/` | 语言专项（LaTeX） |
| tools | `tools/` | 编辑、搜索、Git、终端、效率 |
| ui | `ui/` | 主题、渲染、状态栏、图标 |
| ai | `ai/` | AI 集成 |

## core/ — 核心能力

| 文件 | 插件 | 说明 |
|------|------|------|
| `blink.lua` | `saghen/blink.cmp` | 补全引擎（`nvim-cmp` 已禁用） |
| `lsp.lua` | `nvim-lspconfig` + `mason-lspconfig` | 14 个 LSP server，含 Tailwind `cn`/`cva`/`twMerge` class 正则 |
| `formatting.lua` | `conform.nvim` + `mason.nvim` | 保存时格式化，14 个 formatter 自动安装 |

## lang/ — 语言专项

| 文件 | 插件 | 说明 |
|------|------|------|
| `dap.lua` | — | 调试已禁用（纯阅读定位） |
| `latex.lua` | `lervag/vimtex` | LaTeX 编辑编译 |

## tools/ — 效率工具

| 文件 | 插件 | 说明 |
|------|------|------|
| `coding.lua` | `treesj` `mini.surround` `grug-far` `lightbulb` `trouble` `inc-rename` `todo-comments` | 代码编辑增强与 TODO 导航 |
| `editor.lua` | `which-key` `hop` `auto-save` `toggleterm` `lazygit` `highlight-colors` | 交互、跳转、终端、Git |
| `telescope.lua` | `telescope` + `fzf-native` + `file-browser` | 模糊搜索与文件浏览 |
| `git.lua` | `sindrets/diffview.nvim` | Diff 与历史可视化 |
| `highlight-undo.lua` | `tzachar/highlight-undo.nvim` | 撤销时高亮改动区域 |
| `productivity.lua` | `zen-mode` `undotree` | 专注模式与撤销树 |
| `ime.lua` | `im-select.nvim` | Windows 下自动切换英文输入法 |

## ui/ — 视觉与界面

| 文件 | 插件 | 说明 |
|------|------|------|
| `colorscheme.lua` | `catppuccin/nvim` | Mocha 主题，Neovide 不透明 |
| `ui.lua` | `noice` `markview` `treesitter` `bufferline` `mini.icons` `gitsigns` `snacks` | Snacks 仪表盘 + Explorer、Catppuccin 全组件集成 |
| `rainbow.lua` | `HiPhish/rainbow-delimiters` | 彩虹括号 |
| `lsp-status.lua` | `folke/snacks.nvim` override | 状态栏显示当前 LSP 名称 |

## ai/ — AI 集成

| 文件 | 插件 | 说明 |
|------|------|------|
| `codex.lua` | `johnseth97/codex.nvim` | Codex 浮动面板 |
| `claudecode.lua` | `coder/claudecode.nvim` | Claude Code MCP 集成，含 diff accept/deny |

## 快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `<leader>ff` / `;f` | 查找文件 |
| `<leader>fw` / `;r` | 全文搜索 |
| `;;` | 恢复上次搜索 |
| `gd` / `gr` / `gi` | LSP 定义/引用/实现 (Telescope) |
| `ss` `sv` `sh` `sj` `sk` `sl` | 分屏与窗口移动 |
| `<leader><leader>w` / `<leader><leader>a` | Hop 单词/任意位置跳转 |
| `<leader>gg` | LazyGit |
| `<leader>tt` / `<leader>tf` | 终端 |
| `<leader>ac` / `<leader>ai` | Claude Code / Codex |
| `<leader>y` | Lazy 面板 |
| `<leader>ub` | 切换光标颜色 |

## Markdown 渲染

| 特性 | 插件/配置 | 说明 |
|------|------|------|
| 编辑器内渲染 | `OXY2DEV/markview.nvim` | 标题/粗斜体/表格/代码块/复选框 实时渲染 |
| 显示模式 | `modes = {"n","no","c","i"}` | 全模式渲染 |
| 混合模式 | `hybrid_modes = {}` | 不显示原始语法（纯阅读） |
| 自动换行 | `wrap` + `linebreak` | 长段落自动折行 |
| 拼写检查 | `spell = false` | 已关闭（避免技术术语标红） |
| 语法隐藏 | `conceallevel = 2` | 隐藏 `**` `_` `###` 等标记符 |

> 不再需要 `markdown-preview.nvim`（浏览器预览）和 `render-markdown.nvim`（已被 markview 替代）。
