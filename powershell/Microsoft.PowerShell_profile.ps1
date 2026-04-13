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

# ---------- 2.1 命令不存在时给出安装建议 ----------
# 类似 Linux 的 command-not-found：在报错后补充 winget / scoop / choco / npm 安装提示。
$script:CommandNotFoundHintCache = @{}

function Get-CommandNotFoundInstallHints {
    param([Parameter(Mandatory)][string]$CommandName)

    if ($script:CommandNotFoundHintCache.ContainsKey($CommandName)) {
        return $script:CommandNotFoundHintCache[$CommandName]
    }

    $hints = [System.Collections.Generic.List[string]]::new()

    function Add-Hint {
        param([string]$Value)
        if ($Value -and -not $hints.Contains($Value)) {
            $hints.Add($Value) | Out-Null
        }
    }

    function Get-SearchCandidates {
        param([string]$Name)

        $list = [System.Collections.Generic.List[string]]::new()
        $commonPrefixes = @('get', 'set', 'new', 'remove', 'install', 'start', 'stop', 'open')

        function Add-Candidate {
            param([string]$Value)
            if (-not [string]::IsNullOrWhiteSpace($Value) -and -not $list.Contains($Value)) {
                $list.Add($Value) | Out-Null
            }
        }

        Add-Candidate $Name

        $base = [IO.Path]::GetFileNameWithoutExtension($Name)
        Add-Candidate $base
        $parts = $base -split '[-_\.]'

        if ($parts.Count -ge 2) {
            if ($parts[-1].Length -ge 3) { Add-Candidate ($parts[-1]) }
            Add-Candidate (($parts[1..($parts.Count - 1)] -join '-'))
        }

        foreach ($prefix in $commonPrefixes) {
            if ($base -match "^$prefix[-_](.+)$") {
                Add-Candidate $matches[1]
            }
        }

        foreach ($part in $parts) {
            if ($part.Length -ge 3 -and $part -notin $commonPrefixes) {
                Add-Candidate $part
            }
        }

        return @($list)
    }

    function Get-FirstDataLine {
        param([string[]]$Lines)

        $seenDivider = $false
        foreach ($line in $Lines) {
            if (-not $line) { continue }
            $plain = ([regex]::Replace($line, "`e\[[\d;]*m", '')).Trim()
            if (-not $plain) { continue }

            if ($plain -match '^(Name|名称)\s{2,}' -or $plain -match '^----') {
                $seenDivider = $true
                continue
            }

            if ($plain -match '^(Results from|The following source|Found|No package found|没有找到)') { continue }
            if ($plain -match '^(WARN|WARNING)\s') { continue }
            if ($plain -match '^[\\/\-\|\s]+$') { continue }
            if ($plain -match '^\d+%$') { continue }
            if ($plain -match 'KB / ' -or $plain -match 'MB / ') { continue }

            if ($seenDivider) { return $plain }
        }

        return $null
    }

    function Normalize-MatchText {
        param([string]$Value)
        if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
        return (($Value.ToLowerInvariant() -replace '\.(exe|cmd|bat|ps1)$', '') -replace '[^a-z0-9]+', '')
    }

    function Test-HighConfidencePackageMatch {
        param(
            [string]$Candidate,
            [string]$PackageName,
            [string]$PackageId
        )

        $candidateNorm = Normalize-MatchText $Candidate
        $nameNorm = Normalize-MatchText $PackageName
        $idNorm = Normalize-MatchText $PackageId
        $idLeafNorm = Normalize-MatchText (($PackageId -split '\.')[-1])

        if (-not $candidateNorm) { return $false }

        return (
            $nameNorm -eq $candidateNorm -or
            $idNorm -eq $candidateNorm -or
            $idLeafNorm -eq $candidateNorm -or
            $nameNorm.StartsWith($candidateNorm) -or
            $idLeafNorm.StartsWith($candidateNorm)
        )
    }

    $candidates = Get-SearchCandidates $CommandName

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        foreach ($candidate in $candidates) {
            try {
                $line = Get-FirstDataLine @(winget search --source winget --disable-interactivity --accept-source-agreements $candidate 2>$null)
                $id = $null
                $name = $null
                if ($line) {
                    $parts = @($line -split '\s+' | Where-Object { $_ })
                    $name = if ($parts.Count -ge 1) { $parts[0].Trim() } else { $null }
                    $id = if ($parts.Count -ge 2) { $parts[1].Trim() } else { $null }
                    if (-not $id -and $line -match '^(.+?)\s{2,}([^\s]+)\s{2,}(.+)$') {
                        $name = $matches[1].Trim()
                        $id = $matches[2].Trim()
                    }
                }
                if ($id -and (Test-HighConfidencePackageMatch -Candidate $candidate -PackageName $name -PackageId $id)) {
                    Add-Hint "winget install --id $id -e"
                    break
                }
            } catch {}
        }
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        foreach ($candidate in $candidates) {
            try {
                $searchResult = @(& scoop search $candidate 2>$null 3>$null 4>$null 5>$null 6>$null)
                $pkg = $null
                if ($searchResult.Count -gt 0) {
                    if ($searchResult[0] -is [psobject] -and $searchResult[0].PSObject.Properties['Name']) {
                        $pkg = [string]$searchResult[0].Name
                    } else {
                        $line = Get-FirstDataLine $searchResult
                        if ($line -and $line -match '^([^\s]+)\s{2,}') {
                            $pkg = $matches[1].Trim()
                        }
                    }
                }
                if ($pkg -and (Test-HighConfidencePackageMatch -Candidate $candidate -PackageName $pkg -PackageId $pkg)) {
                    Add-Hint "scoop install $pkg"
                    break
                }
            } catch {}
        }
    }

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        foreach ($candidate in $candidates) {
            try {
                $line = @(& choco search $candidate --limit-output 2>$null 3>$null 4>$null 5>$null 6>$null | Select-Object -First 1)
                if ($line -and $line[0] -match '^([^|]+)\|') {
                    $pkg = $matches[1].Trim()
                    if (Test-HighConfidencePackageMatch -Candidate $candidate -PackageName $pkg -PackageId $pkg) {
                        Add-Hint "choco install $pkg -y"
                        break
                    }
                }
            } catch {}
        }
    }

    if (Get-Command npm -ErrorAction SilentlyContinue) {
        foreach ($candidate in $candidates) {
            try {
                $pkg = npm view $candidate name --silent 2>$null
                if ($LASTEXITCODE -eq 0 -and $pkg) {
                    Add-Hint "npm i -g $($pkg.Trim())"
                    break
                }
            } catch {}
        }
    }

    $nearby = @(Get-Command "*$CommandName*" -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Name -Unique |
        Select-Object -First 5)

    $result = [pscustomobject]@{
        Hints  = @($hints)
        Nearby = @($nearby)
    }

    $script:CommandNotFoundHintCache[$CommandName] = $result
    return $result
}

