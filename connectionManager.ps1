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

$choise = (Read-Host "selezionare il numero scelto") - 1

try {
    if ( ($choice -ge 0) -and ($choice -lt $connections.Length) ){
        Write-Host "test"
        connect -JSON $connections.GetValue($choise)
    }else{
        Write-Host "Si e' verificato un errore durante l'accesso all'elemento, l'elemento $choise non esiste"
    }
}
catch {
    Write-Host "Si e' verificato un errore durante l'elaborazione dell'oggetto JSON: " 
    Write-Error $_
}