#!/usr/bin/env pwsh
# Claude Code statusline — Windows (PowerShell 7+)
# Configure in .claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "pwsh -NoProfile -NonInteractive -File C:\\path\\to\\statusline-windows.ps1"
#   }
#
# Output — two lines:
#
#   Line 1:  ~/path/to/dir  [| branch]  | user@host | v1.x.x | Windows | HH:MM
#
#   Line 2:  [Plan |]  Model  | ctx:45%/200K  | ln:+0/-0
#              [| 5h:30%(1h30m)]  [| wk:20%(2d3h)]   — rate limits, when present
#              [| ent:$5/∞]  or  [| ent:$5/$50]       — enterprise extra usage
#              [| ext:$5/$50]                           — non-enterprise extra usage
#              [| sc:$0.05]  | tk:12345

$ESC     = [char]0x1b
$White   = "$ESC[37m"
$Cyan    = "$ESC[36m"
$Magenta = "$ESC[35m"
$Blue    = "$ESC[34m"
$Green   = "$ESC[32m"
$Yellow  = "$ESC[33m"
$Red     = "$ESC[31m"
$Reset   = "$ESC[0m"
$Dim     = "$ESC[2m"

$CachePath     = "$HOME\.claude\statusline-usage-cache.json"
$CacheTtl      = 120
$CacheErrorTtl = 3600

function Get-PctColor([int]$pct) {
    if ($pct -ge 80) { return $Red }
    if ($pct -ge 50) { return $Yellow }
    return $Green
}

function Format-Tokens([long]$n) {
    if ($n -ge 1000000) { return "{0}M" -f [int]($n / 1000000) }
    if ($n -ge 1000)    { return "{0}K" -f [int]($n / 1000) }
    return "$n"
}

function Format-Pct([double]$pct) {
    if ($pct -ne [Math]::Floor($pct)) { return "{0:F1}%" -f $pct }
    return "{0}%" -f [int]$pct
}

function Format-ResetTime([long]$epochSec) {
    $now  = [long](([DateTime]::UtcNow - [DateTime]::UnixEpoch).TotalSeconds)
    $diff = $epochSec - $now
    if ($diff -le 0) { return "now" }
    $d = [int]($diff / 86400)
    $h = [int](($diff % 86400) / 3600)
    $m = [int](($diff % 3600) / 60)
    if ($d -gt 0) { return "${d}d${h}h$("{0:D2}" -f $m)m" }
    if ($h -gt 0) { return "${h}h$("{0:D2}" -f $m)m" }
    return "${m}m"
}

# Appends a rate-limit field (5h or wk) to $line; returns unchanged $line if $pctRaw is null.
# Reads $sep, $colon, $lp, $rp, $Dim, $Reset from script scope (set before first call).
function Add-RateLimitFields($line, $pctRaw, $resetRaw, $label) {
    if ($null -eq $pctRaw) { return $line }
    $pct      = [double]$pctRaw
    $color    = Get-PctColor ([int][Math]::Floor($pct))
    $pctStr   = Format-Pct $pct
    $resetStr = if ($resetRaw) { " ${lp}${Dim}$(Format-ResetTime ([long]$resetRaw))${Reset}${rp}" } else { "" }
    return $line + " ${sep} ${Dim}${label}${Reset}${colon}${color}${pctStr}${Reset}${resetStr}"
}

# ── Parse input JSON ──────────────────────────────────────────────────────────

$raw = [Console]::In.ReadToEnd()
$d   = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue

$currentDir  = [string]($d.cwd ?? "")
$modelId     = [string]($d.model.id ?? "")
$modelName   = [string]($d.model.display_name ?? "")
$ccVersion   = [string]($d.version ?? "")

$ctxTotalIn  = if ($null -ne $d.context_window.total_input_tokens)  { [long]$d.context_window.total_input_tokens }  else { 0 }
$ctxTotalOut = if ($null -ne $d.context_window.total_output_tokens) { [long]$d.context_window.total_output_tokens } else { 0 }
$ctxSize     = if ($null -ne $d.context_window.context_window_size) { [long]$d.context_window.context_window_size } else { 200000 }
$ctxPct      = if ($null -ne $d.context_window.used_percentage)    { [double]$d.context_window.used_percentage }   else { 0.0 }

