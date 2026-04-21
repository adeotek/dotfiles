#requires -Version 7.0

<#
.SYNOPSIS
    Adds an inbound TCP firewall rule on Windows.

.DESCRIPTION
    Creates a new inbound TCP Windows Firewall rule that allows traffic on a local port
    from a specified remote address. Requires administrator privileges.

.PARAMETER Name
    The display name for the new firewall rule.

.PARAMETER Port
    The local TCP port number to allow (1-65535).

.PARAMETER RemoteAddress
    The remote IP address, CIDR range, or 'Any' to match all remote addresses.

.PARAMETER Description
    An optional description stored with the firewall rule.

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\Add-WinFirewallRule.ps1 -Name "SQL Server" -Port 1433 -RemoteAddress "10.0.0.0/8"

.EXAMPLE
    .\Add-WinFirewallRule.ps1 -Name "Dev Web App" -Port 8080 -RemoteAddress Any -Description "Local dev server"
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Alias('h')]
    [switch]$Help,

    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [ValidateRange(1, 65535)]
    [int]$Port,

    [Parameter(Mandatory)]
    [string]$RemoteAddress,

    [string]$Description = ""
)

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

New-NetFirewallRule `
    -DisplayName $Name `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort $Port `
    -Action Allow `
    -RemoteAddress $RemoteAddress `
    -Description $Description
