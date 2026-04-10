
# 添加如下内容：
clear
# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
# 引入starship
#Invoke-Expression (&starship init powershell)


Import-Module Terminal-Icons
Import-Module posh-git


# 引入oh-my-posh
#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\amro.omp.json" | Invoke-Expression
# Oh My Posh 主题加载（增加容错）
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $themePath = "$env:POSH_THEMES_PATH\amro.omp.json"
    if (Test-Path $themePath) {
        oh-my-posh init pwsh --config $themePath | Invoke-Expression
    } else {
        Write-Warning "Oh My Posh 主题文件不存在，已跳过加载"
    }
} else {
    Write-Warning "oh-my-posh 命令未找到，已跳过加载"
}

# PSReadLine
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView  # 使用下拉列表视图 (F2可切换)

# Fzf
# install :Install-Module -Name PSFzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# # Env
# $env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"



# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}


# Alias
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias vim nvim
#Set-Alias nvim neovide

#代理
# function proxy {
#     $env:http_proxy = "http://127.0.0.1:7890"
#     $env:https_proxy = "http://127.0.0.1:7890"
#     [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy("http://127.0.0.1:7890")
#     Write-Host "Proxy enabled: http://127.0.0.1:7890" -ForegroundColor Green
# }
#
# function unproxy {
#     $env:http_proxy = $null
#     $env:https_proxy = $null
#     [System.Net.WebRequest]::DefaultWebProxy = $null
#     Write-Host "Proxy disabled" -ForegroundColor Yellow
# }
#
# function check-proxy {
#     if ($env:http_proxy -or $env:https_proxy) {
#         Write-Host "Current proxy settings:" -ForegroundColor Cyan
#         Write-Host "HTTP Proxy: $env:http_proxy"
#         Write-Host "HTTPS Proxy: $env:https_proxy"
#     } else {
#         Write-Host "No proxy is currently set." -ForegroundColor Cyan
#     }
# }
#
$global:DEFAULT_PROXY = "http://127.0.0.1:7890"

function proxy {
    [CmdletBinding()]
    param([string]$proxyAddr = $DEFAULT_PROXY)
    $env:http_proxy  = $proxyAddr
    $env:https_proxy = $proxyAddr
    $env:all_proxy   = $proxyAddr # 新增：兼容 Linux/macOS
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($proxyAddr)
    Write-Host "✅ 代理已启用：$proxyAddr" -ForegroundColor Green
}

function unproxy {
    $env:http_proxy  = $null
    $env:https_proxy = $null
    $env:all_proxy   = $null
    [System.Net.WebRequest]::DefaultWebProxy = $null
    Write-Host "✅ 代理已关闭" -ForegroundColor Yellow
}

function check-proxy {
    $httpProxy = $env:http_proxy ?? "未设置"
    $httpsProxy = $env:https_proxy ?? "未设置"
    Write-Host "🔍 当前代理：HTTP $httpProxy | HTTPS $httpsProxy" -ForegroundColor Cyan
}

# zoxide 智能跳转（）

Invoke-Expression (& { (zoxide init powershell | Out-String) })
