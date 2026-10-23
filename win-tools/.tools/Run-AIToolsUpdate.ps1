#requires -Version 7.0

<#
.SYNOPSIS
    Updates AI tools (claude, opencode, pi, graphify, rtk) and their plugins/extensions.

.DESCRIPTION
    Windows counterpart of ai-tools-update.sh. Each tool is updated only if it is installed.
    A failed step does not stop the run; failures are listed at the end and the exit code is 1.

.PARAMETER DryRun
    Print the commands without running them.

.PARAMETER FromSource
    Update rtk from the GitHub releases instead of winget. The latest release asset
    rtk-x86_64-pc-windows-msvc.zip is downloaded and its rtk.exe replaces the binary
    that is currently executed (e.g. the winget package binary), which is kept as
    rtk-old.exe. Use when the winget package lags behind the GitHub release.

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\Run-AIToolsUpdate.ps1 -DryRun

.EXAMPLE
    .\Run-AIToolsUpdate.ps1 -FromSource
    Updates rtk by downloading the latest binaries from GitHub instead of winget.
#>

[CmdletBinding()]
param (
    [Alias('h')]
    [switch]$Help,

    [switch]$DryRun,

    [switch]$FromSource
)

$script:failed = [System.Collections.Generic.List[string]]::new()

function Has([string]$Name) { [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Section([string]$Name) { Write-Host "`n==> $Name" -ForegroundColor Cyan }

# Run "<exe> <args>", print it, record failures (non-zero exit code)
function Run([string]$Exe, [string[]]$Arguments) {
    Write-Host "  > $Exe $($Arguments -join ' ')"
    if ($DryRun) { return }
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  !! failed (exit $LASTEXITCODE)" -ForegroundColor Red
        $script:failed.Add("$Exe $($Arguments -join ' ')")
    }
}

#region rtk from GitHub releases
$script:RtkApiUrl     = 'https://api.github.com/repos/rtk-ai/rtk/releases/latest'
$script:RtkAssetName  = 'rtk-x86_64-pc-windows-msvc.zip'
$script:RtkExeName    = 'rtk.exe'
$script:RtkBackupName = 'rtk-old.exe'

function Get-RtkExePath {
    <#
    Returns the full path of the rtk.exe that 'rtk' currently resolves to, following
    symlinks (winget installs a link into WinGet\Links). Replacing that file makes the
    downloaded build the one that actually runs.
    #>
    $command = Get-Command 'rtk' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $command) { return $null }

    $item = Get-Item -LiteralPath $command.Source
    if ($item.LinkType) {
        $target = $item.ResolveLinkTarget($true)
        if ($target) { $item = $target }
    }
    return $item.FullName
}

function Get-RtkVersion {
    <#
    Returns the version reported by '<exe> --version' as [version], or $null if the
    exe does not exist. Throws if the output is unparseable.
    #>
    param([string]$ExePath)

    if (-not (Test-Path -LiteralPath $ExePath)) { return $null }

    $output = & $ExePath --version 2>&1 | Out-String
    $match = [regex]::Match($output, '\b\d+\.\d+\.\d+\b')
    if (-not $match.Success) {
        throw "Could not parse a version from '$ExePath --version' output: $($output.Trim())"
    }
    return [version]$match.Value
}

function Test-RtkRunning {
    <#
    Returns $true if an rtk process is running from the given exe path
    (Windows locks a running exe against rename).
    #>
    param([string]$ExePath)

    $running = Get-Process -Name 'rtk' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -and $_.Path -eq $ExePath }
    return [bool]$running
}

function Get-LatestRtkRelease {
    <#
    Queries the GitHub API for the latest release and returns an object with
    Version ([version]) and Url (string) of the Windows x64 zip asset.
    #>
    $release = Invoke-RestMethod -Uri $script:RtkApiUrl -Headers @{ 'User-Agent' = 'Run-AIToolsUpdate' }

    $tagText = $release.tag_name -replace '^v', ''
    try {
        $version = [version]$tagText
    }
    catch {
        throw "Release tag '$($release.tag_name)' is not a valid version."
    }

    $asset = $release.assets | Where-Object { $_.name -eq $script:RtkAssetName } | Select-Object -First 1
    if (-not $asset) {
        throw "Release $($release.tag_name) does not contain asset '$($script:RtkAssetName)'."
    }

    return [PSCustomObject]@{
        Version = $version
        Url     = $asset.browser_download_url
    }
}

