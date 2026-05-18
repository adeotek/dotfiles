#!/usr/bin/env pwsh
# Claude Code statusline — Windows (PowerShell 7+)
# Configure in .claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "pwsh -NoProfile -NonInteractive -File C:\\path\\to\\statusline-windows.ps1"
#   }
# Output:
#   <path> | <git-branch> | <time>
#   <user@host> | Windows | <version> | <model> | ctx:<pct>%/<size> | 5h:<pct>% | wk:<pct>% | ent:$<spent>/$<limit|∞> (Enterprise) | ext:$<used>/$<limit> (non-Enterprise)

$ESC      = [char]0x1b
$White    = "$ESC[37m"
$Cyan     = "$ESC[36m"
$Magenta  = "$ESC[35m"
$Blue     = "$ESC[34m"  # reserved / Windows label
$Green    = "$ESC[32m"
$Yellow   = "$ESC[33m"
$Red      = "$ESC[31m"
$Reset    = "$ESC[0m"
$Dim      = "$ESC[2m"

$CachePath      = "$HOME\.claude\statusline-usage-cache.json"
$CacheTtl       = 60
$CacheErrorTtl  = 3600

function Get-PercentColor([int]$pct) {
    if ($pct -ge 80) { return $Red }
    if ($pct -ge 50) { return $Yellow }
    return $Green
}

function Format-Tokens([int]$n) {
    if ($n -ge 1000000) { return "{0:F1}M" -f ($n / 1000000.0) }
    if ($n -ge 1000)    { return "{0}K"    -f [int]($n / 1000) }
    return "$n"
}

# ── Parse input JSON ──────────────────────────────────────────────────────────

$raw = [Console]::In.ReadToEnd()
$d   = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue

$currentDir  = [string]($d.workspace.current_dir ?? $d.cwd ?? "")
$modelName   = [string]($d.model.display_name ?? "")
$ccVersion   = [string]($d.version ?? "")
$contextMax  = if ($null -ne $d.context_window.context_window_size) { [int]$d.context_window.context_window_size } else { 200000 }
$contextPct  = if ($null -ne $d.context_window.used_percentage)    { [double]$d.context_window.used_percentage }  else { 0.0 }

if ($currentDir.StartsWith($HOME)) {
    $currentDir = "~" + $currentDir.Substring($HOME.Length)
}

# ── Git branch ────────────────────────────────────────────────────────────────

$gitBranch = ""
if ($currentDir) {
    $realDir = $currentDir -replace "^~", $HOME
    if (Test-Path $realDir -PathType Container) {
        $gitBranch = (git -C $realDir --no-optional-locks symbolic-ref --short HEAD 2>$null)
        if (-not $gitBranch) {
            $gitBranch = (git -C $realDir --no-optional-locks rev-parse --short HEAD 2>$null)
        }
    }
}

# ── Version fallback ──────────────────────────────────────────────────────────

if (-not $ccVersion -or $ccVersion -eq "unknown") {
    $ccVersion = (claude --version 2>$null | Select-Object -First 1) -replace '\s.*', ''
    if (-not $ccVersion) { $ccVersion = "unknown" }
}

$contextPctInt  = [int][Math]::Floor($contextPct)
$ctxSizeFmt     = Format-Tokens $contextMax

# ── Credentials ───────────────────────────────────────────────────────────────

$token            = ""
$subscriptionType = ""
$credsPath        = "$HOME\.claude\.credentials.json"
if (Test-Path $credsPath) {
    try {
        $creds            = Get-Content $credsPath -Raw | ConvertFrom-Json
        $token            = [string]($creds.claudeAiOauth.accessToken ?? "")
        $subscriptionType = [string]($creds.claudeAiOauth.subscriptionType ?? "")
    } catch {}
}
$isEnterprise = ($subscriptionType -eq "enterprise")

# ── Usage cache ───────────────────────────────────────────────────────────────

$usage5h         = 0.0
$usage7d         = 0.0
$extraEnabled    = $false
$extraUsedCents  = 0
$extraLimitCents = $null   # null = unlimited

$needsFetch = $true
if (Test-Path $CachePath) {
    $cacheContent = Get-Content $CachePath -Raw
    $ttl          = if ($cacheContent -match "permission_error|authentication_error") { $CacheErrorTtl } else { $CacheTtl }
    $cacheAge     = ((Get-Date) - (Get-Item $CachePath).LastWriteTime).TotalSeconds
    if ($cacheAge -le $ttl) {
        $needsFetch = $false
        try {
            $u               = $cacheContent | ConvertFrom-Json
            $eu              = $u.extra_usage
            $usage5h         = [double]($u.five_hour.utilization ?? 0)
            $usage7d         = [double]($u.seven_day.utilization ?? 0)
            $extraEnabled    = ($eu.is_enabled -eq $true)
            $extraUsedCents  = [int]($eu.used_credits ?? 0)
            $extraLimitCents = if ($null -ne $eu.monthly_limit) { [int]$eu.monthly_limit } else { $null }
        } catch {}
    }
}

