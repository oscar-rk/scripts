# Change domain computer name
# Be aware of possible DNS problems

$cred = Get-Credential DOMAIN\USER # <- Replace with your domain admin user
Rename-Computer -ComputerName "oldName" -NewName "newName" -LocalCredential oldName\LocalAdmin -DomainCredential $cred -Force -PassThru # <- Replace name and user values
