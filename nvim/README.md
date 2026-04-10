# 💤 LazyVim (Win11 + Neovide)

这是我在 Windows 11 上使用的 LazyVim 配置，包含 Neovide、Hop、ToggleTerm、Treesitter 等常用能力。

## 1. 必需环境

- `git`
- `neovim` (建议 `0.10+`)
- `nodejs` / `npm`（Treesitter、部分 LSP/工具依赖）
- `go`（Go 开发、`gopls`、`goimports`、`gofmt`）
- `ripgrep (rg)`（全文搜索）
- `fd`（文件搜索）
- `gzip`（部分插件/压缩流程）
- `C/C++ 编译器`（用于 `nvim-treesitter` 编译 parser）
  - 推荐：`llvm/clang`（优先）
  - 兜底：`gcc`（可选）
- Nerd Font（建议 `CaskaydiaCove Nerd Font Mono` 或 `CascadiaCode Nerd Font`）

## 2. 一键安装命令（Scoop）

> 先安装 [Scoop](https://scoop.sh/) 后再执行：

```powershell
scoop bucket add main
scoop bucket add extras
scoop install git neovim nodejs go ripgrep fd gzip llvm mingw
```

可选（用于语法树命令行工具）：

```powershell
npm install -g tree-sitter-cli
```

可选（Neovim/Neovide 启动后默认英文输入法）：

```powershell
scoop install im-select
```

## 3. Go 工具安装（建议）

> `gofmt` 随 Go 自带，无需单独安装。

```powershell
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
```

确认已加入环境变量后可检查：

```powershell
go version
gopls version
goimports -h
```

## 4. Neovide 安装（可选）

```powershell
scoop install neovide
```

## 5. 首次启动后的建议命令

在 Neovim 中执行：

```vim
:Lazy sync
:TSUpdate
:checkhealth
```

> 说明：`mason.nvim` 在此配置里是**懒加载**的。需要时再运行 `:Mason`（会自动加载插件并打开面板）。

## 6. Treesitter 编译说明（Windows 重点）

本配置已将 Treesitter 编译器优先级设为：

1. `clang`
2. `zig`
3. `gcc`

如果出现 `Failed to compile parser`，请先确认：

- `clang --version` 可用
- `:TSUpdate` 后重试
- `:checkhealth nvim-treesitter` 查看诊断

## 7. 字体与终端建议

- 终端/Neovide 请使用 Nerd Font，否则图标会显示异常。
- PowerShell 推荐使用 `pwsh`。

## 8. 参考文档

- [LazyVim 官方文档](https://www.lazyvim.org/)
- [Neovide](https://neovide.dev/)

## 9. 配置文件索引

| 文件/目录 | 作用 |
| --- | --- |
| `lua/config/options.lua` | 全局编辑器选项（编码、界面、缩进、shell、Neovide 参数等） |
| `lua/config/keymaps.lua` | 自定义快捷键总入口（搜索、LSP、终端、运行、Hop、Git 等） |
| `lua/config/autocmds.lua` | 自动命令（保存前处理、文件类型局部设置、窗口行为等） |
| `lua/plugins/*` | 插件分域配置（按 `core` / `ui` / `tools` / `lang` 等拆分） |

维护建议：
- 优先把“行为规则”放在 `config/*`，把“插件参数”放在 `plugins/*`
- 新增功能时先决定归属：是编辑器基础行为，还是某个插件能力

## 10. 输入法：进入后默认英文（Windows / Neovide）

目标：进入 nvim/Neovide 或窗口重新获得焦点时，输入法自动切到英文；进入插入模式恢复上一次使用的输入法。

- 配置文件：`lua/plugins/tools/ime.lua`
- 依赖：系统 `PATH` 可找到 `im-select.exe`（推荐用 Scoop 安装：`scoop install im-select`）
- 默认英文码：`1033`

如果你的英文不是 `1033`，可以在 PowerShell 里运行一次 `im-select.exe` 查看当前输入法编号，再改 `default_im_select`。

## 11. 自定义快捷键速查

> 以下为当前配置中常用的**自定义**映射，定义位置主要在 `lua/config/keymaps.lua`、`lua/plugins/tools/editor.lua`（which-key 分组），以及 `lua/plugins/tools/*.lua`、`lua/plugins/ai/*.lua` 等插件内的 `keys`。
>
> 与 LazyVim 默认键位的主要差异：
> - 已移除默认 `"<leader>l"` 绑定后，再按你的习惯重建了 LSP 分组映射（如 `<leader>la` / `<leader>lr` / `<leader>li`）。
> - `gd` 被改为 Telescope 版本（`reuse_win = false`），以避免定义跳转复用当前窗口。
>   新增运行与终端控制映射（如 `<leader>rp`、`<leader>rk`、终端/普通模式 `<C-c>` 中断）。

### 运行代码（`<leader>r`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>rp` | 运行当前 Python 文件（`python %`） |
| `<leader>rc` | 运行当前 CMake 脚本（`cmake -P %`） |
| `<leader>ru` | 运行 Cargo 项目（`cargo run`） |
| `<leader>rg` | 运行当前 Go 文件（`go run %`） |
| `<leader>rk` | 停止当前 ToggleTerm 运行任务（停止所有终端 job） |

### 终端（`<leader>t`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>tt` | 打开水平终端 |
| `<leader>tf` | 打开浮动终端 |
| `<leader>tv` | 打开垂直终端 |
| `终端模式 <Esc><Esc>` | 终端切回普通模式 |
| `终端模式 <C-c>` | 中断当前终端任务（发送 Ctrl+C） |
| `普通模式 <C-c>` | 在终端 buffer 中中断当前终端任务 |

### LSP（`<leader>l`）

| 快捷键 | 说明 |
| --- | --- |
| `gd` | 跳转定义（Telescope） |
| `gr` | 查找引用（Telescope） |
| `gi` | 查找实现（Telescope） |
| `<leader>la` | LSP 代码动作 |
| `<leader>lr` | LSP 重命名 |
| `<leader>ld` | 查看当前诊断 |
| `<leader>lf` | 格式化当前文件 |
| `<leader>li` | `:checkhealth vim.lsp`（当前环境 LSP 客户端与配置；Neovim 0.11+ 下 `:LspInfo` 可能未注册） |
| `<leader>ls` | LSP Symbols（当前文件符号） |
| `<leader>lS` | LSP Workspace Symbols（工作区符号） |

### 搜索（Telescope 快捷入口）

| 快捷键 | 说明 |
| --- | --- |
| `;f` | 查找文件（含隐藏文件） |
| `;r` | 全文搜索（含隐藏文件） |
| `;;` | 恢复上次 Telescope |
| `;e` | 诊断列表 |
| `;t` | 帮助标签 |
| `;s` | Treesitter 符号 |
| `\\` | Buffer 列表 |

### Hop 跳转（`<leader><leader>` / `<leader>h`）

> 两套按键功能一一对应：`<leader><leader>*` 为主前缀，`<leader>h*` 为单手别名。
>
> 说明：`hop.nvim` 在此配置里是**按键触发懒加载**的，首次使用 Hop 相关按键时会加载一次插件（之后常驻）。

| 主快捷键 | 别名 | 说明 |
| --- | --- | --- |
| `<leader><leader>w` | `<leader>hw` | 跳到下一个词首 |
| `<leader><leader>e` | `<leader>he` | 跳到下一个词尾 |
| `<leader><leader>b` | `<leader>hb` | 跳到上一个词首 |
| `<leader><leader>v` | `<leader>hv` | 跳到上一个词尾 |
| `<leader><leader>l` | `<leader>hl` | 跳到下一个 camelCase 词 |
| `<leader><leader>h` | `<leader>hh` | 跳到上一个 camelCase 词 |
| `<leader><leader>f` | `<leader>hf` | 当前行单字符跳转 |
| `<leader><leader>a` | `<leader>ha` | 任意位置跳转 |
| `<leader><leader>j` | `<leader>hj` | 跳到下方行 |
| `<leader><leader>k` | `<leader>hk` | 跳到上方行 |

### 文件与搜索补充

| 快捷键 | 说明 |
| --- | --- |
| `<leader>fn` | 文件树定位当前文件 |
| `<leader>ff` | 查找文件（Telescope） |
| `<leader>fr` | 最近文件（Telescope） |
| `<leader>fw` | 全文搜索（Telescope） |
| `<leader>fW` | 搜索当前单词（Telescope） |
| `<leader>fk` | 模糊搜索全部快捷键映射（`:Telescope keymaps`） |
| `sf` | 打开当前文件目录的文件浏览器 |

### 窗口与编辑

| 快捷键 | 说明 |
| --- | --- |
| `<C-s>` | 保存文件（Normal / Insert / Visual / Select） |
| `<C-a>` | 全选（Normal / Insert / Visual） |
| `ss` | 水平分屏 |
| `sv` | 垂直分屏 |
| `sh` | 切到左侧窗口 |
| `sj` | 切到下方窗口 |
| `sk` | 切到上方窗口 |
| `sl` | 切到右侧窗口 |

### Bufferline 标签管理

| 快捷键 | 说明 |
| --- | --- |
| `<leader>bb` | Telescope 缓冲列表（MRU、忽略当前 buffer，对应原 `<leader>fb`） |
| `<leader>bB` | Telescope 缓冲列表（全部，对应原 `<leader>fB`） |
| `<leader>bS` | Snacks：选择草稿缓冲（原 `<leader>S`） |
| `<leader>b.` | Snacks：切换草稿缓冲（原 `<leader>.`） |
| `]b` | 下一个标签 |
| `[b` | 上一个标签 |
| `<leader>bp` | 选择标签 |
| `<leader>bd` | 关闭当前标签 |
| `<leader>bo` | 关闭其他标签 |
| `<b` | 标签左移 |
| `>b` | 标签右移 |
| `<leader>bh` | 标签左移 |
| `<leader>bl` | 标签右移 |

### Git 与路径复制

| 快捷键 | 说明 |
| --- | --- |
| `<leader>gg` | 打开 LazyGit |
| `<leader>gl` | 查看当前行 Git 信息（完整） |
| `<leader>gB` | 切换行内 blame |
| `<leader>cp` | 复制当前文件完整路径 |
| `<leader>cP` | 复制当前文件相对路径 |

### Diffview（`lua/plugins/tools/git.lua`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>gD` | 打开 Git Diff 视图 |
| `<leader>gC` | 关闭 Diff 视图 |
| `<leader>gF` | 当前文件的提交历史 |
| `<leader>gH` | 仓库提交历史 |

### AI — Codex（`lua/plugins/ai/codex.lua`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>ai` | 开关 Codex 面板（Normal / 终端模式） |
| `<C-q>` | Codex 浮窗内退出（插件内映射） |

### AI — Claude Code（`lua/plugins/ai/claudecode.lua`）

使用 [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim)：与官方 Claude Code 扩展相同的 WebSocket MCP 协议，终端由 `snacks.nvim` 提供（默认**大浮窗**）。

**前置条件**

- 已安装 [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)，且终端能执行 `claude`。
- 首次使用在 Neovim 中执行 `:Lazy sync` 拉取插件。

若使用 `claude migrate-installer` 将 CLI 装到本地目录，请在 `claudecode.lua` 的 `opts` 里设置 `terminal_cmd`（示例见该文件内注释）。

| 快捷键 | 说明 |
| --- | --- |
| `<leader>ac` | 开关 Claude Code 终端 |
| `<leader>af` | 聚焦 / 智能切换 Claude 终端 |
| `<leader>ar` | `claude --resume` |
| `<leader>aC` | `claude --continue` |
| `<leader>am` | 选择模型并打开终端 |
| `<leader>ab` | 将当前文件加入上下文 |
| `<leader>as` | Visual：发送选区；在文件树 buffer 中：将文件加入上下文 |
| `<leader>aa` / `<leader>ad` | 接受 / 拒绝 Claude 提出的 diff |
| 浮窗内终端模式 | `<C-\><C-n>`：先退出终端插入模式并隐藏浮窗（见 `snacks_win_opts.keys`） |

### 专注与撤销历史（`lua/plugins/tools/productivity.lua`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>mz` | Zen Mode 专注编辑 |
| `<leader>mu` | Undotree 撤销树开关 |

### 编辑增强（`lua/plugins/tools/coding.lua`）

| 快捷键 | 说明 |
| --- | --- |
| `<leader>cj` | TreeSJ：按语法拆分/合并语句 |
| `<leader>sr` | GrugFar：工程内搜索替换 |
| `]T` / `[T` | 下一个 / 上一个 TODO 类注释 |
| `<leader>st` | Telescope 搜索 TODO / FIXME 等 |

`mini.surround` 使用默认键位，可在 Neovim 内查看 `:h mini.surround`。

### Neovide 专用（`lua/config/keymaps.lua`）

仅在 [Neovide](https://neovide.dev/) 下生效；终端版 Neovim 无下列映射。

| 快捷键 | 说明 |
| --- | --- |
| `<C-=>` / `<C-->` | 界面缩放放大 / 缩小（Normal / Insert） |
| `<C-0>` | 重置缩放 |
| `<leader>un` | 切换性能档位（需存在 `_G.neovide_cycle_profile`） |

光标动效（粒子、`guicursor`、浮动窗阴影等）在 `lua/config/options.lua` 的 `vim.g.neovide` 段配置，思路参考 [fanlusky/FanyLazyvim](https://github.com/fanlusky/FanyLazyvim)（如 `pixiedust` 粒子、`guicursor` 无闪烁）。

### 其他

| 快捷键 | 说明 |
| --- | --- |
| `<leader>y` | 打开 Lazy 面板 |
| `<leader>ub` | 切换光标颜色（雷姆蓝 / 拉姆粉） |

### Markdown 增强

前置条件（避免 `<leader>mP` 无响应）：
- 已安装 `node` / `npm`
- 首次使用前先在 Neovim 执行：`:Lazy build markdown-preview.nvim`

| 快捷键 | 说明 |
| --- | --- |
| `<leader>mp` | Markdown 预览开关 |
| `<leader>mP` | Markdown 开始预览 |
| `<leader>mr` | render-markdown 渲染开关（编辑区） |
| `<leader>mR` | render-markdown 侧边预览 |
| `<leader>ms` | Markdown 停止预览 |

当前 `.md` / `.markdown` 文件（`markdown` filetype）还启用了以下本地增强：
- 自动换行（`wrap` + `linebreak`）
- 拼写检查（`spell`）
- 语法隐藏渲染（`conceallevel=2`，`concealcursor=nc`）
- `render-markdown` 使用 `preset=lazy`，并开启 LSP 补全支持（checkbox / callout）
- `render-markdown` 开启 `anti_conceal`（光标上下各 1 行，编辑时更清晰）
- `markdown-preview` 开启组合预览窗口复用与相对滚动同步

## 12. 性能与懒加载说明（卡顿排查）

如果你体感“从 `<leader>e`（Snacks Explorer）里第一次打开文件会卡一下，后续变流畅”，通常是**第一次打开某类文件时**触发了 LSP/Treesitter/渲染类插件的初始化，这是正常现象。

本配置已做过几项“降低首开阻塞”的处理：
- `hop.nvim`：按键触发懒加载
- `mason.nvim`：`VeryLazy`/命令触发懒加载，避免后台安装影响首开
- `nvim-highlight-colors`：仅在前端相关文件类型加载
- 已禁用 `netrw*`（使用 Snacks Explorer 作为文件管理器）
- LSP `codelens` 默认关闭（减少 BufEnter 阶段同步刷新）

需要进一步定位时，可在 `:Lazy` 面板按 `P` 查看 Profile（或使用 `:Lazy profile`）。
