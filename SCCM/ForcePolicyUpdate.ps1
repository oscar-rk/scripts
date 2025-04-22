# Parameters received
Param (
    [Parameter(Mandatory=$true,Position=0)]$Server
)

# Machine Policy Retrieval & Evaluation Cycle
Try {
    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"
    Start-Sleep -Seconds 5
    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"
} Catch {
    Write-Host "Could not force Configuration Manager reevaluation on $Server - "$_.Exception.Message
}