function Show-CommandNotFoundGuidance {
    param([Parameter(Mandatory)][string]$CommandName)

    $displayName = $CommandName
    if ($displayName -match '^(get|set|new|remove|install|start|stop|open)-(.+)$') {
        $displayName = $matches[2]
    }

    $message = "$displayName : The term '$displayName' is not recognized as a name of a cmdlet, function, script file, or executable program."
    Write-Host $message -ForegroundColor Red
    Write-Host "Check the spelling of the name, or if a path was included, verify that the path is correct and try again." -ForegroundColor Red

    $info = Get-CommandNotFoundInstallHints -CommandName $displayName

    if ($info.Nearby.Count -gt 0) {
        Write-Host ''
        Write-Host '相近的本地命令：' -ForegroundColor Yellow
        foreach ($item in $info.Nearby) {
            Write-Host "  - $item" -ForegroundColor DarkYellow
        }
    }

    if ($info.Hints.Count -gt 0) {
        Write-Host ''
        Write-Host '可尝试的安装命令（按当前环境自动探测）：' -ForegroundColor Cyan
        foreach ($hint in $info.Hints) {
            Write-Host "  $hint" -ForegroundColor DarkCyan
        }
    } else {
        Write-Host ''
        Write-Host '未找到直接安装提示，可手动搜索：' -ForegroundColor DarkGray
        if (Get-Command winget -ErrorAction SilentlyContinue) { Write-Host "  winget search $displayName" -ForegroundColor DarkGray }
        if (Get-Command scoop  -ErrorAction SilentlyContinue) { Write-Host "  scoop search $displayName"  -ForegroundColor DarkGray }
        if (Get-Command choco  -ErrorAction SilentlyContinue) { Write-Host "  choco search $displayName"  -ForegroundColor DarkGray }
        if (Get-Command npm    -ErrorAction SilentlyContinue) { Write-Host "  npm search $displayName"    -ForegroundColor DarkGray }
    }
}

