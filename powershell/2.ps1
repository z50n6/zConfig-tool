#Requires -Version 7.0

Set-StrictMode -Version Latest

# ==========================
# PowerShell 7.6 高颜值开发版 Profile
# 适配：Terminal-Icons / posh-git / PSReadLine / PSFzf / zoxide / Neovim / oh-my-posh(amro)
# 文件：D:\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# 目标：稳定、好看、好用，且每一段都便于后续维护
# ==========================

# ---------- 1. 基础编码与默认行为 ----------
# 统一终端输入/输出为 UTF-8，避免中文乱码和特殊字符显示异常。
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# 让 PowerShell 使用宿主终端的渲染能力输出颜色。
$PSStyle.OutputRendering = 'Host'

# 更简洁的报错显示方式，减少大段堆栈噪音。
$ErrorView = 'ConciseView'

# 提高命令历史上限，方便长期检索。
$MaximumHistoryCount = 20000

# 默认编辑器优先使用 nvim，没有时退回到 notepad。
$env:EDITOR = if (Get-Command nvim -ErrorAction SilentlyContinue) { 'nvim' } else { 'notepad' }
$env:VISUAL = $env:EDITOR

# ---------- 2. 环境探测函数 ----------
# 判断当前是否是可交互终端。很多增强功能只应在交互场景启用。
function Test-InteractiveHost {
    try {
        if (-not [Environment]::UserInteractive) { return $false }
        if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) { return $false }
        if ($null -eq $Host.UI -or $null -eq $Host.UI.RawUI) { return $false }
        return $true
    } catch {
        return $false
    }
}

# 判断终端是否支持 VT（虚拟终端）渲染。
# PSReadLine 预测、彩色提示等能力依赖这个特性。
function Test-VTSupport {
    try {
        if (-not (Test-InteractiveHost)) { return $false }
        return ($Host.UI.SupportsVirtualTerminal -eq $true)
    } catch {
        return $false
    }
}

# 安全导入模块：模块存在才加载，避免启动时报错。
function Import-ModuleSafely {
    param([Parameter(Mandatory)][string]$Name)
    if (Get-Module -ListAvailable -Name $Name) {
        Import-Module $Name -ErrorAction SilentlyContinue | Out-Null
        return $true
    }
    return $false
}

# 统一保存环境探测结果，后面各模块直接复用。
$script:IsInteractive = Test-InteractiveHost
$script:HasVT = Test-VTSupport
$script:ThemePath = if ($env:POSH_THEMES_PATH) { Join-Path $env:POSH_THEMES_PATH 'amro.omp.json' } else { $null }
$script:OhMyPoshLoaded = $false

# ---------- 3. 常用模块加载 ----------
# 图标增强、Git 状态、命令行编辑、FZF 模糊搜索。
Import-ModuleSafely Terminal-Icons | Out-Null
Import-ModuleSafely posh-git       | Out-Null
Import-ModuleSafely PSReadLine     | Out-Null
Import-ModuleSafely PSFzf          | Out-Null

# 目录跳转优先使用 zoxide；如果没装 zoxide，再退回 PowerShell 的 z 模块。
$script:HasZoxide = [bool](Get-Command zoxide -ErrorAction SilentlyContinue)
if (-not $script:HasZoxide) {
    Import-ModuleSafely z | Out-Null
}

# ---------- 4. oh-my-posh 主题加载（固定 amro） ----------
# 只在交互终端中加载 amro 主题。成功后由 oh-my-posh 接管 prompt 外观。
if ($script:IsInteractive -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    if ($script:ThemePath -and (Test-Path -LiteralPath $script:ThemePath)) {
        try {
            oh-my-posh init pwsh --config $script:ThemePath | Invoke-Expression
            $script:OhMyPoshLoaded = $true
        } catch {
            Write-Warning "oh-my-posh 初始化失败，已回退为普通提示符：$script:ThemePath"
        }
    } else {
        Write-Warning '未找到 amro.omp.json，已使用普通提示符。'
    }
}

