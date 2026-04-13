# PowerShell Profile 说明

这是一份面向 **Windows + PowerShell 7** 的个人开发型 Profile，目标不是“炫”，而是：

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

说明：

- `oh-my-posh` 配置**没有删除**
- 当前只是默认使用 `starship`
- 已禁用自定义启动横幅
- 已禁用自定义回退 prompt，避免和第三方主题重复

#### 当前默认

如果没有显式设置环境变量：

```powershell
starship
```

#### 临时切换

只影响当前会话：

```powershell
use-starship
use-ohmyposh
```

#### 持久切换

影响后续新开的终端：

```powershell
set-default-starship
set-default-ohmyposh
clear-default-prompt-theme
```

---

### 1.3 命令不存在时的安装建议

输入不存在的命令时，Profile 会尝试给出安装建议。

来源包括：

- `winget`
- `scoop`
- `choco`
- `npm`

并且当前已经做了优化：

- 优先高置信匹配
- 不再因为弱关联 tag 乱推荐无关工具
- 支持显示相近本地命令
- 已修复与管道命令的冲突问题

例如：

```powershell
yazi
```

可能会得到：

```powershell
可尝试的安装命令（按当前环境自动探测）：
  winget install --id sxyazi.yazi -e
  scoop install yazi
  npm i -g yazi
```

---

### 1.4 PSReadLine

当前配置使用了 **简洁优雅风格** 的 `PSReadLine` 设置：

- 行内历史预测
- 菜单补全
- 历史去重
- Windows 风格编辑模式
- 低饱和、低噪音语法高亮

常用快捷键：

- `Tab`：菜单补全
- `Ctrl+r`：模糊搜索历史（通过 `PSFzf`）
- `Ctrl+f`：模糊搜索文件（通过 `PSFzf`）
- `Up / Down`：按当前前缀搜索历史
- `Ctrl+w`：删除前一个单词
- `Ctrl+u`：删除当前整段输入
- `Ctrl+a` / `Ctrl+e`：行首 / 行尾

---

### 1.5 fzf / PSFzf

当前 `fzf` 样式已经改成**简洁耐看**风格：

- 低饱和配色
- 轻边框
- 减少夸张符号
- 更适合长期使用

默认快捷键：

- `Ctrl+f`：文件搜索
- `Ctrl+r`：历史搜索

---

### 1.6 zoxide 智能跳转

装了 `zoxide` 后，可直接使用：

```powershell
z xxx
```

按访问频率和历史习惯跳目录。

---

### 1.7 eza 目录浏览增强

当前目录浏览命令基于 `eza` 做了增强；如果没装 `eza`，会自动回退到 PowerShell 原生命令。

常用命令：

- `l`：简洁列表
- `ls`：简洁列表
- `ll`：长列表 + 表头 + Git 状态
- `la`：显示隐藏文件
- `lf`：隐藏文件 + 长列表 + Git 状态
- `lt`：树状显示（默认 2 层），自动忽略常见噪音目录
- `ld`：只显示目录
- `lx`：按修改时间倒序

---

### 1.8 Git 快捷命令

内置以下常用 Git 快捷命令：

- `gs` → `git status`
- `ga` → `git add`
- `gaa` → `git add .`
- `gc` → `git commit`
- `gcm` → `git commit -m`
- `gca` → `git commit --amend`
- `gp` → `git push`
- `gpl` → `git pull`
- `gl` → `git log --oneline --graph --decorate -20`
- `gd` → `git diff`
- `gds` → `git diff --staged`
- `gco` → `git checkout`
- `gcb` → `git checkout -b`
- `gsw` → `git switch`
- `gb` → `git branch`

---

### 1.9 常用工具函数

- `mkcd <目录>`：创建目录并进入
- `touch <文件>`：Linux 风格 touch
- `edit-profile`：编辑当前 Profile
- `reload-profile`：重新加载当前 Profile（带成功/失败提示）
- `whichp <命令>`：查看命令实际路径
- `devinfo`：查看当前环境摘要

---

### 1.10 代理函数

- `proxy`：启用代理
- `unproxy`：关闭代理
- `check-proxy`：查看当前代理配置

默认代理地址：

```powershell
http://127.0.0.1:7890
```

---

### 1.11 个人路径跳转

当前配置中包含以下个人路径函数：

- `cdNotion`
- `cdTools`
- `cdPython`
- `cdXray`
- `cdSslscan`

