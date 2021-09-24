# Manage hosts on a vCenter Server system

> Note: The use of the scripts requires the PowerShell VMware.PowerCLI


+ [Export-VMHVHostProfile.ps1](./Export-VMHVHostProfile.ps1)

  Exports the specified host profile to a file

+ [Format-VMHVHostDiskPartition.ps1](./Format-VMHVHostDiskPartition.ps1)

  Formats a new VMFS (Virtual Machine File System) on each of the specified host disk partition

+ [Get-VMHVHostHardware.ps1](./Get-VMHVHostHardware.ps1)

  Retrieves the host hardware and firmware information

+ [Get-VMHVHost.ps1](./Get-VMHVHost.ps1)

  Retrieves the hosts on a vCenter Server system

+ [Get-VMHVHostAccount.ps1](./Get-VMHVHostAccount.ps1)

  Retrieves the host accounts available on a vCenter Server system

+ [Get-VMHVHostDiagnosticPartition.ps1](./Get-VMHVHostDiagnosticPartition.ps1)

  Retrieves a list of the diagnostic partitions on the specified hosts

+ [Get-VMHVHostDisk.ps1](./Get-VMHVHostDisk.ps1)

  Retrieves information about the specified SCSI LUN disk

+ [Get-VMHVHostDiskPartition.ps1](./Get-VMHVHostDiskPartition.ps1)

  Retrieves the partitions of a host disk (LUN)

+ [Get-VMHVHostFirewallDefaultPolicy.ps1](./Get-VMHVHostFirewallDefaultPolicy.ps1)

  Retrieves the firewall default policy of the specified host

+ [Get-VMHVHostFirewallException.ps1](./Get-VMHVHostFirewallException.ps1)

  Retrieves the exceptions from the firewall policy on the specified host

+ [Get-VMHVHostFirmware.ps1](./Get-VMHVHostFirmware.ps1)

  Retrieves hosts firmware information

+ [Get-VMHVHostLogs.ps1](./Get-VMHVHostLogs.ps1)

  Retrieves entries from vSphere logs

+ [Get-VMHVHostLogType.ps1](./Get-VMHVHostLogType.ps1)

  Retrieves information about the log types available on a virtual machine host

+ [Get-VMHVHostNetwork.ps1](./Get-VMHVHostNetwork.ps1)

  Retrieves the host networks on a vCenter Server system

+ [Get-VMHVHostNetworkAdapter.ps1](./Get-VMHVHostNetworkAdapter.ps1)

  Retrieves the host network adapters on a vCenter Server system

+ [Get-VMHVHostPatch.ps1](./Get-VMHVHostPatch.ps1)

  Retrieves the host patches installed on the specified host

+ [Get-VMHVHostPCIDevice.ps1](./Get-VMHVHostPCIDevice.ps1)

  Retrieves the PCI devices on the specified hosts
  
+ [Get-VMHVHostProfile.ps1](./Get-VMHVHostProfile.ps1)

  Retrieves the available host profiles

+ [Get-VMHVHostRoute.ps1](./Get-VMHVHostRoute.ps1)

  Retrieves the routes from the routing table of the specified hosts
  
+ [Get-VMHVHostStartPolicy.ps1](./Get-VMHVHostStartPolicy.ps1)

  Retrieves the start policy of the host
  
+ [Get-VMHVHostStorage.ps1](./Get-VMHVHostStorage.ps1)

  Retrieves the host storages on a vCenter Server system
  
+ [Get-VMHVHostProfileRequiredInput.ps1](./Get-VMHVHostProfileRequiredInput.ps1)

  Check whether the available information is sufficient to apply a host profile, and returns missing values

+ [Import-VMHVHostProfile.ps1](./Import-VMHVHostProfile.ps1)

  Imports a host profile from a file

+ [Install-VMHVHostPatch.ps1](./Install-VMHVHostPatch.ps1)

  Updates the specified host

+ [Invoke-VMHVHostCommand.ps1](./Invoke-VMHVHostCommand.ps1)

  Invokes a command for the specified host.<br>
  The acceptable commands are: Start, Stop, Suspend, Restart
  
+ [Invoke-VMHVHostProfile.ps1](./Invoke-VMHVHostProfile.ps1)

  Applies a host profile to the specified host or cluster

+ [Invoke-VMHVHostServiceCommand.ps1](./Invoke-VMHVHostServiceCommand.ps1)

  Invokes a command for the specified host services.<br>
  The acceptable commands are: Start, Stop, Restart

+ [Move-VMHVHost.ps1](./Move-VMHVHost.ps1)

  Moves the specified host to another location
  
+ [New-VMHVHost.ps1](./New-VMHVHost.ps1)

  Creates a new host
  
+ [New-VMHVHostAcccount.ps1](./New-VMHVHostAccount.ps1)

  Creates a new host user account using the provided parameters

+ [New-VMHVHostNetworkAdapter.ps1](./New-VMHVHostNetworkAdapter.ps1)

  Creates a new HostVirtualNIC (Service Console or VMKernel) on the specified host
  
+ [New-VMHVHostProfile.ps1](./New-VMHVHostProfile.ps1)

  Creates a new host profile based on a reference host
  
+ [New-VMHVHostRoute.ps1](./New-VMHVHostRoute.ps1)

  Creates a new route in the routing table of a host

+ [Remove-VMHVHost.ps1](./Remove-VMHVHost.ps1)

  Removes the specified host from the inventory

+ [Remove-VMHVHostAccount.ps1](./Remove-VMHVHostAccount.ps1)

  Removes the specified host account

+ [Remove-VMHVHostNetworkAdapter.ps1](./Remove-VMHVHostNetworkAdapter.ps1)

  Configures the specified host network adapter
  
+ [Remove-VMHVHostProfile.ps1](./Remove-VMHVHostProfile.ps1)

  Removes the specified host profile

+ [Set-VMHVHost.ps1](./Set-VMHVHost.ps1)

  Modifies the configuration of the host

+ [Set-VMHVHostAccount.ps1](./Set-VMHVHostAccount.ps1)

  Configures a host account

+ [Set-VMHVHostDiagnosticPartition.ps1](./Set-VMHVHostDiagnosticPartition.ps1)

  Activates or deactivates the diagnostic partitions of host

+ [Set-VMHVHostFirewallDefaultPolicy.ps1](./Set-VMHVHostFirewallDefaultPolicy.ps1)

  Sets the default policy for the specified host firewall

+ [Set-VMHVHostFirewallException.ps1](./Set-VMHVHostFirewallException.ps1)

  Enables or disables host firewall exceptions  

+ [Set-VMHVHostFirmware.ps1](./Set-VMHVHostFirmware.ps1)

  Configures hosts firmware settings

+ [Set-VMHVHostNetwork.ps1](./Set-VMHVHostNetwork.ps1)

  Updates the specified virtual network

+ [Set-VMHVHostNetworkAdapter.ps1](./Set-VMHVHostNetworkAdapter.ps1)

  Configures the specified host network adapter

+ [Set-VMHVHostProfile.ps1](./Set-VMHVHostProfile.ps1)

  Modifies the specified host profile
  
+ [Set-VMHVHostStartPolicy.ps1](./Set-VMHVHostStartPolicy.ps1)

  Modifies the host default start policy
  
+ [Set-VMHVHostStorage.ps1](./Set-VMHVHostStorage.ps1)

  Retrieves the host storages on a vCenter Server system

+ [Test-VMHVHostProfileCompliance.ps1](./Test-VMHVHostProfileCompliance.ps1)

  Tests hosts for profile compliance