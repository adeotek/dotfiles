#Requires -Version 7.0
<#
.SYNOPSIS
    Sets up a local Windows development environment from a configuration file.

.DESCRIPTION
    Reads a YAML or JSON configuration file that declares tasks and managed apps,
    then executes each active task using the appropriate package manager (winget,
    npm, or PowerShell modules).

    Configuration file resolution order (first match wins):
      1. <ScriptDir>\<COMPUTERNAME>-config.{yml,yaml,json,jsonc}
      2. <ScriptDir>\win-env-config.{yml,yaml,json,jsonc}

    Task types supported: winget, npm, powershell-module, tf-install

    YAML support requires the 'powershell-yaml' module.

.PARAMETER configFile
    Path to the configuration file. Defaults to auto-discovery based on
    computer name, falling back to "win-env-config.json" in the script directory.

.PARAMETER task
    Name of a specific task to run. When specified, IsActive is ignored and only
    the named task executes.

.PARAMETER Help
    Display this help message and exit.

.EXAMPLE
    .\Run-LocalWinEnvSetup.ps1
    Auto-discovers the config file and runs all active tasks.

.EXAMPLE
    .\Run-LocalWinEnvSetup.ps1 -configFile .\my-config.yml
    Runs all active tasks from the specified config file.

.EXAMPLE
    .\Run-LocalWinEnvSetup.ps1 -task "Install Dev Tools"
    Runs only the task named "Install Dev Tools", regardless of IsActive.

.NOTES
    Requires PowerShell 7.0 or later.
#>
Param (
    [Parameter(Mandatory=$false)][string]$configFile = ".",
    [Parameter(Mandatory=$false)][string]$task = "",
    [Alias('h')][switch]$Help
)

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

## Global variables
$mainColor    = "Cyan"
$commandColor = "Magenta"
$accentColor  = "Green"
$inputColor   = "Yellow"
$baseColor    = "White"
$startingPrefix = "-<"
$donePrefix     = "->"
$itemPrefix     = "---"
## END Global variables

function Write-Color {
    Param (
        [Parameter(Mandatory=$true)]$text,
        [Parameter(Mandatory=$false)]$color = "White"
    )

    if ($text -is [array] -and $color -is [array]) {
        for ($i = 0; $i -lt $text.count; $i++) {
            $iColor = if ($i -lt $color.count) { $color[$i] } else { "White" }
            if (($color.count - 1) -eq $i) {
                Write-Host $text[$i] -ForegroundColor $iColor
            } else {
                Write-Host $text[$i] -ForegroundColor $iColor -NoNewline
            }
        }
    } elseif ($color -is [array]) {
        $iColor = if ($color.count -gt 0) { $color[0] } else { "White" }
        Write-Host $text -ForegroundColor $iColor
    } else {
        Write-Host $text -ForegroundColor $color
    }
}

function ExitWithMessage {
    Param ([string]$message, [int]$exitCode)

    if ($exitCode -eq 1) {
        Write-Error "ERROR: $message"
        exit 1
    } else {
        Write-Color $message -Color Yellow
        exit 0
    }
}

function ReadConfigFile {
    Param ([string]$configFile)

    if (-not (Test-Path -Path $configFile -PathType Leaf)) {
        ExitWithMessage "No configuration file found ($configFile)" 1
    }

    $ext = [System.IO.Path]::GetExtension($configFile)
    if ($ext -in '.json', '.jsonc') {
        $config = Get-Content -Raw $configFile | ConvertFrom-Json
    } else {
        Import-Module powershell-yaml
        $config = Get-Content -Raw $configFile | ConvertFrom-Yaml
    }
    Write-Color "Configuration loaded from: ", $configFile -Color $Script:baseColor, $Script:mainColor

    if ($config.Tasks -is [object]) {
        $config.Tasks = @($config.Tasks)
    }

    if (-not ($config.Tasks -is [object[]]) -or $config.Tasks.length -eq 0) {
        ExitWithMessage "Invalid configuration file: No Tasks found!" 1
    }

    return $config
}

