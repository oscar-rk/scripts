SET-PSDebug -Trace 0
cls 

#initialization
Import-Module ActiveDirectory
$error.Clear()

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$domain = Read-Host "Enter domain of user account(s)"
$input = Read-Host "Enter all users, separated by a semiclon (no spaces)"
$users = $input.Split(";")
cls 

ForEach ($username in $users) {
    Write-Output "Results for $username"
    Try {
        $groups = Get-ADGroup -Filter {managedby -eq $username} -Properties Description,info -Server $domain | Select Name | Sort Name
        if ($groups -eq $null) {Write-Output "No owned groups.";Set-Clipboard -Value "No owned groups."} else {$groups}
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Output "Could not find user $username"
    }
    Write-Output ""
}