# 统一保存环境探测结果，后面各模块直接复用。
$script:IsInteractive = Test-InteractiveHost
$script:HasVT = Test-VTSupport

# 原始主题路径配置（已停用，保留便于回滚）
# $script:ThemePath = if ($env:POSH_THEMES_PATH) { Join-Path $env:POSH_THEMES_PATH 'amro.omp.json' } else { $null }
$script:ThemePath = 'D:\Documents\PowerShell\themes\amro-custom.omp.json'
$script:OhMyPoshLoaded = $false
$script:PromptTheme = if ($env:USE_PROMPT_THEME) { $env:USE_PROMPT_THEME.ToLowerInvariant() } else { 'starship' }

if ($script:IsInteractive) {
    switch ($script:PromptTheme) {
        'oh-my-posh' {
            if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
                if ($script:ThemePath -and (Test-Path -LiteralPath $script:ThemePath)) {
                    try {
                        oh-my-posh init pwsh --config $script:ThemePath | Invoke-Expression
                        $script:OhMyPoshLoaded = $true
                    } catch {
                        Write-Warning "oh-my-posh 初始化失败，已回退为默认提示符：$script:ThemePath"
                    }
                } else {
                    Write-Warning '未找到 oh-my-posh 主题文件，已回退为默认提示符。'
                }
            }
        }
        'starship' {
            if (Get-Command starship -ErrorAction SilentlyContinue) {
                (& starship init powershell) | Invoke-Expression
            }
        }
        default {
            if (Get-Command starship -ErrorAction SilentlyContinue) {
                (& starship init powershell) | Invoke-Expression
            }
        }
    }
}
if ($script:IsInteractive) {
    $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
        param($CommandName, $EventArgs)

        $missingName = $CommandName
        $EventArgs.StopSearch = $true
        $EventArgs.CommandScriptBlock = {
            param(
                [Parameter(ValueFromPipeline = $true)]
                $InputObject,

                [Parameter(ValueFromRemainingArguments = $true)]
                $RemainingArgs
            )

            begin {}
            process {}
            end {
            Show-CommandNotFoundGuidance -CommandName $missingName
            }
        }.GetNewClosure()
    }
}

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

# ---------- 4. 提示主题加载 ----------
# 通过 $env:USE_PROMPT_THEME 切换：
#   starship   -> 使用 starship（默认）
#   oh-my-posh -> 使用 oh-my-posh

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

    # 如果终端支持 VT，则开启历史预测和简洁配色。
    if ($script:HasVT) {
        try {
            # 开启历史预测，并使用行内预测样式，尽量减少视觉干扰。
            Set-PSReadLineOption -PredictionSource History
            Set-PSReadLineOption -PredictionViewStyle InlineView
            Set-PSReadLineOption -Colors @{
                Command                = '#7aa2f7'  # 命令：克制的蓝色
                Parameter              = '#9ece6a'  # 参数：柔和绿色
                Operator               = '#89ddff'  # 操作符：偏冷浅蓝
                Variable               = '#e0af68'  # 变量：低饱和金色
                String                 = '#c0caf5'  # 字符串：浅灰蓝
                Number                 = '#d19a66'  # 数字：柔和橙色
                Type                   = '#73daca'  # 类型：青绿色
                Comment                = '#6b7280'  # 注释：中性灰
                Keyword                = '#bb9af7'  # 关键字：低饱和紫色
                Error                  = '#f7768e'  # 错误：柔和红色
                Selection              = '#1f2335'  # 选中背景：深色块
                InlinePrediction       = '#6b7280'  # 行内预测：低存在感灰色
                ListPrediction         = '#9aa5ce'
                ListPredictionSelected = '#c0caf5'
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

    # 更简洁的 fzf 样式：轻边框、低饱和配色、减少装饰符号。
    $env:FZF_DEFAULT_OPTS = '--height=40% --layout=reverse --border=rounded --margin=0,1 --padding=0 --info=inline-right --prompt="› " --pointer="›" --marker="•" --separator=" " --scrollbar="│" --color=fg:#c0caf5,bg:-1,hl:#7aa2f7,fg+:#e5e9f0,bg+:#24283b,hl+:#7aa2f7,info:#6b7280,prompt:#9aa5ce,pointer:#9aa5ce,marker:#9ece6a,spinner:#9aa5ce,header:#6b7280,query:#c0caf5,border:#414868'
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
# 已禁用自定义 prompt，交给 starship 或宿主默认提示符处理。

# ---------- 10. 常用别名 ----------
# 保持 Linux 风格使用习惯，并把 vim 指向 nvim。
Set-Alias grep Select-String
Set-Alias which Get-Command
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
}

# ---------- 11. 常用函数 ----------
# 目录浏览和快速跳转。
# 优先用 eza：图标、Git 状态、目录优先、统一时间格式；没有 eza 时回退到 Get-ChildItem。
$script:HasEza = [bool](Get-Command eza -ErrorAction SilentlyContinue)
$script:EzaTimeStyle = '+%Y-%m-%d %H:%M:%S %a'
$script:EzaBaseArgs = @(
    '--icons=auto',
    '--group-directories-first',
    ('--time-style={0}' -f $script:EzaTimeStyle)
)
$script:EzaLongArgs = @(
    '-l',
    '-h',
    '--header',
    '--smart-group'
)
$script:EzaTreeIgnore = '.git|node_modules|dist|build|target|__pycache__|.venv|venv'

function Invoke-PrettyList {
    param(
        [string[]]$ExtraArgs = @(),
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$PathArgs
    )

    if ($script:HasEza) {
        $allArgs = @($script:EzaBaseArgs + $ExtraArgs + $PathArgs)
        & eza @allArgs
    } else {
        Get-ChildItem @PathArgs
    }
}

function l {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    Invoke-PrettyList @Args
}

function ls {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    Invoke-PrettyList @Args
}

function ll {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    $extra = @($script:EzaLongArgs)
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $extra += '--git'
    }
    Invoke-PrettyList -ExtraArgs $extra @Args
}

function la {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    $extra = @('-a')
    Invoke-PrettyList -ExtraArgs $extra @Args
}

function lf {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    if ($script:HasEza) {
        $extra = @('-a') + $script:EzaLongArgs
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $extra += '--git'
        }
        Invoke-PrettyList -ExtraArgs $extra @Args
    } else {
        Get-ChildItem -Force @Args
    }
}