# ---------- 5. PSReadLine：输入体验与高颜值配色 ----------
# 这里只负责命令行编辑体验、补全、预测和配色。
# 说明：你输入的 ls / git / nvim 等命令颜色，就是在这里配置的。
if ($script:IsInteractive -and (Get-Module PSReadLine)) {
    # 使用 Windows 风格快捷键编辑体验。
    Set-PSReadLineOption -EditMode Windows

    # 关闭提示音，避免误触时刺耳。
    Set-PSReadLineOption -BellStyle None

    # 历史记录自动去重，并提高保存数量。
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -MaximumHistoryCount 20000

    # 显示参数提示；续行时使用两个空格，更整洁。
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineOption -ContinuationPrompt '  '

    # 如果终端支持 VT，则开启历史预测和高颜值配色。
    if ($script:HasVT) {
        try {
            # 开启历史预测，并使用行内预测样式，避免 ListView 占满屏幕。
            Set-PSReadLineOption -PredictionSource History
            Set-PSReadLineOption -PredictionViewStyle InlineView

            # amro 适配配色：命令蓝、参数绿、提示灰，整体更协调。
            Set-PSReadLineOption -Colors @{
                Command                = '#61AFEF'  # 命令：如 ls / git / nvim
                Parameter              = '#98C379'  # 参数：如 -la / --help
                Operator               = '#56B6C2'  # 操作符：如 | > >>
                Variable               = '#E5C07B'  # 变量：如 $PROFILE
                String                 = '#C678DD'  # 字符串
                Number                 = '#D19A66'  # 数字
                Type                   = '#56B6C2'  # 类型名称
                Comment                = '#7F848E'  # 注释
                Keyword                = '#E06C75'  # 关键字
                Error                  = '#FF6B6B'  # 错误高亮
                Selection              = '#FFFFFF'  # 选中文本
                InlinePrediction       = '#6B7280'  # 行内预测提示
                ListPrediction         = '#ABB2BF'  # 列表预测（保留兜底）
                ListPredictionSelected = '#FFFFFF'  # 列表选中项
            }
        } catch {
            # 某些特殊宿主环境不支持预测渲染，失败时静默跳过。
        }
    }

    # 历史检索：输入前缀后按上下箭头只匹配相关历史命令。
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Tab 使用菜单补全；Ctrl+f / Ctrl+r 交给 FZF。
    Set-PSReadLineKeyHandler -Key Tab        -Function MenuComplete
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
    Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+u' -Function BackwardDeleteInput
    Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
    Set-PSReadLineKeyHandler -Chord 'Ctrl+a' -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Chord 'Ctrl+e' -Function EndOfLine
    Set-PSReadLineKeyHandler -Chord 'Alt+b'  -Function BackwardWord
    Set-PSReadLineKeyHandler -Chord 'Alt+f'  -Function ForwardWord
}

# ---------- 6. PSFzf：模糊搜索增强 ----------
# Ctrl+f 搜索文件，Ctrl+r 模糊搜索历史命令。
if ($script:IsInteractive -and (Get-Module PSFzf)) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

    # 设置 fzf 的窗口高度、边框、指针和提示文案。
    $env:FZF_DEFAULT_OPTS = '--height=10 --layout=reverse --border=none --margin=0,1 --padding=0 --info=inline-right --prompt="❯ " --pointer="❯" --marker="" --separator=" " --scrollbar="" --color=fg:#c0caf5,bg:-1,hl:#7aa2f7,fg+:#e5e9f0,bg+:-1,hl+:#89ddff,info:#7f849c,prompt:#7aa2f7,pointer:#f7768e,marker:#98c379,spinner:#e0af68,header:#7dcfff,query:#c0caf5'
}

# ---------- 7. zoxide：目录智能跳转 ----------
# 有 zoxide 时自动初始化，可直接用 z 进行模糊跳目录。
if ($script:IsInteractive -and $script:HasZoxide) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ---------- 8. posh-git：Git 状态增强 ----------
# 主要提供 Git 自动补全、分支/状态信息等能力。
if (Get-Module posh-git) {
    $GitPromptSettings.EnableFileStatus = $true
    $GitPromptSettings.EnableStashStatus = $true
    $GitPromptSettings.EnablePromptStatus = $true
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
}

