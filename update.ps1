# ============================================================
#  代理配置自动更新脚本
#  从 GitLab 云端镜像拉取 6 个内核的最新配置
#  用法:
#    - GitHub Actions:  powershell -ExecutionPolicy Bypass -File update.ps1
#    - 本地手动:        powershell -ExecutionPolicy Bypass -File update.ps1
#  输出: config/ 目录 (写入最新配置 + .last_update 时间戳)
# ============================================================
$ErrorActionPreference = 'SilentlyContinue'

# 工作目录 = 脚本所在目录
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }
$ConfigDir = Join-Path $ScriptDir 'config'
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

$curl = Join-Path $env:SystemRoot 'System32\curl.exe'
if (-not (Test-Path $curl)) { $curl = 'curl.exe' }

# ---- 源定义: 内核 -> 文件 -> 镜像URL列表 ----
$sources = @(
    @{ file='clash.meta_config.yaml'; urls=@(
        'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ip/clash.meta2/1/config.yaml'
        'https://gitlab.com/free9999/ipupdate/-/raw/master/backup/img/1/2/ip/clash.meta2/1/config.yaml'
    )},
    @{ file='Xray_config.json'; urls=@(
        'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ip/xray/1/config.json'
        'https://gitlab.com/free9999/ipupdate/-/raw/master/backup/img/1/2/ip/xray/1/config.json'
    )},
    @{ file='hysteria_config.json'; urls=@(
        'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ip/hysteria/1/config.json'
        'https://gitlab.com/free9999/ipupdate/-/raw/master/backup/img/1/2/ip/hysteria/1/config.json'
    )},
    @{ file='hysteria2_config.json'; urls=@(
        'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ip/hysteria2/1/config.json'
        'https://gitlab.com/free9999/ipupdate/-/raw/master/backup/img/1/2/ip/hysteria2/1/config.json'
    )},
    @{ file='singbox_config.json'; urls=@(
        'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ip/singbox/1/config.json'
        'https://gitlab.com/free9999/ipupdate/-/raw/master/backup/img/1/2/ip/singbox/1/config.json'
    )},
    @{ file='naiveproxy_config.json'; urls=@(
        'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ip/naiveproxy/1/config.json'
        'https://gitlab.com/free9999/ipupdate/-/raw/master/backup/img/1/2/ip/naiveproxy/1/config.json'
    )}
)

Write-Host "=== 代理配置自动更新 ==="
Write-Host "工作目录: $ScriptDir"
Write-Host ""

$okCount = 0
$changedCount = 0

foreach ($src in $sources) {
    $file = $src.file
    $target = Join-Path $ConfigDir $file
    $tmp = Join-Path $ConfigDir "__tmp"
    $downloaded = $false

    foreach ($url in $src.urls) {
        & $curl -s -L --connect-timeout 10 -m 25 -o $tmp $url 2>$null
        if ((Test-Path $tmp) -and (Get-Item $tmp).Length -gt 100) {
            $content = Get-Content $tmp -Raw -ErrorAction SilentlyContinue
            if ($content -match 'server|port|address|listen|proxies|inbound|tun|vless|hysteria') {
                $moved = $true
                # 仅当内容有变化时才覆盖(减少无谓的 git 提交)
                if ((Test-Path $target)) {
                    $old = Get-Content $target -Raw -ErrorAction SilentlyContinue
                    if ($old -eq $content) { $moved = $false }
                }
                if ($moved) {
                    Copy-Item -Force $tmp $target
                    Write-Host ("  [已更新] {0}  ({1} 字节)" -f $file, (Get-Item $target).Length)
                    $changedCount++
                } else {
                    Write-Host ("  [无变化] {0}" -f $file)
                }
                Remove-Item -Force $tmp -ErrorAction SilentlyContinue
                $downloaded = $true
                $okCount++
                break
            } else {
                Write-Host ("  [内容异常] 跳过 {0}" -f $url)
                Remove-Item -Force $tmp -ErrorAction SilentlyContinue
            }
        } else {
            Remove-Item -Force $tmp -ErrorAction SilentlyContinue
        }
    }
    if (-not $downloaded) {
        Write-Host ("  [获取失败] {0}" -f $file) -ForegroundColor Red
    }
}

# 写入更新时间戳 (纯 ASCII, UTF-8 无 BOM, 跨平台安全)
$ts = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss') + ' UTC'
$tsPath = Join-Path $ConfigDir '.last_update'
[System.IO.File]::WriteAllText($tsPath, $ts, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ""
Write-Host "=== 完成: 成功 $okCount/6, 更新 $changedCount 项 ==="
Write-Host "最新更新时间: $ts"

# 供 GitHub Actions 判断是否有变化
$env:CONFIG_CHANGED = if ($changedCount -gt 0) { 'true' } else { 'false' }
Write-Host "CONFIG_CHANGED=$env:CONFIG_CHANGED"