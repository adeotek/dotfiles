#requires -Version 7.0

<#
.SYNOPSIS
    Tests TCP connectivity to a remote host and port.

.DESCRIPTION
    Attempts to establish a TCP socket connection to the specified host and port,
    reporting whether the connection succeeded or failed. Resolves hostnames via DNS
    and uses the first returned address.

.PARAMETER TargetHost
    The hostname or IP address to probe.

.PARAMETER TargetPort
    The TCP port number to probe (1-65535).

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\Run-PortProbe.ps1 -TargetHost "myserver.example.com" -TargetPort 443

.EXAMPLE
    .\Run-PortProbe.ps1 -TargetHost localhost -TargetPort 8080
#>

[CmdletBinding()]
param (
    [Alias('h')]
    [switch]$Help,

    [Parameter(Mandatory)]
    [string]$TargetHost,

    [Parameter(Mandatory)]
    [ValidateRange(1, 65535)]
    [int]$TargetPort
)

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

function Invoke-PortProbe {
    param (
        [Parameter(Mandatory)]
        [string]$Hostname,

        [Parameter(Mandatory)]
        [int]$Port
    )

    $ipAddress = $null
    $socket    = $null

    try {
        $ipAddress = if ($Hostname.ToLower() -eq 'localhost') {
            [System.Net.IPAddress]::Parse('127.0.0.1')
        } else {
            $addresses = [System.Net.Dns]::GetHostAddresses($Hostname)
            if ($addresses.Count -eq 0) {
                throw [System.ArgumentException]::new("Unable to resolve host: $Hostname")
            }
            $addresses[0]
        }

        $socket = [System.Net.Sockets.Socket]::new(
            [System.Net.Sockets.AddressFamily]::InterNetwork,
            [System.Net.Sockets.SocketType]::Stream,
            [System.Net.Sockets.ProtocolType]::Tcp
        )
        $socket.Connect($ipAddress, $Port)
        $ipInfo = if ($ipAddress) { " (IP: $ipAddress)" } else { "" }
        Write-Host "Successfully connected to $Hostname$ipInfo on port $Port" -ForegroundColor Green
    }
    catch {
        $ipInfo = if ($ipAddress) { " (IP: $ipAddress)" } else { "" }
        Write-Host "Failed to connect to $Hostname$ipInfo on port $Port" -ForegroundColor Red
        Write-Host "-> $($_.Exception.Message)" -ForegroundColor Yellow
    }
    finally {
        if ($null -ne $socket) {
            $socket.Dispose()
        }
    }
}

Invoke-PortProbe -Hostname $TargetHost.Trim() -Port $TargetPort
