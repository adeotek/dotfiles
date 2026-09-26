#Requires -Version 7.0
<#
.SYNOPSIS
    Clear regenerable caches and reclaim disk space on Windows 11.

.DESCRIPTION
    Windows counterpart of tools/.tools/cache-clean.sh. Removes regenerable
    caches only (package managers, toolchains, editors, browsers, AI tools)
    plus stale Temp entries and old VS Code / Insiders / Cursor server
    instances. Anything that cannot be re-downloaded or rebuilt - configs,
    credentials, sessions, extensions, installed packages - is never touched,
    so this script is safe to run at any time.

    Covered by default:
      npm (+npx), pnpm, yarn, bun, NuGet/dotnet, pip, Go, cargo, Playwright,
      opencode, Pi, VS Code server instances (incl. Insiders/Cursor roots),
      VS Code / Cursor desktop caches, Windows Terminal + PowerShell caches,
      Chrome/Edge profile caches, pip/misc cache dirs, Temp leftovers.

    -Deep additionally:
      npx        - clear the whole npx cache (default: entries older than 7 days)
      go         - clear the module cache (default: build cache only)
      opencode   - clear all cached plugin packages (default: older than 7 days)
      playwright - remove all installed browsers (default: keep newest per family)
      electron / huggingface - clear entirely (default: entries older than 30 days)

    User-scope only: steps that need elevation are never attempted and never
    modify anything requiring admin rights.

.PARAMETER DryRun
    Show what would be cleaned, remove nothing.

.PARAMETER Deep
    Also run the deeper cleanups (documented above), still cache-only and safe.

.PARAMETER Verbose
    List every removed/kept item.

.PARAMETER Help
    Show this help and exit.

.EXAMPLE
    .\cache-clean.ps1 -DryRun
    Preview everything that is reclaimable, with sizes.

.NOTES
    Requires PowerShell 7.0 or later. No admin rights needed.
