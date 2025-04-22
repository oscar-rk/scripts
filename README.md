<h1 align="center">
  <br>
  Scripts collection
  <br>
</h1>

<h4 align="center">Collection of useful scripts</h4>

<p align="center">
  <a href="#Infosec">Infosec</a> •
  <a href="#SysAdmin">SysAdmin</a> •
  <a href="#Cloud">Cloud</a> •
  <a href="#Automation">Automation</a>
</p>

---

## Infosec

#### Recon

- [extractPorts.sh](/Infosec/Recon/extractPorts.sh) --- Extract ports from nmap scan result.
- [portScan.sh](/Infosec/Recon/portScan.sh) --- Scan opened ports on target IP.
- [hostScan.sh](/Infosec/Recon/hostScan.sh) --- Scan active hosts on current network segment.
- [whichSystem.py](/Infosec/Recon/whichSystem.py) --- Identify running OS on target IP based on ping TTL value.

#### Discovery

- [procmon.sh](/Infosec/Discovery/procmon.sh) --- Monitor active processes.

## SysAdmin

#### Cleanup

- [clean_ccmcache.ps1](/SysAdmin/Cleanup/clean_ccmcache.ps1) --- Cleans the `ccmcache` folder on local or remote machines.
- [Disk_clean.ps1](/SysAdmin/Cleanup/Disk_clean.ps1) --- Cleans disk space by calling cleanup tools and deleting temp files, orphaned profiles, and inactive users.
- [mass_delete_localuser.ps1](/SysAdmin/Cleanup/mass_delete_localuser.ps1) --- Deletes a specified local user from a list of target servers.

#### Diagnostics

- [mass_ping.ps1](/SysAdmin/Diagnostics/mass_ping.ps1) --- Performs a ping sweep against a list of servers defined in a text file.
- [mass_restart_services.ps1](/SysAdmin/Diagnostics/mass_restart_services.ps1) --- Restarts a specified service across multiple servers listed in a `.txt` file.
- [get_shutdown_restart_logs.ps1](/SysAdmin/Diagnostics/get_shutdown_restart_logs.ps1) --- Gathers shutdown and restart logs from the event viewer for diagnostics.
- [ServerRestart.ps1](/SysAdmin/Diagnostics/ServerRestart.ps1) --- Remotely restarts a target server.

#### Storage

- [get-mpio.ps1](/SysAdmin/Storage/get-mpio.ps1) --- Retrieves a list of MPIO disks and extracts their serial numbers (SN).
- [GetRemoteDiskInfo.ps1](/SysAdmin/Storage/GetRemoteDiskInfo.ps1) --- Collects disk, partition, and volume information using WMI, formats sizes into human-readable units, and exports the data to a CSV.

#### Utils

- [renameMachine.ps1](/SysAdmin/Utils/renameMachine.ps1) --- Rename domain machines.
- [keepAlive.ps1](/SysAdmin/Utils/keepAlive.ps1) --- Keep machine alive, not intrusive.

## SCCM

#### Deployment Utils

- [CollectionSummarization.ps1](/SCCM/CollectionSummarization.ps1) --- Connects to an SCCM site and triggers deployment summarization based on the specified software and action (Install/Uninstall).
- [ForcePolicyUpdate.ps1](/SCCM/ForcePolicyUpdate.ps1) --- Forces a Configuration Manager client on a remote server to run the Machine Policy Retrieval and Evaluation Cycle via WMI.
- [MainCheckDeploy.ps1](/SCCM/MainCheckDeploy.ps1) --- Checks the SCCM deployment status (Install/Uninstall) for a specified software on a remote server via WMI.

## Virtualization

#### Nutanix

- [Get-Nutanix-VM.ps1](/Virtualization/Nutanix/Get-Nutanix-VM.ps1) --- Connects to one or more Nutanix Prism API endpoints, retrieves virtual machine information (IP, OS, CPU, memory, disks), and exports it to a CSV file. Also handles archiving of old files and execution logs.

## Active Directory

#### Queries

- [AD_owned.ps1](/ActiveDirectory/AD_owned.ps1) --- Displays ownership or group ownership for a specified Active Directory user.
- [get_ad_group_members.ps1](/ActiveDirectory/get_ad_group_members.ps1) --- Retrieves and displays the member list of a specified Active Directory group.

## Cloud

#### Azure

- [importHWID](/Cloud/Azure/importHWID) --- Import machine's HWID to Intune automatically. (Online)
- [extractHWID](/Cloud/Azure/extractHWID) --- Extract machine's HWID to CSV file automatically (supports append). (Offline)

## Automation

#### System Tasks

- [mkTree.sh](</Automation/System Tasks/mkTree.sh>) --- Automate creation of specific directory trees.