if ($needsFetch -and $token) {
    try {
        $u = Invoke-RestMethod `
            -Uri     "https://api.anthropic.com/api/oauth/usage" `
            -Headers @{
                "Authorization"  = "Bearer $token"
                "Content-Type"   = "application/json"
                "anthropic-beta" = "oauth-2025-04-20"
            } `
            -TimeoutSec          3 `
            -SkipCertificateCheck  # mirrors curl -k for untrusted CA intermediates
        $u | ConvertTo-Json -Depth 10 | Set-Content $CachePath
        $eu              = $u.extra_usage
        $usage5h         = [double]($u.five_hour.utilization ?? 0)
        $usage7d         = [double]($u.seven_day.utilization ?? 0)
        $extraEnabled    = ($eu.is_enabled -eq $true)
        $extraUsedCents  = [int]($eu.used_credits ?? 0)
        $extraLimitCents = if ($null -ne $eu.monthly_limit) { [int]$eu.monthly_limit } else { $null }
    } catch {}
}

$usage5hInt = [int][Math]::Floor($usage5h)
$usage7dInt = [int][Math]::Floor($usage7d)

$extraUsedDollars      = [int]($extraUsedCents / 100)
$extraLimitIsUnlimited = ($null -eq $extraLimitCents)
$extraLimitDollars     = if ($extraLimitIsUnlimited) { 0 } else { [int]($extraLimitCents / 100) }

# ── Build output ──────────────────────────────────────────────────────────────

$sep = "${Dim} | ${Reset}"

# Line 1: path | branch | time
$line1 = "${Cyan}${currentDir}${Reset}"
if ($gitBranch) { $line1 += "${sep}${Magenta}${gitBranch}${Reset}" }
$line1 += "${sep}${White}$(Get-Date -Format 'HH:mm:ss')${Reset}"

# Line 2: user@host | OS | version | model | ctx | usage | spend
$currentUser = $env:USERNAME
$currentHost = $env:COMPUTERNAME
$line2  = "${Yellow}${currentUser}${Reset}${Dim}@${Reset}${White}${currentHost}${Reset}"
$line2 += "${sep}${Blue}Windows${Reset}"
$line2 += "${sep}${Cyan}v${ccVersion}${Reset}"
if ($modelName) { $line2 += "${sep}${Magenta}${modelName}${Reset}" }

$ctxColor = Get-PercentColor $contextPctInt
$line2 += "${sep}${Dim}ctx:${Reset}${ctxColor}${contextPctInt}%${Reset}${Dim}/${Reset}${Cyan}${ctxSizeFmt}${Reset}"

if ($usage7dInt -gt 0 -or $usage5hInt -gt 0) {
    $color5h = Get-PercentColor $usage5hInt
    $line2  += "${sep}${Dim}5h:${Reset}${color5h}${usage5hInt}%${Reset}"
    $color7d = Get-PercentColor $usage7dInt
    $line2  += "${sep}${Dim}wk:${Reset}${color7d}${usage7dInt}%${Reset}"
}

if ($isEnterprise -and $extraEnabled) {
    if ($extraLimitIsUnlimited) {
        $line2 += "${sep}${Dim}ent:${Reset}${Green}`$${extraUsedDollars}${Reset}${Dim}/∞${Reset}"
    } else {
        $pctEnt   = if ($extraLimitDollars -gt 0) { [int]($extraUsedDollars * 100 / $extraLimitDollars) } else { 0 }
        $colorEnt = Get-PercentColor $pctEnt
        $line2   += "${sep}${Dim}ent:${Reset}${colorEnt}`$${extraUsedDollars}${Reset}${Dim}/${Reset}${Cyan}`$${extraLimitDollars}${Reset}"
    }
} elseif ($extraEnabled) {
    $pctExt   = if ($extraLimitDollars -gt 0) { [int]($extraUsedDollars * 100 / $extraLimitDollars) } else { 0 }
    $colorExt = Get-PercentColor $pctExt
    $line2   += "${sep}${Dim}ext:${Reset}${colorExt}`$${extraUsedDollars}${Reset}${Dim}/${Reset}${Cyan}`$${extraLimitDollars}${Reset}"
}

[Console]::WriteLine($line1)
[Console]::WriteLine($line2)
