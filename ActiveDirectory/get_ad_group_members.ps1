Clear-Host

$groupName = Read-Host -Prompt 'AD group name?'
$infoMember = Get-AdgroupMember "$groupName"

Clear-Host
Write-Host 'Members of '$groupName':'

foreach ($member in $infoMember) {
    Get-ADUser $member.samaccountname -Properties displayname | select displayname, name
}