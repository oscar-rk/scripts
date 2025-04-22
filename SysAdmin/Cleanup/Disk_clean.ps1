# Set log file path
$logFile = "$env:USERPROFILE\Desktop\ProfileCleanup.log"
function Log-Message {
    param ($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
}

==========================================================
==========================================================

# Clean orphaned users
function Clean-OrphanedProfiles {
    $oneYearAgo = (Get-Date).AddYears(-1)
    $userProfiles = Get-WmiObject -Class Win32_UserProfile
    $orphanedProfiles = @()
    $inactiveProfiles = @()

    foreach ($profile in $userProfiles) {
        $userSID = $profile.SID
        $lastUse = [Management.ManagementDateTimeConverter]::ToDateTime($profile.LastUseTime)
        $userAccount = $null

        try {
            $userAccount = [System.Security.Principal.SecurityIdentifier]::new($userSID).Translate([System.Security.Principal.NTAccount]).Value
        } catch {
            Write-Host ("Error resolving SID {0}: {1}" -f $userSID, $_.Exception.Message) -ForegroundColor Red
            Log-Message ("[ERROR] Failed to resolve SID {0}: {1}" -f $userSID, $_.Exception.Message)
        }

        # Skip system accounts
        if ($userAccount -match "NT AUTHORITY|LOCAL SERVICE|NETWORK SERVICE") {
            Write-Host "[i] Skipping system account: $userAccount" -ForegroundColor Cyan
            Log-Message "[INFO] Skipped system account: $userAccount"
            continue
        }

        if ($userAccount -eq $null) { 
            $orphanedProfiles += $profile
            Write-Host "`n[!] Orphaned profile detected: SID $userSID" -ForegroundColor Yellow
        } elseif ($lastUse -lt $oneYearAgo) {
            $inactiveProfiles += $profile
            Write-Host "`n[!] Inactive profile detected: $userAccount (Last login: $lastUse)" -ForegroundColor Yellow
        }
    }

    # Ask user for bulk deletion of orphaned profiles
    if ($orphanedProfiles.Count -gt 0) {
        $confirm = Read-Host "Do you want to delete ALL orphaned profiles? (Y/N)"
        if ($confirm -match "^[Yy]$") {
            foreach ($profile in $orphanedProfiles) {
                try {
                    Remove-WmiObject -InputObject $profile
                    Write-Host "[✔] Deleted orphaned profile with SID $($profile.SID)" -ForegroundColor Green
                    Log-Message "[SUCCESS] Deleted orphaned profile: SID $($profile.SID)"
                } catch {
                    Write-Host "[X] Failed to delete orphaned profile with SID $($profile.SID): $_" -ForegroundColor Red
                    Log-Message "[ERROR] Failed to delete orphaned profile: SID $($profile.SID) - $_"
                }
            }
        } else {
            Write-Host "[i] Skipped deletion of orphaned profiles." -ForegroundColor Cyan
            Log-Message "[INFO] Skipped deletion of orphaned profiles."
        }
    }
}

==========================================================
==========================================================

# Clean inactive users
function Clean-InactiveProfiles {
    if ($inactiveProfiles.Count -gt 0) {
        $confirm = Read-Host "Do you want to delete ALL inactive profiles? (Y/N)"
        if ($confirm -match "^[Yy]$") {
            foreach ($profile in $inactiveProfiles) {
                try {
                    Remove-WmiObject -InputObject $profile
                    Write-Host "[✔] Deleted inactive profile: $($profile.LocalPath)" -ForegroundColor Green
                    Log-Message "[SUCCESS] Deleted inactive profile: $($profile.LocalPath)"
                } catch {
                    Write-Host "[X] Failed to delete inactive profile: $($profile.LocalPath): $_" -ForegroundColor Red
                    Log-Message "[ERROR] Failed to delete inactive profile: $($profile.LocalPath) - $_"
                }
            }
        } else {
            Write-Host "[i] Skipped deletion of inactive profiles." -ForegroundColor Cyan
            Log-Message "[INFO] Skipped deletion of inactive profiles."
        }
    }
}

==========================================================
==========================================================

# Clean bins
function Clean-RecycleBin {
    Write-Host "[i] Cleaning all user recycle bins..."
    $recycleBinPath = 'C:\$Recycle.Bin'
    if (Test-Path $recycleBinPath) {
        Get-ChildItem -Path $recycleBinPath -Force | Remove-Item -Recurse -Force
        Write-Host "[✔] All recycle bins emptied." -ForegroundColor Green
        Log-Message "[SUCCESS] Emptied all recycle bins."
    } else {
        Write-Host "[X] Recycle bin path not found." -ForegroundColor Red
        Log-Message "[ERROR] Recycle bin path not found."
    }
}

==========================================================
==========================================================

# Call Cleanmgr.exe
function Run-Cleanmgr {
    Write-Host "[i] Running Cleanmgr..."
    cleanmgr /sagerun:1
    Log-Message "[INFO] Ran Cleanmgr with /sagerun:1"
}

==========================================================
==========================================================

# Call DISM tool
function Run-DISM {
    Write-Host "[i] Running DISM cleanup..."
    dism.exe /online /cleanup-image /startcomponentcleanup
    Log-Message "[INFO] Ran DISM cleanup"
}

==========================================================
==========================================================

# Clean CCMCache folder
function Clean-CCMCache {
    Write-Host "[i] Cleaning CCMCache..."
    $ccmCachePath = "C:\Windows\ccmcache"
    if (Test-Path $ccmCachePath) {
        Remove-Item "$ccmCachePath\*" -Recurse -Force
        Write-Host "[✔] CCMCache cleaned" -ForegroundColor Green
        Log-Message "[SUCCESS] Cleaned CCMCache"
    } else {
        Write-Host "[X] CCMCache path not found." -ForegroundColor Red
        Log-Message "[ERROR] CCMCache path not found."
    }
}

==========================================================
==========================================================

# Script start
Clean-OrphanedProfiles
Clean-InactiveProfiles
Clean-RecycleBin
Run-Cleanmgr
Run-DISM
Clean-CCMCache

Write-Host "`n[✔] Script execution completed. Log saved to $logFile" -ForegroundColor Green