#>
Param (
    [switch]$DryRun,
    [switch]$Deep,
    [switch]$Verbose,
    [Alias('h')][switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

## Globals -------------------------------------------------------------------
$script:DryRun  = [bool]$DryRun
$script:Deep    = [bool]$Deep
$script:Vv      = [bool]$Verbose
$script:FreedKB = 0
$script:RemovedN = 0
$script:Errors  = 0

$Home_ = [System.Environment]::GetFolderPath('UserProfile')
if ([string]::IsNullOrEmpty($Home_) -or -not (Test-Path -LiteralPath $Home_ -PathType Container)) {
    Write-Error "refusing to run with unsafe USERPROFILE='$Home_'"
    exit 1
}
$LocalAppData = [System.Environment]::GetFolderPath('LocalApplicationData')

function Write-Color {
    Param ([string]$Text, [string]$Color = 'White')
    Write-Host $Text -ForegroundColor $Color
}

function Write-VerboseLog {
    if ($script:Vv) { Write-Color "  $Text" -Color Magenta }
}

## Safety guard for EVERY deletion: only paths under the user profile and
## %LOCALAPPDATA% may ever be removed. Nothing admin-scoped is attempted.
function Test-SafePath {
    Param ([string]$Path)
    if ([string]::IsNullOrEmpty($Path)) { return $false }
    $full = [System.IO.Path]::GetFullPath($Path).TrimEnd('\','/')
    return ($full.StartsWith($LocalAppData, [StringComparison]::OrdinalIgnoreCase) -or
            $full.StartsWith($Home_,      [StringComparison]::OrdinalIgnoreCase))
}

function Get-SizeKB {
    Param ([string]$Path)
    if ([string]::IsNullOrEmpty($Path) -or -not (Test-Path -LiteralPath $Path)) { return 0 }
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return [math]::Floor((Get-Item -LiteralPath $Path).Length / 1KB)
    }
    return [math]::Floor(((Get-ChildItem -LiteralPath $Path -Recurse -Force -File |
        Measure-Object -Property Length -Sum).Sum) / 1KB)
}

function Measure-Paths {
    Param ([string[]]$Paths)
    $total = 0
    foreach ($p in $Paths) { $total += Get-SizeKB -Path $p }
    return $total
}

function Format-KB {
    Param ([double]$KB)
    if ($KB -lt 1KB)   { return '{0} KB' -f [math]::Round($KB) }
    if ($KB -lt 1MB)   { return '{0:N1} MB' -f ($KB / 1KB) }
    return '{0:N2} GB' -f ($KB / 1MB)
}

# Running process named $Name -> section must be skipped.
function Test-ProcessRunning {
    Param ([string]$Name)
    return [bool](Get-Process -Name $Name -ErrorAction SilentlyContinue)
}

# True when any running process has the path on its command line - such items
# are kept (best effort): false positives only mean something gets kept.
function Test-PathInUse {
    Param ([string]$Path)
    try {
        $needle = $Path.ToLowerInvariant()
        foreach ($p in Get-CimInstance Win32_Process -Filter 'Name != "System Idle Process"') {
            if ($p.CommandLine -and $p.CommandLine.ToLowerInvariant().Contains($needle)) { return $true }
        }
    } catch { }
    return $false
}

function Write-Warn {
    Write-Color "  WARN: $($args[0])" -Color Red
    $script:Errors++
}

function Invoke-StepResult {
    # Shared bookkeeping for a single named action: prints freed size and
    # updates counters. $BeforeKB/$AfterKB choose between delta and full size.
    Param ([string]$Label, [double]$KB, [bool]$DryRunShown)
    if ($DryRun) {
        if ($KB -gt 0) {
            Write-Color ("  [$Label] (dry-run) up to {0} reclaimable" -f (Format-KB $KB)) -Color Yellow
            $script:FreedKB += $KB
        }
    } elseif (-not $DryRunShown -and $KB -gt 0) {
        $script:FreedKB += $KB
        Write-Color ("  [$Label] freed {0}" -f (Format-KB $KB)) -Color Green
    }
}

# Remove a directory/file with the standard bookkeeping. Returns $true on success.
function Remove-CachePath {
    Param ([string]$Path, [string]$Label)
    if ([string]::IsNullOrEmpty($Path)) { return $false }
    if (-not (Test-SafePath -Path $Path)) {
        Write-Warn "refusing to remove unsafe path: '$Path'"
        return $false
    }
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-VerboseLog "  absent, skipping: $Path"
        return $false
    }
    if (Test-PathInUse -Path $Path) {
        Write-VerboseLog "  in use by a running process, keeping: $Path"
        return $false
    }
    $kb = Get-SizeKB -Path $Path
    if ($script:DryRun) {
        Write-Color ("  DRY-RUN: Remove-Item '{0}'  ({1})" -f $Path, (Format-KB $kb)) -Color Yellow
    } else {
        try {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Warn "failed to remove '$Path': $($_.Exception.Message)"
            return $false
        }
        Write-Color ("  removed: {0}  ({1})" -f $Path, (Format-KB $kb)) -Color Green
    }
    $script:FreedKB += $kb
    $script:RemovedN++
    return $true
}

# Remove first-level entries of a directory older than $AgeMinutes.
function Remove-OldEntries {
    Param ([string]$Dir, [int]$AgeMinutes, [string]$Label, [switch]$ExcludeDot)
    if ([string]::IsNullOrEmpty($Dir) -or -not (Test-Path -LiteralPath $Dir -PathType Container)) {
        Write-VerboseLog "  [$Label] not present, skipping"
        return
    }
    $cutoff = (Get-Date).AddMinutes(-$AgeMinutes)
    $beforeKB = $script:FreedKB
    $beforeN  = $script:RemovedN
    foreach ($item in Get-ChildItem -LiteralPath $Dir -Force |
                        Where-Object { $_.LastWriteTime -lt $cutoff -and (-not $ExcludeDot -or $_.Name -notlike '.*') }) {
        Remove-CachePath -Path $item.FullName -Label $Label | Out-Null
    }
    $n = $script:RemovedN - $beforeN
    $freed = $script:FreedKB - $beforeKB
    $noun = if ($n -eq 1) { 'entry' } else { 'entries' }
    if ($n -eq 0) {
        Write-VerboseLog "  [$Label] nothing to remove"
    } elseif ($script:DryRun) {
        Write-Color ("  [$Label] would remove {0} {1} ({2})" -f $n, $noun, (Format-KB $freed)) -Color Green
    } else {
        Write-Color ("  [$Label] removed {0} {1} ({2})" -f $n, $noun, (Format-KB $freed)) -Color Green
    }
}

function Write-Section {
    Param ([string]$Title)
    Write-Host ''
    Write-Color "== $Title ==" -Color Blue
}

# Run a tool's own cache-clean via $Cmd (used for npm/pnpm/yarn/dotnet) with
# measure-before/after, falling back to deleting the cache dirs when the tool
# is missing (orphaned caches of an uninstalled tool are still regenerable).
function Invoke-ToolClean {
    Param ([string]$Tool, [string]$CleanCmd, [string[]]$CacheDirs, [string]$Label)
    if (Get-Command $Tool -ErrorAction SilentlyContinue) {
        $before = Measure-Paths -Paths $CacheDirs
        if ($script:DryRun) {
            Write-Color "  DRY-RUN: $CleanCmd" -Color Yellow
        } else {
            Write-VerboseLog "  `$ $CleanCmd"
            Invoke-Expression $CleanCmd 2>$null | Out-Null
        }
        $after = Measure-Paths -Paths $CacheDirs
        $delta = $before - $after
        if ($delta -gt 0) {
            $script:FreedKB += $delta
            Write-Color ("  [$Label] freed {0}" -f (Format-KB $delta)) -Color Green
        } elseif ($before -gt 0) {
            Write-Color "  [$Label] already clean" -Color Green
        } else {
            Write-VerboseLog "  [$Label] nothing to clean"
        }
    } else {
        foreach ($d in $CacheDirs) { Remove-CachePath -Path $d -Label $Label | Out-Null }
    }
}

# ============================================================================
# Steps
# ============================================================================

function Step-Node {
    Write-Section 'node package managers'

    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Invoke-ToolClean -Tool 'npm' -CleanCmd 'npm cache clean --force' -CacheDirs @("$LocalAppData\npm-cache") -Label 'npm'
        if (Test-Path -LiteralPath "$LocalAppData\npm-cache\_npx") {
            if ($script:Deep) {
                foreach ($e in Get-ChildItem -LiteralPath "$LocalAppData\npm-cache\_npx" -Directory) {
                    Remove-CachePath -Path $e.FullName -Label 'npx (all)' | Out-Null
                }
            } else {
                Remove-OldEntries -Dir "$LocalAppData\npm-cache\_npx" -AgeMinutes 10080 -Label 'npx (> 7d)' -ExcludeDot
            }
        }
    } else {
        Remove-CachePath -Path "$LocalAppData\npm-cache" -Label 'npm' | Out-Null
    }

    Invoke-ToolClean -Tool 'pnpm' -CleanCmd 'pnpm store prune' -CacheDirs @("$Home_\AppData\Local\pnpm\store") -Label 'pnpm'
    Invoke-ToolClean -Tool 'yarn' -CleanCmd 'yarn cache clean' -CacheDirs @("$Home_\AppData\Local\Yarn\Cache") -Label 'yarn'
    Invoke-ToolClean -Tool 'bun' -CleanCmd 'bun pm cache rm' -CacheDirs @("$Home_\.bun\install\cache") -Label 'bun'
}

