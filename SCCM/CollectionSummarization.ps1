# ----------------------------------------------------------------------------------------------
# Trigger SCCM Deployment Summarization for a Specific Software and Action
# ----------------------------------------------------------------------------------------------

# Parameters received
Param (
    [Parameter(Mandatory = $true, Position = 0)] $Action,
    [Parameter(Mandatory = $true, Position = 1)] $Software
)

# SCCM configuration (customize with your environment's provider and site code)
$Global:ProviderMachineName = "YourSCCMProviderFQDN"
$Global:SiteCode = "YourSiteCode"

# Save the current prompt location to return to it later
$CurrentLocation = Get-Location

# Try to import Configuration Manager module
Try {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
} Catch {
    Write-Host "Could not import Configuration Manager module. Is the SCCM Console installed?"
}

# ----------------------------------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------------------------------

# Connect to the SCCM provider and mount the site drive
function Set-SCCMCli {
    $initParams = @{}
    # $initParams.Add("Verbose", $true)       # Uncomment to enable verbose logging
    # $initParams.Add("ErrorAction", "Stop")  # Uncomment to stop execution on error

    if ((Get-Module ConfigurationManager) -eq $null) {
        Try {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
        } Catch {
            Write-Host "Could not import Configuration Manager module."
        }
    }

    Try {
        if ((Get-PSDrive -Name $Global:SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
            New-PSDrive -Name $Global:SiteCode -PSProvider CMSite -Root $Global:ProviderMachineName @initParams
        }
    } Catch {
        Write-Host $_.Exception.Message
    }
}

# ----------------------------------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------------------------------

# Connect to SCCM
Set-SCCMCli
Set-Location "$($Global:SiteCode):\"

# Map of supported software actions to corresponding SCCM collection names
# Customize this section based on your actual collection naming convention
$SoftwareActions = @{
    "ExampleSoftware1" = @{
        "Install"   = "COLL_Install_ExampleSoftware1"
        "Uninstall" = "COLL_Uninstall_ExampleSoftware1"
    }
    "ExampleSoftware2" = @{
        "Install"   = "COLL_Install_ExampleSoftware2"
        "Uninstall" = "COLL_Uninstall_ExampleSoftware2"
    }
    # Add more software mappings as needed
}

# Validate the inputs and get the corresponding collection name
if ($SoftwareActions.ContainsKey($Software)) {
    if ($SoftwareActions[$Software].ContainsKey($Action)) {
        $CollectionName = $SoftwareActions[$Software][$Action]
    } else {
        throw "Summarization failed: Action '$Action' is not supported for software '$Software'. Manual handling required."
    }
} else {
    throw "Summarization failed: Software '$Software' is not configured for automation. Manual handling required."
}

# Trigger summarization for the selected collection
Invoke-CMDeploymentSummarization -CollectionName $CollectionName

# Return to the original prompt location
Set-Location $CurrentLocation
