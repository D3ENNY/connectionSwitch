function connect() { param([Parameter(Mandatory=$true)] [Object]$Json)
    Write-Host $Json
}

$connections = (Get-Content .\assets\config.json -Raw | ConvertFrom-Json).connections

Write-Output "A che rete LAN vuoi connetterti?"

foreach ($i in $connections) {
    foreach ($key in $i.PSObject.Properties.Name) {
        $cnt = $connections.IndexOf($i) + 1
        Write-Output "$cnt : $key"
    }
}

$choise = [Math]::Floor(((Read-Host "selezionare il numero scelto") - 1))
Write-Host $choise
try {
    if ( ($choise -ge 0) -and ($choise -lt ($connections.Length)) ){
        connect -JSON $connections.GetValue($choise)
    }else{
        Write-Host "Si e' verificato un errore durante l'accesso all'elemento, l'elemento $choise non esiste"
    }
}
catch {
    Write-Host "Si e' verificato un errore durante l'elaborazione dell'oggetto JSON: " 
    Write-Error $_
}