$linesAdded   = if ($null -ne $d.cost.total_lines_added)   { [int]$d.cost.total_lines_added }   else { 0 }
$linesRemoved = if ($null -ne $d.cost.total_lines_removed) { [int]$d.cost.total_lines_removed } else { 0 }
$sessionCost  = $d.cost.total_cost_usd

$rate5hPct   = $d.rate_limits.five_hour.used_percentage
$rate5hReset = $d.rate_limits.five_hour.resets_at
$rateWkPct   = $d.rate_limits.seven_day.used_percentage
$rateWkReset = $d.rate_limits.seven_day.resets_at

# Tilde-shorten path for display (raw path still used for git)
$currentDirDisplay = $currentDir
if ($currentDirDisplay.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) {
    $currentDirDisplay = "~" + $currentDirDisplay.Substring($HOME.Length)
}

# ── Git branch ────────────────────────────────────────────────────────────────

$gitBranch = ""
if ($currentDir -and (Test-Path $currentDir -PathType Container)) {
    $gitBranch = (git -C $currentDir --no-optional-locks symbolic-ref --short HEAD 2>$null)
    if (-not $gitBranch) {
        $gitBranch = (git -C $currentDir --no-optional-locks rev-parse --short HEAD 2>$null)
    }
}

# ── Version fallback ──────────────────────────────────────────────────────────

if (-not $ccVersion -or $ccVersion -eq "unknown") {
    $ccVersion = (claude --version 2>$null | Select-Object -First 1) -replace '\s.*', ''
    if (-not $ccVersion) { $ccVersion = "unknown" }
}

# ── Credentials ───────────────────────────────────────────────────────────────

$fetchToken       = ""
$rateTier         = ""
$subscriptionType = ""
$credsPath        = "$HOME\.claude\.credentials.json"
if (Test-Path $credsPath) {
    try {
        $creds            = Get-Content $credsPath -Raw | ConvertFrom-Json
        $fetchToken       = [string]($creds.claudeAiOauth.accessToken ?? "")
        $rateTier         = [string]($creds.claudeAiOauth.rateLimitTier ?? "")
        $subscriptionType = [string]($creds.claudeAiOauth.subscriptionType ?? "")
    } catch {}
}
$isEnterpriseCreds = ($subscriptionType -eq "enterprise")

# ── Extra usage cache ─────────────────────────────────────────────────────────

$extraEnabled    = $false
$extraUsedCents  = 0
$extraLimitCents = $null

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
            $extraEnabled    = ($eu.is_enabled -eq $true)
            $extraUsedCents  = [int]($eu.used_credits ?? 0)
            $extraLimitCents = if ($null -ne $eu.monthly_limit) { [int]$eu.monthly_limit } else { $null }
        } catch {}
    }
}

if ($needsFetch -and $fetchToken) {
    try {
        $u = Invoke-RestMethod `
            -Uri     "https://api.anthropic.com/api/oauth/usage" `
            -Headers @{
                "Authorization"  = "Bearer $fetchToken"
                "Content-Type"   = "application/json"
                "anthropic-beta" = "oauth-2025-04-20"
            } `
            -TimeoutSec           3 `
            -SkipCertificateCheck
        $u | ConvertTo-Json -Depth 10 | Set-Content $CachePath
        $eu              = $u.extra_usage
        $extraEnabled    = ($eu.is_enabled -eq $true)
        $extraUsedCents  = [int]($eu.used_credits ?? 0)
        $extraLimitCents = if ($null -ne $eu.monthly_limit) { [int]$eu.monthly_limit } else { $null }
    } catch {}
}

$extraUsedDollars      = [int]($extraUsedCents / 100)
$extraLimitIsUnlimited = ($null -eq $extraLimitCents)
$extraLimitDollars     = if ($extraLimitIsUnlimited) { 0 } else { [int]($extraLimitCents / 100) }

# ── Derived values ────────────────────────────────────────────────────────────

# Exclude Max/Pro tiers — they can have absent rate-limit data transiently but are never enterprise.
$isNonEnterprisePlan = $rateTier -match "max|pro"
$isEnterprise = $isEnterpriseCreds -or (($null -eq $rate5hPct -and $null -eq $rateWkPct) -and -not $isNonEnterprisePlan)

