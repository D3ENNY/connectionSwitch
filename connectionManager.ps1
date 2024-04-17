function Configure-StaticSettings { param ([PSCustomObject]$config)
    $IPType = "IPv4"
    $adapter = Get-NetAdapter | ? { $_.Status -eq "up" }

    # Remove any existing IP and gateway from the IPv4 adapter
    if (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
        $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
    }
    if (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
    }

    # Configure the IP address and default gateway
    $adapter | New-NetIPAddress `
        -AddressFamily $IPType `
        -IPAddress $config.IP `
        -PrefixLength $config.MaskBits `
        -DefaultGateway $config.Gateway

    # Configure the DNS client server IP addresses
    $adapter | Set-DnsClientServerAddress -ServerAddresses ($config.PrimaryDns, $config.SecondaryDns)
}

function Configure-DHCPSettings {
    $IPType = "IPv4"
    $adapter = Get-NetAdapter | ? { $_.Status -eq "up" }
    $interface = $adapter | Get-NetIPInterface -AddressFamily $IPType

    # Remove existing gateway
    if (($interface | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $interface | Remove-NetRoute -Confirm:$false
    }

    # Enable DHCP
    $interface | Set-NetIPInterface -DHCP Enabled

    # Configure the DNS Servers automatically
    $interface | Set-DnsClientServerAddress -ResetServerAddresses
}

Clear-Host
# Read static JSON file
$config = Get-Content .\assets\config.json -Raw | ConvertFrom-Json
$staticSettings = $config.static_settings

$choice = Read-Host "Select network configuration:`n1. DHCP`n2. Static`nEnter your choice:"
Clear-Host

switch ($choice) {
    1 {
        Configure-DHCPSettings
        Write-Host "DHCP settings applied successfully."
    }
    2 {
        Write-Output "Select static configuration:"
        $staticSettings | ForEach-Object {
            Write-Output "$($staticSettings.IndexOf($_)+1). $($_.name)"
        }
        $staticChoice = Read-Host "Enter the number of the static configuration you want to apply:"
        Clear-Host

        if ($staticChoice -ge 1 -and $staticChoice -le $staticSettings.Count) {
                        Configure-StaticSettings -config $staticSettings[$staticChoice - 1]
            Write-Host "Static configuration '$($selectedStaticConfig.name)' applied successfully."
        } else {
            Write-Host "Invalid choice. Please enter a number corresponding to the static configuration you want to apply."
        }
    }
    default {
        Write-Host "Invalid choice. Please select either 1 or 2."
    }
}