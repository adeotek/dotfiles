#requires -Version 7.0

<#
.SYNOPSIS
    Starts a TCP or UDP port listener for network testing.

.DESCRIPTION
    Opens a TCP or UDP listener on the specified port. The listener stays active
    until you press Escape. Useful for verifying firewall rules and connectivity
    from remote hosts.

    Before starting, the script verifies the port is not already in use.

.PARAMETER TCPPort
    The TCP port number to listen on (1-65535).

.PARAMETER UDPPort
    The UDP port number to listen on (1-65535).

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\Run-PortListen.ps1 -TCPPort 8080

.EXAMPLE
    .\Run-PortListen.ps1 -UDPPort 514
#>

[CmdletBinding()]
param (
    [Alias('h')]
    [switch]$Help,

    [Parameter(ParameterSetName = 'TCP')]
    [ValidateRange(1, 65535)]
    [int]$TCPPort,

    [Parameter(ParameterSetName = 'UDP')]
    [ValidateRange(1, 65535)]
    [int]$UDPPort
)

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

if (-not $TCPPort -and -not $UDPPort) {
    Write-Error "You must specify either -TCPPort or -UDPPort."
    exit 1
}

function Invoke-Portlistener {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'TCP')]
        [ValidateRange(1, 65535)]
        [int]$TCPPort,

        [Parameter(ParameterSetName = 'UDP')]
        [ValidateRange(1, 65535)]
        [int]$UDPPort
    )

    if ($TCPPort) {
        # Suppress the GUI progress overlay while testing the port
        $prevProgress = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        $testResult = Test-NetConnection -ComputerName localhost -Port $TCPPort -WarningAction SilentlyContinue -ErrorAction Stop
        $ProgressPreference = $prevProgress

        if ($testResult.TcpTestSucceeded) {
            Write-Warning ("TCP Port {0} is already listening, aborting..." -f $TCPPort)
            return
        }
        Write-Host ("TCP port {0} is available, continuing..." -f $TCPPort) -ForegroundColor Green

        $ipendpoint = New-Object System.Net.IPEndPoint([ipaddress]::any, $TCPPort)
        $listener   = New-Object System.Net.Sockets.TcpListener $ipendpoint
        $listener.start()
        Write-Host ("Now listening on TCP port {0}, press Escape to stop listening" -f $TCPPort) -ForegroundColor Green
        while ($true) {
            if ($host.ui.RawUi.KeyAvailable) {
                $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
                if ($key.VirtualKeyCode -eq 27) {
                    $listener.stop()
                    Write-Host ("Stopped listening on TCP port {0}" -f $TCPPort) -ForegroundColor Green
                    return
                }
            }
        }
    }

    if ($UDPPort) {
        try {
            $UdpObject = New-Object System.Net.Sockets.UdpClient($UDPPort)
            $UdpObject.Connect('localhost', $UDPPort)
            $bytes = [System.Text.Encoding]::ASCII.GetBytes((Get-Date -UFormat '%Y-%m-%d %T'))
            [void]$UdpObject.Send($bytes, $bytes.Length)
            $UdpObject.Close()
            Write-Host ("UDP port {0} is available, continuing..." -f $UDPPort) -ForegroundColor Green
        }
        catch {
            Write-Warning ("UDP Port {0} is already listening, aborting..." -f $UDPPort)
            return
        }

        $endpoint  = New-Object System.Net.IPEndPoint([IPAddress]::Any, $UDPPort)
        $udpclient = New-Object System.Net.Sockets.UdpClient $UDPPort
        Write-Host ("Now listening on UDP port {0}, press Escape to stop listening" -f $UDPPort) -ForegroundColor Green
        while ($true) {
            if ($host.ui.RawUi.KeyAvailable) {
                $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
                if ($key.VirtualKeyCode -eq 27) {
                    $udpclient.Close()
                    Write-Host ("Stopped listening on UDP port {0}" -f $UDPPort) -ForegroundColor Green
                    return
                }
            }
            if ($udpclient.Available) {
                $content = $udpclient.Receive([ref]$endpoint)
                Write-Host "$($endpoint.Address.IPAddressToString):$($endpoint.Port) $([Text.Encoding]::ASCII.GetString($content))"
            }
        }
    }
}

if ($UDPPort) {
    Write-Host "Starting UDP $UDPPort port listener..." -ForegroundColor Green
    Invoke-Portlistener -UDPPort $UDPPort
} else {
    Write-Host "Starting TCP $TCPPort port listener..." -ForegroundColor Green
    Invoke-Portlistener -TCPPort $TCPPort
}
