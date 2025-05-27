
function Convert-PrefixLengthToSubnetMask {
    param (
        [int]$PrefixLength
    )
    try {
        $octetos = for ($i = 0; $i -lt 4; $i++) {
            $bits  = [Math]::Min([Math]::Max($PrefixLength - ($i * 8), 0), 8)
            $value = ((1 -shl $bits) - 1) -shl (8 - $bits)
            $value
        }
        return $octetos -join '.'
    }
    catch {
        Write-Warning "No se pudo convertir el prefijo ($PrefixLength) a mascara: $_"
        return ''
    }
}


$scriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition

$computerName = $env:COMPUTERNAME

$outputFile   = Join-Path $scriptDir "$computerName.txt"


$output = @()

$output += "=== INFORMACION DEL SISTEMA ==="
try {
    $output += "Nombre del equipo      : $computerName"
} catch {
    $output += "Error al obtener nombre del equipo: $_"
}

try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $output += "Sistema operativo      : $($os.Caption) (Version $($os.Version))"
} catch {
    $output += "Error al obtener sistema operativo: $_"
}

try {
    $user = $env:USERNAME
    $output += "Usuario en sesion      : $user"
} catch {
    $output += "Error al obtener usuario en sesion: $_"
}

$output += ""
$output += "=== INFORMACION DE RED ==="
try {
    $netConfigs = Get-NetIPConfiguration -ErrorAction Stop |
                  Where-Object { $_.IPv4Address -ne $null }

    foreach ($net in $netConfigs) {
        $iface = $net.InterfaceAlias
        $ip    = $net.IPv4Address.IPAddress
        $pref  = $net.IPv4Address.PrefixLength
        $mask  = Convert-PrefixLengthToSubnetMask -PrefixLength $pref
        $gw    = $net.IPv4DefaultGateway.NextHop

        $output += "Interfaz             : $iface"
        $output += "  Direccion IPv4     : $ip"
        $output += "  Mascara de subred  : $mask"
        $output += "  Puerta de enlace   : $gw"
        $output += "------------------------------------"
    }
} catch {
    $output += "Error al obtener configuracion de red: $_"
}

$output | ForEach-Object { Write-Host $_ }


try {
    $output | Out-File -FilePath $outputFile -Encoding UTF8 -Force
    Write-Host "`nDatos guardados en: ${outputFile}" -ForegroundColor Green
}
catch {
    Write-Warning "No se pudo escribir el archivo ${outputFile}: $_"
}
