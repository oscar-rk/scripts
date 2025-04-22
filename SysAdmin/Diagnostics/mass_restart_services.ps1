$serviceName = "YourServiceName"
$computers = Get-Content -Path "servers.txt"

foreach ($computer in $computers) {
    Write-Host "Working on $computer"

    # Force stop
    Invoke-Command -ComputerName $computer -ScriptBlock {
        Param($serviceName)
        Stop-Service -Name $serviceName -Force
    } -ArgumentList $serviceName

    # Wait until service stops
    Start-Sleep -Seconds 5

    # Start service
    Invoke-Command -ComputerName $computer -ScriptBlock {
        Param($serviceName)
        Start-Service -Name $serviceName
    } -ArgumentList $serviceName
}