function Invoke-RtkFromSourceUpdate {
    <#
    Downloads the latest rtk Windows x64 zip from GitHub, verifies the binary and
    installs it over the currently executed rtk.exe (kept as rtk-old.exe).
    #>
    param([string]$TargetExe)

    if (-not $TargetExe) {
        $TargetExe = Get-RtkExePath
    }
    if (-not $TargetExe) {
        throw 'rtk is not installed - nothing to replace.'
    }
    $targetDir = Split-Path -Parent $TargetExe

    Write-Host "  target: $TargetExe"
    if ($DryRun) {
        Write-Host "  > download $($script:RtkAssetName) from GitHub releases and replace $($script:RtkExeName)"
        return
    }

    if (Test-RtkRunning -ExePath $TargetExe) {
        throw "$($script:RtkExeName) is running from $targetDir. Close all rtk/agent sessions and re-run."
    }

    $installed = Get-RtkVersion -ExePath $TargetExe

    Write-Host "  > GET $($script:RtkApiUrl)"
    $latest = Get-LatestRtkRelease
    if ($null -ne $installed) {
        Write-Host "  updating $installed -> $($latest.Version)"
    }
    else {
        Write-Host "  installing $($latest.Version)"
    }

    $workDir = Join-Path ([System.IO.Path]::GetTempPath()) "rtk-update-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null

    $backupExe = Join-Path $targetDir $script:RtkBackupName
    try {
        $zipPath = Join-Path $workDir $script:RtkAssetName
        Write-Host "  > download $($script:RtkAssetName)"
        Invoke-WebRequest -Uri $latest.Url -OutFile $zipPath

        $extractDir = Join-Path $workDir 'extract'
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir

        $stagedExe = Get-ChildItem -LiteralPath $extractDir -Recurse -Filter $script:RtkExeName -File | Select-Object -First 1
        if (-not $stagedExe) {
            throw "Downloaded archive does not contain $($script:RtkExeName)."
        }

        Write-Host '  verifying downloaded binary'
        $downloaded = Get-RtkVersion -ExePath $stagedExe.FullName
        if ($downloaded -ne $latest.Version) {
            throw "Downloaded binary reports version $downloaded, expected $($latest.Version)."
        }

        # Swap: keep the previous binary as rtk-old.exe, drop the new one in place
        if (Test-Path -LiteralPath $backupExe) { Remove-Item -LiteralPath $backupExe -Force }
        if (Test-Path -LiteralPath $TargetExe) {
            Rename-Item -LiteralPath $TargetExe -NewName $script:RtkBackupName
            Write-Host "  kept previous binary as $($script:RtkBackupName)"
        }
        Move-Item -LiteralPath $stagedExe.FullName -Destination $TargetExe
    }
    catch {
        # Roll back if the previous binary was already moved aside
        if ((Test-Path -LiteralPath $backupExe) -and -not (Test-Path -LiteralPath $TargetExe)) {
            try { Rename-Item -LiteralPath $backupExe -NewName $script:RtkExeName } catch {}
        }
        throw
    }
    finally {
        if (Test-Path -LiteralPath $workDir) {
            Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    $final = Get-RtkVersion -ExePath $TargetExe
    if ($final -ne $latest.Version) {
        throw "Installed binary reports version $final, expected $($latest.Version). Previous binary is at $backupExe."
    }
    Write-Host "  rtk $final installed in $targetDir" -ForegroundColor Green
}
#endregion

# Dot-sourcing defines the functions only (used for testing); the update run is skipped.
if ($MyInvocation.InvocationName -ne '.') {
    if ($Help) {
        Get-Help $PSCommandPath -Detailed
        return
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

    if (Has moca) {
        Section 'moca'
        Run moca 'update'
    }

    if (Has graphify) {
        Section 'graphify'
        if (Has uv) { Run uv 'tool', 'upgrade', 'graphifyy' }
        else { Write-Host '  uv not found - skipping package upgrade' }
    }

    if (Has rtk) {
        Section 'rtk'
        if ($FromSource) {
            try {
                Invoke-RtkFromSourceUpdate -TargetExe (Get-RtkExePath)
            }
            catch {
                Write-Host "  !! $($_.Exception.Message)" -ForegroundColor Red
                $script:failed.Add("rtk from source: $($_.Exception.Message)")
            }
        }
        else {
            Run winget 'upgrade', '-e', '--id', 'rtk-ai.rtk'
        }
    }

    Write-Host ''
    if ($script:failed.Count -gt 0) {
        Write-Host 'Failures:' -ForegroundColor Red
        $script:failed | ForEach-Object { Write-Host "  - $_" }
        exit 1
    }
    Write-Host 'AI tools update done.' -ForegroundColor Green
}
