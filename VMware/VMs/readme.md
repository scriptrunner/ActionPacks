# Manage Virtual machines

> Note: The use of the scripts requires the PowerShell VMware.PowerCLI

+ [Clone-VMHVVirtualMachine.ps1](./Clone-VMHVVirtualMachine.ps1)

  Creates a new virtual machine from a linked clone

+ [Copy-VMHVGuestFile.ps1](./Copy-VMHVGuestFile.ps1)

  Copies files and folders from and to the guest OS

+ [Dismount-VMHVTools.ps1](./Dismount-VMHVTools.ps1)

  Dismounts the VMware Tools installer CD

+ [Get-VMHVGuestSystem.ps1](./Get-VMHVGuestSystem.ps1)

  Retrieves the guest operating system of the specified virtual machine

+ [Get-VMHVSnapShot.ps1](./Get-VMHVSnapShot.ps1)

  Retrieves the virtual machine snapshot

+ [Get-VMHVVirtualMachine.ps1](./Get-VMHVVirtualMachine.ps1)

  Retrieves the virtual machines on a vCenter Server system

+ [Get-VMHVVirtualMachineStartPolicy.ps1](./Get-VMHVVirtualMachineStartPolicy.ps1)

  Retrieves the start policy of the virtual machine on a vCenter Server system

+ [Get-VMHVVMResourceConfiguration.ps1](./Get-VMHVVMResourceConfiguration.ps1)

  Retrieves information about the resource allocation between the selected virtual machine

+ [Install-VMHVTools.ps1](./Install-VMHVTools.ps1)

  Install VMtools on the virtual machine

+ [Invoke-VMHVGuestSystemCommand.ps1](./Invoke-VMHVGuestSystemCommand.ps1)

  Invokes a command for the specified virtual machine guest OS. 
  The acceptable commands are: Stop, Suspend, Restart

+ [Invoke-VMHVVirtualMachineCommand.ps1](./Invoke-VMHVVirtualMachineCommand.ps1)

  Invokes a command for the specified virtual machine.<br>
  The acceptable commands are: Start, Stop, Suspend, Restart

+ [Invoke-VMHVVMScript.ps1](./Invoke-VMHVVMScript.ps1)

  Runs a script in the guest OS of the specified virtual machine

+ [Mount-VMHVTools.ps1](./Mount-VMHVTools.ps1)

  Mounts the VMware Tools CD installer as a CD-ROM on the guest operating system

+ [Move-VMHVVirtualMachine.ps1](./Move-VMHVVirtualMachine.ps1)

  Move the virtual machine to another location

+ [New-VMHVSnapShot.ps1](./New-VMHVSnapShot.ps1)
  
  Creates a new snapshot of a virtual machine

+ [New-VMHVVirtualMachine.ps1](./New-VMHVVirtualMachine.ps1)
  
  Creates a new virtual machine

+ [New-VMHVVirtualMachineFromTemplate.ps1](./New-VMHVVirtualMachineFromTemplate.ps1)
  
  Creates a new virtual machine with use a the virtual machine template

+ [Register-VMHVVirtualMachine.ps1](./Register-VMHVVirtualMachine.ps1)
  
  Register a new virtual machine

+ [Remove-VMHVSnapShot.ps1](./Remove-VMHVSnapShot.ps1)

  Removes the specified virtual machine snapshot

+ [Remove-VMHVVirtualMachine.ps1](./Remove-VMHVVirtualMachine.ps1)

  Removes the specified virtual machine from the vCenter Server system

+ [Restore-VMHVVirtualMachine.ps1](./Restore-VMHVVirtualMachine.ps1)

  Revert the VM virtual machine to the specified snapshot

+ [Set-VMHVSnapShot.ps1](./Set-VMHVSnapShot.ps1)

  Modifies the specified virtual machine snapshot

+ [Set-VMHVVirtualMachine.ps1](./Set-VMHVVirtualMachine.ps1)
  
  Modifies the configuration of the virtual machine

+ [Set-VMHVVirtualMachineStartPolicy.ps1](./Set-VMHVVirtualMachineStartPolicy.ps1)

  Modifies the virtual machine start policy

+ [Set-VMHVVMResourceConfiguration.ps1](./Set-VMHVVMResourceConfiguration.ps1)

  Configures resource allocation between the virtual machine

+ [Update-VMHVTools.ps1](./Update-VMHVTools.ps1)

  Upgrades VMware Tools on the specified virtual machine guest OS