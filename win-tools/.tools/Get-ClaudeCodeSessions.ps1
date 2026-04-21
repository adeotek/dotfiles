#!/usr/bin/env pwsh
#requires -Version 7.0
<#
.SYNOPSIS
    Lists Claude Code sessions stored in ~/.claude/projects/.

.DESCRIPTION
    Scans Claude Code session JSONL files and displays them grouped by project,
    with optional filtering, file listing, projects-only output, and deletion.

.PARAMETER List
    Output full session file paths only (pipeline-friendly, no colours).

.PARAMETER Project
    Filter by project path (partial match, case-insensitive).

.PARAMETER Filter
    Filter by session ID (exact), name, or summary (partial, case-insensitive).

.PARAMETER ProjectsOnly
    Output only deduplicated project paths. Respects -Project and -Filter.

.PARAMETER Remove
    Interactively remove matched sessions and all associated UUID-keyed data.

.PARAMETER Help
    Show this help message.

.EXAMPLE
    cc-sessions.ps1

.EXAMPLE
    cc-sessions.ps1 -Project myrepo -Filter "authentication"

.EXAMPLE
    cc-sessions.ps1 -ProjectsOnly -Project dotfiles

.EXAMPLE
    cc-sessions.ps1 -List | Select-String "myrepo"

.EXAMPLE
    cc-sessions.ps1 -Project oldrepo -Remove
#>

