# PowerShell 配置安装指南

适用目录：

- `E:\知识库\zConfig-tool\powershell`

相关文件：

- 配置文件：`Microsoft.PowerShell_profile.ps1`
- 使用说明：`README.md`

这份文档只关注一件事：**如何在一台新 Windows 机器上快速安装并跑通这套 PowerShell 配置。**

---

## 1. 最终效果

安装完成后，你将获得：

- PowerShell 7 开发环境
- `starship` 默认提示符
- 可切回 `oh-my-posh`
- `eza` 增强版目录命令
- `PSReadLine` 简洁风格高亮与历史预测
- `PSFzf + fzf` 模糊搜索
- `zoxide` 智能跳目录
- Git 快捷命令
- 命令不存在时的安装建议

---

## 2. 推荐安装顺序

建议按以下顺序安装：

1. PowerShell 7
2. Git
3. Windows Terminal
4. Nerd Font
5. starship
6. oh-my-posh（可选但推荐）
7. eza
8. fzf
9. zoxide
10. Neovim
11. PowerShell 模块
12. 复制配置文件
13. 修改硬编码路径
14. 测试并切换提示符

---

## 3. 基础软件安装

### 3.1 PowerShell 7

```powershell
winget install Microsoft.PowerShell -e
```

验证：

```powershell
pwsh
$PSVersionTable.PSVersion
```

要求：

- `7.0+`

---

### 3.2 Git

```powershell
winget install Git.Git -e
```

验证：

```powershell
git --version
```

---

### 3.3 Windows Terminal

```powershell
winget install Microsoft.WindowsTerminal -e
```

---

### 3.4 Nerd Font

推荐安装 Nerd Font，否则：

- `starship` 图标
- `oh-my-posh` 图标
- `eza` 图标

可能显示不正常。

推荐字体：

- CaskaydiaCove Nerd Font
- MesloLGS NF
- JetBrainsMono Nerd Font

安装后请在 Windows Terminal 中切换到对应字体。

---

## 4. 主题与工具安装

### 4.1 starship（当前默认）

```powershell
winget install Starship.Starship -e
```

或：

```powershell
scoop install starship
```

验证：

```powershell
starship --version
```

---

### 4.2 oh-my-posh（保留备用）

```powershell
winget install JanDeDobbeleer.OhMyPosh -e
```

或：

```powershell
scoop install oh-my-posh
```

验证：

```powershell
oh-my-posh version
```

---

### 4.3 eza

```powershell
winget install --id eza-community.eza -e
```

或：

```powershell
scoop install eza
```

验证：

```powershell
eza --version
```

---

### 4.4 fzf

```powershell
winget install junegunn.fzf -e
```

或：

```powershell
scoop install fzf
```

验证：

```powershell
fzf --version
```

---

### 4.5 zoxide

```powershell
winget install ajeetdsouza.zoxide -e
```

或：

```powershell
scoop install zoxide
```

验证：

```powershell
zoxide --version
```

---

### 4.6 Neovim（推荐）

```powershell
winget install Neovim.Neovim -e
```

或：

```powershell
scoop install neovim
```

验证：

```powershell
nvim --version
```

---

## 5. PowerShell 模块安装

在 `pwsh` 中执行：

```powershell
Install-Module Terminal-Icons -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force
Install-Module PSFzf -Scope CurrentUser -Force
```

验证：

```powershell
Get-Module -ListAvailable Terminal-Icons, posh-git, PSReadLine, PSFzf
```

---

## 6. 用于安装建议的可选来源

如果你希望“命令不存在时自动给安装建议”，推荐尽量具备这些来源：

- `winget`
- `scoop`
- `choco`
- `npm`

### scoop

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

验证：

```powershell
scoop --version
```

### Node.js / npm

```powershell
winget install OpenJS.NodeJS.LTS -e
```

验证：

```powershell
node -v
npm -v
```

---

## 7. 复制配置文件

查看当前 Profile 路径：

```powershell
$PROFILE.CurrentUserCurrentHost
```

如目录不存在，先创建：

```powershell
New-Item -ItemType Directory -Force (Split-Path $PROFILE.CurrentUserCurrentHost)
```

复制配置：

```powershell
Copy-Item `
  'E:\知识库\zConfig-tool\powershell\Microsoft.PowerShell_profile.ps1' `
  $PROFILE.CurrentUserCurrentHost `
  -Force
```

---

## 8. 迁移前必须检查的硬编码路径

### 8.1 oh-my-posh 主题路径

当前配置内保留：

```powershell
D:\Documents\PowerShell\themes\amro-custom.omp.json
```

如果以后要切到 `oh-my-posh`，这个路径必须正确。

### 8.2 自定义目录跳转路径

以下函数是个人环境路径：

- `cdNotion`
- `cdTools`
- `cdPython`
- `cdXray`
- `cdSslscan`

迁移到新机器时通常都要改。

### 8.3 代理地址

当前默认：

```powershell
http://127.0.0.1:7890
```

如端口不同，请修改：

```powershell
$global:DEFAULT_PROXY
```

---

## 9. 重新加载配置

```powershell
. $PROFILE.CurrentUserCurrentHost
```

或者直接重开终端。

---

## 10. 安装完成后的测试

建议依次执行：

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

测试主题切换：

```powershell
use-starship
use-ohmyposh
set-default-starship
set-default-ohmyposh
clear-default-prompt-theme
```

测试安装建议：

```powershell
yazi
```

---

## 11. 常见问题

### 11.1 为什么默认不是 oh-my-posh？

因为当前配置默认主题已经调整为：

```powershell
starship
```

如需切回：

```powershell
use-ohmyposh
```

或：

```powershell
set-default-ohmyposh
```

### 11.2 为什么没有自定义横幅？

因为当前已禁用：

- 启动横幅
- 自定义回退 prompt

这样可以减少和 `starship / oh-my-posh` 的冲突。

### 11.3 为什么有些命令不存在时不给安装建议？

因为现在采用的是**高置信匹配优先**策略。  
弱匹配不会乱推荐，避免出现：

- `fasd -> zoxide`

这种明显不靠谱的建议。

### 11.4 为什么 `fzf` 和 `PSReadLine` 没有很花哨？

因为当前配置已经刻意调成：

- 简洁
- 低饱和
- 长时间使用不累眼

不是“炫技型”风格。

---

## 12. 一条龙安装参考

```powershell
winget install Microsoft.PowerShell -e
winget install Git.Git -e
winget install Microsoft.WindowsTerminal -e
winget install Starship.Starship -e
winget install JanDeDobbeleer.OhMyPosh -e
winget install eza-community.eza -e
winget install junegunn.fzf -e
winget install ajeetdsouza.zoxide -e
winget install Neovim.Neovim -e
winget install OpenJS.NodeJS.LTS -e
```

然后安装 PowerShell 模块：

```powershell
Install-Module Terminal-Icons -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force
Install-Module PSFzf -Scope CurrentUser -Force
```

