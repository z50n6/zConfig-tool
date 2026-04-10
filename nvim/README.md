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
:Mason
:TSUpdate
:checkhealth
```

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

## 10. 自定义快捷键速查

> 以下为当前配置中常用的**自定义**映射，定义位置主要在 `lua/config/keymaps.lua` 和 `lua/plugins/tools/editor.lua`。
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
| `<leader>li` | 打开 `:LspInfo` |

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
