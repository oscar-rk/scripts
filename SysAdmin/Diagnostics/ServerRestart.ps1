# ----------------------------------------------------------------------------------------------
# Graceful server restart
# ----------------------------------------------------------------------------------------------

Param (
    [Parameter(Mandatory=$true,Position=0)]$Server
)

# Animation
$animation = @('|', '/', '-', '\')

Function Show-Animation {
    foreach ($frame in $animation) {
        Write-Host -NoNewline $frame
        Start-Sleep -Milliseconds 200
        Write-Host -NoNewline "`b"
    }
}

Write-Host "Restarting server $Server..."

Try {
    # Show loading animation
    $animationProcess = Start-Job -ScriptBlock { Show-Animation }

    # Proceed with restart
    Restart-Computer -ComputerName $Server -Wait -For Powershell -Timeout 300 -Delay 10

    # Stop when restart is done
    Stop-Job -Job $animationProcess
    Remove-Job -Job $animationProcess

} Catch {
    Stop-Job -Job $animationProcess
    Remove-Job -Job $animationProcess
    Write-Host "Error restarting server $Server - "$_.Exception.Message
}