function lt {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    if ($script:HasEza) {
        $extra = @('--tree', '--level=2', '-a', '--git-ignore', '-I', $script:EzaTreeIgnore)
        Invoke-PrettyList -ExtraArgs $extra @Args
    } else {
        Get-ChildItem -Force @Args
    }
}

function ld {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    if ($script:HasEza) {
        Invoke-PrettyList -ExtraArgs @('-D') @Args
    } else {
        Get-ChildItem -Directory @Args
    }
}

function lx {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
    if ($script:HasEza) {
        Invoke-PrettyList -ExtraArgs (@($script:EzaLongArgs) + @('--sort=modified', '-r')) @Args
    } else {
        Get-ChildItem @Args | Sort-Object LastWriteTime -Descending
    }
}

if (Test-Path Alias:ls) {
    Remove-Item Alias:ls -Force
}

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
    try {
        . $PROFILE.CurrentUserCurrentHost
        Write-Host "✅ Profile 已重新加载：$($PROFILE.CurrentUserCurrentHost)" -ForegroundColor Green
    } catch {
        Write-Error "Profile 重新加载失败：$($_.Exception.Message)"
    }
}

function use-starship {
    $env:USE_PROMPT_THEME = 'starship'
    . $PROFILE.CurrentUserCurrentHost
}

function use-ohmyposh {
    $env:USE_PROMPT_THEME = 'oh-my-posh'
    . $PROFILE.CurrentUserCurrentHost
}

function set-default-starship {
    [Environment]::SetEnvironmentVariable('USE_PROMPT_THEME', 'starship', 'User')
    $env:USE_PROMPT_THEME = 'starship'
    . $PROFILE.CurrentUserCurrentHost
}

function set-default-ohmyposh {
    [Environment]::SetEnvironmentVariable('USE_PROMPT_THEME', 'oh-my-posh', 'User')
    $env:USE_PROMPT_THEME = 'oh-my-posh'
    . $PROFILE.CurrentUserCurrentHost
}

function clear-default-prompt-theme {
    [Environment]::SetEnvironmentVariable('USE_PROMPT_THEME', $null, 'User')
    Remove-Item Env:USE_PROMPT_THEME -ErrorAction SilentlyContinue
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
        PromptTheme    = $script:PromptTheme
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
# 已禁用启动横幅，避免与 starship 或终端自身输出重复。