# ---------- 9. 回退提示符 ----------
# 正常情况下由 oh-my-posh 的 amro 主题接管 prompt。
# 只有 oh-my-posh 没有成功加载时，才使用这里的简洁回退提示符。
if (-not $script:OhMyPoshLoaded) {
    function global:prompt {
        $exitCode = if ($null -ne $global:LASTEXITCODE) { $global:LASTEXITCODE } else { 0 }
        $ok = $exitCode -eq 0
        $status = if ($ok) { 'OK' } else { "ERR:$exitCode" }
        $time = Get-Date -Format 'HH:mm:ss'
        $path = $executionContext.SessionState.Path.CurrentLocation

        if ($script:HasVT) {
            $statusColor = if ($ok) { $PSStyle.Foreground.BrightGreen } else { $PSStyle.Foreground.BrightRed }
            $timeColor   = $PSStyle.Foreground.BrightBlack
            $pathColor   = $PSStyle.Foreground.BrightBlue
            $reset       = $PSStyle.Reset
            Write-Host "`n$statusColor$status$reset $timeColor$time$reset $pathColor$path$reset" -NoNewline
        } else {
            Write-Host "`n[$status] $time $path" -NoNewline
        }

        if (Get-Command Write-GitStatus -ErrorAction SilentlyContinue) {
            Write-GitStatus
        } else {
            Write-Host ''
        }

        return ' > '
    }
}

# ---------- 10. 常用别名 ----------
# 保持 Linux 风格使用习惯，并把 vim 指向 nvim。
Set-Alias ll Get-ChildItem
Set-Alias la Get-ChildItem
Set-Alias grep Select-String
Set-Alias which Get-Command
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
}

# ---------- 11. 常用函数 ----------
# 目录浏览和快速跳转。
function l  { Get-ChildItem }
function ls { Get-ChildItem }
function lf { Get-ChildItem -Force }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# 创建目录并立即进入。
function mkcd {
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    $null = New-Item -ItemType Directory -Path $Path -Force
    Set-Location -LiteralPath $Path
}

# Linux 风格 touch：存在就更新时间，不存在就创建文件。
function touch {
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    if (Test-Path -LiteralPath $Path) {
        (Get-Item -LiteralPath $Path).LastWriteTime = Get-Date
    } else {
        $null = New-Item -ItemType File -Path $Path -Force
    }
}

# 打开并编辑当前 Profile。
function edit-profile {
    & $env:EDITOR $PROFILE.CurrentUserCurrentHost
}

# 重新加载当前 Profile，修改后立即生效。
function reload-profile {
    . $PROFILE.CurrentUserCurrentHost
}

# 查看某个命令实际落到哪个路径上。
function whichp {
    param([Parameter(Mandatory, Position = 0)][string]$Command)
    (Get-Command -Name $Command -ErrorAction SilentlyContinue).Path
}

# 输出当前开发环境摘要，方便排查版本和主题状态。
function devinfo {
    [pscustomobject]@{
        PowerShell     = $PSVersionTable.PSVersion.ToString()
        Editor         = $env:EDITOR
        Theme          = $script:ThemePath
        OhMyPoshLoaded = $script:OhMyPoshLoaded
        Git            = (git --version 2>$null)
        Node           = (node -v 2>$null)
        Python         = (python --version 2>$null)
        Dotnet         = (dotnet --version 2>$null)
        Go             = (go version 2>$null)
        Rust           = (rustc --version 2>$null)
    }
}

# ---------- 12. Git 快捷命令 ----------
# 常用 Git 操作做短命令封装，提升输入效率。
function gs   { git status @args }
function ga   { git add @args }
function gaa  { git add . }
function gc   { git commit @args }
function gcm  { git commit -m $args }
function gca  { git commit --amend @args }
function gp   { git push @args }
function gpl  { git pull @args }
function gl   { git log --oneline --graph --decorate -20 }
function gd   { git diff @args }
function gds  { git diff --staged @args }
function gco  { git checkout @args }
function gcb  { git checkout -b @args }
function gsw  { git switch @args }
function gb   { git branch @args }

