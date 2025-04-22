<#
.SYNOPSIS
   Retrieves disk information from the local system using WMI.
.DESCRIPTION
   Gathers disk, partition, and volume details from the local machine.
   Formats sizes in KB/MB/GB for readability and exports selected data to CSV.
#>

# ===== CONFIGURABLE VARIABLES =====
$BaseLogPath = "C:\Logs\DiskInfo\"                         # Path for execution logs
$BaseCsvPath = "C:\Reports\Disks\"                         # Path for CSV output (change to a UNC path if needed)
$TempPath = "C:\Temp\"                                     # Optional local temp path

# ===== INIT VARIABLES =====
$currentDate = Get-Date -Format "yyyyMMdd-HHmmss"
$computerName = $env:COMPUTERNAME
$logName = "DiskInfo_$computerName_$currentDate.log"
$csvName = "$computerName" + "_" + "$currentDate.csv"

# ===== CREATE PATHS IF NEEDED =====
New-Item -ItemType Directory -Path $BaseLogPath -Force | Out-Null
New-Item -ItemType Directory -Path $BaseCsvPath -Force | Out-Null

# ===== START LOGGING =====
Start-Transcript -Path (Join-Path $BaseLogPath $logName) -Append > $null

# ===== FUNCTION: Convert bytes to readable size =====
Function ConvertTo-KMG {
    Param (
        [long]$bytecount
    )
    switch ([math]::truncate([math]::log($bytecount, 1024))) {
        0 { "$bytecount Bytes" }
        1 { "{0:n2} KB" -f ($bytecount / 1kb) }
        2 { "{0:n2} MB" -f ($bytecount / 1mb) }
        3 { "{0:n2} GB" -f ($bytecount / 1gb) }
        4 { "{0:n2} TB" -f ($bytecount / 1tb) }
        Default { "{0:n2} PB" -f ($bytecount / 1pb) }
    }
}

# ===== MAIN: Get disk info via WMI =====
try {
    $DiskDrives = Get-WmiObject -Class Win32_DiskDrive

    foreach ($Drive in $DiskDrives) {
        $PartitionQuery = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($Drive.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
        $Partitions = @(Get-WmiObject -Query $PartitionQuery)

        foreach ($Partition in $Partitions) {
            $LogicalDiskQuery = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($Partition.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"
            $LogicalDisks = @(Get-WmiObject -Query $LogicalDiskQuery)

            foreach ($LogicalDisk in $LogicalDisks) {
                $PercentFree = [math]::Round(($LogicalDisk.FreeSpace / $LogicalDisk.Size) * 100, 2)
                $UsedSpace = ($LogicalDisk.Size - $LogicalDisk.FreeSpace)

                # Build export object
                $exportObj = [PSCustomObject]@{
                    ComputerName  = $computerName
                    Model         = $Drive.Model
                    Partition     = $Partition.Name
                    VolumeName    = $LogicalDisk.VolumeName
                    Drive         = $LogicalDisk.Name
                    DiskSize      = ConvertTo-KMG -bytecount $LogicalDisk.Size
                    FreeSpace     = ConvertTo-KMG -bytecount $LogicalDisk.FreeSpace
                    UsedSpace     = ConvertTo-KMG -bytecount $UsedSpace
                    PercentFree   = "$PercentFree %"
                    PercentUsed   = "{0:n2} %" -f (100 - $PercentFree)
                    DiskType      = 'Partition'
                    SerialNumber  = $Drive.SerialNumber
                }

                # Export to CSV
                try {
                    $exportObj | Export-Csv -Path (Join-Path $BaseCsvPath $csvName) -NoTypeInformation -Append
                } catch {
                    Write-Warning "Error exporting to CSV: $_"
                }
            }
        }
    }

    Write-Output "Export completed successfully. CSV: $BaseCsvPath$csvName"
} catch {
    Write-Warning "Failed to collect disk information: $_"
}

# ===== STOP LOGGING =====
Stop-Transcript > $null