function Add-Env-Path {
    param (
        [Parameter(Mandatory, Position = 0)][string] $LiteralPath,
        [ValidateSet('User', 'CurrentUser', 'Machine', 'LocalMachine')][string] $Scope
    )

    Set-StrictMode -Version 1; $ErrorActionPreference = 'Stop'

    $isMachineLevel = $Scope -in 'Machine', 'LocalMachine'
    if ($isMachineLevel -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "You must run AS ADMIN to update the machine-level Path environment variable."
    }

    $regPath = 'registry::' + ('HKEY_CURRENT_USER\Environment', 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment')[$isMachineLevel]

    # Use .GetValue() to retrieve the unexpanded registry value (avoids resolving %vars%)
    $currDirs = (Get-Item -LiteralPath $regPath).GetValue('Path', '', 'DoNotExpandEnvironmentNames') -split ';' -ne ''

    if ($LiteralPath -in $currDirs) {
        Write-Color "INFO: ", "Already present in the persistent $(('user', 'machine')[$isMachineLevel])-level Path: $LiteralPath" -Color $Script:commandColor, $Script:baseColor
        return
    }

    $newValue = ($currDirs + $LiteralPath) -join ';'
    Set-ItemProperty -Type ExpandString -LiteralPath $regPath Path $newValue

    # Broadcast WM_SETTINGCHANGE so the Windows shell picks up the updated PATH
    $dummyName = [guid]::NewGuid().ToString()
    [Environment]::SetEnvironmentVariable($dummyName, 'foo', 'User')
    [Environment]::SetEnvironmentVariable($dummyName, [NullString]::value, 'User')

    $env:Path = ($env:Path -replace ';$') + ';' + $LiteralPath
    Write-Color "`"$LiteralPath`" successfully appended to the persistent $(('user', 'machine')[$isMachineLevel])-level Path and also the current-process value." -Color $Script:accentColor
}

function CreateAlias {
    Param ([string]$source, [string]$destination)

    # ~ maps to the user home directory, not AppData\Local
    if ($source.Contains("~")) {
        $source = $source.Replace("~", $env:USERPROFILE)
    }
    if (Test-Path -Path $destination -PathType Leaf) {
        return
    }
    New-Item -ItemType SymbolicLink -Path $destination -Target $source
    Write-Color "Alias created: ", $destination, " -> ", $source -Color $Script:baseColor, $Script:accentColor, $Script:baseColor, $Script:commandColor
}

function ExecuteWinGetTask {
    Param ([object[]]$task, [object[]]$managedApps)

    try {
        $action = $task.Action -eq "upgrade" ? "upgrade" : "install"
        Write-Color "$($Script:startingPrefix) Starting Task $($task.Name)", ": [", $task.Type, ":", $action, "]" -Color $Script:inputColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
        [System.Linq.Enumerable]::Where($managedApps, [Func[object,bool]]{ param($x) $x.Source -eq "winget" -and ($null -eq $x.IsActive -or $true -eq $x.IsActive) }) | ForEach-Object {
            $app = $_
            try {
                Write-Color "$($Script:itemPrefix)$($Script:startingPrefix) Starting ", "winget $action ", $app.Id, " -s winget" -Color $Script:inputColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
                winget $action $app.Id -s winget
                # Coerce single alias object or array of aliases into a uniform array
                if ($null -ne $app.CreateAlias) {
                    @($app.CreateAlias) | ForEach-Object {
                        CreateAlias $_.Source $_.Destination
                    }
                }
                Write-Color "$($Script:itemPrefix)$($Script:donePrefix) Done " -Color $Script:accentColor
            }
            catch {
                Write-Color "ERROR: ", "Executing winget $action ", $app.Id, " -s winget >> ", $_.Exception.Message -Color Red, $Script:baseColor, $Script:commandColor, $Script:baseColor, Red
            }
        }
        Write-Color "$($Script:donePrefix) Task $($task.Name) Executed", ": [", $task.Type, ":", $task.Action, "]" -Color $Script:accentColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
    }
    catch {
        Write-Color "ERROR: ", "Executing Task $($task.Name) [", $task.Type, ":", $action, "] >> ", $_.Exception.Message -Color Red, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, Red
    }
}

function ExecutePowershellModuleTask {
    Param ([object[]]$task, [object[]]$managedApps)

    try {
        $action = $task.Action -eq "upgrade" ? "Update-Module" : "Install-Module"
        Write-Color "$($Script:startingPrefix) Starting Task $($task.Name)", ": [", $task.Type, ":", $action, "]" -Color $Script:inputColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
        [System.Linq.Enumerable]::Where($managedApps, [Func[object,bool]]{ param($x) $x.Source -eq "powershell-module" -and ($null -eq $x.IsActive -or $true -eq $x.IsActive) }) | ForEach-Object {
            try {
                $flags = ""
                if ($action -eq "Install-Module" -and -not [string]::IsNullOrEmpty($_.Scope)) {
                    $flags = "$flags -Scope $($_.Scope)"
                }
                if ($action -eq "Install-Module" -and -not [string]::IsNullOrEmpty($_.Repository)) {
                    $flags = "$flags -Repository $($_.Repository)"
                }
                if ($action -eq "Install-Module" -and -not [string]::IsNullOrEmpty($_.InstallFlags)) {
                    $flags = "$flags $($_.InstallFlags)"
                }
                if (-not [string]::IsNullOrEmpty($_.Flags)) {
                    $flags = "$flags $($_.Flags)"
                }
                if ($action -eq "Install-Module" -and $_.Force -eq $true) {
                    $flags = "$flags -Force"
                }
                Write-Color "$($Script:itemPrefix)$($Script:startingPrefix) Starting ", "PowerShellGet\$action -Name ", $_.Id, $flags -Color $Script:inputColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
                Invoke-Expression "PowerShellGet\$action -Name $($_.Id) $flags"
                Write-Color "$($Script:itemPrefix)$($Script:donePrefix) Done " -Color $Script:accentColor
            }
            catch {
                Write-Color "ERROR: ", "Executing PowerShellGet\$action -Name ", $_.Id, " $flags >> ", $_.Exception.Message -Color Red, $Script:baseColor, $Script:commandColor, $Script:baseColor, Red
            }
        }
        Write-Color "$($Script:donePrefix) Task $($task.Name) Executed", ": [", $task.Type, ":", $task.Action, "]" -Color $Script:accentColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
    }
    catch {
        Write-Color "ERROR: ", "Executing Task $($task.Name) [", $task.Type, ":", $action, "] >> ", $_.Exception.Message -Color Red, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, Red
    }
}

function ExecuteNpmTask {
    Param ([object[]]$task, [object[]]$managedApps)

    try {
        $action = "npm install --global"
        Write-Color "$($Script:startingPrefix) Starting Task $($task.Name)", ": [", $task.Type, ":", $action, "]" -Color $Script:inputColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
        [System.Linq.Enumerable]::Where($managedApps, [Func[object,bool]]{ param($x) $x.Source -eq "npm" -and ($null -eq $x.IsActive -or $true -eq $x.IsActive) }) | ForEach-Object {
            try {
                Write-Color "$($Script:itemPrefix)$($Script:startingPrefix) Starting ", "$action ", $_.Id -Color $Script:inputColor, $Script:baseColor, $Script:commandColor
                Invoke-Expression "$action $($_.Id)"
                Write-Color "$($Script:itemPrefix)$($Script:donePrefix) Done " -Color $Script:accentColor
            }
            catch {
                Write-Color "ERROR: ", "Executing $action ", $_.Id, " >> ", $_.Exception.Message -Color Red, $Script:baseColor, $Script:commandColor, $Script:baseColor, Red
            }
        }
        Write-Color "$($Script:donePrefix) Task $($task.Name) Executed", ": [", $task.Type, ":", $task.Action, "]" -Color $Script:accentColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor
    }
    catch {
        Write-Color "ERROR: ", "Executing Task $($task.Name) [", $task.Type, ":", $action, "] >> ", $_.Exception.Message -Color Red, $Script:baseColor, $Script:commandColor, $Script:baseColor, $Script:commandColor, $Script:baseColor, Red
    }
}

function ExecuteTasks {
    Param ([object[]]$config, [string]$task)

    if ($config.ManagedApps -is [object]) {
        $managedApps = @($config.ManagedApps)
    } elseif ($config.ManagedApps -is [array]) {
        $managedApps = $config.ManagedApps
    } else {
        $managedApps = @()
    }

    for ($i = 0; $i -lt $config.Tasks.Count; $i++) {
        if ($null -ne $task -and $task -ne "" -and $config.Tasks[$i].Name -ne $task) {
            continue
        }
        if (($null -eq $task -or $task -eq "") -and -not ([bool]($config.Tasks[$i].IsActive))) {
            continue
        }
        $taskType = $null -eq $config.Tasks[$i].Type ? "" : $config.Tasks[$i].Type
        switch ($taskType.ToLower()) {
            "winget"            { ExecuteWinGetTask $config.Tasks[$i] $managedApps }
            "npm"               { ExecuteNpmTask $config.Tasks[$i] $managedApps }
            "powershell-module" { ExecutePowershellModuleTask $config.Tasks[$i] $managedApps }
            Default {
                Write-Color "ERROR: ", "Unknown Task type [", $taskType, "]" -Color Red, $Script:baseColor, $Script:commandColor, $Script:baseColor
            }
        }
    }
}

### MAIN
Write-Color "Starting..." -Color $mainColor

if ($configFile -eq ".") {
    $prefixes    = @($env:COMPUTERNAME, 'win-env')
    $extensions  = @('yml', 'yaml', 'json', 'jsonc')
    $configFile  = $null
    :discovery foreach ($prefix in $prefixes) {
        foreach ($ext in $extensions) {
            $candidate = Join-Path $PSScriptRoot "$prefix-config.$ext"
            if (Test-Path -Path $candidate -PathType Leaf) {
                $configFile = $candidate
                break discovery
            }
        }
    }
    if ($null -eq $configFile) {
        $configFile = Join-Path $PSScriptRoot "win-env-config.json"
    }
}

$config = ReadConfigFile $configFile
ExecuteTasks $config $task
Write-Color "`nDone!" -Color $baseColor
### END MAIN
