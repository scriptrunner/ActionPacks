#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the names of the virtual SCSI controllers assigned to the specified HardDisk, VirtualMachine, Template, or Snapshot object

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Disks

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMName
    Specifies the virtual machine from which you want to retrieve the SCSI controllers 
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$VMName
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }

    $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop        
    $Script:harddisks = Get-HardDisk -Server $Script:vmServer -VM $vm -ErrorAction Stop
    $script:disks = Get-ScsiController -Server $Script:vmServer -HardDisk $Script:harddisks -ErrorAction Stop | Select-Object * | Sort-Object Name

    foreach($item in $Script:disks)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.Name
            $SRXEnv.ResultList2 += "$($item.Parent) - $($item.Name)" # Display
        }
        else{
            Write-Output "$($item.Parent) - $($item.Name)"
        }
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}