function Step-NuGet {
    Write-Section 'nuget'
    Invoke-ToolClean -Tool 'dotnet' -CleanCmd 'dotnet nuget locals all --clear' `
        -CacheDirs @("$Home_\.nuget\packages", "$Home_\.local\share\NuGet", "$LocalAppData\NuGet\v3-cache") `
        -Label 'nuget'
}

function Step-Uv {
    Write-Section 'uv'
    Invoke-ToolClean -Tool 'uv' -CleanCmd 'uv cache clean' -CacheDirs @("$LocalAppData\uv\cache") -Label 'uv'
}

function Step-Pip {
    Write-Section 'pip'
    Invoke-ToolClean -Tool 'pip' -CleanCmd 'pip cache purge' -CacheDirs @("$LocalAppData\pip\cache") -Label 'pip'
}

function Step-Go {
    Write-Section 'go'
    if (Get-Command go -ErrorAction SilentlyContinue) {
        $buildCache = "$LocalAppData\go-build"
        $modCache   = "$Home_\go\pkg\mod"
        $before = Measure-Paths -Paths (@($buildCache) + $(if ($script:Deep) { @($modCache) } else { @() }))
        if ($script:DryRun) {
            Write-Color "  DRY-RUN: go clean -cache$(if ($script:Deep) { ' -modcache' })" -Color Yellow
        } else {
            $goArgs = '-cache'; if ($script:Deep) { $goArgs += ' -modcache' }
            Write-VerboseLog "  `$ go clean $goArgs"
            go clean $goArgs.Split(' ') 2>$null | Out-Null
        }
        $after = Measure-Paths -Paths (@($buildCache) + $(if ($script:Deep) { @($modCache) } else { @() }))
        $delta = $before - $after
        if ($delta -gt 0) {
            $script:FreedKB += $delta
            Write-Color ("  [go] freed {0}" -f (Format-KB $delta)) -Color Green
        } elseif ($before -gt 0) {
            Write-Color "  [go] already clean" -Color Green
        } else {
            Write-VerboseLog "  [go] nothing to clean"
        }
    } else {
        Remove-CachePath -Path "$LocalAppData\go-build" -Label 'go' | Out-Null
        Remove-CachePath -Path "$Home_\go\pkg\mod"      -Label 'go' | Out-Null
    }
}

