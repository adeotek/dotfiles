#requires -Version 7.0

<#
.SYNOPSIS
    Bulk renames files recursively in a given path using regex expressions.

.DESCRIPTION
    Searches recursively for files whose names match a regex search expression and renames
    them using a replacement expression. Supports a dry run mode that prints the planned
    renames without making any changes.

    The search and replacement expressions follow .NET regex syntax, so capture groups
    can be referenced in the replacement (e.g. '$1', '$2').

.PARAMETER Path
    The root directory to search recursively for files.

.PARAMETER Search
    A .NET regex expression matched against each file's name (not the full path).
    Only files whose names contain a match will be renamed.

.PARAMETER Replacement
    The replacement expression applied to the matched portion of the file name.
    Supports regex substitution syntax (e.g. '$1', '$2' for capture groups).

.PARAMETER DryRun
    When specified, prints the planned renames without making any changes to the filesystem.

.PARAMETER Exclude
    One or more directory names to exclude from the search. Subdirectories at any depth
    whose name matches an entry in this list will be skipped entirely.

.EXAMPLE
    .\Rename-Files.ps1 -Path "C:\Reports" -Search "report_" -Replacement "summary_"
    Renames all files containing 'report_' in their name to use 'summary_' instead.

.EXAMPLE
    .\Rename-Files.ps1 -Path "C:\Logs" -Search "\.log$" -Replacement ".txt" -DryRun
    Previews renaming all .log files to .txt without making any changes.

.EXAMPLE
    .\Rename-Files.ps1 -Path ".\src" -Search "^(.+)_v(\d+)(\..+)$" -Replacement "v`$2_`$1`$3"
    Renames files matching the pattern 'name_v1.ext' to 'v1_name.ext' using capture groups.

.EXAMPLE
    .\Rename-Files.ps1 -Path "." -Search "^eslint\.config\.js$" -Replacement "eslint.config.mjs" -Exclude "node_modules","dist" -DryRun
    Previews renaming eslint.config.js files while skipping node_modules and dist directories.
#>

[CmdletBinding()]
param(
    [Alias('h')]
    [switch]$Help,

    [Parameter(Mandatory = $true, HelpMessage = "Root directory to search recursively")]
    [string]$Path,

    [Parameter(Mandatory = $true, HelpMessage = "Regex expression to match against file names")]
    [string]$Search,

    [Parameter(Mandatory = $true, HelpMessage = "Replacement expression (supports regex capture groups)")]
    [string]$Replacement,

    [Parameter(Mandatory = $false, HelpMessage = "Preview renames without applying changes")]
    [switch]$DryRun,

    [Parameter(Mandatory = $false, HelpMessage = "Directory names to exclude from the search")]
    [string[]]$Exclude = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

# Validate the search expression is a valid regex
try {
    $null = [regex]$Search
}
catch {
    Write-Host "✗ Invalid regex expression for -Search: $_" -ForegroundColor Red
    exit 1
}

# Validate target path
if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Host "✗ Path '$Path' does not exist or is not a directory." -ForegroundColor Red
    exit 1
}

$resolvedPath = (Resolve-Path -Path $Path).Path

if ($DryRun) {
    Write-Host "`n=== Dry Run — no files will be renamed ===" -ForegroundColor Yellow
}
else {
    Write-Host "`n=== Bulk Rename ===" -ForegroundColor Cyan
}

Write-Host "Path:        $resolvedPath" -ForegroundColor White
Write-Host "Search:      $Search" -ForegroundColor White
Write-Host "Replacement: $Replacement" -ForegroundColor White
if ($Exclude.Count -gt 0) {
    Write-Host "Exclude:     $($Exclude -join ', ')" -ForegroundColor White
}
Write-Host ""

$matchedCount = 0
$renamedCount = 0
$errorCount = 0

$files = Get-ChildItem -Path $resolvedPath -File -Recurse

foreach ($file in $files) {
    if ($Exclude.Count -gt 0) {
        $pathSegments = $file.FullName.Split([System.IO.Path]::DirectorySeparatorChar)
        if ($pathSegments | Where-Object { $Exclude -contains $_ }) {
            continue
        }
    }

    if ($file.Name -notmatch $Search) {
        continue
    }

    $matchedCount++
    $newName = $file.Name -replace $Search, $Replacement
    $relativePath = [System.IO.Path]::GetRelativePath($resolvedPath, $file.DirectoryName)
    $displayCurrent = Join-Path $relativePath $file.Name
    $displayNew = Join-Path $relativePath $newName

    if ($DryRun) {
        Write-Host "  $displayCurrent" -ForegroundColor Gray -NoNewline
        Write-Host "  →  " -ForegroundColor DarkGray -NoNewline
        Write-Host "$displayNew" -ForegroundColor Cyan
        continue
    }

    try {
        Rename-Item -Path $file.FullName -NewName $newName
        Write-Host "✓ $displayCurrent  →  $displayNew" -ForegroundColor Green
        $renamedCount++
    }
    catch {
        Write-Host "✗ Failed to rename '$displayCurrent': $_" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""

if ($matchedCount -eq 0) {
    Write-Host "⚠ No files matched the search expression." -ForegroundColor Yellow
}
elseif ($DryRun) {
    Write-Host "Dry run complete. $matchedCount file(s) would be renamed." -ForegroundColor Yellow
}
else {
    Write-Host "Done. $renamedCount/$matchedCount file(s) renamed." -ForegroundColor Cyan
    if ($errorCount -gt 0) {
        Write-Host "⚠ $errorCount file(s) failed to rename." -ForegroundColor Yellow
        exit 1
    }
}