[CmdletBinding()]
param(
    [Alias('l')]
    [switch]$List,

    [Alias('p')]
    [string]$Project = '',

    [Alias('f')]
    [string]$Filter = '',

    [switch]$ProjectsOnly,

    [Alias('r')]
    [switch]$Remove,

    [Alias('h')]
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Configuration ─────────────────────────────────────────────────────────────

$claudeDir = if ($env:CLAUDE_DIR) { $env:CLAUDE_DIR } else { Join-Path $HOME '.claude' }
$projectsDir = Join-Path $claudeDir 'projects'

# ── Help ──────────────────────────────────────────────────────────────────────

if ($Help) {
    Write-Host "Usage: cc-sessions.ps1 [-h] [-l] [-p <str>] [-f <str>] [-ProjectsOnly] [-r] "
    Write-Host ""
    Write-Host "  -h, -Help            Show this help message"
    Write-Host "  -l, -List            Output full session file paths only"
    Write-Host "  -p, -Project <str>   Filter by project path (partial match, case-insensitive)"
    Write-Host "  -f, -Filter <str>    Filter by session ID, name, or summary (case-insensitive)"
    Write-Host "      -ProjectsOnly    Output only project paths (respects -Project and -Filter)"
    Write-Host "  -r, -Remove          Remove matched sessions and their associated data (requires confirmation)"
    exit 0
}

# ── Conflict guards ────────────────────────────────────────────────────────────

if ($List -and $Remove) {
    Write-Error 'Error: -List and -Rm cannot be used together'
    exit 1
}
if ($ProjectsOnly -and $List) {
    Write-Error 'Error: -ProjectsOnly and -List cannot be used together'
    exit 1
}
if ($ProjectsOnly -and $Remove) {
    Write-Error 'Error: -ProjectsOnly and -Rm cannot be used together'
    exit 1
}
if (-not (Test-Path $projectsDir -PathType Container)) {
    Write-Error "Error: Claude projects directory not found: $projectsDir"
    exit 1
}

# ── Colour setup ──────────────────────────────────────────────────────────────

# Check both stdout redirection and virtual terminal support
$useColour = -not [Console]::IsOutputRedirected -and
             $Host.UI.SupportsVirtualTerminal

$cProject = if ($useColour) { "`e[1;36m" } else { '' }
$cSession = if ($useColour) { "`e[1;33m" } else { '' }
$cLabel   = if ($useColour) { "`e[0;90m" } else { '' }
$cReset   = if ($useColour) { "`e[0m"    } else { '' }

# ── Terminal width ─────────────────────────────────────────────────────────────

$termWidth = try { $Host.UI.RawUI.WindowSize.Width } catch { 0 }
if ($termWidth -le 0) { $termWidth = 80 }

# ── Helper: extract first JSON string field value from a line ─────────────────

function Get-JsonField([string]$Line, [string]$Field) {
    # Handles escaped characters inside the value (e.g. \\ in Windows paths)
    if ($Line -match ('"' + [regex]::Escape($Field) + '":"((?:[^"\\]|\\.)*)')) {
        return $Matches[1] -replace '\\\\"', '"' -replace '\\\\', '\'
    }
    return $null
}

# ── State ─────────────────────────────────────────────────────────────────────

$rmFiles         = [System.Collections.Generic.List[string]]::new()
$rmLabels        = [System.Collections.Generic.List[string]]::new()
$seenProjects    = [System.Collections.Generic.HashSet[string]]::new(
                       [System.StringComparer]::OrdinalIgnoreCase)
$orderedProjects = [System.Collections.Generic.List[string]]::new()
$firstProject    = $true

# ── Main loop ─────────────────────────────────────────────────────────────────

foreach ($projDir in Get-ChildItem $projectsDir -Directory -ErrorAction SilentlyContinue) {
    $projSlug      = $projDir.Name
    $headerPrinted = $false

    foreach ($sessionFile in Get-ChildItem $projDir.FullName -Filter '*.jsonl' -File -ErrorAction SilentlyContinue) {
        $lines = Get-Content $sessionFile.FullName -ErrorAction SilentlyContinue
        if (-not $lines) { continue }

        # Resolve project path from cwd, fall back to slug
        $cwdLine     = $lines | Where-Object { $_ -match '"cwd"' } | Select-Object -First 1
        $projectPath = if ($cwdLine) { Get-JsonField $cwdLine 'cwd' } else { $null }
        if (-not $projectPath) { $projectPath = $projSlug }

        $sessionId = $sessionFile.BaseName

        # AI-generated session title (may be absent)
        $titleLine = $lines | Where-Object { $_ -match '"type":"ai-title"' } | Select-Object -First 1
        $name      = if ($titleLine) { Get-JsonField $titleLine 'aiTitle' } else { $null }

        # Last prompt used as summary
        $promptLine = $lines | Where-Object { $_ -match '"type":"last-prompt"' } | Select-Object -First 1
        $summary    = if ($promptLine) { Get-JsonField $promptLine 'lastPrompt' } else { $null }
        if (-not $summary) { $summary = 'No summary available' }

        # ── Filters ───────────────────────────────────────────────────────────

        if ($Project -and $projectPath -notlike "*$Project*") { continue }

        if ($Filter) {
            $idMatch      = $sessionId -ieq $Filter
            $nameMatch    = $name -and $name -ilike "*$Filter*"
            $summaryMatch = $summary -ilike "*$Filter*"
            if (-not ($idMatch -or $nameMatch -or $summaryMatch)) { continue }
        }

        # ── Mode dispatch ─────────────────────────────────────────────────────

        if ($ProjectsOnly) {
            if ($seenProjects.Add($projectPath)) {
                $orderedProjects.Add($projectPath)
            }
            continue
        }

        if ($Remove) {
            $rmFiles.Add($sessionFile.FullName)
            $label = if ($name) {
                "$projectPath  |  $sessionId  ($name)"
            } else {
                "$projectPath  |  $sessionId"
            }
            $rmLabels.Add($label)
            continue
        }

        if ($List) {
            Write-Output $sessionFile.FullName
            continue
        }

        # ── Default display ───────────────────────────────────────────────────

        if (-not $headerPrinted) {
            if (-not $firstProject) { Write-Host '' }
            $headerText = "── $projectPath "
            $padLen     = $termWidth - $headerText.Length
            if ($padLen -lt 2) { $padLen = 2 }
            $padding = '─' * $padLen
            Write-Host "${cProject}${headerText}${padding}${cReset}"
            $headerPrinted = $true
            $firstProject  = $false
        }

        $relPath    = "projects/$projSlug/$($sessionFile.Name)"
        $maxSummary = $termWidth - 15
        $dispSummary = if ($summary.Length -gt $maxSummary) {
            $summary.Substring(0, $maxSummary) + '…'
        } else {
            $summary
        }

        Write-Host "  ${cSession}${sessionId}${cReset}"
        if ($name) {
            Write-Host "  ${cLabel}  $('Name'.PadRight(7))${cReset}  $name"
        }
        Write-Host "  ${cLabel}  $('Summary'.PadRight(7))${cReset}  $dispSummary"
        Write-Host "  ${cLabel}  $('File'.PadRight(7))${cReset}  $relPath"
    }
}

# ── Projects-only output ──────────────────────────────────────────────────────

if ($ProjectsOnly) {
    foreach ($proj in $orderedProjects) {
        Write-Host "${cProject}${proj}${cReset}"
    }
    exit 0
}

# ── Remove sessions ───────────────────────────────────────────────────────────

if ($Remove) {
    if ($rmFiles.Count -eq 0) {
        Write-Host 'No sessions matched.'
        exit 0
    }

    Write-Host "The following $($rmFiles.Count) session(s) will be permanently removed:"
    foreach ($label in $rmLabels) {
        Write-Host "  $label"
    }
    Write-Host ''

    $confirm = Read-Host 'Proceed? [y/N]'
    if ($confirm -ine 'y') {
        Write-Host 'Aborted.'
        exit 0
    }

    $removed = 0
    foreach ($sessionFilePath in $rmFiles) {
        $uuid = [System.IO.Path]::GetFileNameWithoutExtension($sessionFilePath)
        Remove-Item $sessionFilePath -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $claudeDir 'file-history' $uuid) -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $claudeDir 'session-env'  $uuid) -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $claudeDir 'tasks'        $uuid) -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $claudeDir "security_warnings_state_$uuid.json") -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $claudeDir 'debug' "$uuid.txt")  -Force -ErrorAction SilentlyContinue
        $removed++
    }
    Write-Host "Removed $removed session(s)."
}