function Step-Cargo {
    Write-Section 'rust'
    # The crate cache + extracted sources: rebuilt from the network next build.
    foreach ($d in @("$Home_\.cargo\registry\cache", "$Home_\.cargo\registry\src")) {
        Remove-CachePath -Path $d -Label 'cargo' | Out-Null
    }
}

function Step-Playwright {
    Write-Section 'playwright'
    $root = "$LocalAppData\ms-playwright"
    if (-not (Test-Path -LiteralPath $root)) { Write-VerboseLog '  not present, skipping'; return }
    if ($script:Deep) {
        # Re-install with: npx --yes playwright install chromium
        foreach ($e in Get-ChildItem -LiteralPath $root -Directory) {
            Remove-CachePath -Path $e.FullName -Label 'playwright (all)' | Out-Null
        }
        return
    }
    # Default: keep the most recent build of each browser family, drop stale ones.
    $entries   = @(Get-ChildItem -LiteralPath $root -Directory)
    $families  = @{}
    foreach ($e in $entries) {
        $fam = ($e.Name -replace '-[0-9.]+.*$', '')
        if (-not $families.ContainsKey($fam) -or $e.LastWriteTime -gt $families[$fam].LastWriteTime) {
            $families[$fam] = $e
        }
    }
    foreach ($e in $entries) {
        $fam = ($e.Name -replace '-[0-9.]+.*$', '')
        if ($families[$fam].FullName -eq $e.FullName) {
            Write-VerboseLog "  keep: $($e.FullName) (family $fam)"
        } else {
            Remove-CachePath -Path $e.FullName -Label 'playwright (stale)' | Out-Null
        }
    }
}

function Step-OpenCode {
    Write-Section 'opencode'
    $cacheDir = "$Home_\.cache\opencode"
    if (-not (Test-Path -LiteralPath $cacheDir)) { Write-VerboseLog '  not present, skipping'; return }
    if (Test-ProcessRunning -Name 'opencode') { Write-Color '  opencode is running, skipping' -Color Yellow; return }
    # Plugin packages are re-installed on demand; hidden entries are internal state.
    if ($script:Deep) {
        foreach ($e in Get-ChildItem -LiteralPath "$cacheDir\packages" -Directory | Where-Object { $_.Name -notlike '.*' }) {
            Remove-CachePath -Path $e.FullName -Label 'opencode packages (all)' | Out-Null
        }
    } else {
        Remove-OldEntries -Dir "$cacheDir\packages" -AgeMinutes 10080 -Label 'opencode packages (> 7d)' -ExcludeDot
    }
}

