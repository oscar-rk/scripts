<#
    .SYNOPSIS
        This script will extract hardware ID and save it to a CSV file automatically.
        Created to be used for offline HWID extractions without need of network connection.
        Use startImport.bat to call this script from a privileged CMD console in order to avoid policy and/or permission prompts.
    .DEPENDENCIES
        CMD, PowerShell
        https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo (download .ps1 manually and place in the same directory as this script).
    .AUTHOR
        oscar-rk - https://github.com/oscar-rk
#>

# Global variables
# Define here as many variables needed for your tenant infraestructure (Group Tag, Profile, User, etc.) and use them with Get-WindowsAutoPilotInfo.ps1, check example below.
# $groupTag = "test"

# Extract HWID to CSV
function extractHWID(){
    try{
        Write-Host "`n[+] Extracting HWID to CSV" -foregroundcolor Yellow
        Get-WindowsAutoPilotInfo.ps1 -OutputFile AutoPilotHWID.csv -GroupTag $groupTag -Append #<- Will append new entries without overwriting the current CSV file. Useful when extracting multiple HWID's. Delete if not needed.
    }
    catch{
        Write-Host "`n[!] Error: Could not extract HWID to CSV" -foregroundcolor Red
    break}
}

# Check dependencies
function dependencies{
    if(Test-Path -Path ./Get-WindowsAutoPilotInfo.ps1 -PathType Leaf){
        Write-Host "`n[+] Dependencies detected" -foregroundcolor Yellow
    }else{
        throw "`n[!] Dependencies not detected"
    }
}

# --- Execution starts here ---
$Host.UI.RawUI.WindowTitle = "HWID extraction"
Clear-Host

# Call functions
dependencies
extractHWID

# Done - Exiting
Write-Host "`n[+] HWID Extracted" -foregroundcolor Green
Sleep 1
Write-Host "[+] Exiting script ..." -foregroundcolor Yellow
Sleep 1
Exit