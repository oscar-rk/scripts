$serverList = Get-Content -Path "servers.txt"
$outputFile = New-Item -ItemType File -Path "log$(Get-Date -Format ddMMyyyy_HHmmss).txt" -ErrorAction SilentlyContinue

Clear-Host

Write-Host "Created log $outputFile`n"

& {
    foreach ($server in $serverList) {
        try {
            $session = New-PSSession -ComputerName $server -ErrorAction Stop
            Write-Host "Connected to $server"
            
            Invoke-Command -Session $session -ScriptBlock {
                $localUser = net user [Your User Goes Here]
                if ($localUser) {
                    #net user UserToDelete /delete
                    Write-Output "$($env:COMPUTERNAME): User deleted`n"
                } else {
                    Write-Output "$($env:COMPUTERNAME): User does not exist`n"
                }
            } 4>&1
        }
        catch {
            Write-Output "`nFailed to connect to $server - $_`n"
        }
        finally {
            if ($session) {
                Remove-PSSession -Session $session
            }
        }
        Start-Sleep -Seconds 2
    }
} | Tee-Object -FilePath "$outputFile" -Append

Write-Host "`nCheck log $outputFile to see result for every computer`n"