function Step-Pi {
    Write-Section 'pi'
    $installDir = "$Home_\.pi\agent\install"
    if (-not (Test-Path -LiteralPath $installDir)) { Write-VerboseLog '  install dir not present, skipping'; return }
    if (Test-ProcessRunning -Name 'pi') { Write-Color '  pi is running, skipping' -Color Yellow; return }

    $current = ''
    $cvFile = "$installDir\current-version"
    if (Test-Path -LiteralPath $cvFile -PathType Leaf) { $current = (Get-Content -LiteralPath $cvFile -TotalCount 1).Trim() }
    # Old managed releases: keep only the active one (launcher reads
    # install/current-version and executes install/releases/<version>).
    $releases = "$installDir\releases"
    if ($current -and (Test-Path -LiteralPath $releases)) {
        foreach ($rel in Get-ChildItem -LiteralPath $releases -Directory) {
            if ($rel.Name -ne $current) {
                Remove-CachePath -Path $rel.FullName -Label 'pi releases' | Out-Null
            } else {
                Write-VerboseLog "  keep: $($rel.FullName) (current)"
            }
        }
    }
    # Staged downloads are transient by design.
    if (Test-Path -LiteralPath "$installDir\staging") {
        foreach ($e in Get-ChildItem -LiteralPath "$installDir\staging" -Force) {
            Remove-CachePath -Path $e.FullName -Label 'pi staging' | Out-Null
        }
    }
    # NOTE: ~/.pi/agent/npm and ~/.pi/agent/git hold installed extensions -
    # deliberately never touched.
}

# Prune one VS Code server root: keep the newest (active) instance of each
# layout, drop older ones plus their launcher binaries/logs. Never touches
# data/ or extensions/ (user state). Running processes referencing a path
# keep it via the Test-PathInUse guard.
function Remove-VsCodeServerStale {
    Param ([string]$Root)
    $label = Split-Path $Root -Leaf
    $keep = @{}

    # Current layout: cli/servers/<Flavor>-<sha40>. Keep newest + lru.json entry.
    $serversDir = "$Root\cli\servers"
    if (Test-Path -LiteralPath $serversDir) {
        $instances = @(Get-ChildItem -LiteralPath $serversDir -Directory |
            Where-Object { $_.Name -match '^[A-Za-z][A-Za-z0-9]*-[0-9a-f]{40}$' })
        if ($instances.Count -gt 0) {
            $newest = $instances | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $keep[$newest.Name -replace '^.*-(.+)$', '$1'] = $true
            Write-VerboseLog "  keep: $($newest.FullName) (newest)"
            $lruFile = "$serversDir\lru.json"
            if (Test-Path -LiteralPath $lruFile) {
                $lru = ([regex]::Match((Get-Content -LiteralPath $lruFile -Raw), '"([^"]+)"')).Groups[1].Value
                if ($lru -and (Test-Path -LiteralPath "$serversDir\$lru")) {
                    $hash = $lru -replace '^.*-(.+)$', '$1'
                    if (-not $keep.ContainsKey($hash)) {
                        $keep[$hash] = $true
                        Write-VerboseLog "  keep: $serversDir\$lru (lru.json)"
                    }
                }
            }
            foreach ($i in $instances) {
                if (-not $keep.ContainsKey($i.Name -replace '^.*-(.+)$', '$1')) {
                    Remove-CachePath -Path $i.FullName -Label "$label server instances" | Out-Null
                }
            }
        }
    }

    # Legacy layout: bin/<sha40> - keep newest only.
    $binDir = "$Root\bin"
    if (Test-Path -LiteralPath $binDir) {
        $bins = @(Get-ChildItem -LiteralPath $binDir -Directory | Where-Object { $_.Name -match '^[0-9a-f]{40}$' })
        if ($bins.Count -gt 1) {
            $newestBin = $bins | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            foreach ($b in $bins) {
                if ($b.FullName -ne $newestBin.FullName) { Remove-CachePath -Path $b.FullName -Label "$label/bin instances" | Out-Null }
            }
        }
    }

    # Launcher binaries code-<sha>: keep those of kept instances and newest.
    if (Test-Path -LiteralPath $Root) {
        $launchers = @(Get-ChildItem -LiteralPath $Root -File | Where-Object { $_.Name -match '^code-[0-9a-f]{40}$' })
        if ($launchers.Count -gt 0) {
            $newestL = $launchers | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            foreach ($l in $launchers) {
                $h = $l.Name -replace '^code-', ''
                if (-not $keep.ContainsKey($h) -or $l.FullName -ne $newestL.FullName) {
                    if (-not $keep.ContainsKey($h)) { Remove-CachePath -Path $l.FullName -Label "$label launcher binaries" | Out-Null }
                }
            }
        }
        # Connection logs of removed instances + old server logs (14 days).
        foreach ($log in Get-ChildItem -LiteralPath $Root -File | Where-Object { $_.Name -match '^\.cli\.[0-9a-f]{40}\.log$' }) {
            $h = $log.Name -replace '^\.cli\.', '' -replace '\.log$', ''
            if (-not $keep.ContainsKey($h)) { Remove-CachePath -Path $log.FullName -Label "$label stale logs" | Out-Null }
        }
    }
    Remove-OldEntries -Dir "$Root\data\logs" -AgeMinutes 20160 -Label "$label logs (> 14d)"
}

