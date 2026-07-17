# 💤 LazyVim (Win11 + Neovide)

基于 LazyVim v8，定位为**纯编辑器**（非 IDE）：快速、专注、阅读友好。

## 1. 必需环境

- `git`
- `neovim`（建议 0.10+）
- `nodejs` / `npm`（Treesitter 编译依赖）
- `ripgrep (rg)`（全文搜索）
- `fd`（文件搜索）
- `C/C++ 编译器`（Treesitter parser 编译，推荐 `llvm/clang`）
- Nerd Font（推荐 `CaskaydiaCove Nerd Font Mono`）
- 可选：`go`、`python`（对应 LSP 需要时才装）

## 2. 一键安装（Scoop）

```powershell
scoop bucket add main
scoop bucket add extras
scoop install git neovim nodejs ripgrep fd llvm mingw
```

可选：

```powershell
scoop install neovide           # GUI 客户端
scoop install im-select         # 自动英文输入法
npm install -g tree-sitter-cli  # 语法树命令行
```

## 3. 首次启动

```vim
:Lazy sync
:TSUpdate
:checkhealth
```

> `mason.nvim` 懒加载，需要时 `:Mason` 即可。

## 4. 配置文件索引

| 文件/目录 | 作用 |
| --- | --- |
| `lua/config/options.lua` | 全局选项（编码、缩进、Neovide 性能档位/光标特效） |
| `lua/config/keymaps.lua` | 全部自定义快捷键 |
| `lua/config/autocmds.lua` | 自动命令（文件类型设置、恢复光标位置等） |
| `lua/config/lazy.lua` | lazy.nvim 启动配置 |
| `lua/plugins/core/` | 补全、LSP、格式化 |
| `lua/plugins/lang/` | 语言专项（LaTeX） |
| `lua/plugins/tools/` | 搜索、Git、终端、跳转、效率 |
| `lua/plugins/ui/` | 主题、渲染、状态栏、图标 |
| `lua/plugins/ai/` | Codex / Claude Code |

## 5. 快捷键速查

> 与 LazyVim 默认键位的主要差异：`gd`/`gr`/`gi` 改为 Telescope 版本；LSP 键位重映射到 `<leader>l` 组。

### 搜索（Telescope）

| 快捷键 | 说明 |
| --- | --- |
| `;f` / `<leader>ff` | 查找文件 |
| `;r` / `<leader>fw` | 全文搜索 |
| `;;` | 恢复上次搜索 |
| `;e` | 诊断列表 |
| `;s` | Treesitter 符号 |
| `\\` | Buffer 列表 |
| `sf` | 当前目录文件浏览 |

### LSP（`<leader>l`）

| 快捷键 | 说明 |
| --- | --- |
| `gd` / `gr` / `gi` | 定义 / 引用 / 实现（Telescope） |
| `<leader>la` | 代码动作 |
| `<leader>lr` | 重命名 |
| `<leader>ld` | 查看当前诊断 |
| `<leader>lf` | 格式化当前文件 |
| `<leader>li` | LSP 健康检查 |
| `<leader>ls` / `<leader>lS` | 文档符号 / 工作区符号 |

### 运行代码（`<leader>r`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>rp` | `python %` |
| `<leader>rg` | `go run %` |
| `<leader>ru` | `cargo run` |
| `<leader>rc` | `cmake -P %` |
| `<leader>rk` | 停止所有终端任务 |

### 终端（`<leader>t`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>tt` / `<leader>tf` / `<leader>tv` | 水平 / 浮动 / 垂直终端 |
| `<Esc><Esc>`（终端模式） | 切回普通模式 |
| `<C-c>` | 中断当前终端任务 |

### Hop 跳转（`<leader><leader>` / `<leader>h`）

> `<leader><leader>*` 和 `<leader>h*` 功能相同，选一套用即可。

| 主键 | 别名 | 说明 |
| --- | --- | --- |
| `<leader><leader>w` | `<leader>hw` | 下一个词首 |
| `<leader><leader>b` | `<leader>hb` | 上一个词首 |
| `<leader><leader>a` | `<leader>ha` | 任意位置 |
| `<leader><leader>j` | `<leader>hj` | 下方行 |
| `<leader><leader>k` | `<leader>hk` | 上方行 |
| `<leader><leader>f` | `<leader>hf` | 当前行单字符 |
| `<leader><leader>l` | `<leader>hl` | 下一个 camelCase |
| `<leader><leader>e` | `<leader>he` | 下一个词尾 |

### 窗口与标签

| 快捷键 | 说明 |
| --- | --- |
| `<C-s>` | 保存 |
| `ss` / `sv` | 水平 / 垂直分屏 |
| `sh` `sj` `sk` `sl` | 窗口移动 |
| `]b` / `[b` | 下一个 / 上一个标签 |
| `<b` / `>b` | 标签左移 / 右移 |
| `<leader>bd` / `<leader>bo` | 关闭 / 关闭其他标签 |

### Git

| 快捷键 | 说明 |
| --- | --- |
| `<leader>gg` | LazyGit |
| `<leader>gl` | 行 blame |
| `<leader>gD` / `<leader>gC` | DiffView 打开 / 关闭 |
| `<leader>gF` / `<leader>gH` | 文件历史 / 仓库历史 |

### AI

| 快捷键 | 说明 |
| --- | --- |
| `<leader>ac` | Claude Code 开关 |
| `<leader>af` | 聚焦 Claude 终端 |
| `<leader>ai` | Codex 开关 |

### 专注与效率

| 快捷键 | 说明 |
| --- | --- |
| `<leader>mz` | Zen Mode |
| `<leader>mu` | Undotree |
| `<leader>sr` | 搜索替换（GrugFar） |
| `]T` / `[T` | 下一个 / 上一个 TODO |
| `<leader>st` | Telescope 搜索 TODO |

### Neovide 专用

| 快捷键 | 说明 |
| --- | --- |
| `<C-=>` / `<C-->` / `<C-0>` | 放大 / 缩小 / 重置缩放 |
| `<leader>un` | 切换性能档位 |
| `<leader>ub` | 切换光标颜色 |

## 6. Markdown 渲染

| 特性 | 配置 | 说明 |
|------|------|------|
| 编辑器内渲染 | `OXY2DEV/markview.nvim`，`lazy = false` | 标题/粗斜体/表格/代码块/复选框 实时渲染 |
| 显示模式 | `modes = {"n","no","c","i"}`，`hybrid_modes = {}` | 全模式始终渲染，不显示原始语法 |
| 自动换行 | `wrap` + `linebreak` | 长段落自动折行 |
| 拼写检查 | `spell = false` | 已关闭（技术文档术语多，避免红波浪） |
| 语法隐藏 | `conceallevel = 2` | 隐藏 `**` `_` `###` 等标记符 |

> 已移除 `markdown-preview.nvim`（浏览器预览）和 `render-markdown.nvim`（已被 markview 替代）。

## 7. 性能说明

- `hop.nvim`：按键触发懒加载
- `mason.nvim`：`VeryLazy`，避免后台安装拖慢启动
- `nvim-highlight-colors`：仅前端文件类型加载
- `markview.nvim`：`lazy = false`（markdown 打开即渲染）
- 已禁用 `netrw*`（使用 Snacks Explorer）
- LSP `codelens` 默认关闭
- DAP 调试功能已禁用

需要定位卡顿时 `:Lazy profile`。
