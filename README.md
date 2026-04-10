## zConfig-tool

一套以 **Windows** 为主的个人配置集合：`PowerShell` / `Starship` / `NuShell` / `Neovim(LazyVim)` / `Yazi` / `Hexo`，以及 Windows Terminal 右键菜单注册表脚本等。

### 你会得到什么

- **可直接落地的配置文件**：按目录划分，复制到对应系统路径即可生效
- **Neovim（LazyVim）增强**：包含 LSP/格式化/搜索/终端/Git/AI（Codex、Claude Code）等分域配置与键位速查
- **NuShell 完整体验**：主题、代理、别名 + `nushell/script/*` 的一系列自定义补全
- **Yazi**：启用隐藏文件、Catppuccin 主题、较完整的键位映射

### 仓库结构

```text
.
├─ README.md
├─ add-wt-right-click.reg         # Windows Terminal 右键菜单（目录背景）
├─ imgs/                          # README 截图
├─ powershell/                    # PowerShell profile 与脚本
│  └─ Microsoft.PowerShell_profile.ps1
├─ starship/                      # Starship 配置
│  └─ starship.toml
├─ nushell/                       # NuShell 主配置 + 补全脚本集合
│  ├─ config.nu
│  ├─ env.nu
│  └─ script/
├─ nvim/                          # Neovim(LazyVim) 配置
│  ├─ init.lua
│  └─ lua/...
├─ yazi/                          # Yazi 配置（含 catppuccin flavors）
│  ├─ yazi.toml
│  ├─ keymap.toml
│  ├─ theme.toml
│  └─ flavors/
└─ hexo/                          # Hexo blog 配置（anzhiyu 主题）
   ├─ _config.yml
   └─ _config.anzhiyu.yml
```

### 快速开始（Windows）

> 下面用的是“复制覆盖”的方式；如果你希望一处修改、处处生效，建议用符号链接（见“同步与更新”）。

#### 0) 基础依赖（建议用 Scoop）

至少建议准备：

- **终端**：Windows Terminal / PowerShell 7（`pwsh`）
- **字体**：任意 Nerd Font（确保图标显示正常）
- **工具**：`git`、`ripgrep (rg)`、`fd`
- **可选**：`zoxide`（目录跳转）、`fastfetch`（系统信息）

#### 1) PowerShell（profile）

- **源文件**：`powershell/Microsoft.PowerShell_profile.ps1`
- **目标位置（常见）**：`$PROFILE` 指向的路径（PowerShell 中运行 `$PROFILE` 查看）

你这份 profile 里包含：

- UTF-8 输入输出
- `Terminal-Icons`、`posh-git`、`PSFzf`、`PSReadLine` 配置
- `proxy / unproxy / check-proxy` 三个函数（默认 `http://127.0.0.1:7890`）
- `zoxide init powershell`

安装模块示例：

```powershell
Set-ExecutionPolicy RemoteSigned
Install-Module -Name Terminal-Icons -Repository PSGallery
Install-Module -Name posh-git -Scope CurrentUser
Install-Module -Name PSReadLine -Force
Install-Module -Name PSFzf
```

#### 2) Starship

- **源文件**：`starship/starship.toml`
- **目标位置**：`%USERPROFILE%\.config\starship.toml`（即 `~/.config/starship.toml`）

NuShell 侧初始化（本仓库 `nushell/config.nu` 已写入）：

```powershell
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
```

#### 3) NuShell

- **源文件**：`nushell/config.nu`、`nushell/env.nu`
- **目标位置（Windows）**：通常在 `~\AppData\Roaming\nushell\`
  - 在 NuShell 中运行：`$nu.config-path` / `$nu.env-path` 可确认

这份 `config.nu` 的关键点：

- 启动 Starship：`use ~/.cache/starship/init.nu`
- 主题配色（`$dark_theme` / `$light_theme`）与 `$env.config` 大量默认项
- 代理函数：`proxy set / proxy unset / proxy check`（注意端口是 `7897`，与 PowerShell 默认不一样）
- 一系列别名（`vim`、`l`、`ll` 等）
- **引入补全脚本**：`source ~/AppData/Roaming/nushell/script/.../*-completions.nu`

##### 自定义补全（nushell/script）

`nushell/script/` 下是按命令分目录的补全模块（如 `docker/`、`ssh/`、`git/`、`scoop/`、`winget/` 等）。

- 总览说明见：`nushell/script/README.md`
- 例如 ssh 补全会解析 `~/.ssh/config`（详见 `nushell/script/ssh/README.md`）

#### 4) Neovim（LazyVim + Neovide 可选）

- **目录**：`nvim/`
- **目标位置（Windows）**：`%LOCALAPPDATA%\nvim`（示例：`C:\Users\用户名\AppData\Local\nvim`）

特点（按仓库实际配置）：

- 插件按职责拆分：`lua/plugins/{core,ui,tools,lang,ai}`
- Windows 下 Treesitter 编译器优先级：`clang > zig > gcc`
- 输入法自动切英文（依赖 `im-select.exe`）：`lua/plugins/tools/ime.lua`
- AI：
  - Codex：`lua/plugins/ai/codex.lua`
  - Claude Code：`lua/plugins/ai/claudecode.lua`（依赖系统能执行 `claude`）

更完整的安装、依赖与键位速查：`nvim/README.md`  
插件索引：`nvim/lua/plugins/README.md`

#### 5) Yazi

- **目录**：`yazi/`
- **目标位置（Windows）**：通常为 `~\AppData\Roaming\yazi\config\`（也可能是 `~\.config\yazi\`，按你的安装方式为准）

这份配置包含：

- `yazi.toml`：显示隐藏文件、排序、预览与 opener 规则等
- `theme.toml`：`catppuccin-mocha` / `catppuccin-latte`
- `keymap.toml`：较完整的默认键位映射（含 `zoxide`/`fzf` 插件入口）
- `package.toml`：声明 catppuccin flavors 依赖

#### 6) Windows Terminal 右键菜单

- 文件：`add-wt-right-click.reg`
- 作用：在**目录背景**右键添加 “Open with Terminal”

注意：该 `.reg` 内写死了 `wt.exe` 路径与图标路径（需按你本机实际路径修改后再导入）。

### Hexo（博客配置）

`hexo/_config.yml` 与 `hexo/_config.anzhiyu.yml` 是博客配置示例（主题 `anzhiyu`、菜单、展示与功能开关等）。  
它更偏“站点私有配置”，通常不建议直接照搬到别人的站点，仅作为你自己的可复用模板。

### 同步与更新

- **复制覆盖**：简单粗暴，适合首次快速落地
- **符号链接（推荐）**：把系统配置目录指向本仓库文件，更新时只需要 `git pull`

Windows 下常用的链接方式（管理员或开发者模式视系统而定）：

- PowerShell：`New-Item -ItemType SymbolicLink ...`
- CMD：`mklink` / `mklink /D`

### 常见问题（FAQ）

- **NuShell 与 PowerShell 代理端口不一致**：PowerShell 默认 `7890`，NuShell 配置里是 `7897`，按你实际代理软件端口统一即可。
- **Neovim Treesitter 编译失败**：优先确保 `clang` 可用（或按 `nvim/README.md` 的 Scoop 依赖安装），再在 Neovim 里执行 `:TSUpdate`、` :checkhealth nvim-treesitter`。
- **终端图标乱码**：确认终端与编辑器都在用 Nerd Font。