function Step-VsCodeServers {
    Write-Section 'vs code server instances'
    foreach ($root in @("$Home_\.vscode-server", "$Home_\.vscode-server-insiders", "$Home_\.cursor-server")) {
        if (Test-Path -LiteralPath $root) { Remove-VsCodeServerStale -Root $root }
    }
}

function Step-EditorDesktop {
    Param ([string]$AppDir, [string]$AppName, [string]$ProcName)
    Write-Section "$AppName desktop caches"
    if (-not (Test-Path -LiteralPath $AppDir)) { Write-VerboseLog '  not present, skipping'; return }
    if (Test-ProcessRunning -Name $ProcName) { Write-Color "  $AppName is running, skipping" -Color Yellow; return }
    foreach ($d in @('Cache', 'CachedData', 'Code Cache', 'GPUCache', 'DawnGraphiteCache', 'DawnWebGPUCache', 'CachedExtensionVSIXs')) {
        Remove-CachePath -Path "$AppDir\$d" -Label $AppName | Out-Null
    }
    Remove-OldEntries -Dir "$AppDir\logs" -AgeMinutes 20160 -Label "$AppName logs (> 14d)"
}

function Step-MiscCaches {
    Write-Section 'other caches'
    # Regenerable per-user caches (full clear - they rebuild on next use).
    foreach ($d in @(
        "$LocalAppData\Microsoft\Windows\PowerShell\ModuleAnalysisCache",
        "$LocalAppData\Microsoft\windows\Explorer\thumbcache_*.db",
        "$LocalAppData\Microsoft\Windows\Explorer\iconcache_*.db"
    )) {
        Get-Item $d -ErrorAction SilentlyContinue | ForEach-Object { Remove-CachePath -Path $_.FullName -Label 'cache' | Out-Null }
    }

    # Download caches where old versions pile up: 30 days.
    if (Test-Path -LiteralPath "$LocalAppData\electron\Cache") {
        Remove-OldEntries -Dir "$LocalAppData\electron\Cache" -AgeMinutes 43200 -Label 'electron (> 30d)'
    }
    # NOTE: "~\.cache\huggingface\token" is a credential - never touched.
    $hf = "$LocalAppData\huggingface\hub"
    if (Test-Path -LiteralPath $hf) {
        if ($script:Deep) {
            foreach ($e in Get-ChildItem -LiteralPath $hf -Directory | Where-Object { $_.Name -notlike '.*' -and $_.Name -ne 'CACHEDIR.TAG' }) {
                Remove-CachePath -Path $e.FullName -Label 'huggingface hub (all)' | Out-Null
            }
        } else {
            Remove-OldEntries -Dir $hf -AgeMinutes 43200 -Label 'huggingface hub (> 30d)' -ExcludeDot
        }
    }
}

