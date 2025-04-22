<#
    .SYNOPSIS
        This script will get and import device hardware ID to Intune tenant automatically.
        Intune Administrator credentials with permissions will be required, check Graph API permissions for Intune.
        Use startImport.bat to call this script from a privileged CMD console in order to avoid policy and/or permission prompts.
    .DEPENDENCIES
        CMD, PowerShell
        https://www.nuget.org/ (installed automatically by the script).
        https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo (installed automatically by the script).
        https://github.com/okieselbach/Intune/blob/master/Get-WindowsAutoPilotInfo.ps1 (installed automatically by the script).
    .AUTHOR
        oscar-rk - https://github.com/oscar-rk
#>

# Global variables
# Define here as many variables needed for your tenant infraestructure (Group Tag, Profile, User, etc.) and use them with Get-WindowsAutoPilotInfo.ps1, check example below.
# $groupTag = "Test"

# Import HWID to Intune
function importHWID(){
    try{
        Write-Host "`n[+] Importing HWID to Intune" -foregroundcolor Yellow
        Get-WindowsAutoPilotInfo.ps1 -Online -GroupTag $groupTag -Assign # <- -Assign will wait until Profile is assigned (currently will take between 5 and 15 minutes), remove it if don't need to wait.
    }
    catch{
        Write-Host "`n[!] Error: Could not import HWID to Intune" -foregroundcolor Red
    break}
}

# Install dependencies
function dependencies{
    try{
        Write-Host "`n[+] Installing dependencies" -foregroundcolor Yellow
        Install-PackageProvider -Name NuGet -Force
        Install-Module WindowsAutopilotIntune -Force 
        Install-Script Get-WindowsAutoPilotInfo -Force
    }
    catch{
        Write-Host "`n[!] Error: Could not install dependencies" -foregroundcolor Red
    break}
}

# --- Execution starts here ---
$Host.UI.RawUI.WindowTitle = "Intune HWID import"
Clear-Host

# Ensure that TLS 1.2 is being used (https://docs.microsoft.com/en-us/powershell/module/packagemanagement/?view=powershell-7.2)
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Call functions
dependencies
importHWID

# Done - Restarting
Write-Host "[+] HWID Imported, Profile + Group assigned succesfully, ready to start deployment" -foregroundcolor Green
Write-Host "[+] Restarting computer ..." -foregroundcolor Yellow
Sleep 5
Restart-Computer