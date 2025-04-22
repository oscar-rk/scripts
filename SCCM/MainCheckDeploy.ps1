# ----------------------------------------------------------------------------------------------
# Check server software deployment status in SCCM via WMI
# ----------------------------------------------------------------------------------------------

# Parameters received (e.g. from automation or orchestrator)
Param (
    [Parameter(Mandatory = $true, Position = 0)] $Action,
    [Parameter(Mandatory = $true, Position = 1)] $Server,
    [Parameter(Mandatory = $true, Position = 2)] $Software
)

# Function to retrieve deployment status for a given application and collection
function Check-DeployStatus {
    Param ( 
        [String] $Server,
        [String] $ApplicationName,
        [String] $CollectionName
    )

    # SCCM server and site configuration (adjust to your environment)
    $sccmServer = "YourSCCMServerName"
    $siteCode = "YourSiteCode"

    # Default return value
    $AppStatusType = "Unknown"

    # Retrieve deployment status from SCCM via WMI
    try {
        $assignment = Get-WmiObject -ComputerName $sccmServer -Namespace "root\sms\site_$($siteCode)" -Class SMS_ApplicationAssignment |
            Where-Object { $_.ApplicationName -eq $ApplicationName -and $_.CollectionName -eq $CollectionName }

        if ($assignment) {
            $assignmentId = $assignment.AssignmentID
            $query = "SELECT AppStatusType FROM SMS_AppDeploymentAssetDetails WHERE AssignmentID = '$assignmentId' AND MachineName = '$Server'"
            $result = Get-WmiObject -ComputerName $sccmServer -Namespace "root\sms\site_$($siteCode)" -Query $query | Select-Object -Unique

            if ($result) {
                switch ($result.AppStatusType) {
                    1 { $AppStatusType = 'Success' }
                    2 { $AppStatusType = 'InProgress' }
                    3 { $AppStatusType = 'Requirements Not Met' }
                    5 { $AppStatusType = 'Error' }
                }
            }
        }
    } catch {
        Write-Host "Error checking deployment status for '$ApplicationName' on '$Server': $($_.Exception.Message)"
    }

    return $AppStatusType
}

# ----------------------------------------------------------------------------------------------
# MAIN EXECUTION
# ----------------------------------------------------------------------------------------------

# Software-to-collection mapping (adjust to match your SCCM environment)
# Example only – this should be customized per organization
$SoftwareActions = @{
    "ExampleSoftware1" = @{
        "Install"   = "COLL_Install_ExampleSoftware1"
        "Uninstall" = "COLL_Uninstall_ExampleSoftware1"
    }
    "ExampleSoftware2" = @{
        "Install"   = "COLL_Install_ExampleSoftware2"
        "Uninstall" = "COLL_Uninstall_ExampleSoftware2"
    }
    # Add additional software entries as needed
}

# Validate the software and action against the mapping table
if ($SoftwareActions.ContainsKey($Software)) {
    if ($SoftwareActions[$Software].ContainsKey($Action)) {
        $collectionName = $SoftwareActions[$Software][$Action]
        $status = Check-DeployStatus -Server $Server -ApplicationName $Software -CollectionName $collectionName
    } else {
        throw "Unsupported action '$Action' for software '$Software'."
    }
} else {
    throw "Unsupported software '$Software'. Please check the mapping table."
}

# Output deployment status
Write-Host $status
