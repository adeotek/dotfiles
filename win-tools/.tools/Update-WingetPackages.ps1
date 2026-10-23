#Requires -Version 5.1
<#
.SYNOPSIS
    Lists available winget updates and upgrades all packages after confirmation.

.DESCRIPTION
    Runs `winget upgrade` to check for available package updates.

    - If no updates are available, the script reports that and exits.
    - Otherwise it displays the list of available updates and asks for permission.
    - If the user grants permission, all packages are upgraded via
      `winget upgrade --all`; otherwise the script exits without changing anything.

.EXAMPLE
    .\Update-WingetPackages.ps1

.NOTES
    The check uses --include-unknown so packages whose installed version cannot
    be determined are listed and upgraded as well.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-UpdateRows {
    <#
        Extracts the data rows of the update table from `winget upgrade` output.
        The table is locale-independent: a dashed separator line is followed by
        one row per update, and each row has its columns separated by at least
        two spaces. A footer summary ("N upgrades available.") has single spaces
        and is therefore not counted as a row.
    #>
    param([string[]]$Lines)

    if (-not $Lines) {
        return
    }

    $separatorIndex = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i] -replace '\x1b\[[0-9;]*[A-Za-z]', ''  # strip ANSI escapes
        if ($line.Trim() -match '^[-\u2500]{5,}$') {
            $separatorIndex = $i
            break
        }
    }

    if ($separatorIndex -lt 0) {
        return
    }

    $rows = @()
    for ($i = $separatorIndex + 1; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i] -replace '\x1b\[[0-9;]*[A-Za-z]', ''
        if ([string]::IsNullOrWhiteSpace($line)) {
            break
        }
        if ($line -match '\S\s{2,}\S') {
            $rows += $line
        }
    }
    return $rows
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host 'winget was not found. Install "App Installer" from the Microsoft Store and try again.' -ForegroundColor Red
    exit 1
}

# winget emits UTF-8; make sure the table renders correctly in the console.
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # No console attached; the output is still readable.
}

Write-Host 'Checking for winget updates...' -ForegroundColor Cyan
$listing = @(& winget upgrade --include-unknown --accept-source-agreements 2>&1 | ForEach-Object { [string]$_ })
$listingExitCode = $LASTEXITCODE
$updates = @(Get-UpdateRows -Lines $listing)

if ($updates.Count -eq 0) {
    if ($listingExitCode -ne 0) {
        $listing | ForEach-Object { Write-Host $_ }
        Write-Host "winget upgrade failed with exit code $listingExitCode." -ForegroundColor Red
        exit 1
    }
    Write-Host 'No winget updates available.' -ForegroundColor Green
    exit 0
}

Write-Host ''
Write-Host 'Available winget updates:' -ForegroundColor Cyan
$listing | ForEach-Object { Write-Host $_ }
Write-Host ''

$answer = Read-Host 'Do you want to update all packages now? [y/N]'
if ($answer.Trim() -notmatch '^(y|yes)$') {
    Write-Host 'Update cancelled. No packages were changed.' -ForegroundColor Yellow
    exit 0
}

Write-Host ''
Write-Host 'Updating all packages...' -ForegroundColor Cyan
& winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements
$upgradeExitCode = $LASTEXITCODE

if ($upgradeExitCode -ne 0) {
    Write-Warning "winget upgrade exited with code $upgradeExitCode. Some packages may not have been updated."
    exit 1
}

Write-Host 'All winget updates completed successfully.' -ForegroundColor Green
exit 0
