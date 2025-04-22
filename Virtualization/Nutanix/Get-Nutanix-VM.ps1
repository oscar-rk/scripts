Clear-Host
Set-ExecutionPolicy Unrestricted

# Trust self-signed certificates
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# File locations for password, CSV, and logs
$pwdLocation     = "PathToEncryptedPasswordFiles"
$csvLocation     = "PathToCurrentCSVOutput"
$csvArchive      = "PathToArchivedCSVs"
$logLocation     = "PathToLogs"

# Date formatting for file names
$currentDate     = Get-Date
$logDate         = ((Get-Date -Format dd/MM/yyyy).split("/")) -join "-"

# Mark new execution in log
Write-Output "=========== New execution: $currentDate ===========" | Out-File -FilePath "$logLocation\log.txt" -Append

# Move old CSV files if they exist
try {
    $csvFiles = Get-ChildItem $csvLocation -Filter "*.csv" | Where-Object { $_.Name -like "*ReportFile*" }

    if ($csvFiles) {
        foreach ($file in $csvFiles) {
            $destination = Join-Path $csvArchive $file.Name

            # If a file with the same name exists, append a counter
            if (Test-Path $destination) {
                $baseName = $file.BaseName
                $extension = $file.Extension
                $counter = 1

                while (Test-Path $destination) {
                    $newName = "${baseName}_$counter$extension"
                    $destination = Join-Path $csvArchive $newName
                    $counter++
                }
            }

            Move-Item -Path $file.FullName -Destination $destination
        }

        Write-Output "$logDate - Moved old CSVs from $csvLocation to $csvArchive" | Out-File -FilePath "$logLocation\log.txt" -Append
    }
} catch {
    Write-Output "$logDate - Error moving old CSVs: $($_.Exception.Message)" | Out-File -FilePath "$logLocation\log.txt" -Append
}

# Generate new CSV with headers
try {
    "Date;Cluster;Host;VM;IP;OS;Memory;VCPU;Disks;State;" | Out-File -FilePath "$csvLocation\ReportFile_$logDate.csv" -Encoding UTF8 -Force
    Write-Output "$logDate - CSV header generated successfully" | Out-File -FilePath "$logLocation\log.txt" -Append
} catch {
    Write-Output "$logDate - Error generating CSV header: $($_.Exception.Message)" | Out-File -FilePath "$logLocation\log.txt" -Append
}

# ----------------- API connection setup ----------------- #
$apiUrls = @("YourPrismAPIAddress")

try {
    $username      = "YourUsername"
    $passwordFile  = "$pwdLocation\encrypted-password-file"
    $keyFile       = "$pwdLocation\encryption-key-file.key"
    $key           = Get-Content $keyFile

    $secureCreds = New-Object System.Management.Automation.PSCredential ($username, (Get-Content $passwordFile | ConvertTo-SecureString -Key $key))

    $authBytes = [System.Text.Encoding]::UTF8.GetBytes("{0}:{1}" -f $secureCreds.UserName, (
        [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureCreds.Password)
        )
    ))
    $authToken = [Convert]::ToBase64String($authBytes)

    Write-Output "$logDate - Credentials retrieved successfully" | Out-File -FilePath "$logLocation\log.txt" -Append
} catch {
    Write-Output "$logDate - Error retrieving credentials: $($_.Exception.Message)" | Out-File -FilePath "$logLocation\log.txt" -Append
}

# ----------------- POST request to API ----------------- #
foreach ($api in $apiUrls) {
    try {
        $request = @{
            Uri         = "https://CLUSTER_URI:9440/api/nutanix/v3/vms/list"
            Headers     = @{ 
                'Authorization' = "Basic $authToken"
                'Accept'        = 'application/json'
            }
            Method      = 'POST'
            Body        = '{
                "kind": "vm",
                "length": 500,
                "offset": 0
            }'
            ContentType = 'application/json'
        }

        $request.Uri = $request.Uri.Replace("CLUSTER_URI", $api)
        $response = Invoke-RestMethod @request

        foreach ($vm in $response.entities) {
            # Extract key values
            $cluster   = $vm.status.cluster_reference.name
            $vmName    = $vm.status.name
            $cpu       = $vm.status.resources.num_sockets
            $state     = $vm.status.resources.power_state
            $ip        = $vm.status.resources.nic_list.ip_endpoint_list.ip
            $memoryMB  = $vm.status.resources.memory_size_mib
            $memoryGB  = [Math]::Round($memoryMB / 1024)

            # Parse OS version
            $osFull = $vm.status.resources.guest_tools.nutanix_guest_tools.guest_os_version
            $os     = if ($osFull) { $osFull.Substring($osFull.LastIndexOf(":") + 1) } else { "Unknown" }

            # Parse disk sizes
            $diskSizes = @()
            foreach ($disk in $vm.status.resources.disk_list) {
                $sizeGB = [math]::Round($disk.disk_size_mib / 1024, 2)
                $diskSizes += $sizeGB
            }
            $diskSummary = ($diskSizes -join ",") -replace '^,', ''

            # Resolve hostname
            $hostIP = $vm.status.resources.host_reference.name
            $hostName = if ($hostIP) {
                $resolved = Resolve-DnsName -Name $hostIP -ErrorAction SilentlyContinue
                $resolved.NameHost
            } else { "N/A" }

            # Export to CSV
            "$currentDate;$cluster;$hostName;$vmName;$ip;$os;$memoryGB;$cpu;$diskSummary;$state;" | Out-File -FilePath "$csvLocation\ReportFile_$logDate.csv" -Encoding UTF8 -Append -Force
        }

        Write-Output "$logDate - $api - Executed successfully" | Out-File -FilePath "$logLocation\log.txt" -Append
    } catch {
        Write-Output "$logDate - $api - Error: $($_.Exception.Message)" | Out-File -FilePath "$logLocation\log.txt" -Append
    }
}
