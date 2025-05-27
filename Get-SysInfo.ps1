

function Convert-PrefixLengthToSubnetMask {
    param ([int]$PrefixLength)
    try {
        $octetos = for ($i = 0; $i -lt 4; $i++) {
            $bits  = [Math]::Min([Math]::Max($PrefixLength - ($i * 8), 0), 8)
            ((1 -shl $bits) - 1) -shl (8 - $bits)
        }
        return $octetos -join '.'
    }
    catch { return '' }
}


$computerName = $env:COMPUTERNAME
$sharePath    = "\\192.168.168.10\InfoEquipos"
$outputFile   = Join-Path $sharePath "$computerName.txt"


$output = @(
    "=== INFORMACION DEL SISTEMA ==="
    try { "Nombre del equipo      : $computerName" } catch { "Error nombre equipo: $_" }
    try { 
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        "SO: $($os.Caption) (Ver $($os.Version))"
    } catch { "Error SO: $_" }
    try { "Usuario en sesion      : $env:USERNAME" } catch { "Error usuario: $_" }
    ""
    "=== INFORMACION DE RED ==="
)
try {
    Get-NetIPConfiguration -ErrorAction Stop |
      Where-Object IPv4Address |
      ForEach-Object {
        $alias = $_.InterfaceAlias
        $ip    = $_.IPv4Address.IPAddress
        $pref  = $_.IPv4Address.PrefixLength
        $mask  = Convert-PrefixLengthToSubnetMask $pref
        $gw    = $_.IPv4DefaultGateway.NextHop

        $output += "Interfaz:    $alias"
        $output += "  IPv4:      $ip"
        $output += "  Mascara:   $mask"
        $output += "  Gateway:   $gw"
        $output += "-----------------------------"
      }
}
catch {
    $output += "Error red: $_"
}


if (Test-Path $sharePath) {
    try {
        $output | Out-File -FilePath $outputFile -Encoding UTF8 -Force -ErrorAction Stop
    } catch { }
} else {
    
}