# ---------- 13. 代理管理 ----------
# 一键开关本地代理，适合日常开发和工具链使用。
$global:DEFAULT_PROXY = 'http://127.0.0.1:7890'

function proxy {
    [CmdletBinding()]
    param([string]$ProxyAddress = $global:DEFAULT_PROXY)

    $env:http_proxy  = $ProxyAddress
    $env:https_proxy = $ProxyAddress
    $env:all_proxy   = $ProxyAddress
    [System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebProxy]::new($ProxyAddress)
    Write-Host "🌐 代理已启用：$ProxyAddress" -ForegroundColor Green
}

function unproxy {
    $env:http_proxy  = $null
    $env:https_proxy = $null
    $env:all_proxy   = $null
    [System.Net.WebRequest]::DefaultWebProxy = $null
    Write-Host '🚫 代理已关闭' -ForegroundColor Yellow
}

function check-proxy {
    Write-Host '🔍 当前代理配置' -ForegroundColor Cyan
    Write-Host "🌐 HTTP  : $($env:http_proxy  ?? '未设置')" -ForegroundColor DarkCyan
    Write-Host "🔒 HTTPS : $($env:https_proxy ?? '未设置')" -ForegroundColor DarkCyan
    Write-Host "🧭 ALL   : $($env:all_proxy   ?? '未设置')" -ForegroundColor DarkCyan
}


# ---------- 14. Windows 常用目录跳转 ----------
# 针对你的常用工作目录提供快速跳转函数，仅在 Windows 下启用。
if ($IsWindows) {
    function cdNotion  {
        if (Test-Path 'E:/知识库/The-Road-to-Safety-main/') { Set-Location 'E:/知识库/The-Road-to-Safety-main/' } else { Write-Warning '路径不存在：E:/知识库/The-Road-to-Safety-main/' }
    }

    function cdTools   {
        if (Test-Path 'E:/SafeTools/Penetration') { Set-Location 'E:/SafeTools/Penetration' } else { Write-Warning '路径不存在：E:/SafeTools/Penetration' }
    }

    function cdPython  {
        if (Test-Path 'D:/SoftWare/Python/pyenv/pyenv-win/versions') { Set-Location 'D:/SoftWare/Python/pyenv/pyenv-win/versions' } else { Write-Warning '路径不存在：D:/SoftWare/Python/pyenv/pyenv-win/versions' }
    }

    function cdXray    {
        if (Test-Path 'E:/SafeTools/Penetration/Vulnerability_Scanning/xray/') { Set-Location 'E:/SafeTools/Penetration/Vulnerability_Scanning/xray/' } else { Write-Warning '路径不存在：E:/SafeTools/Penetration/Vulnerability_Scanning/xray/' }
    }

    function cdSslscan {
        if (Test-Path 'E:/SafeTools/Penetration/Information_Collection/others/sslscan-2.2.0/') { Set-Location 'E:/SafeTools/Penetration/Information_Collection/others/sslscan-2.2.0/' } else { Write-Warning '路径不存在：E:/SafeTools/Penetration/Information_Collection/others/sslscan-2.2.0/' }
    }
}
# ---------- 15. 启动提示 ----------
# 启动时显示当前 PowerShell 版本、已加载模块和主题路径，便于确认环境是否正常。
if ($script:IsInteractive) {
    $mods = @('Terminal-Icons', 'posh-git', 'PSReadLine', 'PSFzf') | Where-Object { Get-Module $_ }
    Write-Host "PowerShell $($PSVersionTable.PSVersion) 已就绪 | 模块：$($mods -join ', ')" -ForegroundColor DarkGray
    if ($script:ThemePath) {
        Write-Host "当前主题：$script:ThemePath" -ForegroundColor DarkGray
    }
}






