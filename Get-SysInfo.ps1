

function Convert-PrefixLengthToSubnetMask {
    param ([int]$PrefixLength)
    try {
        $octetos = for ($i = 0; $i -lt 4; $i++) {
            $bits  = [Math]::Min([Math]::Max($PrefixLength - ($i * 8), 0), 8)
            ((1 -shl $bits) - 1) -shl (8 - $bits)
        }
        return $octetos -join '.'
    } catch {
        return ''
    }
}


$computerName = $env:COMPUTERNAME
$localPath    = 'C:\Tisa'
$localFile    = Join-Path $localPath "$computerName.txt"
$sharePath    = '\\192.168.168.10\InfoEquipos'
$shareFile    = Join-Path $sharePath "$computerName.txt"


$output = @()
$output += '=== INFORMACION DEL SISTEMA ==='
$output += "Nombre del equipo      : $computerName"
try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $output += "SO                     : $($os.Caption) (Ver $($os.Version))"
} catch {
    $output += 'SO                     : Error al obtener datos'
}
$output += "Usuario en sesion      : $env:USERNAME"
$output += ''
$output += '=== CONFIGURACION IP DE WINDOWS (ipconfig /all) ==='

try {
    $ipText = ipconfig /all | Out-String
    $output += $ipText -split "`r?`n"
} catch {
    $output += "Error al ejecutar ipconfig /all: $_"
}


try {
    $output | Out-File -FilePath $localFile -Encoding UTF8 -Force -ErrorAction Stop
} catch { }


if (Test-Path $sharePath) {
    try {
        $output | Out-File -FilePath $shareFile -Encoding UTF8 -Force -ErrorAction Stop
    } catch { }
}

