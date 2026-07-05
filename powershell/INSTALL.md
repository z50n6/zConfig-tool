# PowerShell 配置安装指南

这份文档只关注一件事：**如何在一台新 Windows 机器上快速安装并跑通这套 PowerShell 配置。**

---

## 1. 最终效果

安装完成后，你将获得：

- PowerShell 7 开发环境
- `starship` 默认提示符（可切 `oh-my-posh`）
- `eza` 增强版目录命令（ls / ll / la / lt）
- `PSReadLine` 简洁风格高亮与历史预测
- `fzf` 模糊搜索文件和历史（原生调用，无需 PSFzf 模块）
- `zoxide` 智能跳目录
- Git 快捷命令
- 代理一键开关

---

## 2. 安装顺序

1. PowerShell 7
2. Git
3. Windows Terminal
4. Nerd Font
5. starship
6. oh-my-posh（可选）
7. eza
8. fzf
9. zoxide
10. Neovim
11. PowerShell 模块
12. 复制配置文件
13. 检查硬编码路径
14. 测试

---

## 3. 基础软件

### 3.1 PowerShell 7

```powershell
winget install Microsoft.PowerShell -e
```

验证：`pwsh -c '$PSVersionTable.PSVersion'`（要求 7.0+）

### 3.2 Git

```powershell
winget install Git.Git -e
```

### 3.3 Windows Terminal

```powershell
winget install Microsoft.WindowsTerminal -e
```

### 3.4 Nerd Font

推荐安装 Nerd Font（否则 starship / oh-my-posh / eza 图标显示异常）：

- CaskaydiaCove Nerd Font
- MesloLGS NF
- JetBrainsMono Nerd Font

---

## 4. 主题与工具

### 4.1 starship（当前默认）

```powershell
winget install Starship.Starship -e
```

### 4.2 oh-my-posh（保留备用）

```powershell
winget install JanDeDobbeleer.OhMyPosh -e
```

### 4.3 eza

```powershell
winget install eza-community.eza -e
```

### 4.4 fzf

```powershell
winget install junegunn.fzf -e
```

> 仅需 fzf.exe，**不需要安装 PSFzf 模块**。Profile 通过 PSReadLine KeyHandler 直接调用 fzf。

### 4.5 zoxide

```powershell
winget install ajeetdsouza.zoxide -e
```

### 4.6 Neovim（推荐）

```powershell
winget install Neovim.Neovim -e
```

---

## 5. PowerShell 模块

```powershell
Install-Module Terminal-Icons -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force
```

验证：

```powershell
Get-Module -ListAvailable Terminal-Icons, posh-git, PSReadLine
```

---

## 6. 复制配置文件

```powershell
Copy-Item 'E:\知识库\zConfig-tool\powershell\Microsoft.PowerShell_profile.ps1' $PROFILE.CurrentUserCurrentHost -Force
```

如目录不存在：

```powershell
New-Item -ItemType Directory -Force (Split-Path $PROFILE.CurrentUserCurrentHost)
```

---

## 7. 迁移前必须检查

### 7.1 oh-my-posh 主题路径

当前自动从 scoop 目录动态查找 `amro.omp.json`（无需手动改版本号）。如果使用自定义主题目录，设置环境变量：

```powershell
[Environment]::SetEnvironmentVariable('POSH_THEMES_PATH', 'D:\your\themes', 'User')
```

### 7.2 个人目录跳转

以下函数是个人环境路径，迁移到新机器时通常需要修改或删除：

- `cdNotion`
- `cdTools`
- `cdPython`
- `cdXray`
- `cdSslscan`

### 7.3 代理地址

默认 `http://127.0.0.1:7890`，如端口不同请修改 `$global:DEFAULT_PROXY`。

---

## 8. 重新加载

```powershell
. $PROFILE.CurrentUserCurrentHost
```

或重开终端。

---

## 9. 安装后测试

```powershell
devinfo
ls
ll
la
lt
gs
proxy
unproxy
reload-profile
```

测试主题切换：

```powershell
Switch-PromptTheme starship       # 临时切到 starship
Switch-PromptTheme oh-my-posh     # 临时切到 oh-my-posh
Switch-PromptTheme oh-my-posh -Persist   # 永久设为 oh-my-posh
```

---

## 10. 一条龙安装参考

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
```

然后安装 PowerShell 模块：

```powershell
Install-Module Terminal-Icons -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force
```

---

## 11. 常见问题

### Q1：为什么默认不是 oh-my-posh？

默认是 `starship`。切回 oh-my-posh：

```powershell
Switch-PromptTheme oh-my-posh -Persist
```

### Q2：为什么 Ctrl+f / Ctrl+r 不工作？

需要安装 fzf.exe（`winget install junegunn.fzf -e`）。Profile 不再依赖 PSFzf 模块，直接调用 fzf.exe。

### Q3：为什么没有命令不存在的安装建议了？

该功能已移除（精简 ~300 行），启动速度更快，打错命令时不再触发包管理器搜索。