$planLabel = switch -Wildcard ($rateTier) {
    "*max_10x*"    { "Max 10x"; break }
    "*max_5x*"     { "Max 5x";  break }
    "*max*"        { "Max";     break }
    "*pro*"        { "Pro";     break }
    "*enterprise*" { "Enterprise"; break }
    default        { "" }
}

$modelColor = $Cyan
if     ($modelId -match "opus")   { $modelColor = $Yellow }
elseif ($modelId -match "sonnet") { $modelColor = $Green }

$ctxPctInt     = [int][Math]::Floor($ctxPct)
$ctxPctDisplay = Format-Pct $ctxPct
$ctxColor      = Get-PctColor $ctxPctInt
$ctxSizeFmt    = Format-Tokens $ctxSize
$tokenCount    = $ctxTotalIn + $ctxTotalOut

# ── Build output ──────────────────────────────────────────────────────────────

$sep   = "${Dim}|${Reset}"
$colon = "${Dim}:${Reset}"
$slash = "${Dim}/${Reset}"
$at    = "${Dim}@${Reset}"
$lp    = "${Dim}(${Reset}"
$rp    = "${Dim})${Reset}"

# ── Line 1 ────────────────────────────────────────────────────────────────────
$line1 = "${Cyan}${currentDirDisplay}${Reset}"
if ($gitBranch) { $line1 += " ${sep} ${Magenta}${gitBranch}${Reset}" }
$line1 += " ${sep} ${Yellow}$($env:USERNAME)${Reset}${at}${White}$($env:COMPUTERNAME)${Reset}"
$line1 += " ${sep} ${Cyan}v${ccVersion}${Reset}"
$line1 += " ${sep} ${Blue}Windows${Reset}"
$line1 += " ${sep} ${White}$(Get-Date -Format 'HH:mm')${Reset}"

# ── Line 2 ────────────────────────────────────────────────────────────────────
if ($planLabel) {
    $line2 = "${Magenta}${planLabel}${Reset} ${sep} "
} else {
    $line2 = ""
}
$line2 += "${modelColor}${modelName}${Reset}"
$line2 += " ${sep} ${Dim}ctx${Reset}${colon}${ctxColor}${ctxPctDisplay}${Reset}${slash}${Cyan}${ctxSizeFmt}${Reset}"
$line2 += " ${sep} ${Dim}ln${Reset}${colon}${Green}+${linesAdded}${Reset}${slash}${Red}-${linesRemoved}${Reset}"

$line2 = Add-RateLimitFields $line2 $rate5hPct $rate5hReset "5h"
$line2 = Add-RateLimitFields $line2 $rateWkPct $rateWkReset "wk"

if ($isEnterprise -and $extraEnabled) {
    if ($extraLimitIsUnlimited) {
        $line2 += " ${sep} ${Dim}ent${Reset}${colon}${Green}`$${extraUsedDollars}${Reset}${Dim}/∞${Reset}"
    } else {
        $pct   = if ($extraLimitDollars -gt 0) { [int]($extraUsedDollars * 100 / $extraLimitDollars) } else { 0 }
        $color = Get-PctColor $pct
        $line2 += " ${sep} ${Dim}ent${Reset}${colon}${color}`$${extraUsedDollars}${Reset}${slash}${Cyan}`$${extraLimitDollars}${Reset}"
    }
} elseif ($extraEnabled) {
    $pct   = if ($extraLimitDollars -gt 0) { [int]($extraUsedDollars * 100 / $extraLimitDollars) } else { 0 }
    $color = Get-PctColor $pct
    $line2 += " ${sep} ${Dim}ext${Reset}${colon}${color}`$${extraUsedDollars}${Reset}${slash}${Cyan}`$${extraLimitDollars}${Reset}"
}

if ($null -ne $sessionCost) {
    $scFmt = "{0:F2}" -f [double]$sessionCost
    $line2 += " ${sep} ${Dim}sc${Reset}${colon}${Magenta}`$${scFmt}${Reset}"
}

$line2 += " ${sep} ${Dim}tk${Reset}${colon}${White}${tokenCount}${Reset}"

[Console]::WriteLine($line1)
[Console]::WriteLine($line2)
