# PowerShell Profile 说明

这是一份面向 **Windows + PowerShell 7** 的个人开发型 Profile，目标不是"炫"，而是：

- 简洁
- 顺手
- 稳定
- 便于迁移和维护

---

## 1. 当前配置的核心特性

### 1.1 终端基础行为

- 强制 UTF-8 输入输出
- 使用较简洁的 PowerShell 错误视图
- 历史记录上限提升到 `20000`
- 默认编辑器优先 `nvim`，不存在时回退 `notepad`

---

### 1.2 提示符系统

当前配置支持两套提示符：

- `starship`（默认）
- `oh-my-posh`（保留，可随时切回）

oh-my-posh 主题路径会**自动动态查找** scoop 安装目录中最新版本的 `amro.omp.json`，不再硬编码版本号。

#### 切换提示符

使用统一的 `Switch-PromptTheme` 函数：

```powershell
# 临时切换（仅当前会话）
Switch-PromptTheme starship
Switch-PromptTheme oh-my-posh

# 永久切换（写入用户环境变量）
Switch-PromptTheme oh-my-posh -Persist
Switch-PromptTheme starship -Persist
```

---

### 1.3 PSReadLine

使用了**简洁优雅风格**的 `PSReadLine` 设置：

- 行内历史预测
- 菜单补全
- 历史去重
- Windows 风格编辑模式
- 低饱和、低噪音语法高亮

常用快捷键：

- `Tab`：菜单补全
- `Ctrl+f`：模糊搜索文件/目录（fzf）
- `Ctrl+r`：模糊搜索命令历史（fzf）
- `Up / Down`：按当前前缀搜索历史
- `Ctrl+w`：删除前一个单词
- `Ctrl+u`：删除当前整段输入
- `Ctrl+a` / `Ctrl+e`：行首 / 行尾

---

### 1.4 FZF 模糊搜索

**直接调用 fzf.exe，不需要 PSFzf 模块**。fzf 安装即可用：

```powershell
winget install junegunn.fzf -e
# 或
scoop install fzf
```

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+f` | 搜索文件/目录（自动优先用 fd 加速） |
| `Ctrl+r` | 模糊搜索持久化命令历史 |

FZF 样式已调成简洁耐看风格：低饱和配色、轻边框、适合长期使用。

---

### 1.5 zoxide 智能跳转

装了 `zoxide` 后，可直接使用 `z xxx` 按访问频率和历史习惯跳目录。

---

### 1.6 eza 目录浏览增强

基于 `eza` 增强目录浏览；没装 `eza` 时自动回退到 PowerShell 原生命令。

| 命令 | 功能 |
|------|------|
| `ls` | 简洁列表（带图标、目录优先） |
| `ll` | 长列表 + 表头 + Git 状态 |
| `la` | 含隐藏文件 |
| `lt` | 树状显示（2层），自动忽略 .git/node_modules 等 |

---

### 1.7 Git 快捷命令

| 命令 | 等价 |
|------|------|
| `gs` | `git status` |
| `ga` / `gaa` | `git add` / `git add .` |
| `gc` / `gcm` / `gca` | `git commit` / `-m` / `--amend` |
| `gp` / `gpl` | `git push` / `git pull` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `gd` / `gds` | `git diff` / `git diff --staged` |
| `gco` / `gcb` | `git checkout` / `git checkout -b` |
| `gsw` / `gb` | `git switch` / `git branch` |

---

### 1.8 常用工具函数

- `mkcd <目录>`：创建目录并进入
- `touch <文件>`：Linux 风格 touch
- `edit-profile`：编辑当前 Profile
- `reload-profile`：重新加载当前 Profile
- `whichp <命令>`：查看命令实际路径
- `devinfo`：查看当前环境摘要

---

### 1.9 代理函数

- `proxy`：启用代理（默认 `http://127.0.0.1:7890`）
- `unproxy`：关闭代理
- `check-proxy`：查看当前代理配置

---

### 1.10 个人路径跳转

- `cdNotion` / `cdTools` / `cdPython` / `cdXray` / `cdSslscan`

这些是**强绑定个人环境**的路径，迁移时需要修改或删除。

---

## 2. 需要安装哪些东西

### 2.1 必需

- PowerShell 7+（`#Requires -Version 7.0`）

### 2.2 推荐安装

```powershell
winget install Starship.Starship -e
winget install JanDeDobbeleer.OhMyPosh -e
winget install eza-community.eza -e
winget install Git.Git -e
winget install junegunn.fzf -e
winget install ajeetdsouza.zoxide -e
winget install Neovim.Neovim -e
```

### 2.3 PowerShell 模块

```powershell
Install-Module Terminal-Icons -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force
```

> **不再需要 PSFzf 模块**。FZF 功能通过 fzf.exe + PSReadLine KeyHandler 原生实现。

---

## 3. 如何部署

```powershell
Copy-Item 'E:\知识库\zConfig-tool\powershell\Microsoft.PowerShell_profile.ps1' $PROFILE.CurrentUserCurrentHost -Force
. $PROFILE.CurrentUserCurrentHost
```

---

## 4. 迁移前必须检查

### 4.1 oh-my-posh 主题路径

当前自动从 scoop 目录查找 `amro.omp.json`。如果使用自定义主题，设置环境变量：

```powershell
$env:POSH_THEMES_PATH = "D:\your\theme\dir"
```

### 4.2 个人目录函数

`cdNotion` / `cdTools` / `cdPython` / `cdXray` / `cdSslscan` 依赖本地路径，迁移时需修改。

### 4.3 代理地址

默认 `http://127.0.0.1:7890`，不同端口请修改 `$global:DEFAULT_PROXY`。

---

## 5. 快速自检

```powershell
devinfo
ls
ll
la
lt
gs
Switch-PromptTheme starship
Switch-PromptTheme oh-my-posh
proxy
unproxy
reload-profile
```

---

## 6. 与旧版的主要变化

| 旧版 | 新版 |
|------|------|
| PSFzf 模块依赖 | fzf.exe 原生调用 |
| `use-starship` / `use-ohmyposh` 等 6 个函数 | `Switch-PromptTheme [-Persist]` 一个函数 |
| CommandNotFound 安装建议（~300行） | 已删除（启动更快） |
| `l` / `lf` / `ld` / `lx` 等 8 个 ls 变体 | 精简为 `ls` / `ll` / `la` / `lt` 4 个 |
| oh-my-posh 主题路径硬编码版本号 | 自动动态查找最新版本 |

---

## 7. 文件说明

- 配置文件：`Microsoft.PowerShell_profile.ps1`
- 使用说明：`README.md`（本文档）
- 安装指南：`INSTALL.md`