这些是**强绑定个人环境**的路径。  
如果迁移到别的机器，需要改或删。

---

## 2. 需要安装哪些东西

下面按“必需 / 推荐 / 可选”分类。

### 2.1 必需

#### PowerShell 7+

配置顶部包含：

```powershell
#Requires -Version 7.0
```

因此必须使用 PowerShell 7 或更高版本。

检查：

```powershell
$PSVersionTable.PSVersion
```

---

### 2.2 推荐安装

#### starship

当前默认主题系统。

```powershell
winget install Starship.Starship -e
```

或：

```powershell
scoop install starship
```

#### oh-my-posh

不是当前默认，但配置中保留了切换能力。

```powershell
winget install JanDeDobbeleer.OhMyPosh -e
```

或：

```powershell
scoop install oh-my-posh
```

#### eza

用于增强版 `ls / ll / lt / ld / lx`

```powershell
winget install --id eza-community.eza -e
```

或：

```powershell
scoop install eza
```

#### git

用于：

- Git 快捷命令
- `posh-git`
- `eza --git`

```powershell
winget install Git.Git -e
```

#### fzf

用于 `PSFzf`。

```powershell
winget install junegunn.fzf -e
```

或：

```powershell
scoop install fzf
```

#### zoxide

```powershell
winget install ajeetdsouza.zoxide -e
```

或：

```powershell
scoop install zoxide
```

#### Neovim（推荐）

```powershell
winget install Neovim.Neovim -e
```

或：

```powershell
scoop install neovim
```

---

### 2.3 PowerShell 模块

建议安装：

- `Terminal-Icons`
- `posh-git`
- `PSReadLine`
- `PSFzf`

安装方式：

```powershell
Install-Module Terminal-Icons -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force
Install-Module PSFzf -Scope CurrentUser -Force
```

---

### 2.4 可选安装

这些会影响“命令不存在时的安装建议”能力：

- `winget`
- `scoop`
- `choco`
- `npm`

不装也能用，只是安装建议来源会变少。

---

## 3. 如何部署这份配置

先查看当前用户 Profile 路径：

```powershell
$PROFILE.CurrentUserCurrentHost
```

复制配置：

```powershell
Copy-Item `
  'E:\知识库\zConfig-tool\powershell\Microsoft.PowerShell_profile.ps1' `
  $PROFILE.CurrentUserCurrentHost `
  -Force
```

重新加载：

```powershell
. $PROFILE.CurrentUserCurrentHost
```

---

## 4. 使用前必须检查的硬编码项

### 4.1 oh-my-posh 主题路径

当前配置中仍保留：

```powershell
D:\Documents\PowerShell\themes\amro-custom.omp.json
```

如果以后切到 `oh-my-posh`，这个路径必须存在，否则会回退。

### 4.2 个人目录函数

以下函数依赖你的本地路径：

- `cdNotion`
- `cdTools`
- `cdPython`
- `cdXray`
- `cdSslscan`

### 4.3 代理地址

默认：

```powershell
http://127.0.0.1:7890
```

---

## 5. 快速自检

加载配置后，建议测试：

```powershell
devinfo
ls
ll
lt
gs
proxy
unproxy
reload-profile
```

以及：

```powershell
use-starship
use-ohmyposh
set-default-starship
set-default-ohmyposh
clear-default-prompt-theme
```

---

## 6. 常见问题

### Q1：为什么 `oh-my-posh` 没生效？

因为当前默认主题是：

```powershell
starship
```

需要手动切换：

```powershell
use-ohmyposh
```

或：

```powershell
set-default-ohmyposh
```

### Q2：为什么没有自定义启动提示了？

因为当前已经禁用：

- 自定义启动横幅
- 自定义回退 prompt

目的是减少和 `starship / oh-my-posh` 的冲突与重复。

### Q3：为什么有时命令不存在提示不给安装命令？

因为当前逻辑已经改成了**高置信匹配优先**。  
弱匹配、tag 关联、明显无关的包不会乱推荐。

---

## 7. 文件说明

- 配置文件：`E:\知识库\zConfig-tool\powershell\Microsoft.PowerShell_profile.ps1`
- 使用说明：`E:\知识库\zConfig-tool\powershell\README.md`
- 安装指南：`E:\知识库\zConfig-tool\powershell\INSTALL.md`
