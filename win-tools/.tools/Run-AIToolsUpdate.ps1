#requires -Version 7.0

<#
.SYNOPSIS
    Updates AI tools (claude, opencode, pi, graphify, rtk) and their plugins/extensions.

.DESCRIPTION
    Windows counterpart of ai-tools-update.sh. Each tool is updated only if it is installed.
    A failed step does not stop the run; failures are listed at the end and the exit code is 1.

.PARAMETER DryRun
    Print the commands without running them.

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\Run-AIToolsUpdate.ps1 -DryRun
#>

[CmdletBinding()]
param (
    [Alias('h')]
    [switch]$Help,

    [switch]$DryRun
)

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    return
}

$failed = [System.Collections.Generic.List[string]]::new()

function Has([string]$Name) { [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Section([string]$Name) { Write-Host "`n==> $Name" -ForegroundColor Cyan }

# Run "<exe> <args>", print it, record failures (non-zero exit code)
function Run([string]$Exe, [string[]]$Arguments) {
    Write-Host "  > $Exe $($Arguments -join ' ')"
    if ($DryRun) { return }
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  !! failed (exit $LASTEXITCODE)" -ForegroundColor Red
        $failed.Add("$Exe $($Arguments -join ' ')")
    }
}

if (Has claude) {
    Section 'claude'
    Run claude 'update'
    Run claude 'plugin', 'marketplace', 'update'
    foreach ($plugin in (claude plugin list --json 2>$null | ConvertFrom-Json).id) {
        Run claude 'plugin', 'update', $plugin
    }
}

if (Has opencode) {
    Section 'opencode'
    Run opencode 'upgrade'
    Run opencode 'plugin', 'update'
}

if (Has pi) {
    Section 'pi'
    Run pi 'update', '--all'
}

if (Has graphify) {
    Section 'graphify'
    if (Has uv) { Run uv 'tool', 'upgrade', 'graphifyy' }
    else { Write-Host '  uv not found - skipping package upgrade' }
}

if (Has rtk) {
    Section 'rtk'
    Run winget 'upgrade', '-e', '--id', 'rtk-ai.rtk'
}

Write-Host ''
if ($failed.Count -gt 0) {
    Write-Host 'Failures:' -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  - $_" }
    exit 1
}
Write-Host 'AI tools update done.' -ForegroundColor Green
