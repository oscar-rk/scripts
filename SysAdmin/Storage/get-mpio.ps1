# Get the list of all MPIO disks
$mpioDisks = mpclaim -s -d
mpclaim -s -d

# Check if there are any results
if ($mpioDisks -and $mpioDisks.Length -gt 0) {
    foreach ($line in $mpioDisks) {
        # Look for lines containing MPIO disk info (example: "MPIO Disk0")
        if ($line -match "MPIO Disk(\d+)") {
            $diskId = $matches[1]

            # Run mpclaim -s -d <diskId> to get detailed information
            $diskDetails = mpclaim -s -d $diskId		

            # Search for the line containing the serial number (SN)
            foreach ($detailLine in $diskDetails) {
                if ($detailLine -match "SN:\s*(\S+)") {
                    $serialNumber = $matches[1]
                    Write-Host "MPIO Disk$diskId - Serial Number (SN): $serialNumber"
                    break
                }
            }
        }
    }
} else {
    Write-Host "No MPIO disks found."
}
