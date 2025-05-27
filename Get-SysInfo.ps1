
$computerName = $env:COMPUTERNAME
$scriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition
$localFile    = Join-Path $scriptDir "$computerName.txt"
$sharePath    = "\\192.168.168.10\InfoEquipos"
$shareFile    = Join-Path $sharePath "$computerName.txt"


$output = @()
$output += "=== INFORMACION DEL SISTEMA ==="
$output += "Nombre del equipo      : $computerName"
try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $output += "SO                     : $($os.Caption) (Ver $($os.Version))"
} catch {
    $output += "SO                     : Error al obtener datos"
}
$output += "Usuario en sesion      : $env:USERNAME"
$output += ""
$output += "=== CONFIGURACION IP DE WINDOWS ==="
try {
    
    $ipLines = ipconfig /all | Out-String -Stream
    $output += $ipLines
} catch {
    $output += "Error al ejecutar ipconfig: $_"
}


try {
    $output | Out-File -FilePath $localFile -Encoding UTF8 -Force -ErrorAction Stop
} catch { }


if (Test-Path $sharePath) {
    try {
        $output | Out-File -FilePath $shareFile -Encoding UTF8 -Force -ErrorAction Stop
    } catch { }
}

