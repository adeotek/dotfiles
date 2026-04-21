#requires -Version 7.0

<#
.SYNOPSIS
    Finds enabled Windows Firewall rules matching a given port number.

.DESCRIPTION
    Queries enabled Windows Firewall rules and returns those whose local or remote port
    filter matches the specified port number. Optionally includes rules where the port
    is set to 'Any'.

    Each matching rule is retrieved in a single pass — port and address filters are fetched
    once per rule rather than twice.

.PARAMETER Port
    The port number to search for (1-65535).

.PARAMETER IncludeAny
    When specified, also includes rules where the local or remote port is 'Any'.

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\Get-WinFirewallRuleByPort.ps1 -Port 443

.EXAMPLE
    .\Get-WinFirewallRuleByPort.ps1 -Port 3389 -IncludeAny
#>

[CmdletBinding()]
param (
    [Alias('h')]
    [switch]$Help,

    [Parameter(Mandatory)]
    [ValidateRange(1, 65535)]
    [int]$Port,

    [switch]$IncludeAny
)

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

$portStr = [string]$Port

$results = Get-NetFirewallRule -Enabled True | ForEach-Object {
    $rule        = $_
    $portFilter  = $rule | Get-NetFirewallPortFilter
    $localMatch  = $portFilter.LocalPort  -contains $portStr
    $remoteMatch = $portFilter.RemotePort -contains $portStr

    if ($IncludeAny) {
        $localMatch  = $localMatch  -or $portFilter.LocalPort  -eq 'Any'
        $remoteMatch = $remoteMatch -or $portFilter.RemotePort -eq 'Any'
    }

    if ($localMatch -or $remoteMatch) {
        $addressFilter = $rule | Get-NetFirewallAddressFilter
        [PSCustomObject]@{
            DisplayName   = $rule.DisplayName
            Direction     = $rule.Direction
            Action        = $rule.Action
            LocalPort     = $portFilter.LocalPort  -join ','
            RemotePort    = $portFilter.RemotePort -join ','
            Protocol      = $portFilter.Protocol
            RemoteAddress = $addressFilter.RemoteAddress -join ','
            LocalAddress  = $addressFilter.LocalAddress  -join ','
            Enabled       = $rule.Enabled
            Profile       = $rule.Profile
            Name          = $rule.Name
        }
    }
} | Where-Object { $_ }

if (-not $results) {
    Write-Host "No enabled firewall rules found for port $Port." -ForegroundColor Yellow
} else {
    $results | Format-Table -AutoSize -Property DisplayName, Direction, Action, LocalPort, RemoteAddress, Protocol, Enabled
}