function Step-Browsers {
    # Chromium profile caches only (Cache, Code Cache, GPUCache) - cookies,
    # history, extensions and data are never touched. Skipped while running.
    foreach ($b in @(
        @{ Dir = "$LocalAppData\Google\Chrome\User Data";   Proc = 'chrome'; Name = 'Chrome' },
        @{ Dir = "$LocalAppData\Microsoft\Edge\User Data";  Proc = 'msedge'; Name = 'Edge' }
    )) {
        Write-Section "$($b.Name) caches"
        if (-not (Test-Path -LiteralPath $b.Dir)) { Write-VerboseLog '  not present, skipping'; continue }
        if (Test-ProcessRunning -Name $b.Proc) { Write-Color "  $($b.Name) is running, skipping" -Color Yellow; continue }
        $profiles = Get-ChildItem -LiteralPath $b.Dir -Directory | Where-Object { $_.Name -match '^(Default|Profile \d+)$' }
        foreach ($p in $profiles) {
            foreach ($d in @('Cache', 'Code Cache', 'GPUCache', 'Service Worker\CacheStorage')) {
                Remove-CachePath -Path "$($p.FullName)\$d" -Label $b.Name | Out-Null
            }
        }
    }
}

function Step-Temp {
    Write-Section 'temp leftovers'
    # %TEMP% entries older than 24h; some tools place session scratch there,
    # so only clearly stale entries are removed.
    Remove-OldEntries -Dir $env:TEMP -AgeMinutes 1440 -Label 'temp (> 24h)'
}

## Main ----------------------------------------------------------------------

Write-Color 'cache-clean - clearing regenerable caches' -Color Blue
if ($script:DryRun) { Write-Color 'DRY-RUN mode: nothing will be removed.' -Color Yellow }

$systemDrive = $env:SystemDrive
$availBefore = [double]((Get-PSDrive ($systemDrive.TrimEnd(':'))).Free / 1KB)

Step-Uv
Step-Node
Step-NuGet
Step-Pip
Step-Go
Step-Cargo
Step-Playwright
Step-OpenCode
Step-Pi
Step-VsCodeServers
Step-EditorDesktop -AppDir "$Home_\AppData\Roaming\Code"    -AppName 'VS Code' -ProcName 'Code'

Step-EditorDesktop -AppDir "$Home_\AppData\Roaming\Code"    -AppName 'VS Code' -ProcName 'Code'
Step-EditorDesktop -AppDir "$Home_\AppData\Roaming\Cursor"  -AppName 'Cursor'  -ProcName 'Cursor'
Step-EditorDesktop -AppDir "$Home_\AppData\Roaming\Code - Insiders" -AppName 'VS Code Insiders' -ProcName 'Code - Insiders'
Step-Browsers
Step-MiscCaches
Step-Temp

Write-Section 'summary'
$availAfter  = [double]((Get-PSDrive ($systemDrive.TrimEnd(':'))).Free / 1KB)
$availDelta  = $availAfter - $availBefore
if ($script:DryRun) {
    Write-Color ("Would free up to: {0}" -f (Format-KB $script:FreedKB)) -Color Green
} else {
    Write-Color ("Total freed: {0}" -f (Format-KB $script:FreedKB)) -Color Green
    if ($availDelta -gt 0) {
        Write-Color ("Disk space gained: {0} (available now {1})" -f (Format-KB $availDelta), (Format-KB $availAfter)) -Color Green
    }
}
if ($script:Errors -gt 0) {
    Write-Color "Completed with $script:Errors warning(s) - see messages above." -Color Yellow
}
if (-not $script:Deep) {
    Write-Color '-Deep also clears the full npx/opencode/playwright caches and the Go module cache.' -Color White
    Write-Color 'Use -DryRun first to preview.' -Color White
}
exit 0
